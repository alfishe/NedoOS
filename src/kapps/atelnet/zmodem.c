#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "xfer.h"
#include "xfer_dbg.h"

#define ZDLE 24u
#define ZPAD 42u
#define ZBIN 65u
#define ZBIN32 67u
#define ZHEX 66u

#define ZRQINIT 0u
#define ZRINIT 1u
#define ZACK 3u
#define ZFILE 4u
#define ZFIN 8u
#define ZRPOS 9u
#define ZDATA 10u
#define ZEOF 11u

#define ZCRCE 0x68u
#define ZCRCG 0x69u
#define ZCRCQ 0x6Au
#define ZCRCW 0x6Bu

#define ZMAXDAT 1024u

#define CANFC32 1u
#define CANFDX  2u
#define CANOVIO 4u

static unsigned char g_z_undo[8];
static unsigned char g_z_undo_n;
static unsigned char g_z_rx_bin;
static unsigned char g_zfile_tries;

static unsigned int z_crc16(unsigned char *ptr, unsigned int count)
{
  unsigned int crc;
  unsigned char b;
  unsigned char i;

  crc = 0u;
  while (count > 0u)
  {
    b = *ptr++;
    count--;
    crc = (unsigned int)(crc ^ ((unsigned int)b << 8));
    for (i = 0u; i < 8u; i++)
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

static void z_put(XferIO *io, unsigned char c)
{
  io->write_byte(io, c);
}

static void z_flush(XferIO *io)
{
  if (io->flush != 0)
  {
    io->flush(io);
  }
}

static unsigned char z_get_raw(XferIO *io, unsigned char *out)
{
  unsigned int wait;

  if (g_z_undo_n > 0u)
  {
    g_z_undo_n--;
    *out = g_z_undo[g_z_undo_n];
    return 1u;
  }
  for (wait = 0u; wait < 128u; wait++)
  {
    if (io->read_byte(io, out) != 0u)
    {
      return 1u;
    }
    if (io->cancelled != 0u)
    {
      return 0u;
    }
    if (io->pump != 0)
    {
      io->pump(io);
    }
    else
    {
      YIELD();
    }
  }
  return 0u;
}

static void z_unget_raw(unsigned char c)
{
  if (g_z_undo_n < 8u)
  {
    g_z_undo[g_z_undo_n++] = c;
  }
}

static unsigned char z_hex_nibble(unsigned char c)
{
  if (c >= '0' && c <= '9')
  {
    return (unsigned char)(c - '0');
  }
  if (c >= 'a' && c <= 'f')
  {
    return (unsigned char)(c - 'a' + 10u);
  }
  if (c >= 'A' && c <= 'F')
  {
    return (unsigned char)(c - 'A' + 10u);
  }
  return 0xFFu;
}

static unsigned char z_get_hex_byte(XferIO *io, unsigned char *out)
{
  unsigned char hi;
  unsigned char lo;
  unsigned char nh;
  unsigned char nl;

  for (;;)
  {
    if (z_get_raw(io, &hi) == 0u)
    {
      return 0u;
    }
    nh = z_hex_nibble(hi);
    if (nh == 0xFFu)
    {
      continue;
    }
    if (z_get_raw(io, &lo) == 0u)
    {
      return 0u;
    }
    nl = z_hex_nibble(lo);
    if (nl == 0xFFu)
    {
      return 0u;
    }
    *out = (unsigned char)((nh << 4) | nl);
    return 1u;
  }
}

static void z_put_hex_pair(unsigned char *out, unsigned int *n, unsigned char c)
{
  static const unsigned char hextab[] = "0123456789abcdef";

  out[(*n)++] = hextab[(c >> 4) & 0x0Fu];
  out[(*n)++] = hextab[c & 0x0Fu];
}

static void z_send_raw(XferIO *io, unsigned char c)
{
  z_put(io, c);
  if (c == ZDLE)
  {
    z_put(io, ZDLE);
  }
}

static void z_send_bin_hdr(XferIO *io, unsigned char typ, unsigned char *hdr)
{
  unsigned char rxhdr[5];
  unsigned int crc;
  unsigned char i;

  rxhdr[0] = typ;
  rxhdr[1] = hdr[0];
  rxhdr[2] = hdr[1];
  rxhdr[3] = hdr[2];
  rxhdr[4] = hdr[3];
  crc = z_crc16(rxhdr, 5u);
  z_put(io, ZPAD);
  z_put(io, ZDLE);
  z_send_raw(io, ZBIN);
  z_send_raw(io, typ);
  for (i = 0u; i < 4u; i++)
  {
    z_send_raw(io, hdr[i]);
  }
  z_send_raw(io, (unsigned char)(crc >> 8));
  z_send_raw(io, (unsigned char)(crc & 0xFFu));
  z_flush(io);
}

static void z_send_hex_hdr(XferIO *io, unsigned char typ, unsigned char *hdr)
{
  unsigned char tx[5];
  unsigned char frame[40];
  unsigned int crc;
  unsigned int n;
  unsigned char i;

  tx[0] = typ;
  tx[1] = hdr[0];
  tx[2] = hdr[1];
  tx[3] = hdr[2];
  tx[4] = hdr[3];
  crc = z_crc16(tx, 5u);
  n = 0u;
  frame[n++] = ZPAD;
  frame[n++] = ZPAD;
  frame[n++] = ZDLE;
  frame[n++] = ZHEX;
  z_put_hex_pair(frame, &n, typ);
  for (i = 0u; i < 4u; i++)
  {
    z_put_hex_pair(frame, &n, hdr[i]);
  }
  z_put_hex_pair(frame, &n, (unsigned char)(crc >> 8));
  z_put_hex_pair(frame, &n, (unsigned char)(crc & 0xFFu));
  frame[n++] = 13u;
  frame[n++] = 10u;
  if (typ != ZACK && typ != ZFIN)
  {
    frame[n++] = 17u;
  }
  io->write_buf(io, frame, n);
}

static void z_skip_hex_tail(XferIO *io)
{
  unsigned char c;

  for (;;)
  {
    if (z_get_raw(io, &c) == 0u)
    {
      return;
    }
    if (c == 13u || c == 10u || c == 17u)
    {
      continue;
    }
    z_unget_raw(c);
    return;
  }
}

static unsigned char z_read_hex_hdr(XferIO *io, unsigned char *typ, unsigned char *hdr)
{
  unsigned char rxhdr[5];
  unsigned char crcbuf[2];
  unsigned int crc;
  unsigned int got;
  unsigned char i;

  if (z_get_hex_byte(io, &rxhdr[0]) == 0u)
  {
    return 0u;
  }
  for (i = 0u; i < 4u; i++)
  {
    if (z_get_hex_byte(io, &rxhdr[i + 1u]) == 0u)
    {
      return 0u;
    }
    hdr[i] = rxhdr[i + 1u];
  }
  if (z_get_hex_byte(io, &crcbuf[0]) == 0u)
  {
    return 0u;
  }
  if (z_get_hex_byte(io, &crcbuf[1]) == 0u)
  {
    return 0u;
  }
  crc = z_crc16(rxhdr, 5u);
  got = ((unsigned int)crcbuf[0] << 8) | (unsigned int)crcbuf[1];
  if (crc != got)
  {
    return 3u;
  }
  *typ = rxhdr[0];
  z_skip_hex_tail(io);
  return 1u;
}

static unsigned char z_read_hex_subpacket(XferIO *io, unsigned char *buf, unsigned int max,
                                          unsigned int *dlen, unsigned char *end)
{
  unsigned char b;
  unsigned char c;
  unsigned int n;

  n = 0u;
  for (;;)
  {
    if (z_get_hex_byte(io, &b) == 0u)
    {
      return 0u;
    }
    if (b == ZDLE)
    {
      if (z_get_hex_byte(io, &c) == 0u)
      {
        return 0u;
      }
      if (c >= ZCRCE && c <= ZCRCW)
      {
        *end = c;
        *dlen = n;
        z_skip_hex_tail(io);
        return 1u;
      }
      if (n < max)
      {
        buf[n++] = b;
      }
      if (n < max)
      {
        buf[n++] = c;
      }
      continue;
    }
    if (n < max)
    {
      buf[n++] = b;
    }
  }
}

static void z_send_zfin(XferIO *io)
{
  unsigned char hdr[4];

  hdr[0] = 0u;
  hdr[1] = 0u;
  hdr[2] = 0u;
  hdr[3] = 0u;
  z_send_hex_hdr(io, ZFIN, hdr);
}

static void z_send_can(XferIO *io, unsigned char count)
{
  unsigned char i;

  for (i = 0u; i < count; i++)
  {
    z_put(io, 0x18u);
  }
  z_flush(io);
}

static void z_send_zrinit(XferIO *io)
{
  unsigned char hdr[4];

  hdr[0] = (unsigned char)(CANFC32 | CANFDX | CANOVIO);
  hdr[1] = (unsigned char)((ZMAXDAT >> 8) & 0xFFu);
  hdr[2] = (unsigned char)(ZMAXDAT & 0xFFu);
  hdr[3] = 0u;
  z_send_hex_hdr(io, ZRINIT, hdr);
  z_flush(io);
  xfer_zmodem_unlock();
}

static void z_hdr_to_pos(unsigned char *hdr, unsigned long pos)
{
  hdr[0] = (unsigned char)(pos & 0xFFu);
  hdr[1] = (unsigned char)((pos >> 8) & 0xFFu);
  hdr[2] = (unsigned char)((pos >> 16) & 0xFFu);
  hdr[3] = (unsigned char)((pos >> 24) & 0xFFu);
}

static void z_send_posack(XferIO *io, unsigned char typ, unsigned long pos, unsigned char use_bin)
{
  unsigned char hdr[4];

  z_hdr_to_pos(hdr, pos);
  if (use_bin != 0u)
  {
    z_send_bin_hdr(io, typ, hdr);
  }
  else
  {
    z_send_hex_hdr(io, typ, hdr);
    z_flush(io);
  }
}

static unsigned char z_get_escaped(XferIO *io, unsigned char *out)
{
  unsigned char c;
  unsigned char n;

  if (z_get_raw(io, &c) == 0u)
  {
    return 0u;
  }
  if (c != ZDLE)
  {
    *out = c;
    return 1u;
  }
  if (z_get_raw(io, &n) == 0u)
  {
    return 0u;
  }
  if (n == ZDLE)
  {
    *out = ZDLE;
    return 1u;
  }
  if (n >= ZCRCE && n <= ZCRCW)
  {
    *out = n;
    return 3u;
  }
  if (n == 24u)
  {
    return 2u;
  }
  if ((n & 0x60u) == 0x40u)
  {
    *out = (unsigned char)(n ^ 0x40u);
    return 1u;
  }
  *out = n;
  return 1u;
}

static unsigned char z_read_subpacket(XferIO *io, unsigned char *buf, unsigned int max,
                                      unsigned int *dlen, unsigned char *end)
{
  unsigned char c;
  unsigned char rc;
  unsigned int n;

  n = *dlen;
  for (;;)
  {
    rc = z_get_escaped(io, &c);
    if (rc == 0u)
    {
      return 0u;
    }
    if (rc == 2u)
    {
      return 2u;
    }
    if (rc == 3u)
    {
      *end = c;
      *dlen = n;
      (void)z_get_raw(io, &c);
      (void)z_get_raw(io, &c);
      return 1u;
    }
    if (n < max)
    {
      buf[n++] = c;
    }
  }
}

static unsigned char z_read_hex_frame(XferIO *io, unsigned char *typ, unsigned char *hdr,
                                      unsigned char *data, unsigned int *dlen)
{
  unsigned char rc;
  unsigned char end;

  rc = z_read_hex_hdr(io, typ, hdr);
  if (rc != 1u)
  {
    return rc;
  }
  if (*typ == ZFILE || *typ == ZDATA)
  {
    return z_read_hex_subpacket(io, data, ZMAXDAT, dlen, &end);
  }
  *dlen = 0u;
  return 1u;
}

static unsigned char z_hdr_crc_ok(unsigned char *rxhdr, unsigned char *crcbuf)
{
  unsigned int crc;
  unsigned int got;

  crc = z_crc16(rxhdr, 5u);
  got = ((unsigned int)crcbuf[0] << 8) | (unsigned int)crcbuf[1];
  if (crc == got)
  {
    return 1u;
  }
  got = ((unsigned int)crcbuf[1] << 8) | (unsigned int)crcbuf[0];
  if (crc == got)
  {
    return 1u;
  }
  return 0u;
}

static unsigned char z_typ_valid(unsigned char typ)
{
  return (unsigned char)(typ <= 13u);
}

static unsigned char z_read_frame(XferIO *io, unsigned char *typ, unsigned char *hdr,
                                  unsigned char *data, unsigned int *dlen)
{
  unsigned char c;
  unsigned char rc;
  unsigned char rxhdr[5];
  unsigned char crcbuf[2];
  unsigned char end;
  unsigned char i;

  *dlen = 0u;
  for (;;)
  {
    if (z_get_raw(io, &c) == 0u)
    {
      return 0u;
    }
    if (c == ZPAD)
    {
      if (z_get_raw(io, &c) == 0u)
      {
        z_unget_raw(ZPAD);
        return 0u;
      }
      if (c == ZPAD)
      {
        if (z_get_raw(io, &c) == 0u)
        {
          z_unget_raw(ZPAD);
          z_unget_raw(ZPAD);
          return 0u;
        }
        if (c == 'B' || c == 'b' || c == ZHEX)
        {
          g_z_rx_bin = 0u;
          return z_read_hex_frame(io, typ, hdr, data, dlen);
        }
        if (c == ZDLE)
        {
          if (z_get_raw(io, &c) == 0u)
          {
            z_unget_raw(ZPAD);
            z_unget_raw(ZPAD);
            return 0u;
          }
          if (c == 'B' || c == 'b' || c == ZHEX)
          {
            g_z_rx_bin = 0u;
            return z_read_hex_frame(io, typ, hdr, data, dlen);
          }
          if (c == ZBIN || c == ZBIN32 || c == 'A' || c == 'a' || c == 'C' || c == 'c')
          {
            g_z_rx_bin = 1u;
            break;
          }
          z_unget_raw(c);
          z_unget_raw(ZPAD);
          z_unget_raw(ZPAD);
          return 0u;
        }
        z_unget_raw(c);
        z_unget_raw(ZPAD);
        z_unget_raw(ZPAD);
        return 0u;
      }
      if (c == ZDLE)
      {
        if (z_get_raw(io, &c) == 0u)
        {
          z_unget_raw(ZPAD);
          return 0u;
        }
        if (c == 'B' || c == 'b' || c == ZHEX)
        {
          g_z_rx_bin = 0u;
          return z_read_hex_frame(io, typ, hdr, data, dlen);
        }
        if (c == ZBIN || c == ZBIN32 || c == 'A' || c == 'a' || c == 'C' || c == 'c')
        {
          g_z_rx_bin = 1u;
          break;
        }
        continue;
      }
      if (c == 'B' || c == 'b' || c == ZHEX)
      {
        g_z_rx_bin = 0u;
        return z_read_hex_frame(io, typ, hdr, data, dlen);
      }
      continue;
    }
    if (c == ZDLE)
    {
      if (z_get_raw(io, &c) == 0u)
      {
        return 0u;
      }
      if (c == ZDLE)
      {
        if (z_get_raw(io, &c) == 0u)
        {
          return 0u;
        }
      }
      if (c == 'B' || c == 'b' || c == ZHEX)
      {
        g_z_rx_bin = 0u;
        return z_read_hex_frame(io, typ, hdr, data, dlen);
      }
      if (c == ZBIN || c == ZBIN32 || c == 'A' || c == 'a' || c == 'C' || c == 'c')
      {
        g_z_rx_bin = 1u;
        break;
      }
      continue;
    }
    if (c == 13u || c == 10u || c == 17u || c == 11u)
    {
      continue;
    }
  }

  if (z_get_raw(io, typ) == 0u)
  {
    return 0u;
  }
  rxhdr[0] = *typ;
  for (i = 0u; i < 4u; i++)
  {
    if (z_get_raw(io, &rxhdr[i + 1u]) == 0u)
    {
      return 0u;
    }
    hdr[i] = rxhdr[i + 1u];
  }
  if (z_get_raw(io, &crcbuf[0]) == 0u)
  {
    return 0u;
  }
  if (z_get_raw(io, &crcbuf[1]) == 0u)
  {
    return 0u;
  }
  if (z_hdr_crc_ok(rxhdr, crcbuf) == 0u && z_typ_valid(*typ) == 0u)
  {
    return 3u;
  }

  rc = z_get_escaped(io, &c);
  if (rc == 0u)
  {
    return 0u;
  }
  if (rc == 2u)
  {
    return 2u;
  }
  if (rc == 3u)
  {
    *dlen = 0u;
    return 1u;
  }

  *dlen = 0u;
  data[0] = c;
  *dlen = 1u;
  return z_read_subpacket(io, data, ZMAXDAT, dlen, &end);
}

static void z_parse_name(unsigned char *data, unsigned int len, char *name)
{
  unsigned int i;
  unsigned char j;

  for (i = 0u; i < len && i < 63u && data[i] != 0; i++)
  {
    name[i] = (char)data[i];
  }
  name[i] = 0;
  for (j = 0u; name[j] != 0; j++)
  {
    if (name[j] == '\\' || name[j] == '/' || name[j] == ':')
    {
      name[j] = '_';
    }
  }
}

static unsigned char z_same_name(const char *a, const char *b)
{
  unsigned char i;

  for (i = 0u; i < 63u; i++)
  {
    if (a[i] != b[i])
    {
      return 0u;
    }
    if (a[i] == 0)
    {
      return 1u;
    }
  }
  return 0u;
}

static FILE *z_open_out(const char *name)
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
  }
  return OS_CREATEHANDLE((unsigned char *)path, 0x80u);
}

static void z_close_out(FILE **pfp, const char *name, unsigned long fpos, unsigned char del_empty)
{
  if (pfp != 0 && *pfp != 0)
  {
    OS_CLOSEHANDLE(*pfp);
    *pfp = 0;
  }
  if (del_empty != 0u && fpos == 0ul && name != 0 && name[0] != 0)
  {
    (void)OS_DELETE((unsigned char *)name);
  }
}

static void z_pump_io(XferIO *io, unsigned char rounds)
{
  unsigned char i;

  if (io->pump == 0)
  {
    return;
  }
  for (i = 0u; i < rounds; i++)
  {
    io->pump(io);
  }
}

static unsigned char z_handle_zfile(XferIO *io, char *fname, unsigned int dlen, FILE **pfp,
                                    unsigned long *pfpos, unsigned char *pgot_data)
{
  char newname[64];
  unsigned char use_bin;

  xfer_zmodem_unlock();
  z_parse_name(g_xfer_block, dlen, newname);
  if (newname[0] == 0)
  {
    return 0u;
  }
  if (*pfp != 0 && z_same_name(fname, newname) != 0u && *pfpos == 0ul && *pgot_data == 0u)
  {
    g_zfile_tries++;
  }
  else
  {
    g_zfile_tries = 0u;
    z_close_out(pfp, fname, *pfpos, 0u);
    strcpy(fname, newname);
    *pfpos = 0ul;
    *pgot_data = 0u;
    *pfp = z_open_out(fname);
    if (((int)(*pfp)) & 0xFF)
    {
      *pfp = 0;
      if (io->status != 0)
      {
        io->status(io, "Zmodem: cannot create file");
      }
      return 0u;
    }
    if (io->status != 0)
    {
      io->status(io, fname);
    }
  }
  use_bin = 0u;
  if (g_zfile_tries > 0u)
  {
    use_bin = (unsigned char)(g_zfile_tries & 1u);
  }
  z_send_posack(io, ZRPOS, 0ul, use_bin);
  if (io->status != 0)
  {
    io->status(io, "Zmodem: ZRPOS sent");
  }
  z_pump_io(io, 48u);
  return 1u;
}

int xfer_zmodem_receive(XferIO *io)
{
  unsigned char typ;
  unsigned char hdr[4];
  unsigned int dlen;
  unsigned char rc;
  char fname[64];
  FILE *fp;
  unsigned long fpos;
  unsigned char idle;
  unsigned char got_data;
  unsigned char await_file;
  unsigned char draw_skip;

  fp = 0;
  fpos = 0ul;
  fname[0] = 0;
  idle = 0u;
  got_data = 0u;
  await_file = 0u;
  draw_skip = 0u;
  g_z_undo_n = 0u;
  g_z_rx_bin = 0u;
  g_zfile_tries = 0u;
  xfer_zmodem_mode(1u);
  xfer_zmodem_unlock();
  xfer_dbg_zmodem_begin();
  z_pump_io(io, 64u);

  rc = z_read_frame(io, &typ, hdr, g_xfer_block, &dlen);
  if (rc == 1u && typ == ZRQINIT)
  {
    z_send_zrinit(io);
    await_file = 1u;
  }
  else
  {
    z_send_zrinit(io);
    await_file = 1u;
  }
  if (rc == 1u && typ != ZRQINIT)
  {
    goto handle_frame;
  }

  for (;;)
  {
    if (io->cancelled != 0u)
    {
      z_close_out(&fp, fname, fpos, 1u);
      z_send_can(io, 8u);
      return 0;
    }
    rc = z_read_frame(io, &typ, hdr, g_xfer_block, &dlen);
    if (rc == 0u)
    {
      idle++;
      z_pump_io(io, 8u);
      if ((idle & 0x3Fu) == 0u)
      {
        xfer_dbg_frame(rc, typ, idle);
        if ((draw_skip++ & 0x07u) == 0u)
        {
          xfer_dbg_draw(xfer_queue_depth());
        }
      }
      if (idle >= 2400u && await_file != 0u)
      {
        idle = 0u;
        z_send_zrinit(io);
      }
      YIELD();
      continue;
    }
    idle = 0u;
    if (rc == 2u)
    {
      z_close_out(&fp, fname, fpos, 1u);
      return 0;
    }
    if (rc == 3u)
    {
      xfer_dbg_frame(rc, typ, idle);
      continue;
    }

    xfer_dbg_frame(rc, typ, idle);
    if (typ != ZDATA || (draw_skip++ & 0x0Fu) == 0u)
    {
      xfer_dbg_draw(xfer_queue_depth());
    }

handle_frame:
    if (typ == ZFILE)
    {
      await_file = 0u;
      if (z_handle_zfile(io, fname, dlen, &fp, &fpos, &got_data) == 0u)
      {
        z_close_out(&fp, fname, fpos, 1u);
        return 0;
      }
    }
    else if (typ == ZDATA)
    {
      if (fp != 0 && dlen > 0u)
      {
        OS_WRITEHANDLE(g_xfer_block, fp, dlen);
        fpos += (unsigned long)dlen;
        got_data = 1u;
        g_zfile_tries = 0u;
      }
      z_send_posack(io, ZACK, fpos, 0u);
    }
    else if (typ == ZEOF)
    {
      z_close_out(&fp, fname, fpos, 0u);
      z_send_posack(io, ZRPOS, fpos, 0u);
    }
    else if (typ == ZFIN)
    {
      z_put(io, 'O');
      z_put(io, 'O');
      z_flush(io);
      if (got_data == 0u && fpos == 0ul)
      {
        z_close_out(&fp, fname, fpos, 1u);
        return 0;
      }
      z_close_out(&fp, fname, fpos, 0u);
      if (io->status != 0)
      {
        io->status(io, "Zmodem: done");
      }
      return 1;
    }
    else if (typ == ZRQINIT)
    {
      z_send_zrinit(io);
    }
  }
}
