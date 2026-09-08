#ifndef TERM_H
#define TERM_H

#define TERM_COLS 80u
#define TERM_ROWS 25u
#define TERM_LAST_ROW 24u
#define TERM_LAST_COL 79u

/* ATM attribute: bits2..0 ink, bits5..3 paper, bit6 bright ink, bit7 bright paper. */
#define TERM_ATTR_BRIGHT_INK  0x40u
#define TERM_ATTR_BRIGHT_PAPER 0x80u

extern const unsigned char cp437toatm[256];

void term_init(void);
void term_set_wire_cp437(void);
void term_set_wire_cp866(void);

unsigned char term_wire_is_cp866(void);
void term_cls(unsigned char attr);
void term_set_color(unsigned char attr);
unsigned char term_get_color(void);
void term_set_xy(unsigned char col, unsigned char row);
void term_get_xy(unsigned char *col, unsigned char *row);
void term_putchar(unsigned char cp437);
void term_scroll_up(unsigned char count);
void term_scroll_down(unsigned char count);
int term_feed(unsigned char b); /* 0 = stop (SAUCE/0x1A marker) */
int term_feed_buf(const unsigned char *buf, unsigned int n);
void term_drain_replies(void (*emit)(unsigned char b));
unsigned char term_has_replies(void);
unsigned char term_take_ed2_needs_cr(void);
void term_palette_begin(void);
void term_palette_restore(void);
void term_set_ansi_palette(void);
/* After key_redraw: sync HW cursor to tracked position and redraw caret. */
void term_focus_redraw(void);

#define TERM_CURS_HOLD_RX  1u
#define TERM_CURS_HOLD_ZM  2u
#define TERM_CURS_HOLD_DEC 4u

void term_cursor_hide(void);
void term_cursor_show(void);
void term_cursor_hold_or(unsigned char mask);
void term_cursor_hold_and_not(unsigned char mask);

#endif
