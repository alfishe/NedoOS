/*
 * sxgview - TS-Config SXG stills on ATM 320x200x16.
 *
 * Real header (16 bytes, bmp2sXg / moroz1999/sxg):
 *   7F 'S' 'X' 'G', version, bgcolor, packing (0=raw), format (1=16c, 2=256c),
 *   width LE, height LE, pal shift from 0x0E, pixel shift from 0x10.
 * Palette: RGB555 LE. 4bpp: high nibble first. Typical TS sizes: 320x240, 360x288.
 * ATM shows a 320x200 crop: center first. Arrows move by half a screen, or
 * to the edge if less remains (360x288 still reaches the stop in one press).
 *
 * Keys: P = 64-color (PWM off) / file DDp, N = nibble order,
 *       arrows = pan crop (edge is a stop), other = quit.
 */
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include <graphic.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gfx.h"

#define SXG_MAGIC0     0x7Fu
#define SXG_MAGIC1     'S'
#define SXG_MAGIC2     'X'
#define SXG_MAGIC3     'G'
#define SXG_HDR_SIZE   16u
#define SXG_MAX_W      1024u
#define SXG_MAX_H      2048u

#define KEY_LEFT  248
#define KEY_DOWN  249
#define KEY_UP    250
#define KEY_RIGHT 251

/* ATM pair encoding (doc 5.4 / iarlib gfxdraw.asm zx_ega_*_tab). */
static const unsigned char left_tab[16] = {
  0, 1, 2, 3, 4, 5, 6, 7, 64, 65, 66, 67, 68, 69, 70, 71
};
static const unsigned char right_tab[16] = {
  0, 8, 16, 24, 32, 40, 48, 56, 128, 136, 144, 152, 160, 168, 176, 184
};

unsigned char g_row[160];

static FILE *g_fp;
static unsigned int g_width;
static unsigned int g_height;
static unsigned char g_bpp;
static unsigned char g_bg;
static unsigned int g_ncolors;
static unsigned long g_pix_ofs;
static unsigned char g_use_ddp;
static unsigned char g_ddp_port; /* 1 = Evo/ATM3: port #BF D5 is PWM/444 */
static unsigned char g_key_held; /* 1 = still the same GETKEY make/repeat */
static unsigned char g_nibble_swap;
static unsigned char g_ddp[GFX_PALETTE_OS_BYTES];
static unsigned char g_idx_map[256];
static unsigned char g_pixrow[GFX_EGA_SCREEN_W];
static unsigned char g_srcrow[SXG_MAX_W];
static unsigned char g_pair_tab[256];
static unsigned char g_chunk[2048];
static unsigned int g_chunk_i;
static unsigned int g_chunk_n;
static unsigned char g_pal_r[256];
static unsigned char g_pal_g[256];
static unsigned char g_pal_b[256];
static unsigned char g_pal_bytes[512];
static unsigned char g_opened;
/* Crop origin in the source image; start centered. */
static unsigned int g_src_x;
static unsigned int g_src_y;

/* Evo/ATM3: OUT (#BF),32 enables 12-bit PWM (DDp). 0 = 64-color DAC.
 * Kernel ISR follows the focused app palette; this is extra between frames. */
static void ddp_hw_apply(void)
{
  if (g_ddp_port == 0u)
  {
    return;
  }
  output(0xBFu, (unsigned char)(g_use_ddp ? 32u : 0u));
}

static unsigned char adiff(unsigned char a, unsigned char b)
{
  if (a > b)
  {
    return (unsigned char)(a - b);
  }
  return (unsigned char)(b - a);
}

/* view.asm palcol: DDp %grbG11RB inverted, 4-bit RGB.
 * Evo PWM uses the low 2 bits of each nibble (4096). ATM 64-color DAC is bits 2-3. */
static void rgb4_to_ddp(unsigned char r, unsigned char g, unsigned char b,
                        unsigned char *lo, unsigned char *hi)
{
  unsigned char v0;
  unsigned char v1;

  r = (unsigned char)(r & 15u);
  g = (unsigned char)(g & 15u);
  b = (unsigned char)(b & 15u);
  v0 = (unsigned char)(((g & 1u) << 7) | ((r & 1u) << 6) | ((b & 1u) << 5)
                       | ((g & 2u) << 3) | (r & 2u) | ((b & 2u) >> 1));
  v1 = (unsigned char)(((g & 4u) << 5) | ((r & 4u) << 4) | ((b & 4u) << 3)
                       | ((g & 8u) << 1) | ((r & 8u) >> 2) | ((b & 8u) >> 3));
  *lo = (unsigned char)(0xFFu - v0);
  *hi = (unsigned char)(0xFFu - v1);
}

/* Drop PWM bits: RGB444 -> RGB222 (64 hardware colours). */
static void rgb4_to_64(unsigned char *r, unsigned char *g, unsigned char *b)
{
  *r = (unsigned char)(*r & 12u);
  *g = (unsigned char)(*g & 12u);
  *b = (unsigned char)(*b & 12u);
}

static unsigned int pal_word(const unsigned char *pal_bytes, unsigned int i);
static void word_to_rgb4(unsigned int word, unsigned char *r4,
                         unsigned char *g4, unsigned char *b4);

static void pal_rgb4(const unsigned char *pal_bytes, unsigned int i,
                     unsigned char *r4, unsigned char *g4, unsigned char *b4)
{
  word_to_rgb4(pal_word(pal_bytes, i), r4, g4, b4);
  if (g_use_ddp == 0u)
  {
    rgb4_to_64(r4, g4, b4);
  }
}

static unsigned char rgb555_to4(unsigned char c5)
{
  return (unsigned char)((c5 >> 1) & 15u);
}

static void fail(const char *msg)
{
  OS_SETGFX(GFX_MODE_TEXT_KEEP);
  OS_CLS(0);
  OS_SETCOLOR(7u);
  OS_SETXY(0, 0);
  printf("%s\r\n", msg);
  OS_SETXY(0, 2);
  printf("Press a key\r\n");
  for (;;)
  {
    if ((unsigned char)OS_GETKEY() != 0u)
    {
      break;
    }
    YIELD();
  }
  if (g_opened)
  {
    OS_CLOSEHANDLE(g_fp);
    g_opened = 0u;
  }
  gfx_shutdown();
  g_use_ddp = 1u;
  ddp_hw_apply();
  exit(1);
}

static unsigned int read_exact(unsigned char *dst, unsigned int n)
{
  unsigned int got;
  unsigned int chunk;

  got = 0u;
  while (got < n)
  {
    chunk = OS_READHANDLE(dst + got, g_fp, (unsigned int)(n - got));
    if (chunk == 0u || chunk == 0xffffu)
    {
      return got;
    }
    got = (unsigned int)(got + chunk);
  }
  return got;
}

static unsigned char sat4(unsigned char r, unsigned char g, unsigned char b)
{
  unsigned char mx;
  unsigned char mn;

  mx = r;
  if (g > mx)
  {
    mx = g;
  }
  if (b > mx)
  {
    mx = b;
  }
  mn = r;
  if (g < mn)
  {
    mn = g;
  }
  if (b < mn)
  {
    mn = b;
  }
  return (unsigned char)(mx - mn);
}

static unsigned int pal_dist(unsigned char i, unsigned char j)
{
  return (unsigned int)adiff(g_pal_r[i], g_pal_r[j])
         + (unsigned int)adiff(g_pal_g[i], g_pal_g[j])
         + (unsigned int)adiff(g_pal_b[i], g_pal_b[j]);
}

/* 16 diverse CLUT entries: start at darkest, then maximin + saturation. */
static void pick_16_diverse(unsigned char *pick)
{
  unsigned int i;
  unsigned int k;
  unsigned int best;
  unsigned int best_score;
  unsigned int lum;
  unsigned int d;
  unsigned int score;
  unsigned char nsel;
  unsigned char already;

  best = 0u;
  best_score = 0xffffu;
  for (i = 0u; i < g_ncolors; i++)
  {
    lum = (unsigned int)g_pal_r[i] + g_pal_g[i] + g_pal_b[i];
    if (lum < best_score)
    {
      best_score = lum;
      best = i;
    }
  }
  pick[0] = (unsigned char)best;

  for (nsel = 1u; nsel < 16u; nsel++)
  {
    best = 0u;
    best_score = 0u;
    for (i = 0u; i < g_ncolors; i++)
    {
      already = 0u;
      for (k = 0u; k < (unsigned int)nsel; k++)
      {
        if (pick[k] == (unsigned char)i)
        {
          already = 1u;
          break;
        }
      }
      if (already)
      {
        continue;
      }
      d = 0xffffu;
      for (k = 0u; k < (unsigned int)nsel; k++)
      {
        score = pal_dist((unsigned char)i, pick[k]);
        if (score < d)
        {
          d = score;
        }
      }
      if (d == 0u)
      {
        continue;
      }
      score = d + d
              + (unsigned int)sat4(g_pal_r[i], g_pal_g[i], g_pal_b[i]);
      if (score > best_score)
      {
        best_score = score;
        best = i;
      }
    }
    if (best_score == 0u)
    {
      for (i = 0u; i < g_ncolors; i++)
      {
        already = 0u;
        for (k = 0u; k < (unsigned int)nsel; k++)
        {
          if (pick[k] == (unsigned char)i)
          {
            already = 1u;
            break;
          }
        }
        if (!already)
        {
          best = i;
          break;
        }
      }
    }
    pick[nsel] = (unsigned char)best;
  }
}

static unsigned char nearest16(unsigned char r, unsigned char g, unsigned char b)
{
  unsigned char i;
  unsigned char best;
  unsigned int best_d;
  unsigned int d;

  best = 0u;
  best_d = 0xffffu;
  for (i = 0u; i < 16u; i++)
  {
    d = (unsigned int)adiff(r, g_pal_r[i])
        + (unsigned int)adiff(g, g_pal_g[i])
        + (unsigned int)adiff(b, g_pal_b[i]);
    if (d < best_d)
    {
      best_d = d;
      best = i;
    }
  }
  return best;
}

static unsigned int pal_word(const unsigned char *pal_bytes, unsigned int i)
{
  return (unsigned int)pal_bytes[i * 2u]
         | ((unsigned int)pal_bytes[i * 2u + 1u] << 8);
}

static void word_to_rgb4(unsigned int word, unsigned char *r4,
                         unsigned char *g4, unsigned char *b4)
{
  *r4 = rgb555_to4((unsigned char)((word >> 10) & 0x1Fu));
  *g4 = rgb555_to4((unsigned char)((word >> 5) & 0x1Fu));
  *b4 = rgb555_to4((unsigned char)(word & 0x1Fu));
}

static void build_file_palette(const unsigned char *pal_bytes)
{
  unsigned int i;
  unsigned char r4;
  unsigned char g4;
  unsigned char b4;
  unsigned char lo;
  unsigned char hi;
  static unsigned char pick[16];
  static unsigned char hw_r[16];
  static unsigned char hw_g[16];
  static unsigned char hw_b[16];

  for (i = 0u; i < 256u; i++)
  {
    g_idx_map[i] = 0u;
  }

  if (g_bpp != 8u)
  {
    for (i = 0u; i < 16u; i++)
    {
      if (i < g_ncolors)
      {
        pal_rgb4(pal_bytes, i, &r4, &g4, &b4);
      }
      else
      {
        r4 = 0u;
        g4 = 0u;
        b4 = 0u;
      }
      g_pal_r[i] = r4;
      g_pal_g[i] = g4;
      g_pal_b[i] = b4;
      rgb4_to_ddp(r4, g4, b4, &lo, &hi);
      g_ddp[i * 2u] = lo;
      g_ddp[i * 2u + 1u] = hi;
      g_idx_map[i] = (unsigned char)((i < g_ncolors) ? i : 0u);
    }
    return;
  }

  /* Full CLUT (RGB444 or RGB222), then 16 diverse hardware slots. */
  for (i = 0u; i < g_ncolors; i++)
  {
    pal_rgb4(pal_bytes, i, &r4, &g4, &b4);
    g_pal_r[i] = r4;
    g_pal_g[i] = g4;
    g_pal_b[i] = b4;
  }

  if (g_ncolors <= 16u)
  {
    for (i = 0u; i < 16u; i++)
    {
      if (i < g_ncolors)
      {
        r4 = g_pal_r[i];
        g4 = g_pal_g[i];
        b4 = g_pal_b[i];
        g_idx_map[i] = (unsigned char)i;
      }
      else
      {
        r4 = 0u;
        g4 = 0u;
        b4 = 0u;
      }
      rgb4_to_ddp(r4, g4, b4, &lo, &hi);
      g_ddp[i * 2u] = lo;
      g_ddp[i * 2u + 1u] = hi;
    }
    return;
  }

  pick_16_diverse(pick);
  for (i = 0u; i < 16u; i++)
  {
    hw_r[i] = g_pal_r[pick[i]];
    hw_g[i] = g_pal_g[pick[i]];
    hw_b[i] = g_pal_b[pick[i]];
  }
  for (i = 0u; i < 16u; i++)
  {
    g_pal_r[i] = hw_r[i];
    g_pal_g[i] = hw_g[i];
    g_pal_b[i] = hw_b[i];
    rgb4_to_ddp(hw_r[i], hw_g[i], hw_b[i], &lo, &hi);
    g_ddp[i * 2u] = lo;
    g_ddp[i * 2u + 1u] = hi;
  }
  for (i = 0u; i < g_ncolors; i++)
  {
    pal_rgb4(pal_bytes, i, &r4, &g4, &b4);
    g_idx_map[i] = nearest16(r4, g4, b4);
  }
}

static void apply_palette(void)
{
  /* Mode bit first, then DAC bytes (444 vs 64c). Kernel ISR does the same. */
  ddp_hw_apply();
  gfx_set_palette_bytes(g_ddp);
  ddp_hw_apply();
}

static void build_pair_tab(void)
{
  unsigned int b;
  unsigned char p0;
  unsigned char p1;
  unsigned char t;

  for (b = 0u; b < 256u; b++)
  {
    p0 = (unsigned char)((b >> 4) & 15u);
    p1 = (unsigned char)(b & 15u);
    if (g_nibble_swap)
    {
      t = p0;
      p0 = p1;
      p1 = t;
    }
    p0 = g_idx_map[p0];
    p1 = g_idx_map[p1];
    g_pair_tab[b] = (unsigned char)(left_tab[p0] | right_tab[p1]);
  }
}

static unsigned int row_bytes(void)
{
  if (g_bpp == 8u)
  {
    return g_width;
  }
  return (unsigned int)((g_width + 1u) / 2u);
}

static void plot_row(unsigned char y, const unsigned char *pix)
{
  unsigned int yoff;
  unsigned char col;
  unsigned char *b0;
  unsigned char *b1;
  unsigned char *b2;
  unsigned char *b3;

  yoff = ((unsigned int)y << 5) + ((unsigned int)y << 3);
  b0 = (unsigned char *)(0x8000u + yoff);
  b1 = (unsigned char *)(0xC000u + yoff);
  b2 = (unsigned char *)(0xA000u + yoff);
  b3 = (unsigned char *)(0xE000u + yoff);
  for (col = 0u; col < 40u; col++)
  {
    *b0++ = (unsigned char)(left_tab[pix[0] & 15u] | right_tab[pix[1] & 15u]);
    *b1++ = (unsigned char)(left_tab[pix[2] & 15u] | right_tab[pix[3] & 15u]);
    *b2++ = (unsigned char)(left_tab[pix[4] & 15u] | right_tab[pix[5] & 15u]);
    *b3++ = (unsigned char)(left_tab[pix[6] & 15u] | right_tab[pix[7] & 15u]);
    pix += 8;
  }
}

/* 4bpp: 160 packed bytes (320 pixels, even start) -> ATM banks. */
static void plot_row_4(unsigned char y, const unsigned char *src)
{
  unsigned int yoff;
  unsigned char col;
  unsigned char *b0;
  unsigned char *b1;
  unsigned char *b2;
  unsigned char *b3;

  yoff = ((unsigned int)y << 5) + ((unsigned int)y << 3);
  b0 = (unsigned char *)(0x8000u + yoff);
  b1 = (unsigned char *)(0xC000u + yoff);
  b2 = (unsigned char *)(0xA000u + yoff);
  b3 = (unsigned char *)(0xE000u + yoff);
  for (col = 0u; col < 40u; col++)
  {
    *b0++ = g_pair_tab[src[0]];
    *b1++ = g_pair_tab[src[1]];
    *b2++ = g_pair_tab[src[2]];
    *b3++ = g_pair_tab[src[3]];
    src += 4;
  }
}

static void plot_row_8(unsigned char y, const unsigned char *src)
{
  unsigned int yoff;
  unsigned char col;
  unsigned char *b0;
  unsigned char *b1;
  unsigned char *b2;
  unsigned char *b3;

  yoff = ((unsigned int)y << 5) + ((unsigned int)y << 3);
  b0 = (unsigned char *)(0x8000u + yoff);
  b1 = (unsigned char *)(0xC000u + yoff);
  b2 = (unsigned char *)(0xA000u + yoff);
  b3 = (unsigned char *)(0xE000u + yoff);
  for (col = 0u; col < 40u; col++)
  {
    *b0++ = (unsigned char)(left_tab[g_idx_map[src[0]]] | right_tab[g_idx_map[src[1]]]);
    *b1++ = (unsigned char)(left_tab[g_idx_map[src[2]]] | right_tab[g_idx_map[src[3]]]);
    *b2++ = (unsigned char)(left_tab[g_idx_map[src[4]]] | right_tab[g_idx_map[src[5]]]);
    *b3++ = (unsigned char)(left_tab[g_idx_map[src[6]]] | right_tab[g_idx_map[src[7]]]);
    src += 8;
  }
}

static void unpack_row(const unsigned char *src, unsigned int vis_w,
                       unsigned int dst_x)
{
  unsigned int x;
  unsigned int si;
  unsigned char v;
  unsigned char p0;
  unsigned char p1;

  if (g_bpp == 8u)
  {
    for (x = 0u; x < vis_w; x++)
    {
      g_pixrow[dst_x + x] = g_idx_map[src[x]];
    }
    return;
  }

  si = 0u;
  x = 0u;
  while (x < vis_w)
  {
    v = src[si];
    si++;
    p0 = (unsigned char)((v >> 4) & 15u);
    p1 = (unsigned char)(v & 15u);
    if (g_nibble_swap)
    {
      v = p0;
      p0 = p1;
      p1 = v;
    }
    g_pixrow[dst_x + x] = g_idx_map[p0];
    x++;
    if (x < vis_w)
    {
      g_pixrow[dst_x + x] = g_idx_map[p1];
      x++;
    }
  }
}

static void chunk_rewind(unsigned long ofs)
{
  OS_SEEKHANDLE(g_fp, ofs);
  g_chunk_i = 0u;
  g_chunk_n = 0u;
}

static unsigned int chunk_read(unsigned char *dst, unsigned int n)
{
  unsigned int got;
  unsigned int take;

  got = 0u;
  while (got < n)
  {
    if (g_chunk_i >= g_chunk_n)
    {
      g_chunk_n = OS_READHANDLE(g_chunk, g_fp, (unsigned int)sizeof(g_chunk));
      g_chunk_i = 0u;
      if (g_chunk_n == 0u || g_chunk_n == 0xffffu)
      {
        return got;
      }
    }
    take = (unsigned int)(n - got);
    if (take > (unsigned int)(g_chunk_n - g_chunk_i))
    {
      take = (unsigned int)(g_chunk_n - g_chunk_i);
    }
    memcpy(dst + got, g_chunk + g_chunk_i, take);
    g_chunk_i = (unsigned int)(g_chunk_i + take);
    got = (unsigned int)(got + take);
  }
  return got;
}

static const unsigned char *chunk_row(unsigned int n)
{
  unsigned char *p;

  if ((unsigned int)(g_chunk_n - g_chunk_i) >= n)
  {
    p = g_chunk + g_chunk_i;
    g_chunk_i = (unsigned int)(g_chunk_i + n);
    return p;
  }
  if (chunk_read(g_srcrow, n) < n)
  {
    return 0;
  }
  return g_srcrow;
}

static void draw_image(void)
{
  unsigned int src_x0;
  unsigned int src_y0;
  unsigned int dst_x0;
  unsigned int dst_y0;
  unsigned int vis_w;
  unsigned int vis_h;
  unsigned int maxx;
  unsigned int maxy;
  unsigned int rb;
  unsigned int skip_head;
  unsigned int y;
  unsigned char full_w;
  unsigned long ofs;
  const unsigned char *row;

  vis_w = g_width;
  vis_h = g_height;
  src_x0 = 0u;
  src_y0 = 0u;
  dst_x0 = 0u;
  dst_y0 = 0u;
  if (vis_w > GFX_EGA_SCREEN_W)
  {
    maxx = (unsigned int)(vis_w - GFX_EGA_SCREEN_W);
    src_x0 = g_src_x;
    if (src_x0 > maxx)
    {
      src_x0 = maxx;
    }
    if (g_bpp != 8u)
    {
      src_x0 = (unsigned int)(src_x0 & ~1u);
    }
    vis_w = GFX_EGA_SCREEN_W;
  }
  else
  {
    dst_x0 = (unsigned int)((GFX_EGA_SCREEN_W - vis_w) / 2u);
    dst_x0 = (unsigned int)(dst_x0 & ~1u);
  }
  if (vis_h > GFX_EGA_SCREEN_H)
  {
    maxy = (unsigned int)(vis_h - GFX_EGA_SCREEN_H);
    src_y0 = g_src_y;
    if (src_y0 > maxy)
    {
      src_y0 = maxy;
    }
    vis_h = GFX_EGA_SCREEN_H;
  }
  else
  {
    dst_y0 = (unsigned int)((GFX_EGA_SCREEN_H - vis_h) / 2u);
  }

  rb = row_bytes();
  skip_head = src_x0;
  if (g_bpp != 8u)
  {
    skip_head = src_x0 / 2u;
  }
  full_w = (unsigned char)((dst_x0 == 0u && vis_w == GFX_EGA_SCREEN_W) ? 1u : 0u);

  gfx_map_front();
  if (dst_y0 != 0u || vis_h != GFX_EGA_SCREEN_H || full_w == 0u)
  {
    gfx_clear(g_idx_map[g_bg]);
  }

  ofs = g_pix_ofs + (unsigned long)src_y0 * (unsigned long)rb;
  chunk_rewind(ofs);

  for (y = 0u; y < vis_h; y++)
  {
    if (rb > SXG_MAX_W)
    {
      break;
    }
    row = chunk_row(rb);
    if (row == 0)
    {
      break;
    }
    ddp_hw_apply();
    if (full_w)
    {
      if (g_bpp == 8u)
      {
        plot_row_8((unsigned char)(dst_y0 + y), row + src_x0);
      }
      else
      {
        plot_row_4((unsigned char)(dst_y0 + y), row + skip_head);
      }
    }
    else
    {
      memset(g_pixrow, (char)g_idx_map[g_bg], GFX_EGA_SCREEN_W);
      if (g_bpp == 8u)
      {
        unpack_row(row + src_x0, vis_w, dst_x0);
      }
      else
      {
        unpack_row(row + skip_head, vis_w, dst_x0);
      }
      plot_row((unsigned char)(dst_y0 + y), g_pixrow);
    }
  }
}

static unsigned int crop_max_x(void)
{
  if (g_width <= GFX_EGA_SCREEN_W)
  {
    return 0u;
  }
  return (unsigned int)(g_width - GFX_EGA_SCREEN_W);
}

static unsigned int crop_max_y(void)
{
  if (g_height <= GFX_EGA_SCREEN_H)
  {
    return 0u;
  }
  return (unsigned int)(g_height - GFX_EGA_SCREEN_H);
}

static void crop_align_x(void)
{
  if (g_bpp != 8u)
  {
    g_src_x = (unsigned int)(g_src_x & ~1u);
  }
}

static void crop_center(void)
{
  g_src_x = (unsigned int)(crop_max_x() / 2u);
  g_src_y = (unsigned int)(crop_max_y() / 2u);
  crop_align_x();
}

/* Half-screen step, or remaining distance to the edge. Returns 1 if the crop moved. */
static unsigned char crop_step(unsigned char dir)
{
  unsigned int maxv;
  unsigned int step;
  unsigned int remain;

  if (dir == KEY_LEFT || dir == KEY_RIGHT)
  {
    maxv = crop_max_x();
    step = GFX_EGA_SCREEN_W / 2u;
    if (dir == KEY_LEFT)
    {
      if (g_src_x == 0u)
      {
        return 0u;
      }
      if (step > g_src_x)
      {
        step = g_src_x;
      }
      g_src_x = (unsigned int)(g_src_x - step);
    }
    else
    {
      if (g_src_x >= maxv)
      {
        return 0u;
      }
      remain = (unsigned int)(maxv - g_src_x);
      if (step > remain)
      {
        step = remain;
      }
      g_src_x = (unsigned int)(g_src_x + step);
    }
    crop_align_x();
    return 1u;
  }

  maxv = crop_max_y();
  step = GFX_EGA_SCREEN_H / 2u;
  if (dir == KEY_UP)
  {
    if (g_src_y == 0u)
    {
      return 0u;
    }
    if (step > g_src_y)
    {
      step = g_src_y;
    }
    g_src_y = (unsigned int)(g_src_y - step);
    return 1u;
  }
  if (g_src_y >= maxv)
  {
    return 0u;
  }
  remain = (unsigned int)(maxv - g_src_y);
  if (step > remain)
  {
    step = remain;
  }
  g_src_y = (unsigned int)(g_src_y + step);
  return 1u;
}

static void drain_keys(void)
{
  unsigned int n;

  for (n = 0u; n < 64u; n++)
  {
    if ((unsigned char)OS_GETKEY() == 0u)
    {
      break;
    }
  }
}

static unsigned char wait_command(void)
{
  unsigned char k;

  for (;;)
  {
    ddp_hw_apply();
    YIELD();
    k = (unsigned char)OS_GETKEY();
    if (k == 0u)
    {
      g_key_held = 0u;
      continue;
    }
    if (k == 'P' || k == 'p' || k == 'N' || k == 'n')
    {
      /* Ignore auto-repeat of the same make; next real press after a 0. */
      if (g_key_held)
      {
        continue;
      }
      g_key_held = 1u;
      if (k == 'P' || k == 'p')
      {
        g_use_ddp = (unsigned char)(g_use_ddp ? 0u : 1u);
        build_file_palette(g_pal_bytes);
        build_pair_tab();
        apply_palette();
        draw_image();
      }
      else
      {
        g_nibble_swap = (unsigned char)(g_nibble_swap ? 0u : 1u);
        build_pair_tab();
        draw_image();
      }
      continue;
    }
    if (k == KEY_LEFT || k == KEY_RIGHT || k == KEY_UP || k == KEY_DOWN)
    {
      if (crop_step(k))
      {
        draw_image();
      }
      continue;
    }
    return k;
  }
}

C_task main(int argc, char *argv[])
{
  unsigned char hdr[SXG_HDR_SIZE];
  unsigned int pal_sz;
  unsigned int pal_ofs;
  unsigned char mach;

  g_opened = 0u;
  g_bg = 0u;
  g_use_ddp = 1u; /* file DDp (PWM 4096); P = 64-color, PWM off */
  g_ddp_port = 0u;
  g_key_held = 0u;
  g_nibble_swap = 0u;
  g_src_x = 0u;
  g_src_y = 0u;

  OS_SETGFX(GFX_MODE_TEXT_KEEP);
  OS_CLS(0);
  OS_HIDEFROMPARENT();
  OS_SETCOLOR(7u);
  mach = (unsigned char)OS_GETCONFIG();
  if (mach == 1u || mach == 3u)
  {
    g_ddp_port = 1u;
  }

  if (argc < 2)
  {
    fail("sxgview <file.sxg>");
  }

  g_fp = OS_OPENHANDLE((unsigned char *)argv[1], 0x80);
  if (((int)g_fp) & 0xff)
  {
    fail("Open error");
  }
  g_opened = 1u;

  if (read_exact(hdr, SXG_HDR_SIZE) < SXG_HDR_SIZE)
  {
    fail("Short header");
  }
  if (hdr[0] != SXG_MAGIC0 || hdr[1] != SXG_MAGIC1
      || hdr[2] != SXG_MAGIC2 || hdr[3] != SXG_MAGIC3)
  {
    fail("Not SXG");
  }

  g_bg = hdr[5];
  if (hdr[6] != 0u)
  {
    fail("Packed SXG");
  }
  if (hdr[7] == 1u)
  {
    g_bpp = 4u;
  }
  else if (hdr[7] == 2u)
  {
    g_bpp = 8u;
  }
  else
  {
    fail("Format not 16/256");
  }

  g_width = (unsigned int)hdr[8] | ((unsigned int)hdr[9] << 8);
  g_height = (unsigned int)hdr[10] | ((unsigned int)hdr[11] << 8);
  if (g_width == 0u || g_height == 0u
      || g_width > SXG_MAX_W || g_height > SXG_MAX_H)
  {
    fail("Bad size");
  }

  pal_ofs = 0x0Eu
            + ((unsigned int)hdr[12] | ((unsigned int)hdr[13] << 8));
  g_pix_ofs = 0x10u
              + ((unsigned long)hdr[14] | ((unsigned long)hdr[15] << 8));
  if (g_pix_ofs <= (unsigned long)pal_ofs)
  {
    fail("Bad offsets");
  }
  pal_sz = (unsigned int)(g_pix_ofs - (unsigned long)pal_ofs);
  if ((pal_sz & 1u) != 0u || pal_sz > 512u)
  {
    fail("Bad palette");
  }
  g_ncolors = pal_sz / 2u;
  if (g_ncolors == 0u)
  {
    fail("Empty palette");
  }

  OS_SEEKHANDLE(g_fp, (unsigned long)pal_ofs);
  if (read_exact(g_pal_bytes, pal_sz) < pal_sz)
  {
    fail("Short palette");
  }

  build_file_palette(g_pal_bytes);
  build_pair_tab();
  crop_center();

  /* Eat nv Enter before the picture. Do not drain after draw: that ate the first P. */
  drain_keys();

  gfx_enter_ega();
  gfx_map_front();
  apply_palette();
  draw_image();

  wait_command();

  if (g_opened)
  {
    OS_CLOSEHANDLE(g_fp);
    g_opened = 0u;
  }
  gfx_shutdown();
  g_use_ddp = 1u;
  ddp_hw_apply();
  return 0;
}
