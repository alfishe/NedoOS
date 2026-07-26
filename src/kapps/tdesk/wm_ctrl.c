#include <oscalls.h>
#include "wm_ctrl.h"

struct wm_ctrl {
	wm_id win;			/* 0 = free */
	unsigned char cx, cy, cw, ch;
	unsigned char flags;
	unsigned char tag;
	const struct wm_ctrl_ops *ops;
	void *data;
};

static struct wm_ctrl g_ctrls[WM_CTRL_MAX];
static unsigned char g_focus_slot[WM_MAX_WIN + 1];
static unsigned char g_focus_ready;
static wm_ctrl_redraw_fn g_redraw;

void wm_ctrl_set_redraw(wm_ctrl_redraw_fn fn)
{
	g_redraw = fn;
}

void wm_ctrl_redraw(void)
{
	if (g_redraw != 0)
		g_redraw();
}

static void focus_init(void)
{
	unsigned char i;

	if (g_focus_ready)
		return;
	for (i = 0u; i <= WM_MAX_WIN; i++)
		g_focus_slot[i] = 0xFFu;
	g_focus_ready = 1u;
}

static unsigned char slot_of(wm_ctrl_h h)
{
	if (h == 0u || h > WM_CTRL_MAX)
		return 0xFFu;
	return (unsigned char)(h - 1u);
}

static wm_ctrl_h handle_of(unsigned char slot)
{
	return (wm_ctrl_h)(slot + 1u);
}

static unsigned char win_focus_get(wm_id win)
{
	focus_init();
	if (win == 0u || win > WM_MAX_WIN)
		return 0xFFu;
	return g_focus_slot[win];
}

static void win_focus_set_slot(wm_id win, unsigned char slot)
{
	focus_init();
	if (win == 0u || win > WM_MAX_WIN)
		return;
	g_focus_slot[win] = slot;
}

wm_ctrl_h wm_ctrl_attach(wm_id win,
			 unsigned char cx, unsigned char cy,
			 unsigned char cw, unsigned char ch,
			 unsigned char flags,
			 unsigned char tag,
			 const struct wm_ctrl_ops *ops,
			 void *data)
{
	unsigned char i;

	focus_init();
	if (win == 0u || ops == 0 || cw == 0u || ch == 0u)
		return 0u;

	for (i = 0u; i < WM_CTRL_MAX; i++)
	{
		if (g_ctrls[i].win == 0u)
		{
			g_ctrls[i].win = win;
			g_ctrls[i].cx = cx;
			g_ctrls[i].cy = cy;
			g_ctrls[i].cw = cw;
			g_ctrls[i].ch = ch;
			g_ctrls[i].flags = flags;
			g_ctrls[i].tag = tag;
			g_ctrls[i].ops = ops;
			g_ctrls[i].data = data;
			if ((flags & WM_CF_FOCUSABLE) != 0 &&
			    win_focus_get(win) == 0xFFu)
				win_focus_set_slot(win, i);
			return handle_of(i);
		}
	}
	return 0u;
}

void wm_clear_controls(wm_id win)
{
	unsigned char i;
	struct wm_ctrl *c;

	focus_init();
	for (i = 0u; i < WM_CTRL_MAX; i++)
	{
		c = &g_ctrls[i];
		if (c->win != win)
			continue;
		if (c->ops != 0 && c->ops->destroy != 0)
			c->ops->destroy(c->data);
		c->win = 0u;
		c->ops = 0;
		c->data = 0;
	}
	if (win <= WM_MAX_WIN)
		g_focus_slot[win] = 0xFFu;
}

void wm_ctrl_detach_win(wm_id win)
{
	wm_clear_controls(win);
}

unsigned char wm_ctrl_abs(wm_id win, unsigned char cx, unsigned char cy,
			  unsigned char *ax, unsigned char *ay)
{
	unsigned char wx, wy, ww, wh;

	if (!wm_get_geom(win, &wx, &wy, &ww, &wh))
		return 0u;
	if (ax != 0)
		*ax = (unsigned char)(wx + 1u + cx);
	if (ay != 0)
		*ay = (unsigned char)(wy + 1u + cy);
	return 1u;
}

void wm_ctrl_paint_win(wm_id win, unsigned char wx, unsigned char wy,
		       unsigned char ww, unsigned char wh,
		       unsigned char wcolor)
{
	unsigned char i, slot, cliw, clih;
	struct wm_ctrl *c;
	struct wm_ctrl_draw d;

	wcolor = wcolor;
	if (ww < 3u || wh < 3u)
		return;
	cliw = (unsigned char)(ww - 2u);
	clih = (unsigned char)(wh - 2u);
	slot = win_focus_get(win);

	for (i = 0u; i < WM_CTRL_MAX; i++)
	{
		c = &g_ctrls[i];
		if (c->win != win || c->ops == 0 || c->ops->paint == 0)
			continue;
		if (c->cx >= cliw || c->cy >= clih)
			continue;

		d.win = win;
		d.handle = handle_of(i);
		d.ax = (unsigned char)(wx + 1u + c->cx);
		d.ay = (unsigned char)(wy + 1u + c->cy);
		d.cw = c->cw;
		d.ch = c->ch;
		d.data = c->data;
		d.state = 0u;
		if (win == wm_active())
			d.state |= WM_CS_ACTIVEWIN;
		if (i == slot)
			d.state |= WM_CS_FOCUSED;
		if (c->flags & WM_CF_PRESSED)
			d.state |= WM_CS_PRESSED;

		c->ops->paint(&d);
	}
}

unsigned char wm_ctrl_hit(wm_id win, unsigned char sx, unsigned char sy,
			  unsigned char *tag_out)
{
	unsigned char i, ax, ay, wx, wy, ww, wh;
	struct wm_ctrl *c;

	if (!wm_get_geom(win, &wx, &wy, &ww, &wh))
		return 0u;

	i = WM_CTRL_MAX;
	while (i > 0u)
	{
		i--;
		c = &g_ctrls[i];
		if (c->win != win || (c->flags & WM_CF_HITABLE) == 0)
			continue;

		ax = (unsigned char)(wx + 1u + c->cx);
		ay = (unsigned char)(wy + 1u + c->cy);
		if (sx < ax || sy < ay)
			continue;
		if (sx >= (unsigned char)(ax + c->cw))
			continue;
		if (sy >= (unsigned char)(ay + c->ch))
			continue;

		if (tag_out != 0)
			*tag_out = c->tag;
		win_focus_set_slot(win, i);
		return 1u;
	}
	return 0u;
}

wm_ctrl_h wm_ctrl_find_tag(wm_id win, unsigned char tag)
{
	unsigned char i;

	for (i = 0u; i < WM_CTRL_MAX; i++)
	{
		if (g_ctrls[i].win == win && g_ctrls[i].tag == tag)
			return handle_of(i);
	}
	return 0u;
}

unsigned char wm_ctrl_tag(wm_ctrl_h h)
{
	unsigned char s;

	s = slot_of(h);
	if (s == 0xFFu || g_ctrls[s].win == 0u)
		return 0u;
	return g_ctrls[s].tag;
}

void wm_ctrl_set_flag(wm_ctrl_h h, unsigned char flag, unsigned char on)
{
	unsigned char s;

	s = slot_of(h);
	if (s == 0xFFu || g_ctrls[s].win == 0u)
		return;
	if (on)
		g_ctrls[s].flags |= flag;
	else
		g_ctrls[s].flags &= (unsigned char)~flag;
}

unsigned char wm_ctrl_get_flags(wm_ctrl_h h)
{
	unsigned char s;

	s = slot_of(h);
	if (s == 0xFFu)
		return 0u;
	return g_ctrls[s].flags;
}

void wm_ctrl_click_handle(wm_ctrl_h h)
{
	unsigned char s;
	struct wm_ctrl *c;

	s = slot_of(h);
	if (s == 0xFFu)
		return;
	c = &g_ctrls[s];
	if (c->win == 0u || c->ops == 0 || c->ops->click == 0)
		return;
	win_focus_set_slot(c->win, s);
	c->ops->click(h, c->win, c->data);
}

void wm_ctrl_click_tag(wm_id win, unsigned char tag)
{
	wm_ctrl_click_handle(wm_ctrl_find_tag(win, tag));
}

void wm_ctrl_focus_first(wm_id win)
{
	unsigned char i;

	for (i = 0u; i < WM_CTRL_MAX; i++)
	{
		if (g_ctrls[i].win == win &&
		    (g_ctrls[i].flags & WM_CF_FOCUSABLE) != 0)
		{
			win_focus_set_slot(win, i);
			return;
		}
	}
	win_focus_set_slot(win, 0xFFu);
}

void wm_ctrl_focus_handle(wm_id win, wm_ctrl_h h)
{
	unsigned char s;

	s = slot_of(h);
	if (s == 0xFFu || g_ctrls[s].win != win)
		return;
	if ((g_ctrls[s].flags & WM_CF_FOCUSABLE) == 0)
		return;
	win_focus_set_slot(win, s);
}

void wm_ctrl_focus_tag(wm_id win, unsigned char tag)
{
	wm_ctrl_focus_handle(win, wm_ctrl_find_tag(win, tag));
}

wm_ctrl_h wm_ctrl_focus_get(wm_id win)
{
	unsigned char s;

	s = win_focus_get(win);
	if (s >= WM_CTRL_MAX || g_ctrls[s].win != win)
		return 0u;
	return handle_of(s);
}

unsigned char wm_ctrl_focus_tag_id(wm_id win)
{
	wm_ctrl_h h;

	h = wm_ctrl_focus_get(win);
	return wm_ctrl_tag(h);
}

unsigned char wm_ctrl_count_focusable(wm_id win)
{
	unsigned char i, n;

	n = 0u;
	for (i = 0u; i < WM_CTRL_MAX; i++)
	{
		if (g_ctrls[i].win == win &&
		    (g_ctrls[i].flags & WM_CF_FOCUSABLE) != 0)
			n++;
	}
	return n;
}

static unsigned char focus_step(wm_id win, signed char dir)
{
	unsigned char cur, start, n;

	n = wm_ctrl_count_focusable(win);
	if (n == 0u)
		return 0u;

	cur = win_focus_get(win);
	if (cur >= WM_CTRL_MAX || g_ctrls[cur].win != win)
	{
		wm_ctrl_focus_first(win);
		return 1u;
	}

	start = cur;
	for (;;)
	{
		if (dir > 0)
		{
			cur++;
			if (cur >= WM_CTRL_MAX)
				cur = 0u;
		}
		else
		{
			if (cur == 0u)
				cur = (unsigned char)(WM_CTRL_MAX - 1u);
			else
				cur--;
		}
		if (g_ctrls[cur].win == win &&
		    (g_ctrls[cur].flags & WM_CF_FOCUSABLE) != 0)
		{
			win_focus_set_slot(win, cur);
			return 1u;
		}
		if (cur == start)
			return 0u;
	}
}

unsigned char wm_ctrl_focus_next(wm_id win)
{
	return focus_step(win, 1);
}

unsigned char wm_ctrl_focus_prev(wm_id win)
{
	return focus_step(win, -1);
}

unsigned char wm_ctrl_activate_focused(wm_id win)
{
	wm_ctrl_h h;

	h = wm_ctrl_focus_get(win);
	if (h == 0u)
		return 0u;
	wm_ctrl_click_handle(h);
	return 1u;
}

unsigned char wm_ctrl_key_focused(wm_id win, unsigned char key)
{
	unsigned char s;
	struct wm_ctrl *c;

	s = win_focus_get(win);
	if (s >= WM_CTRL_MAX || g_ctrls[s].win != win)
		return 0u;
	c = &g_ctrls[s];
	if (c->ops == 0 || c->ops->key == 0)
		return 0u;
	return c->ops->key(handle_of(s), win, key, c->data);
}
