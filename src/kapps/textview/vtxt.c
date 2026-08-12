#include <string.h>
#include <oscalls.h>
#include "vtxt.h"

#include "cp866toatm.inc"

static unsigned char g_ch[VTXT_CELLS];
static unsigned char g_at[VTXT_CELLS];
static unsigned char g_pg_text;
static unsigned char g_pg_attr;
static unsigned char g_ok;

extern unsigned char vtxt_pg_text;
extern unsigned char vtxt_pg_attr;
extern unsigned char *vtxt_ptr_ch;
extern unsigned char *vtxt_ptr_at;
extern unsigned char vtxt_saved_c000;

void vtxt_blit(void);
void vtxt_blit_row(unsigned char y);
void vtxt_blit_rows(unsigned char y0, unsigned char y1);

static unsigned char vtxt_atm(unsigned char ch)
{
	return g_866toatm[ch];
}

static unsigned char cur_c000(void)
{
	union APP_PAGES cur;

	cur.l = OS_GETMAINPAGES();
	return cur.pgs.window_3;
}

static void present_setup(void)
{
	vtxt_pg_text = g_pg_text;
	vtxt_pg_attr = g_pg_attr;
	vtxt_ptr_ch = g_ch;
	vtxt_ptr_at = g_at;
	vtxt_saved_c000 = cur_c000();
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

void vtxt_clear(unsigned char ch, unsigned char attr)
{
	memset(g_ch, vtxt_atm(ch), VTXT_CELLS);
	memset(g_at, attr, VTXT_CELLS);
}

void vtxt_puts_row(unsigned char y, const unsigned char *s, unsigned char attr)
{
	unsigned int off;
	unsigned char i;
	unsigned char ch;

	if (y >= VTXT_H)
		return;
	off = (unsigned int)y * VTXT_W;
	for (i = 0; i < VTXT_W; i++)
	{
		ch = s[i];
		if (ch == 0)
			ch = ' ';
		g_ch[off + i] = vtxt_atm(ch);
		g_at[off + i] = attr;
	}
}

void vtxt_puts_span(unsigned char y, unsigned char x, const unsigned char *s,
	unsigned char n, unsigned char attr)
{
	unsigned int off;
	unsigned char i;
	unsigned char ch;

	if (y >= VTXT_H || x >= VTXT_W || n == 0u)
		return;
	if ((unsigned int)x + (unsigned int)n > VTXT_W)
		n = (unsigned char)(VTXT_W - x);
	off = (unsigned int)y * VTXT_W + (unsigned int)x;
	for (i = 0; i < n; i++)
	{
		ch = s[i];
		if (ch == 0)
			ch = ' ';
		g_ch[off + i] = vtxt_atm(ch);
		g_at[off + i] = attr;
	}
}

void vtxt_present(void)
{
	if (!g_ok)
		return;
	present_setup();
	vtxt_blit();
}

void vtxt_present_row(unsigned char y)
{
	if (!g_ok || y >= VTXT_H)
		return;
	present_setup();
	vtxt_blit_row(y);
}

void vtxt_present_rows(unsigned char y0, unsigned char y1)
{
	if (!g_ok || y0 >= VTXT_H || y1 <= y0)
		return;
	if (y1 > VTXT_H)
		y1 = VTXT_H;
	present_setup();
	vtxt_blit_rows(y0, y1);
}
