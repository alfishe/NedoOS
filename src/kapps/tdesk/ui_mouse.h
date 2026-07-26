#ifndef TDESK_UI_MOUSE_H
#define TDESK_UI_MOUSE_H

/*
 * Soft mouse for text mode ? same model as ngsplay / term.com:
 * Kempston 8-bit wrap deltas, fixed-point cell position, attr cursor.
 */

void ui_mouse_init(void);
void ui_mouse_hide(void);
void ui_mouse_show(void);
/* Call after OS_GETKEY() while focused; uses mouse_x/y/btns globals. */
void ui_mouse_poll(void);

unsigned char ui_mouse_x(void);
unsigned char ui_mouse_y(void);
unsigned char ui_mouse_lmb_click(void); /* 1 = LMB pressed edge this poll */
unsigned char ui_mouse_lmb_down(void);  /* 1 = LMB currently held */
signed char ui_mouse_wheel_delta(void);

#endif
