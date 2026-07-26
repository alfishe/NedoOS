#ifndef TDESK_WM_EDIT_H
#define TDESK_WM_EDIT_H

#include "wm_ctrl.h"

/*
 * Simple single-line edit field bound to the window.
 * Buffer lives in caller (or static); edit only paints/handles keys.
 */

#define WM_EDIT_MAX 40

struct wm_edit {
	char *buf;
	unsigned char maxlen; /* capacity including NUL */
	unsigned char len;
	unsigned char cursor;
};

/* buf must be stable while attached. */
wm_ctrl_h wm_edit_add(wm_id win,
		      unsigned char cx, unsigned char cy,
		      unsigned char cw,
		      struct wm_edit *edit);

#endif
