#include "term_doc.h"

void term_doc_begin(void)
{
}

void term_doc_end(void)
{
}

unsigned char term_doc_active(void)
{
  return 0u;
}

unsigned char term_doc_content_last_row(void)
{
  return 0u;
}

void term_doc_paint(void)
{
}

int term_doc_scroll_view(signed char delta)
{
  (void)delta;
  return 0;
}

unsigned char term_doc_can_scroll_up(void)
{
  return 0u;
}

unsigned char term_doc_can_scroll_down(void)
{
  return 0u;
}

void term_doc_set_follow(unsigned char follow)
{
  (void)follow;
}

void term_doc_set_defer_paint(unsigned char defer)
{
  (void)defer;
}

void term_doc_goto_top(void)
{
}

void term_doc_set_color(unsigned char attr)
{
  (void)attr;
}

void term_doc_cls(unsigned char attr)
{
  (void)attr;
}

void term_doc_set_vis_xy(unsigned char col, unsigned char vis_row)
{
  (void)col;
  (void)vis_row;
}

void term_doc_get_vis_xy(unsigned char *col, unsigned char *vis_row)
{
  if (col != 0)
  {
    *col = 0u;
  }
  if (vis_row != 0)
  {
    *vis_row = 0u;
  }
}

void term_doc_put_atm(unsigned char ch)
{
  (void)ch;
}

void term_doc_newline(void)
{
}

void term_doc_backspace(void)
{
}

void term_doc_fill_spaces(unsigned char count)
{
  (void)count;
}

void term_doc_erase_line(unsigned char mode)
{
  (void)mode;
}

void term_doc_erase_display(unsigned char mode)
{
  (void)mode;
}

void term_doc_cursor_up(unsigned char count)
{
  (void)count;
}

void term_doc_cursor_down(unsigned char count)
{
  (void)count;
}

void term_doc_cursor_left(unsigned char count)
{
  (void)count;
}

void term_doc_cursor_right(unsigned char count)
{
  (void)count;
}

void term_doc_scroll_up(unsigned char count)
{
  (void)count;
}

void term_doc_scroll_down(unsigned char count)
{
  (void)count;
}
