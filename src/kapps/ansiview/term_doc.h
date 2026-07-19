#ifndef TERM_DOC_H
#define TERM_DOC_H

#define TERM_VIEW_ROWS 25u

void term_doc_begin(void);
void term_doc_end(void);
void term_doc_set_canvas(unsigned char canvas);
unsigned char term_doc_active(void);
unsigned char term_doc_content_last_row(void);

void term_doc_paint(void);
int term_doc_scroll_view(signed char delta);
unsigned char term_doc_can_scroll_up(void);
unsigned char term_doc_can_scroll_down(void);
void term_doc_set_follow(unsigned char follow);
void term_doc_set_defer_paint(unsigned char defer);
void term_doc_goto_top(void);
void term_doc_set_color(unsigned char attr);

void term_doc_cls(unsigned char attr);
void term_doc_set_vis_xy(unsigned char col, unsigned char vis_row);
void term_doc_get_vis_xy(unsigned char *col, unsigned char *vis_row);
void term_doc_carriage_return(void);
void term_doc_put_atm(unsigned char ch);
void term_doc_newline(void);
void term_doc_backspace(void);
void term_doc_fill_spaces(unsigned char count);
void term_doc_erase_line(unsigned char mode);
void term_doc_erase_display(unsigned char mode);
void term_doc_cursor_up(unsigned char count);
void term_doc_cursor_down(unsigned char count);
void term_doc_cursor_left(unsigned char count);
void term_doc_cursor_right(unsigned char count);
void term_doc_scroll_up(unsigned char count);
void term_doc_scroll_down(unsigned char count);

#endif
