#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include "term.h"
#include "term_doc.h"

extern void term_palette_begin(void);
extern void term_palette_restore(void);

/* atelnet: -DTERM_NO_DOC ? no doc canvas; kill call tax + undefined refs. */
#ifdef TERM_NO_DOC
#define TERM_DOC_ON() 0
#define term_doc_cls(a) ((void)0)
#define term_doc_set_color(a) ((void)0)
#define term_doc_set_vis_xy(c, r) ((void)0)
#define term_doc_get_vis_xy(c, r) ((void)0)
#define term_doc_fill_spaces(n) ((void)0)
#define term_doc_newline() ((void)0)
#define term_doc_backspace() ((void)0)
#define term_doc_put_atm(ch) ((void)0)
#define term_doc_carriage_return() ((void)0)
#define term_doc_scroll_up(n) ((void)0)
#define term_doc_scroll_down(n) ((void)0)
#define term_doc_erase_line(m) ((void)0)
#define term_doc_erase_display(m) ((void)0)
#define term_doc_cursor_up(n) ((void)0)
#define term_doc_cursor_down(n) ((void)0)
#define term_doc_cursor_left(n) ((void)0)
#define term_doc_cursor_right(n) ((void)0)
#define term_doc_end() ((void)0)
#define term_doc_content_last_row() TERM_LAST_ROW
#else
#define TERM_DOC_ON() (term_doc_active() != 0u)
#endif

static unsigned char term_last_row(void)
{
#ifdef TERM_NO_DOC
  return TERM_LAST_ROW;
#else
  if (TERM_DOC_ON())
  {
    return term_doc_content_last_row();
  }
  return TERM_LAST_ROW;
#endif
}

static unsigned char term_color = 0x07u;
static unsigned char term_col;
static unsigned char term_row;
static unsigned char term_literal_next;
static unsigned char term_wire_cp866;

#define ANSI_MAX_ARGS 8u
#define ST_TEXT 0u
#define ST_ESC  1u
#define ST_CSI  2u

static unsigned char ansi_state;
static unsigned char ansi_args[ANSI_MAX_ARGS];
static unsigned char ansi_argc;
static unsigned char ansi_private_csi;

static unsigned char saved_col;
static unsigned char saved_row;
static unsigned char saved_color;
static unsigned char has_saved;
static unsigned char term_cpr_fix_corner;

#define TERM_REPLY_MAX 24u
static unsigned char term_reply[TERM_REPLY_MAX];
static unsigned char term_reply_len;
static unsigned char term_hw_sync;
static unsigned char g_ed2_needs_cr;

static unsigned char g_curs_hold;
static unsigned char g_curs_drawn;
static unsigned char g_curs_x;
static unsigned char g_curs_y;
static unsigned char g_curs_saved_attr;

static unsigned char term_curs_inv_attr(unsigned char attr)
{
  return (unsigned char)(((attr & 7u) << 3) | ((attr >> 3) & 7u) | (attr & 0xC0u));
}

static void term_reply_push(unsigned char b)
{
  if (term_reply_len < TERM_REPLY_MAX)
  {
    term_reply[term_reply_len++] = b;
  }
}

static void term_reply_dec(unsigned char v)
{
  if (v >= 100u)
  {
    term_reply_push((unsigned char)('0' + (v / 100u)));
  }
  if (v >= 10u)
  {
    term_reply_push((unsigned char)('0' + ((v / 10u) % 10u)));
  }
  term_reply_push((unsigned char)('0' + (v % 10u)));
}

static void term_reply_corner_cpr(void)
{
  term_row = TERM_LAST_ROW;
  term_col = TERM_LAST_COL;
  term_reply_push(0x1Bu);
  term_reply_push('[');
  term_reply_dec(TERM_ROWS);
  term_reply_push(';');
  term_reply_dec(TERM_COLS);
  term_reply_push('R');
}

static void term_reply_dsr(void)
{
  if (term_cpr_fix_corner > 0u)
  {
    term_cpr_fix_corner--;
    term_reply_corner_cpr();
    return;
  }
  /* Use tracked cursor (Synchronet moves to 80x25 before ESC[6n). */
  term_reply_push(0x1Bu);
  term_reply_push('[');
  if (ansi_private_csi != 0u)
  {
    term_reply_push('?');
  }
  term_reply_dec((unsigned char)(term_row + 1u));
  term_reply_push(';');
  term_reply_dec((unsigned char)(term_col + 1u));
  term_reply_push('R');
}

static void term_reply_size_cpr(void)
{
  term_reply_corner_cpr();
}

void term_drain_replies(void (*emit)(unsigned char b))
{
  unsigned char i;

  if (emit == 0)
  {
    term_reply_len = 0u;
    return;
  }
  for (i = 0u; i < term_reply_len; i++)
  {
    emit(term_reply[i]);
  }
  term_reply_len = 0u;
}

unsigned char term_has_replies(void)
{
  return term_reply_len > 0u;
}

static void term_sync_hw(void)
{
  OS_SETXY(term_col, term_row);
  term_hw_sync = 1u;
}

static void term_desync_hw(void)
{
  term_hw_sync = 0u;
}

static void term_pull_hw_xy(void)
{
  term_get_xy(&term_col, &term_row);
  term_hw_sync = 1u;
}

static void term_curs_invalidate(void)
{
  term_cursor_hide();
}

void term_cursor_hide(void)
{
  if (g_curs_drawn == 0u)
  {
    return;
  }
  if (TERM_DOC_ON())
  {
    g_curs_drawn = 0u;
    return;
  }
  OS_SETXY(g_curs_x, g_curs_y);
  OS_PRATTR(g_curs_saved_attr);
  g_curs_drawn = 0u;
}

void term_cursor_show(void)
{
  unsigned char cx;
  unsigned char cy;
  unsigned char cell_attr;

  if (g_curs_hold != 0u || TERM_DOC_ON())
  {
    return;
  }
  if (g_curs_drawn != 0u)
  {
    return;
  }
  term_get_xy(&cx, &cy);
  g_curs_x = cx;
  g_curs_y = cy;
  OS_SETXY(cx, cy);
  cell_attr = OS_GETATTR();
  g_curs_saved_attr = cell_attr;
  OS_PRATTR(term_curs_inv_attr(cell_attr));
  g_curs_drawn = 1u;
}

void term_cursor_hold_or(unsigned char mask)
{
  g_curs_hold = (unsigned char)(g_curs_hold | mask);
  term_cursor_hide();
}

void term_cursor_hold_and_not(unsigned char mask)
{
  g_curs_hold = (unsigned char)(g_curs_hold & (unsigned char)~mask);
  term_cursor_show();
}

static unsigned char term_safe_cls_attr(unsigned char attr)
{
  if (attr == 0x00u)
  {
    return 0x07u;
  }
  return attr;
}

static void term_reset_cpr_fix(void)
{
  term_cpr_fix_corner = 0u;
}

static unsigned char term_erase_attr(void)
{
  unsigned char c;

  c = term_color;
  if (c == 0x00u)
  {
    return 0x07u;
  }
  if ((c & 0x07u) == 0u && (c & 0x38u) == 0u)
  {
    return 0x07u;
  }
  return c;
}

unsigned char term_take_ed2_needs_cr(void)
{
  unsigned char v;

  v = g_ed2_needs_cr;
  g_ed2_needs_cr = 0u;
  return v;
}

void term_init(void)
{
  term_color = 0x07u;
  term_col = 0u;
  term_row = 0u;
  ansi_state = ST_TEXT;
  ansi_argc = 0u;
  ansi_private_csi = 0u;
  has_saved = 0u;
  term_reply_len = 0u;
  term_literal_next = 0u;
  term_wire_cp866 = 0u;
  term_cpr_fix_corner = 0u;
#ifndef TERM_NO_DOC
  term_doc_end();
#endif
  term_desync_hw();
  g_ed2_needs_cr = 0u;
  g_curs_hold = 0u;
  g_curs_drawn = 0u;
}

void term_set_wire_cp437(void)
{
  term_wire_cp866 = 0u;
}

void term_set_wire_cp866(void)
{
  term_wire_cp866 = 1u;
}

unsigned char term_wire_is_cp866(void)
{
  return term_wire_cp866;
}
#define term_emit_bdos(bdos_ch) putchar((int)(unsigned char)(bdos_ch))

/* After BDOS putchar of a printable: track cursor without OS_GETXY. */
static void term_soft_advance(void)
{
  if (term_col < TERM_LAST_COL)
  {
    term_col++;
  }
  else
  {
    term_col = 0u;
    if (term_row < TERM_LAST_ROW)
    {
      term_row++;
    }
  }
  term_hw_sync = 1u;
}

void term_cls(unsigned char attr)
{
  term_curs_invalidate();
  term_reset_cpr_fix();
  term_color = attr;
  if (TERM_DOC_ON())
  {
    term_doc_cls(attr);
    return;
  }
  OS_CLS(term_safe_cls_attr(attr));
  OS_SETCOLOR(term_safe_cls_attr(attr));
  term_col = 0u;
  term_row = 0u;
  term_hw_sync = 1u;
}

void term_set_color(unsigned char attr)
{
  if (term_color == attr)
  {
    return;
  }
  term_color = attr;
  if (TERM_DOC_ON())
  {
    term_doc_set_color(attr);
    return;
  }
  OS_SETCOLOR(attr);
}

unsigned char term_get_color(void)
{
  return term_color;
}

void term_set_xy(unsigned char col, unsigned char row)
{
  unsigned char old_col;
  unsigned char old_row;

  old_col = term_col;
  old_row = term_row;
  if (col > TERM_LAST_COL)
  {
    col = TERM_LAST_COL;
  }
  if (row > term_last_row())
  {
    row = term_last_row();
  }
  if (col != old_col || row != old_row)
  {
    term_curs_invalidate();
  }
  term_col = col;
  term_row = row;
  if (TERM_DOC_ON())
  {
    term_doc_set_vis_xy(col, row);
    return;
  }
  if (term_hw_sync != 0u && col == old_col && row == old_row)
  {
    return;
  }
  term_sync_hw();
}

void term_get_xy(unsigned char *col, unsigned char *row)
{
  unsigned int yx;

  if (TERM_DOC_ON())
  {
    term_doc_get_vis_xy(col, row);
    term_col = *col;
    term_row = *row;
    return;
  }

  yx = OS_GETXY();
  *col = (unsigned char)(yx & 0xFFu);
  *row = (unsigned char)((yx >> 8) & 0xFFu);
  term_col = *col;
  term_row = *row;
}

static void term_fill_spaces(unsigned char count)
{
  unsigned char i;
  unsigned char erase;

  if (TERM_DOC_ON())
  {
    term_doc_fill_spaces(count);
    return;
  }

  erase = term_erase_attr();
  if (erase != term_color)
  {
    OS_SETCOLOR(erase);
  }
  for (i = 0u; i < count; i++)
  {
    if (term_hw_sync == 0u)
    {
      term_sync_hw();
    }
    term_emit_bdos(' ');
    if (term_col < TERM_LAST_COL)
    {
      term_col++;
    }
  }
  if (erase != term_color)
  {
    OS_SETCOLOR(term_color);
  }
  term_pull_hw_xy();
}

static void term_newline(void)
{
  if (TERM_DOC_ON())
  {
    term_doc_newline();
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  term_curs_invalidate();
  term_emit_bdos(0x0Au);
  term_pull_hw_xy();
}

static void term_backspace(void)
{
  /* VT100 BS: cursor left only. BBS erase is BS SPACE BS from the host. */
  if (TERM_DOC_ON())
  {
    term_doc_backspace();
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  if (term_col == 0u)
  {
    return;
  }
  term_curs_invalidate();
  term_col--;
  term_sync_hw();
}

static void term_tab(void)
{
  unsigned char next;
  unsigned char spaces;

  next = (unsigned char)(((term_col >> 3) + 1u) << 3);
  if (next > TERM_COLS)
  {
    next = TERM_COLS;
  }
  if (term_col >= next)
  {
    return;
  }
  term_curs_invalidate();
  spaces = (unsigned char)(next - term_col);
  term_fill_spaces(spaces);
}

/* Hot path: printable glyph (caller already filtered controls / BS-echo). */
static void term_putchar_glyph(unsigned char cp437)
{
  unsigned char ch;

  if (term_color == 0x00u)
  {
    /* Synchronet: ESC[30;40m then invisible chars move cursor before ESC[6n. */
    if (TERM_DOC_ON())
    {
      term_doc_put_atm((unsigned char)' ');
      term_soft_advance();
      return;
    }
    term_curs_invalidate();
    if (term_col < TERM_LAST_COL)
    {
      term_col++;
    }
    else
    {
      term_newline();
    }
    term_sync_hw();
    return;
  }

  ch = term_wire_cp866 != 0u ? cp437 : cp437toatm[cp437];
  if (TERM_DOC_ON())
  {
    g_ed2_needs_cr = 0u;
    term_doc_put_atm(ch);
    term_soft_advance();
    return;
  }
  g_ed2_needs_cr = 0u;
  if (g_curs_drawn != 0u)
  {
    term_cursor_hide();
  }
  if (term_hw_sync == 0u)
  {
    term_sync_hw();
  }
  term_emit_bdos(ch);
  term_soft_advance();
}

void term_putchar(unsigned char cp437)
{
  if (cp437 == 0x07u)
  {
    return;
  }
  if (cp437 == 0x08u || cp437 == 0x7Fu)
  {
    term_backspace();
    return;
  }
  if (cp437 == 0x09u)
  {
    term_tab();
    return;
  }
  if (cp437 == 0x0Au)
  {
    if (TERM_DOC_ON())
    {
      term_doc_newline();
      term_doc_get_vis_xy(&term_col, &term_row);
      return;
    }
    term_curs_invalidate();
    term_emit_bdos(0x0Au);
    term_pull_hw_xy();
    return;
  }
  if (cp437 == 0x0Du)
  {
    if (TERM_DOC_ON())
    {
      term_doc_carriage_return();
      term_doc_get_vis_xy(&term_col, &term_row);
      return;
    }
    term_curs_invalidate();
    term_emit_bdos(0x0Du);
    term_pull_hw_xy();
    return;
  }
  if (cp437 == 0x0Cu)
  {
    term_cls(term_color == 0x00u ? 0x07u : term_color);
    return;
  }
  if (cp437 == 0x0Eu || cp437 == 0x0Fu || cp437 == 0x10u || cp437 == 0x11u)
  {
    /* PCBoard/Mystic charset shift codes - no visible glyph. */
    return;
  }
  if (cp437 < 0x20u)
  {
    return;
  }
  term_putchar_glyph(cp437);
}

void term_scroll_up(unsigned char count)
{
  if (count == 0u)
  {
    return;
  }
  if (TERM_DOC_ON())
  {
    term_doc_scroll_up(count);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  term_curs_invalidate();
  term_desync_hw();
  OS_SCROLL_SCREEN_UP(count);
}

void term_scroll_down(unsigned char count)
{
  if (count == 0u)
  {
    return;
  }
  if (TERM_DOC_ON())
  {
    term_doc_scroll_down(count);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  term_curs_invalidate();
  term_desync_hw();
  OS_SCROLL_SCREEN_DOWN(count);
}

static void ansi_reset_args(void)
{
  ansi_argc = 0u;
  ansi_private_csi = 0u;
  memset(ansi_args, 0, sizeof(ansi_args));
}

static void term_save_cursor(void)
{
  saved_col = term_col;
  saved_row = term_row;
  saved_color = term_color;
  has_saved = 1u;
}

static void term_restore_cursor(void)
{
  if (has_saved == 0u)
  {
    return;
  }
  term_set_color(saved_color);
  term_set_xy(saved_col, saved_row);
}

static void ansi_push_digit(unsigned char digit)
{
  if (ansi_argc >= ANSI_MAX_ARGS)
  {
    return;
  }
  ansi_args[ansi_argc] = (unsigned char)(ansi_args[ansi_argc] * 10u + digit);
}

static unsigned char ansi_param(unsigned char index)
{
  if (index >= ansi_argc)
  {
    return 0u;
  }
  return ansi_args[index];
}

/* Apply one SGR code to a working attribute (no BDOS). */
static unsigned char term_sgr_apply(unsigned char c, unsigned char code)
{
  if (code == 0u)
  {
    return 0x07u;
  }
  if (code == 1u)
  {
    return (unsigned char)(c | TERM_ATTR_BRIGHT_INK);
  }
  if (code == 22u)
  {
    return (unsigned char)(c & (unsigned char)~TERM_ATTR_BRIGHT_INK);
  }
  if (code == 39u)
  {
    return (unsigned char)((c & 0xF8u) | 0x07u);
  }
  if (code == 49u)
  {
    return (unsigned char)(c & 0xC7u);
  }
  if (code >= 30u && code <= 37u)
  {
    /* PC ANSI index goes straight to ink bits; palette provides hue. */
    return (unsigned char)((c & 0xF8u) | (code - 30u));
  }
  if (code >= 40u && code <= 47u)
  {
    return (unsigned char)((c & 0xC7u) | ((code - 40u) << 3));
  }
  if (code >= 90u && code <= 97u)
  {
    return (unsigned char)((c & 0xF8u) | (code - 90u) | TERM_ATTR_BRIGHT_INK);
  }
  if (code >= 100u && code <= 107u)
  {
    return (unsigned char)((c & 0xC7u) | ((code - 100u) << 3) | TERM_ATTR_BRIGHT_PAPER);
  }
  return c;
}

static void term_sgr(void)
{
  unsigned char i;
  unsigned char c;
  unsigned char saw30;
  unsigned char saw40;

  saw30 = 0u;
  saw40 = 0u;
  c = term_color;
  if (ansi_argc == 0u)
  {
    c = term_sgr_apply(c, 0u);
  }
  else
  {
    for (i = 0u; i < ansi_argc; i++)
    {
      if (ansi_args[i] == 30u)
      {
        saw30 = 1u;
      }
      if (ansi_args[i] == 40u)
      {
        saw40 = 1u;
      }
      c = term_sgr_apply(c, ansi_args[i]);
    }
  }
  term_set_color(c);
  /* Synchronet probe: ESC[30;40m then ESC[6n expects ESC[25;80R (cterm.txt). */
  if (saw30 != 0u && saw40 != 0u && term_color == 0x00u)
  {
    term_cpr_fix_corner = 2u;
  }
}

static void term_erase_line(unsigned char mode)
{
  unsigned char col;
  unsigned char row;

  if (TERM_DOC_ON())
  {
    term_doc_erase_line(mode);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }

  /* Match src/telnet/telnet.asm: EL uses BDOS cursor, not cached term_col. */
  term_curs_invalidate();
  term_get_xy(&term_col, &term_row);
  col = term_col;
  row = term_row;
  if (mode == 0u)
  {
    /* EL0: clear to EOL; cursor position must not change (BSRealm login prompt). */
    if (row >= term_last_row())
    {
      return;
    }
    term_fill_spaces((unsigned char)(TERM_COLS - col));
    term_col = col;
    term_row = row;
    term_sync_hw();
  }
  else if (mode == 1u)
  {
    term_col = 0u;
    term_row = row;
    term_sync_hw();
    term_fill_spaces((unsigned char)(col + 1u));
    term_col = col;
    term_row = row;
    term_sync_hw();
  }
  else if (mode == 2u)
  {
    term_col = 0u;
    term_row = row;
    term_sync_hw();
    term_fill_spaces(TERM_COLS);
    term_col = 0u;
    term_row = row;
    term_hw_sync = 1u;
  }
}

static void term_erase_display(unsigned char mode)
{
  unsigned char r;
  unsigned char saved_row;
  unsigned char saved_col;

  if (TERM_DOC_ON())
  {
    term_doc_erase_display(mode);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }

  term_reset_cpr_fix();
  term_curs_invalidate();
  term_get_xy(&term_col, &term_row);
  saved_row = term_row;
  saved_col = term_col;
  if (mode == 0u)
  {
    term_erase_line(0u);
    for (r = (unsigned char)(term_row + 1u); r <= term_last_row(); r++)
    {
      term_col = 0u;
      term_row = r;
      term_desync_hw();
      term_fill_spaces(TERM_COLS);
    }
  }
  else if (mode == 1u)
  {
    for (r = 0u; r < term_row; r++)
    {
      term_col = 0u;
      term_row = r;
      term_desync_hw();
      term_fill_spaces(TERM_COLS);
    }
    term_col = 0u;
    term_sync_hw();
    term_erase_line(1u);
  }
  else if (mode == 2u)
  {
    g_ed2_needs_cr = 1u;
    term_cls(term_color);
    return;
  }
  term_col = saved_col;
  term_row = saved_row;
  term_sync_hw();
}

static void term_cursor_up(unsigned char count)
{
  if (TERM_DOC_ON())
  {
    term_doc_cursor_up(count);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  term_curs_invalidate();
  if (term_hw_sync == 0u)
  {
    term_pull_hw_xy();
  }
  if (count == 0u)
  {
    count = 1u;
  }
  if (count > term_row)
  {
    term_row = 0u;
  }
  else
  {
    term_row = (unsigned char)(term_row - count);
  }
  term_sync_hw();
}

static void term_cursor_down(unsigned char count)
{
  unsigned char max_down;

  if (TERM_DOC_ON())
  {
    term_doc_cursor_down(count);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }

  term_curs_invalidate();
  if (term_hw_sync == 0u)
  {
    term_pull_hw_xy();
  }
  if (count == 0u)
  {
    count = 1u;
  }
  max_down = (unsigned char)(term_last_row() - term_row);
  if (count > max_down)
  {
    term_row = term_last_row();
  }
  else
  {
    term_row = (unsigned char)(term_row + count);
  }
  term_sync_hw();
}

static void term_cursor_left(unsigned char count)
{
  if (TERM_DOC_ON())
  {
    term_doc_cursor_left(count);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  term_curs_invalidate();
  if (term_hw_sync == 0u)
  {
    term_pull_hw_xy();
  }
  if (count == 0u)
  {
    count = 1u;
  }
  if (count > term_col)
  {
    term_col = 0u;
  }
  else
  {
    term_col = (unsigned char)(term_col - count);
  }
  term_sync_hw();
}

static void term_cursor_right(unsigned char count)
{
  unsigned char max_right;

  if (TERM_DOC_ON())
  {
    term_doc_cursor_right(count);
    term_doc_get_vis_xy(&term_col, &term_row);
    return;
  }
  term_curs_invalidate();
  if (term_hw_sync == 0u)
  {
    term_pull_hw_xy();
  }
  if (count == 0u)
  {
    count = 1u;
  }
  max_right = (unsigned char)(TERM_LAST_COL - term_col);
  if (count > max_right)
  {
    term_col = TERM_LAST_COL;
  }
  else
  {
    term_col = (unsigned char)(term_col + count);
  }
  term_sync_hw();
}

static void term_cursor_col(unsigned char col)
{
  if (col == 0u)
  {
    col = 1u;
  }
  col--;
  if (col > TERM_LAST_COL)
  {
    col = TERM_LAST_COL;
  }
  term_set_xy(col, term_row);
}

static void term_cursor_row(unsigned char row)
{
  if (row == 0u)
  {
    row = 1u;
  }
  row--;
  if (row > term_last_row())
  {
    row = term_last_row();
  }
  term_set_xy(term_col, row);
}

static void term_cursor_pos(unsigned char row, unsigned char col)
{
  if (row == 0u)
  {
    row = 1u;
  }
  if (col == 0u)
  {
    col = 1u;
  }
  row--;
  col--;
  term_set_xy(col, row);
}

static void term_dispatch_csi(unsigned char cmd)
{
  switch (cmd)
  {
  case 'm':
    term_sgr();
    break;
  case 'A':
    term_cursor_up(ansi_param(0));
    break;
  case 'B':
    term_cursor_down(ansi_param(0));
    break;
  case 'C':
    term_cursor_right(ansi_param(0));
    break;
  case 'D':
    term_cursor_left(ansi_param(0));
    break;
  case 'G':
    term_cursor_col(ansi_param(0));
    break;
  case 'd':
    term_cursor_row(ansi_param(0));
    break;
  case 'H':
  case 'f':
    term_cursor_pos(ansi_param(0), ansi_param(1));
    break;
  case 'J':
    term_erase_display(ansi_param(0));
    break;
  case 'K':
    term_erase_line(ansi_param(0));
    break;
  case 'S':
    term_scroll_up(ansi_param(0) == 0u ? 1u : ansi_param(0));
    break;
  case 'T':
    term_scroll_down(ansi_param(0) == 0u ? 1u : ansi_param(0));
    break;
  case 's':
    term_save_cursor();
    break;
  case 'u':
    term_restore_cursor();
    break;
  case 'n':
    if (ansi_param(0) == 5u)
    {
      term_reply_push(0x1Bu);
      term_reply_push('[');
      term_reply_push('0');
      term_reply_push('n');
    }
    else if (ansi_param(0) == 6u)
    {
      term_reply_dsr();
    }
    else if (ansi_param(0) == 255u)
    {
      term_reply_size_cpr();
    }
    break;
  case 'h':
    if (ansi_private_csi != 0u && ansi_param(0) == 25u)
    {
      term_cursor_hold_and_not(TERM_CURS_HOLD_DEC);
    }
    break;
  case 'l':
    if (ansi_private_csi != 0u && ansi_param(0) == 25u)
    {
      term_cursor_hold_or(TERM_CURS_HOLD_DEC);
    }
    break;
  default:
    break;
  }
  ansi_state = ST_TEXT;
  ansi_reset_args();
}

static void term_feed_csi(unsigned char b)
{
  if (b >= '0' && b <= '9')
  {
    ansi_push_digit((unsigned char)(b - '0'));
    return;
  }
  if (b == ';')
  {
    if (ansi_argc < ANSI_MAX_ARGS)
    {
      ansi_argc++;
    }
    return;
  }
  if (b == '?' || b == '>' || b == '=')
  {
    ansi_private_csi = 1u;
    return;
  }
  if (b >= 0x20 && b <= 0x2F)
  {
    return;
  }
  if (ansi_argc < ANSI_MAX_ARGS)
  {
    ansi_argc++;
  }
  term_dispatch_csi(b);
}

int term_feed(unsigned char b)
{
  if (ansi_state == ST_TEXT)
  {
    if (b == 0x1Au)
    {
      return 0;
    }
    if (term_literal_next != 0u)
    {
      term_literal_next = 0u;
      if (b == 0x1Bu)
      {
        ansi_state = ST_ESC;
        return 1;
      }
      term_putchar(b);
      return 1;
    }
    if (b == 0x00u)
    {
      /* Synchronet invisible SGR: NUL then literal char moves cursor. */
      if (term_color == 0x00u)
      {
        term_literal_next = 1u;
      }
      return 1;
    }
    if (b == 0x1Bu)
    {
      ansi_state = ST_ESC;
      return 1;
    }
    /* Fast path: plain glyph, no control. */
    if (b >= 0x20u && b != 0x7Fu)
    {
      term_putchar_glyph(b);
      return 1;
    }
    term_putchar(b);
    return 1;
  }
  if (ansi_state == ST_ESC)
  {
    if (b == '[')
    {
      ansi_reset_args();
      ansi_state = ST_CSI;
      return 1;
    }
    if (b == 's')
    {
      term_save_cursor();
      ansi_state = ST_TEXT;
      return 1;
    }
    if (b == 'u')
    {
      term_restore_cursor();
      ansi_state = ST_TEXT;
      return 1;
    }
    /* Ignore other ESC-letter sequences (DEC ident, charset, etc.). */
    ansi_state = ST_TEXT;
    return 1;
  }
  term_feed_csi(b);
  return 1;
}

int term_feed_buf(const unsigned char *buf, unsigned int n)
{
  unsigned int i;
  unsigned char b;

  if (buf == 0)
  {
    return 1;
  }
  for (i = 0u; i < n; i++)
  {
    b = buf[i];
    /* Tight loop for runs of plain text (common BBS / ANSI flood). */
    if (ansi_state == ST_TEXT && term_literal_next == 0u
        && b >= 0x20u && b != 0x7Fu && b != 0x1Bu && b != 0x1Au)
    {
      term_putchar_glyph(b);
      continue;
    }
    if (term_feed(b) == 0)
    {
      return 0;
    }
  }
  return 1;
}
