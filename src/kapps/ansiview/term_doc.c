#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <oscalls.h>
#include "term.h"
#include "term_doc.h"

extern void term_putchar_stay(unsigned char ch);

#define TERM_DOC_MAX_LINES 86u

static void term_doc_paint_char(unsigned char vis_y, unsigned char x, unsigned char ch)
{
  if (vis_y == TERM_LAST_ROW && x == TERM_LAST_COL)
  {
    term_putchar_stay(ch);
    return;
  }
  putchar((int)ch);
}

static unsigned char doc_ch[TERM_DOC_MAX_LINES][TERM_COLS];
static unsigned char doc_at[TERM_DOC_MAX_LINES][TERM_COLS];
static unsigned int doc_count;
static unsigned int doc_view;
static unsigned int doc_parse_base;
static unsigned int doc_high_line;
static unsigned int doc_abs_line;
static unsigned char doc_col;
static unsigned char doc_vis_row;
static unsigned char doc_active;
static unsigned char doc_follow;
static unsigned char doc_defer_paint;
static unsigned char doc_canvas;
static unsigned char doc_color;
static unsigned char doc_screen_ok;

static void term_doc_mark_screen_bad(void)
{
  doc_screen_ok = 0u;
}

static void term_doc_mark_screen_ok(void)
{
  doc_screen_ok = 1u;
}

static void term_doc_paint_maybe(void)
{
  if (doc_defer_paint == 0u)
  {
    term_doc_paint();
  }
}

static void term_doc_clear_line(unsigned int line, unsigned char attr)
{
  memset(doc_ch[line], ' ', TERM_COLS);
  memset(doc_at[line], attr, TERM_COLS);
}

static void term_doc_drop_oldest(void)
{
  unsigned int i;

  if (doc_count <= 1u)
  {
    return;
  }
  for (i = 1u; i < doc_count; i++)
  {
    memcpy(doc_ch[i - 1u], doc_ch[i], TERM_COLS);
    memcpy(doc_at[i - 1u], doc_at[i], TERM_COLS);
  }
  doc_count--;
  if (doc_view > 0u)
  {
    doc_view--;
  }
  if (doc_abs_line > 0u)
  {
    doc_abs_line--;
  }
}

static void term_doc_ensure_abs_line(unsigned int line)
{
  if (doc_follow == 0u && line >= TERM_DOC_MAX_LINES)
  {
    return;
  }
  while (doc_count <= line)
  {
    if (doc_count >= TERM_DOC_MAX_LINES)
    {
      if (doc_follow != 0u)
      {
        term_doc_drop_oldest();
        continue;
      }
      return;
    }
    term_doc_clear_line(doc_count, doc_color);
    doc_count++;
  }
}

static void term_doc_sync_view_follow(void)
{
  unsigned int max_view;

  if (doc_follow == 0u)
  {
    return;
  }
  if (doc_count <= TERM_VIEW_ROWS)
  {
    doc_view = 0u;
    return;
  }
  max_view = doc_count - TERM_VIEW_ROWS;
  if (doc_abs_line >= doc_view + TERM_VIEW_ROWS)
  {
    doc_view = doc_abs_line - TERM_VIEW_ROWS + 1u;
  }
  if (doc_view > max_view)
  {
    doc_view = max_view;
  }
}

static void term_doc_note_abs_line(unsigned int line)
{
  if (line > doc_high_line)
  {
    doc_high_line = line;
  }
  term_doc_ensure_abs_line(line);
}

static unsigned int term_doc_max_view(void)
{
  unsigned int lines;

  lines = doc_high_line + 1u;
  if (lines <= TERM_VIEW_ROWS)
  {
    return 0u;
  }
  return lines - TERM_VIEW_ROWS;
}

static void term_doc_vis_to_abs(void)
{
  if (doc_canvas != 0u)
  {
    doc_abs_line = doc_view + (unsigned int)doc_vis_row;
  }
  else
  {
    doc_abs_line = doc_parse_base + (unsigned int)doc_vis_row;
    if (doc_follow == 0u && doc_abs_line >= TERM_DOC_MAX_LINES)
    {
      doc_abs_line = TERM_DOC_MAX_LINES - 1u;
    }
  }
  term_doc_note_abs_line(doc_abs_line);
}

static void term_doc_canvas_scroll_up(void)
{
  unsigned int base;
  unsigned int line;
  unsigned int bottom;

  base = doc_view;
  bottom = base + (unsigned int)TERM_VIEW_ROWS - 1u;
  term_doc_ensure_abs_line(bottom);
  for (line = base; line < bottom; line++)
  {
    memcpy(doc_ch[line], doc_ch[line + 1u], TERM_COLS);
    memcpy(doc_at[line], doc_at[line + 1u], TERM_COLS);
  }
  term_doc_clear_line(bottom, doc_color);
}

void term_doc_begin(void)
{
  doc_active = 1u;
  doc_follow = 0u;
  doc_canvas = 0u;
  doc_defer_paint = 0u;
  doc_color = 0x07u;
  doc_count = 1u;
  doc_view = 0u;
  doc_parse_base = 0u;
  doc_high_line = 0u;
  doc_abs_line = 0u;
  doc_col = 0u;
  doc_vis_row = 0u;
  doc_screen_ok = 0u;
  term_doc_clear_line(0u, doc_color);
}

void term_doc_end(void)
{
  doc_active = 0u;
  doc_follow = 0u;
  doc_canvas = 0u;
}

void term_doc_set_canvas(unsigned char canvas)
{
  doc_canvas = canvas;
}

unsigned char term_doc_active(void)
{
  return doc_active;
}

unsigned char term_doc_content_last_row(void)
{
  return TERM_VIEW_ROWS - 1u;
}

void term_doc_set_follow(unsigned char follow)
{
  doc_follow = follow;
}

void term_doc_set_defer_paint(unsigned char defer)
{
  if (doc_defer_paint != 0u && defer == 0u)
  {
    term_doc_mark_screen_bad();
  }
  doc_defer_paint = defer;
}

void term_doc_goto_top(void)
{
  doc_view = 0u;
  term_doc_mark_screen_bad();
}

static void term_doc_paint_row(unsigned char vis_y, unsigned int src_line)
{
  if (src_line <= doc_high_line && src_line < doc_count)
  {
    unsigned char x;
    unsigned char attr;
    unsigned char prev_attr;
    unsigned char ch;

    prev_attr = doc_at[src_line][0];
    OS_SETXY(0u, vis_y);
    OS_SETCOLOR(prev_attr);
    for (x = 0u; x < TERM_COLS; x++)
    {
      attr = doc_at[src_line][x];
      ch = doc_ch[src_line][x];
      if (attr != prev_attr)
      {
        OS_SETXY(x, vis_y);
        OS_SETCOLOR(attr);
        prev_attr = attr;
      }
      term_doc_paint_char(vis_y, x, ch);
    }
  }
  else
  {
    unsigned char x;

    OS_SETXY(0u, vis_y);
    OS_SETCOLOR(0x07u);
    for (x = 0u; x < TERM_COLS; x++)
    {
      term_doc_paint_char(vis_y, x, (unsigned char)' ');
    }
  }
}

static void term_doc_scroll_screen_step(signed char delta)
{
  if (delta > 0)
  {
    OS_SCROLL_SCREEN_UP(1u);
    term_doc_paint_row(TERM_LAST_ROW, doc_view + (unsigned int)TERM_VIEW_ROWS - 1u);
  }
  else
  {
    OS_SCROLL_SCREEN_DOWN(1u);
    term_doc_paint_row(0u, doc_view);
  }
}

void term_doc_paint(void)
{
  unsigned char vis_y;

  if (doc_active == 0u)
  {
    return;
  }
  for (vis_y = 0u; vis_y < TERM_VIEW_ROWS; vis_y++)
  {
    term_doc_paint_row(vis_y, doc_view + (unsigned int)vis_y);
  }
  term_doc_mark_screen_ok();
}

int term_doc_scroll_view(signed char delta)
{
  unsigned int new_view;
  unsigned int max_view;
  unsigned int old_view;
  unsigned int steps;

  if (doc_active == 0u || delta == 0)
  {
    return 0;
  }
  max_view = term_doc_max_view();
  if (max_view == 0u)
  {
    return 0;
  }
  if (delta < 0)
  {
    if (doc_view == 0u)
    {
      return 0;
    }
    new_view = doc_view - 1u;
  }
  else
  {
    if (doc_view >= max_view)
    {
      return 0;
    }
    new_view = doc_view + 1u;
  }
  old_view = doc_view;
  doc_view = new_view;
  if (doc_defer_paint != 0u)
  {
    return 1;
  }
  if (doc_screen_ok != 0u)
  {
    if (new_view > old_view)
    {
      steps = new_view - old_view;
      while (steps-- != 0u)
      {
        term_doc_scroll_screen_step(1);
      }
      term_doc_mark_screen_ok();
      return 1;
    }
    if (new_view < old_view)
    {
      steps = old_view - new_view;
      while (steps-- != 0u)
      {
        term_doc_scroll_screen_step(-1);
      }
      term_doc_mark_screen_ok();
      return 1;
    }
  }
  term_doc_paint();
  return 1;
}

unsigned char term_doc_can_scroll_up(void)
{
  return (doc_active != 0u && doc_view > 0u) ? 1u : 0u;
}

unsigned char term_doc_can_scroll_down(void)
{
  unsigned int max_view;

  if (doc_active == 0u)
  {
    return 0u;
  }
  max_view = term_doc_max_view();
  return (doc_view < max_view) ? 1u : 0u;
}

static void term_doc_scroll_viewport_up(void)
{
  if (doc_parse_base + TERM_VIEW_ROWS >= TERM_DOC_MAX_LINES)
  {
    return;
  }
  doc_parse_base++;
  term_doc_note_abs_line(doc_parse_base + (unsigned int)TERM_VIEW_ROWS - 1u);
}

void term_doc_cls(unsigned char attr)
{
  unsigned char r;

  doc_color = attr;
  doc_col = 0u;
  doc_vis_row = 0u;
  term_doc_mark_screen_bad();
  if (doc_follow == 0u)
  {
    if (doc_canvas != 0u)
    {
      for (r = 0u; r < TERM_VIEW_ROWS; r++)
      {
        term_doc_clear_line(doc_view + (unsigned int)r, attr);
        term_doc_note_abs_line(doc_view + (unsigned int)r);
      }
      term_doc_paint_maybe();
      return;
    }
    for (r = 0u; r < TERM_VIEW_ROWS; r++)
    {
      term_doc_clear_line(doc_parse_base + (unsigned int)r, attr);
      term_doc_note_abs_line(doc_parse_base + (unsigned int)r);
    }
    term_doc_paint_maybe();
    return;
  }
  doc_count = 1u;
  doc_view = 0u;
  doc_parse_base = 0u;
  doc_high_line = 0u;
  doc_abs_line = 0u;
  term_doc_clear_line(0u, attr);
  term_doc_paint_maybe();
}

void term_doc_set_vis_xy(unsigned char col, unsigned char vis_row)
{
  if (col > TERM_LAST_COL)
  {
    col = TERM_LAST_COL;
  }
  if (vis_row >= TERM_VIEW_ROWS)
  {
    vis_row = TERM_VIEW_ROWS - 1u;
  }
  doc_col = col;
  doc_vis_row = vis_row;
  term_doc_vis_to_abs();
}

void term_doc_get_vis_xy(unsigned char *col, unsigned char *vis_row)
{
  *col = doc_col;
  *vis_row = doc_vis_row;
}

void term_doc_carriage_return(void)
{
  doc_col = 0u;
  term_doc_vis_to_abs();
}

void term_doc_put_atm(unsigned char ch)
{
  term_doc_vis_to_abs();
  doc_ch[doc_abs_line][doc_col] = ch;
  doc_at[doc_abs_line][doc_col] = doc_color;
  if (doc_col < TERM_LAST_COL)
  {
    doc_col++;
    return;
  }
  term_doc_newline();
}

void term_doc_newline(void)
{
  unsigned int old_view;

  doc_col = 0u;
  if (doc_vis_row + 1u < TERM_VIEW_ROWS)
  {
    doc_vis_row++;
    term_doc_vis_to_abs();
    return;
  }
  old_view = doc_view;
  if (doc_follow == 0u)
  {
    if (doc_canvas != 0u)
    {
      term_doc_canvas_scroll_up();
      doc_col = 0u;
      doc_vis_row = TERM_VIEW_ROWS - 1u;
      term_doc_vis_to_abs();
      return;
    }
    term_doc_scroll_viewport_up();
    doc_vis_row = TERM_VIEW_ROWS - 1u;
    return;
  }
  doc_abs_line = doc_parse_base + (unsigned int)TERM_VIEW_ROWS;
  if (doc_abs_line >= TERM_DOC_MAX_LINES)
  {
    doc_abs_line = TERM_DOC_MAX_LINES - 1u;
  }
  term_doc_note_abs_line(doc_abs_line);
  doc_vis_row = TERM_VIEW_ROWS - 1u;
  term_doc_sync_view_follow();
  if (doc_defer_paint == 0u)
  {
    if (doc_screen_ok != 0u && doc_view == old_view + 1u)
    {
      term_doc_scroll_screen_step(1);
    }
    else if (doc_screen_ok != 0u && doc_view == old_view)
    {
      term_doc_scroll_screen_step(1);
    }
    else
    {
      term_doc_paint();
    }
  }
}

void term_doc_backspace(void)
{
  if (doc_col == 0u)
  {
    return;
  }
  doc_col--;
  term_doc_vis_to_abs();
  doc_ch[doc_abs_line][doc_col] = ' ';
  doc_at[doc_abs_line][doc_col] = doc_color;
}

void term_doc_fill_spaces(unsigned char count)
{
  while (count > 0u)
  {
    term_doc_put_atm(' ');
    count--;
  }
}

void term_doc_erase_line(unsigned char mode)
{
  unsigned char col;

  term_doc_vis_to_abs();
  col = doc_col;
  if (mode == 0u)
  {
    term_doc_fill_spaces((unsigned char)(TERM_COLS - col));
    doc_col = col;
  }
  else if (mode == 1u)
  {
    doc_col = 0u;
    term_doc_fill_spaces((unsigned char)(col + 1u));
    doc_col = col;
  }
  else if (mode == 2u)
  {
    doc_col = 0u;
    term_doc_fill_spaces(TERM_COLS);
    doc_col = 0u;
  }
}

void term_doc_erase_display(unsigned char mode)
{
  unsigned char saved_col;
  unsigned char saved_vis_row;
  unsigned char r;

  saved_col = doc_col;
  saved_vis_row = doc_vis_row;
  if (mode == 0u)
  {
    term_doc_erase_line(0u);
    for (r = (unsigned char)(doc_vis_row + 1u); r < TERM_VIEW_ROWS; r++)
    {
      doc_vis_row = r;
      term_doc_vis_to_abs();
      doc_col = 0u;
      term_doc_fill_spaces(TERM_COLS);
    }
  }
  else if (mode == 1u)
  {
    for (r = 0u; r < doc_vis_row; r++)
    {
      doc_vis_row = r;
      term_doc_vis_to_abs();
      doc_col = 0u;
      term_doc_fill_spaces(TERM_COLS);
    }
    doc_vis_row = saved_vis_row;
    term_doc_vis_to_abs();
    doc_col = 0u;
    term_doc_erase_line(1u);
  }
  else if (mode == 2u)
  {
    term_doc_cls(doc_color);
    return;
  }
  doc_col = saved_col;
  doc_vis_row = saved_vis_row;
  term_doc_vis_to_abs();
  term_doc_mark_screen_bad();
  term_doc_paint_maybe();
}

void term_doc_cursor_up(unsigned char count)
{
  if (count == 0u)
  {
    count = 1u;
  }
  if (count > doc_vis_row)
  {
    doc_vis_row = 0u;
  }
  else
  {
    doc_vis_row = (unsigned char)(doc_vis_row - count);
  }
  term_doc_vis_to_abs();
}

void term_doc_cursor_down(unsigned char count)
{
  unsigned char max_down;

  if (count == 0u)
  {
    count = 1u;
  }
  max_down = (unsigned char)(TERM_VIEW_ROWS - 1u - doc_vis_row);
  if (count > max_down)
  {
    doc_vis_row = TERM_VIEW_ROWS - 1u;
  }
  else
  {
    doc_vis_row = (unsigned char)(doc_vis_row + count);
  }
  term_doc_vis_to_abs();
}

void term_doc_cursor_left(unsigned char count)
{
  if (count == 0u)
  {
    count = 1u;
  }
  if (count > doc_col)
  {
    doc_col = 0u;
  }
  else
  {
    doc_col = (unsigned char)(doc_col - count);
  }
}

void term_doc_cursor_right(unsigned char count)
{
  unsigned char max_right;

  if (count == 0u)
  {
    count = 1u;
  }
  max_right = (unsigned char)(TERM_LAST_COL - doc_col);
  if (count > max_right)
  {
    doc_col = TERM_LAST_COL;
  }
  else
  {
    doc_col = (unsigned char)(doc_col + count);
  }
}

static void term_doc_shift_region_down(void)
{
  unsigned int top;
  unsigned int bottom;
  unsigned int line;

  top = doc_view;
  bottom = doc_view + (unsigned int)TERM_VIEW_ROWS - 1u;
  if (bottom >= doc_count)
  {
    bottom = doc_count - 1u;
  }
  for (line = bottom; line > top; line--)
  {
    memcpy(doc_ch[line], doc_ch[line - 1u], TERM_COLS);
    memcpy(doc_at[line], doc_at[line - 1u], TERM_COLS);
  }
  term_doc_clear_line(top, doc_color);
}

static void term_doc_shift_region_up(void)
{
  unsigned int top;
  unsigned int bottom;
  unsigned int line;

  top = doc_view;
  bottom = doc_view + (unsigned int)TERM_VIEW_ROWS - 1u;
  term_doc_ensure_abs_line(bottom);
  for (line = top; line < bottom; line++)
  {
    memcpy(doc_ch[line], doc_ch[line + 1u], TERM_COLS);
    memcpy(doc_at[line], doc_at[line + 1u], TERM_COLS);
  }
  term_doc_clear_line(bottom, doc_color);
}

void term_doc_scroll_up(unsigned char count)
{
  while (count > 0u)
  {
    if (doc_follow == 0u)
    {
      if (doc_canvas != 0u)
      {
        term_doc_canvas_scroll_up();
        term_doc_mark_screen_bad();
      }
      else
      {
        term_doc_scroll_viewport_up();
        term_doc_mark_screen_bad();
      }
    }
    else
    {
      term_doc_shift_region_up();
      if (doc_defer_paint == 0u && doc_screen_ok != 0u)
      {
        term_doc_scroll_screen_step(1);
      }
      else
      {
        term_doc_mark_screen_bad();
      }
    }
    count--;
  }
  term_doc_vis_to_abs();
  if (doc_defer_paint == 0u && doc_screen_ok == 0u)
  {
    term_doc_paint();
  }
}

void term_doc_scroll_down(unsigned char count)
{
  while (count > 0u)
  {
    if (doc_follow == 0u)
    {
      if (doc_parse_base > 0u)
      {
        doc_parse_base--;
      }
      term_doc_mark_screen_bad();
    }
    else
    {
      term_doc_shift_region_down();
      if (doc_defer_paint == 0u && doc_screen_ok != 0u)
      {
        term_doc_scroll_screen_step(-1);
      }
      else
      {
        term_doc_mark_screen_bad();
      }
    }
    count--;
  }
  term_doc_vis_to_abs();
  if (doc_defer_paint == 0u && doc_screen_ok == 0u)
  {
    term_doc_paint();
  }
}

void term_doc_set_color(unsigned char attr)
{
  doc_color = attr;
  OS_SETCOLOR(attr);
}
