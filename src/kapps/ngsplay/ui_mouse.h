#ifndef UI_MOUSE_H
#define UI_MOUSE_H

/* Text-mode soft mouse (term.com style): fixed-point + signed wrap deltas. */

void ui_mouse_init(void);
void ui_mouse_hide(void);
void ui_mouse_show(void);
/* Call after OS_GETKEY() while focused; uses mouse_x/y/btns globals. */
void ui_mouse_poll(void);

/* Hit results for click handlers in main. */
#define UI_MOUSE_HIT_NONE 0
#define UI_MOUSE_HIT_LIST 1
#define UI_MOUSE_HIT_BTN0 2 /* prev */
#define UI_MOUSE_HIT_BTN1 3 /* next */
#define UI_MOUSE_HIT_BTN2 4 /* stop */
#define UI_MOUSE_HIT_BTN3 5 /* pause */

unsigned char ui_mouse_hit(void);
unsigned char ui_mouse_list_row(void); /* valid if HIT_LIST */
unsigned char ui_mouse_lmb_click(void); /* 1 = LMB pressed edge this poll */
signed char ui_mouse_wheel_delta(void); /* signed notches, 0 = none */

#endif
