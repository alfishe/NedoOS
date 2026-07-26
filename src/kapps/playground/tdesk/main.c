#include <oscalls.h>
#include "wm.h"
#include "wm_ctrl.h"
#include "wm_form.h"
#include "wm_button.h"
#include "wm_edit.h"
#include "ui_mouse.h"

#define BR_NORMAL 0x00
#define BR_INK    0x40
#define BR_PAPER  0x80
#define BR_BOTH   0xC0
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))

#define COL_DESK MKCOLOR(BR_INK, PAPER_BLUE, INK_CYAN)

#define KEY_ESC    27
#define KEY_TAB    9
#define KEY_ENTER  13
#define KEY_SPACE  32
#define KEY_FOCUS  31
#define KEY_LEFT   248
#define KEY_DOWN   249
#define KEY_UP     250
#define KEY_RIGHT  251
/* Back-Tab often arrives as Shift+Tab ? same 9 with modifier in high bits;
 * NedoOS: use KEY_LEFT/UP as prev when no dedicated backtab. */

#define CID_CLOSE  1
#define CID_PING   2
#define CID_NEW    3

#include "forms_demo.inc"

static unsigned char g_form_seq;
static unsigned char g_need_redraw;

static unsigned char g_drag;
static wm_id g_drag_id;
static unsigned char g_drag_ox, g_drag_oy, g_drag_mx, g_drag_my;

static void desk_redraw(void)
{
	ui_mouse_hide();
	wm_redraw();
	ui_mouse_show();
	g_need_redraw = 0u;
}

static wm_id open_form(const unsigned char *res);
static wm_id open_form_file(const char *path, const unsigned char *fallback);
static wm_id open_form_cached(const char *path, const unsigned char *fallback);

static void on_btn(wm_id win, unsigned char ctrl_id, void *user)
{
	user = user;
	switch (ctrl_id)
	{
	case CID_CLOSE:
		wm_destroy(win);
		g_need_redraw = 1u;
		break;
	case CID_PING:
		wm_set_body(win, "Ping!\n"
			    "Resource form + binds.\n"
			    "Focus: yellow >btn<\n"
			    "Press: white flash.");
		g_need_redraw = 1u;
		break;
	case CID_NEW:
		g_form_seq++;
		if (open_form_file((g_form_seq & 1u) ? "dialog.frm" : "welcome.frm",
				   (g_form_seq & 1u) ? form_dialog : form_welcome) != 0u)
			g_need_redraw = 1u;
		break;
	default:
		break;
	}
}

static char g_name_buf[24];
static struct wm_edit g_name_edit;

static void on_name_ok(wm_id win, unsigned char tag, void *user)
{
	user = user;
	tag = tag;
	wm_set_body(win, g_name_buf[0] ? g_name_buf : "(empty)");
	g_need_redraw = 1u;
}

static wm_id open_name_dialog(void)
{
	wm_id id;
	unsigned char col;

	col = MKCOLOR(BR_BOTH, PAPER_WHITE, INK_BLACK);
	id = wm_create(10, 8, 40, 8, "Your name", col);
	if (id == 0u)
		return 0u;
	wm_set_body(id, "Type below, Tab to OK:");
	g_name_buf[0] = 0;
	g_name_edit.buf = g_name_buf;
	g_name_edit.maxlen = (unsigned char)sizeof(g_name_buf);
	g_name_edit.len = 0;
	g_name_edit.cursor = 0;
	wm_edit_add(id, 1, 3, 28, &g_name_edit);
	wm_button_add(id, 1, 5, 10, 1, " OK ", 10, on_name_ok, 0);
	wm_ctrl_focus_first(id);
	wm_set_modal(id, 1u);
	return id;
}

static const struct wm_form_bind g_binds[] = {
	{ CID_CLOSE, on_btn, 0 },
	{ CID_PING,  on_btn, 0 },
	{ CID_NEW,   on_btn, 0 }
};

/* Caller-owned staging: load now, open later (or keep for reuse). */
static unsigned char g_frm_cache[WM_FORM_MAX];
static unsigned int g_frm_cache_len;

static wm_id open_form(const unsigned char *res)
{
	return wm_form_open(res, g_binds, 3);
}

/* Prefer disk .frm; fall back to embedded forms_demo.inc. */
static wm_id open_form_file(const char *path, const unsigned char *fallback)
{
	wm_id id;

	id = wm_form_open_file(path, g_binds, 3);
	if (id != 0u)
		return id;
	if (fallback != 0)
		return open_form(fallback);
	return 0u;
}

/* Preload into g_frm_cache, then open from memory. */
static wm_id open_form_cached(const char *path, const unsigned char *fallback)
{
	g_frm_cache_len = wm_form_load(path, g_frm_cache, WM_FORM_MAX);
	if (g_frm_cache_len != 0u)
		return wm_form_open(g_frm_cache, g_binds, 3);
	if (fallback != 0)
		return open_form(fallback);
	return 0u;
}

static void cycle_windows(void)
{
	wm_id cur, nxt;

	cur = wm_active();
	nxt = wm_next(cur);
	if (nxt != 0u)
	{
		wm_bring_front(nxt);
		wm_restore(nxt);
	}
}

static unsigned char handle_form_keys(unsigned char key)
{
	wm_id win;

	win = wm_active();
	if (win == 0u)
		return 0u;

	/* First: focused widget (edit etc.) may consume the key */
	if (wm_ctrl_key_focused(win, key))
	{
		g_need_redraw = 1u;
		return 1u;
	}

	if (key == KEY_TAB || key == KEY_RIGHT || key == KEY_DOWN)
	{
		if (wm_ctrl_count_focusable(win) == 0u)
			return 0u;
		wm_ctrl_focus_next(win);
		g_need_redraw = 1u;
		return 1u;
	}
	if (key == KEY_LEFT || key == KEY_UP)
	{
		if (wm_ctrl_count_focusable(win) == 0u)
			return 0u;
		wm_ctrl_focus_prev(win);
		g_need_redraw = 1u;
		return 1u;
	}
	if (key == KEY_ENTER || key == KEY_SPACE)
	{
		if (wm_ctrl_count_focusable(win) == 0u)
			return 0u;
		wm_ctrl_activate_focused(win);
		g_need_redraw = 1u;
		return 1u;
	}
	return 0u;
}

static void drag_clamp(unsigned char *nx, unsigned char *ny,
		       unsigned char w, unsigned char h)
{
	unsigned char maxx, maxy;

	if (w >= WM_SCR_W)
		maxx = 0u;
	else
		maxx = (unsigned char)(WM_SCR_W - w);
	if (h >= WM_DESK_H)
		maxy = 0u;
	else
		maxy = (unsigned char)(WM_DESK_H - h);
	if (*nx > maxx)
		*nx = maxx;
	if (*ny > maxy)
		*ny = maxy;
}

static void drag_begin(wm_id id)
{
	unsigned char wx, wy, mx, my;

	if (!wm_get_geom(id, &wx, &wy, 0, 0))
		return;
	mx = ui_mouse_x();
	my = ui_mouse_y();
	g_drag = 1u;
	g_drag_id = id;
	g_drag_ox = (unsigned char)(mx - wx);
	g_drag_oy = (unsigned char)(my - wy);
	g_drag_mx = mx;
	g_drag_my = my;
	if (id != wm_active())
		wm_bring_front(id);
}

static void drag_update(void)
{
	unsigned char mx, my, nx, ny, w, h, ox, oy;

	if (!g_drag)
		return;
	if (!ui_mouse_lmb_down())
	{
		g_drag = 0u;
		g_drag_id = 0u;
		return;
	}
	mx = ui_mouse_x();
	my = ui_mouse_y();
	if (mx == g_drag_mx && my == g_drag_my)
		return;
	g_drag_mx = mx;
	g_drag_my = my;
	if (!wm_get_geom(g_drag_id, &ox, &oy, &w, &h))
	{
		g_drag = 0u;
		return;
	}
	if (mx >= g_drag_ox)
		nx = (unsigned char)(mx - g_drag_ox);
	else
		nx = 0u;
	if (my >= g_drag_oy)
		ny = (unsigned char)(my - g_drag_oy);
	else
		ny = 0u;
	drag_clamp(&nx, &ny, w, h);
	if (nx == ox && ny == oy)
		return;
	wm_move(g_drag_id, nx, ny);
	desk_redraw();
}

static void handle_mouse(void)
{
	struct wm_hit hit;
	unsigned char need;

	if (g_drag)
	{
		drag_update();
		return;
	}
	if (!ui_mouse_lmb_click())
		return;

	wm_hit_test(ui_mouse_x(), ui_mouse_y(), &hit);
	need = 0u;

	switch (hit.kind)
	{
	case WM_HIT_CLOSE:
		if (hit.id != 0u)
		{
			wm_destroy(hit.id);
			need = 1u;
		}
		break;
	case WM_HIT_MINBTN:
		if (hit.id != 0u)
		{
			wm_minimize(hit.id);
			need = 1u;
		}
		break;
	case WM_HIT_TITLE:
		if (hit.id != 0u)
		{
			drag_begin(hit.id);
			need = 1u;
		}
		break;
	case WM_HIT_CTRL:
		if (hit.id != 0u)
		{
			if (hit.id != wm_active())
				wm_bring_front(hit.id);
			/* tag 0 may be edit/label-hit: still focused by hit */
			if (hit.ctrl_id != 0u)
				wm_ctrl_click_tag(hit.id, hit.ctrl_id);
			need = 1u;
		}
		break;
	case WM_HIT_WIN:
		if (hit.id != 0u && hit.id != wm_active())
		{
			wm_bring_front(hit.id);
			need = 1u;
		}
		break;
	case WM_HIT_MINBAR:
		if (hit.id != 0u)
		{
			wm_restore(hit.id);
			need = 1u;
		}
		break;
	default:
		break;
	}

	if (need || g_need_redraw)
		desk_redraw();
}

void main(void)
{
	signed long gk;
	wm_id id;
	unsigned char key;

	OS_SETGFX(0x86);
	OS_CLS(COL_DESK);

	if (!wm_init())
	{
		OS_SETXY(0, 0);
		OS_SETCOLOR(COL_DESK);
		return;
	}

	wm_set_desktop_color(COL_DESK);
	wm_set_desktop_char(0xB0);
	wm_ctrl_set_redraw(desk_redraw);

	g_form_seq = 0u;
	g_drag = 0u;
	g_need_redraw = 0u;
	g_frm_cache_len = 0u;

	/* Cache path: load .frm into RAM, then open (fallback = embedded). */
	open_form_cached("welcome.frm", form_welcome);
	/* One-shot: load via internal stage and open immediately. */
	open_form_file("dialog.frm", form_dialog);
	open_name_dialog();

	ui_mouse_init();
	desk_redraw();

	for (;;)
	{
		gk = OS_GETKEY();

		if (((unsigned long)gk & 0x80000000UL) != 0UL)
		{
			ui_mouse_hide();
			g_drag = 0u;
			YIELD();
			continue;
		}

		key = (unsigned char)gk;

		if (key == KEY_FOCUS)
		{
			g_drag = 0u;
			desk_redraw();
			continue;
		}
		if (key == KEY_ESC)
			break;

		if (!g_drag)
		{
			if (handle_form_keys(key))
			{
				if (g_need_redraw)
					desk_redraw();
			}
			else if (key == '`')
			{
				/* backtick: cycle windows (no-op under modal) */
				if (wm_modal_top() == 0u)
				{
					cycle_windows();
					desk_redraw();
				}
			}
			else if (key == 'n' || key == 'N')
			{
				/* opening more windows under a modal is confusing */
				if (wm_modal_top() == 0u)
				{
					g_form_seq++;
					id = open_form_file(
						(g_form_seq & 1u) ? "dialog.frm" : "welcome.frm",
						(g_form_seq & 1u) ? form_dialog : form_welcome);
					if (id != 0u)
						desk_redraw();
				}
			}
			else if (key == 'm' || key == 'M')
			{
				id = wm_active();
				if (id != 0u && !wm_is_modal(id))
				{
					wm_minimize(id);
					desk_redraw();
				}
			}
			else if (key == 'r' || key == 'R')
			{
				if (wm_modal_top() == 0u)
				{
					id = wm_active();
					if (id != 0u)
					{
						wm_restore(id);
						desk_redraw();
					}
				}
			}
		}

		ui_mouse_poll();
		handle_mouse();

		if (key == 0 && !g_drag)
			YIELD();
	}

	ui_mouse_hide();
	wm_shutdown();
	OS_SETGFX(0xFF);
}
