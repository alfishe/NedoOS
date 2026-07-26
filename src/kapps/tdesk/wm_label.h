#ifndef TDESK_WM_LABEL_H
#define TDESK_WM_LABEL_H

#include "wm_ctrl.h"

/* Static text bound to the window (moves with it). Not focusable. */
wm_ctrl_h wm_label_add(wm_id win,
		       unsigned char cx, unsigned char cy,
		       unsigned char cw, unsigned char ch,
		       const char *text,
		       unsigned char color);

#endif
