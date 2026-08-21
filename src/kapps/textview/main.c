/*
 * textview - TEXT/HEX viewer for NedoOS (BDOS 80x25)
 * Loads whole file into OS pages at C000 window (rejects if not enough RAM).
 * Builds display-line offset cache for WRAP/CHAR; RAW scans file on the fly.
 *
 * F1 Help  F2 Enc  F3 TEXT/HEX  F4 Wrap  F7 Find  F10/ESC Exit
 *       Left/Right horiz scroll in RAW (no-wrap) mode
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>

#define BR_NORMAL 0x00
#define BR_INK    0x40
#define BR_PAPER  0x80
#define BR_BOTH   0xC0
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))

#define COL_TITLE  MKCOLOR(BR_BOTH, PAPER_BLUE, INK_WHITE)
#define COL_STATUS MKCOLOR(BR_BOTH, PAPER_CYAN, INK_BLACK)
#define COL_TEXT   MKCOLOR(BR_NORMAL, PAPER_BLACK, INK_WHITE)
#define COL_HEX    MKCOLOR(BR_INK, PAPER_BLACK, INK_YELLOW)
#define COL_PROGRESS MKCOLOR(BR_INK, PAPER_BLACK, INK_WHITE)
#define COL_HELP   MKCOLOR(BR_BOTH, PAPER_BLUE, INK_WHITE)
#define COL_DLG    MKCOLOR(BR_BOTH, PAPER_BLACK, INK_YELLOW)
#define COL_MENU   MKCOLOR(BR_BOTH, PAPER_BLUE, INK_WHITE)
#define COL_MENU_SEL MKCOLOR(BR_BOTH, PAPER_CYAN, INK_BLACK)

#define KEY_ESC   27
#define KEY_ENTER   13
#define KEY_CSENTER 253
#define KEY_EXTENTER 255
#define KEY_BS    8
#define KEY_HOME  28
#define KEY_END   30
#define KEY_UP    250
#define KEY_DOWN  249
#define KEY_PGUP  246
#define KEY_PGDN  247
#define KEY_LEFT  248
#define KEY_RIGHT 251
#define KEY_F1    0xB1
#define KEY_F2    0xB2
#define KEY_F3    0xB3
#define KEY_F4    0xB4
#define KEY_F7    0xB7
#define KEY_F10   0xB0

#define FS_OPEN 0x80u

#define ROW_TITLE  0
#define ROW_TEXT0  1
#define VIEW_ROWS  22
#define ROW_STATUS 23
#define ROW_PROGRESS 12
#define COLS       80
#define TEXT_W     78
#define HEX_BPL    16

#define PAGE_SHIFT 14
#define PAGE_SIZE  16384u
#define PAGE_MASK  0x3FFFu
#define DOC_WIN    0xC000u /* file + line-cache page window */
#define MEM_RESERVE 8u
#define MAX_FILE_PAGES 200u
#define MAX_LINE_PAGES 64u
#define LINES_PER_PAGE 4096u /* 16384/4 */

#define FIND_MAX 40
#define PAT_MAX  80

#define ENC_CP866 0
#define ENC_1251  1
#define ENC_KOI8  2
#define ENC_UTF8  3
#define ENC_COUNT 4

#define MODE_TEXT 0
#define MODE_HEX  1

#define WRAP_WORD 0 /* word wrap at spaces */
#define WRAP_CHAR 1 /* hard wrap at TEXT_W */
#define WRAP_NOLF 2 /* file lines only, horiz scroll */

static const unsigned char koi8_to_866[64] = {
	0xEE, 0xA0, 0xA1, 0xE6, 0xA4, 0xA5, 0xE4, 0xA3,
	0xE5, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE,
	0xAF, 0xEF, 0xE0, 0xE1, 0xE2, 0xE3, 0xA6, 0xA2,
	0xEC, 0xEB, 0xA7, 0xE8, 0xED, 0xE9, 0xE7, 0xEA,
	0x9E, 0x80, 0x81, 0x96, 0x84, 0x85, 0x94, 0x83,
	0x95, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E,
	0x8F, 0x9F, 0x90, 0x91, 0x92, 0x93, 0x86, 0x82,
	0x9C, 0x9B, 0x87, 0x98, 0x9D, 0x99, 0x97, 0x9A
};

static const unsigned char cp866_to_koi8[64] = {
	0xE1, 0xE2, 0xF7, 0xE7, 0xE4, 0xE5, 0xF6, 0xFA,
	0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 0xF0,
	0xF2, 0xF3, 0xF4, 0xF5, 0xE6, 0xE8, 0xE3, 0xFE,
	0xFB, 0xFD, 0xFF, 0xF9, 0xF8, 0xFC, 0xE0, 0xF1,
	0xC1, 0xC2, 0xD7, 0xC7, 0xC4, 0xC5, 0xD6, 0xDA,
	0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xD0
};

static const unsigned char cp866_to_koi8_low[16] = {
	0xD2, 0xD3, 0xD4, 0xD5, 0xC6, 0xC8, 0xC3, 0xDE,
	0xDB, 0xDD, 0xDF, 0xD9, 0xD8, 0xDC, 0xC0, 0xD1
};

static const char *enc_name[ENC_COUNT] = {
	"CP866", "Win1251", "KOI8-R", "UTF-8"
};

static unsigned long g_fsize;
static unsigned char g_path[80];
static unsigned char g_enc;
static unsigned char g_mode;
static unsigned char g_wrapmode;
static unsigned long g_view_col;   /* horiz scroll (display cols) in WRAP_NOLF */
static unsigned long g_view_ofs;   /* file offset of top line in RAW mode */
static unsigned long g_raw_bot;    /* file offset of bottom visible line (RAW) */
static unsigned long g_raw_max;    /* cached max top ofs for End */
static unsigned char g_raw_max_ok;
static unsigned long g_raw_row[VIEW_ROWS]; /* line starts on screen */
static unsigned long g_raw_end[VIEW_ROWS]; /* exclusive ends */

static unsigned char g_pg_file[MAX_FILE_PAGES];
static unsigned char g_npg_file;
static unsigned char g_pg_line[MAX_LINE_PAGES];
static unsigned char g_npg_line;
static unsigned long g_nlines;     /* TEXT display lines */
static unsigned long g_view_line;  /* first visible line index */

/* Per wrap-mode line cache (instant F4 switch after first build). */
typedef struct
{
	unsigned char valid;
	unsigned char npg;
	unsigned long nlines;
	unsigned char pg[MAX_LINE_PAGES];
} WRAP_CACHE;
static WRAP_CACHE g_wcache[2]; /* WRAP + CHAR; RAW has no line cache */
static unsigned char g_wcache_enc;
static unsigned char g_map_doc;
static unsigned char g_home_c000;

static unsigned char g_find_cp866[FIND_MAX + 1];
static unsigned char g_find_pat[PAT_MAX];
static unsigned int g_find_pat_len;
static unsigned char g_have_find;

static unsigned char g_rowbuf[COLS + 1];
static unsigned long g_lbatch[16];

/* ---- tiny helpers ---- */

static unsigned char hex_digit(unsigned char v)
{
	v &= 0x0Fu;
	return (unsigned char)(v < 10u ? ('0' + v) : ('A' + (v - 10u)));
}

static void restore_doc(void);
static void map_doc(unsigned char page);

static void paint_span(unsigned char y, unsigned char x, unsigned char *s,
	unsigned char n, unsigned char color)
{
	unsigned char i;

	if (n == 0u)
		return;
	restore_doc();
	OS_SETCOLOR(color);
	OS_SETXY(x, y);
	for (i = 0; i < n; i++)
		putchar(s[i]);
}

static void paint_row(unsigned char y, unsigned char color, unsigned char *s)
{
	unsigned char i;
	unsigned char c;

	restore_doc();
	OS_SETCOLOR(color);
	OS_SETXY(0, y);
	for (i = 0; i < COLS; i++)
	{
		c = s[i];
		if (c == 0)
			c = ' ';
		putchar(c);
	}
}

static void flush_screen(void)
{
}

static void flush_row(unsigned char y)
{
	(void)y;
}

static void fill_spaces(unsigned char *dst, unsigned char n)
{
	unsigned char i;
	for (i = 0; i < n; i++)
		dst[i] = ' ';
	dst[n] = 0;
}

static void status_msg(const char *msg)
{
	unsigned char i;
	fill_spaces(g_rowbuf, COLS);
	for (i = 0; i < COLS && msg[i]; i++)
		g_rowbuf[i] = (unsigned char)msg[i];
	paint_row(ROW_STATUS, COL_STATUS, g_rowbuf);
	flush_row(ROW_STATUS);
}

/* Progress dialog: framed window, % centered on the bar. */
static void draw_progress(unsigned char pct, const char *label)
{
	unsigned char i, j, k, filled, barw;
	unsigned char mx, my, mw;
	unsigned char tpos, tlen;
	char tbuf[5];

	if (pct > 100u)
		pct = 100u;

	mw = 42u; /* same width as wrap menu */
	mx = (unsigned char)((COLS - mw) / 2u);
	my = 10u;
	barw = (unsigned char)(mw - 4u); /* ∫ + pad + bar + pad + ∫ */
	filled = (unsigned char)((unsigned int)barw * (unsigned int)pct / 100u);

	/* top: …ÕÕ label ÕÕª */
	g_rowbuf[0] = 0xC9;
	for (j = 1; j < mw - 1u; j++)
		g_rowbuf[j] = 0xCD;
	g_rowbuf[mw - 1u] = 0xBB;
	k = 2u;
	for (j = 0; label[j] && k < (unsigned char)(mw - 2u); j++, k++)
		g_rowbuf[k] = (unsigned char)label[j];
	paint_span(my, mx, g_rowbuf, mw, COL_MENU);

	/* body: ∫ €€€€∞45%∞∞∞∞ ∫  (% overlaid on bar center) */
	g_rowbuf[0] = 0xBA;
	g_rowbuf[1] = ' ';
	for (i = 0; i < barw; i++)
		g_rowbuf[2u + i] = (unsigned char)(i < filled ? 0xDBu : 0xB0);
	g_rowbuf[mw - 2u] = ' ';
	g_rowbuf[mw - 1u] = 0xBA;

	if (pct >= 100u)
	{
		tbuf[0] = '1';
		tbuf[1] = '0';
		tbuf[2] = '0';
		tbuf[3] = '%';
		tlen = 4u;
	}
	else
	{
		tbuf[0] = (char)('0' + (pct / 10u));
		tbuf[1] = (char)('0' + (pct % 10u));
		tbuf[2] = '%';
		tlen = 3u;
	}
	tpos = (unsigned char)(2u + (barw - tlen) / 2u);
	for (i = 0; i < tlen; i++)
		g_rowbuf[tpos + i] = (unsigned char)tbuf[i];

	paint_span((unsigned char)(my + 1u), mx, g_rowbuf, mw, COL_MENU);

	/* bottom: »ÕÕº */
	g_rowbuf[0] = 0xC8;
	for (j = 1; j < mw - 1u; j++)
		g_rowbuf[j] = 0xCD;
	g_rowbuf[mw - 1u] = 0xBC;
	paint_span((unsigned char)(my + 2u), mx, g_rowbuf, mw, COL_MENU);
}

static unsigned char key_is_enter(unsigned char ch)
{
	return (unsigned char)(ch == KEY_ENTER || ch == KEY_CSENTER || ch == KEY_EXTENTER);
}

/* OS_GETKEY: L=keylang, H=keynolang; RU keys often have keylang=0. */
static unsigned char read_key(void)
{
	signed long k;
	unsigned char kl, kn;

	k = OS_GETKEY();
	if (((unsigned long)k & 0x80000000UL) != 0UL)
		return 0;
	kl = (unsigned char)k;
	kn = (unsigned char)((unsigned long)k >> 8);
	if (kl != 0)
		return kl;
	return kn;
}

static unsigned char key_is_printable(unsigned char ch)
{
	if (ch < 32u || ch == 127u)
		return 0;
	if (key_is_enter(ch) || ch == KEY_ESC || ch == KEY_F10)
		return 0;
	if (ch >= 0xB0u && ch <= 0xB7u)
		return 0;
	if (ch >= KEY_PGUP && ch <= KEY_RIGHT)
		return 0;
	if (ch == KEY_HOME || ch == KEY_END)
		return 0;
	return 1;
}

/* ---- page memory ---- */

static unsigned char count_free_pages(void)
{
	unsigned int i;
	unsigned char n;

	n = 0;
	for (i = 0; i < 256u; i++)
	{
		if (OS_GETPAGEOWNER((unsigned char)i) == 0)
			n++;
	}
	if (n > MEM_RESERVE)
		return (unsigned char)(n - MEM_RESERVE);
	return 0;
}

static void restore_doc(void)
{
	if (g_home_c000 != 0xFFu && g_map_doc != g_home_c000)
	{
		OS_SETPGC000(g_home_c000);
		g_map_doc = g_home_c000;
	}
}

static void map_doc(unsigned char page)
{
	if (g_map_doc == 0xFFu || page != g_map_doc)
	{
		OS_SETPGC000(page);
		g_map_doc = page;
	}
}

static void free_line_pages(void)
{
	unsigned char i;
	for (i = 0; i < g_npg_line; i++)
		OS_DELPAGE((char)g_pg_line[i]);
	g_npg_line = 0;
	g_nlines = 0;
}

static void wcache_free_mode(unsigned char mode)
{
	unsigned char i;

	if (mode > WRAP_CHAR || !g_wcache[mode].valid)
		return;
	for (i = 0; i < g_wcache[mode].npg; i++)
		OS_DELPAGE((char)g_wcache[mode].pg[i]);
	g_wcache[mode].valid = 0;
	g_wcache[mode].npg = 0;
	g_wcache[mode].nlines = 0;
}

static void wcache_invalidate_all(void)
{
	unsigned char m;

	for (m = 0; m <= WRAP_CHAR; m++)
		wcache_free_mode(m);
	g_wcache_enc = 0xFFu;
	g_npg_line = 0;
	g_nlines = 0;
}

static void wcache_store(unsigned char mode)
{
	if (mode > WRAP_CHAR)
		return;
	g_wcache[mode].npg = g_npg_line;
	g_wcache[mode].nlines = g_nlines;
	memcpy(g_wcache[mode].pg, g_pg_line, g_npg_line);
	g_wcache[mode].valid = 1;
	g_wcache_enc = g_enc;
}

static unsigned char line_cache_try_activate(void)
{
	WRAP_CACHE *c;

	if (g_wrapmode == WRAP_NOLF)
		return 1;
	if (g_wcache_enc != g_enc)
		return 0;
	c = &g_wcache[g_wrapmode];
	if (!c->valid)
		return 0;
	g_npg_line = c->npg;
	g_nlines = c->nlines;
	memcpy(g_pg_line, c->pg, g_npg_line);
	return 1;
}

static void free_file_pages(void)
{
	unsigned char i;
	for (i = 0; i < g_npg_file; i++)
		OS_DELPAGE((char)g_pg_file[i]);
	g_npg_file = 0;
}

static void free_all_pages(void)
{
	wcache_invalidate_all();
	free_file_pages();
	restore_doc();
}

static unsigned char alloc_pages(unsigned char *dst, unsigned char need)
{
	unsigned char i;
	unsigned int r;

	for (i = 0; i < need; i++)
	{
		r = OS_NEWPAGE();
		if (r > 255u)
		{
			while (i > 0u)
			{
				i--;
				OS_DELPAGE((char)dst[i]);
			}
			return 0;
		}
		dst[i] = (unsigned char)r;
	}
	return 1;
}

static unsigned char file_byte(unsigned long ofs)
{
	unsigned int pi;
	unsigned int off;

	if (ofs >= g_fsize)
		return 0;
	pi = (unsigned int)(ofs >> PAGE_SHIFT);
	off = (unsigned int)ofs & PAGE_MASK;
	map_doc(g_pg_file[pi]);
	return *((unsigned char *)(DOC_WIN + off));
}

/* ---- RAW mode: no line cache, scan on the fly (page-pointer walks) ---- */

/* Byte after next '\n' at/after ofs, or g_fsize. Also used as exclusive line end. */
static unsigned long raw_next_line(unsigned long ofs)
{
	unsigned int pi, off, room;
	unsigned char *p;
	unsigned char cur_pg;

	if (ofs >= g_fsize)
		return g_fsize;
	cur_pg = 0xFFu;
	while (ofs < g_fsize)
	{
		pi = (unsigned int)(ofs >> PAGE_SHIFT);
		off = (unsigned int)ofs & PAGE_MASK;
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
		}
		p = (unsigned char *)(DOC_WIN + off);
		room = PAGE_SIZE - off;
		if ((unsigned long)room > g_fsize - ofs)
			room = (unsigned int)(g_fsize - ofs);
		while (room != 0u)
		{
			if (*p++ == '\n')
				return ofs + 1UL;
			ofs++;
			room--;
		}
	}
	return g_fsize;
}

/* Start of line containing ofs. */
static unsigned long raw_line_start(unsigned long ofs)
{
	unsigned int pi, off, left;
	unsigned char *p;
	unsigned char cur_pg;
	unsigned long page_base;

	if (g_fsize == 0UL)
		return 0UL;
	if (ofs >= g_fsize)
		ofs = g_fsize - 1UL;
	cur_pg = 0xFFu;
	for (;;)
	{
		pi = (unsigned int)(ofs >> PAGE_SHIFT);
		off = (unsigned int)ofs & PAGE_MASK;
		page_base = ((unsigned long)pi << PAGE_SHIFT);
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
		}
		p = (unsigned char *)(DOC_WIN + off);
		left = off + 1u;
		while (left != 0u)
		{
			if (*p == '\n')
				return page_base + (unsigned long)(p - (unsigned char *)0xC000u) + 1UL;
			if (ofs == 0UL)
				return 0UL;
			p--;
			ofs--;
			left--;
		}
		/* ofs is now page_base - 1 */
	}
}

/* Previous line start before line-start ls. */
static unsigned long raw_prev_line(unsigned long ls)
{
	if (ls <= 1UL)
		return 0UL;
	return raw_line_start(ls - 2UL);
}

static unsigned long raw_skip_lines(unsigned long ls, unsigned char n)
{
	unsigned char i;

	for (i = 0; i < n; i++)
	{
		if (ls >= g_fsize)
			break;
		ls = raw_next_line(ls);
	}
	return ls;
}

/* Cached: max top offset so last line is still visible. */
static unsigned long raw_max_view_ofs(void)
{
	unsigned long ls;
	unsigned char i;

	if (g_raw_max_ok)
		return g_raw_max;
	if (g_fsize == 0UL)
	{
		g_raw_max = 0UL;
		g_raw_max_ok = 1;
		return 0UL;
	}
	ls = raw_line_start(g_fsize - 1UL);
	for (i = 0; i < (unsigned char)(VIEW_ROWS - 1u) && ls > 0UL; i++)
		ls = raw_prev_line(ls);
	g_raw_max = ls;
	g_raw_max_ok = 1;
	return g_raw_max;
}

static void raw_clamp_view(void)
{
	unsigned long m;

	m = raw_max_view_ofs();
	if (g_view_ofs > m)
		g_view_ofs = m;
}

static void line_set(unsigned long idx, unsigned long val)
{
	unsigned int pi;
	unsigned int off;
	unsigned char *p;

	pi = (unsigned int)(idx >> 12); /* /4096 */
	off = (unsigned int)(idx & 4095u) << 2;
	map_doc(g_pg_line[pi]);
	p = (unsigned char *)(DOC_WIN + off);
	p[0] = (unsigned char)val;
	p[1] = (unsigned char)(val >> 8);
	p[2] = (unsigned char)(val >> 16);
	p[3] = (unsigned char)(val >> 24);
}

static unsigned long line_get(unsigned long idx)
{
	unsigned int pi;
	unsigned int off;
	unsigned char *p;
	unsigned long v;

	if (idx >= g_nlines)
		return g_fsize;
	pi = (unsigned int)(idx >> 12);
	if (pi >= (unsigned int)g_npg_line)
		return g_fsize;
	off = (unsigned int)(idx & 4095u) << 2;
	map_doc(g_pg_line[pi]);
	p = (unsigned char *)(DOC_WIN + off);
	v = (unsigned long)p[0];
	v |= ((unsigned long)p[1] << 8);
	v |= ((unsigned long)p[2] << 16);
	v |= ((unsigned long)p[3] << 24);
	if (v > g_fsize)
		v = g_fsize;
	return v;
}

/* Batch-read n consecutive line starts (one map_doc per line-cache page). */
static void line_get_range(unsigned long idx0, unsigned char n, unsigned long *out)
{
	unsigned char i;
	unsigned int pi, off;
	unsigned char *p;
	unsigned long v;
	unsigned char cur_pg;

	cur_pg = 0xFFu;
	for (i = 0; i < n; i++)
	{
		if (idx0 + (unsigned long)i >= g_nlines)
			v = g_fsize;
		else
		{
			pi = (unsigned int)((idx0 + (unsigned long)i) >> 12);
			if (pi >= (unsigned int)g_npg_line)
				v = g_fsize;
			else
			{
				off = (unsigned int)((idx0 + (unsigned long)i) & 4095u) << 2;
				if ((unsigned char)pi != cur_pg)
				{
					map_doc(g_pg_line[pi]);
					cur_pg = (unsigned char)pi;
				}
				p = (unsigned char *)(DOC_WIN + off);
				v = (unsigned long)p[0];
				v |= ((unsigned long)p[1] << 8);
				v |= ((unsigned long)p[2] << 16);
				v |= ((unsigned long)p[3] << 24);
				if (v > g_fsize)
					v = g_fsize;
			}
		}
		out[i] = v;
	}
}

/* ---- encoding ---- */

static unsigned char win1251_to_866(unsigned char c)
{
	if (c < 0x80u)
		return c;
	if (c == 0xA8u)
		return 0xF0u;
	if (c == 0xB8u)
		return 0xF1u;
	if (c >= 0xC0u && c <= 0xEFu)
		return (unsigned char)(c - 0x40u);
	if (c >= 0xF0u)
		return (unsigned char)(c - 0x10u);
	return '?';
}

static unsigned char koi8_byte_to_866(unsigned char c)
{
	if (c < 0x80u)
		return c;
	if (c == 0xA3u)
		return 0xF0u;
	if (c == 0xB3u)
		return 0xF1u;
	if (c >= 0xC0u)
		return koi8_to_866[c - 0xC0u];
	return '?';
}

static unsigned char map_byte(unsigned char b)
{
	if (g_enc == ENC_CP866)
		return b;
	if (g_enc == ENC_1251)
		return win1251_to_866(b);
	if (g_enc == ENC_KOI8)
		return koi8_byte_to_866(b);
	return b;
}

static unsigned char utf8_glyph(unsigned long ofs, unsigned long *next)
{
	unsigned char b0, b1;

	b0 = file_byte(ofs);
	*next = ofs + 1UL;
	if (b0 < 0x80u)
		return b0;
	if (ofs + 1UL < g_fsize)
		b1 = file_byte(ofs + 1UL);
	else
		b1 = 0;
	if (b0 == 0xD0u)
	{
		*next = ofs + 2UL;
		if (b1 == 0x81u)
			return 0xF0u;
		if (b1 >= 0x90u && b1 <= 0xBFu)
			return (unsigned char)(b1 - 0x10u);
		return '?';
	}
	if (b0 == 0xD1u)
	{
		*next = ofs + 2UL;
		if (b1 == 0x91u)
			return 0xF1u;
		if (b1 >= 0x80u && b1 <= 0x8Fu)
			return (unsigned char)(b1 + 0x60u);
		return '?';
	}
	if ((b0 & 0xE0u) == 0xC0u)
	{
		*next = ofs + 2UL;
		return '?';
	}
	if ((b0 & 0xF0u) == 0xE0u)
	{
		*next = ofs + 3UL;
		return '?';
	}
	if ((b0 & 0xF8u) == 0xF0u)
	{
		*next = ofs + 4UL;
		return '?';
	}
	return '?';
}

static unsigned char dec_mem(unsigned long ofs, unsigned char *glyph, unsigned long *next)
{
	unsigned char b;

	if (ofs >= g_fsize)
		return 0;
	if (g_enc == ENC_UTF8)
	{
		*glyph = utf8_glyph(ofs, next);
		if (*next > g_fsize)
			*next = g_fsize;
		return 1;
	}
	b = file_byte(ofs);
	*glyph = map_byte(b);
	*next = ofs + 1UL;
	return 1;
}

/* Advance one display line from ofs; optionally fill g_rowbuf. Returns next ofs. */
static unsigned long wrap_line(unsigned long ofs, unsigned char do_paint, unsigned char *hit_eof)
{
	unsigned long pos, next, brk_pos;
	unsigned char glyph, col, brk_col;

	*hit_eof = 0;
	if (do_paint)
		fill_spaces(g_rowbuf, COLS);
	if (ofs >= g_fsize)
	{
		*hit_eof = 1;
		return ofs;
	}
	pos = ofs;
	col = 0;
	brk_pos = ofs;
	brk_col = 0;

	while (col < TEXT_W)
	{
		if (!dec_mem(pos, &glyph, &next))
		{
			*hit_eof = 1;
			break;
		}
		if (glyph == '\r')
		{
			pos = next;
			continue;
		}
		if (glyph == '\n')
		{
			pos = next;
			break;
		}
		if (glyph == '\t')
		{
			unsigned char sp = (unsigned char)(8u - (col & 7u));
			if ((unsigned int)col + sp > TEXT_W)
				break;
			if (do_paint)
			{
				while (sp--)
					g_rowbuf[col++] = ' ';
			}
			else
				col = (unsigned char)(col + sp);
			pos = next;
			brk_pos = pos;
			brk_col = col;
			continue;
		}
		if (glyph < 0x20u)
			glyph = '.';
		if (do_paint)
			g_rowbuf[col] = glyph;
		col++;
		pos = next;
		if (glyph == ' ' || glyph == '\t')
		{
			brk_pos = pos;
			brk_col = col;
		}
		if (col >= TEXT_W)
		{
			if (g_wrapmode == WRAP_WORD && brk_col > 0u && brk_col < TEXT_W && brk_pos > ofs)
			{
				if (do_paint)
				{
					unsigned char i;
					for (i = brk_col; i < TEXT_W; i++)
						g_rowbuf[i] = ' ';
				}
				pos = brk_pos;
			}
			break;
		}
	}
	if (do_paint)
		g_rowbuf[COLS] = 0;
	return pos;
}

/* ---- load file + build line cache (ONE fast pass) ---- */

static unsigned char pages_for_bytes(unsigned long nbytes)
{
	if (nbytes == 0UL)
		return 1;
	return (unsigned char)((nbytes + (unsigned long)PAGE_SIZE - 1UL) >> PAGE_SHIFT);
}

static unsigned char pages_for_lines(unsigned long nlines)
{
	if (nlines == 0UL)
		return 1;
	return (unsigned char)((nlines + (unsigned long)LINES_PER_PAGE - 1UL) / (unsigned long)LINES_PER_PAGE);
}

static unsigned char ensure_line_pages(unsigned long need_idx)
{
	unsigned char need_pg;
	unsigned int r;

	need_pg = pages_for_lines(need_idx + 1UL);
	if (need_pg > MAX_LINE_PAGES)
		return 0;
	while (g_npg_line < need_pg)
	{
		unsigned char *zp;

		if (count_free_pages() < 1u)
			return 0;
		r = OS_NEWPAGE();
		if (r > 255u)
			return 0;
		g_pg_line[g_npg_line] = (unsigned char)r;
		map_doc(g_pg_line[g_npg_line]);
		zp = (unsigned char *)DOC_WIN;
		memset(zp, 0, (unsigned int)PAGE_SIZE);
		g_npg_line++;
	}
	return 1;
}

/* Write n consecutive line offsets starting at idx0 (keeps one map per page). */
static void line_set_range(unsigned long idx0, unsigned long *vals, unsigned char n)
{
	unsigned int i, j, pi, off, nthis;
	unsigned char *p;
	unsigned long v;

	i = 0;
	while (i < (unsigned int)n)
	{
		pi = (unsigned int)((idx0 + (unsigned long)i) >> 12);
		off = (unsigned int)((idx0 + (unsigned long)i) & 4095u) << 2;
		nthis = (unsigned int)(LINES_PER_PAGE - ((idx0 + (unsigned long)i) & 4095u));
		if (nthis > (unsigned int)n - i)
			nthis = (unsigned int)n - i;
		map_doc(g_pg_line[pi]);
		p = (unsigned char *)(DOC_WIN + off);
		for (j = 0; j < nthis; j++)
		{
			v = vals[i + j];
			p[0] = (unsigned char)v;
			p[1] = (unsigned char)(v >> 8);
			p[2] = (unsigned char)(v >> 16);
			p[3] = (unsigned char)(v >> 24);
			p += 4;
		}
		i += nthis;
	}
}

/* Must be < 256: bn is unsigned char. */
#define LINE_BATCH 16

static void line_flush_batch(unsigned long batch_base, unsigned char bn, unsigned char file_pg)
{
	if (bn == 0u)
		return;
	if (!ensure_line_pages(batch_base + (unsigned long)bn - 1UL))
		return;
	line_set_range(batch_base, g_lbatch, bn);
	if (file_pg != 0xFFu)
		map_doc(g_pg_file[file_pg]);
}

static unsigned char index_push_line(unsigned long line_start, unsigned long *idx, unsigned char *bn,
									 unsigned long *batch_base, unsigned char *cur_pg)
{
	unsigned char fp;

	if (*bn == 0u)
		*batch_base = *idx;
	g_lbatch[*bn] = line_start;
	(*bn)++;
	(*idx)++;

	if (*bn >= LINE_BATCH)
	{
		fp = (unsigned char)(line_start >> PAGE_SHIFT);
		if (!ensure_line_pages(*batch_base + (unsigned long)(*bn) - 1UL))
			return 0;
		line_flush_batch(*batch_base, *bn, fp);
		*cur_pg = fp;
		*bn = 0;
	}
	return 1;
}

static unsigned char g_prog_last;

static void prog_update(unsigned char pct, const char *label)
{
	if (pct != g_prog_last)
	{
		g_prog_last = pct;
		draw_progress(pct, label);
	}
}

/*
 * Single-pass wrap cache for 1-byte encodings (CP866/1251/KOI8).
 * Walks file pages via pointer - no per-byte OS calls.
 */
static unsigned char fill_line_cache_sb(void)
{
	unsigned long ofs, idx, line_start, brk_pos;
	unsigned char col, brk_col, b, glyph;
	unsigned int pi, off, room;
	unsigned char *p;
	unsigned char bn;
	unsigned long batch_base;
	unsigned char cur_pg;

	if (g_fsize == 0UL)
	{
		g_nlines = 0;
		return 1;
	}

	ofs = 0;
	idx = 0;
	bn = 0;
	batch_base = 0;
	cur_pg = 0xFFu;
	g_prog_last = 0xFFu;

	while (ofs < g_fsize)
	{
		pi = (unsigned int)(ofs >> PAGE_SHIFT);
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
			prog_update((unsigned char)((ofs * 100UL) / g_fsize), " Indexing...");
			cur_pg = 0xFFu; /* progress bar restores screen at C000 */
		}

		line_start = ofs;
		if (!index_push_line(line_start, &idx, &bn, &batch_base, &cur_pg))
		{
			printf("Not enough RAM for wrap cache\r\n");
			free_line_pages();
			return 0;
		}

		col = 0;
		brk_col = 0;
		brk_pos = ofs;

		while (col < TEXT_W && ofs < g_fsize)
		{
			pi = (unsigned int)(ofs >> PAGE_SHIFT);
			off = (unsigned int)ofs & PAGE_MASK;
			if ((unsigned char)pi != cur_pg)
			{
				map_doc(g_pg_file[pi]);
				cur_pg = (unsigned char)pi;
				prog_update((unsigned char)((ofs * 100UL) / g_fsize), " Indexing...");
				cur_pg = 0xFFu; /* progress bar restores screen at C000 */
			}
			p = (unsigned char *)(DOC_WIN + off);
			room = PAGE_SIZE - off;
			if ((unsigned long)room > g_fsize - ofs)
				room = (unsigned int)(g_fsize - ofs);

			while (room != 0u && col < TEXT_W)
			{
				b = *p;
				p++;
				room--;
				ofs++;

				if (g_enc == ENC_CP866)
					glyph = b;
				else
					glyph = map_byte(b);
				if (glyph == '\r')
					continue;
				if (glyph == '\n')
					goto line_done;
				if (glyph == '\t')
				{
					unsigned char sp = (unsigned char)(8u - (col & 7u));
					if ((unsigned int)col + sp > TEXT_W)
					{
						ofs--;
						goto line_done;
					}
					col = (unsigned char)(col + sp);
					brk_pos = ofs;
					brk_col = col;
					continue;
				}
				if (glyph < 0x20u)
					glyph = '.';
				col++;
				if (glyph == ' ')
				{
					brk_pos = ofs;
					brk_col = col;
				}
				if (col >= TEXT_W)
				{
					if (g_wrapmode == WRAP_WORD && brk_col > 0u && brk_col < TEXT_W && brk_pos > line_start)
						ofs = brk_pos;
					goto line_done;
				}
			}
		}
	line_done:
		;
	}

	if (bn != 0u)
	{
		if (!ensure_line_pages(batch_base + (unsigned long)bn - 1UL))
		{
			printf("Not enough RAM for wrap cache\r\n");
			free_line_pages();
			return 0;
		}
		line_flush_batch(batch_base, bn, cur_pg);
	}
	g_nlines = idx;
	prog_update(100u, " Indexing...");
	return 1;
}

/* UTF-8: still one pass, but via wrap_line (rarer). */
static unsigned char fill_line_cache_utf8(void)
{
	unsigned long ofs, next, idx;
	unsigned char hit;
	unsigned char bn;
	unsigned long batch_base;

	if (g_fsize == 0UL)
	{
		g_nlines = 0;
		return 1;
	}

	ofs = 0;
	idx = 0;
	bn = 0;
	batch_base = 0;

	while (ofs < g_fsize)
	{
		if (bn == 0)
			batch_base = idx;
		g_lbatch[bn++] = ofs;
		idx++;
		if (bn >= LINE_BATCH)
		{
			if (!ensure_line_pages(batch_base + (unsigned long)bn - 1UL))
			{
				printf("Not enough RAM for wrap cache\r\n");
				free_line_pages();
				return 0;
			}
			line_flush_batch(batch_base, bn, 0xFFu);
			bn = 0;
		}
		next = wrap_line(ofs, 0, &hit);
		if (next <= ofs)
			break;
		ofs = next;
		if (hit)
			break;
	}
	if (bn != 0u)
	{
		if (!ensure_line_pages(batch_base + (unsigned long)bn - 1UL))
		{
			printf("Not enough RAM for wrap cache\r\n");
			free_line_pages();
			return 0;
		}
		line_flush_batch(batch_base, bn, 0xFFu);
	}
	g_nlines = idx;
	return 1;
}

static unsigned char fill_line_cache(void)
{
	unsigned char ok;

	if (line_cache_try_activate())
		return 1;

	if (g_wrapmode == WRAP_NOLF)
		return 1;

	wcache_free_mode(g_wrapmode);
	g_npg_line = 0;
	g_nlines = 0;

	if (g_enc == ENC_UTF8)
		ok = fill_line_cache_utf8();
	else
		ok = fill_line_cache_sb();

	if (ok && g_wrapmode != WRAP_NOLF)
		wcache_store(g_wrapmode);
	return ok;
}

static unsigned char load_file_to_pages(FILE *fp)
{
	unsigned char need, free_pg, i;
	unsigned int got;
	unsigned long left;
	unsigned char *dst;
	unsigned char pct;

	need = pages_for_bytes(g_fsize);
	if (need > MAX_FILE_PAGES)
	{
		printf("File too large (%u pages max %u)\r\n",
			   (unsigned int)need, (unsigned int)MAX_FILE_PAGES);
		return 0;
	}
	free_pg = count_free_pages();
	if (need > free_pg)
	{
		printf("Not enough memory: need %u pages, free %u (reserve %u)\r\n",
			   (unsigned int)need, (unsigned int)free_pg, (unsigned int)MEM_RESERVE);
		return 0;
	}
	if (!alloc_pages(g_pg_file, need))
	{
		printf("Alloc file pages failed\r\n");
		return 0;
	}
	g_npg_file = need;

	OS_SEEKHANDLE(fp, 0UL);
	left = g_fsize;
	g_prog_last = 0xFFu;
	for (i = 0; i < need; i++)
	{
		map_doc(g_pg_file[i]);
		dst = (unsigned char *)0xC000u;
		if (left >= (unsigned long)PAGE_SIZE)
		{
			got = OS_READHANDLE(dst, fp, PAGE_SIZE);
			if (got != PAGE_SIZE)
			{
				printf("Read error at page %u\r\n", (unsigned int)i);
				return 0;
			}
			left -= (unsigned long)PAGE_SIZE;
		}
		else
		{
			memset(dst, 0, PAGE_SIZE);
			if (left > 0UL)
			{
				got = OS_READHANDLE(dst, fp, (unsigned int)left);
				if (got != (unsigned int)left)
				{
					printf("Read error (tail)\r\n");
					return 0;
				}
				left = 0;
			}
		}
		pct = (unsigned char)(((unsigned long)(i + 1u) * 100UL) / (unsigned long)need);
		prog_update(pct, " Loading...");
	}
	prog_update(100u, " Loading...");
	return 1;
}

/* Binary search: first line whose start <= ofs < next start */
static unsigned long line_for_ofs(unsigned long ofs)
{
	unsigned long lo, hi, mid, s;

	if (g_nlines == 0UL)
		return 0;
	if (ofs >= g_fsize)
		return g_nlines > 0UL ? g_nlines - 1UL : 0UL;
	lo = 0;
	hi = g_nlines;
	while (lo + 1UL < hi)
	{
		mid = (lo + hi) >> 1;
		s = line_get(mid);
		if (s <= ofs)
			lo = mid;
		else
			hi = mid;
	}
	return lo;
}

static unsigned long view_file_ofs(void)
{
	if (g_mode == MODE_HEX)
		return g_view_line * (unsigned long)HEX_BPL;
	if (g_wrapmode == WRAP_NOLF)
		return g_view_ofs;
	if (g_view_line < g_nlines)
		return line_get(g_view_line);
	return 0UL;
}

static void view_goto_ofs(unsigned long ofs)
{
	if (g_mode == MODE_HEX)
		g_view_line = ofs / (unsigned long)HEX_BPL;
	else if (g_wrapmode == WRAP_NOLF)
	{
		g_view_ofs = raw_line_start(ofs);
		g_view_col = 0UL;
	}
	else
		g_view_line = line_for_ofs(ofs);
}

static unsigned long hex_nlines(void)
{
	if (g_fsize == 0UL)
		return 0UL;
	return (g_fsize + (unsigned long)HEX_BPL - 1UL) / (unsigned long)HEX_BPL;
}

static unsigned long view_max(void)
{
	unsigned long n;

	n = (g_mode == MODE_HEX) ? hex_nlines() : g_nlines;
	if (n <= (unsigned long)VIEW_ROWS)
		return 0UL;
	return n - (unsigned long)VIEW_ROWS;
}

/* ---- paint ---- */

static const char *wrap_name(unsigned char mode)
{
	if (mode == WRAP_CHAR)
		return "CHAR";
	if (mode == WRAP_NOLF)
		return "RAW";
	return "WRAP";
}

static void draw_title(void)
{
	unsigned char i;
	char tmp[COLS + 1];
	unsigned int n;
	unsigned long total;

	total = (g_mode == MODE_HEX) ? hex_nlines() : g_nlines;
	fill_spaces((unsigned char *)tmp, COLS);
	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
	{
		sprintf(tmp, " TEXTVIEW %-10s [%s][TEXT][%s] O%lu C%lu ",
				g_path,
				enc_name[g_enc],
				wrap_name(g_wrapmode),
				g_view_ofs,
				g_view_col + 1UL);
	}
	else
	{
		sprintf(tmp, " TEXTVIEW %-14s [%s][%s][%s] L%lu/%lu ",
				g_path,
				enc_name[g_enc],
				g_mode == MODE_HEX ? "HEX" : "TEXT",
				g_mode == MODE_HEX ? "HEX" : wrap_name(g_wrapmode),
				g_view_line + (total ? 1UL : 0UL),
				total);
	}
	n = (unsigned int)strlen(tmp);
	if (n > COLS)
		n = COLS;
	for (i = 0; i < (unsigned char)n; i++)
		g_rowbuf[i] = (unsigned char)tmp[i];
	for (; i < COLS; i++)
		g_rowbuf[i] = ' ';
	paint_row(ROW_TITLE, COL_TITLE, g_rowbuf);
}

static void update_title(void)
{
	draw_title();
	flush_row(ROW_TITLE);
}

static void draw_status(const char *msg)
{
	unsigned char i;
	const char *def;

	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
		def = " F1 Help F2 Enc menu F3 HEX F4 mode Left/Right F7 Find ESC ";
	else
		def = " F1 Help F2 Enc menu F3 HEX F4 wrap menu F7 Find PgUp/Dn ESC ";

	if (msg == 0 || msg[0] == 0)
		msg = def;
	fill_spaces(g_rowbuf, COLS);
	for (i = 0; i < COLS && msg[i]; i++)
		g_rowbuf[i] = (unsigned char)msg[i];
	paint_row(ROW_STATUS, COL_STATUS, g_rowbuf);
}

static void text_fill_row_fast(unsigned long line);

/* Skip skip display columns from ofs (within end).
 * col0 = absolute display column at ofs (for tab stops). */
static unsigned long text_skip_cols(unsigned long ofs, unsigned long end,
	unsigned long skip, unsigned int col0)
{
	unsigned int col;
	unsigned char glyph;
	unsigned long next;
	unsigned char sp;
	unsigned int pi, off, room;
	unsigned char *p;
	unsigned char cur_pg;
	unsigned char b;

	if (skip == 0UL || ofs >= end)
		return ofs;
	col = col0;

	if (g_enc == ENC_UTF8)
	{
		while (skip > 0UL && ofs < end)
		{
			if (!dec_mem(ofs, &glyph, &next))
				break;
			if (glyph == '\r')
			{
				ofs = next;
				continue;
			}
			if (glyph == '\n')
				break;
			if (glyph == '\t')
			{
				sp = (unsigned char)(8u - (col & 7u));
				while (sp != 0u && skip > 0UL)
				{
					skip--;
					col++;
					sp--;
				}
				ofs = next;
				continue;
			}
			skip--;
			col++;
			ofs = next;
		}
		return ofs;
	}

	cur_pg = 0xFFu;
	while (skip > 0UL && ofs < end)
	{
		pi = (unsigned int)(ofs >> PAGE_SHIFT);
		if (pi >= (unsigned int)g_npg_file)
			break;
		off = (unsigned int)ofs & PAGE_MASK;
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
		}
		p = (unsigned char *)(DOC_WIN + off);
		room = PAGE_SIZE - off;
		if ((unsigned long)room > end - ofs)
			room = (unsigned int)(end - ofs);
		while (room != 0u && skip > 0UL)
		{
			b = *p++;
			room--;
			ofs++;
			if (g_enc == ENC_CP866)
				glyph = b;
			else
				glyph = map_byte(b);
			if (glyph == '\r')
				continue;
			if (glyph == '\n')
				return ofs - 1UL;
			if (glyph == '\t')
			{
				sp = (unsigned char)(8u - (col & 7u));
				while (sp != 0u && skip > 0UL)
				{
					skip--;
					col++;
					sp--;
				}
				continue;
			}
			skip--;
			col++;
		}
	}
	return ofs;
}

static void hex_fill_row_fast(unsigned long base)
{
	unsigned long pos;
	unsigned char i, b;
	unsigned char ascii_at;
	unsigned int pi, off;
	unsigned char cur_pg;

	fill_spaces(g_rowbuf, COLS);
	{
		unsigned long v = base;
		unsigned char sh;
		for (sh = 0; sh < 8u; sh++)
		{
			g_rowbuf[7u - sh] = hex_digit((unsigned char)(v & 0x0FUL));
			v >>= 4;
		}
	}
	g_rowbuf[8] = ' ';
	g_rowbuf[9] = ' ';
	ascii_at = 10u + HEX_BPL * 3u + 2u;
	cur_pg = 0xFFu;
	pos = base;
	for (i = 0; i < HEX_BPL; i++)
	{
		unsigned char hx = (unsigned char)(10u + i * 3u);

		g_rowbuf[hx + 2u] = (i == 7u) ? '-' : ' ';
		if (pos >= g_fsize)
			continue;
		pi = (unsigned int)(pos >> PAGE_SHIFT);
		off = (unsigned int)pos & PAGE_MASK;
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
		}
		b = *((unsigned char *)(DOC_WIN + off));
		g_rowbuf[hx] = hex_digit((unsigned char)(b >> 4));
		g_rowbuf[hx + 1u] = hex_digit(b);
		g_rowbuf[ascii_at + i] = (b < 0x20u || b == 0x7Fu) ? '.' : b;
		pos++;
	}
}

static void text_fill_row_mem(unsigned long ofs, unsigned long end, unsigned long col_skip)
{
	unsigned char col, b, glyph;
	unsigned int pi, off, room;
	unsigned char *p;
	unsigned char cur_pg;

	fill_spaces(g_rowbuf, COLS);
	if (ofs >= g_fsize || ofs >= end)
		return;
	if (end > g_fsize)
		end = g_fsize;
	if (end <= ofs)
		return;
	if (col_skip > 0UL)
		ofs = text_skip_cols(ofs, end, col_skip, 0u);
	if (ofs >= end)
		return;
	col = 0;
	cur_pg = 0xFFu;

	if (g_enc == ENC_UTF8)
	{
		unsigned long next;
		while (ofs < end && col < TEXT_W)
		{
			if (!dec_mem(ofs, &glyph, &next))
				break;
			if (glyph == '\r')
			{
				ofs = next;
				continue;
			}
			if (glyph == '\n')
				return;
			if (glyph == '\t')
			{
				unsigned char sp = (unsigned char)(8u - (col & 7u));
				while (sp != 0u && col < TEXT_W)
				{
					g_rowbuf[col++] = ' ';
					sp--;
				}
				ofs = next;
				continue;
			}
			if (glyph < 0x20u)
				glyph = '.';
			g_rowbuf[col++] = glyph;
			ofs = next;
		}
		return;
	}

	while (ofs < end && col < TEXT_W)
	{
		pi = (unsigned int)(ofs >> PAGE_SHIFT);
		if (pi >= (unsigned int)g_npg_file)
			return;
		off = (unsigned int)ofs & PAGE_MASK;
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
		}
		p = (unsigned char *)(DOC_WIN + off);
		room = PAGE_SIZE - off;
		if ((unsigned long)room > end - ofs)
			room = (unsigned int)(end - ofs);

		while (room != 0u && col < TEXT_W)
		{
			b = *p++;
			room--;
			ofs++;
			if (g_enc == ENC_CP866)
				glyph = b;
			else
				glyph = map_byte(b);
			if (glyph == '\r')
				continue;
			if (glyph == '\n')
				return;
			if (glyph == '\t')
			{
				unsigned char sp = (unsigned char)(8u - (col & 7u));
				while (sp != 0u && col < TEXT_W)
				{
					g_rowbuf[col++] = ' ';
					sp--;
				}
				continue;
			}
			if (glyph < 0x20u)
				glyph = '.';
			g_rowbuf[col++] = glyph;
		}
	}
}

static void text_fill_row_fast(unsigned long line)
{
	unsigned long ofs, end;

	if (line >= g_nlines)
	{
		fill_spaces(g_rowbuf, COLS);
		return;
	}
	ofs = line_get(line);
	end = (line + 1UL < g_nlines) ? line_get(line + 1UL) : g_fsize;
	text_fill_row_mem(ofs, end, 0UL);
}

static void flush_view(void)
{
}

static void paint_view(void)
{
	unsigned char row;
	unsigned char color;
	unsigned long nlines, line;

	color = (g_mode == MODE_HEX) ? COL_HEX : COL_TEXT;

	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
	{
		unsigned long ofs;
		unsigned long end;

		ofs = g_view_ofs;
		for (row = 0; row < VIEW_ROWS; row++)
		{
			if (ofs >= g_fsize)
			{
				g_raw_row[row] = g_fsize;
				g_raw_end[row] = g_fsize;
				fill_spaces(g_rowbuf, COLS);
			}
			else
			{
				end = raw_next_line(ofs);
				g_raw_row[row] = ofs;
				g_raw_end[row] = end;
				g_raw_bot = ofs;
				text_fill_row_mem(ofs, end, g_view_col);
				ofs = end;
			}
			paint_row((unsigned char)(ROW_TEXT0 + row), color, g_rowbuf);
		}
		flush_view();
		return;
	}

	nlines = (g_mode == MODE_HEX) ? hex_nlines() : g_nlines;

	for (row = 0; row < VIEW_ROWS; row++)
	{
		line = g_view_line + (unsigned long)row;
		if (line >= nlines)
			fill_spaces(g_rowbuf, COLS);
		else if (g_mode == MODE_HEX)
			hex_fill_row_fast(line * (unsigned long)HEX_BPL);
		else
			text_fill_row_fast(line);
		paint_row((unsigned char)(ROW_TEXT0 + row), color, g_rowbuf);
	}
	flush_view();
}

static void paint_content(void)
{
	paint_view();
	draw_title();
	flush_row(ROW_TITLE);
}

static void scroll_down_one(void)
{
	unsigned char color;
	unsigned long nlines, line;
	unsigned long end;
	unsigned long next;

	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
	{
		unsigned char i;

		/* Only look forward from bottom row ? never scan whole file. */
		next = raw_next_line(g_raw_bot);
		if (next >= g_fsize)
			return;
		g_view_ofs = raw_next_line(g_view_ofs);
		g_raw_bot = next;
		for (i = 0; i < (unsigned char)(VIEW_ROWS - 1u); i++)
		{
			g_raw_row[i] = g_raw_row[i + 1u];
			g_raw_end[i] = g_raw_end[i + 1u];
		}
		end = raw_next_line(g_raw_bot);
		g_raw_row[VIEW_ROWS - 1u] = g_raw_bot;
		g_raw_end[VIEW_ROWS - 1u] = end;
		restore_doc();
		OS_SCROLLUP(OS_SCROLL_XY(ROW_TEXT0, 0), OS_SCROLL_WH(VIEW_ROWS, COLS));
		color = COL_TEXT;
		text_fill_row_mem(g_raw_bot, end, g_view_col);
		paint_row((unsigned char)(ROW_TEXT0 + VIEW_ROWS - 1u), color, g_rowbuf);
		flush_row((unsigned char)(ROW_TEXT0 + VIEW_ROWS - 1u));
		update_title();
		return;
	}

	if (g_view_line >= view_max())
		return;
	g_view_line++;
	restore_doc();
	OS_SCROLLUP(OS_SCROLL_XY(ROW_TEXT0, 0), OS_SCROLL_WH(VIEW_ROWS, COLS));
	color = (g_mode == MODE_HEX) ? COL_HEX : COL_TEXT;
	nlines = (g_mode == MODE_HEX) ? hex_nlines() : g_nlines;
	line = g_view_line + (unsigned long)VIEW_ROWS - 1UL;
	if (line >= nlines)
		fill_spaces(g_rowbuf, COLS);
	else if (g_mode == MODE_HEX)
		hex_fill_row_fast(line * (unsigned long)HEX_BPL);
	else
		text_fill_row_fast(line);
	paint_row((unsigned char)(ROW_TEXT0 + VIEW_ROWS - 1u), color, g_rowbuf);
	flush_row((unsigned char)(ROW_TEXT0 + VIEW_ROWS - 1u));
	update_title();
}

static void scroll_up_one(void)
{
	unsigned char color;

	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
	{
		unsigned char i;
		unsigned long end;

		if (g_view_ofs == 0UL)
			return;
		g_view_ofs = raw_prev_line(g_view_ofs);
		g_raw_bot = raw_prev_line(g_raw_bot);
		for (i = (unsigned char)(VIEW_ROWS - 1u); i > 0u; i--)
		{
			g_raw_row[i] = g_raw_row[i - 1u];
			g_raw_end[i] = g_raw_end[i - 1u];
		}
		end = raw_next_line(g_view_ofs);
		g_raw_row[0] = g_view_ofs;
		g_raw_end[0] = end;
		restore_doc();
		OS_SCROLLDOWN(OS_SCROLL_XY(ROW_TEXT0, 0), OS_SCROLL_WH(VIEW_ROWS, COLS));
		color = COL_TEXT;
		text_fill_row_mem(g_view_ofs, end, g_view_col);
		paint_row(ROW_TEXT0, color, g_rowbuf);
		flush_row(ROW_TEXT0);
		update_title();
		return;
	}

	if (g_view_line == 0UL)
		return;
	g_view_line--;
	restore_doc();
	OS_SCROLLDOWN(OS_SCROLL_XY(ROW_TEXT0, 0), OS_SCROLL_WH(VIEW_ROWS, COLS));
	color = (g_mode == MODE_HEX) ? COL_HEX : COL_TEXT;
	if (g_mode == MODE_HEX)
		hex_fill_row_fast(g_view_line * (unsigned long)HEX_BPL);
	else
		text_fill_row_fast(g_view_line);
	paint_row(ROW_TEXT0, color, g_rowbuf);
	flush_row(ROW_TEXT0);
	update_title();
}

static void page_down(void)
{
	unsigned long m;

	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
	{
		unsigned long next;

		next = raw_next_line(g_raw_bot);
		if (next >= g_fsize)
			return;
		g_view_ofs = raw_skip_lines(g_view_ofs, VIEW_ROWS);
		raw_clamp_view();
		paint_content();
		return;
	}

	m = view_max();
	if (g_view_line >= m)
		return;
	g_view_line += (unsigned long)VIEW_ROWS;
	if (g_view_line > m)
		g_view_line = m;
	paint_content();
}

static void page_up(void)
{
	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
	{
		unsigned char i;

		if (g_view_ofs == 0UL)
			return;
		for (i = 0; i < VIEW_ROWS; i++)
		{
			if (g_view_ofs == 0UL)
				break;
			g_view_ofs = raw_prev_line(g_view_ofs);
		}
		paint_content();
		return;
	}

	if (g_view_line == 0UL)
		return;
	if (g_view_line > (unsigned long)VIEW_ROWS)
		g_view_line -= (unsigned long)VIEW_ROWS;
	else
		g_view_line = 0UL;
	paint_content();
}

static void goto_home(void)
{
	g_view_line = 0UL;
	g_view_ofs = 0UL;
	g_view_col = 0UL;
	paint_content();
}

static void goto_end(void)
{
	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
		g_view_ofs = raw_max_view_ofs();
	else
		g_view_line = view_max();
	paint_content();
}

static void scroll_left(void)
{
	if (g_mode != MODE_TEXT || g_wrapmode != WRAP_NOLF)
		return;
	if (g_view_col == 0UL)
		return;
	g_view_col--;
	paint_content();
}

static void scroll_right(void)
{
	if (g_mode != MODE_TEXT || g_wrapmode != WRAP_NOLF)
		return;
	g_view_col++;
	paint_content();
}

static void rebuild_wrap(void)
{
	unsigned long keep_ofs;

	if (g_mode == MODE_HEX)
		return;
	keep_ofs = view_file_ofs();
	g_view_col = 0UL;

	if (g_wrapmode == WRAP_NOLF)
	{
		g_view_ofs = raw_line_start(keep_ofs);
		raw_clamp_view();
		paint_content();
		draw_status(0);
		flush_screen();
		return;
	}

	if (!line_cache_try_activate())
	{
		draw_progress(0, " Indexing...");
		if (!fill_line_cache())
		{
			status_msg(" Index failed");
			return;
		}
	}
	g_view_line = line_for_ofs(keep_ofs);
	if (g_view_line > view_max())
		g_view_line = view_max();
	paint_content();
	draw_status(0);
	flush_screen();
}

/* ---- find ---- */

static void build_find_pat(void)
{
	unsigned int i, o;
	unsigned char c, t, hi, n, v;

	if (g_mode == MODE_HEX)
	{
		o = 0;
		hi = 0;
		n = 0;
		for (i = 0; g_find_cp866[i] != 0 && o < PAT_MAX; i++)
		{
			c = g_find_cp866[i];
			if (c == ' ')
				continue;
			v = (unsigned char)(c - '0');
			if (v <= 9u)
				t = v;
			else
			{
				c = (unsigned char)(c | 0x20u);
				if (c >= 'a' && c <= 'f')
					t = (unsigned char)(c - 'a' + 10u);
				else
				{
					g_find_pat_len = 0;
					return;
				}
			}
			if (!n)
			{
				hi = t;
				n = 1;
			}
			else
			{
				g_find_pat[o++] = (unsigned char)((hi << 4) | t);
				n = 0;
			}
		}
		g_find_pat_len = n ? 0u : o;
		return;
	}

	o = 0;
	for (i = 0; g_find_cp866[i] != 0 && o + 3u < PAT_MAX; i++)
	{
		c = g_find_cp866[i];
		if (g_enc == ENC_CP866)
			g_find_pat[o++] = c;
		else if (g_enc == ENC_1251)
		{
			if (c < 0x80u)
				t = c;
			else if (c == 0xF0u)
				t = 0xA8u;
			else if (c == 0xF1u)
				t = 0xB8u;
			else if (c >= 0x80u && c <= 0xAFu)
				t = (unsigned char)(c + 0x40u);
			else if (c >= 0xE0u && c <= 0xEFu)
				t = (unsigned char)(c + 0x10u);
			else
				t = c;
			g_find_pat[o++] = t;
		}
		else if (g_enc == ENC_KOI8)
		{
			if (c < 0x80u)
				t = c;
			else if (c == 0xF0u)
				t = 0xA3u;
			else if (c == 0xF1u)
				t = 0xB3u;
			else if (c >= 0x80u && c <= 0xAFu)
				t = cp866_to_koi8[c - 0x80u];
			else if (c >= 0xE0u && c <= 0xEFu)
				t = cp866_to_koi8_low[c - 0xE0u];
			else
				t = c;
			g_find_pat[o++] = t;
		}
		else
		{
			if (c < 0x80u)
				g_find_pat[o++] = c;
			else if (c == 0xF0u)
			{
				g_find_pat[o++] = 0xD0u;
				g_find_pat[o++] = 0x81u;
			}
			else if (c == 0xF1u)
			{
				g_find_pat[o++] = 0xD1u;
				g_find_pat[o++] = 0x91u;
			}
			else if (c >= 0x80u && c <= 0xAFu)
			{
				g_find_pat[o++] = 0xD0u;
				g_find_pat[o++] = (unsigned char)(c + 0x10u);
			}
			else if (c >= 0xE0u && c <= 0xEFu)
			{
				g_find_pat[o++] = 0xD1u;
				g_find_pat[o++] = (unsigned char)(c - 0x60u);
			}
			else
				g_find_pat[o++] = '?';
		}
	}
	g_find_pat_len = o;
}

/* Scan [start..end] for pattern; direct page pointers, first-byte filter. */
static unsigned long find_scan(unsigned long start, unsigned long end)
{
	unsigned long pos, limit;
	unsigned int plen, pi, off, room, i;
	unsigned char *p, first, cur_pg, ok;

	plen = g_find_pat_len;
	if (plen == 0u || g_fsize < (unsigned long)plen)
		return 0xFFFFFFFFUL;
	limit = g_fsize - (unsigned long)plen;
	if (start > limit)
		return 0xFFFFFFFFUL;
	if (end > limit)
		end = limit;

	first = g_find_pat[0];
	cur_pg = 0xFFu;
	pos = start;

	while (pos <= end)
	{
		pi = (unsigned int)(pos >> PAGE_SHIFT);
		off = (unsigned int)pos & PAGE_MASK;
		if ((unsigned char)pi != cur_pg)
		{
			map_doc(g_pg_file[pi]);
			cur_pg = (unsigned char)pi;
			YIELD();
		}
		p = (unsigned char *)(DOC_WIN + off);
		room = PAGE_SIZE - off;
		if ((unsigned long)room > end - pos + 1UL)
			room = (unsigned int)(end - pos + 1UL);

		while (room != 0u)
		{
			if (*p == first)
			{
				ok = 1;
				for (i = 1; i < plen; i++)
				{
					unsigned long q;
					unsigned int pi2, off2;

					q = pos + (unsigned long)i;
					pi2 = (unsigned int)(q >> PAGE_SHIFT);
					off2 = (unsigned int)q & PAGE_MASK;
					if ((unsigned char)pi2 != cur_pg)
					{
						map_doc(g_pg_file[pi2]);
						cur_pg = (unsigned char)pi2;
					}
					if (*((unsigned char *)(DOC_WIN + off2)) != g_find_pat[i])
					{
						ok = 0;
						break;
					}
				}
				if (ok)
					return pos;
			}
			p++;
			room--;
			pos++;
		}
	}
	return 0xFFFFFFFFUL;
}

static void prompt_find(void)
{
	unsigned char buf[FIND_MAX + 2];
	unsigned char i, ch, len, v;

	len = 0;
	buf[0] = 0;
	if (g_have_find)
	{
		for (i = 0; g_find_cp866[i] != 0 && i < FIND_MAX; i++)
		{
			buf[i] = g_find_cp866[i];
			len++;
		}
		buf[len] = 0;
	}

	/* Drop F7 release / repeat still in queue. */
	while ((ch = read_key()) == KEY_F7)
		YIELD();

	for (;;)
	{
		fill_spaces(g_rowbuf, COLS);
		g_rowbuf[0] = ' ';
		if (g_mode == MODE_HEX)
		{
			g_rowbuf[1] = 'H';
			g_rowbuf[2] = 'e';
			g_rowbuf[3] = 'x';
			g_rowbuf[4] = ':';
			g_rowbuf[5] = ' ';
			for (i = 0; i < len; i++)
				g_rowbuf[6u + i] = buf[i];
			g_rowbuf[6u + len] = '_';
		}
		else
		{
			g_rowbuf[1] = 'F';
			g_rowbuf[2] = 'i';
			g_rowbuf[3] = 'n';
			g_rowbuf[4] = 'd';
			g_rowbuf[5] = ':';
			g_rowbuf[6] = ' ';
			for (i = 0; i < len; i++)
				g_rowbuf[7u + i] = buf[i];
			g_rowbuf[7u + len] = '_';
		}
		paint_row(ROW_STATUS, COL_DLG, g_rowbuf);
		flush_row(ROW_STATUS);

		ch = read_key();
		if (ch == 0)
		{
			YIELD();
			continue;
		}
		if (ch == KEY_ESC)
		{
			draw_status(0);
			flush_row(ROW_STATUS);
			return;
		}
		if (key_is_enter(ch))
			break;
		if (ch == KEY_BS || ch == 127u)
		{
			if (len > 0u)
			{
				len--;
				buf[len] = 0;
			}
			continue;
		}
		if (len < FIND_MAX)
		{
			if (g_mode == MODE_HEX)
			{
				if (ch == ' ')
				{
					buf[len++] = ch;
					buf[len] = 0;
				}
				else
				{
					v = (unsigned char)(ch - '0');
					if (v <= 9u || ((ch | 0x20u) >= 'a' && (ch | 0x20u) <= 'f'))
					{
						buf[len++] = ch;
						buf[len] = 0;
					}
				}
			}
			else if (key_is_printable(ch))
			{
				buf[len++] = ch;
				buf[len] = 0;
			}
		}
	}
	if (len == 0u)
	{
		draw_status(0);
		flush_row(ROW_STATUS);
		return;
	}
	for (i = 0; i <= len; i++)
		g_find_cp866[i] = buf[i];
	g_have_find = 1;
	build_find_pat();
}

static void do_find(unsigned char from_prompt)
{
	unsigned long start, found;

	if (from_prompt)
		prompt_find();
	if (!g_have_find)
	{
		draw_status(0);
		flush_screen();
		return;
	}
	build_find_pat();
	if (g_find_pat_len == 0u)
	{
		status_msg(g_mode == MODE_HEX ? " Bad hex." : " Empty.");
		return;
	}

	status_msg(" Searching...");

	if (g_mode == MODE_HEX)
		start = g_view_line * (unsigned long)HEX_BPL;
	else if (g_wrapmode == WRAP_NOLF)
		start = g_view_ofs;
	else if (g_view_line < g_nlines)
		start = line_get(g_view_line);
	else
		start = 0;

	found = find_scan(start, g_fsize - (unsigned long)g_find_pat_len);
	if (found == 0xFFFFFFFFUL && start > 0UL)
		found = find_scan(0UL, start - 1UL);
	if (found == 0xFFFFFFFFUL)
	{
		status_msg(" Not found.");
		return;
	}
	if (g_mode == MODE_HEX)
		g_view_line = found / (unsigned long)HEX_BPL;
	else if (g_wrapmode == WRAP_NOLF)
	{
		g_view_ofs = raw_line_start(found);
		g_view_col = 0UL;
		raw_clamp_view();
	}
	else
		g_view_line = line_for_ofs(found);
	if (g_mode != MODE_TEXT || g_wrapmode != WRAP_NOLF)
	{
		if (g_view_line > view_max())
			g_view_line = view_max();
	}
	paint_content();
	status_msg(" Found.");
}

/* ---- UI ---- */

static void show_help(void)
{
	static const char *lines[] = {
		" TEXTVIEW - loads file into RAM",
		"",
		" F1  help   F2 enc menu   F3 TEXT/HEX",
		" F4  wrap menu   F7 find   ESC exit",
		"",
		" Up/Dn line   PgUp/PgDn page   Home/End",
		" RAW mode: no index, Left/Right horiz scroll",
		"",
		" WRAP/CHAR build line cache after load/switch.",
		" File must fit in free pages (minus 8 reserve).",
		"",
		" Press any key..."
	};
	unsigned char i, n, j;

	n = (unsigned char)(sizeof(lines) / sizeof(lines[0]));
	restore_doc();
	OS_CLS(COL_HELP);
	for (i = 0; i < n && i < 22u; i++)
	{
		fill_spaces(g_rowbuf, COLS);
		for (j = 0; j < COLS && lines[i][j]; j++)
			g_rowbuf[j] = (unsigned char)lines[i][j];
		paint_row((unsigned char)(1u + i), COL_HELP, g_rowbuf);
	}
	flush_screen();
	{
		unsigned char k;
		do
		{
			k = (unsigned char)OS_GETKEY();
			YIELD();
		} while (k == 0);
	}
	paint_content();
	draw_status(0);
	flush_screen();
}

/* Draw one menu item row; sel != 0xFF highlights that row. */
static void menu_paint_item(unsigned char y, unsigned char mx, unsigned char mw,
	const char *text, unsigned char sel_on)
{
	unsigned char j;

	g_rowbuf[0] = 0xBA;
	for (j = 1; j < mw - 1u; j++)
		g_rowbuf[j] = ' ';
	g_rowbuf[mw - 1u] = 0xBA;
	for (j = 0; text[j] && (unsigned char)(2u + j) < (unsigned char)(mw - 1u); j++)
		g_rowbuf[2u + j] = (unsigned char)text[j];
	paint_span(y, mx, g_rowbuf, mw, COL_MENU);
	if (sel_on)
		paint_span(y, (unsigned char)(mx + 2u), &g_rowbuf[2],
			(unsigned char)(mw - 4u), COL_MENU_SEL);
}

static void menu_paint_frame(unsigned char my, unsigned char mx, unsigned char mw,
	const char *title, const char *const *items, unsigned char nitems,
	unsigned char sel)
{
	unsigned char i, j, k;

	g_rowbuf[0] = 0xC9;
	for (j = 1; j < mw - 1u; j++)
		g_rowbuf[j] = 0xCD;
	g_rowbuf[mw - 1u] = 0xBB;
	k = 2u;
	for (j = 0; title[j] && k < (unsigned char)(mw - 2u); j++, k++)
		g_rowbuf[k] = (unsigned char)title[j];
	paint_span(my, mx, g_rowbuf, mw, COL_MENU);

	for (i = 0; i < nitems; i++)
		menu_paint_item((unsigned char)(my + 1u + i), mx, mw, items[i],
			(unsigned char)(i == sel));

	g_rowbuf[0] = 0xC8;
	for (j = 1; j < mw - 1u; j++)
		g_rowbuf[j] = 0xCD;
	g_rowbuf[mw - 1u] = 0xBC;
	paint_span((unsigned char)(my + 1u + nitems), mx, g_rowbuf, mw, COL_MENU);
}

/* List menu dialog. Returns index, or 0xFF if Esc. */
static unsigned char show_list_menu(const char *title, const char *const *items,
	unsigned char nitems, unsigned char cur)
{
	unsigned char sel, ch, mx, my, mw;
	unsigned char old;

	mw = 42u;
	mx = (unsigned char)((COLS - mw) / 2u);
	my = 8u;
	sel = cur;
	if (sel >= nitems)
		sel = 0;

	paint_content();
	draw_status(0);
	flush_screen();
	menu_paint_frame(my, mx, mw, title, items, nitems, sel);

	for (;;)
	{
		ch = read_key();
		if (ch == 0)
		{
			YIELD();
			continue;
		}
		if (ch == KEY_ESC)
		{
			paint_content();
			draw_status(0);
			flush_screen();
			return 0xFFu;
		}
		if (key_is_enter(ch))
			return sel;
		if (ch == KEY_UP)
		{
			if (sel > 0u)
			{
				old = sel;
				sel--;
				menu_paint_item((unsigned char)(my + 1u + old), mx, mw,
					items[old], 0);
				menu_paint_item((unsigned char)(my + 1u + sel), mx, mw,
					items[sel], 1);
			}
			continue;
		}
		if (ch == KEY_DOWN)
		{
			if (sel + 1u < nitems)
			{
				old = sel;
				sel++;
				menu_paint_item((unsigned char)(my + 1u + old), mx, mw,
					items[old], 0);
				menu_paint_item((unsigned char)(my + 1u + sel), mx, mw,
					items[sel], 1);
			}
			continue;
		}
		if (ch >= '1' && (unsigned char)(ch - '1') < nitems)
		{
			old = sel;
			sel = (unsigned char)(ch - '1');
			if (old != sel)
			{
				menu_paint_item((unsigned char)(my + 1u + old), mx, mw,
					items[old], 0);
				menu_paint_item((unsigned char)(my + 1u + sel), mx, mw,
					items[sel], 1);
			}
		}
	}
}

static void show_wrap_menu(void)
{
	static const char *items[3] = {
		"1  WRAP  word wrap at spaces",
		"2  CHAR  hard wrap at 78 cols",
		"3  RAW   lines, Left/Right scroll"
	};
	unsigned char sel;

	if (g_mode == MODE_HEX)
	{
		status_msg(" Wrap menu: TEXT mode only.");
		return;
	}

	sel = show_list_menu(" Wrap mode ", items, 3u, g_wrapmode);
	if (sel == 0xFFu)
		return;
	if (sel != g_wrapmode)
	{
		g_wrapmode = sel;
		g_view_col = 0UL;
		rebuild_wrap();
	}
	else
	{
		paint_content();
		draw_status(0);
		flush_screen();
	}
}

static void show_enc_menu(void)
{
	static const char *items[4] = {
		"1  CP866",
		"2  Win1251",
		"3  KOI8-R",
		"4  UTF-8"
	};
	unsigned char sel;

	sel = show_list_menu(" Encoding ", items, ENC_COUNT, g_enc);
	if (sel == 0xFFu)
		return;
	if (sel != g_enc)
	{
		g_enc = sel;
		if (g_have_find)
			build_find_pat();
		wcache_invalidate_all();
		if (g_mode == MODE_TEXT)
			rebuild_wrap();
		else
		{
			paint_content();
			draw_status(0);
			flush_screen();
		}
	}
	else
	{
		paint_content();
		draw_status(0);
		flush_screen();
	}
}

static void toggle_mode(void)
{
	unsigned long ofs;

	if (g_mode == MODE_TEXT)
	{
		ofs = view_file_ofs();
		g_mode = MODE_HEX;
		g_view_line = ofs / (unsigned long)HEX_BPL;
	}
	else
	{
		ofs = g_view_line * (unsigned long)HEX_BPL;
		g_mode = MODE_TEXT;
		view_goto_ofs(ofs);
	}
	if (g_mode == MODE_TEXT && g_wrapmode == WRAP_NOLF)
		raw_clamp_view();
	else if (g_view_line > view_max())
		g_view_line = view_max();
	paint_content();
	draw_status(0);
	flush_screen();
}

static void usage(void)
{
	printf("Usage: textview <file>\r\n");
	printf("  Loads file into RAM; needs free pages (reserve 8).\r\n");
}

C_task main(int argc, char *argv[])
{
	FILE *fp;
	unsigned char key;
	unsigned int i;
	union APP_PAGES main_pg;

	os_initstdio();
	g_npg_file = 0;
	g_npg_line = 0;
	g_map_doc = 0xFFu;
	g_home_c000 = 0xFFu;
	g_wcache_enc = 0xFFu;

	if (argc < 2 || argv[1] == 0 || argv[1][0] == 0)
	{
		usage();
		return 0;
	}
	for (i = 0; i < sizeof(g_path) - 1u && argv[1][i]; i++)
		g_path[i] = (unsigned char)argv[1][i];
	g_path[i] = 0;

	fp = OS_OPENHANDLE(g_path, FS_OPEN);
	if (((int)fp) & 0xff)
	{
		printf("Cannot open: %s\r\n", g_path);
		return 1;
	}

	g_fsize = OS_GETFILESIZE(fp);
	main_pg.l = OS_GETMAINPAGES();
	g_home_c000 = main_pg.pgs.window_3;
	g_map_doc = g_home_c000;

	OS_SETGFX(0x86);
	restore_doc();
	OS_CLS(COL_TEXT);
	draw_progress(0, " Loading...");

	if (!load_file_to_pages(fp))
	{
		OS_CLOSEHANDLE(fp);
		free_all_pages();
		return 1;
	}
	OS_CLOSEHANDLE(fp);

	g_enc = ENC_CP866;
	g_mode = MODE_TEXT;
	g_wrapmode = WRAP_NOLF;
	g_view_line = 0UL;
	g_view_ofs = 0UL;
	g_raw_bot = 0UL;
	g_raw_max_ok = 0;
	g_view_col = 0UL;
	g_have_find = 0;
	g_find_cp866[0] = 0;

	if (g_wrapmode != WRAP_NOLF)
	{
		draw_progress(0, " Indexing...");
		if (!fill_line_cache())
		{
			free_all_pages();
			return 1;
		}
	}

	paint_content();
	draw_status(0);
	flush_screen();

	for (;;)
	{
		key = (unsigned char)OS_GETKEY();
		if (key == 0)
		{
			YIELD();
			continue;
		}
		if (key == KEY_ESC || key == KEY_F10)
			break;
		if (key == KEY_F1)
		{
			show_help();
			continue;
		}
		if (key == KEY_F2)
		{
			show_enc_menu();
			continue;
		}
		if (key == KEY_F3)
		{
			toggle_mode();
			continue;
		}
		if (key == KEY_F4)
		{
			show_wrap_menu();
			continue;
		}
		if (key == KEY_F7)
		{
			do_find(1);
			continue;
		}
		if (key == KEY_DOWN)
		{
			scroll_down_one();
			continue;
		}
		if (key == KEY_UP)
		{
			scroll_up_one();
			continue;
		}
		if (key == KEY_PGDN)
		{
			page_down();
			draw_status(0);
			flush_row(ROW_STATUS);
			continue;
		}
		if (key == KEY_PGUP)
		{
			page_up();
			draw_status(0);
			flush_row(ROW_STATUS);
			continue;
		}
		if (key == KEY_HOME)
		{
			goto_home();
			draw_status(0);
			flush_screen();
			continue;
		}
		if (key == KEY_END)
		{
			goto_end();
			draw_status(0);
			flush_screen();
			continue;
		}
		if (key == KEY_LEFT)
		{
			scroll_left();
			continue;
		}
		if (key == KEY_RIGHT)
		{
			scroll_right();
			continue;
		}
	}

	free_all_pages();
	OS_SETGFX(0x86);
	restore_doc();
	OS_CLS(MKCOLOR(BR_NORMAL, PAPER_BLACK, INK_WHITE));
	return 0;
}
