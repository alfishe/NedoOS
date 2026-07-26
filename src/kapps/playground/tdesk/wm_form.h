#ifndef TDESK_WM_FORM_H
#define TDESK_WM_FORM_H

#include "wm_button.h"

/*
 * Compact form resource (.frm blob).
 * Layout ? see winApi.txt ?6. Actions are NOT in the file: bind by tag.
 */

#define WM_FORM_MAGIC    0x46  /* 'F' */
#define WM_FORM_VER      1
#define WM_FORM_F_SHADOW 0x01
#define WM_FORM_F_MODAL  0x02

/* Max size for the built-in staging buffer (open_file). */
#define WM_FORM_MAX      256

struct wm_form_bind {
	unsigned char ctrl_id;
	wm_btn_fn fn;
	void *user;
};

/* Open an already-resident blob (CODE or RAM). Returns wm_id or 0. */
wm_id wm_form_open(const unsigned char *res,
		   const struct wm_form_bind *binds,
		   unsigned char nbinds);

/*
 * Load .frm from disk into caller buffer.
 * Returns byte count on success, 0 on error (open/read/too big/bad magic).
 * Buffer stays yours - call wm_form_open(buf, ...) when ready.
 *
 * Open check: ((int)fp) & 0xFF  ? NOT fp==0 (handle 0 is valid on NedoOS).
 */
unsigned int wm_form_load(const char *path,
			  unsigned char *buf, unsigned int maxlen);

/*
 * Load into buf then open immediately (one-shot before showing).
 * Same return as wm_form_open.
 */
wm_id wm_form_open_buf(const char *path,
		       unsigned char *buf, unsigned int maxlen,
		       const struct wm_form_bind *binds,
		       unsigned char nbinds);

/*
 * Load via internal WM_FORM_MAX staging buffer, then open.
 * Staging is overwritten on the next open_file/load_stage call.
 */
wm_id wm_form_open_file(const char *path,
			const struct wm_form_bind *binds,
			unsigned char nbinds);

/* Pointer to last successful open_file staging blob (or 0). */
const unsigned char *wm_form_stage(void);

#endif
