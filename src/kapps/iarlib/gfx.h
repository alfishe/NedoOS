#ifndef IARLIB_GFX_H
#define IARLIB_GFX_H

/*
 * NedoOS video modes (ATM Turbo family). Do not mix with ZX Spectrum layouts.
 *
 * Reference: ATM-turbo 2+ architecture manual (kapps/nc/, section 5.4 ff.).
 * OS_SETGFX names say "EGA" for historical reasons; VRAM layout is ATM-specific.
 *
 * 6912  OS_SETGFX(3)   ZX native 256x192 + 32x24 attrs; memcpy 6912 -> 0xC000.
 *       getpic / scaview use that. This lib decodes .scr into mode 0 via gfxlib.com.
 *
 * 320x200 OS_SETGFX(0)   ATM "EGA-like" 320x200x16 (doc 5.4). iarlib implementation.
 *       No separate attr plane: one screen byte = two horizontal pixels (a pair).
 *       VRAM is four interleaved column banks (pairs 0,1,2,3 in a quartet); see
 *       xytoscraddr / next_column in gfxdraw.asm. Not linear PC EGA.
 *       Palette: 64 hardware entries (OS_SETPAL / OS_GETPAL, 32 bytes DDp), 16 visible.
 *       Pair encoding: D0-D2,D6 = left pixel; D3-D5,D7 = right (doc fig. 10).
 *
 * MC    OS_SETGFX(2)   ATM 640x200x16 hardware multicolor (doc 5.3).
 *       Same 64-entry palette; 16 colors per 8x1 attribute cell.
 *       NOT implemented yet; constants below document the target API.
 *
 * Text  OS_SETGFX(6)   80x24 BDOS console (OS_SETXY, OS_SETCOLOR, putchar/printf).
 *       Use gfx_leave_ega() / OS_SETGFX(0x86) to print without ANSI escapes.
 *
 * App must define blit scratch: unsigned char g_row[160]; (128 is enough for 256px).
 */

#define GFX_MODE_KEEP      0x80u
#define GFX_MODE_EGA       0x00u   /* OS name: ATM 320x200 x16 (doc 5.4) */
#define GFX_MODE_MC        0x02u
#define GFX_MODE_ZX6912    0x03u
#define GFX_MODE_TEXT      0x06u

#define GFX_MODE_EGA_KEEP  (GFX_MODE_EGA | GFX_MODE_KEEP)   /* 0x80 */
#define GFX_MODE_MC_KEEP   (GFX_MODE_MC | GFX_MODE_KEEP)    /* 0x82 */
#define GFX_MODE_TEXT_KEEP 0x86u                            /* text + keep pages */

#define GFX_PALETTE_ENTRIES   64u   /* hardware palette (320x200 and MC modes) */
#define GFX_PALETTE_OS_BYTES  32u   /* OS_SETPAL / OS_GETPAL buffer */
#define GFX_ONSCREEN_COLORS   16u   /* palette indices 0..15 on screen */

/* --- ATM 320x200 x16 (doc 5.4) --- */
#define GFX_EGA_SCREEN_W      320u
#define GFX_EGA_SCREEN_H      200u
#define GFX_EGA_PIXELS_PER_BYTE 2u  /* one VRAM byte = left+right pixel pair */

#define GFX_PAGE_SIZE           16384u
#define GFX_PAGE_PAIR_BYTES     (GFX_PAGE_SIZE * 2u)

/* nc-style OS page bank window (SETPG32KHIGH only; does not touch 0x8000). */
#define GFX_BANK_WINDOW         0xC000u

#define GFX_SCREEN_W      GFX_EGA_SCREEN_W
#define GFX_SCREEN_H      GFX_EGA_SCREEN_H
#define GFX_VISUAL_SQUARE_W(h_px)  ((unsigned char)(h_px))

/* --- ATM MC 640x200 (planned; see src/browser, sprexamp; doc 5.3) --- */
#define GFX_MC_SCREEN_W       640u
#define GFX_MC_SCREEN_H       200u
#define GFX_MC_ATTR_W         8u    /* attribute cell width in pixels */
#define GFX_MC_ATTR_H         1u    /* attribute cell height in pixels */
#define GFX_MC_ATTR_COLS      (GFX_MC_SCREEN_W / GFX_MC_ATTR_W)   /* 80 */
#define GFX_MC_ATTR_ROWS      (GFX_MC_SCREEN_H / GFX_MC_ATTR_H)  /* 200 */

void gfx_init_tables(void);
extern unsigned char ty_lo[200];
void gfx_set_palette(void);           /* ZX Spectrum DDp palette (browser/zxpal) */
void gfx_set_palette_standard(void);  /* kernel STANDARDPAL (games default) */
void gfx_set_palette_black(void);     /* all-black while drawing */
void gfx_set_palette_bytes(const unsigned char *pal32); /* 32-byte DDp (PWM bits in lo) */
void gfx_set_palette_bytes_atm64(const unsigned char *pal32); /* high bytes only, B=#FF */
void gfx_draw_palette_test(unsigned char x, unsigned char y); /* 16 index swatches */

void gfx_init(void);
void gfx_enter_ega(void);   /* OS_SETGFX(0): ATM 320x200 x16 */
void gfx_leave_ega(void);
void gfx_shutdown(void);
void gfx_clear(unsigned char color);
void gfx_clear_screen(unsigned char color);
void gfx_show_text(void); /* same as gfx_leave_ega() */
void gfx_map_back(void);
void gfx_map_front(void);
/* Reload scr0/scr1 from OS after SETGFX/SETSCREEN; remap 8000+C000 front. */
void gfx_sync_screen_pages(void);
void gfx_flip(void);

/* Saved 32K VRAM window (0x8000 + 0xC000 page ids from OS_GETMAINPAGES). */
typedef struct
{
  unsigned char pg8000;
  unsigned char pgc000;
} gfx_page_save;

void gfx_pages_save(gfx_page_save *save);
void gfx_pages_map(unsigned char page_low, unsigned char page_high);
void gfx_pages_restore(const gfx_page_save *save);

typedef struct
{
  unsigned char pgc000;
} gfx_c000_bank;

void gfx_bank_c000_save(gfx_c000_bank *save);
void gfx_bank_c000_map(unsigned char page);
void gfx_bank_c000_restore(const gfx_c000_bank *save);

/*
 * Blit row-major buffer from an OS page pair (C000 bank window, nc-style).
 * Row r at offset r*row_bytes in page_low (rows 0..127) then page_high (128..191).
 * Screen VRAM stays on 0x8000+0xC000 via gfx_map_front; only C000 bank flips for read.
 */
void gfx_copy_pages_to_screen(unsigned char page_low, unsigned char page_high,
                              unsigned char dst_x, unsigned char dst_y,
                              unsigned char row_bytes, unsigned char height);

/* Implemented in gfxdraw.asm. IAR Z80 calling convention (see gfxdraw.asm header).

   Registers: 1st byte -> E, 2nd byte -> C, 16-bit ptr -> DE.
   More args on stack after  push ix; ld ix,0; add ix,sp  -> (IX+4), (IX+6), ...
   Coordinates: E=x, C=y for fill/blit/putpixel; xytoscraddr uses L=x/2, E=y.
   Pair colors: E=color_l (left), C=color_r (right) in gfx_ega_pair_byte.
   Never add C wrappers that call asm without passing DE/C/stack correctly. */
void gfx_fill_vram(unsigned char color);
void gfx_vram_sync(void);
void gfx_prepare_back(void);

void gfx_fill_rect(unsigned char x, unsigned char y,
                   unsigned char w, unsigned char h,
                   unsigned char color);

/* Encode two palette indices into one ATM screen byte (doc 5.4 pair layout). */
unsigned char gfx_ega_pair_byte(unsigned char color_l, unsigned char color_r);

/* Blit count pre-encoded screen bytes along scanline y at even pixel x. */
void gfx_blit_row(unsigned char x, unsigned char y,
                  const unsigned char *bytes, unsigned char count);

/* Map OS screen bitplane page at #4000 (rst 0x18). */
void gfx_setpg4000(unsigned char page);

/* Blit g_row[] to height scanlines at (x,y); one asm entry, inlined next_column. */
void gfx_blit_grow_h(unsigned char x, unsigned char y, unsigned char height);

/* 192-line 2x2 checker (00/FF stripes, flip every 2 rows); pure asm blit test. */
void gfx_blit_checkerboard(unsigned char x, unsigned char y);

/* Write one pre-encoded screen byte at even pixel x, scanline y. */
void gfx_put_screen_byte(unsigned char x, unsigned char y, unsigned char byte_val);

/* Store pair at even x: left/right palette indices (fill encoding, not XOR plot). */
void gfx_store_pair(unsigned char x, unsigned char y,
                    unsigned char color_l, unsigned char color_r);

/* Single pixel (bascmds prpixel addr + XOR %33210210; fill uses xytoscraddr). */
void gfx_putpixel(unsigned char x, unsigned char y, unsigned char color);

#endif
