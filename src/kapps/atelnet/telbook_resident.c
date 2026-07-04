#pragma language=extended
#pragma codeseg(CODE_RESIDENT)

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include "atelnet.h"
#include "atelnet_plug.h"

#define TELBOOK_PATH "user.tel"
#define TELBOOK_MAX 8u
#define TELBOOK_LABEL_LEN 18u
#define TELBOOK_HOST_STORE 48u
#define TELBOOK_HOST_VIEW 28u
#define TELBOOK_PORT_LEN 5u
#define TELBOOK_VIEW_H 8u
#define TELBOOK_TITLE_Y 0u
#define TELBOOK_WIN_X 1u
#define TELBOOK_BOX_Y 1u
#define TELBOOK_HDR_Y 2u
#define TELBOOK_LIST_Y 3u
#define TELBOOK_WIN_W 78u
#define TELBOOK_FRAME_BOT (TELBOOK_LIST_Y + TELBOOK_VIEW_H)
#define TELBOOK_BOX_H (TELBOOK_FRAME_BOT - TELBOOK_BOX_Y)
#define TELBOOK_HELP_Y (TELBOOK_FRAME_BOT + 1u)
#define TELBOOK_GLOBAL_HINT_Y (TELBOOK_HELP_Y + 1u)
#define TELBOOK_FRAME_X 0u
#define TELBOOK_FRAME_Y 1u
#define TELBOOK_FRAME_ATTR 0x67u
#define TELBOOK_SYM_TL 201u
#define TELBOOK_SYM_TR 187u
#define TELBOOK_SYM_BL 200u
#define TELBOOK_SYM_BR 188u
#define TELBOOK_SYM_H 205u
#define TELBOOK_SYM_V 186u

#define TB_INNER_X 1u
#define TB_INNER_W 78u
#define TB_X_MARK 2u
#define TB_X_LABEL 3u
#define TB_W_LABEL 18u
#define TB_X_HOST 22u
#define TB_W_HOST TELBOOK_HOST_VIEW
#define TB_X_PORT 51u
#define TB_W_PORT 5u
#define TB_X_CP 57u
#define TB_W_CP 4u
#define TB_ROW_O_MARK (unsigned char)(TB_X_MARK - TB_INNER_X)
#define TB_ROW_O_LABEL (unsigned char)(TB_X_LABEL - TB_INNER_X)
#define TB_ROW_O_HOST (unsigned char)(TB_X_HOST - TB_INNER_X)
#define TB_ROW_O_PORT (unsigned char)(TB_X_PORT - TB_INNER_X)
#define TB_ROW_O_CP (unsigned char)(TB_X_CP - TB_INNER_X)

#define TELBOOK_ATTR_ROW 0x67u
#define TELBOOK_ATTR_SEL 0xBCu
#define TELBOOK_ATTR_HDR 0x67u
#define TELBOOK_CHIP_ENTER 0x30u
#define TELBOOK_CHIP_EDIT 0x1Fu
#define TELBOOK_CHIP_ADD 0x0Fu
#define TELBOOK_CHIP_DEL 0x17u
#define TELBOOK_CHIP_SAVE 0x28u
#define TELBOOK_CHIP_DBG 0x5Fu
#define TELBOOK_CHIP_QUIT 0x70u
#define TELBOOK_CHIP_HINT 0x17u

#define TELBOOK_KEY_UP 250u
#define TELBOOK_KEY_DOWN 249u
#define TELBOOK_KEY_LEFT 248u
#define TELBOOK_KEY_RIGHT 251u
#define TELBOOK_KEY_INS 29u
#define TELBOOK_KEY_F2 178u
#define TELBOOK_KEY_DEL 252u
#define TELBOOK_KEY_TAB 9u

#define TELBOOK_F_LABEL 0u
#define TELBOOK_F_HOST 1u
#define TELBOOK_F_PORT 2u
#define TELBOOK_F_CP 3u
#define TELBOOK_F_COUNT 4u

typedef struct
{
  char label[TELBOOK_LABEL_LEN + 1u];
  char host[TELBOOK_HOST_STORE + 1u];
  unsigned int port;
  unsigned char cp866;
} TelBookEntry;

#pragma memory=dataseg(UDATA_RESIDENT)

static TelBookEntry telbook[TELBOOK_MAX];
static unsigned char telbook_count;
static unsigned char telbook_dirty;
static unsigned char tel_sel;
static unsigned char tel_scroll;
static unsigned char telbook_debug;
static unsigned char telbook_editing;
static unsigned char telbook_ed_field;
static unsigned char telbook_ed_curs;
static unsigned char telbook_ed_replace;
static char telbook_port_edit[TELBOOK_PORT_LEN + 1u];
static char telbook_file_buf[512];
static unsigned char telbook_io_path[128];
static char telbook_io_line[160];
static char telbook_draw_line[TB_INNER_W + 1u];
static char telbook_field_buf[32];
static TelBookEntry telbook_load_tmp;

#pragma memory=default

static const char telbook_header[] =
  "# atelnet address book: label|host|port|cp\r\n"
  "# cp = 437 or 866\r\n";

static const char telbook_default[] =
  "# atelnet address book: label|host|port|cp\r\n"
  "# cp = 437 or 866\r\n"
  "Music Station|musicstation.bsrealm.net|23|866\r\n"
  "HispaMSX|bbs.hispamsx.org|23|437\r\n";

static unsigned char telbook_total_items(void)
{
  return telbook_count;
}

static void telbook_trim_line(char *s)
{
  unsigned int n;
  char *p;

  while (*s == ' ' || *s == '\t')
  {
    s++;
  }
  n = strlen(s);
  while (n > 0u && (s[n - 1u] == ' ' || s[n - 1u] == '\t' || s[n - 1u] == '\r' || s[n - 1u] == '\n'))
  {
    s[n - 1u] = 0;
    n--;
  }
  p = s;
  while (*p)
  {
    if (*p == '\r' || *p == '\n')
    {
      *p = 0;
      break;
    }
    p++;
  }
}

static void telbook_clear_entry(TelBookEntry *e)
{
  e->label[0] = 0;
  e->host[0] = 0;
  e->port = 23u;
  e->cp866 = 0u;
}

static unsigned char telbook_parse_cp(const char *s)
{
  unsigned long v;

  v = strtoul(s, NULL, 10);
  if (v == 866ul)
  {
    return 1u;
  }
  return 0u;
}

static int telbook_parse_line(char *line, TelBookEntry *e)
{
  char *p1;
  char *p2;
  char *p3;
  unsigned long port;

  telbook_trim_line(line);
  if (line[0] == 0 || line[0] == '#' || line[0] == ';')
  {
    return 0;
  }

  telbook_clear_entry(e);
  p1 = strchr(line, '|');
  if (p1 == NULL)
  {
    strncpy(e->host, line, TELBOOK_HOST_STORE);
    e->host[TELBOOK_HOST_STORE] = 0;
    strncpy(e->label, e->host, TELBOOK_LABEL_LEN);
    e->label[TELBOOK_LABEL_LEN] = 0;
    return 1;
  }
  *p1++ = 0;
  p2 = strchr(p1, '|');
  if (p2 == NULL)
  {
    return 0;
  }
  *p2++ = 0;
  p3 = strchr(p2, '|');
  if (p3 == NULL)
  {
    strncpy(e->label, line, TELBOOK_LABEL_LEN);
    e->label[TELBOOK_LABEL_LEN] = 0;
    strncpy(e->host, p1, TELBOOK_HOST_STORE);
    e->host[TELBOOK_HOST_STORE] = 0;
    port = strtoul(p2, NULL, 10);
    e->port = (port > 0ul && port <= 65535ul) ? (unsigned int)port : 23u;
    return e->host[0] != 0;
  }
  *p3++ = 0;
  strncpy(e->label, line, TELBOOK_LABEL_LEN);
  e->label[TELBOOK_LABEL_LEN] = 0;
  strncpy(e->host, p1, TELBOOK_HOST_STORE);
  e->host[TELBOOK_HOST_STORE] = 0;
  port = strtoul(p2, NULL, 10);
  e->port = (port > 0ul && port <= 65535ul) ? (unsigned int)port : 23u;
  e->cp866 = telbook_parse_cp(p3);
  if (e->label[0] == 0)
  {
    strncpy(e->label, e->host, TELBOOK_LABEL_LEN);
    e->label[TELBOOK_LABEL_LEN] = 0;
  }
  return e->host[0] != 0;
}

static void telbook_load(void)
{
  FILE *fp;
  unsigned int n;
  unsigned int i;
  unsigned int line_start;

  telbook_count = 0u;
  telbook_dirty = 0u;
  at_path_to_ini(telbook_io_path);
  fp = OS_OPENHANDLE((unsigned char *)TELBOOK_PATH, 0x80u);
  if (((int)fp) & 0xff)
  {
    fp = OS_CREATEHANDLE((unsigned char *)TELBOOK_PATH, 0x80u);
    if (((int)fp) & 0xff)
    {
      OS_CHDIR(telbook_io_path);
      return;
    }
    OS_WRITEHANDLE((unsigned char *)telbook_default, fp, (unsigned int)strlen(telbook_default));
    OS_CLOSEHANDLE(fp);
    fp = OS_OPENHANDLE((unsigned char *)TELBOOK_PATH, 0x80u);
    if (((int)fp) & 0xff)
    {
      OS_CHDIR(telbook_io_path);
      return;
    }
  }

  n = OS_READHANDLE((unsigned char *)telbook_file_buf, fp,
                    (unsigned int)(sizeof(telbook_file_buf) - 1u));
  OS_CLOSEHANDLE(fp);
  if (n == 0u)
  {
    OS_CHDIR(telbook_io_path);
    return;
  }
  telbook_file_buf[n] = 0;

  line_start = 0u;
  for (i = 0u; i <= n; i++)
  {
    if (telbook_file_buf[i] == 0 || telbook_file_buf[i] == '\r' || telbook_file_buf[i] == '\n')
    {
      unsigned int len;
      unsigned int j;

      len = i - line_start;
      if (len >= sizeof(telbook_io_line))
      {
        len = sizeof(telbook_io_line) - 1u;
      }
      for (j = 0u; j < len; j++)
      {
        telbook_io_line[j] = telbook_file_buf[line_start + j];
      }
      telbook_io_line[len] = 0;
      if (telbook_parse_line(telbook_io_line, &telbook_load_tmp) && telbook_count < TELBOOK_MAX)
      {
        telbook[telbook_count] = telbook_load_tmp;
        telbook_count++;
      }
      line_start = i + 1u;
      if (telbook_file_buf[i] == '\r' && telbook_file_buf[i + 1u] == '\n')
      {
        line_start++;
        i++;
      }
    }
  }
  OS_CHDIR(telbook_io_path);
}

static void telbook_seed_defaults(void)
{
  telbook_clear_entry(&telbook[0]);
  strcpy(telbook[0].label, "Music Station");
  strcpy(telbook[0].host, "musicstation.bsrealm.net");
  telbook[0].port = 23u;
  telbook[0].cp866 = 1u;

  telbook_clear_entry(&telbook[1]);
  strcpy(telbook[1].label, "HispaMSX");
  strcpy(telbook[1].host, "bbs.hispamsx.org");
  telbook[1].port = 23u;
  telbook[1].cp866 = 0u;

  telbook_count = 2u;
  telbook_dirty = 1u;
}

static void telbook_ensure_entries(void)
{
  if (telbook_count == 0u)
  {
    telbook_seed_defaults();
  }
}

static int telbook_save(void)
{
  FILE *fp;
  unsigned int out_len;
  unsigned char i;

  at_path_to_ini(telbook_io_path);
  fp = OS_CREATEHANDLE((unsigned char *)TELBOOK_PATH, 0x80u);
  if (((int)fp) & 0xff)
  {
    OS_CHDIR(telbook_io_path);
    return 0;
  }

  out_len = (unsigned int)strlen(telbook_header);
  if (OS_WRITEHANDLE((unsigned char *)telbook_header, fp, out_len) != out_len)
  {
    OS_CLOSEHANDLE(fp);
    OS_CHDIR(telbook_io_path);
    return 0;
  }

  for (i = 0u; i < telbook_count; i++)
  {
    sprintf(telbook_io_line, "%s|%s|%u|%s\r\n",
            telbook[i].label,
            telbook[i].host,
            telbook[i].port,
            telbook[i].cp866 != 0u ? "866" : "437");
    out_len = (unsigned int)strlen(telbook_io_line);
    if (OS_WRITEHANDLE((unsigned char *)telbook_io_line, fp, out_len) != out_len)
    {
      OS_CLOSEHANDLE(fp);
      OS_CHDIR(telbook_io_path);
      return 0;
    }
  }

  OS_CLOSEHANDLE(fp);
  telbook_dirty = 0u;
  OS_CHDIR(telbook_io_path);
  return 1;
}

static void telbook_wait_key(void)
{
  do
  {
    YIELD();
  } while ((OS_GETKEY() & 0xFFL) == 0L);
}

static void telbook_fill_rect(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char attr)
{
  unsigned char row;
  unsigned char col;

  for (row = 0u; row < h; row++)
  {
    OS_SETXY(x, (unsigned char)(y + row));
    OS_SETCOLOR(attr);
    for (col = 0u; col < w; col++)
    {
      putchar(' ');
    }
  }
}

static void telbook_draw_chip(unsigned char x, unsigned char y, unsigned char w, unsigned char attr, const char *text)
{
  unsigned char i;
  unsigned char len;

  len = (unsigned char)strlen(text);
  OS_SETXY(x, y);
  OS_SETCOLOR(attr);
  for (i = 0u; i < w; i++)
  {
    if (i < len)
    {
      putchar((int)text[i]);
    }
    else
    {
      putchar(' ');
    }
  }
}

static void telbook_draw_frame(void)
{
  unsigned char y;
  unsigned char x;

  OS_SETCOLOR(TELBOOK_FRAME_ATTR);
  OS_SETXY(TELBOOK_FRAME_X, TELBOOK_FRAME_Y);
  putchar((int)TELBOOK_SYM_TL);
  for (x = 1u; x <= 78u; x++)
  {
    OS_SETXY(x, TELBOOK_FRAME_Y);
    putchar((int)TELBOOK_SYM_H);
  }
  OS_SETXY(79u, TELBOOK_FRAME_Y);
  putchar((int)TELBOOK_SYM_TR);

  for (y = 2u; y < TELBOOK_FRAME_BOT; y++)
  {
    OS_SETXY(TELBOOK_FRAME_X, y);
    putchar((int)TELBOOK_SYM_V);
    OS_SETXY(79u, y);
    putchar((int)TELBOOK_SYM_V);
  }

  OS_SETXY(TELBOOK_FRAME_X, TELBOOK_FRAME_BOT);
  putchar((int)TELBOOK_SYM_BL);
  for (x = 1u; x <= 78u; x++)
  {
    OS_SETXY(x, TELBOOK_FRAME_BOT);
    putchar((int)TELBOOK_SYM_H);
  }
  OS_SETXY(79u, TELBOOK_FRAME_BOT);
  putchar((int)TELBOOK_SYM_BR);
}

static void telbook_draw_help(void)
{
  telbook_fill_rect(1u, TELBOOK_HELP_Y, 78u, 1u, 0x07u);
  if (telbook_editing != 0u)
  {
    telbook_draw_chip(1u, TELBOOK_HELP_Y, 10u, TELBOOK_CHIP_HINT, " Type ");
    telbook_draw_chip(12u, TELBOOK_HELP_Y, 10u, TELBOOK_CHIP_EDIT, " Tab fld ");
    telbook_draw_chip(23u, TELBOOK_HELP_Y, 10u, TELBOOK_CHIP_ENTER, " Enter ok ");
    telbook_draw_chip(34u, TELBOOK_HELP_Y, 11u, TELBOOK_CHIP_QUIT, " Esc cancel");
  }
  else
  {
    telbook_draw_chip(1u, TELBOOK_HELP_Y, 14u, TELBOOK_CHIP_ENTER, " Enter connect");
    telbook_draw_chip(16u, TELBOOK_HELP_Y, 8u, TELBOOK_CHIP_EDIT, " E edit ");
    telbook_draw_chip(25u, TELBOOK_HELP_Y, 8u, TELBOOK_CHIP_ADD, " Ins add");
    telbook_draw_chip(34u, TELBOOK_HELP_Y, 11u, TELBOOK_CHIP_DEL, " Del delete");
    telbook_draw_chip(46u, TELBOOK_HELP_Y, 9u, TELBOOK_CHIP_SAVE, " F2 save ");
    telbook_draw_chip(56u, TELBOOK_HELP_Y, 8u, TELBOOK_CHIP_DBG, " G debug");
    telbook_draw_chip(65u, TELBOOK_HELP_Y, 14u, TELBOOK_CHIP_QUIT, " Esc quit    ");
  }
}

static void telbook_draw_global_hint(void)
{
  telbook_fill_rect(1u, TELBOOK_GLOBAL_HINT_Y, 78u, 1u, 0x07u);
  OS_SETCOLOR(0x07u);
  OS_SETXY(25u, TELBOOK_GLOBAL_HINT_Y);
  printf("Esc quit   Enter connect");
}

static void telbook_paste(char *line, unsigned char off, unsigned char w, const char *text)
{
  unsigned char i;

  for (i = 0u; i < w; i++)
  {
    line[off + i] = ' ';
  }
  for (i = 0u; text[i] != 0 && i < w; i++)
  {
    line[off + i] = text[i];
  }
}

static void telbook_field_text(unsigned char field, TelBookEntry *e, char *out, unsigned char out_sz)
{
  if (field == TELBOOK_F_LABEL)
  {
    strncpy(out, e->label, out_sz - 1u);
  }
  else if (field == TELBOOK_F_HOST)
  {
    strncpy(out, e->host, out_sz - 1u);
  }
  else if (field == TELBOOK_F_PORT)
  {
    if (telbook_editing != 0u && tel_sel < telbook_count && &telbook[tel_sel] == e)
    {
      strncpy(out, telbook_port_edit, out_sz - 1u);
    }
    else
    {
      sprintf(out, "%u", e->port);
    }
  }
  else
  {
    strcpy(out, e->cp866 != 0u ? "866" : "437");
  }
  out[out_sz - 1u] = 0;
}

static void telbook_build_header(char *line)
{
  unsigned char i;

  for (i = 0u; i < TB_INNER_W; i++)
  {
    line[i] = ' ';
  }
  line[TB_INNER_W] = 0;
  line[TB_ROW_O_MARK] = ' ';
  telbook_paste(line, TB_ROW_O_LABEL, TB_W_LABEL, "Label");
  telbook_paste(line, TB_ROW_O_HOST, TB_W_HOST, "Host");
  telbook_paste(line, TB_ROW_O_PORT, TB_W_PORT, "Port");
  telbook_paste(line, TB_ROW_O_CP, TB_W_CP, "CP");
}

static void telbook_build_row(char *line, unsigned char item_idx, unsigned char selected)
{
  unsigned char i;

  for (i = 0u; i < TB_INNER_W; i++)
  {
    line[i] = ' ';
  }
  line[TB_INNER_W] = 0;
  line[TB_ROW_O_MARK] = (selected != 0u) ? '>' : ' ';

  telbook_field_text(TELBOOK_F_LABEL, &telbook[item_idx], telbook_field_buf, sizeof(telbook_field_buf));
  telbook_paste(line, TB_ROW_O_LABEL, TB_W_LABEL, telbook_field_buf);
  telbook_field_text(TELBOOK_F_HOST, &telbook[item_idx], telbook_field_buf, sizeof(telbook_field_buf));
  telbook_paste(line, TB_ROW_O_HOST, TB_W_HOST, telbook_field_buf);
  telbook_field_text(TELBOOK_F_PORT, &telbook[item_idx], telbook_field_buf, sizeof(telbook_field_buf));
  telbook_paste(line, TB_ROW_O_PORT, TB_W_PORT, telbook_field_buf);
  telbook_field_text(TELBOOK_F_CP, &telbook[item_idx], telbook_field_buf, sizeof(telbook_field_buf));
  telbook_paste(line, TB_ROW_O_CP, TB_W_CP, telbook_field_buf);
}

static unsigned char telbook_field_x(unsigned char field)
{
  switch (field)
  {
    case TELBOOK_F_LABEL: return TB_X_LABEL;
    case TELBOOK_F_HOST: return TB_X_HOST;
    case TELBOOK_F_PORT: return TB_X_PORT;
    case TELBOOK_F_CP: return TB_X_CP;
    default: return TB_X_LABEL;
  }
}

static unsigned char telbook_field_w(unsigned char field)
{
  switch (field)
  {
    case TELBOOK_F_LABEL: return TB_W_LABEL;
    case TELBOOK_F_HOST: return TB_W_HOST;
    case TELBOOK_F_PORT: return TB_W_PORT;
    case TELBOOK_F_CP: return TB_W_CP;
    default: return TB_W_LABEL;
  }
}

static void telbook_draw_inner_line(unsigned char y, const char *line, unsigned char attr)
{
  unsigned char i;

  OS_SETXY(TB_INNER_X, y);
  OS_SETCOLOR(attr);
  for (i = 0u; i < TB_INNER_W; i++)
  {
    putchar((int)line[i]);
  }
}

static void telbook_park_cursor(void)
{
  OS_SETXY(0u, 24u);
}

static void telbook_draw_edit_cursor(unsigned char y, unsigned char item_idx, const char *line)
{
  unsigned char fx;
  unsigned char cx;
  char ch;

  if (telbook_editing == 0u || item_idx != tel_sel)
  {
    return;
  }

  fx = telbook_field_x(telbook_ed_field);
  cx = (unsigned char)(fx + telbook_ed_curs);
  if (cx < TB_INNER_X || cx >= TB_INNER_X + TB_INNER_W)
  {
    return;
  }

  ch = line[(unsigned char)(cx - TB_INNER_X)];
  if (ch == 0)
  {
    ch = ' ';
  }

  OS_SETXY(cx, y);
  OS_SETCOLOR(INK_BLACK | PAPER_YELLOW);
  putchar((int)ch);
}

static void telbook_draw_row(unsigned char vis_y, unsigned char item_idx)
{
  unsigned char y;
  unsigned char selected;

  y = (unsigned char)(TELBOOK_LIST_Y + vis_y);
  selected = (item_idx == tel_sel) ? 1u : 0u;
  telbook_build_row(telbook_draw_line, item_idx, selected);
  telbook_draw_inner_line(y, telbook_draw_line, selected != 0u ? TELBOOK_ATTR_SEL : TELBOOK_ATTR_ROW);
  telbook_draw_edit_cursor(y, item_idx, telbook_draw_line);
}

static void telbook_draw_header_row(void)
{
  telbook_build_header(telbook_draw_line);
  telbook_draw_inner_line(TELBOOK_HDR_Y, telbook_draw_line, TELBOOK_ATTR_HDR);
}

static void telbook_draw_item_if_visible(unsigned char item_idx)
{
  unsigned char q;

  if (item_idx < tel_scroll)
  {
    return;
  }
  q = (unsigned char)(item_idx - tel_scroll);
  if (q < TELBOOK_VIEW_H)
  {
    telbook_draw_row(q, item_idx);
  }
}

static void telbook_draw_list(void)
{
  unsigned char q;

  telbook_draw_header_row();
  for (q = 0u; q < TELBOOK_VIEW_H; q++)
  {
    unsigned char item = (unsigned char)(q + tel_scroll);
    if (item < telbook_total_items())
    {
      telbook_draw_row(q, item);
    }
    else
    {
      unsigned char i;
      unsigned char y = (unsigned char)(TELBOOK_LIST_Y + q);

      for (i = 0u; i < TB_INNER_W; i++)
      {
        telbook_draw_line[i] = ' ';
      }
      telbook_draw_line[TB_INNER_W] = 0;
      telbook_draw_inner_line(y, telbook_draw_line, TELBOOK_ATTR_ROW);
    }
  }
}

static void telbook_draw_static(void)
{
  term_cls(0x07u);
  telbook_fill_rect(TELBOOK_WIN_X, TELBOOK_BOX_Y, TELBOOK_WIN_W, TELBOOK_BOX_H, TELBOOK_ATTR_ROW);
  telbook_draw_frame();
  telbook_draw_help();
  telbook_draw_global_hint();
}

static void telbook_clamp_scroll(void)
{
  unsigned char total;

  total = telbook_total_items();
  if (tel_sel >= total)
  {
    tel_sel = (unsigned char)(total - 1u);
  }
  if (tel_scroll > tel_sel)
  {
    tel_scroll = tel_sel;
  }
  if (tel_sel >= tel_scroll + TELBOOK_VIEW_H)
  {
    tel_scroll = (unsigned char)(tel_sel - TELBOOK_VIEW_H + 1u);
  }
}

static void telbook_port_sync_from_entry(unsigned char idx)
{
  sprintf(telbook_port_edit, "%u", telbook[idx].port);
}

static void telbook_port_sync_to_entry(unsigned char idx)
{
  unsigned long p;

  p = strtoul(telbook_port_edit, NULL, 10);
  if (p > 0ul && p <= 65535ul)
  {
    telbook[idx].port = (unsigned int)p;
  }
  else
  {
    telbook[idx].port = 23u;
  }
}

static void telbook_begin_edit(unsigned char idx)
{
  telbook_editing = 1u;
  telbook_ed_field = TELBOOK_F_LABEL;
  telbook_ed_curs = (unsigned char)strlen(telbook[idx].label);
  telbook_ed_replace = 0u;
  telbook_port_sync_from_entry(idx);
}

static void telbook_end_edit(unsigned char apply)
{
  if (telbook_editing == 0u)
  {
    return;
  }
  if (apply != 0u)
  {
    telbook_port_sync_to_entry(tel_sel);
    if (telbook[tel_sel].label[0] == 0)
    {
      strncpy(telbook[tel_sel].label, telbook[tel_sel].host, TELBOOK_LABEL_LEN);
      telbook[tel_sel].label[TELBOOK_LABEL_LEN] = 0;
    }
    telbook_dirty = 1u;
  }
  telbook_editing = 0u;
}

static char *telbook_edit_buf(unsigned char idx, unsigned char field)
{
  if (field == TELBOOK_F_LABEL)
  {
    return telbook[idx].label;
  }
  if (field == TELBOOK_F_HOST)
  {
    return telbook[idx].host;
  }
  if (field == TELBOOK_F_PORT)
  {
    return telbook_port_edit;
  }
  return telbook[idx].label;
}

static unsigned char telbook_edit_maxlen(unsigned char field)
{
  if (field == TELBOOK_F_LABEL)
  {
    return TELBOOK_LABEL_LEN;
  }
  if (field == TELBOOK_F_HOST)
  {
    return TELBOOK_HOST_STORE;
  }
  if (field == TELBOOK_F_PORT)
  {
    return TELBOOK_PORT_LEN;
  }
  return 3u;
}

static void telbook_edit_clamp_curs(unsigned char idx)
{
  unsigned char len;
  char *buf;

  if (telbook_ed_field == TELBOOK_F_CP)
  {
    telbook_ed_curs = 0u;
    return;
  }
  buf = telbook_edit_buf(idx, telbook_ed_field);
  len = (unsigned char)strlen(buf);
  if (telbook_ed_curs > len)
  {
    telbook_ed_curs = len;
  }
}

static void telbook_edit_next_field(unsigned char idx, signed char delta)
{
  if (telbook_ed_field == TELBOOK_F_PORT)
  {
    telbook_port_sync_to_entry(idx);
  }
  if (delta > 0)
  {
    if (telbook_ed_field + 1u < TELBOOK_F_COUNT)
    {
      telbook_ed_field++;
    }
  }
  else if (telbook_ed_field > 0u)
  {
    telbook_ed_field--;
  }
  if (telbook_ed_field == TELBOOK_F_PORT)
  {
    telbook_port_sync_from_entry(idx);
  }
  telbook_ed_replace = 1u;
  telbook_ed_curs = (unsigned char)strlen(telbook_edit_buf(idx, telbook_ed_field));
  telbook_edit_clamp_curs(idx);
}

static void telbook_edit_insert(unsigned char idx, char ch)
{
  char *buf;
  unsigned char maxl;
  unsigned char len;
  char *p;

  if (telbook_ed_field == TELBOOK_F_CP)
  {
    if (ch == '8')
    {
      telbook[idx].cp866 = 1u;
    }
    else if (ch == '4' || ch == '3' || ch == '7')
    {
      telbook[idx].cp866 = 0u;
    }
    telbook_dirty = 1u;
    return;
  }

  if (telbook_ed_replace != 0u)
  {
    buf = telbook_edit_buf(idx, telbook_ed_field);
    if (telbook_ed_field == TELBOOK_F_PORT && (ch < '0' || ch > '9'))
    {
      return;
    }
    buf[0] = ch;
    buf[1] = 0;
    telbook_ed_curs = 1u;
    telbook_ed_replace = 0u;
    telbook_dirty = 1u;
    return;
  }

  if (telbook_ed_field == TELBOOK_F_PORT && (ch < '0' || ch > '9'))
  {
    return;
  }

  buf = telbook_edit_buf(idx, telbook_ed_field);
  maxl = telbook_edit_maxlen(telbook_ed_field);
  len = (unsigned char)strlen(buf);
  if (len >= maxl)
  {
    return;
  }
  p = buf + len;
  while (p > buf + telbook_ed_curs)
  {
    *p = *(p - 1);
    p--;
  }
  buf[telbook_ed_curs] = ch;
  buf[len + 1u] = 0;
  telbook_ed_curs++;
  telbook_dirty = 1u;
}

static void telbook_edit_backspace(unsigned char idx)
{
  char *buf;
  char *p;

  if (telbook_ed_field == TELBOOK_F_CP)
  {
    return;
  }
  if (telbook_ed_curs == 0u)
  {
    return;
  }
  telbook_ed_replace = 0u;
  buf = telbook_edit_buf(idx, telbook_ed_field);
  if (buf[0] == 0)
  {
    return;
  }
  p = buf + telbook_ed_curs - 1u;
  while (*p)
  {
    *p = *(p + 1);
    p++;
  }
  telbook_ed_curs--;
  telbook_dirty = 1u;
}

static void telbook_add_entry(void)
{
  if (telbook_count >= TELBOOK_MAX)
  {
    return;
  }
  telbook_clear_entry(&telbook[telbook_count]);
  telbook_count++;
  tel_sel = (unsigned char)(telbook_count - 1u);
  telbook_clamp_scroll();
  telbook_begin_edit(tel_sel);
  telbook_dirty = 1u;
}

static void telbook_delete_entry(void)
{
  unsigned char i;

  if (telbook_count == 0u)
  {
    return;
  }
  telbook_end_edit(1u);
  for (i = tel_sel; i + 1u < telbook_count; i++)
  {
    telbook[i] = telbook[i + 1u];
  }
  telbook_count--;
  telbook_dirty = 1u;
  telbook_clamp_scroll();
}

static int telbook_confirm_quit(void)
{
  unsigned char key;

  if (telbook_dirty == 0u)
  {
    return 1;
  }
  telbook_fill_rect(1u, TELBOOK_HELP_Y, 78u, 1u, 0x07u);
  telbook_draw_chip(1u, TELBOOK_HELP_Y, 32u, 0x70u, " Save changes? Y/N Esc=discard ");
  for (;;)
  {
    YIELD();
    key = (unsigned char)(OS_GETKEY() & 0xFFL);
    if (key == 'y' || key == 'Y')
    {
      (void)telbook_save();
      return 1;
    }
    if (key == 'n' || key == 'N' || key == 27u)
    {
      return 1;
    }
  }
}

static unsigned char telbook_handle_edit_key(unsigned char key)
{
  if (key == 27u)
  {
    telbook_end_edit(0u);
    return 1u;
  }
  if (key == 13u)
  {
    telbook_end_edit(1u);
    return 1u;
  }
  if (key == TELBOOK_KEY_TAB)
  {
    telbook_edit_next_field(tel_sel, 1);
    return 1u;
  }
  if (key == TELBOOK_KEY_RIGHT)
  {
    telbook_ed_replace = 0u;
    if (telbook_ed_field == TELBOOK_F_CP)
    {
      telbook[tel_sel].cp866 = 1u;
      telbook_dirty = 1u;
    }
    else
    {
      char *buf = telbook_edit_buf(tel_sel, telbook_ed_field);
      if (telbook_ed_curs < (unsigned char)strlen(buf))
      {
        telbook_ed_curs++;
      }
      else
      {
        telbook_edit_next_field(tel_sel, 1);
      }
    }
    return 1u;
  }
  if (key == TELBOOK_KEY_LEFT)
  {
    telbook_ed_replace = 0u;
    if (telbook_ed_field == TELBOOK_F_CP)
    {
      telbook[tel_sel].cp866 = 0u;
      telbook_dirty = 1u;
    }
    else if (telbook_ed_curs > 0u)
    {
      telbook_ed_curs--;
    }
    else
    {
      telbook_edit_next_field(tel_sel, -1);
      telbook_edit_clamp_curs(tel_sel);
    }
    return 1u;
  }
  if (key == 8u)
  {
    telbook_edit_backspace(tel_sel);
    return 1u;
  }
  if (key == TELBOOK_KEY_UP || key == TELBOOK_KEY_DOWN)
  {
    return 0u;
  }
  if (key >= 0x20u && key <= 0x7Eu)
  {
    telbook_edit_insert(tel_sel, (char)key);
    return 1u;
  }
  return 0u;
}

#define TEL_RB_NONE 0u
#define TEL_RB_ROW 1u
#define TEL_RB_LIST 2u

static void telbook_redraw_flush(unsigned char *kind, unsigned char *old_sel,
                                 unsigned char *help)
{
  if (*kind == TEL_RB_LIST)
  {
    telbook_draw_list();
  }
  else if (*kind == TEL_RB_ROW)
  {
    telbook_draw_item_if_visible(*old_sel);
    telbook_draw_item_if_visible(tel_sel);
  }
  if (*help != 0u)
  {
    telbook_draw_help();
    telbook_draw_global_hint();
  }
  *kind = TEL_RB_NONE;
  *help = 0u;
}

int r_telbook_run(char *host, unsigned int host_sz, unsigned int *port,
                unsigned char *cp866, unsigned char *debug)
{
  unsigned char key;
  unsigned char rb_kind;
  unsigned char rb_old_sel;
  unsigned char rb_help;
  unsigned char total;

  telbook_debug = (debug != 0u && *debug != 0u) ? 1u : 0u;
  telbook_editing = 0u;
  telbook_load();
  telbook_ensure_entries();
  tel_sel = 0u;
  tel_scroll = 0u;
  telbook_draw_static();
  while ((OS_GETKEY() & 0xFFL) != 0L)
  {
    YIELD();
  }
  rb_kind = TEL_RB_LIST;
  rb_old_sel = 0u;
  rb_help = 0u;

  for (;;)
  {
    if (rb_kind != TEL_RB_NONE || rb_help != 0u)
    {
      telbook_redraw_flush(&rb_kind, &rb_old_sel, &rb_help);
    }
    if (telbook_editing != 0u)
    {
      telbook_park_cursor();
    }

    YIELD();
    key = (unsigned char)(OS_GETKEY() & 0xFFL);
    if (key == 0u)
    {
      continue;
    }

    if (telbook_editing != 0u)
    {
      if (telbook_handle_edit_key(key) != 0u)
      {
        rb_old_sel = tel_sel;
        rb_kind = TEL_RB_ROW;
        if (telbook_editing == 0u)
        {
          rb_help = 1u;
        }
        continue;
      }
    }

    total = telbook_total_items();
    if (key == TELBOOK_KEY_UP || key == 'A' || key == 'a')
    {
      if (tel_sel > 0u)
      {
        unsigned char old_sel = tel_sel;
        unsigned char old_scroll = tel_scroll;
        unsigned char was_editing = telbook_editing;

        telbook_end_edit(1u);
        tel_sel--;
        if (tel_sel < tel_scroll)
        {
          tel_scroll = tel_sel;
        }
        if (was_editing != 0u)
        {
          rb_help = 1u;
        }
        if (old_scroll != tel_scroll)
        {
          rb_kind = TEL_RB_LIST;
        }
        else
        {
          rb_old_sel = old_sel;
          rb_kind = TEL_RB_ROW;
        }
      }
    }
    else if (key == TELBOOK_KEY_DOWN || key == 'B' || key == 'b')
    {
      if (tel_sel + 1u < total)
      {
        unsigned char old_sel = tel_sel;
        unsigned char old_scroll = tel_scroll;
        unsigned char was_editing = telbook_editing;

        telbook_end_edit(1u);
        tel_sel++;
        if (tel_sel >= tel_scroll + TELBOOK_VIEW_H)
        {
          tel_scroll = (unsigned char)(tel_sel - TELBOOK_VIEW_H + 1u);
        }
        if (was_editing != 0u)
        {
          rb_help = 1u;
        }
        if (old_scroll != tel_scroll)
        {
          rb_kind = TEL_RB_LIST;
        }
        else
        {
          rb_old_sel = old_sel;
          rb_kind = TEL_RB_ROW;
        }
      }
    }
    else if (key == 13u)
    {
      if (telbook[tel_sel].host[0] != 0)
      {
        telbook_end_edit(1u);
        strncpy(host, telbook[tel_sel].host, host_sz - 1u);
        host[host_sz - 1u] = 0;
        *port = telbook[tel_sel].port;
        *cp866 = telbook[tel_sel].cp866;
        if (debug != 0u)
        {
          *debug = telbook_debug;
        }
        return 1;
      }
    }
    else if (key == 'e' || key == 'E')
    {
      telbook_begin_edit(tel_sel);
      rb_old_sel = tel_sel;
      rb_kind = TEL_RB_ROW;
      rb_help = 1u;
    }
    else if (key == TELBOOK_KEY_INS || key == 'n' || key == 'N')
    {
      telbook_add_entry();
      rb_kind = TEL_RB_LIST;
    }
    else if (key == 'g' || key == 'G')
    {
      telbook_debug = (unsigned char)(1u - telbook_debug);
    }
    else if (key == TELBOOK_KEY_DEL || key == 'd')
    {
      telbook_delete_entry();
      rb_kind = TEL_RB_LIST;
    }
    else if (key == TELBOOK_KEY_F2 || key == 's' || key == 'S')
    {
      unsigned char was_editing = telbook_editing;

      telbook_end_edit(1u);
      (void)telbook_save();
      if (was_editing != 0u)
      {
        rb_help = 1u;
      }
    }
    else if (key == 27u)
    {
      telbook_end_edit(0u);
      if (telbook_confirm_quit())
      {
        return 0;
      }
      telbook_draw_static();
      rb_kind = TEL_RB_LIST;
    }
  }
}
