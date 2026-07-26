#include <oscalls.h>
#include "vtxt.h"
#include "wm_edit.h"

#define BR_BOTH 0xC0
#define BR_INK  0x40
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))
#define COL_EDIT       MKCOLOR(BR_INK, PAPER_BLACK, INK_WHITE)
#define COL_EDIT_FOCUS MKCOLOR(BR_BOTH, PAPER_BLACK, INK_YELLOW)

#define KEY_BS    8
#define KEY_LEFT  248
#define KEY_RIGHT 251
#define KEY_DEL   252

static void edit_paint(const struct wm_ctrl_draw *d)
{
	struct wm_edit *e;
	unsigned char col, i, ch, view;
	unsigned char focused;

	e = (struct wm_edit *)d->data;
	if (e == 0 || e->buf == 0)
		return;

	focused = ((d->state & (WM_CS_FOCUSED | WM_CS_ACTIVEWIN)) ==
		   (WM_CS_FOCUSED | WM_CS_ACTIVEWIN)) ? 1u : 0u;
	col = focused ? COL_EDIT_FOCUS : COL_EDIT;

	vtxt_fill(d->ax, d->ay, d->cw, 1u, ' ', col);

	view = 0u;
	if (e->cursor >= d->cw)
		view = (unsigned char)(e->cursor - d->cw + 1u);

	for (i = 0u; i < d->cw; i++)
	{
		if ((unsigned char)(view + i) < e->len)
			ch = (unsigned char)e->buf[view + i];
		else
			ch = ' ';
		vtxt_putc((unsigned char)(d->ax + i), d->ay, ch, col);
	}

	/* caret */
	if (focused && e->cursor >= view &&
	    (unsigned char)(e->cursor - view) < d->cw)
	{
		i = (unsigned char)(e->cursor - view);
		ch = (e->cursor < e->len) ? (unsigned char)e->buf[e->cursor]
					 : (unsigned char)'_';
		vtxt_putc((unsigned char)(d->ax + i), d->ay, ch,
			  MKCOLOR(BR_BOTH, PAPER_YELLOW, INK_BLACK));
	}
}

static unsigned char edit_key(wm_ctrl_h h, wm_id win, unsigned char key,
			      void *data)
{
	struct wm_edit *e;
	unsigned char i;

	h = h;
	win = win;
	e = (struct wm_edit *)data;
	if (e == 0 || e->buf == 0 || e->maxlen < 2u)
		return 0u;

	if (key == KEY_LEFT)
	{
		if (e->cursor > 0u)
			e->cursor--;
		return 1u;
	}
	if (key == KEY_RIGHT)
	{
		if (e->cursor < e->len)
			e->cursor++;
		return 1u;
	}
	if (key == KEY_BS)
	{
		if (e->cursor == 0u)
			return 1u;
		for (i = (unsigned char)(e->cursor - 1u); i < e->len; i++)
			e->buf[i] = e->buf[i + 1u];
		e->cursor--;
		e->len--;
		e->buf[e->len] = 0;
		return 1u;
	}
	if (key == KEY_DEL)
	{
		if (e->cursor >= e->len)
			return 1u;
		for (i = e->cursor; i < e->len; i++)
			e->buf[i] = e->buf[i + 1u];
		e->len--;
		e->buf[e->len] = 0;
		return 1u;
	}
	/* printable ASCII */
	if (key >= 32u && key < 127u)
	{
		if (e->len + 1u >= e->maxlen)
			return 1u;
		for (i = e->len; i > e->cursor; i--)
			e->buf[i] = e->buf[i - 1u];
		e->buf[e->cursor] = (char)key;
		e->cursor++;
		e->len++;
		e->buf[e->len] = 0;
		return 1u;
	}
	return 0u;
}

static const struct wm_ctrl_ops g_edit_ops = {
	edit_paint,
	0, /* click: focus only via attach hit + focus_handle */
	edit_key,
	0
};

wm_ctrl_h wm_edit_add(wm_id win,
		      unsigned char cx, unsigned char cy,
		      unsigned char cw,
		      struct wm_edit *edit)
{
	if (edit == 0 || edit->buf == 0 || cw == 0u)
		return 0u;
	if (edit->maxlen < 2u)
		return 0u;
	edit->buf[edit->maxlen - 1u] = 0;
	edit->len = 0u;
	while (edit->buf[edit->len] != 0 &&
	       edit->len + 1u < edit->maxlen)
		edit->len++;
	edit->cursor = edit->len;

	return wm_ctrl_attach(win, cx, cy, cw, 1u,
			      (unsigned char)(WM_CF_FOCUSABLE | WM_CF_HITABLE),
			      0u, &g_edit_ops, edit);
}
