/*
 * Soft mouse for text mode ? same model as ngsplay / term.com:
 *  - Kempston counters are 8-bit; delta = (signed char)(new - old) with wrap
 *  - Y inverted like term (old - new) so screen Y follows the mouse
 *  - Fixed-point cell position (frac bits)
 *  - Cursor = invert attr via OS_PRATTR on live VRAM (after vtxt_present)
 */
#include <oscalls.h>
#include "ui_mouse.h"

#define SCR_W 80u
#define SCR_H 25u
/* term TEXTMODE: Y factor 8, X factor 4 */
#define MX_FACT 4u
#define MY_FACT 8u
#define MX_MAX ((SCR_W - 1u) * MX_FACT)
#define MY_MAX ((SCR_H - 1u) * MY_FACT)

#define CURSOR_ATTR 0x38u
#define LMB_MASK 0x01u
#define WHEEL_MASK 0xf0u

static unsigned char raw_x;
static unsigned char raw_y;
static unsigned char raw_btns;
static unsigned char raw_wheel;
static unsigned int x_fp;
static unsigned int y_fp;
static unsigned char cell_x;
static unsigned char cell_y;
static unsigned char saved_attr;
static unsigned char cursor_on;
static unsigned char inited;
static unsigned char have_sample;
static unsigned char lmb_click;
static unsigned char lmb_down;
static signed char wheel_delta;

static signed char delta_u8(unsigned char neu, unsigned char oldv)
{
	return (signed char)(neu - oldv);
}

static void clamp_fp(void)
{
	if (x_fp > MX_MAX)
		x_fp = MX_MAX;
	if (y_fp > MY_MAX)
		y_fp = MY_MAX;
	cell_x = (unsigned char)(x_fp / MX_FACT);
	cell_y = (unsigned char)(y_fp / MY_FACT);
}

static void apply_delta(signed char dx, signed char dy)
{
	int nx;
	int ny;

	nx = (int)x_fp + (int)dx;
	if (nx < 0)
		nx = 0;
	if (nx > (int)MX_MAX)
		nx = (int)MX_MAX;
	x_fp = (unsigned int)nx;

	ny = (int)y_fp + (int)dy;
	if (ny < 0)
		ny = 0;
	if (ny > (int)MY_MAX)
		ny = (int)MY_MAX;
	y_fp = (unsigned int)ny;

	clamp_fp();
}

void ui_mouse_hide(void)
{
	if (!cursor_on)
		return;
	OS_SETXY(cell_x, cell_y);
	OS_PRATTR(saved_attr);
	cursor_on = 0;
}

void ui_mouse_show(void)
{
	if (cursor_on || !inited)
		return;
	OS_SETXY(cell_x, cell_y);
	saved_attr = OS_GETATTR();
	OS_PRATTR(CURSOR_ATTR);
	cursor_on = 1;
}

void ui_mouse_init(void)
{
	x_fp = (SCR_W / 2u) * MX_FACT;
	y_fp = (SCR_H / 2u) * MY_FACT;
	clamp_fp();
	raw_x = 0;
	raw_y = 0;
	raw_btns = 0xff;
	raw_wheel = 0;
	have_sample = 0;
	cursor_on = 0;
	inited = 1;
	lmb_click = 0;
	lmb_down = 0;
	wheel_delta = 0;
}

void ui_mouse_poll(void)
{
	unsigned char nx;
	unsigned char ny;
	unsigned char nb;
	unsigned char nw;
	signed char dx;
	signed char dy;

	lmb_click = 0;
	wheel_delta = 0;

	if (!inited)
		return;

	nx = mouse_x;
	ny = mouse_y;
	nb = mouse_btns;
	nw = (unsigned char)(nb & WHEEL_MASK);

	if (!have_sample)
	{
		raw_x = nx;
		raw_y = ny;
		raw_btns = nb;
		raw_wheel = nw;
		have_sample = 1;
		lmb_down = ((nb & LMB_MASK) == 0) ? 1u : 0u;
		ui_mouse_show();
		return;
	}

	dx = delta_u8(nx, raw_x);
	dy = delta_u8(raw_y, ny);
	raw_x = nx;
	raw_y = ny;

	if (dx != 0 || dy != 0)
	{
		ui_mouse_hide();
		apply_delta(dx, dy);
	}

	/* LMB active-low: 0 = pressed. Edge = was up, now down. */
	if (((raw_btns & LMB_MASK) != 0) && ((nb & LMB_MASK) == 0))
		lmb_click = 1;
	lmb_down = ((nb & LMB_MASK) == 0) ? 1u : 0u;
	raw_btns = nb;

	if (nw != raw_wheel)
	{
		wheel_delta = (signed char)(nw - raw_wheel);
		raw_wheel = nw;
	}

	ui_mouse_show();
}

unsigned char ui_mouse_x(void)
{
	return cell_x;
}

unsigned char ui_mouse_y(void)
{
	return cell_y;
}

unsigned char ui_mouse_lmb_click(void)
{
	return lmb_click;
}

unsigned char ui_mouse_lmb_down(void)
{
	return lmb_down;
}

signed char ui_mouse_wheel_delta(void)
{
	return wheel_delta;
}
