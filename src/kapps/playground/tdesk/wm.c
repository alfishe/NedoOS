#include <string.h>
#include <oscalls.h>
#include "bank.h"
#include "vtxt.h"
#include "wm.h"
#include "wm_ctrl.h"

/* ---- colors (Spectrum attr) ----------------------------------------- */
#define BR_NORMAL 0x00
#define BR_INK    0x40
#define BR_PAPER  0x80
#define BR_BOTH   0xC0
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))

#define COL_TITLE_ACT   MKCOLOR(BR_BOTH, PAPER_BLACK, INK_YELLOW)
#define COL_TITLE_INACT MKCOLOR(BR_INK, PAPER_BLUE, INK_WHITE)
#define COL_MINBAR      MKCOLOR(BR_BOTH, PAPER_BLUE, INK_WHITE)
#define COL_MINBTN_ACT  MKCOLOR(BR_BOTH, PAPER_BLACK, INK_YELLOW)
#define COL_MINBTN      MKCOLOR(BR_INK, PAPER_CYAN, INK_BLACK)
#define COL_SHADOW      MKCOLOR(BR_NORMAL, PAPER_BLACK, INK_BLACK)

/* Double-line frame: CP866 codes (vtxt maps to ATM like BDOS) */
#define CH_TL  201
#define CH_TR  187
#define CH_BL  200
#define CH_BR  188
#define CH_H   205
#define CH_V   186

/* ---- banked window record (fixed slot) ------------------------------ */
#define WM_MAGIC0       0x57  /* 'W' */
#define WM_MAGIC1       0x4D  /* 'M' */
#define WM_SLOT_SIZE    208
#define WM_SLOT_BASE    16
#define WM_OFF_FLAGS    0
#define WM_OFF_X        1
#define WM_OFF_Y        2
#define WM_OFF_W        3
#define WM_OFF_H        4
#define WM_OFF_COLOR    5
#define WM_OFF_TITLE    6
#define WM_OFF_BODY     (6 + WM_TITLE_MAX)

/* slot address inside mapped C000 page */
#define WM_SLOT_PTR(i)  ((unsigned char *)(BANK_WIN_C000 + WM_SLOT_BASE + \
			 (unsigned int)(i) * WM_SLOT_SIZE))

/* ---- low-RAM WM state (tiny) ---------------------------------------- */
static unsigned char g_page;       /* data page number */
static unsigned char g_home_c000;
static unsigned char g_home_8000;
static unsigned char g_n;          /* live window count */
static unsigned char g_active;     /* 1..WM_MAX_WIN */
static unsigned char g_z[WM_MAX_WIN]; /* back ? front, values = id */
static unsigned char g_desk_color;
static unsigned char g_desk_char;
static unsigned char g_inited;

/* Public helper used early by create/bring_front ? defined below. */
wm_id wm_modal_top(void);

/* ---- helpers -------------------------------------------------------- */

static unsigned char *wm_slot(unsigned char idx)
{
	/* idx 0..WM_MAX_WIN-1; page must already be mapped */
	return WM_SLOT_PTR(idx);
}

static unsigned char wm_idx_of(wm_id id)
{
	return (unsigned char)(id - 1u);
}

static unsigned char wm_valid(wm_id id)
{
	unsigned char *s;
	unsigned char saved;
	unsigned char f;

	if (id == 0u || id > WM_MAX_WIN || !g_inited)
		return 0u;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	f = s[WM_OFF_FLAGS];
	bank_pop(saved);
	/* unused slots have flags == 0 */
	return (f != 0u) ? 1u : 0u;
}

static void wm_strcpy_n(char *dst, const char *src, unsigned char maxlen)
{
	unsigned char i;

	if (src == 0)
	{
		dst[0] = 0;
		return;
	}
	for (i = 0u; i < maxlen - 1u && src[i] != 0; i++)
		dst[i] = src[i];
	dst[i] = 0;
}

static void wm_z_remove(wm_id id)
{
	unsigned char i, j;

	for (i = 0u; i < g_n; i++)
	{
		if (g_z[i] == id)
		{
			for (j = i; j + 1u < g_n; j++)
				g_z[j] = g_z[j + 1u];
			g_n--;
			return;
		}
	}
}

static void wm_z_push_front(wm_id id)
{
	wm_z_remove(id);
	g_z[g_n++] = id;
}

/* Place id just under modal in z-order (modal stays frontmost). */
static void wm_z_insert_under(wm_id id, wm_id modal)
{
	unsigned char i, mi;

	wm_z_remove(id);
	mi = g_n;
	for (i = 0u; i < g_n; i++)
	{
		if (g_z[i] == modal)
		{
			mi = i;
			break;
		}
	}
	for (i = g_n; i > mi; i--)
		g_z[i] = g_z[i - 1u];
	g_z[mi] = id;
	g_n++;
}

static unsigned char wm_slot_flags(wm_id id)
{
	unsigned char *s;
	unsigned char saved;
	unsigned char f;

	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	f = s[WM_OFF_FLAGS];
	bank_pop(saved);
	return f;
}

static wm_id wm_alloc_id(void)
{
	unsigned char i;
	unsigned char *s;
	unsigned char saved;

	saved = bank_push(g_page);
	for (i = 0u; i < WM_MAX_WIN; i++)
	{
		s = wm_slot(i);
		if (s[WM_OFF_FLAGS] == 0u)
		{
			bank_pop(saved);
			return (wm_id)(i + 1u);
		}
	}
	bank_pop(saved);
	return 0u;
}

static void wm_fill_row(unsigned char x, unsigned char y,
			unsigned char n, unsigned char ch, unsigned char color)
{
	vtxt_hline(x, y, n, ch, color);
}

static void wm_draw_desktop(void)
{
	vtxt_fill(0, 0, WM_SCR_W, WM_DESK_H, g_desk_char, g_desk_color);
}

static void wm_draw_shadow(unsigned char x, unsigned char y,
			   unsigned char w, unsigned char h)
{
	unsigned char i;
	unsigned char sx, sy;

	if (x + w >= WM_SCR_W || y + h >= WM_DESK_H)
		return;
	sx = (unsigned char)(x + 1u);
	sy = (unsigned char)(y + h);
	if (sy < WM_DESK_H)
		wm_fill_row(sx, sy, w, ' ', COL_SHADOW);
	sx = (unsigned char)(x + w);
	if (sx < WM_SCR_W)
	{
		for (i = 1u; i < h; i++)
		{
			sy = (unsigned char)(y + i);
			if (sy >= WM_DESK_H)
				break;
			vtxt_putc(sx, sy, ' ', COL_SHADOW);
		}
	}
}

static void wm_draw_frame(unsigned char x, unsigned char y,
			  unsigned char w, unsigned char h,
			  unsigned char color, unsigned char title_color,
			  const char *title, unsigned char active,
			  unsigned char show_min)
{
	unsigned char i, inner, tlen, tx;
	unsigned char tcol;

	if (w < 4u || h < 3u)
		return;

	inner = (unsigned char)(w - 2u);
	tcol = active ? title_color : COL_TITLE_INACT;

	/* client fill + border */
	vtxt_fill(x, y, w, h, ' ', color);
	vtxt_putc(x, y, CH_TL, color);
	vtxt_hline((unsigned char)(x + 1u), y, inner, CH_H, color);
	vtxt_putc((unsigned char)(x + w - 1u), y, CH_TR, color);

	for (i = 1u; i < h - 1u; i++)
	{
		vtxt_putc(x, (unsigned char)(y + i), CH_V, color);
		vtxt_putc((unsigned char)(x + w - 1u), (unsigned char)(y + i),
			  CH_V, color);
	}

	vtxt_putc(x, (unsigned char)(y + h - 1u), CH_BL, color);
	vtxt_hline((unsigned char)(x + 1u), (unsigned char)(y + h - 1u),
		   inner, CH_H, color);
	vtxt_putc((unsigned char)(x + w - 1u), (unsigned char)(y + h - 1u),
		  CH_BR, color);

	if (title != 0 && title[0] != 0)
	{
		tlen = 0u;
		while (title[tlen] != 0)
			tlen++;
		if (tlen + 2u > inner)
			tlen = (unsigned char)(inner - 2u);
		tx = (unsigned char)(x + 1u + (inner - (tlen + 2u)) / 2u);
		vtxt_putc(tx, y, '[', tcol);
		for (i = 0u; i < tlen; i++)
			vtxt_putc((unsigned char)(tx + 1u + i), y,
				  (unsigned char)title[i], tcol);
		vtxt_putc((unsigned char)(tx + 1u + tlen), y, ']', tcol);
	}

	vtxt_putc((unsigned char)(x + 2u), y, 254, tcol);
	if (show_min && w > 8u)
		vtxt_putc((unsigned char)(x + 4u), y, 22, tcol);
}

static void wm_draw_body(unsigned char x, unsigned char y,
			 unsigned char w, unsigned char h,
			 unsigned char color, const char *body)
{
	unsigned char row, col, maxr, maxc;
	const char *p;

	if (body == 0 || body[0] == 0 || h < 3u || w < 4u)
		return;

	maxr = (unsigned char)(h - 2u);
	maxc = (unsigned char)(w - 2u);
	p = body;
	row = 0u;
	col = 0u;

	while (*p != 0 && row < maxr)
	{
		if (*p == '\n' || *p == '\r')
		{
			row++;
			col = 0u;
			if (*p == '\r' && p[1] == '\n')
				p++;
			p++;
			continue;
		}
		if (col >= maxc)
		{
			row++;
			col = 0u;
			if (row >= maxr)
				break;
		}
		vtxt_putc((unsigned char)(x + 1u + col),
			  (unsigned char)(y + 1u + row),
			  (unsigned char)*p, color);
		p++;
		col++;
	}
}

static void wm_paint_one(wm_id id, unsigned char *s, unsigned char is_active)
{
	unsigned char flags, x, y, w, h, color;

	flags = s[WM_OFF_FLAGS];
	if ((flags & WM_F_VISIBLE) == 0u)
		return;
	if (flags & WM_F_MINIMIZED)
		return;

	x = s[WM_OFF_X];
	y = s[WM_OFF_Y];
	w = s[WM_OFF_W];
	h = s[WM_OFF_H];
	color = s[WM_OFF_COLOR];

	if (flags & WM_F_SHADOW)
		wm_draw_shadow(x, y, w, h);

	wm_draw_frame(x, y, w, h, color,
		      COL_TITLE_ACT,
		      (const char *)&s[WM_OFF_TITLE],
		      is_active,
		      (flags & WM_F_MODAL) ? 0u : 1u);
	wm_draw_body(x, y, w, h, color, (const char *)&s[WM_OFF_BODY]);
	wm_ctrl_paint_win(id, x, y, w, h, color);
}

static void wm_draw_minbar(void)
{
	unsigned char i, saved;
	unsigned char *s;
	unsigned char flags;
	unsigned char bx;
	const char *title;
	unsigned char tlen, j;
	unsigned char is_act;
	unsigned char col;

	wm_fill_row(0, WM_DESK_H, WM_SCR_W, ' ', COL_MINBAR);

	bx = 1u;
	saved = bank_push(g_page);
	for (i = 0u; i < g_n; i++)
	{
		s = wm_slot(wm_idx_of(g_z[i]));
		flags = s[WM_OFF_FLAGS];
		if ((flags & WM_F_VISIBLE) == 0u)
			continue;
		if ((flags & WM_F_MINIMIZED) == 0u)
			continue;

		title = (const char *)&s[WM_OFF_TITLE];
		tlen = 0u;
		while (title[tlen] != 0)
			tlen++;
		if (tlen > 12u)
			tlen = 12u;
		if (bx + tlen + 3u >= WM_SCR_W)
			break;

		is_act = (g_z[i] == g_active) ? 1u : 0u;
		col = is_act ? COL_MINBTN_ACT : COL_MINBTN;
		vtxt_putc(bx, WM_DESK_H, '[', col);
		for (j = 0u; j < tlen; j++)
			vtxt_putc((unsigned char)(bx + 1u + j), WM_DESK_H,
				  (unsigned char)title[j], col);
		vtxt_putc((unsigned char)(bx + 1u + tlen), WM_DESK_H, ']', col);
		bx = (unsigned char)(bx + tlen + 3u);
	}
	bank_pop(saved);

	vtxt_puts(50, WM_DESK_H, "Tab Ent ` N M Esc", COL_MINBAR);
}

/* ---- public API ----------------------------------------------------- */

unsigned char wm_init(void)
{
	unsigned char *base;
	unsigned char i;

	if (g_inited)
		return 1u;

	g_home_c000 = bank_cur_c000();
	g_home_8000 = bank_cur_8000();

	if (!vtxt_init())
		return 0u;

	if (!bank_new_page(&g_page))
	{
		vtxt_shutdown();
		return 0u;
	}

	{
		unsigned char saved;
		saved = bank_push(g_page);
		base = (unsigned char *)BANK_WIN_C000;
		base[0] = WM_MAGIC0;
		base[1] = WM_MAGIC1;
		base[2] = 1; /* version */
		base[3] = 0;
		for (i = 0u; i < WM_MAX_WIN; i++)
		{
			unsigned char *s = wm_slot(i);
			memset(s, 0, WM_SLOT_SIZE);
		}
		bank_pop(saved);
	}

	g_n = 0u;
	g_active = 0u;
	g_desk_color = MKCOLOR(BR_INK, PAPER_BLUE, INK_CYAN);
	g_desk_char = 0xB0; /* ° */
	g_inited = 1u;
	return 1u;
}

void wm_shutdown(void)
{
	unsigned char i;

	if (!g_inited)
		return;
	for (i = 1u; i <= WM_MAX_WIN; i++)
		wm_clear_controls((wm_id)i);
	bank_map_c000(g_home_c000);
	bank_map_8000(g_home_8000);
	bank_del_page(g_page);
	vtxt_shutdown();
	g_page = 0u;
	g_n = 0u;
	g_active = 0u;
	g_inited = 0u;
}

wm_id wm_create(unsigned char x, unsigned char y,
		unsigned char w, unsigned char h,
		const char *title, unsigned char color)
{
	wm_id id;
	unsigned char *s;
	unsigned char saved;

	if (!g_inited)
		return 0u;
	if (w < 6u || h < 3u)
		return 0u;
	if (x >= WM_SCR_W || y >= WM_DESK_H)
		return 0u;

	id = wm_alloc_id();
	if (id == 0u)
		return 0u;

	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	memset(s, 0, WM_SLOT_SIZE);
	s[WM_OFF_FLAGS] = (unsigned char)(WM_F_VISIBLE | WM_F_SHADOW);
	s[WM_OFF_X] = x;
	s[WM_OFF_Y] = y;
	s[WM_OFF_W] = w;
	s[WM_OFF_H] = h;
	s[WM_OFF_COLOR] = color;
	wm_strcpy_n((char *)&s[WM_OFF_TITLE], title, WM_TITLE_MAX);
	bank_pop(saved);

	{
		wm_id mt;

		mt = wm_modal_top();
		if (mt != 0u)
		{
			/* Keep modal on top and focused; new window sits under it. */
			wm_z_insert_under(id, mt);
			g_active = mt;
		}
		else
		{
			wm_z_push_front(id);
			g_active = id;
		}
	}
	return id;
}

void wm_destroy(wm_id id)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;

	wm_clear_controls(id);

	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	memset(s, 0, WM_SLOT_SIZE);
	bank_pop(saved);

	wm_z_remove(id);
	if (g_active == id)
		g_active = (g_n > 0u) ? g_z[g_n - 1u] : 0u;
}

void wm_set_title(wm_id id, const char *title)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	wm_strcpy_n((char *)&s[WM_OFF_TITLE], title, WM_TITLE_MAX);
	bank_pop(saved);
}

void wm_set_body(wm_id id, const char *body)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	wm_strcpy_n((char *)&s[WM_OFF_BODY], body, WM_BODY_MAX);
	bank_pop(saved);
}

void wm_set_color(wm_id id, unsigned char color)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	s[WM_OFF_COLOR] = color;
	bank_pop(saved);
}

void wm_show(wm_id id)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	s[WM_OFF_FLAGS] |= WM_F_VISIBLE;
	s[WM_OFF_FLAGS] &= (unsigned char)~WM_F_MINIMIZED;
	bank_pop(saved);
	wm_bring_front(id);
}

void wm_hide(wm_id id)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	s[WM_OFF_FLAGS] &= (unsigned char)~WM_F_VISIBLE;
	bank_pop(saved);
	if (g_active == id)
		g_active = (g_n > 0u) ? g_z[g_n - 1u] : 0u;
}

void wm_minimize(wm_id id)
{
	unsigned char *s;
	unsigned char saved;
	unsigned char flags;

	if (!wm_valid(id))
		return;
	flags = wm_slot_flags(id);
	if (flags & WM_F_MODAL)
		return; /* modal cannot be minimized */
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	s[WM_OFF_FLAGS] |= WM_F_MINIMIZED;
	bank_pop(saved);
}

void wm_restore(wm_id id)
{
	unsigned char *s;
	unsigned char saved;
	wm_id mt;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	s[WM_OFF_FLAGS] |= WM_F_VISIBLE;
	s[WM_OFF_FLAGS] &= (unsigned char)~WM_F_MINIMIZED;
	bank_pop(saved);

	mt = wm_modal_top();
	if (mt != 0u && id != mt && (wm_slot_flags(id) & WM_F_MODAL) == 0u)
	{
		/* Restoring a normal window under an active modal ? no steal. */
		wm_z_insert_under(id, mt);
		return;
	}
	wm_bring_front(id);
}

void wm_bring_front(wm_id id)
{
	wm_id mt;
	unsigned char flags;

	if (!wm_valid(id))
		return;

	flags = wm_slot_flags(id);
	mt = wm_modal_top();
	if (mt != 0u && id != mt && (flags & WM_F_MODAL) == 0u)
	{
		/* Non-modal cannot cover / steal focus from a modal. */
		wm_z_insert_under(id, mt);
		return;
	}

	wm_z_push_front(id);
	g_active = id;
}

void wm_move(wm_id id, unsigned char x, unsigned char y)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	s[WM_OFF_X] = x;
	s[WM_OFF_Y] = y;
	bank_pop(saved);
}

unsigned char wm_get_geom(wm_id id, unsigned char *x, unsigned char *y,
			  unsigned char *w, unsigned char *h)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return 0u;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	if (x != 0)
		*x = s[WM_OFF_X];
	if (y != 0)
		*y = s[WM_OFF_Y];
	if (w != 0)
		*w = s[WM_OFF_W];
	if (h != 0)
		*h = s[WM_OFF_H];
	bank_pop(saved);
	return 1u;
}

void wm_set_modal(wm_id id, unsigned char on)
{
	unsigned char *s;
	unsigned char saved;

	if (!wm_valid(id))
		return;
	saved = bank_push(g_page);
	s = wm_slot(wm_idx_of(id));
	if (on)
	{
		s[WM_OFF_FLAGS] |= WM_F_MODAL;
		s[WM_OFF_FLAGS] &= (unsigned char)~WM_F_MINIMIZED;
		s[WM_OFF_FLAGS] |= WM_F_VISIBLE;
	}
	else
		s[WM_OFF_FLAGS] &= (unsigned char)~WM_F_MODAL;
	bank_pop(saved);
	if (on)
		wm_bring_front(id);
}

unsigned char wm_is_modal(wm_id id)
{
	if (!wm_valid(id))
		return 0u;
	return (wm_slot_flags(id) & WM_F_MODAL) ? 1u : 0u;
}

wm_id wm_modal_top(void)
{
	unsigned char i;
	unsigned char flags;

	if (!g_inited || g_n == 0u)
		return 0u;
	i = g_n;
	while (i > 0u)
	{
		i--;
		flags = wm_slot_flags(g_z[i]);
		if ((flags & WM_F_VISIBLE) == 0u)
			continue;
		if (flags & WM_F_MINIMIZED)
			continue;
		if (flags & WM_F_MODAL)
			return g_z[i];
	}
	return 0u;
}

wm_id wm_active(void)
{
	return g_active;
}

wm_id wm_next(wm_id id)
{
	unsigned char i;
	wm_id mt;

	mt = wm_modal_top();
	if (mt != 0u)
		return mt; /* cannot cycle away from modal */

	if (g_n == 0u)
		return 0u;
	if (id == 0u)
		return g_z[g_n - 1u];
	for (i = 0u; i < g_n; i++)
	{
		if (g_z[i] == id)
		{
			if (i + 1u < g_n)
				return g_z[i + 1u];
			return g_z[0];
		}
	}
	return g_z[g_n - 1u];
}

void wm_set_desktop_color(unsigned char color)
{
	g_desk_color = color;
}

void wm_set_desktop_char(unsigned char ch)
{
	g_desk_char = ch;
}

void wm_hit_test(unsigned char x, unsigned char y, struct wm_hit *out)
{
	unsigned char i, saved;
	unsigned char *s;
	unsigned char flags, wx, wy, ww, wh;
	unsigned char bx, tlen;
	const char *title;
	wm_id modal;

	out->kind = WM_HIT_NONE;
	out->id = 0;
	out->ctrl_id = 0;

	if (!g_inited)
		return;

	modal = wm_modal_top();

	/* Minimize bar: blocked while a modal is up (cannot restore others). */
	if (y == WM_DESK_H)
	{
		if (modal != 0u)
		{
			out->kind = WM_HIT_DESK;
			return;
		}
		bx = 1u;
		saved = bank_push(g_page);
		for (i = 0u; i < g_n; i++)
		{
			s = wm_slot(wm_idx_of(g_z[i]));
			flags = s[WM_OFF_FLAGS];
			if ((flags & WM_F_VISIBLE) == 0u)
				continue;
			if ((flags & WM_F_MINIMIZED) == 0u)
				continue;

			title = (const char *)&s[WM_OFF_TITLE];
			tlen = 0u;
			while (title[tlen] != 0)
				tlen++;
			if (tlen > 12u)
				tlen = 12u;
			if (bx + tlen + 3u >= WM_SCR_W)
				break;

			if (x >= bx && x < (unsigned char)(bx + tlen + 2u))
			{
				out->kind = WM_HIT_MINBAR;
				out->id = g_z[i];
				bank_pop(saved);
				return;
			}
			bx = (unsigned char)(bx + tlen + 3u);
		}
		bank_pop(saved);
		out->kind = WM_HIT_DESK;
		return;
	}

	/* Windows front ? back. With modal: only that window is hittable. */
	saved = bank_push(g_page);
	i = g_n;
	while (i > 0u)
	{
		i--;
		if (modal != 0u && g_z[i] != modal)
			continue;

		s = wm_slot(wm_idx_of(g_z[i]));
		flags = s[WM_OFF_FLAGS];
		if ((flags & WM_F_VISIBLE) == 0u)
			continue;
		if (flags & WM_F_MINIMIZED)
			continue;

		wx = s[WM_OFF_X];
		wy = s[WM_OFF_Y];
		ww = s[WM_OFF_W];
		wh = s[WM_OFF_H];

		if (x < wx || y < wy)
			continue;
		if (x >= (unsigned char)(wx + ww) || y >= (unsigned char)(wy + wh))
			continue;

		out->id = g_z[i];
		if (y == wy)
		{
			/* title row glyphs */
			if (x == (unsigned char)(wx + 2u))
				out->kind = WM_HIT_CLOSE;
			else if (ww > 8u && x == (unsigned char)(wx + 4u)
				 && (flags & WM_F_MODAL) == 0u)
				out->kind = WM_HIT_MINBTN;
			else
				out->kind = WM_HIT_TITLE;
			bank_pop(saved);
			return;
		}

		bank_pop(saved);
		if (wm_ctrl_hit(out->id, x, y, &out->ctrl_id))
		{
			out->kind = WM_HIT_CTRL;
			return;
		}
		out->kind = WM_HIT_WIN;
		return;
	}
	bank_pop(saved);

	out->kind = WM_HIT_DESK;
}

void wm_redraw(void)
{
	unsigned char i, saved;
	unsigned char *s;

	if (!g_inited)
		return;

	wm_draw_desktop();

	saved = bank_push(g_page);
	for (i = 0u; i < g_n; i++)
	{
		s = wm_slot(wm_idx_of(g_z[i]));
		wm_paint_one(g_z[i], s, (g_z[i] == g_active) ? 1u : 0u);
	}
	bank_pop(saved);

	wm_draw_minbar();
	vtxt_present();
}
