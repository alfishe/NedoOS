#include "gfx.h"
#include <graphic.h>
#include <oscalls.h>
#include <intrz80.h>

static unsigned char g_scr0_low;
static unsigned char g_scr0_high;
static unsigned char g_scr1_low;
static unsigned char g_scr1_high;
static unsigned char g_front;

extern unsigned char gfx_pal_buf[32];
extern unsigned char g_row[];

void gfx_pal_load_zx(void);
void gfx_pal_load_standard(void);
void gfx_pal_load_black(void);
void gfx_pal_apply(void);

static void gfx_map_pages(unsigned char low_pg, unsigned char high_pg)
{
  OS_SETPG8000(low_pg);
  SETPG32KHIGH(high_pg);
}

static unsigned char gfx_back_index(void)
{
  return (unsigned char)(1u - g_front);
}

static void gfx_load_screen_pages(void)
{
  unsigned int s0;
  unsigned int s1;

  s0 = OS_GETSCR0();
  s1 = OS_GETSCR1();
  g_scr0_low = (unsigned char)(s0 & 0xFFu);
  g_scr0_high = (unsigned char)((s0 >> 8) & 0xFFu);
  g_scr1_low = (unsigned char)(s1 & 0xFFu);
  g_scr1_high = (unsigned char)((s1 >> 8) & 0xFFu);
}

static void gfx_push_palette(void)
{
  unsigned char n;

  gfx_pal_apply();
  for (n = 0u; n < 3u; n++)
  {
    OS_HALT();
  }
}

void gfx_set_palette(void)
{
  gfx_pal_load_zx();
  gfx_push_palette();
}

void gfx_set_palette_standard(void)
{
  gfx_pal_load_standard();
  gfx_push_palette();
}

void gfx_set_palette_black(void)
{
  gfx_pal_load_black();
  gfx_push_palette();
}

void gfx_set_palette_bytes(const unsigned char *pal32)
{
  unsigned char i;

  if (pal32 == 0)
  {
    return;
  }
  for (i = 0u; i < GFX_PALETTE_OS_BYTES; i++)
  {
    gfx_pal_buf[i] = pal32[i];
  }
  gfx_push_palette();
}

void gfx_draw_palette_test(unsigned char x, unsigned char y)
{
  unsigned char i;

  for (i = 0u; i < 16u; i++)
  {
    gfx_fill_rect((unsigned char)(x + i * 10u), y, 8u, 8u, i);
  }
}

void gfx_enter_ega(void)
{
  gfx_init_tables();
  OS_SETGFX((unsigned char)GFX_MODE_EGA_KEEP);
  gfx_load_screen_pages();
  g_front = 0u;
  OS_SETSCREEN(0u);
  OS_HALT();
  gfx_map_front();
  gfx_set_palette_black();
  OS_CLS(0);
}

void gfx_init(void)
{
  OS_HIDEFROMPARENT();
  gfx_enter_ega();
}

void gfx_shutdown(void)
{
  OS_SETGFX(0x86u);
}

void gfx_clear(unsigned char color)
{
  gfx_map_front();
  OS_CLS((unsigned char)(color & 15u));
}

void gfx_clear_screen(unsigned char color)
{
  OS_CLS((unsigned char)(color & 15u));
}

void gfx_prepare_back(void)
{
  /* Map back for drawing; do not OS_SETSCREEN until gfx_flip(). */
  gfx_map_back();
  gfx_fill_vram(0u);
}

void gfx_leave_ega(void)
{
  OS_SETGFX(GFX_MODE_TEXT_KEEP);
  OS_CLS(0);
  OS_SETCOLOR(7u);
}

void gfx_show_text(void)
{
  gfx_leave_ega();
}

void gfx_map_back(void)
{
  if (gfx_back_index() == 0u)
  {
    gfx_map_pages(g_scr0_low, g_scr0_high);
  }
  else
  {
    gfx_map_pages(g_scr1_low, g_scr1_high);
  }
}

void gfx_map_front(void)
{
  if (g_front == 0u)
  {
    gfx_map_pages(g_scr0_low, g_scr0_high);
  }
  else
  {
    gfx_map_pages(g_scr1_low, g_scr1_high);
  }
}

void gfx_sync_screen_pages(void)
{
  gfx_load_screen_pages();
  OS_HALT();
  gfx_map_front();
}

void gfx_flip(void)
{
  unsigned char shown;

  shown = gfx_back_index();
  g_front = shown;
  OS_SETSCREEN(shown);
  OS_HALT();
  gfx_map_back();
}

void gfx_pages_save(gfx_page_save *save)
{
  union APP_PAGES cur;

  cur.l = OS_GETMAINPAGES();
  save->pg8000 = cur.pgs.window_2;
  save->pgc000 = cur.pgs.window_3;
}

void gfx_pages_map(unsigned char page_low, unsigned char page_high)
{
  OS_SETPG8000(page_low);
  SETPG32KHIGH(page_high);
}

void gfx_pages_restore(const gfx_page_save *save)
{
  OS_SETPG8000(save->pg8000);
  SETPG32KHIGH(save->pgc000);
}

void gfx_bank_c000_save(gfx_c000_bank *save)
{
  union APP_PAGES cur;

  cur.l = OS_GETMAINPAGES();
  save->pgc000 = cur.pgs.window_3;
}

void gfx_bank_c000_map(unsigned char page)
{
  SETPG32KHIGH(page);
}

void gfx_bank_c000_restore(const gfx_c000_bank *save)
{
  SETPG32KHIGH(save->pgc000);
}

void gfx_copy_pages_to_screen(unsigned char page_low,
                              unsigned char page_high,
                              unsigned char dst_x,
                              unsigned char dst_y,
                              unsigned char row_bytes,
                              unsigned char height)
{
  gfx_page_save screen;
  unsigned char row;
  unsigned char y;
  unsigned char split;
  unsigned int off;
  unsigned char i;
  unsigned char *src;

  split = (unsigned char)(GFX_PAGE_SIZE / (unsigned int)row_bytes);

  gfx_pages_save(&screen);

  gfx_bank_c000_map(page_low);
  for (row = 0u; row < split && row < height; row++)
  {
    off = (unsigned int)row * (unsigned int)row_bytes;
    src = (unsigned char *)(GFX_BANK_WINDOW + off);
    for (i = 0u; i < row_bytes; i++)
    {
      g_row[i] = src[i];
    }
    SETPG32KHIGH(screen.pgc000);
    y = (unsigned char)(dst_y + row);
    gfx_blit_row(dst_x, y, g_row, row_bytes);
    gfx_bank_c000_map(page_low);
  }

  gfx_bank_c000_map(page_high);
  for (row = split; row < height; row++)
  {
    off = ((unsigned int)row - (unsigned int)split) * (unsigned int)row_bytes;
    src = (unsigned char *)(GFX_BANK_WINDOW + off);
    for (i = 0u; i < row_bytes; i++)
    {
      g_row[i] = src[i];
    }
    SETPG32KHIGH(screen.pgc000);
    y = (unsigned char)(dst_y + row);
    gfx_blit_row(dst_x, y, g_row, row_bytes);
    gfx_bank_c000_map(page_high);
  }

  gfx_pages_restore(&screen);
}
