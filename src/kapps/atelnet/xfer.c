#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "xfer.h"
#include "xfer_dbg.h"

#define XSOH 1u
#define XSTX 2u
#define XEOT 4u
#define XACK 6u
#define XNAK 21u
#define XCAN 24u
#define XC 67u

#define XBLK128 128u
#define XBLK1K 1024u

#define XFER_QSIZE 512u
#define XFER_SNIFF_MAX 32u
#define XFER_ZDLE 24u

#define XFER_TIMEOUT 60000ul

static unsigned char g_xfer_q[XFER_QSIZE];
static unsigned int g_xfer_qhead;
static unsigned int g_xfer_qtail;
static unsigned char g_xfer_active;
static unsigned char g_sniff[XFER_SNIFF_MAX];
static unsigned char g_sniff_len;
unsigned char g_xfer_block[XBLK1K];

static unsigned int crc16_ccitt(unsigned char *data, unsigned int len)
{
  unsigned int crc;
  unsigned char b;
  unsigned char bit;

  crc = 0u;
  while (len > 0u)
  {
    b = *data++;
    len--;
    crc = (unsigned int)(crc ^ ((unsigned int)b << 8));
    for (bit = 0u; bit < 8u; bit++)
    {
      if (crc & 0x8000u)
      {
        crc = (unsigned int)((crc << 1) ^ 0x1021u);
      }
      else
      {
        crc = (unsigned int)(crc << 1);
      }
    }
  }
  return (unsigned int)(crc & 0xFFFFu);
}

static void xfer_overlay(const char *msg)
{
  term_set_xy(0u, XFER_STATUS_Y);
  term_set_color(0x70u);
  printf("%-78s", msg);
  term_set_color(0x07u);
}

static void xfer_q_push_raw(unsigned char b)
{
  unsigned int next;

  next = (g_xfer_qhead + 1u) % XFER_QSIZE;
  if (next == g_xfer_qtail)
  {
    return;
  }
  g_xfer_q[g_xfer_qhead] = b;
  g_xfer_qhead = next;
}

static unsigned char xfer_q_push(unsigned char b)
{
  if (g_xfer_active == 0u)
  {
    return 0u;
  }
  xfer_q_push_raw(b);
  if (xfer_dbg_capturing() != 0u)
  {
    xfer_dbg_log_q(b);
  }
  return 1u;
}

static unsigned char xfer_q_pop(unsigned char *out)
{
  if (g_xfer_qtail == g_xfer_qhead)
  {
    return 0u;
  }
  *out = g_xfer_q[g_xfer_qtail];
  g_xfer_qtail = (g_xfer_qtail + 1u) % XFER_QSIZE;
  return 1u;
}

static unsigned char g_sniff_trigger;
static unsigned char g_sniff_pending;
static unsigned char g_xfer_prefilled;
static unsigned char g_auto_xfer_proto = 0xFFu;

static unsigned char xfer_sniff_match(unsigned char a, unsigned char b, unsigned char c)
{
  if (a == '*' && b == '*')
  {
    if (c == 'B' || c == 'b')
    {
      return XFER_PROTO_ZMODEM;
    }
    if (c == 'Y' || c == 'y' || c == 'G' || c == 'g')
    {
      return XFER_PROTO_YMODEM;
    }
    if (c == 'X' || c == 'x')
    {
      return XFER_PROTO_XMODEM;
    }
  }
  return 0xFFu;
}

static unsigned char xfer_is_hex(unsigned char c)
{
  if (c >= '0' && c <= '9')
  {
    return 1u;
  }
  if (c >= 'a' && c <= 'f')
  {
    return 1u;
  }
  if (c >= 'A' && c <= 'F')
  {
    return 1u;
  }
  return 0u;
}

static unsigned char xfer_b_after_star(unsigned char i, unsigned char *bpos)
{
  unsigned char b;
  unsigned char c;

  if (g_sniff[i] != '*')
  {
    return 0u;
  }
  if (i + 1u >= g_sniff_len)
  {
    return 0u;
  }
  b = g_sniff[i + 1u];
  if (b == 'B' || b == 'b')
  {
    *bpos = (unsigned char)(i + 1u);
    return 1u;
  }
  if (b == XFER_ZDLE && i + 2u < g_sniff_len)
  {
    c = g_sniff[i + 2u];
    if (c == 'B' || c == 'b')
    {
      *bpos = (unsigned char)(i + 2u);
      return 1u;
    }
  }
  if (b == '*' && i + 2u < g_sniff_len)
  {
    c = g_sniff[i + 2u];
    if (c == 'B' || c == 'b')
    {
      *bpos = (unsigned char)(i + 2u);
      return 1u;
    }
    if (c == XFER_ZDLE && i + 3u < g_sniff_len)
    {
      if (g_sniff[i + 3u] == 'B' || g_sniff[i + 3u] == 'b')
      {
        *bpos = (unsigned char)(i + 3u);
        return 1u;
      }
    }
  }
  return 0u;
}

static unsigned char xfer_sniff_zrqinit_complete(unsigned char *trig)
{
  unsigned char i;
  unsigned char bpos;
  unsigned char j;
  unsigned char got;

  for (i = 0u; i < g_sniff_len; i++)
  {
    if (xfer_b_after_star(i, &bpos) == 0u)
    {
      continue;
    }
    if (bpos + 2u >= g_sniff_len)
    {
      continue;
    }
    if (g_sniff[bpos + 1u] != '0' || g_sniff[bpos + 2u] != '0')
    {
      continue;
    }
    got = 0u;
    for (j = (unsigned char)(bpos + 1u); j < g_sniff_len; j++)
    {
      if (xfer_is_hex(g_sniff[j]) != 0u)
      {
        got++;
        if (got >= 14u)
        {
          *trig = i;
          return XFER_PROTO_ZMODEM;
        }
      }
    }
  }
  return 0xFFu;
}

static unsigned char xfer_sniff_find_zmodem(unsigned char *trig)
{
  unsigned char i;
  unsigned char b;
  unsigned char c;

  for (i = 0u; i < g_sniff_len; i++)
  {
    if (g_sniff[i] != '*')
    {
      continue;
    }
    if (i + 1u < g_sniff_len)
    {
      b = g_sniff[i + 1u];
      if (b == 'B' || b == 'b')
      {
        *trig = i;
        return XFER_PROTO_ZMODEM;
      }
      if (b == XFER_ZDLE && i + 2u < g_sniff_len)
      {
        c = g_sniff[i + 2u];
        if (c == 'B' || c == 'b')
        {
          *trig = i;
          return XFER_PROTO_ZMODEM;
        }
      }
      if (b == '*' && i + 2u < g_sniff_len)
      {
        c = g_sniff[i + 2u];
        if (c == 'B' || c == 'b')
        {
          *trig = i;
          return XFER_PROTO_ZMODEM;
        }
        if (c == XFER_ZDLE && i + 3u < g_sniff_len)
        {
          if (g_sniff[i + 3u] == 'B' || g_sniff[i + 3u] == 'b')
          {
            *trig = i;
            return XFER_PROTO_ZMODEM;
          }
        }
      }
    }
  }
  return 0xFFu;
}

void xfer_sniff_begin_manual(void)
{
  unsigned char trig;
  unsigned char proto;

  proto = xfer_sniff_find_zmodem(&trig);
  if (proto != 0xFFu)
  {
    g_sniff_trigger = trig;
    g_sniff_pending = 1u;
    return;
  }
  g_sniff_trigger = g_sniff_len;
  g_sniff_pending = 0u;
}

unsigned char xfer_sniff_is_pending(void)
{
  return g_sniff_pending;
}

void xfer_sniff_replay(void)
{
  unsigned char i;

  if (g_sniff_pending != 0u)
  {
    for (i = g_sniff_trigger; i < g_sniff_len; i++)
    {
      xfer_q_push_raw(g_sniff[i]);
    }
  }
  g_sniff_len = 0u;
  g_sniff_pending = 0u;
}

void xfer_sniff_reset(void)
{
  g_sniff_len = 0u;
  g_sniff_trigger = 0u;
  g_sniff_pending = 0u;
}

static void xfer_arm_capture(unsigned char proto)
{
  unsigned char i;

  xfer_dbg_capture_begin();
  if (g_sniff_pending != 0u)
  {
    for (i = g_sniff_trigger; i < g_sniff_len; i++)
    {
      xfer_dbg_log_rx(g_sniff[i]);
    }
  }
  g_xfer_prefilled = 1u;
  g_xfer_active = 1u;
  if (proto == XFER_PROTO_ZMODEM)
  {
    xfer_zmodem_mode(1u);
  }
  xfer_sniff_replay();
}

void xfer_preflight(unsigned char proto)
{
  xfer_arm_capture(proto);
  g_auto_xfer_proto = proto;
}

void xfer_capture_pending(unsigned char proto)
{
  if (g_sniff_pending != 0u)
  {
    xfer_arm_capture(proto);
  }
}

unsigned char xfer_take_auto(void)
{
  unsigned char proto;

  proto = g_auto_xfer_proto;
  g_auto_xfer_proto = 0xFFu;
  return proto;
}

unsigned char xfer_is_prefilled(void)
{
  return g_xfer_prefilled;
}

unsigned char xfer_sniff_byte(unsigned char b)
{
  unsigned char i;
  unsigned char proto;
  unsigned char trig;

  if (g_xfer_active != 0u)
  {
    return 0xFFu;
  }
  if (b == XSOH || b == XSTX)
  {
    g_sniff_trigger = g_sniff_len;
    g_sniff_pending = 1u;
    if (g_sniff_len < XFER_SNIFF_MAX)
    {
      g_sniff[g_sniff_len++] = b;
    }
    return XFER_PROTO_YMODEM;
  }
  if (g_sniff_len < XFER_SNIFF_MAX)
  {
    g_sniff[g_sniff_len++] = b;
  }
  else
  {
    for (i = 0u; i < XFER_SNIFF_MAX - 1u; i++)
    {
      g_sniff[i] = g_sniff[i + 1u];
    }
    g_sniff[XFER_SNIFF_MAX - 1u] = b;
  }
  proto = xfer_sniff_zrqinit_complete(&trig);
  if (proto != 0xFFu)
  {
    g_sniff_trigger = trig;
    g_sniff_pending = 1u;
    return proto;
  }
  if (g_sniff_len >= 3u)
  {
    for (i = 0u; i + 2u < g_sniff_len; i++)
    {
      proto = xfer_sniff_match(g_sniff[i], g_sniff[i + 1u], g_sniff[i + 2u]);
      if (proto != 0xFFu)
      {
        g_sniff_trigger = i;
        g_sniff_pending = 1u;
        return proto;
      }
    }
  }
  return 0xFFu;
}

static unsigned char g_xfer_zmodem;
static unsigned char g_ansi_st;
static unsigned char g_z_rx_hex;

static unsigned char xfer_rx_zmodem_filter(unsigned char b)
{
  if (g_ansi_st == 0u)
  {
    if (b == 27u)
    {
      g_ansi_st = 1u;
      return 0u;
    }
    if (b == 32u && g_xfer_zmodem == 0u)
    {
      return 0u;
    }
    if (g_z_rx_hex != 0u)
    {
      if (b == '*' || b == XFER_ZDLE || b == 'B' || b == 'b' ||
          b == 'A' || b == 'a' || b == 'C' || b == 'c')
      {
        return 1u;
      }
      if (b == 13u || b == 10u || b == 17u || b == 11u)
      {
        return 1u;
      }
      if (xfer_is_hex(b) != 0u)
      {
        return 1u;
      }
      return 0u;
    }
    return 1u;
  }
  if (g_ansi_st == 1u)
  {
    g_ansi_st = (b == '[') ? 2u : 0u;
    return 0u;
  }
  if (b >= 0x40u && b <= 0x7Eu)
  {
    g_ansi_st = 0u;
  }
  return 0u;
}

void xfer_zmodem_mode(unsigned char on)
{
  g_xfer_zmodem = on;
  g_ansi_st = 0u;
  g_z_rx_hex = 0u;
}

void xfer_zmodem_unlock(void)
{
  g_z_rx_hex = 0u;
}

int xfer_rx_byte(unsigned char b)
{
  if (g_xfer_active == 0u)
  {
    return 0;
  }
  if (g_xfer_zmodem != 0u)
  {
    if (xfer_rx_zmodem_filter(b) == 0u)
    {
      return 1;
    }
  }
  xfer_dbg_rx(b);
  if (xfer_q_push(b) == 0u)
  {
    return -1;
  }
  return 1;
}

void xfer_io_init(XferIO *io, signed char socket,
                  unsigned char (*read_byte)(XferIO *io, unsigned char *out),
                  void (*write_byte)(XferIO *io, unsigned char b),
                  void (*write_buf)(XferIO *io, const unsigned char *buf, unsigned int len),
                  void (*flush)(XferIO *io),
                  void (*pump)(XferIO *io),
                  void (*status)(XferIO *io, const char *msg))
{
  io->socket = socket;
  io->cancelled = 0u;
  io->read_byte = read_byte;
  io->write_byte = write_byte;
  io->write_buf = write_buf;
  io->flush = flush;
  io->pump = pump;
  io->status = status;
}

static void xfer_status_line(XferIO *io, const char *msg)
{
  if (io->status != 0)
  {
    io->status(io, msg);
  }
  else
  {
    xfer_overlay(msg);
  }
}

static unsigned char xfer_read_u8(XferIO *io, unsigned long timeout)
{
  unsigned char b;
  unsigned long t;

  t = 0ul;
  while (t < timeout)
  {
    if (io->read_byte(io, &b) != 0u)
    {
      return b;
    }
    YIELD();
    t++;
  }
  return 0u;
}

static unsigned char xfer_read_exact(XferIO *io, unsigned char *buf, unsigned int len, unsigned long timeout)
{
  unsigned int got;
  unsigned long t;
  unsigned char b;

  got = 0u;
  t = 0ul;
  while (got < len)
  {
    if (io->read_byte(io, &b) != 0u)
    {
      buf[got++] = b;
      t = 0ul;
      continue;
    }
    YIELD();
    t++;
    if (t >= timeout)
    {
      return 0u;
    }
  }
  return 1u;
}

static void xfer_sanitize_name(char *name)
{
  unsigned char i;

  for (i = 0u; name[i] != 0; i++)
  {
    if (name[i] == '\\' || name[i] == '/' || name[i] == ':' || name[i] == ' ')
    {
      name[i] = '_';
    }
  }
}

static FILE *xfer_open_out(const char *name)
{
  char path[64];

  if (name[0] == 0)
  {
    strcpy(path, "download.bin");
  }
  else
  {
    strncpy(path, name, sizeof(path) - 1u);
    path[sizeof(path) - 1u] = 0;
    xfer_sanitize_name(path);
  }
  return OS_CREATEHANDLE((unsigned char *)path, 0x80u);
}

static int xfer_xmodem_receive(XferIO *io)
{
  unsigned char hdr[2];
  unsigned char crcbuf[2];
  unsigned char blknum;
  unsigned char blkxor;
  unsigned int blklen;
  unsigned int expect;
  unsigned int crc;
  unsigned int gotcrc;
  unsigned char ch;
  FILE *fp;

  fp = 0;
  expect = 1u;
  io->write_byte(io, XC);
  xfer_status_line(io, "Xmodem: waiting...");

  for (;;)
  {
    if (io->cancelled != 0u)
    {
      io->write_byte(io, XCAN);
      return 0;
    }
    ch = xfer_read_u8(io, XFER_TIMEOUT);
    if (ch == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (ch == XCAN)
    {
      return 0;
    }
    if (ch == XEOT)
    {
      io->write_byte(io, XACK);
      if (fp != 0)
      {
        OS_CLOSEHANDLE(fp);
      }
      xfer_status_line(io, "Xmodem: done");
      return 1;
    }
    if (ch == XSOH)
    {
      blklen = XBLK128;
    }
    else if (ch == XSTX)
    {
      blklen = XBLK1K;
    }
    else
    {
      continue;
    }
    if (xfer_read_exact(io, hdr, 2u, XFER_TIMEOUT) == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    blknum = hdr[0];
    blkxor = hdr[1];
    if ((unsigned char)(blknum + blkxor) != 0xFFu)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (xfer_read_exact(io, g_xfer_block, blklen, XFER_TIMEOUT) == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (xfer_read_exact(io, crcbuf, 2u, XFER_TIMEOUT) == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    crc = crc16_ccitt(g_xfer_block, blklen);
    gotcrc = ((unsigned int)crcbuf[0] << 8) | (unsigned int)crcbuf[1];
    if (crc != gotcrc)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (fp == 0)
    {
      fp = xfer_open_out("download.bin");
      if (((int)fp) & 0xFF)
      {
        xfer_status_line(io, "Xmodem: cannot create file");
        return 0;
      }
    }
    if (blknum == (unsigned char)expect || blknum == (unsigned char)(expect - 1u))
    {
      if (blknum == (unsigned char)expect)
      {
        OS_WRITEHANDLE(g_xfer_block, fp, blklen);
        expect++;
      }
      io->write_byte(io, XACK);
    }
    else
    {
      io->write_byte(io, XNAK);
    }
  }
}

static int xfer_ymodem_receive(XferIO *io)
{
  unsigned char hdr[2];
  unsigned char crcbuf[2];
  unsigned char blknum;
  unsigned char blkxor;
  unsigned int blklen;
  unsigned int expect;
  unsigned int crc;
  unsigned int gotcrc;
  unsigned char ch;
  char fname[64];
  unsigned char i;
  unsigned char done;
  FILE *fp;

  fp = 0;
  fname[0] = 0;
  done = 0u;
  expect = 0u;
  io->write_byte(io, XC);
  xfer_status_line(io, "Ymodem: waiting...");

  for (;;)
  {
    if (io->cancelled != 0u)
    {
      io->write_byte(io, XCAN);
      if (fp != 0)
      {
        OS_CLOSEHANDLE(fp);
      }
      return 0;
    }
    ch = xfer_read_u8(io, XFER_TIMEOUT);
    if (ch == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (ch == XCAN)
    {
      if (fp != 0)
      {
        OS_CLOSEHANDLE(fp);
      }
      return 0;
    }
    if (ch == XEOT)
    {
      io->write_byte(io, XNAK);
      ch = xfer_read_u8(io, XFER_TIMEOUT);
      if (ch == XEOT)
      {
        io->write_byte(io, XACK);
        io->write_byte(io, XC);
        if (fp != 0)
        {
          OS_CLOSEHANDLE(fp);
          fp = 0;
        }
        if (done != 0u)
        {
          xfer_status_line(io, "Ymodem: done");
          return 1;
        }
        expect = 0u;
        continue;
      }
      continue;
    }
    if (ch == XSOH)
    {
      blklen = XBLK128;
    }
    else if (ch == XSTX)
    {
      blklen = XBLK1K;
    }
    else
    {
      continue;
    }
    if (xfer_read_exact(io, hdr, 2u, XFER_TIMEOUT) == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    blknum = hdr[0];
    blkxor = hdr[1];
    if ((unsigned char)(blknum + blkxor) != 0xFFu)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (xfer_read_exact(io, g_xfer_block, blklen, XFER_TIMEOUT) == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (xfer_read_exact(io, crcbuf, 2u, XFER_TIMEOUT) == 0u)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    crc = crc16_ccitt(g_xfer_block, blklen);
    gotcrc = ((unsigned int)crcbuf[0] << 8) | (unsigned int)crcbuf[1];
    if (crc != gotcrc)
    {
      io->write_byte(io, XNAK);
      continue;
    }
    if (blknum == 0u)
    {
      for (i = 0u; i < 63u && i < blklen && g_xfer_block[i] != 0; i++)
      {
        fname[i] = (char)g_xfer_block[i];
      }
      fname[i] = 0;
      if (fname[0] == 0)
      {
        done = 1u;
        io->write_byte(io, XACK);
        continue;
      }
      if (fp != 0)
      {
        OS_CLOSEHANDLE(fp);
      }
      fp = xfer_open_out(fname);
      if (((int)fp) & 0xFF)
      {
        xfer_status_line(io, "Ymodem: cannot create file");
        return 0;
      }
      xfer_status_line(io, fname);
      expect = 1u;
      io->write_byte(io, XACK);
      io->write_byte(io, XC);
      continue;
    }
    if (fp == 0)
    {
      fp = xfer_open_out("download.bin");
      if (((int)fp) & 0xFF)
      {
        return 0;
      }
    }
    OS_WRITEHANDLE(g_xfer_block, fp, blklen);
    io->write_byte(io, XACK);
  }
}

static unsigned char xfer_peek_queue(unsigned char *out)
{
  if (g_xfer_qtail == g_xfer_qhead)
  {
    return 0u;
  }
  *out = g_xfer_q[g_xfer_qtail];
  return 1u;
}

static unsigned char xfer_queue_has_zmodem(void)
{
  unsigned int i;
  unsigned int count;
  unsigned char a;
  unsigned char b;
  unsigned char c;

  if (g_xfer_qtail == g_xfer_qhead)
  {
    return 0u;
  }
  count = (g_xfer_qhead + XFER_QSIZE - g_xfer_qtail) % XFER_QSIZE;
  for (i = 0u; i < count; i++)
  {
    a = g_xfer_q[(g_xfer_qtail + i) % XFER_QSIZE];
    if (a != '*')
    {
      continue;
    }
    if (i + 1u >= count)
    {
      continue;
    }
    b = g_xfer_q[(g_xfer_qtail + i + 1u) % XFER_QSIZE];
    if (b == 'B' || b == 'b')
    {
      return 1u;
    }
    if (b == XFER_ZDLE && i + 2u < count)
    {
      c = g_xfer_q[(g_xfer_qtail + i + 2u) % XFER_QSIZE];
      if (c == 'B' || c == 'b')
      {
        return 1u;
      }
    }
    if (b == '*' && i + 2u < count)
    {
      c = g_xfer_q[(g_xfer_qtail + i + 2u) % XFER_QSIZE];
      if (c == 'B' || c == 'b')
      {
        return 1u;
      }
      if (c == XFER_ZDLE && i + 3u < count)
      {
        if (g_xfer_q[(g_xfer_qtail + i + 3u) % XFER_QSIZE] == 'B' ||
            g_xfer_q[(g_xfer_qtail + i + 3u) % XFER_QSIZE] == 'b')
        {
          return 1u;
        }
      }
    }
  }
  return 0u;
}

static unsigned char xfer_resolve_auto(XferIO *io)
{
  unsigned char b;
  unsigned long t;

  if (xfer_queue_has_zmodem() != 0u)
  {
    return XFER_PROTO_ZMODEM;
  }
  if (xfer_peek_queue(&b) != 0u)
  {
    if (b == XSOH || b == XSTX)
    {
      return XFER_PROTO_YMODEM;
    }
  }
  xfer_overlay("Zmodem: starting (send ZRINIT)...");
  for (t = 0ul; t < 4000ul; t++)
  {
    if (io->cancelled != 0u)
    {
      return XFER_PROTO_ZMODEM;
    }
    if (io->read_byte(io, &b) != 0u)
    {
      xfer_q_push_raw(b);
      if (b == XSOH || b == XSTX)
      {
        return XFER_PROTO_YMODEM;
      }
      if (b == 'B' || b == 'b')
      {
        if (xfer_queue_has_zmodem() != 0u)
        {
          return XFER_PROTO_ZMODEM;
        }
      }
    }
    YIELD();
  }
  return XFER_PROTO_ZMODEM;
}

int xfer_zmodem_receive(XferIO *io);

int xfer_receive(unsigned char proto, XferIO *io)
{
  int rc;
  const char *name;

  if (g_xfer_prefilled == 0u)
  {
    g_xfer_qhead = 0u;
    g_xfer_qtail = 0u;
    g_xfer_active = 1u;
    xfer_sniff_replay();
  }
  else
  {
    g_xfer_prefilled = 0u;
  }

  if (proto == XFER_PROTO_AUTO)
  {
    proto = xfer_resolve_auto(io);
  }

  if (proto == XFER_PROTO_XMODEM)
  {
    name = "Xmodem";
  }
  else if (proto == XFER_PROTO_YMODEM)
  {
    name = "Ymodem";
  }
  else
  {
    name = "Zmodem";
  }
  xfer_overlay("Receiving ");
  term_set_xy(11u, XFER_STATUS_Y);
  term_set_color(0x70u);
  printf("%s  F5=cancel", name);
  term_set_color(0x07u);

  if (proto == XFER_PROTO_XMODEM)
  {
    rc = xfer_xmodem_receive(io);
  }
  else if (proto == XFER_PROTO_YMODEM)
  {
    rc = xfer_ymodem_receive(io);
  }
  else
  {
    rc = xfer_zmodem_receive(io);
    xfer_zmodem_mode(0u);
    xfer_dbg_zmodem_end();
  }

  g_xfer_active = 0u;
  g_xfer_qhead = 0u;
  g_xfer_qtail = 0u;
  g_xfer_prefilled = 0u;
  g_auto_xfer_proto = 0xFFu;
  xfer_sniff_reset();
  return rc;
}

unsigned char xfer_queue_pop_for_io(unsigned char *out)
{
  return xfer_q_pop(out);
}

unsigned char xfer_is_active(void)
{
  return g_xfer_active;
}

unsigned char xfer_queue_depth(void)
{
  if (g_xfer_qhead >= g_xfer_qtail)
  {
    return (unsigned char)(g_xfer_qhead - g_xfer_qtail);
  }
  return (unsigned char)(XFER_QSIZE - g_xfer_qtail + g_xfer_qhead);
}

unsigned char xfer_queue_copy(unsigned char *buf, unsigned char max)
{
  unsigned int count;
  unsigned int i;

  if (buf == 0 || max == 0u)
  {
    return 0u;
  }
  count = (unsigned int)xfer_queue_depth();
  if (count > (unsigned int)max)
  {
    count = (unsigned int)max;
  }
  for (i = 0u; i < count; i++)
  {
    buf[i] = g_xfer_q[(g_xfer_qtail + i) % XFER_QSIZE];
  }
  return (unsigned char)count;
}
