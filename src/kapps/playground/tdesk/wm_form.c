#include <osfs.h>
#include "wm_form.h"
#include "wm_button.h"
#include "wm_label.h"

#define WM_CTRL_BUTTON 1
#define WM_CTRL_LABEL  2

/* Internal staging for wm_form_open_file ? not for long-term storage. */
static unsigned char g_stage[WM_FORM_MAX];
static unsigned int g_stage_len;

static const unsigned char *skip_zstr(const unsigned char *p)
{
	while (*p != 0)
		p++;
	return p + 1;
}

static void bind_ctrl(unsigned char ctrl_id,
		      const struct wm_form_bind *binds, unsigned char nbinds,
		      wm_btn_fn *fn_out, void **user_out)
{
	unsigned char i;

	*fn_out = 0;
	*user_out = 0;
	if (binds == 0)
		return;
	for (i = 0u; i < nbinds; i++)
	{
		if (binds[i].ctrl_id == ctrl_id)
		{
			*fn_out = binds[i].fn;
			*user_out = binds[i].user;
			return;
		}
	}
}

static unsigned char form_hdr_ok(const unsigned char *res)
{
	if (res == 0)
		return 0u;
	if (res[0] != WM_FORM_MAGIC || res[1] != WM_FORM_VER)
		return 0u;
	return 1u;
}

wm_id wm_form_open(const unsigned char *res,
		   const struct wm_form_bind *binds,
		   unsigned char nbinds)
{
	const unsigned char *p;
	wm_id id;
	unsigned char x, y, w, h, color, flags, nctrl, i;
	unsigned char ctype, cid, cx, cy, cw, ch, ccol, cflags;
	const char *title;
	const char *body;
	const char *label;
	wm_btn_fn fn;
	void *user;
	unsigned char want_focus;
	unsigned char focus_id;

	if (!form_hdr_ok(res))
		return 0u;

	x = res[2];
	y = res[3];
	w = res[4];
	h = res[5];
	color = res[6];
	flags = res[7];
	nctrl = res[8];
	p = res + 9;

	title = (const char *)p;
	p = skip_zstr(p);
	body = (const char *)p;
	p = skip_zstr(p);

	id = wm_create(x, y, w, h, title, color);
	if (id == 0u)
		return 0u;

	wm_set_body(id, body);
	if (flags & WM_FORM_F_MODAL)
		wm_set_modal(id, 1u);

	want_focus = 0u;
	focus_id = 0u;

	for (i = 0u; i < nctrl; i++)
	{
		ctype = p[0];
		cid = p[1];
		cx = p[2];
		cy = p[3];
		cw = p[4];
		ch = p[5];
		ccol = p[6];
		cflags = p[7];
		p += 8;
		label = (const char *)p;
		p = skip_zstr(p);

		if (ctype == WM_CTRL_LABEL)
		{
			wm_label_add(id, cx, cy, cw, ch, label, ccol);
		}
		else if (ctype == WM_CTRL_BUTTON)
		{
			bind_ctrl(cid, binds, nbinds, &fn, &user);
			wm_button_add(id, cx, cy, cw, ch, label, cid, fn, user);
			if ((cflags & 0x01u) != 0u)
			{
				want_focus = 1u;
				focus_id = cid;
			}
		}
	}

	if (want_focus)
		wm_ctrl_focus_tag(id, focus_id);
	else
		wm_ctrl_focus_first(id);

	return id;
}

unsigned int wm_form_load(const char *path,
			  unsigned char *buf, unsigned int maxlen)
{
	FILE *fp;
	unsigned long fsz;
	unsigned int n, want;

	if (path == 0 || buf == 0 || maxlen < 9u)
		return 0u;

	fp = OS_OPENHANDLE((unsigned char *)path, 0x80u);
	/* NedoOS: HL = handle<<8 | errno. OK when low byte == 0; handle may be 0.
	 * NEVER test fp == 0 / !fp ? that rejects a valid zero handle. */
	if (((int)fp) & 0xFF)
		return 0u;

	fsz = OS_GETFILESIZE(fp);
	if (fsz == 0UL || fsz > (unsigned long)maxlen)
	{
		OS_CLOSEHANDLE(fp);
		return 0u;
	}

	want = (unsigned int)fsz;
	n = OS_READHANDLE(buf, fp, want);
	OS_CLOSEHANDLE(fp);

	if (n < 9u || n != want)
		return 0u;
	if (!form_hdr_ok(buf))
		return 0u;

	return n;
}

wm_id wm_form_open_buf(const char *path,
		       unsigned char *buf, unsigned int maxlen,
		       const struct wm_form_bind *binds,
		       unsigned char nbinds)
{
	if (wm_form_load(path, buf, maxlen) == 0u)
		return 0u;
	return wm_form_open(buf, binds, nbinds);
}

wm_id wm_form_open_file(const char *path,
			const struct wm_form_bind *binds,
			unsigned char nbinds)
{
	g_stage_len = wm_form_load(path, g_stage, WM_FORM_MAX);
	if (g_stage_len == 0u)
		return 0u;
	return wm_form_open(g_stage, binds, nbinds);
}

const unsigned char *wm_form_stage(void)
{
	if (g_stage_len == 0u)
		return 0;
	return g_stage;
}
