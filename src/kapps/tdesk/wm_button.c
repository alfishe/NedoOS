#include <oscalls.h>
#include "vtxt.h"
#include "wm_button.h"

#define BR_BOTH 0xC0
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))
#define COL_BTN       MKCOLOR(BR_BOTH, PAPER_GREEN, INK_BLACK)
#define COL_BTN_FOCUS MKCOLOR(BR_BOTH, PAPER_YELLOW, INK_BLACK)
#define COL_BTN_PRESS MKCOLOR(BR_BOTH, PAPER_WHITE, INK_BLACK)

#define BTN_POOL 24
#define PRESS_TICKS 4

struct btn_data {
	unsigned char used;
	unsigned char tag;
	const char *label;
	wm_btn_fn fn;
	void *user;
};

static struct btn_data g_btns[BTN_POOL];

static struct btn_data *btn_alloc(void)
{
	unsigned char i;

	for (i = 0u; i < BTN_POOL; i++)
	{
		if (!g_btns[i].used)
		{
			g_btns[i].used = 1u;
			return &g_btns[i];
		}
	}
	return 0;
}

static void btn_destroy(void *data)
{
	struct btn_data *b;

	b = (struct btn_data *)data;
	if (b != 0)
		b->used = 0u;
}

static void btn_paint(const struct wm_ctrl_draw *d)
{
	struct btn_data *b;
	unsigned char col, tlen, tx, row, i, marks;
	const char *lab;

	b = (struct btn_data *)d->data;
	if (b == 0)
		return;

	if (d->state & WM_CS_PRESSED)
		col = COL_BTN_PRESS;
	else if ((d->state & (WM_CS_FOCUSED | WM_CS_ACTIVEWIN)) ==
		 (WM_CS_FOCUSED | WM_CS_ACTIVEWIN))
		col = COL_BTN_FOCUS;
	else
		col = COL_BTN;

	vtxt_fill(d->ax, d->ay, d->cw, d->ch, ' ', col);

	lab = b->label;
	tlen = 0u;
	if (lab != 0)
	{
		while (lab[tlen] != 0)
			tlen++;
	}

	marks = 0u;
	if ((d->state & WM_CS_PRESSED) == 0 &&
	    (d->state & WM_CS_FOCUSED) != 0 &&
	    (d->state & WM_CS_ACTIVEWIN) != 0 &&
	    d->cw >= (unsigned char)(tlen + 2u))
		marks = 1u;

	row = (unsigned char)(d->ay + (d->ch / 2u));
	if (marks)
	{
		tx = (unsigned char)(d->ax + (d->cw - (tlen + 2u)) / 2u);
		vtxt_putc(tx, row, '>', col);
		for (i = 0u; i < tlen; i++)
			vtxt_putc((unsigned char)(tx + 1u + i), row,
				  (unsigned char)lab[i], col);
		vtxt_putc((unsigned char)(tx + 1u + tlen), row, '<', col);
	}
	else if (lab != 0)
	{
		if (tlen > d->cw)
			tlen = d->cw;
		tx = (unsigned char)(d->ax + (d->cw - tlen) / 2u);
		for (i = 0u; i < tlen; i++)
			vtxt_putc((unsigned char)(tx + i), row,
				  (unsigned char)lab[i], col);
	}
}

static void btn_click(wm_ctrl_h h, wm_id win, void *data)
{
	struct btn_data *b;
	long t0;
	wm_btn_fn fn;
	unsigned char tag;
	void *user;

	b = (struct btn_data *)data;
	if (b == 0)
		return;

	fn = b->fn;
	tag = b->tag;
	user = b->user;

	wm_ctrl_set_flag(h, WM_CF_PRESSED, 1u);
	wm_ctrl_redraw();

	t0 = time();
	while ((time() - t0) < (long)PRESS_TICKS)
		YIELD();

	wm_ctrl_set_flag(h, WM_CF_PRESSED, 0u);
	wm_ctrl_redraw();

	if (fn != 0)
		fn(win, tag, user);
}

static const struct wm_ctrl_ops g_btn_ops = {
	btn_paint,
	btn_click,
	0, /* key */
	btn_destroy
};

wm_ctrl_h wm_button_add(wm_id win,
			unsigned char cx, unsigned char cy,
			unsigned char cw, unsigned char ch,
			const char *label,
			unsigned char tag,
			wm_btn_fn on_click,
			void *user)
{
	struct btn_data *b;
	wm_ctrl_h h;

	b = btn_alloc();
	if (b == 0)
		return 0u;
	b->tag = tag;
	b->label = label;
	b->fn = on_click;
	b->user = user;

	h = wm_ctrl_attach(win, cx, cy, cw, ch,
			   (unsigned char)(WM_CF_FOCUSABLE | WM_CF_HITABLE),
			   tag, &g_btn_ops, b);
	if (h == 0u)
		b->used = 0u;
	return h;
}
