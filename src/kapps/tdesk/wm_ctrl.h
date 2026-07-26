#ifndef TDESK_WM_CTRL_H
#define TDESK_WM_CTRL_H

#include "wm.h"

/*
 * Universal control BINDING to a window ? not the widgets themselves.
 *
 * Attach with client-relative (cx,cy,cw,ch). On every redraw the window
 * calls ops->paint with ABSOLUTE screen coords, so drawing moves with
 * the window. Freehand draw outside attach will NOT follow the window.
 *
 * Widget modules (button, label, edit, ?) supply ops + private data.
 */

#define WM_CTRL_MAX 32

#define WM_CF_FOCUSABLE 0x01
#define WM_CF_HITABLE   0x02
#define WM_CF_PRESSED   0x04

#define WM_CS_FOCUSED   0x01
#define WM_CS_PRESSED   0x02
#define WM_CS_ACTIVEWIN 0x04

typedef unsigned char wm_ctrl_h; /* 1..WM_CTRL_MAX, 0 = none */
typedef void (*wm_ctrl_redraw_fn)(void);

struct wm_ctrl_draw {
	wm_id win;
	wm_ctrl_h handle;
	unsigned char ax, ay;
	unsigned char cw, ch;
	unsigned char state;
	void *data;
};

struct wm_ctrl_ops {
	void (*paint)(const struct wm_ctrl_draw *d);
	void (*click)(wm_ctrl_h h, wm_id win, void *data);
	unsigned char (*key)(wm_ctrl_h h, wm_id win, unsigned char key, void *data);
	void (*destroy)(void *data);
};

wm_ctrl_h wm_ctrl_attach(wm_id win,
			 unsigned char cx, unsigned char cy,
			 unsigned char cw, unsigned char ch,
			 unsigned char flags,
			 unsigned char tag,
			 const struct wm_ctrl_ops *ops,
			 void *data);

void wm_clear_controls(wm_id win);
void wm_ctrl_detach_win(wm_id win);

void wm_ctrl_set_redraw(wm_ctrl_redraw_fn fn);
void wm_ctrl_redraw(void);

void wm_ctrl_paint_win(wm_id win, unsigned char wx, unsigned char wy,
		       unsigned char ww, unsigned char wh,
		       unsigned char wcolor);

unsigned char wm_ctrl_hit(wm_id win, unsigned char sx, unsigned char sy,
			  unsigned char *tag_out);

void wm_ctrl_click_tag(wm_id win, unsigned char tag);
void wm_ctrl_click_handle(wm_ctrl_h h);
#define wm_ctrl_click wm_ctrl_click_tag

wm_ctrl_h wm_ctrl_find_tag(wm_id win, unsigned char tag);
unsigned char wm_ctrl_tag(wm_ctrl_h h);

void wm_ctrl_set_flag(wm_ctrl_h h, unsigned char flag, unsigned char on);
unsigned char wm_ctrl_get_flags(wm_ctrl_h h);

void wm_ctrl_focus_first(wm_id win);
void wm_ctrl_focus_handle(wm_id win, wm_ctrl_h h);
void wm_ctrl_focus_tag(wm_id win, unsigned char tag);
#define wm_ctrl_focus_set wm_ctrl_focus_tag

wm_ctrl_h wm_ctrl_focus_get(wm_id win);
unsigned char wm_ctrl_focus_tag_id(wm_id win);
#define wm_ctrl_focus_id wm_ctrl_focus_tag_id

unsigned char wm_ctrl_focus_next(wm_id win);
unsigned char wm_ctrl_focus_prev(wm_id win);
unsigned char wm_ctrl_activate_focused(wm_id win);
unsigned char wm_ctrl_count_focusable(wm_id win);
unsigned char wm_ctrl_key_focused(wm_id win, unsigned char key);

unsigned char wm_ctrl_abs(wm_id win, unsigned char cx, unsigned char cy,
			  unsigned char *ax, unsigned char *ay);

#endif
