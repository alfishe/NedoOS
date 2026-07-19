/*
 * zmodem_os.c - NedoOS / atelnet platform layer for ZMP zmodem.c
 *
 * Direct OS_* file calls, telnet RX via netbuf (no extra copy buffer) and TX hook.
 * Does not implement ZMODEM protocol logic (that stays in zmodem_recv.c).
 */


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "term.h"
#include "atelnet_plug.h"
#include "netglue.h"
#include "app_bank.h"
#include "zmodem.h"
#include "zmodem_datapage.h"
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

/* Bulk buffers live in g_dataPg (see zmodem_datapage.h); no main-image fallback. */

static unsigned char g_zm_status_on;
static char g_zm_proto[20];
static char g_zm_name[32];
static char g_zm_size[16];
static char g_zm_time[12];
static char g_zm_line[ZM_STATUS_W + 1u];
static unsigned char g_zm_err_on;

static char g_zm_pathbuf[128];
static char g_zm_pathbuf2[128];
static char *g_zm_paths[1];

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

static char *zm_dp_cpmbuf_ptr(void)
{
  return (char *)(unsigned int)(BANK_WINDOW_ADDR + ZM_DP_CPMBUF_OFF);
}

static char *zm_dp_secbuf_ptr(void)
{
  return (char *)(unsigned int)(BANK_WINDOW_ADDR + ZM_DP_SECBUF_OFF);
}

static int zm_dp_buf_mapped(char *buf)
{
  unsigned int addr;

  if (buf == 0)
  {
    return 0;
  }
  addr = (unsigned int)buf;
  return addr >= BANK_WINDOW_ADDR && addr < BANK_WINDOW_ADDR + ZM_DP_USED;
}

void zm_dp_map_ensure(void)
{
  if (g_dataPg == 0u)
  {
    return;
  }
  if (bank_window_current() != g_dataPg)
  {
    bank_window_map(g_dataPg);
  }
}

void zm_dp_pull_secbuf(char *dst, unsigned int dstlen)
{
  if (Secbuf != 0)
  {
    zm_dp_map_ensure();
    zm_field_copy(dst, dstlen, Secbuf);
  }
}


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

static const char *zm_prog_tag(void)
{
  if (g_zm_proto[0] == 'Y')
  {
    return "YMODEM";
  }
  if (g_zm_proto[0] == 'X')
  {
    return "XMODEM";
  }
  return "ZMODEM";
}

static void zm_prog_show(long cur)
{
  unsigned long cur_kb;
  unsigned long total_kb;
  const char *tag;
  const char *dir;

  if (cur < 0L)
  {
    cur = 0L;
  }
  cur_kb = (unsigned long)(cur / 1024L);
  tag = zm_prog_tag();
  dir = (Sending != 0) ? "ul" : "dl";
  if (g_zm_total_sz > 0L)
  {
    total_kb = (unsigned long)((g_zm_total_sz + 1023L) / 1024L);
    sprintf(g_zm_line, "%s %lu kb of %lu kb %s", tag, cur_kb, total_kb, dir);
  }
  else
  {
    sprintf(g_zm_line, "%s %lu kb %s", tag, cur_kb, dir);
  }
  zm_status_paint(g_zm_line, 0u);
}



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
}

void zm_io_end(void)
{
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

void zm_io_try_read(void)
{
  if (g_zm_poll != 0 && g_zm_nb_pos >= g_zm_nb_len)
  {
    g_zm_poll();
  }
}

int zm_io_peek(void)
{
  if (g_zm_nb_pos < g_zm_nb_len)
  {
    return (int)(unsigned char)netbuf[g_zm_nb_pos];
  }
  return -1;
}

/* ---- NedoOS file layer ---- */

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
    return UBIOT;
  }
  g_zm_wr_valid = 1u;
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
      return NERROR;
    }
    g_zm_wr = 0;
    g_zm_wr_valid = 0u;
    return OK;
  }
  if (g_zm_rd_valid != 0u && !zm_os_err(g_zm_rd))
  {
    if (zm_os_err(OS_CLOSEHANDLE(zm_hnd(g_zm_rd))))
    {
      g_zm_rd = 0;
      g_zm_rd_valid = 0u;
      return NERROR;
    }
    g_zm_rd = 0;
    g_zm_rd_valid = 0u;
    return OK;
  }
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

  if (zm_dp_buf_mapped(buf))
  {
    zm_dp_map_ensure();
  }

  if (fd == UBIOT || count <= 0 || g_zm_wr_valid == 0u || zm_os_err(g_zm_wr))
  {
    return NERROR;
  }
  n = OS_WRITEHANDLE((unsigned char *)buf, zm_hnd(g_zm_wr), (unsigned int)count);
  return (int)n;
}

int zm_unlink(char *path)
{
  zm_path_build(g_zm_pathbuf, (unsigned int)sizeof(g_zm_pathbuf), path);
  if (OS_DELETE((unsigned char *)g_zm_pathbuf) != 0u)
  {
    return NERROR;
  }
  return OK;
}

int zm_rename(char *oldpath, char *newpath)
{
  zm_path_build(g_zm_pathbuf, (unsigned int)sizeof(g_zm_pathbuf), oldpath);
  zm_path_build(g_zm_pathbuf2, (unsigned int)sizeof(g_zm_pathbuf2), newpath);
  if (OS_RENAME((unsigned char *)g_zm_pathbuf, (unsigned char *)g_zm_pathbuf2) != 0u)
  {
    return NERROR;
  }
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

int zm_wseek(int fd, long offset)
{
  if (fd == UBIOT || g_zm_wr_valid == 0u || zm_os_err(g_zm_wr))
  {
    return NERROR;
  }
  OS_SEEKHANDLE(zm_hnd(g_zm_wr), (unsigned long)offset);
  return OK;
}

/* ---- memory (Cpmbuf + Secbuf in g_dataPg @ C000 when bank is mapped) ---- */

char *alloc(int n)
{
  if (n > (int)ZM_DP_SECBUF_SIZE || g_dataPg == 0u)
  {
    return 0;
  }
  zm_dp_map_ensure();
  return zm_dp_secbuf_ptr();
}

char *grabmem(unsigned *size)
{
  *size = ZM_DP_CPMBUF_SIZE;
  if (g_dataPg == 0u)
  {
    return 0;
  }
  zm_dp_map_ensure();
  return zm_dp_cpmbuf_ptr();
}

int allocerror(char *p)
{
  return p == 0;
}

void zm_memfree(char *p)
{
  p = p;
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

unsigned zm_rx_take_raw(char *dst, unsigned max)
{
  unsigned n = 0;

  while (n < max && g_zm_nb_pos < g_zm_nb_len)
  {
    dst[n++] = netbuf[g_zm_nb_pos++];
  }
  return n;
}

#define ZM_RX_ABORT_MASK  0xFFFu  /* opabort every 4096 idle YIELDs while waiting for RX */

static int zm_rx_read_byte(void)
{
  int pr;
  static unsigned idle;

  for (;;)
  {
    if (g_zm_nb_pos < g_zm_nb_len)
    {
      return (int)(unsigned char)netbuf[g_zm_nb_pos++];
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
          return RCDO;
        }
        if (g_zm_nb_pos < g_zm_nb_len)
        {
          return (int)(unsigned char)netbuf[g_zm_nb_pos++];
        }
      } while (pr > 0);
    }
    if (QuitFlag != 0)
    {
      return RCDO;
    }
    if ((idle++ & ZM_RX_ABORT_MASK) == 0u)
    {
      opabort();
    }
    if (QuitFlag != 0)
    {
      return RCDO;
    }
    YIELD();
  }
}

unsigned zm_rx_read(char *dst, unsigned need)
{
  unsigned n = 0;
  int c;

  while (n < need)
  {
    unsigned got = zm_rx_take_raw(dst + n, need - n);

    n += got;
    if (n >= need)
    {
      break;
    }
    c = zm_rx_read_byte();
    if (c < 0)
    {
      return n;
    }
    dst[n++] = (char)c;
  }
  return n;
}

int readline(int timeout)
{
  /* timeout is legacy (tenths of a second on CP/M); telnet waits for data. */
  timeout = timeout;
  if (g_zm_nb_pos < g_zm_nb_len)
  {
    return (int)(unsigned char)netbuf[g_zm_nb_pos++];
  }
  return zm_rx_read_byte();
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
  if (Nozmodem != 0)
  {
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
  unsigned int n;
  unsigned char key;

  if (prompt == 0)
  {
    prompt = "";
  }
  Pathname[0] = 0;
  n = 0u;
  for (;;)
  {
    sprintf(g_zm_line, "Name%s: %s_", prompt, Pathname);
    zm_status_line(g_zm_line);
    do
    {
      key = (unsigned char)(OS_GETKEY() & 0xFFL);
      if (key != 0u)
      {
        break;
      }
      YIELD();
    } while (1);
    if (key == 13u || key == 253u)
    {
      break;
    }
    if (key == 27u)
    {
      Pathname[0] = 0;
      return 0;
    }
    if (key == 8u || key == 127u)
    {
      if (n > 0u)
      {
        n--;
        Pathname[n] = 0;
      }
      continue;
    }
    if (key >= 32u && key < 127u && n < (unsigned int)sizeof(Pathname) - 1u)
    {
      Pathname[n++] = (char)key;
      Pathname[n] = 0;
    }
  }
  if (Pathname[0] == 0)
  {
    return 0;
  }
  g_zm_paths[0] = Pathname;
  Pathlist = g_zm_paths;
  return 1;
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
    break;
  case FILESIZE:
    zm_field_copy(g_zm_size, (unsigned int)sizeof(g_zm_size), msg);
    if (msg != 0 && msg[0] != 0)
    {
      g_zm_total_sz = atol(msg);
      g_zm_prog_last = -ZM_PROG_STEP;
      zm_prog_show(0L);
    }
    return;
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
    zm_status_paint(g_zm_line, 1u);
    return;
  default:
    break;
  }
  /* Progress line (KBYTES) and errors (MESSAGE) paint themselves. */
  if (g_zm_total_sz == 0L && row != MESSAGE)
  {
    zm_status_render();
  }
}

void box(void)
{
}

void savecurs(void)
{
}

void hidecurs(void)
{
  term_cursor_hold_or(TERM_CURS_HOLD_ZM);
}

void showcurs(void)
{
  term_cursor_hold_and_not(TERM_CURS_HOLD_ZM);
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

int ymodem_session_receive(void)
{
  QuitFlag = FALSE;
  StopFlag = FALSE;
  Zmodem = FALSE;
  Nozmodem = TRUE;
  Xmodem = FALSE;
  return bringin('Y');
}

int xmodem_session_receive(void)
{
  extern int wcreceive(char *filename);

  if (Pathlist == 0 || Pathlist[0] == 0 || Pathlist[0][0] == 0)
  {
    return NERROR;
  }
  QuitFlag = FALSE;
  StopFlag = FALSE;
  Zmodem = FALSE;
  Nozmodem = FALSE;
  Xmodem = TRUE;
  return wcreceive(Pathlist[0]);
}

int zmodem_session_send(void)
{
  QuitFlag = FALSE;
  StopFlag = FALSE;
  return sendout('Z');
}

int ymodem_session_send(void)
{
  QuitFlag = FALSE;
  StopFlag = FALSE;
  return sendout('Y');
}

int xmodem_session_send(void)
{
  QuitFlag = FALSE;
  StopFlag = FALSE;
  Blklen = 128;
  return sendout('X');
}
