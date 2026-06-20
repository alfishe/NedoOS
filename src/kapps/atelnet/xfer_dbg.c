#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "xfer.h"
#include "xfer_dbg.h"

#define XDBG_RING 32u
#define XDBG_HEX_SHOW 10u
#define XDBG_RAW_MAX 256u
#define XDBG_LOG_LINE 56u
#define XDBG_LOG_HDR 48u

static const unsigned char g_log_raw[] = "../ini/zmrx.log";
static const unsigned char g_log_queue[] = "../ini/zmque.log";
static const char g_tag_zmrx[] = "zmrx";
static const char g_tag_queue[] = "queue";
static const char g_tag_zmtx[] = "zmtx";

static unsigned char g_xdbg_on;
static unsigned char g_xdbg_cap;
static unsigned char g_xdbg_tx[XDBG_RING];
static unsigned char g_xdbg_rx[XDBG_RING];
static unsigned char g_xdbg_txi;
static unsigned char g_xdbg_rxi;
static unsigned int g_xdbg_txtot;
static unsigned int g_xdbg_rxtot;

static unsigned char g_raw[XDBG_RAW_MAX];
static unsigned int g_raw_count;
static unsigned char g_tx_raw[128];
static unsigned int g_tx_raw_count;
static unsigned char g_qhist[256];
static unsigned int g_qhist_count;
static unsigned char g_dump_q[256];
static unsigned int g_dump_qlen;

static unsigned char g_saved_path[64];
static char g_log_buf[XDBG_LOG_LINE];

static FILE *xdbg_file_open_append(const unsigned char *path)
{
  FILE *fp;
  unsigned long fileSize;

  OS_GETPATH((unsigned int)g_saved_path);
  OS_SETSYSDRV();
  fp = OS_OPENHANDLE((unsigned char *)path, 0x80u);
  if (((int)fp) & 0xff)
  {
    fp = OS_CREATEHANDLE((unsigned char *)path, 0x80u);
    if (!(((int)fp) & 0xff))
    {
      OS_CLOSEHANDLE(fp);
    }
    fp = OS_OPENHANDLE((unsigned char *)path, 0x80u);
  }
  if (((int)fp) & 0xff)
  {
    OS_CHDIR(g_saved_path);
    return 0;
  }
  fileSize = OS_GETFILESIZE(fp);
  OS_SEEKHANDLE(fp, fileSize);
  return fp;
}

static void xdbg_file_close(FILE *fp)
{
  if (fp != 0)
  {
    OS_CLOSEHANDLE(fp);
  }
  OS_CHDIR(g_saved_path);
}

/* open -> seek end -> write -> close (как writeLog в esp-com.c) */
static void xdbg_file_append(const unsigned char *path, const unsigned char *data, unsigned int len)
{
  FILE *fp;

  if (data == 0 || len == 0u)
  {
    return;
  }
  fp = xdbg_file_open_append(path);
  if (fp == 0)
  {
    return;
  }
  (void)OS_WRITEHANDLE((unsigned char *)data, fp, len);
  xdbg_file_close(fp);
}

static void xdbg_file_reset(const unsigned char *path)
{
  FILE *fp;

  OS_GETPATH((unsigned int)g_saved_path);
  OS_SETSYSDRV();
  fp = OS_CREATEHANDLE((unsigned char *)path, 0x80u);
  if (!(((int)fp) & 0xff))
  {
    OS_CLOSEHANDLE(fp);
  }
  OS_CHDIR(g_saved_path);
}

static void xdbg_push(unsigned char *ring, unsigned char *idx, unsigned char b)
{
  ring[*idx] = b;
  *idx = (unsigned char)((*idx + 1u) % XDBG_RING);
}

static void xdbg_hex_tail(char *out, const unsigned char *ring, unsigned char idx, unsigned int total)
{
  static const char *hexd = "0123456789ABCDEF";
  unsigned int n;
  unsigned int i;
  unsigned int pos;
  unsigned int skip;

  pos = 0u;
  n = total;
  if (n > XDBG_HEX_SHOW)
  {
    n = XDBG_HEX_SHOW;
  }
  skip = total - n;
  for (i = 0u; i < n && pos + 3u < 40u; i++)
  {
    unsigned char b;
    unsigned int slot;

    slot = (unsigned int)(idx + skip + i) % (unsigned int)XDBG_RING;
    b = ring[slot];
    out[pos++] = hexd[b >> 4];
    out[pos++] = hexd[b & 0x0Fu];
    out[pos++] = ' ';
  }
  out[pos] = 0;
}

static void xdbg_wait_key(void)
{
  unsigned char k;

  do
  {
    YIELD();
    k = (unsigned char)(OS_GETKEY() & 0xFFL);
  } while (k == 0u);
  while ((OS_GETKEY() & 0xFFL) != 0L)
  {
    YIELD();
  }
}

static unsigned int xdbg_raw_get(unsigned int index)
{
  unsigned int start;
  unsigned int n;

  n = g_raw_count;
  if (n > XDBG_RAW_MAX)
  {
    n = XDBG_RAW_MAX;
  }
  if (n == 0u)
  {
    return 0u;
  }
  start = g_raw_count - n;
  return g_raw[(start + index) % XDBG_RAW_MAX];
}

static void xdbg_printable(unsigned char b)
{
  if (b >= 32u && b <= 126u)
  {
    term_putchar(b);
  }
  else
  {
    term_putchar('.');
  }
}

static void xdbg_show_hex_ring(const char *title, unsigned char (*get_byte)(unsigned int index), unsigned int len)
{
  unsigned int page;
  unsigned int pages;
  unsigned int pos;
  unsigned int line;
  unsigned int i;
  unsigned int got;

  if (len == 0u)
  {
    term_cls(0x07u);
    term_set_xy(0u, 0u);
    printf("%s empty key\r\n", title);
    xdbg_wait_key();
    return;
  }
  pages = (len + 159u) / 160u;
  if (pages == 0u)
  {
    pages = 1u;
  }
  for (page = 0u; page < pages; page++)
  {
    term_cls(0x07u);
    term_set_xy(0u, 0u);
    printf("%s len=%u pg %u/%u key\r\n", title, len, page + 1u, pages);
    pos = page * 160u;
    for (line = 0u; line < 20u; line++)
    {
      term_set_xy(0u, (unsigned char)(line + 2u));
      if (pos >= len)
      {
        break;
      }
      got = len - pos;
      if (got > 8u)
      {
        got = 8u;
      }
      printf("%04X:", pos);
      for (i = 0u; i < got; i++)
      {
        printf(" %02X", (unsigned int)get_byte(pos + i));
      }
      for (; i < 8u; i++)
      {
        printf("   ");
      }
      printf("  ");
      for (i = 0u; i < got; i++)
      {
        xdbg_printable(get_byte(pos + i));
      }
      pos += 8u;
    }
    xdbg_wait_key();
  }
}

static void xdbg_write_log_hdr(FILE *fp, const char *tag, unsigned int len)
{
  unsigned int n;

  if (fp == 0)
  {
    return;
  }
  n = (unsigned int)sprintf(g_log_buf, "%5u : %s : len=%u\r\n",
                            (unsigned int)(g_raw_count & 0xFFFFu), tag, len);
  (void)OS_WRITEHANDLE((unsigned char *)g_log_buf, fp, n);
}

static void xdbg_write_hex_log(const unsigned char *path, const char *tag,
                               unsigned char (*get_byte)(unsigned int index), unsigned int len)
{
  static const char *hexd = "0123456789ABCDEF";
  FILE *fp;
  unsigned int pos;
  unsigned int i;
  unsigned int j;
  unsigned int n;
  unsigned int li;

  fp = xdbg_file_open_append(path);
  if (fp == 0)
  {
    return;
  }
  xdbg_write_log_hdr(fp, tag, len);

  for (pos = 0u; pos < len; pos += 8u)
  {
    n = len - pos;
    if (n > 8u)
    {
      n = 8u;
    }
    li = (unsigned int)sprintf(g_log_buf, "%04X:", pos);
    for (i = 0u; i < n; i++)
    {
      unsigned char b;

      b = get_byte(pos + i);
      g_log_buf[li++] = ' ';
      g_log_buf[li++] = hexd[b >> 4];
      g_log_buf[li++] = hexd[b & 0x0Fu];
    }
    for (j = n; j < 8u; j++)
    {
      g_log_buf[li++] = ' ';
      g_log_buf[li++] = ' ';
      g_log_buf[li++] = ' ';
    }
    g_log_buf[li++] = ' ';
    g_log_buf[li++] = ' ';
    for (i = 0u; i < n; i++)
    {
      unsigned char b;

      b = get_byte(pos + i);
      if (b >= 32u && b <= 126u)
      {
        g_log_buf[li++] = (char)b;
      }
      else
      {
        g_log_buf[li++] = '.';
      }
    }
    g_log_buf[li++] = '\r';
    g_log_buf[li++] = '\n';
    (void)OS_WRITEHANDLE((unsigned char *)g_log_buf, fp, li);
  }
  xdbg_file_close(fp);
}

static unsigned int xdbg_raw_len(void);

static unsigned char xdbg_raw_get_byte(unsigned int index)
{
  return (unsigned char)xdbg_raw_get(index);
}

static unsigned int xdbg_tx_raw_len(void)
{
  unsigned int n;

  n = g_tx_raw_count;
  if (n > (unsigned int)sizeof(g_tx_raw))
  {
    n = (unsigned int)sizeof(g_tx_raw);
  }
  return n;
}

static unsigned char xdbg_tx_raw_get(unsigned int index)
{
  unsigned int start;
  unsigned int n;

  n = xdbg_tx_raw_len();
  if (n == 0u)
  {
    return 0u;
  }
  start = g_tx_raw_count - n;
  return g_tx_raw[(start + index) % (unsigned int)sizeof(g_tx_raw)];
}

static unsigned char xdbg_tx_get_byte(unsigned int index)
{
  return xdbg_tx_raw_get(index);
}

static unsigned char xdbg_queue_get_byte(unsigned int index)
{
  if (index >= g_dump_qlen)
  {
    return 0u;
  }
  return g_dump_q[index];
}

static unsigned int xdbg_raw_len(void)
{
  if (g_raw_count > XDBG_RAW_MAX)
  {
    return XDBG_RAW_MAX;
  }
  return g_raw_count;
}

static unsigned int xdbg_qhist_len(void)
{
  if (g_qhist_count > (unsigned int)sizeof(g_qhist))
  {
    return (unsigned int)sizeof(g_qhist);
  }
  return g_qhist_count;
}

void xfer_dbg_capture_begin(void)
{
  g_xdbg_cap = 1u;
  g_raw_count = 0u;
  g_tx_raw_count = 0u;
  g_qhist_count = 0u;
}

void xfer_dbg_capture_end(void)
{
  g_xdbg_cap = 0u;
}

unsigned char xfer_dbg_capturing(void)
{
  return g_xdbg_cap;
}

void xfer_dbg_log_rx(unsigned char b)
{
  if (g_xdbg_cap == 0u)
  {
    return;
  }
  g_raw[g_raw_count % XDBG_RAW_MAX] = b;
  g_raw_count++;
  if (g_xdbg_on != 0u)
  {
    xdbg_push(g_xdbg_rx, &g_xdbg_rxi, b);
    g_xdbg_rxtot++;
  }
}

void xfer_dbg_log_tx(unsigned char b)
{
  if (g_xdbg_cap == 0u)
  {
    return;
  }
  g_tx_raw[g_tx_raw_count % (unsigned int)sizeof(g_tx_raw)] = b;
  g_tx_raw_count++;
}

void xfer_dbg_zmodem_begin(void)
{
  g_xdbg_on = 1u;
  g_xdbg_txi = 0u;
  g_xdbg_rxi = 0u;
  g_xdbg_txtot = 0u;
  g_xdbg_rxtot = 0u;
  g_tx_raw_count = 0u;
  xdbg_file_reset(g_log_raw);
  xdbg_file_reset(g_log_queue);
}

void xfer_dbg_zmodem_end(void)
{
  g_xdbg_on = 0u;
  term_set_xy(0u, 18u);
  term_set_color(0x07u);
  printf("%-78s", "");
  term_set_xy(0u, 19u);
  term_set_color(0x07u);
  printf("%-78s", "");
  term_set_xy(0u, 20u);
  printf("%-78s", "");
  term_set_color(0x07u);
}

void xfer_dbg_tx(const unsigned char *buf, unsigned int len)
{
  unsigned int i;

  if (g_xdbg_on == 0u || buf == 0 || len == 0u)
  {
    return;
  }
  for (i = 0u; i < len; i++)
  {
    xdbg_push(g_xdbg_tx, &g_xdbg_txi, buf[i]);
    g_xdbg_txtot++;
    xfer_dbg_log_tx(buf[i]);
  }
}

void xfer_dbg_rx(unsigned char b)
{
  if (g_xdbg_on == 0u)
  {
    return;
  }
  xdbg_push(g_xdbg_rx, &g_xdbg_rxi, b);
  g_xdbg_rxtot++;
}

void xfer_dbg_draw(unsigned char qdepth)
{
  char txhex[40];
  char rxhex[40];
  unsigned int shown;

  if (g_xdbg_on == 0u)
  {
    return;
  }
  shown = xdbg_raw_len();
  xdbg_hex_tail(txhex, g_xdbg_tx, g_xdbg_txi, g_xdbg_txtot);
  xdbg_hex_tail(rxhex, g_xdbg_rx, g_xdbg_rxi, g_xdbg_rxtot);
  term_set_xy(0u, 19u);
  term_set_color(0x70u);
  printf("TX=%u %-56s", (unsigned int)(g_xdbg_txtot & 0xFFFFu), txhex);
  term_set_xy(0u, 20u);
  printf("RX=%u q=%u L=%u %-40s",
         (unsigned int)(g_xdbg_rxtot & 0xFFFFu),
         (unsigned int)qdepth,
         shown,
         rxhex);
  term_set_color(0x07u);
}

void xfer_dbg_note(const char *msg)
{
  (void)msg;
}

void xfer_dbg_frame(unsigned char rc, unsigned char typ, unsigned char idle)
{
  char line[40];

  if (g_xdbg_on == 0u)
  {
    return;
  }
  if (rc == 0u)
  {
    sprintf(line, "wait idle=%u (no zmodem frame yet)", (unsigned int)idle);
  }
  else
  {
    sprintf(line, "rc=%u typ=%u idle=%u", (unsigned int)rc, (unsigned int)typ, (unsigned int)idle);
  }
  term_set_xy(0u, 18u);
  term_set_color(0x4Eu);
  printf("%-78s", line);
  term_set_color(0x07u);
}

void xfer_dbg_log_q(unsigned char b)
{
  if (g_xdbg_cap == 0u)
  {
    return;
  }
  g_qhist[g_qhist_count % (unsigned int)sizeof(g_qhist)] = b;
  g_qhist_count++;
}

static void xdbg_qhist_copy(unsigned char *out, unsigned int max)
{
  unsigned int n;
  unsigned int i;
  unsigned int start;

  n = xdbg_qhist_len();
  if (n > max)
  {
    n = max;
  }
  start = g_qhist_count - n;
  for (i = 0u; i < n; i++)
  {
    out[i] = g_qhist[(start + i) % (unsigned int)sizeof(g_qhist)];
  }
}

static unsigned int xdbg_queue_prepare(void)
{
  unsigned int n;

  n = (unsigned int)xfer_queue_copy(g_dump_q, (unsigned char)sizeof(g_dump_q));
  if (n != 0u)
  {
    return n;
  }
  n = xdbg_qhist_len();
  if (n > (unsigned int)sizeof(g_dump_q))
  {
    n = (unsigned int)sizeof(g_dump_q);
  }
  xdbg_qhist_copy(g_dump_q, n);
  return n;
}

void xfer_dbg_queue_snap(void)
{
  /* live snap kept for zmodem exit paths; F8 uses xdbg_queue_bytes */
}

void xfer_dbg_dump_session(unsigned char qdepth)
{
  g_dump_qlen = xdbg_queue_prepare();

  if (xdbg_raw_len() == 0u && g_dump_qlen == 0u && xdbg_tx_raw_len() == 0u)
  {
    term_set_xy(0u, 23u);
    term_set_color(0x4Eu);
    printf("%-78s", "No capture data");
    term_set_color(0x07u);
    xfer_dbg_capture_end();
    return;
  }

  if (xdbg_raw_len() != 0u)
  {
    xdbg_write_hex_log(g_log_raw, g_tag_zmrx, xdbg_raw_get_byte, xdbg_raw_len());
  }

  if (xdbg_tx_raw_len() != 0u)
  {
    xdbg_write_hex_log(g_log_raw, g_tag_zmtx, xdbg_tx_get_byte, xdbg_tx_raw_len());
  }

  if (g_dump_qlen != 0u)
  {
    xdbg_write_hex_log(g_log_queue, g_tag_queue, xdbg_queue_get_byte, g_dump_qlen);
  }
  else
  {
    (void)sprintf(g_log_buf, "%5u : %s : empty live=%u hist=%u\r\n",
                  (unsigned int)(g_raw_count & 0xFFFFu),
                  g_tag_queue,
                  (unsigned int)qdepth,
                  xdbg_qhist_len());
    xdbg_file_append(g_log_queue, (unsigned char *)g_log_buf, (unsigned int)strlen(g_log_buf));
  }

  term_set_xy(0u, 23u);
  term_set_color(0x4Eu);
  printf("%-78s", "Log saved (F8 again) Enter=back");
  term_set_color(0x07u);
}
