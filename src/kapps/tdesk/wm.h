#ifndef TDESK_WM_H
#define TDESK_WM_H

/*
 * Pseudographic window manager (EDIT / Turbo Pascal style).
 *
 * Window records and body text live in a 16K data page mapped at C000.
 * Low RAM keeps only handles, z-order and a few bytes of WM state.
 *
 * Handles are 1..WM_MAX_WIN. 0 = invalid.
 */

#define WM_MAX_WIN      12
#define WM_TITLE_MAX    28
#define WM_BODY_MAX     160

#define WM_F_VISIBLE    0x01
#define WM_F_MINIMIZED  0x02
#define WM_F_SHADOW     0x04
#define WM_F_ACTIVE     0x08
#define WM_F_MODAL      0x10  /* captures input; only topmost modal gets hits/keys */

#define WM_SCR_W        80
#define WM_SCR_H        25
#define WM_DESK_H       24   /* last row = minimize bar */

typedef unsigned char wm_id;

unsigned char wm_init(void);
void wm_shutdown(void);

/* Create overlapping window; returns id or 0. */
wm_id wm_create(unsigned char x, unsigned char y,
		unsigned char w, unsigned char h,
		const char *title, unsigned char color);

void wm_destroy(wm_id id);
void wm_set_title(wm_id id, const char *title);
void wm_set_body(wm_id id, const char *body);
void wm_set_color(wm_id id, unsigned char color);

void wm_show(wm_id id);
void wm_hide(wm_id id);
void wm_minimize(wm_id id);
void wm_restore(wm_id id);
void wm_bring_front(wm_id id);
void wm_move(wm_id id, unsigned char x, unsigned char y);
/* Returns 1 if id valid; fills x,y,w,h (NULL pointers skipped). */
unsigned char wm_get_geom(wm_id id, unsigned char *x, unsigned char *y,
			  unsigned char *w, unsigned char *h);

/* Modal: set after create (or via form flag). Nested OK ? topmost wins. */
void wm_set_modal(wm_id id, unsigned char on);
unsigned char wm_is_modal(wm_id id);
/* Frontmost visible non-minimized modal, or 0. */
wm_id wm_modal_top(void);

wm_id wm_active(void);
wm_id wm_next(wm_id id);   /* cycle; stuck on modal_top while one exists */

/* Hit-test for mouse (topmost first). */
#define WM_HIT_NONE     0
#define WM_HIT_DESK     1
#define WM_HIT_WIN      2  /* client / frame */
#define WM_HIT_TITLE    3
#define WM_HIT_CLOSE    4  /* þ at title x+2 */
#define WM_HIT_MINBTN   5  /* minimize glyph at title x+4 */
#define WM_HIT_MINBAR   6  /* minimized window on taskbar */
#define WM_HIT_CTRL     7  /* control inside client */

struct wm_hit {
	unsigned char kind;
	wm_id id;
	unsigned char ctrl_id; /* valid if kind == WM_HIT_CTRL */
};

void wm_hit_test(unsigned char x, unsigned char y, struct wm_hit *out);

/* Full redraw: desktop, windows back?front, minimize bar. */
void wm_redraw(void);

void wm_set_desktop_color(unsigned char color);
void wm_set_desktop_char(unsigned char ch);

#endif
