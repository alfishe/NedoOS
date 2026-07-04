/*
 * zmodem_os.c - NedoOS / atelnet platform layer for ZMP zmodem.c
 *
 * Direct OS_* file calls, telnet RX via netbuf (no extra copy buffer) and TX hook.
 * Does not implement ZMODEM protocol logic (that stays in zmodem_recv.c).
 */

#ifdef ATELNET_ZMODEM_RESIDENT
#pragma language=extended
#pragma codeseg(CODE_RESIDENT)
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "atelnet_plug.h"
#include "netglue.h"
#include "zmodem.h"

#define ZM_CPMBUF_SIZE 4096u
#define ZM_STATUS_W    80u
#define ZM_STATUS_FILL 79u   /* cols 1..79; leave col 80 empty (no CR/LF) */
#define ZM_PROG_STEP   16384L
#define ZM_COLOR_MSG   0x45u   /* bright cyan on black */
#define ZM_COLOR_ERR   0x42u   /* bright red on black */

/* Decoded ZMODEM bytes live in netbuf[0..nb_len); readline advances nb_pos. */
static unsigned int g_zm_nb_pos;
static unsigned int g_zm_nb_len;
static unsigned char g_zm_active;
static zm_tx_fn g_zm_tx;
static zm_poll_fn g_zm_poll;
static zm_flush_fn g_zm_flush;

unsigned char g_zm_skip_purge;

/* Secbuf/Txbuf scratch and Cpmbuf are both live during ZMODEM receive. */
static char g_zm_scratch[KSIZE + 1];
static char g_zm_cpmbuf[ZM_CPMBUF_SIZE];
static unsigned char g_zm_scratch_used;

static unsigned char g_zm_status_on;
static char g_zm_proto[20];
static char g_zm_name[32];
static char g_zm_size[16];
static char g_zm_time[12];
static char g_zm_line[ZM_STATUS_W + 1u];
static unsigned char g_zm_err_on;

static char g_zm_pathbuf[128];
static char g_zm_pathbuf2[128];
#ifdef ATELNET_ZMODEM_LOG
static unsigned char g_zm_logpath[128];
#endif

#define zm_os_err(fp)  (((int)(fp)) & 0xff)

/* OS returns handle in HL: H=slot, L=error. Slot 0 => value 0x0000 (not NULL!). */
static FILE g_zm_wr;
static unsigned char g_zm_wr_valid;
static FILE g_zm_rd;
static unsigned char g_zm_rd_valid;

static long g_zm_total_sz;
static long g_zm_prog_last;
static unsigned char g_zm_saved_path[128];
static unsigned char g_zm_fs_cwd;

static FILE *zm_hnd(FILE h)
{
  return (FILE *)(unsigned int)h;
}

static void zm_wr_drop(void)
{
  if (g_zm_wr_valid != 0u && !zm_os_err(g_zm_wr))
  {
    OS_CLOSEHANDLE(zm_hnd(g_zm_wr));
  }
  g_zm_wr = 0;
  g_zm_wr_valid = 0u;
}

static void zm_rd_drop(void)
{
  if (g_zm_rd_valid != 0u && !zm_os_err(g_zm_rd))
  {
    OS_CLOSEHANDLE(zm_hnd(g_zm_rd));
  }
  g_zm_rd = 0;
  g_zm_rd_valid = 0u;
}

static void zm_field_copy(char *dst, unsigned int dstlen, char *src);
static void zm_status_paint(char *msg, unsigned char is_err);

#ifdef ATELNET_ZMODEM_LOG
static void zm_disk_log(const char *tag, const char *msg);
static void zm_disk_log_wr(unsigned int req, int got);
#endif

static void zm_path_build(char *dst, unsigned int dstlen, char *leaf)
{
  if (dstlen == 0u || leaf == 0)
  {
    return;
  }
  zm_field_copy(dst, dstlen, leaf);
}

static void zm_fs_enter(void)
{
  if (g_zm_fs_cwd != 0u)
  {
    return;
  }
  at_path_to_downloads(g_zm_saved_path);
  g_zm_fs_cwd = 1u;
}

static void zm_fs_leave(void)
{
  if (g_zm_fs_cwd == 0u)
  {
    return;
  }
  OS_CHDIR(g_zm_saved_path);
  g_zm_fs_cwd = 0u;
}

static void zm_downloads_ensure(void)
{
  zm_fs_enter();
}

static void zm_prog_reset(void)
{
  g_zm_total_sz = 0L;
  g_zm_prog_last = -ZM_PROG_STEP;
}

static void zm_prog_show(long cur)
{
  unsigned long cur_kb;
  unsigned long total_kb;

  if (cur < 0L)
  {
    cur = 0L;
  }
  cur_kb = (unsigned long)(cur / 1024L);
  if (g_zm_total_sz > 0L)
  {
    total_kb = (unsigned long)((g_zm_total_sz + 1023L) / 1024L);
    sprintf(g_zm_line, "ZMODEM %lu kb of %lu kb dl", cur_kb, total_kb);
  }
  else
  {
    sprintf(g_zm_line, "ZMODEM %lu kb downloaded", cur_kb);
  }
  zm_status_paint(g_zm_line, 0u);
}

#ifdef ATELNET_ZMODEM_LOG

void writeLog(const char *logline, const char *place)
{
  FILE *LogFile;
  unsigned long fileSize;
  char hdr[32];
  unsigned int n;

  OS_GETPATH((unsigned int)&g_zm_logpath);
  OS_SETSYSDRV();
  LogFile = OS_OPENHANDLE((unsigned char *)"../telnet.log", 0x80u);
  if (zm_os_err(LogFile))
  {
    LogFile = OS_CREATEHANDLE((unsigned char *)"../telnet.log", 0x80u);
    OS_CLOSEHANDLE(LogFile);
    LogFile = OS_OPENHANDLE((unsigned char *)"../telnet.log", 0x80u);
  }
  if (zm_os_err(LogFile))
  {
    OS_CHDIR(g_zm_logpath);
    return;
  }

  fileSize = OS_GETFILESIZE(LogFile);
  OS_SEEKHANDLE(LogFile, fileSize);

  sprintf(hdr, "%7lu : ", time());
  OS_WRITEHANDLE((unsigned char *)hdr, LogFile, (unsigned int)strlen(hdr));
  if (place != 0)
  {
    n = (unsigned int)strlen(place);
    if (n > 8u)
    {
      n = 8u;
    }
    OS_WRITEHANDLE((unsigned char *)place, LogFile, n);
    OS_WRITEHANDLE((unsigned char *)" : ", LogFile, 3u);
  }
  if (logline != 0)
  {
    n = (unsigned int)strlen(logline);
    if (n > 160u)
    {
      n = 160u;
    }
    OS_WRITEHANDLE((unsigned char *)logline, LogFile, n);
  }
  OS_WRITEHANDLE((unsigned char *)"\r\n", LogFile, 2u);
  OS_CLOSEHANDLE(LogFile);
  OS_CHDIR(g_zm_logpath);
}

void zm_log(const char *line)
{
  writeLog(line, "ZM      ");
}

static void zm_disk_log(const char *tag, const char *msg)
{
  writeLog(msg, tag);
}

static void zm_disk_log_wr(unsigned int req, int got)
{
  char buf[16];

  sprintf(buf, "%u/%d", req, got);
  zm_disk_log("ZM-wr   ", buf);
}

#endif /* ATELNET_ZMODEM_LOG */

#ifndef ATELNET_ZMODEM_LOG
#define zm_disk_log(tag, msg) ((void)0)
#define zm_disk_log_wr(req, got) ((void)0)
#endif

static void zm_field_copy(char *dst, unsigned int dstlen, char *src)
{
  unsigned int i;

  if (dstlen == 0u)
  {
    return;
  }
  if (src == 0)
  {
    dst[0] = 0;
    return;
  }
  for (i = 0u; i < dstlen - 1u && src[i] != 0; i++)
  {
    dst[i] = src[i];
  }
  dst[i] = 0;
}

static unsigned char zm_status_is_error(char *msg)
{
  char *p;

  if (msg == 0 || msg[0] == 0)
  {
    return 0u;
  }
  for (p = msg; *p != 0; p++)
  {
    if ((*p == 'f' || *p == 'F') && strncmp(p, "fail", 4) == 0)
    {
      return 1u;
    }
    if ((*p == 'e' || *p == 'E') && strncmp(p, "error", 5) == 0)
    {
      return 1u;
    }
    if ((*p == 'c' || *p == 'C') && strncmp(p, "Cannot", 6) == 0)
    {
      return 1u;
    }
  }
  return 0u;
}

static void zm_status_paint(char *msg, unsigned char is_err)
{
  unsigned int i;
  unsigned int len;

  if (msg == 0 || msg[0] == 0)
  {
    return;
  }
  len = 0u;
  while (msg[len] != 0 && len < ZM_STATUS_W - 1u)
  {
    len++;
  }
  term_set_xy(0u, ZM_STATUS_ROW);
  term_set_color(is_err != 0u ? ZM_COLOR_ERR : ZM_COLOR_MSG);
  for (i = 0u; i < len; i++)
  {
    term_putchar((unsigned char)msg[i]);
  }
  for (; i < ZM_STATUS_FILL; i++)
  {
    term_putchar((unsigned char)' ');
  }
  term_set_color(0x07u);
}

static void zm_status_render(void)
{
  unsigned int n;

  if (g_zm_status_on == 0u)
  {
    return;
  }
  if (g_zm_err_on != 0u)
  {
    zm_status_paint(g_zm_line, 1u);
    return;
  }

  g_zm_line[0] = 0;
  if (g_zm_proto[0] != 0)
  {
    zm_field_copy(g_zm_line, (unsigned int)sizeof(g_zm_line), g_zm_proto);
  }
  if (g_zm_name[0] != 0)
  {
    n = (unsigned int)strlen(g_zm_line);
    if (n > 0u && n < ZM_STATUS_W - 1u)
    {
      g_zm_line[n] = ' ';
      g_zm_line[n + 1u] = 0;
    }
    strncat(g_zm_line, g_zm_name, (unsigned int)(ZM_STATUS_W - strlen(g_zm_line)));
  }
  if (g_zm_size[0] != 0)
  {
    n = (unsigned int)strlen(g_zm_line);
    if (n > 0u && n < ZM_STATUS_W - 1u)
    {
      g_zm_line[n] = ' ';
      g_zm_line[n + 1u] = 0;
    }
    strncat(g_zm_line, g_zm_size, (unsigned int)(ZM_STATUS_W - strlen(g_zm_line)));
  }
  if (g_zm_time[0] != 0)
  {
    n = (unsigned int)strlen(g_zm_line);
    if (n > 0u && n < ZM_STATUS_W - 1u)
    {
      g_zm_line[n] = ' ';
      g_zm_line[n + 1u] = 0;
    }
    strncat(g_zm_line, g_zm_time, (unsigned int)(ZM_STATUS_W - strlen(g_zm_line)));
  }
  g_zm_line[ZM_STATUS_W] = 0;
  zm_status_paint(g_zm_line, 0u);
}

void zm_status_line(char *msg)
{
  g_zm_status_on = 1u;
  g_zm_err_on = 0u;
  g_zm_proto[0] = 0;
  g_zm_name[0] = 0;
  g_zm_size[0] = 0;
  g_zm_time[0] = 0;
  zm_field_copy(g_zm_line, (unsigned int)sizeof(g_zm_line), msg);
  zm_status_paint(g_zm_line, zm_status_is_error(msg));
}

void zm_status_clear(void)
{
  g_zm_status_on = 0u;
  g_zm_err_on = 0u;
  g_zm_proto[0] = 0;
  g_zm_name[0] = 0;
  g_zm_size[0] = 0;
  g_zm_time[0] = 0;
  g_zm_line[0] = 0;
}

static unsigned int zm_elapsed_sec(unsigned long t0, unsigned long t1)
{
  unsigned int a;
  unsigned int b;

  a = (unsigned int)(((t0 >> 11) & 31u) * 3600u + ((t0 >> 5) & 63u) * 60u + (t0 & 31u) * 2u);
  b = (unsigned int)(((t1 >> 11) & 31u) * 3600u + ((t1 >> 5) & 63u) * 60u + (t1 & 31u) * 2u);
  if (b >= a)
  {
    return b - a;
  }
  return (unsigned int)(86400u - a + b);
}

static void zm_nb_clear(void)
{
  g_zm_nb_pos = 0u;
  g_zm_nb_len = 0u;
}

unsigned char zm_io_nb_pending(void)
{
  return (g_zm_nb_pos < g_zm_nb_len) ? 1u : 0u;
}

void zm_io_nb_supply(unsigned int len)
{
  g_zm_nb_pos = 0u;
  g_zm_nb_len = len;
}

void zm_io_begin(zm_tx_fn tx, zm_poll_fn poll, zm_flush_fn flush)
{
  g_zm_tx = tx;
  g_zm_poll = poll;
  g_zm_flush = flush;
  g_zm_active = 1u;
  g_zm_skip_purge = 0u;
  zm_nb_clear();
  zm_prog_reset();
  zm_fs_enter();
  ZM_LOG("session begin");
}

void zm_io_end(void)
{
  ZM_LOG("session end");
  g_zm_active = 0u;
  g_zm_skip_purge = 0u;
  g_zm_tx = 0;
  g_zm_poll = 0;
  g_zm_flush = 0;
  zm_nb_clear();
  zm_wr_drop();
  zm_rd_drop();
  zm_fs_leave();
}

unsigned char zm_io_active(void)
{
  return g_zm_active;
}

void zm_io_rx(unsigned char b)
{
  if (g_zm_active != 0u && g_zm_nb_pos >= g_zm_nb_len)
  {
    netbuf[0] = b;
    g_zm_nb_pos = 0u;
    g_zm_nb_len = 1u;
  }
}

void zm_io_drain_input(void)
{
  unsigned int i;
  int pr;

  for (i = 0u; i < 512u; i++)
  {
    if (g_zm_poll == 0)
    {
      break;
    }
    zm_nb_clear();
    pr = g_zm_poll();
    if (pr <= 0)
    {
      break;
    }
  }
  zm_nb_clear();
}

/* ---- NedoOS file layer (up to 8 handles; log and data use separate fp) ---- */

int zm_creat(char *path, int mode)
{
  unsigned char flags;

  flags = 0x80u;
  if (mode != 0)
  {
    flags = 0x80u;
  }
  zm_downloads_ensure();
  zm_path_build(g_zm_pathbuf, (unsigned int)sizeof(g_zm_pathbuf), path);
  zm_rd_drop();
  zm_wr_drop();
  g_zm_wr = (FILE)(unsigned int)OS_CREATEHANDLE((unsigned char *)g_zm_pathbuf, flags);
  if (zm_os_err(g_zm_wr))
  {
    g_zm_wr = 0;
    g_zm_wr_valid = 0u;
    zm_disk_log("ZM-crt  ", "FAIL");
    return UBIOT;
  }
  g_zm_wr_valid = 1u;
  zm_disk_log("ZM-crt  ", g_zm_pathbuf);
  return 0;
}

int zm_open(char *path, int mode)
{
  unsigned char flags;

  flags = 0x80u;
  if (mode != 0)
  {
    flags = 0x80u;
  }
  zm_downloads_ensure();
  zm_path_build(g_zm_pathbuf, (unsigned int)sizeof(g_zm_pathbuf), path);
  zm_rd_drop();
  g_zm_rd = (FILE)(unsigned int)OS_OPENHANDLE((unsigned char *)g_zm_pathbuf, flags);
  if (zm_os_err(g_zm_rd))
  {
    g_zm_rd = 0;
    g_zm_rd_valid = 0u;
    return UBIOT;
  }
  g_zm_rd_valid = 1u;
  zm_disk_log("ZM-opn  ", g_zm_pathbuf);
  return 0;
}

int zm_close(int fd)
{
  if (fd == UBIOT)
  {
    return OK;
  }
  if (g_zm_wr_valid != 0u && !zm_os_err(g_zm_wr))
  {
    if (zm_os_err(OS_CLOSEHANDLE(zm_hnd(g_zm_wr))))
    {
      g_zm_wr = 0;
      g_zm_wr_valid = 0u;
      zm_disk_log("ZM-cls  ", "FAIL");
      return NERROR;
    }
    g_zm_wr = 0;
    g_zm_wr_valid = 0u;
    zm_disk_log("ZM-cls  ", "ok");
    return OK;
  }
  if (g_zm_rd_valid != 0u && !zm_os_err(g_zm_rd))
  {
    if (zm_os_err(OS_CLOSEHANDLE(zm_hnd(g_zm_rd))))
    {
      g_zm_rd = 0;
      g_zm_rd_valid = 0u;
      zm_disk_log("ZM-cls  ", "FAIL");
      return NERROR;
    }
    g_zm_rd = 0;
    g_zm_rd_valid = 0u;
    zm_disk_log("ZM-cls  ", "ok");
    return OK;
  }
  zm_disk_log("ZM-cls  ", "noop");
  return OK;
}

int zm_read(int fd, char *buf, int count)
{
  unsigned int n;

  if (fd == UBIOT || count <= 0 || g_zm_rd_valid == 0u || zm_os_err(g_zm_rd))
  {
    return NERROR;
  }
  n = OS_READHANDLE((unsigned char *)buf, zm_hnd(g_zm_rd), (unsigned int)count);
  return (int)n;
}

int zm_write(int fd, char *buf, int count)
{
  unsigned int n;

  if (fd == UBIOT || count <= 0 || g_zm_wr_valid == 0u || zm_os_err(g_zm_wr))
  {
    if (g_zm_wr_valid == 0u)
    {
      zm_disk_log("ZM-wr   ", "no hnd");
    }
    else if (zm_os_err(g_zm_wr))
    {
      zm_disk_log("ZM-wr   ", "bad hnd");
    }
    else
    {
      zm_disk_log("ZM-wr   ", "bad arg");
    }
    return NERROR;
  }
  n = OS_WRITEHANDLE((unsigned char *)buf, zm_hnd(g_zm_wr), (unsigned int)count);
  if (n != (unsigned int)count)
  {
    zm_disk_log_wr((unsigned int)count, (int)n);
    return (int)n;
  }
  zm_disk_log_wr((unsigned int)count, (int)n);
  return (int)n;
}

int zm_unlink(char *path)
{
  zm_path_build(g_zm_pathbuf, (unsigned int)sizeof(g_zm_pathbuf), path);
  if (OS_DELETE((unsigned char *)g_zm_pathbuf) != 0u)
  {
    zm_disk_log("ZM-del  ", "FAIL");
    return NERROR;
  }
  zm_disk_log("ZM-del  ", g_zm_pathbuf);
  return OK;
}

int zm_rename(char *oldpath, char *newpath)
{
  zm_path_build(g_zm_pathbuf, (unsigned int)sizeof(g_zm_pathbuf), oldpath);
  zm_path_build(g_zm_pathbuf2, (unsigned int)sizeof(g_zm_pathbuf2), newpath);
  if (OS_RENAME((unsigned char *)g_zm_pathbuf, (unsigned char *)g_zm_pathbuf2) != 0u)
  {
    zm_disk_log("ZM-ren  ", "FAIL");
    return NERROR;
  }
  zm_disk_log("ZM-ren  ", g_zm_pathbuf);
  return OK;
}

long zm_lseek(int fd, long offset, int whence)
{
  if (fd == UBIOT || g_zm_rd_valid == 0u || zm_os_err(g_zm_rd))
  {
    return -1L;
  }
  if (whence != 0)
  {
    return -1L;
  }
  OS_SEEKHANDLE(zm_hnd(g_zm_rd), (unsigned long)offset);
  return offset;
}

/* ---- memory (static buffers for receive path) ---- */

char *alloc(int n)
{
  if (n <= (int)sizeof(g_zm_scratch) && g_zm_scratch_used == 0u)
  {
    g_zm_scratch_used = 1u;
    return g_zm_scratch;
  }
  return 0;
}

char *grabmem(unsigned *size)
{
  *size = (unsigned)sizeof(g_zm_cpmbuf);
  return g_zm_cpmbuf;
}

int allocerror(char *p)
{
  return p == 0;
}

void zm_memfree(char *p)
{
  if (p == g_zm_cpmbuf || p == g_zm_scratch)
  {
    if (p == g_zm_scratch)
    {
      g_zm_scratch_used = 0u;
    }
    return;
  }
  free(p);
}

/* ---- modem I/O (TCP chunk in netbuf, next read only when consumed) ---- */

/*
 * Copy plain (non-ZDLE) bytes already in netbuf; same skip rules as zdlread().
 * Does not block ? returns 0 when netbuf is empty (caller uses zdlread/readline).
 */
unsigned zm_rx_take_plain(char *dst, unsigned max, int zctlesc)
{
  unsigned n = 0;
  int c;

  while (n < max && g_zm_nb_pos < g_zm_nb_len)
  {
    c = (int)netbuf[g_zm_nb_pos];
    if (c == ZDLE)
    {
      break;
    }
    if (c == 023 || c == 0223 || c == 021 || c == 0221)
    {
      g_zm_nb_pos++;
      continue;
    }
    if (zctlesc != 0 && !(c & 0140))
    {
      g_zm_nb_pos++;
      continue;
    }
    dst[n++] = (char)c;
    g_zm_nb_pos++;
  }
  return n;
}

#define ZM_RX_ABORT_MASK  0xFFFu  /* opabort every 4096 idle YIELDs in readline */

int readline(int timeout)
{
  int pr;
  static unsigned idle;

  /* timeout is legacy (tenths of a second on CP/M); telnet waits for data. */
  timeout = timeout;
  for (;;)
  {
    if (g_zm_nb_pos < g_zm_nb_len)
    {
      return (int)netbuf[g_zm_nb_pos++];
    }
    if (g_zm_flush != 0)
    {
      g_zm_flush();
    }
    if (g_zm_poll != 0)
    {
      do
      {
        pr = g_zm_poll();
        if (pr < 0)
        {
          zm_log("readline RCDO socket err");
          return RCDO;
        }
        if (g_zm_nb_pos < g_zm_nb_len)
        {
          return (int)netbuf[g_zm_nb_pos++];
        }
      } while (pr > 0);
    }
    if (QuitFlag != 0)
    {
      zm_log("readline RCDO QuitFlag");
      return RCDO;
    }
    if ((idle++ & ZM_RX_ABORT_MASK) == 0u)
    {
      opabort();
    }
    if (QuitFlag != 0)
    {
      zm_log("readline RCDO ESC");
      return RCDO;
    }
    YIELD();
  }
}

int readock(int timeout, int flag)
{
  int c;

  c = readline(timeout);
  if (flag < 0)
  {
    return TIMEOUT;
  }
  if (c == TIMEOUT)
  {
    return TIMEOUT;
  }
  if (c == RCDO)
  {
    return RCDO;
  }
  return c;
}

int minprdy(void)
{
  return (g_zm_nb_pos < g_zm_nb_len) ? TRUE : FALSE;
}

int mcharinp(void)
{
  if (g_zm_nb_pos >= g_zm_nb_len)
  {
    return 0;
  }
  return (int)netbuf[g_zm_nb_pos++];
}

void mcharout(char c)
{
  if (g_zm_tx != 0)
  {
    g_zm_tx((unsigned char)c);
  }
}

void purgeline(void)
{
  if (g_zm_skip_purge != 0u)
  {
    return;
  }
  zm_nb_clear();
}

int opabort(void)
{
  unsigned char key;

  key = (unsigned char)(OS_GETKEY() & 0xFFL);
  if (key == 0u)
  {
    return FALSE;
  }
  if (key == 27u || key == 24u || key == 176u)
  {
    QuitFlag = TRUE;
    return TRUE;
  }
  return FALSE;
}

void flush(void)
{
  if (g_zm_flush != 0)
  {
    g_zm_flush();
  }
}

void wait(int sec)
{
  unsigned long t0;

  t0 = OS_GETTIME();
  while (zm_elapsed_sec(t0, OS_GETTIME()) < (unsigned int)sec)
  {
    YIELD();
  }
}

void mswait(int ms)
{
  unsigned int i;

  for (i = 0u; i < (unsigned int)ms * 40u; i++)
  {
    YIELD();
  }
}

void sendbrk(void)
{
  unsigned char i;

  for (i = 0u; i < 8u; i++)
  {
    mcharout((char)CAN);
  }
}

void mstrout(char *s, int crlf)
{
  while (s != 0 && *s != 0)
  {
    mcharout(*s);
    s++;
  }
  if (crlf != 0)
  {
    mcharout(CR);
    mcharout(LF);
  }
}

int chrin(void)
{
  unsigned char key;

  for (;;)
  {
    key = (unsigned char)(OS_GETKEY() & 0xFFL);
    if (key != 0u)
    {
      return (int)key;
    }
    YIELD();
  }
}

int getpathname(char *prompt)
{
  return prompt != 0 ? 0 : 0;
}

void freepath(int count)
{
  if (count < 0)
  {
    return;
  }
}

int openerror(int fd, char *name, int mode)
{
  if (fd == UBIOT)
  {
    zperr("Cannot open file", TRUE);
    report(PATHNAME, name);
    return TRUE;
  }
  if (mode < 0)
  {
    return FALSE;
  }
  return FALSE;
}

void fstat(char *name, struct stat *st)
{
  FILINFO fi;

  memset(st, 0, sizeof(*st));
  if (OS_GETFILINFO((unsigned char *)name, &fi) == 0u)
  {
    st->records = (int)((fi.fsize + 127u) / 128u);
  }
}

void deldrive(char *name)
{
  char *p;

  p = name;
  if (p[0] != 0 && p[1] == ':')
  {
    memmove(p, p + 2, strlen(p + 2) + 1u);
  }
}

void setmodtime(void)
{
}

int roundup(int n, int r)
{
  return ((n + r - 1) / r) * r;
}

/* ---- UI: single bottom status line, no box overlay ---- */

void locate(int line, int col)
{
  if (line != 0 || col != 0)
  {
    return;
  }
}

void putlabel(char *msg)
{
  if (msg != 0)
  {
    g_zm_status_on = 1u;
    zm_field_copy(g_zm_proto, (unsigned int)sizeof(g_zm_proto), "ZMODEM ESC=abort");
    zm_status_render();
  }
}

void clrline(int line)
{
  if (line == MESSAGE)
  {
    g_zm_err_on = 0u;
    zm_status_render();
  }
}

void report(int row, char *msg)
{
  g_zm_status_on = 1u;
  switch (row)
  {
  case PROTOCOL:
    zm_field_copy(g_zm_proto, (unsigned int)sizeof(g_zm_proto), msg);
    break;
  case PATHNAME:
    zm_field_copy(g_zm_name, (unsigned int)sizeof(g_zm_name), msg);
    if (msg != 0 && msg[0] != 0)
    {
#ifdef ATELNET_ZMODEM_LOG
      writeLog(msg, "ZM-name ");
#endif
    }
    break;
  case FILESIZE:
    zm_field_copy(g_zm_size, (unsigned int)sizeof(g_zm_size), msg);
    if (msg != 0 && msg[0] != 0)
    {
      g_zm_total_sz = atol(msg);
      g_zm_prog_last = -ZM_PROG_STEP;
#ifdef ATELNET_ZMODEM_LOG
      writeLog(msg, "ZM-size ");
#endif
      zm_prog_show(0L);
    }
    break;
  case SENDTIME:
    zm_field_copy(g_zm_time, (unsigned int)sizeof(g_zm_time), msg);
    break;
  case KBYTES:
    if (msg != 0 && msg[0] != 0)
    {
      long cur;

      cur = atol(msg);
      if (g_zm_total_sz > 0L && cur < g_zm_total_sz)
      {
        if (cur - g_zm_prog_last < ZM_PROG_STEP)
        {
          return;
        }
      }
      g_zm_prog_last = cur;
      zm_prog_show(cur);
    }
    return;
  case MESSAGE:
    zm_field_copy(g_zm_line, (unsigned int)sizeof(g_zm_line), msg);
    g_zm_err_on = 1u;
    if (msg != 0 && msg[0] != 0)
    {
#ifdef ATELNET_ZMODEM_LOG
      writeLog(msg, "ZM-err  ");
#endif
    }
    zm_status_paint(g_zm_line, 1u);
    return;
  default:
    break;
  }
  zm_status_render();
}

void box(void)
{
}

void savecurs(void)
{
}

void hidecurs(void)
{
}

void showcurs(void)
{
}

void restcurs(void)
{
}

int zmodem_session_receive(void)
{
  int rc;

  Zmodem = TRUE;
  Nozmodem = FALSE;
  Xmodem = FALSE;
  QuitFlag = FALSE;
  StopFlag = FALSE;
  rc = bringin('Z');
  return rc;
}
