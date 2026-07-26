#include <oscalls.h>
#include "vtxt.h"
#include "wm_label.h"

#define BR_INK 0x40
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))
#define COL_LABEL MKCOLOR(BR_INK, PAPER_BLUE, INK_CYAN)

#define LAB_POOL 24

struct lab_data {
	unsigned char used;
	unsigned char color;
	const char *text;
};

static struct lab_data g_labs[LAB_POOL];

static struct lab_data *lab_alloc(void)
{
	unsigned char i;

	for (i = 0u; i < LAB_POOL; i++)
	{
		if (!g_labs[i].used)
		{
			g_labs[i].used = 1u;
			return &g_labs[i];
		}
	}
	return 0;
}

static void lab_destroy(void *data)
{
	struct lab_data *l;

	l = (struct lab_data *)data;
	if (l != 0)
		l->used = 0u;
}

static void lab_paint(const struct wm_ctrl_draw *d)
{
	struct lab_data *l;
	unsigned char i, n;
	const char *t;

	l = (struct lab_data *)d->data;
	if (l == 0)
		return;
	t = l->text;
	if (t == 0)
		return;
	n = 0u;
	while (t[n] != 0 && n < d->cw)
		n++;
	for (i = 0u; i < n; i++)
		vtxt_putc((unsigned char)(d->ax + i), d->ay,
			  (unsigned char)t[i], l->color);
}

static const struct wm_ctrl_ops g_lab_ops = {
	lab_paint,
	0,
	0,
	lab_destroy
};

wm_ctrl_h wm_label_add(wm_id win,
		       unsigned char cx, unsigned char cy,
		       unsigned char cw, unsigned char ch,
		       const char *text,
		       unsigned char color)
{
	struct lab_data *l;
	wm_ctrl_h h;

	l = lab_alloc();
	if (l == 0)
		return 0u;
	l->text = text;
	l->color = (color == 0u) ? COL_LABEL : color;

	h = wm_ctrl_attach(win, cx, cy,
			   (cw == 0u) ? 1u : cw,
			   (ch == 0u) ? 1u : ch,
			   0u, 0u, &g_lab_ops, l);
	if (h == 0u)
		l->used = 0u;
	return h;
}
