#include <string.h>
#include <oscalls.h>
#include "bank.h"
#include "vtxt.h"

/*
 * App-side codes are CP866 (same as NC / putchar sources).
 * Backbuffer stores ATM font codes via 866toatm ? same as BDOS trecode.
 */
#include "cp866toatm.inc"

/* Linear backbuffer in low RAM ? stays visible while C000 is VRAM. */
static unsigned char g_ch[VTXT_CELLS];
static unsigned char g_at[VTXT_CELLS];
static unsigned char g_pg_text; /* user_scr0_high */
static unsigned char g_pg_attr; /* user_scr0_low */
static unsigned char g_ok;

/* Filled by C, defined in vtxt_blit.asm */
extern unsigned char vtxt_pg_text;
extern unsigned char vtxt_pg_attr;
extern unsigned char *vtxt_ptr_ch;
extern unsigned char *vtxt_ptr_at;
extern unsigned char vtxt_saved_c000;

void vtxt_blit(void); /* asm */

static unsigned char vtxt_atm(unsigned char ch)
{
	return g_866toatm[ch];
}

unsigned char vtxt_init(void)
{
	unsigned int scr;

	scr = OS_GETSCR0();
	g_pg_text = (unsigned char)(scr >> 8);
	g_pg_attr = (unsigned char)(scr & 0xFFu);
	if (g_pg_text == 0u && g_pg_attr == 0u)
		return 0u;
	g_ok = 1u;
	vtxt_clear(' ', 0x07);
	return 1u;
}

void vtxt_shutdown(void)
{
	g_ok = 0u;
}

unsigned char *vtxt_chars(void)
{
	return g_ch;
}

unsigned char *vtxt_attrs(void)
{
	return g_at;
}

void vtxt_clear(unsigned char ch, unsigned char attr)
{
	memset(g_ch, vtxt_atm(ch), VTXT_CELLS);
	memset(g_at, attr, VTXT_CELLS);
}

void vtxt_putc(unsigned char x, unsigned char y,
	       unsigned char ch, unsigned char attr)
{
	unsigned int off;

	if (x >= VTXT_W || y >= VTXT_H)
		return;
	off = (unsigned int)y * VTXT_W + x;
	g_ch[off] = vtxt_atm(ch);
	g_at[off] = attr;
}

void vtxt_puts(unsigned char x, unsigned char y,
	       const char *s, unsigned char attr)
{
	unsigned char xx;

	if (s == 0 || y >= VTXT_H)
		return;
	xx = x;
	while (*s != 0 && xx < VTXT_W)
	{
		vtxt_putc(xx, y, (unsigned char)*s, attr);
		xx++;
		s++;
	}
}

void vtxt_hline(unsigned char x, unsigned char y,
		unsigned char n, unsigned char ch, unsigned char attr)
{
	unsigned char i;
	unsigned char atm;

	atm = vtxt_atm(ch);
	for (i = 0u; i < n; i++)
	{
		unsigned int off;
		unsigned char xx;

		xx = (unsigned char)(x + i);
		if (xx >= VTXT_W || y >= VTXT_H)
			continue;
		off = (unsigned int)y * VTXT_W + xx;
		g_ch[off] = atm;
		g_at[off] = attr;
	}
}

void vtxt_fill(unsigned char x, unsigned char y,
	       unsigned char w, unsigned char h,
	       unsigned char ch, unsigned char attr)
{
	unsigned char row, col;
	unsigned int off;
	unsigned char *pc, *pa;
	unsigned char atm;

	if (x >= VTXT_W || y >= VTXT_H || w == 0u || h == 0u)
		return;
	if ((unsigned int)x + w > VTXT_W)
		w = (unsigned char)(VTXT_W - x);
	if ((unsigned int)y + h > VTXT_H)
		h = (unsigned char)(VTXT_H - y);

	atm = vtxt_atm(ch);
	for (row = 0u; row < h; row++)
	{
		off = (unsigned int)(y + row) * VTXT_W + x;
		pc = &g_ch[off];
		pa = &g_at[off];
		for (col = 0u; col < w; col++)
		{
			pc[col] = atm;
			pa[col] = attr;
		}
	}
}

void vtxt_present(void)
{
	if (!g_ok)
		return;

	vtxt_pg_text = g_pg_text;
	vtxt_pg_attr = g_pg_attr;
	vtxt_ptr_ch = g_ch;
	vtxt_ptr_at = g_at;
	vtxt_saved_c000 = bank_cur_c000();
	vtxt_blit();
}
