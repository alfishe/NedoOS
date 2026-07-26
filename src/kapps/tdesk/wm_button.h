#ifndef TDESK_WM_BUTTON_H
#define TDESK_WM_BUTTON_H

#include "wm_ctrl.h"

typedef void (*wm_btn_fn)(wm_id win, unsigned char tag, void *user);

/* Attaches a button that paints/moves with the window. */
wm_ctrl_h wm_button_add(wm_id win,
			unsigned char cx, unsigned char cy,
			unsigned char cw, unsigned char ch,
			const char *label,
			unsigned char tag,
			wm_btn_fn on_click,
			void *user);

#endif
