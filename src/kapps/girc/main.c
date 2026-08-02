/*
 * girc - graphical IRC client for NedoOS
 * UI: cdplay / ngsplay / gcalc
 * Net: ZXNETUSB only (OS sockets via network.c)
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <tcp.h>
#include <intrz80.h>

#define true 1
#define false 0

#define BR_NORMAL 0x00
#define BR_INK 0x40
#define BR_PAPER 0x80
#define BR_BOTH 0xC0
#define MKCOLOR(b, p, i) ((unsigned char)((b) | (p) | (i)))

#define COL_TITLE MKCOLOR(BR_BOTH, PAPER_BLUE, INK_WHITE)
#define COL_STATUS MKCOLOR(BR_BOTH, PAPER_BLUE, INK_YELLOW)
#define COL_FRAME MKCOLOR(BR_INK, PAPER_BLACK, INK_YELLOW)
#define COL_CHAT MKCOLOR(BR_NORMAL, PAPER_BLACK, INK_WHITE)
#define COL_SYS MKCOLOR(BR_INK, PAPER_BLACK, INK_CYAN)
#define COL_PRIV MKCOLOR(BR_INK, PAPER_BLACK, INK_GREEN)
#define COL_ERR MKCOLOR(BR_BOTH, PAPER_RED, INK_WHITE)
#define COL_INPUT MKCOLOR(BR_BOTH, PAPER_BLACK, INK_YELLOW)
#define COL_NICKS MKCOLOR(BR_NORMAL, PAPER_BLUE, INK_WHITE)
#define COL_DLG MKCOLOR(BR_BOTH, PAPER_MAGENTA, INK_WHITE)
#define COL_FIELD MKCOLOR(BR_BOTH, PAPER_BLACK, INK_WHITE)
#define COL_FIELDFOC MKCOLOR(BR_BOTH, PAPER_BLACK, INK_YELLOW)
#define COL_BTN MKCOLOR(BR_BOTH, PAPER_GREEN, INK_BLACK)
#define COL_BTNQUIT MKCOLOR(BR_BOTH, PAPER_RED, INK_WHITE)
#define COL_HINT MKCOLOR(BR_NORMAL, PAPER_BLACK, INK_CYAN)

#define KEY_ENTER 13
#define KEY_ESC 27
#define KEY_BS 8
#define KEY_TAB 9
#define KEY_DEL 252
#define KEY_LEFT 248
#define KEY_RIGHT 251
#define KEY_UP 250
#define KEY_DOWN 249
#define KEY_HOME 28
#define KEY_END 30
#define KEY_F1 177
#define KEY_F2 178
#define KEY_F10 176
#define KEY_FOCUS 31

#define SCR_CONNECT 0
#define SCR_CHAT 1

#define MAX_HOST 48
#define MAX_NICK 24
#define MAX_CHAN 32
#define MAX_PORTSTR 5
#define MAX_INPUT 200
#define MAX_LINE 400
#define LOG_CAP 100
#define VIEW_H 16
#define LOG_W 60
#define CHAT_X 2
#define CHAT_Y 2
#define NICK_X 64
#define NICK_W 12
#define MAX_NICKS 22
#define NETBUF_SIZE 4096

/* Rows 0..23 only ? writing col 80 on row 24 scrolls the screen */
#define ROW_TITLE 0
#define ROW_INFRAME 19 /* yellow frame around input: rows 19..21 */
#define ROW_INPUT 20
#define ROW_STATUS 23
#define COLS_SAFE 79

/* Frame cols 1..78; interior 2..77. Send fits in 70..77 (not on right border). */
#define INPUT_VIS 66
#define INPUT_X 2
#define SEND_X 70
#define SEND_W 8
#define INP_FRM_X 1
#define INP_FRM_W 78

#define NICK_LIST_Y (CHAT_Y + 1)
#define NICK_VIEW (VIEW_H - 1)

/* Single-line box drawing (CP866) */
#define SYM_TL 218
#define SYM_TR 191
#define SYM_BL 192
#define SYM_BR 217
#define SYM_H 196
#define SYM_V 179

#define OS_CALL_OK(todo) ((todo) <= 32767)
#define OS_CALL_ERR(todo) ((unsigned char)((todo) & 255))

/* ---- globals for network.c (ZXNET) ---- */
unsigned char cmd[512];
unsigned char netbuf[NETBUF_SIZE];
unsigned char curPath[128];
unsigned char crlf[2] = {13, 10};
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char uVer[] = "0.5";
unsigned char netDriver = 0;

struct sockaddr_in targetadr;
struct readstructure readStruct;
struct sockaddr_in dnsaddress;

unsigned int RBR_THR = 0xf8ef;
unsigned int IER = 0xf9ef;
unsigned int IIR_FCR = 0xfaef;
unsigned int LCR = 0xfbef;
unsigned int MCR = 0xfcef;
unsigned int LSR = 0xfdef;
unsigned int MSR = 0xfeef;
unsigned int SR = 0xffef;
unsigned int divider = 1;
unsigned int comType = 0;
unsigned int espType = 32;
unsigned int espRetry = 5;
unsigned long factor, timerok;
const unsigned int magic = 11;

/* ---- app state ---- */
static unsigned char g_scr;
static signed char g_sock = -1;
static unsigned char g_conn;
static unsigned char g_joined;
static unsigned char g_registered;
/* Defer TX until irc_feed() finishes (netbuf still in use). */
static unsigned char g_need_join;
static unsigned char g_need_pong;
static char g_pingarg[96];

static char g_host[MAX_HOST + 1];
static char g_portstr[MAX_PORTSTR + 1];
static unsigned int g_port;
static char g_nick[MAX_NICK + 1];
static char g_chan[MAX_CHAN + 1];
static char g_input[MAX_INPUT + 1];
static unsigned char g_inlen;
static unsigned char g_incurs;
static unsigned char g_instart; /* horizontal scroll for long input */

static char g_rxline[MAX_LINE];
static unsigned int g_rxlen;

static char g_log[LOG_CAP][LOG_W + 1];
static unsigned char g_logcol[LOG_CAP];
static unsigned int g_logn;
static unsigned int g_loghead;
static unsigned int g_view_off; /* 0 = follow bottom */

static char g_nicks[MAX_NICKS][NICK_W + 1];
static unsigned char g_nnicks;
static unsigned char g_nick_scroll;

static unsigned char g_field;
static unsigned char g_fcurs; /* caret in connect dialog field */
static unsigned char g_chrome;
static unsigned char g_need_chrome;
static unsigned char g_need_nicks;
static unsigned char g_need_title;
static char g_status[72];

/* Soft mouse (ngsplay/term style) */
#define MX_FACT 4u
#define MY_FACT 8u
#define MX_MAX ((80u - 1u) * MX_FACT)
/* Keep soft mouse off status row ? PRATTR trash looked like "я┐╜->" there */
#define MY_MAX (22u * MY_FACT)
#define LMB_MASK 0x01u
#define WHEEL_MASK 0xf0u
#define CURSOR_ATTR 0x38u

static unsigned char m_raw_x, m_raw_y, m_raw_btns, m_raw_wheel;
static unsigned int m_x_fp, m_y_fp;
static unsigned char m_cell_x, m_cell_y;
static unsigned char m_saved_attr, m_cursor_on, m_inited, m_have_sample;
static unsigned char m_lmb_click;
static signed char m_wheel_delta;

/* connect dialog button hitboxes */
#define BTN_CX 22
#define BTN_CY 14
#define BTN_CW 12
#define BTN_QX 42
#define BTN_QY 14
#define BTN_QW 10

#define FLD_Y_SERVER 5
#define FLD_Y_PORT 7
#define FLD_Y_NICK 9
#define FLD_Y_CHANNEL 11

#define FOC_SERVER 0
#define FOC_PORT 1
#define FOC_NICK 2
#define FOC_CHAN 3
#define FOC_CONNECT 4
#define FOC_QUIT 5
#define FOC_COUNT 6

/* ---- tiny UI helpers ---- */
static void spaces(unsigned char n)
{
	while (n > 0)
	{
		putchar(' ');
		n--;
	}
}
void clearStatus(void)
{
}

#include <../common/esp-com.c>
#include <../common/esp-com2.c>
#include <../common/network.c>

/* Invert ink/paper (keep bright bits) ? text caret like term.com */
static unsigned char inv_attr(unsigned char a)
{
	return (unsigned char)(((a & 7u) << 3) | ((a >> 3) & 7u) | (a & 0xC0u));
}

static void paint_caret(unsigned char x, unsigned char y, unsigned char base_attr)
{
	OS_SETXY(x, y);
	OS_PRATTR(inv_attr(base_attr));
}

static void fill_row(unsigned char x, unsigned char y, unsigned char w, unsigned char c)
{
	OS_SETCOLOR(c);
	OS_SETXY(x, y);
	spaces(w);
}

static void draw_box(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char c)
{
	unsigned char i, j;
	OS_SETCOLOR(c);
	for (j = 0; j < h; j++)
	{
		OS_SETXY(x, y + j);
		for (i = 0; i < w; i++)
			putchar(' ');
	}
}

static void draw_frm(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char c)
{
	unsigned char i;
	OS_SETCOLOR(c);
	OS_SETXY(x, y);
	putchar(SYM_TL);
	for (i = 0; i < w - 2; i++)
		putchar(SYM_H);
	putchar(SYM_TR);
	for (i = 1; i < h - 1; i++)
	{
		OS_SETXY(x, y + i);
		putchar(SYM_V);
		OS_SETXY(x + w - 1, y + i);
		putchar(SYM_V);
	}
	OS_SETXY(x, y + h - 1);
	putchar(SYM_BL);
	for (i = 0; i < w - 2; i++)
		putchar(SYM_H);
	putchar(SYM_BR);
}

static void draw_title(const char *t)
{
	fill_row(0, ROW_TITLE, COLS_SAFE, COL_TITLE);
	OS_SETXY(1, ROW_TITLE);
	OS_SETCOLOR(COL_TITLE);
	printf("girc %s  %.60s", uVer, t);
	g_need_title = 0;
}

static void set_status(const char *s)
{
	strncpy(g_status, s, sizeof(g_status) - 1);
	g_status[sizeof(g_status) - 1] = 0;
}

static void draw_status(void)
{
	unsigned char i;
	unsigned char ch;
	unsigned char ended;

	OS_SETCOLOR(COL_STATUS);
	OS_SETXY(0, ROW_STATUS);
	ended = 0;
	/* Full-width putchar paint ? no printf (avoids cursor/wrap junk). */
	for (i = 0; i < COLS_SAFE; i++)
	{
		if (!ended)
		{
			ch = (unsigned char)g_status[i];
			if (ch == 0)
				ended = 1;
		}
		putchar(ended ? ' ' : (char)ch);
	}
}

/* ---- soft mouse ---- */
static void mouse_hide(void)
{
	if (!m_cursor_on)
		return;
	OS_SETXY(m_cell_x, m_cell_y);
	OS_PRATTR(m_saved_attr);
	m_cursor_on = 0;
}

static void mouse_show(void)
{
	if (m_cursor_on || !m_inited)
		return;
	OS_SETXY(m_cell_x, m_cell_y);
	m_saved_attr = OS_GETATTR();
	OS_PRATTR(CURSOR_ATTR);
	m_cursor_on = 1;
}

static void mouse_init(void)
{
	m_x_fp = 40u * MX_FACT;
	m_y_fp = 12u * MY_FACT;
	m_cell_x = 40;
	m_cell_y = 12;
	m_raw_x = 0;
	m_raw_y = 0;
	m_raw_btns = 0xff;
	m_raw_wheel = 0;
	m_have_sample = 0;
	m_cursor_on = 0;
	m_inited = 1;
	m_lmb_click = 0;
	m_wheel_delta = 0;
}

static void mouse_clamp(void)
{
	if (m_x_fp > MX_MAX)
		m_x_fp = MX_MAX;
	if (m_y_fp > MY_MAX)
		m_y_fp = MY_MAX;
	m_cell_x = (unsigned char)(m_x_fp / MX_FACT);
	m_cell_y = (unsigned char)(m_y_fp / MY_FACT);
}

static void mouse_apply_delta(signed char dx, signed char dy)
{
	int nx, ny;
	nx = (int)m_x_fp + (int)dx;
	if (nx < 0)
		nx = 0;
	if (nx > (int)MX_MAX)
		nx = (int)MX_MAX;
	m_x_fp = (unsigned int)nx;
	ny = (int)m_y_fp + (int)dy;
	if (ny < 0)
		ny = 0;
	if (ny > (int)MY_MAX)
		ny = (int)MY_MAX;
	m_y_fp = (unsigned int)ny;
	mouse_clamp();
}

static void mouse_poll(void)
{
	unsigned char nx, ny, nb, nw;
	signed char dx, dy;

	m_lmb_click = 0;
	m_wheel_delta = 0;
	if (!m_inited)
		return;

	nx = mouse_x;
	ny = mouse_y;
	nb = mouse_btns;
	nw = (unsigned char)(nb & WHEEL_MASK);

	if (!m_have_sample)
	{
		m_raw_x = nx;
		m_raw_y = ny;
		m_raw_btns = nb;
		m_raw_wheel = nw;
		m_have_sample = 1;
		mouse_show();
		return;
	}

	dx = (signed char)(nx - m_raw_x);
	dy = (signed char)(m_raw_y - ny);
	m_raw_x = nx;
	m_raw_y = ny;

	if (dx != 0 || dy != 0)
	{
		mouse_hide();
		mouse_apply_delta(dx, dy);
	}

	if (((m_raw_btns & LMB_MASK) != 0) && ((nb & LMB_MASK) == 0))
		m_lmb_click = 1;
	m_raw_btns = nb;

	if (nw != m_raw_wheel)
	{
		m_wheel_delta = (signed char)(nw - m_raw_wheel);
		m_raw_wheel = nw;
	}

	mouse_show();
}

static void draw_send_btn(void)
{
	draw_box(SEND_X, ROW_INPUT, SEND_W, 1, COL_BTN);
	OS_SETCOLOR(COL_BTN);
	OS_SETXY(SEND_X + 1, ROW_INPUT);
	printf(" Send ");
}

static void draw_input_frame(void)
{
	draw_frm(INP_FRM_X, ROW_INFRAME, INP_FRM_W, 3, COL_FRAME);
}

/* Keep caret inside the visible INPUT_VIS window; scroll only at edges. */
static void input_scroll_to_cursor(void)
{
	if (g_incurs < g_instart)
		g_instart = g_incurs;
	else if (g_incurs >= (unsigned char)(g_instart + INPUT_VIS))
		g_instart = (unsigned char)(g_incurs - INPUT_VIS + 1u);

	if (g_inlen < INPUT_VIS)
		g_instart = 0;
	else if (g_instart > (unsigned char)(g_inlen - INPUT_VIS + 1u))
		g_instart = (unsigned char)(g_inlen - INPUT_VIS + 1u);
}

static void draw_input(void)
{
	unsigned char i;
	unsigned char ch;
	unsigned char start;
	unsigned char curx;

	input_scroll_to_cursor();
	start = g_instart;

	/* Inside yellow frame; leave vertical borders at x=1 and x=78 */
	fill_row(INPUT_X, ROW_INPUT, (unsigned char)(SEND_X - INPUT_X), COL_INPUT);
	OS_SETCOLOR(COL_INPUT);
	OS_SETXY(INPUT_X, ROW_INPUT);
	putchar('>');
	putchar(' ');

	for (i = 0; i < INPUT_VIS; i++)
	{
		if ((unsigned int)start + i < (unsigned int)g_inlen)
		{
			ch = (unsigned char)g_input[start + i];
			putchar(ch ? ch : ' ');
		}
		else
		{
			putchar(' ');
		}
	}

	curx = (unsigned char)(INPUT_X + 2u + (g_incurs - start));
	if (curx >= SEND_X)
		curx = (unsigned char)(SEND_X - 1);
	paint_caret(curx, ROW_INPUT, COL_INPUT);
}

/* ---- chat log + hardware scroll ---- */
static unsigned int log_idx_from_back(unsigned int back)
{
	return (g_loghead + LOG_CAP - 1u - back) % LOG_CAP;
}

static void chat_paint_row(unsigned char row, unsigned char col, const char *s)
{
	unsigned char i;
	unsigned char ch;
	unsigned char ended;

	OS_SETCOLOR(col);
	OS_SETXY(CHAT_X, (unsigned char)(CHAT_Y + row));
	ended = 0;
	for (i = 0; i < LOG_W; i++)
	{
		if (!ended)
		{
			ch = (unsigned char)s[i];
			if (ch == 0)
				ended = 1;
		}
		putchar(ended ? ' ' : ch);
	}
}

static void chat_hw_up(void)
{
	OS_SCROLLUP(OS_SCROLL_XY(CHAT_Y, CHAT_X), OS_SCROLL_WH(VIEW_H, LOG_W));
}

static void chat_hw_down(void)
{
	OS_SCROLLDOWN(OS_SCROLL_XY(CHAT_Y, CHAT_X), OS_SCROLL_WH(VIEW_H, LOG_W));
}

static void chat_redraw_text(void)
{
	unsigned char row;
	unsigned int back;
	unsigned int idx;

	for (row = 0; row < VIEW_H; row++)
	{
		back = g_view_off + (unsigned int)(VIEW_H - 1u - row);
		if (back < g_logn)
		{
			idx = log_idx_from_back(back);
			chat_paint_row(row, g_logcol[idx], g_log[idx]);
		}
		else
		{
			chat_paint_row(row, COL_CHAT, "");
		}
	}
}

static void log_store_line(unsigned char col, const char *line)
{
	unsigned char i;
	char *dst;
	unsigned char ch;

	dst = g_log[g_loghead];
	g_logcol[g_loghead] = col;
	/* Clear full slot ? otherwise short lines keep a tail of the previous one */
	for (i = 0; i <= LOG_W; i++)
		dst[i] = 0;
	for (i = 0; i < LOG_W; i++)
	{
		ch = (unsigned char)line[i];
		if (ch == 0)
			break;
		dst[i] = (char)ch;
	}
	g_loghead = (g_loghead + 1u) % LOG_CAP;
	if (g_logn < LOG_CAP)
		g_logn++;
}

static void log_emit(unsigned char col, const char *line)
{
	unsigned int max_off;

	log_store_line(col, line);

	if (g_scr != SCR_CHAT || !g_chrome)
		return;

	if (g_view_off == 0)
	{
		chat_hw_up();
		chat_paint_row((unsigned char)(VIEW_H - 1), col, line);
		return;
	}

	/* scrolled up: keep position relative to bottom, clamp */
	max_off = (g_logn > VIEW_H) ? (g_logn - VIEW_H) : 0;
	if (g_view_off > max_off)
		g_view_off = max_off;
}

static void log_add(unsigned char col, const char *s)
{
	char chunk[LOG_W + 1];
	unsigned int len;
	unsigned int pos;

	if (s == 0)
		s = "";
	len = strlen(s);
	pos = 0;

	if (len == 0)
	{
		chunk[0] = 0;
		log_emit(col, chunk);
		return;
	}

	while (pos < len)
	{
		unsigned int n = len - pos;
		unsigned int take;
		unsigned int brk;
		unsigned int i;
		unsigned char ch;

		if (n > LOG_W)
		{
			take = LOG_W;
			brk = take;
			while (brk > (LOG_W / 2u))
			{
				ch = (unsigned char)s[pos + brk - 1u];
				if (ch == ' ')
					break;
				brk--;
			}
			if (brk > (LOG_W / 2u))
				take = brk;
		}
		else
		{
			take = n;
		}
		if (take == 0)
			take = 1;

		for (i = 0; i < take; i++)
			chunk[i] = s[pos + i];
		chunk[take] = 0;
		if (take > 0 && (unsigned char)chunk[take - 1u] == ' ')
			chunk[take - 1u] = 0;

		pos += take;
		while (pos < len && (unsigned char)s[pos] == ' ')
			pos++;

		log_emit(col, chunk);
	}
}

static void log_clear(void)
{
	g_logn = 0;
	g_loghead = 0;
	g_view_off = 0;
}

static void chat_view_line(int dir)
{
	unsigned int max_off;

	if (g_scr != SCR_CHAT || !g_chrome)
		return;
	if (g_logn <= VIEW_H)
		return;

	max_off = g_logn - VIEW_H;

	if (dir < 0)
	{
		/* older */
		if (g_view_off >= max_off)
			return;
		g_view_off++;
		chat_hw_down();
		chat_paint_row(0, g_logcol[log_idx_from_back(g_view_off + VIEW_H - 1u)],
					   g_log[log_idx_from_back(g_view_off + VIEW_H - 1u)]);
	}
	else
	{
		/* newer */
		if (g_view_off == 0)
			return;
		g_view_off--;
		chat_hw_up();
		chat_paint_row((unsigned char)(VIEW_H - 1),
					   g_logcol[log_idx_from_back(g_view_off)],
					   g_log[log_idx_from_back(g_view_off)]);
	}
}

static void chat_view_page(int dir)
{
	unsigned int max_off;

	if (g_scr != SCR_CHAT || !g_chrome)
		return;
	if (g_logn <= VIEW_H)
		return;

	max_off = g_logn - VIEW_H;
	if (dir < 0)
	{
		g_view_off += VIEW_H;
		if (g_view_off > max_off)
			g_view_off = max_off;
	}
	else
	{
		if (g_view_off > VIEW_H)
			g_view_off -= VIEW_H;
		else
			g_view_off = 0;
	}
	chat_redraw_text();
}

/* ---- nick list ---- */
static unsigned char nick_eq(const char *a, const char *b)
{
	unsigned char ca, cb;
	while (*a && *b)
	{
		ca = (unsigned char)*a++;
		cb = (unsigned char)*b++;
		if (ca >= 'A' && ca <= 'Z')
			ca = (unsigned char)(ca + 32);
		if (cb >= 'A' && cb <= 'Z')
			cb = (unsigned char)(cb + 32);
		if (ca != cb)
			return 0;
	}
	return (unsigned char)(*a == 0 && *b == 0);
}

static void nick_copy(char *dst, const char *n)
{
	unsigned char i;
	if (n[0] == '@' || n[0] == '+' || n[0] == '%' || n[0] == '~' || n[0] == '&')
		n++;
	for (i = 0; i <= NICK_W; i++)
		dst[i] = 0;
	for (i = 0; i < NICK_W && n[i] && n[i] != ' ' && n[i] != '\r' && n[i] != '\n'; i++)
		dst[i] = n[i];
}

static void nicks_clear(void)
{
	unsigned char i;
	g_nnicks = 0;
	g_nick_scroll = 0;
	for (i = 0; i < MAX_NICKS; i++)
		g_nicks[i][0] = 0;
	g_need_nicks = 1;
}

static void nick_add(const char *n)
{
	unsigned char j;
	char tmp[NICK_W + 1];

	nick_copy(tmp, n);
	if (tmp[0] == 0)
		return;

	for (j = 0; j < g_nnicks; j++)
	{
		if (nick_eq(g_nicks[j], tmp))
			return;
	}
	if (g_nnicks >= MAX_NICKS)
		return;
	nick_copy(g_nicks[g_nnicks], tmp);
	g_nnicks++;
	g_need_nicks = 1;
}

static void nick_del(const char *n)
{
	unsigned char i, j;
	char tmp[NICK_W + 1];

	nick_copy(tmp, n);
	if (tmp[0] == 0)
		return;

	for (i = 0; i < g_nnicks; i++)
	{
		if (nick_eq(g_nicks[i], tmp))
		{
			for (j = i; j + 1 < g_nnicks; j++)
				nick_copy(g_nicks[j], g_nicks[j + 1]);
			g_nnicks--;
			g_nicks[g_nnicks][0] = 0;
			if (g_nnicks <= NICK_VIEW)
				g_nick_scroll = 0;
			g_need_nicks = 1;
			return;
		}
	}
}

static void nick_rename(const char *oldn, const char *newn)
{
	unsigned char i;
	char told[NICK_W + 1];
	char tnew[NICK_W + 1];

	nick_copy(told, oldn);
	nick_copy(tnew, newn);
	if (told[0] == 0 || tnew[0] == 0)
		return;

	for (i = 0; i < g_nnicks; i++)
	{
		if (nick_eq(g_nicks[i], told))
		{
			nick_copy(g_nicks[i], tnew);
			g_need_nicks = 1;
			return;
		}
	}
	nick_add(tnew);
}

static void nick_paint_row(unsigned char y, const char *s)
{
	unsigned char i;
	unsigned char ch;
	unsigned char ended;

	OS_SETCOLOR(COL_NICKS);
	OS_SETXY(NICK_X + 1, y);
	ended = 0;
	for (i = 0; i < NICK_W; i++)
	{
		if (!ended)
		{
			ch = (unsigned char)s[i];
			if (ch == 0)
				ended = 1;
		}
		putchar(ended ? ' ' : ch);
	}
}

static void draw_nicks(void)
{
	unsigned char i;
	unsigned char idx;
	unsigned char max_off;

	if (g_nnicks > NICK_VIEW)
	{
		max_off = (unsigned char)(g_nnicks - NICK_VIEW);
		if (g_nick_scroll > max_off)
			g_nick_scroll = max_off;
	}
	else
	{
		g_nick_scroll = 0;
	}

	draw_box(NICK_X, CHAT_Y, 14, VIEW_H, COL_NICKS);
	OS_SETCOLOR(COL_TITLE);
	OS_SETXY(NICK_X + 1, CHAT_Y);
	printf(" Nicks");
	for (i = 0; i < NICK_VIEW; i++)
	{
		idx = (unsigned char)(g_nick_scroll + i);
		if (idx < g_nnicks)
			nick_paint_row((unsigned char)(NICK_LIST_Y + i), g_nicks[idx]);
		else
			nick_paint_row((unsigned char)(NICK_LIST_Y + i), "");
	}
	g_need_nicks = 0;
}

/* ---- network glue ---- */
static int parse_ipv4(const char *host, unsigned char *o)
{
	unsigned int octet;
	unsigned char idx;
	const char *p = host;

	for (idx = 0; idx < 4; idx++)
	{
		if (*p < '0' || *p > '9')
			return 0;
		octet = 0;
		while (*p >= '0' && *p <= '9')
		{
			octet = octet * 10u + (unsigned int)(*p - '0');
			p++;
		}
		if (octet > 255)
			return 0;
		o[idx] = (unsigned char)octet;
		if (idx < 3)
		{
			if (*p != '.')
				return 0;
			p++;
		}
	}
	return *p == 0;
}

static char readParamFromIni(void)
{
	FILE *fpini;
	unsigned char *count1;
	const char currentNetwork[] = "currentNetwork";
	unsigned char curNet = 0;

	OS_GETPATH((unsigned int)&curPath);

	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");

	fpini = OS_OPENHANDLE("network.ini", 0x80);
	if (((int)fpini) & 0xff)
	{
		OS_CHDIR(curPath);
		clearStatus();
		printf("network.ini not found.\r\n");
		getchar();
		return false;
	}

	OS_READHANDLE(netbuf, fpini, sizeof(netbuf) - 1);
	OS_CLOSEHANDLE(fpini);

	count1 = strstr(netbuf, currentNetwork);
	if (count1 != NULL)
	{
		sscanf(count1 + strlen(currentNetwork) + 1, "%u", &curNet);
	}

	OS_CHDIR(curPath);
	return curNet;
}

static void net_init_driver(void)
{
	netDriver = readParamFromIni();
	if (netDriver == 1)
	{
		loadEspConfig();
		uart_init(divider);
		espReBoot();
		set_status("ESP-COM ready");
	}
	else
	{
		get_dns();
		targetadr.family = AF_INET;
		targetadr.porth = 0;
		targetadr.portl = 0;
		targetadr.b1 = targetadr.b2 = targetadr.b3 = targetadr.b4 = 0;
		set_status("ZXNETUSB ready");
	}
}

/* BSS - never put MAX_LINE buffers on CSTACK (+300 only). */
static char g_sendline[MAX_LINE + 4];

static int irc_send_line(const char *line)
{
	unsigned int n, byte;
	signed int result;
	n = strlen(line);
	if (n >= MAX_LINE)
		n = MAX_LINE - 1;
	memcpy(g_sendline, line, n);
	g_sendline[n++] = '\r';
	g_sendline[n++] = '\n';
	g_sendline[n] = 0;

	result = -1;
	switch (netDriver)
	{
	case 0:
		result = tcpSend(g_sock, (unsigned int)g_sendline, n, 3);
		break;
	case 1:

		sprintf(netbuf, "AT+CIPSEND=%u", n);
		sendcommand(netbuf);

		do
		{
			byte = uartReadBlock();
			if (byte > 255)
			{
				writeLog("Timeout when waiting '>' ", "irc_send_line  ");
				return -1;
			}

			/* putchar(byte); */
		} while (byte != '>');

		result = putDataEsp((unsigned int)g_sendline, n);
		break;
	}

	return result;
}

static void net_close(void)
{
	switch (netDriver)
	{
	case 0:
		netShutDown(g_sock, 0);
		break;
	case 1:
		sendcommand("AT+CIPCLOSE");
		getAnswer3();
		break;
	}
	g_sock = -1;
	g_conn = 0;
	g_joined = 0;
	g_registered = 0;
	g_need_join = 0;
	g_need_pong = 0;
}

static int net_connect_host(void)
{
	unsigned char ip4[4];
	signed char s;
	unsigned char retry = 3;
	char tmp[96];
	g_port = (unsigned int)atoi(g_portstr);
	if (g_port == 0)
		g_port = 6667;

	switch (netDriver)
	{
	case 0:

		sprintf(tmp, "DNS %s ...", g_host);
		set_status(tmp);
		draw_status();

		if (parse_ipv4(g_host, ip4))
		{
			targetadr.b1 = ip4[0];
			targetadr.b2 = ip4[1];
			targetadr.b3 = ip4[2];
			targetadr.b4 = ip4[3];
		}
		else if (!dnsResolve(g_host))
		{
			set_status("DNS failed");
			return 0;
		}

		targetadr.family = AF_INET;
		targetadr.porth = (unsigned char)((g_port >> 8) & 0xFF);
		targetadr.portl = (unsigned char)(g_port & 0xFF);

		sprintf(tmp, "TCP %u.%u.%u.%u:%u",
				(unsigned int)targetadr.b1, (unsigned int)targetadr.b2,
				(unsigned int)targetadr.b3, (unsigned int)targetadr.b4, g_port);
		set_status(tmp);
		draw_status();

		s = OpenSock(AF_INET, SOCK_STREAM);
		if (s < 0)
		{
			set_status("socket error");
			return 0;
		}
		s = netConnect(s, 2);
		if (s < 0)
		{
			set_status("connect failed");
			return 0;
		}
		break;
	case 1:
		while (true)
		{
			sprintf(tmp, "Connecting[%u] to %s:%u...", retry, g_host, g_port);
			set_status(tmp);
			draw_status();

			sprintf(tmp, "AT+CIPSTART=\"TCP\",\"%s\",%u", g_host, g_port);
			sendcommand(tmp);

			getAnswer3(); /* CONNECT or ERROR */
			netbuf[128] = 0;
			if (strstr((char *)netbuf, "CONNECT") != NULL)
			{
				getAnswer3(); /* OK (gopher-style; some firmwares need it) */
				s = 1;
				break;
			}
			else
			{
				if (strstr((char *)netbuf, "ERROR") != NULL)
				{
					retry--;
					uartFlush(200);
					if (retry == 0)
					{
						return 0;
					}
				}
			}
		}
		break;
	}
	g_sock = s;
	g_conn = 1;
	return 1;
}

/* ---- IRC protocol ---- */
static int irc_register(void)
{
	unsigned int byte;
	int r, n;

	/* g_sendline is BSS ? never put NICK/USER on CSTACK */
	sprintf(g_sendline, "NICK %s\r\nUSER %s 0 * :girc on NedoOS\r\n", g_nick, g_nick);
	set_status("Sending NICK/USER...");
	n = strlen(g_sendline);
	draw_status();
	r = -1;
	switch (netDriver)
	{
	case 0:
		r = tcpSend(g_sock, (unsigned int)g_sendline, n, 3);
		break;
	case 1:

		sprintf(netbuf, "AT+CIPSEND=%u", n);
		sendcommand(netbuf);

		do
		{
			byte = uartReadBlock();
			if (byte > 255)
			{
				writeLog("Timeout when waiting '>' ", "irc_register   ");
				return -1;
			}

			/* putchar(byte); */
		} while (byte != '>');

		r = putDataEsp((unsigned int)g_sendline, n);
		break;
	}
	if (r < 0)
	{
		set_status("Register send failed");
		log_add(COL_ERR, "Register failed: send error");
		draw_status();
		return -1;
	}
	set_status("NICK/USER sent, wait server...");
	draw_status();
	log_add(COL_SYS, "NICK/USER sent");
	return 1;
}

static int irc_do_join(void)
{
	char line[80];
	unsigned char i, j;

	/* trim spaces from channel field */
	i = 0;
	while (g_chan[i] == ' ')
		i++;
	if (i)
	{
		j = 0;
		while (g_chan[i])
			g_chan[j++] = g_chan[i++];
		g_chan[j] = 0;
	}
	for (i = (unsigned char)strlen(g_chan); i > 0 && g_chan[i - 1] == ' '; i--)
		g_chan[i - 1] = 0;

	if (g_chan[0] == 0)
		return -1;
	sprintf(line, "JOIN %s", g_chan);
	return irc_send_line(line);
}

static char *irc_skip_prefix(char *p, char *nickout, unsigned char nlen)
{
	unsigned char i;
	if (*p != ':')
		return p;
	p++;
	for (i = 0; i + 1 < nlen && *p && *p != '!' && *p != '@' && *p != ' '; i++)
		nickout[i] = *p++;
	nickout[i] = 0;
	while (*p && *p != ' ')
		p++;
	while (*p == ' ')
		p++;
	return p;
}

static void irc_handle_line(char *line)
{
	char nick[MAX_NICK + 1];
	char *cmdp;
	char *p;
	unsigned int code;

	nick[0] = 0;
	cmdp = irc_skip_prefix(line, nick, sizeof(nick));

	if (strncmp(cmdp, "PING ", 5) == 0)
	{
		/* Defer PONG ? netbuf still owned by irc_feed. */
		strncpy(g_pingarg, cmdp + 5, sizeof(g_pingarg) - 1);
		g_pingarg[sizeof(g_pingarg) - 1] = 0;
		g_need_pong = 1;
		return;
	}

	if (strncmp(cmdp, "PRIVMSG ", 8) == 0)
	{
		p = cmdp + 8;
		while (*p && *p != ' ')
			p++;
		while (*p == ' ')
			p++;
		if (*p == ':')
			p++;
		/* Skip own messages ? already shown via local echo */
		if (nick[0] && nick_eq(nick, g_nick))
			return;
		sprintf((char *)cmd, "<%.12s> %s", nick, p);
		log_add(COL_PRIV, (char *)cmd);
		return;
	}

	if (strncmp(cmdp, "NOTICE ", 7) == 0)
	{
		p = cmdp + 7;
		while (*p && *p != ' ')
			p++;
		while (*p == ' ')
			p++;
		if (*p == ':')
			p++;
		sprintf((char *)cmd, "-%.12s- %s", nick[0] ? nick : "*", p);
		log_add(COL_SYS, (char *)cmd);
		return;
	}

	if (strncmp(cmdp, "JOIN ", 5) == 0)
	{
		p = cmdp + 5;
		if (*p == ':')
			p++;
		sprintf((char *)cmd, "* %.12s joined %s", nick, p);
		log_add(COL_SYS, (char *)cmd);
		nick_add(nick);
		if (nick_eq(nick, g_nick))
		{
			g_joined = 1;
			strncpy(g_chan, p, MAX_CHAN);
			g_chan[MAX_CHAN] = 0;
			g_need_title = 1;
		}
		return;
	}

	if (strncmp(cmdp, "PART ", 5) == 0 || strncmp(cmdp, "QUIT ", 5) == 0)
	{
		sprintf((char *)cmd, "* %.12s left", nick);
		log_add(COL_SYS, (char *)cmd);
		nick_del(nick);
		return;
	}

	if (strncmp(cmdp, "NICK ", 5) == 0)
	{
		p = cmdp + 5;
		if (*p == ':')
			p++;
		sprintf((char *)cmd, "* %.12s is now %s", nick, p);
		log_add(COL_SYS, (char *)cmd);
		nick_rename(nick, p);
		if (nick_eq(nick, g_nick))
		{
			nick_copy(g_nick, p);
			/* g_nick is MAX_NICK wide ? ensure terminate */
			g_nick[MAX_NICK] = 0;
			g_need_title = 1;
		}
		return;
	}

	/* numeric */
	if (cmdp[0] >= '0' && cmdp[0] <= '9')
	{
		code = (unsigned int)atoi(cmdp);
		p = cmdp;
		while (*p && *p != ' ')
			p++; /* code */
		while (*p == ' ')
			p++;
		while (*p && *p != ' ')
			p++; /* target */
		while (*p == ' ')
			p++;
		if (*p == ':')
			p++;

		if (code == 1)
		{
			g_registered = 1;
			sprintf((char *)cmd, "Welcome %s", p);
			log_add(COL_SYS, (char *)cmd);
			/* JOIN only after 376/422 ? not here (MOTD still in flight). */
		}
		else if (code == 353)
		{
			/* NAMES: skip channel type + channel name */
			while (*p && *p != ' ')
				p++;
			while (*p == ' ')
				p++;
			while (*p && *p != ' ')
				p++;
			while (*p == ' ')
				p++;
			if (*p == ':')
				p++;
			while (*p)
			{
				char *q = p;
				while (*q && *q != ' ')
					q++;
				if (*q)
					*q++ = 0;
				nick_add(p);
				p = q;
			}
		}
		else if (code == 366)
		{
			g_joined = 1;
			set_status("Joined - Up/Dn scroll, F1/F2 page");
			draw_status();
		}
		else if (code == 372 || code == 375 || code == 376 || code == 422)
		{
			log_add(COL_SYS, p);
			if ((code == 376 || code == 422) && !g_joined && g_chan[0])
				g_need_join = 1;
		}
		else if (code >= 400 && code < 600)
		{
			sprintf((char *)cmd, "ERR %u: %s", code, p);
			log_add(COL_ERR, (char *)cmd);
		}
		else
		{
			sprintf((char *)cmd, "[%u] %s", code, p);
			log_add(COL_SYS, (char *)cmd);
		}
		return;
	}

	log_add(COL_CHAT, line);
}

static void irc_feed(const unsigned char *data, unsigned int len)
{
	unsigned int i;
	for (i = 0; i < len; i++)
	{
		unsigned char c = data[i];
		if (c == '\r')
			continue;
		if (c == '\n')
		{
			if (g_rxlen > 0)
			{
				g_rxline[g_rxlen] = 0;
				irc_handle_line(g_rxline);
				g_rxlen = 0;
			}
			continue;
		}
		if (g_rxlen + 1 < MAX_LINE)
			g_rxline[g_rxlen++] = (char)c;
	}
}

static void irc_user_cmd(char *line)
{
	char *arg;
	char *p;

	if (line[0] != '/')
	{
		if (!g_joined || g_chan[0] == 0)
		{
			log_add(COL_ERR, "Not in channel - /join #chan");
			return;
		}
		sprintf((char *)cmd, "PRIVMSG %s :%s", g_chan, line);
		irc_send_line((char *)cmd);
		sprintf((char *)cmd, "<%.12s> %s", g_nick, line);
		log_add(COL_PRIV, (char *)cmd);
		return;
	}

	arg = line + 1;
	while (*arg == ' ')
		arg++;

	if (strncmp(arg, "join ", 5) == 0 || strncmp(arg, "JOIN ", 5) == 0)
	{
		strncpy(g_chan, arg + 5, MAX_CHAN);
		g_chan[MAX_CHAN] = 0;
		nicks_clear();
		g_need_title = 1;
		irc_do_join();
	}
	else if (strncmp(arg, "part", 4) == 0 || strncmp(arg, "PART", 4) == 0)
	{
		sprintf((char *)cmd, "PART %s", g_chan[0] ? g_chan : "*");
		irc_send_line((char *)cmd);
		g_joined = 0;
	}
	else if (strncmp(arg, "nick ", 5) == 0 || strncmp(arg, "NICK ", 5) == 0)
	{
		sprintf((char *)cmd, "NICK %s", arg + 5);
		irc_send_line((char *)cmd);
	}
	else if (strncmp(arg, "msg ", 4) == 0 || strncmp(arg, "MSG ", 4) == 0)
	{
		char *t = arg + 4;
		char *m;
		while (*t == ' ')
			t++;
		m = t;
		while (*m && *m != ' ')
			m++;
		if (*m)
			*m++ = 0;
		while (*m == ' ')
			m++;
		sprintf((char *)cmd, "PRIVMSG %s :%s", t, m);
		irc_send_line((char *)cmd);
		sprintf((char *)cmd, "->%.12s: %s", t, m);
		log_add(COL_PRIV, (char *)cmd);
	}
	else if (strncmp(arg, "me ", 3) == 0 || strncmp(arg, "ME ", 3) == 0)
	{
		sprintf((char *)cmd, "PRIVMSG %s :\001ACTION %s\001", g_chan, arg + 3);
		irc_send_line((char *)cmd);
		sprintf((char *)cmd, "* %.12s %s", g_nick, arg + 3);
		log_add(COL_SYS, (char *)cmd);
	}
	else if (strncmp(arg, "quit", 4) == 0 || strncmp(arg, "QUIT", 4) == 0)
	{
		irc_send_line("QUIT :girc");
		net_close();
		g_scr = SCR_CONNECT;
		g_chrome = 0;
		g_need_chrome = 1;
		set_status("Disconnected");
	}
	else if (strncmp(arg, "list", 4) == 0 || strncmp(arg, "LIST", 4) == 0)
	{
		irc_send_line("LIST");
		log_add(COL_SYS, "Requesting channel list...");
	}
	else if (strncmp(arg, "info", 4) == 0 || strncmp(arg, "INFO", 4) == 0)
	{
		irc_send_line("INFO");
		log_add(COL_SYS, "Requesting server info...");
	}
	else if (strncmp(arg, "server ", 7) == 0 || strncmp(arg, "SERVER ", 7) == 0)
	{
		p = arg + 7;
		while (*p == ' ')
			p++;
		if (*p == 0)
		{
			log_add(COL_ERR, "Usage: /server hostname");
			return;
		}
		strncpy(g_host, p, MAX_HOST);
		g_host[MAX_HOST] = 0;
		if (g_conn)
		{
			irc_send_line("QUIT :reconnect");
			net_close();
		}
		g_joined = 0;
		g_registered = 0;
		nicks_clear();
		g_need_title = 1;
		if (!net_connect_host())
		{
			set_status("Connect failed");
			draw_status();
			g_scr = SCR_CONNECT;
			g_chrome = 0;
			g_need_chrome = 1;
			return;
		}
		g_scr = SCR_CHAT;
		g_chrome = 0;
		g_need_chrome = 1;
		sprintf((char *)cmd, "Connected to %s:%u", g_host, g_port);
		log_add(COL_SYS, (char *)cmd);
		irc_register();
		set_status("Reconnected, registering...");
		draw_status();
	}
	else if (strncmp(arg, "topic", 5) == 0 || strncmp(arg, "TOPIC", 5) == 0)
	{
		char *chan;
		char *text;
		p = arg + 5;
		while (*p == ' ')
			p++;
		if (*p == 0)
		{
			if (g_chan[0] == 0)
			{
				log_add(COL_ERR, "Usage: /topic #chan [text]");
				return;
			}
			sprintf((char *)cmd, "TOPIC %s", g_chan);
			irc_send_line((char *)cmd);
			return;
		}
		chan = p;
		while (*p && *p != ' ')
			p++;
		if (*p == 0)
		{
			if (chan[0] == '#' || chan[0] == '&')
			{
				sprintf((char *)cmd, "TOPIC %s", chan);
			}
			else
			{
				if (g_chan[0] == 0)
				{
					log_add(COL_ERR, "Usage: /topic #chan [text]");
					return;
				}
				sprintf((char *)cmd, "TOPIC %s :%s", g_chan, chan);
			}
			irc_send_line((char *)cmd);
			return;
		}
		*p++ = 0;
		while (*p == ' ')
			p++;
		text = p;
		if (chan[0] == '#' || chan[0] == '&')
			sprintf((char *)cmd, "TOPIC %s :%s", chan, text);
		else
		{
			if (g_chan[0] == 0)
			{
				log_add(COL_ERR, "Usage: /topic #chan [text]");
				return;
			}
			sprintf((char *)cmd, "TOPIC %s :%s", g_chan, chan);
		}
		irc_send_line((char *)cmd);
	}
	else if (strncmp(arg, "raw ", 4) == 0 || strncmp(arg, "RAW ", 4) == 0)
	{
		irc_send_line(arg + 4);
	}
	else if (strncmp(arg, "help", 4) == 0)
	{
		log_add(COL_SYS, "/join /part /nick /msg /me /topic /list /info /server /quit /raw");
	}
	else
	{
		log_add(COL_ERR, "Unknown cmd - /help");
	}
}

/* ---- screens ---- */
static void field_ptr(unsigned char f, char **pp, unsigned char *maxlen)
{
	switch (f)
	{
	case 0:
		*pp = g_host;
		*maxlen = MAX_HOST;
		break;
	case 1:
		*pp = g_portstr;
		*maxlen = MAX_PORTSTR;
		break;
	case 2:
		*pp = g_nick;
		*maxlen = MAX_NICK;
		break;
	default:
		*pp = g_chan;
		*maxlen = MAX_CHAN;
		break;
	}
}

static void draw_field_row(unsigned char y, const char *label, const char *val, unsigned char foc, unsigned char vwidth, unsigned char curs)
{
	unsigned char i;
	unsigned char ch;
	unsigned char cx;

	OS_SETCOLOR(COL_DLG);
	OS_SETXY(14, y);
	printf("%-8s", label);
	OS_SETCOLOR(foc ? COL_FIELDFOC : COL_FIELD);
	OS_SETXY(24, y);
	putchar('[');
	for (i = 0; i < vwidth; i++)
	{
		ch = (unsigned char)val[i];
		putchar(ch ? ch : ' ');
	}
	putchar(']');
	if (foc)
	{
		cx = curs;
		if (cx > vwidth)
			cx = vwidth;
		paint_caret((unsigned char)(25 + cx), y, COL_FIELDFOC);
	}
}

static void sanitize_port(void)
{
	char tmp[MAX_PORTSTR + 1];
	unsigned char i, j;

	j = 0;
	for (i = 0; g_portstr[i] && j < MAX_PORTSTR; i++)
	{
		if (g_portstr[i] >= '0' && g_portstr[i] <= '9')
			tmp[j++] = g_portstr[i];
	}
	tmp[j] = 0;
	if (j == 0)
		strcpy(tmp, "6667");
	strcpy(g_portstr, tmp);
}

static void draw_connect_fields(void)
{
	unsigned char clen;
	char *fp;
	unsigned char maxlen;

	if (g_field < FOC_CONNECT)
	{
		field_ptr(g_field, &fp, &maxlen);
		clen = (unsigned char)strlen(fp);
		if (g_fcurs > clen)
			g_fcurs = clen;
	}

	draw_field_row(FLD_Y_SERVER, "Server", g_host, g_field == FOC_SERVER, 40,
				   (unsigned char)(g_field == FOC_SERVER ? g_fcurs : strlen(g_host)));
	draw_field_row(FLD_Y_PORT, "Port", g_portstr, g_field == FOC_PORT, 5,
				   (unsigned char)(g_field == FOC_PORT ? g_fcurs : strlen(g_portstr)));
	draw_field_row(FLD_Y_NICK, "Nick", g_nick, g_field == FOC_NICK, 24,
				   (unsigned char)(g_field == FOC_NICK ? g_fcurs : strlen(g_nick)));
	draw_field_row(FLD_Y_CHANNEL, "Channel", g_chan, g_field == FOC_CHAN, 32,
				   (unsigned char)(g_field == FOC_CHAN ? g_fcurs : strlen(g_chan)));
}

static void draw_connect_buttons(void)
{
	unsigned char c;

	c = (g_field == FOC_CONNECT) ? inv_attr(COL_BTN) : COL_BTN;
	draw_box(BTN_CX, BTN_CY, BTN_CW, 1, c);
	OS_SETCOLOR(c);
	OS_SETXY(BTN_CX + 2, BTN_CY);
	printf(" Connect ");

	c = (g_field == FOC_QUIT) ? inv_attr(COL_BTNQUIT) : COL_BTNQUIT;
	draw_box(BTN_QX, BTN_QY, BTN_QW, 1, c);
	OS_SETCOLOR(c);
	OS_SETXY(BTN_QX + 2, BTN_QY);
	printf(" Quit ");
}

static void draw_connect_focus(void)
{
	draw_connect_fields();
	draw_connect_buttons();
}

static void connect_focus_next(signed char dir)
{
	char *fp;
	unsigned char maxlen;

	g_field = (unsigned char)((g_field + dir + FOC_COUNT) % FOC_COUNT);
	if (g_field < FOC_CONNECT)
	{
		field_ptr(g_field, &fp, &maxlen);
		g_fcurs = (unsigned char)strlen(fp);
	}
	draw_connect_focus();
}

static void draw_connect(void)
{
	OS_CLS(0);
	draw_title("[ZXNETUSB]");
	draw_frm(10, 2, 60, 14, COL_DLG);
	draw_box(11, 3, 58, 12, COL_DLG);

	OS_SETCOLOR(COL_DLG);
	OS_SETXY(28, 3);
	printf("[ Connect to IRC ]");

	draw_connect_focus();

	OS_SETCOLOR(COL_HINT);
	OS_SETXY(14, 16);
	printf("Tab=next  Enter=ok  Esc/F10=quit");
	draw_status();
	g_chrome = 1;
	g_need_chrome = 0;
}

static void draw_chat_title(void)
{
	char tit[64];
	sprintf(tit, "%s @ %s  %s", g_nick, g_host, g_chan);
	draw_title(tit);
}

static void draw_chat(void)
{
	OS_CLS(0);
	draw_chat_title();
	draw_frm(CHAT_X - 1, CHAT_Y - 1, LOG_W + 2, VIEW_H + 2, COL_FRAME);
	draw_frm(NICK_X - 1, CHAT_Y - 1, 16, VIEW_H + 2, COL_FRAME);
	chat_redraw_text();
	draw_nicks();
	draw_input_frame();
	draw_input();
	draw_send_btn();
	draw_status();
	g_chrome = 1;
	g_need_chrome = 0;
}

static void redraw(void)
{
	g_chrome = 0;
	if (g_scr == SCR_CONNECT)
		draw_connect();
	else
		draw_chat();
}

static void do_connect(void)
{
	char msg[80];

	sanitize_port();

	if (g_host[0] == 0 || g_nick[0] == 0)
	{
		set_status("Need server and nick");
		draw_status();
		return;
	}

	log_clear();
	nicks_clear();
	g_rxlen = 0;
	g_inlen = 0;
	g_incurs = 0;
	g_instart = 0;
	g_input[0] = 0;
	g_joined = 0;
	g_registered = 0;

	if (!net_connect_host())
	{
		set_status("Connect failed");
		draw_status();
		return;
	}

	g_scr = SCR_CHAT;
	g_chrome = 0;
	sprintf(msg, "Connected - registering as %s", g_nick);
	set_status(msg);
	log_add(COL_SYS, msg);
	/* Register immediately after TCP is up. */
	if (irc_register() == true)
		set_status("Up/Dn=scroll  Esc=disconnect  F10=quit  /help");
	g_need_chrome = 1;
}

static void do_disconnect(void)
{
	if (g_conn)
	{
		irc_send_line("QUIT :bye");
		net_close();
	}
	g_scr = SCR_CONNECT;
	g_chrome = 0;
	set_status("Disconnected");
	g_need_chrome = 1;
}

/* ---- input editing ---- */
static void edit_char(char *buf, unsigned char *len, unsigned char *curs, unsigned char maxlen, unsigned char k)
{
	if (k == KEY_BS)
	{
		if (*curs > 0)
		{
			unsigned char i;
			for (i = (unsigned char)(*curs - 1); i < *len; i++)
				buf[i] = buf[i + 1];
			(*len)--;
			(*curs)--;
			buf[*len] = 0;
		}
		return;
	}
	if (k == KEY_DEL)
	{
		if (*curs < *len)
		{
			unsigned char i;
			for (i = *curs; i < *len; i++)
				buf[i] = buf[i + 1];
			(*len)--;
			buf[*len] = 0;
		}
		return;
	}
	if (k == KEY_LEFT)
	{
		if (*curs > 0)
			(*curs)--;
		return;
	}
	if (k == KEY_RIGHT)
	{
		if (*curs < *len)
			(*curs)++;
		return;
	}
	if (k == KEY_HOME)
	{
		*curs = 0;
		return;
	}
	if (k == KEY_END)
	{
		*curs = *len;
		return;
	}
	/* ASCII 32..126 + CP866 128..255 (Cyrillic / pseudographics) */
	if (k >= 32 && k != 127)
	{
		if (*len < maxlen)
		{
			unsigned char i;
			for (i = *len; i > *curs; i--)
				buf[i] = buf[i - 1];
			buf[*curs] = (char)k;
			(*len)++;
			(*curs)++;
			buf[*len] = 0;
		}
	}
}

static void handle_connect_key(unsigned char k)
{
	char *fp;
	unsigned char maxlen;
	unsigned char len;

	if (k == KEY_F10)
	{
		exit(0);
	}
	if (k == KEY_TAB || k == KEY_DOWN)
	{
		connect_focus_next(1);
		return;
	}
	if (k == KEY_UP)
	{
		connect_focus_next(-1);
		return;
	}
	if (g_field >= FOC_CONNECT)
	{
		if (k == KEY_LEFT || k == KEY_RIGHT)
		{
			g_field = (g_field == FOC_CONNECT) ? FOC_QUIT : FOC_CONNECT;
			draw_connect_focus();
			return;
		}
		if (k == KEY_ENTER || k == ' ')
		{
			if (g_field == FOC_CONNECT)
			{
				do_connect();
			}
			else
				exit(0);
		}
		return;
	}
	if (k == KEY_ENTER)
	{
		do_connect();
		return;
	}

	field_ptr(g_field, &fp, &maxlen);
	len = (unsigned char)strlen(fp);
	if (g_fcurs > len)
		g_fcurs = len;
	if (g_field == FOC_PORT && k >= 32 && (k < '0' || k > '9'))
		return;
	edit_char(fp, &len, &g_fcurs, maxlen, k);
	fp[maxlen] = 0;
	draw_connect_focus();
}

static void do_send_input(void);
static void input_set_pm(const char *whom);

static void handle_chat_key(unsigned char k)
{
	if (k == KEY_F10)
	{
		if (g_conn)
		{
			irc_send_line("QUIT :girc");
			net_close();
		}
		exit(0);
	}
	if (k == KEY_ESC)
	{
		do_disconnect();
		return;
	}
	if (k == KEY_UP)
	{
		mouse_hide();
		chat_view_line(-1);
		mouse_show();
		return;
	}
	if (k == KEY_DOWN)
	{
		mouse_hide();
		chat_view_line(1);
		mouse_show();
		return;
	}
	if (k == KEY_F1)
	{
		mouse_hide();
		chat_view_page(-1);
		mouse_show();
		return;
	}
	if (k == KEY_F2)
	{
		mouse_hide();
		chat_view_page(1);
		mouse_show();
		return;
	}
	if (k == KEY_ENTER)
	{
		do_send_input();
		return;
	}
	edit_char(g_input, &g_inlen, &g_incurs, MAX_INPUT, k);
	mouse_hide();
	draw_input();
	mouse_show();
}

static void do_send_input(void)
{
	if (g_inlen == 0)
		return;
	if (g_view_off != 0)
	{
		g_view_off = 0;
		mouse_hide();
		chat_redraw_text();
	}
	irc_user_cmd(g_input);
	g_inlen = 0;
	g_incurs = 0;
	g_instart = 0;
	memset(g_input, 0, sizeof(g_input));
	mouse_hide();
	draw_input();
	draw_send_btn();
	mouse_show();
}

static void input_set_pm(const char *whom)
{
	unsigned char n;
	if (whom == 0 || whom[0] == 0)
		return;
	if (strcmp(whom, g_nick) == 0)
		return;
	sprintf(g_input, "/msg %s ", whom);
	n = (unsigned char)strlen(g_input);
	if (n > MAX_INPUT)
		n = MAX_INPUT;
	g_inlen = n;
	g_incurs = n;
	mouse_hide();
	draw_input();
	draw_send_btn();
	set_status("PM ? type message, Send/Enter");
	draw_status();
	mouse_show();
}

static void handle_mouse(void)
{
	signed char w;
	unsigned char mx, my;
	unsigned char idx;
	unsigned char max_off;

	w = m_wheel_delta;
	mx = m_cell_x;
	my = m_cell_y;

	if (g_scr == SCR_CHAT && w != 0)
	{
		if (mx >= NICK_X && mx < (unsigned char)(NICK_X + 15) &&
			my >= NICK_LIST_Y && my < (unsigned char)(NICK_LIST_Y + NICK_VIEW))
		{
			if (w < 0)
			{
				if (g_nick_scroll > 0)
					g_nick_scroll--;
			}
			else if (g_nnicks > NICK_VIEW)
			{
				max_off = (unsigned char)(g_nnicks - NICK_VIEW);
				if (g_nick_scroll < max_off)
					g_nick_scroll++;
			}
			mouse_hide();
			draw_nicks();
			mouse_show();
		}
		else if (mx >= CHAT_X && mx < (unsigned char)(CHAT_X + LOG_W) &&
				 my >= CHAT_Y && my < (unsigned char)(CHAT_Y + VIEW_H))
		{
			mouse_hide();
			if (w < 0)
				chat_view_line(-1);
			else
				chat_view_line(1);
			mouse_show();
		}
	}

	if (!m_lmb_click)
		return;

	if (g_scr == SCR_CONNECT)
	{
		if (my == BTN_CY && mx >= BTN_CX && mx < (unsigned char)(BTN_CX + BTN_CW))
		{
			g_field = FOC_CONNECT;
			do_connect();
			return;
		}
		if (my == BTN_QY && mx >= BTN_QX && mx < (unsigned char)(BTN_QX + BTN_QW))
		{
			g_field = FOC_QUIT;
			exit(0);
		}
		if (my == FLD_Y_SERVER || my == FLD_Y_PORT ||
			my == FLD_Y_NICK || my == FLD_Y_CHANNEL)
		{
			char *fp;
			unsigned char maxlen;
			unsigned char vwidth;
			unsigned char clen;

			if (my == FLD_Y_SERVER)
			{
				g_field = FOC_SERVER;
				vwidth = 40;
			}
			else if (my == FLD_Y_PORT)
			{
				g_field = FOC_PORT;
				vwidth = 5;
			}
			else if (my == FLD_Y_NICK)
			{
				g_field = FOC_NICK;
				vwidth = 24;
			}
			else
			{
				g_field = FOC_CHAN;
				vwidth = 32;
			}
			field_ptr(g_field, &fp, &maxlen);
			clen = (unsigned char)strlen(fp);
			if (mx >= 25 && mx < (unsigned char)(25 + vwidth))
			{
				g_fcurs = (unsigned char)(mx - 25);
				if (g_fcurs > clen)
					g_fcurs = clen;
			}
			else
			{
				g_fcurs = clen;
			}
			mouse_hide();
			draw_connect_focus();
			mouse_show();
		}
		return;
	}

	if (my == ROW_INPUT && mx >= SEND_X && mx < (unsigned char)(SEND_X + SEND_W))
	{
		do_send_input();
		return;
	}

	/* Click in input text ? place caret */
	if (my == ROW_INPUT && mx >= (unsigned char)(INPUT_X + 2) && mx < SEND_X)
	{
		unsigned char pos;

		pos = (unsigned char)(g_instart + (mx - (INPUT_X + 2)));
		if (pos > g_inlen)
			pos = g_inlen;
		g_incurs = pos;
		mouse_hide();
		draw_input();
		draw_send_btn();
		mouse_show();
		return;
	}

	if (mx >= (unsigned char)(NICK_X + 1) && mx < (unsigned char)(NICK_X + 13) &&
		my >= NICK_LIST_Y && my < (unsigned char)(NICK_LIST_Y + NICK_VIEW))
	{
		idx = (unsigned char)(g_nick_scroll + (my - NICK_LIST_Y));
		if (idx < g_nnicks)
			input_set_pm(g_nicks[idx]);
	}
}

/* ---- main ---- */
void main(void)
{
	unsigned long gk;
	int n;

	OS_HIDEFROMPARENT();
	os_initstdio();
	OS_SETGFX(0x86);
	OS_CLS(0);

	strcpy(g_host, "irc.386.su");
	strcpy(g_portstr, "6666");
	strcpy(g_nick, "nedouser");
	strcpy(g_chan, "#tabor");
	g_field = 0;
	g_fcurs = (unsigned char)strlen(g_host);
	g_scr = SCR_CONNECT;
	g_sock = -1;
	g_conn = 0;
	g_chrome = 0;
	g_nick_scroll = 0;
	g_status[0] = 0;

	mouse_init();
	OS_SETCOLOR(70);
	set_status("Init network...");
	net_init_driver();
	g_need_chrome = 1;

	for (;;)
	{
		if (g_need_chrome)
		{
			mouse_hide();
			redraw();
			mouse_show();
		}
		else
		{
			if (g_need_title && g_scr == SCR_CHAT && g_chrome)
			{
				mouse_hide();
				draw_chat_title();
				mouse_show();
			}
			if (g_need_nicks && g_scr == SCR_CHAT && g_chrome)
			{
				mouse_hide();
				draw_nicks();
				mouse_show();
			}
		}
		if (g_conn)
		{
			/* One socket read per tick. */
			{
				switch (netDriver)
				{
				case 0:
					n = tcpRead(g_sock, 0);
					break;
				case 1:

					n = recvHeadNoBlock();
					if (n < 1)
					{
						break;
					}
					if ((unsigned int)n > NETBUF_SIZE)
						n = (int)NETBUF_SIZE;
					/*
					 * Clear payload window first: if getdataEsp times out mid-packet,
					 * unread tail stays 0 instead of stale bytes from a previous +IPD.
					 * Still irc_feed below (best-effort) ? do not drop the link.
					 */
					memset(netbuf, 0, (unsigned int)n);
					if (!getdataEsp((unsigned int)n))
					{
						writeLog("getdataEsp truncate; feed partial", "main if(g_conn) ");
					}
					break;
				}

				if (n > 0)
				{
					mouse_hide();
					irc_feed(netbuf, (unsigned int)n);
					mouse_show();
				}
				else if (n < 0)
				{
					set_status("Connection lost");
					mouse_hide();
					draw_status();
					mouse_show();
					net_close();
					g_scr = SCR_CONNECT;
					g_chrome = 0;
					g_need_chrome = 1;
				}
			}
			/* One outbound IRC line per tick (PONG then JOIN). */
			if (g_need_pong)
			{
				g_need_pong = 0;
				sprintf((char *)cmd, "PONG %s", g_pingarg);
				if (irc_send_line((char *)cmd) < 0)
					g_need_pong = 1;
			}
			else if (g_need_join && !g_joined && g_chan[0])
			{
				set_status("Joining channel...");
				draw_status();
				if (irc_do_join() >= 0)
				{
					g_need_join = 0;
					log_add(COL_SYS, "JOIN sent");
				}
				else
				{
					log_add(COL_ERR, "JOIN send failed, retry...");
					set_status("JOIN send failed, retry...");
					draw_status();
				}
			}
		}

		gk = OS_GETKEY();
		if (gk & 0x80000000UL)
		{
			mouse_hide();
		}
		else
		{
			unsigned char k = (unsigned char)gk;
			if (k == KEY_FOCUS)
			{
				g_need_chrome = 1;
			}
			else if (k != 0)
			{
				mouse_hide();
				if (g_scr == SCR_CONNECT)
					handle_connect_key(k);
				else
					handle_chat_key(k);
				mouse_show();
			}
			mouse_poll();
			handle_mouse();
		}
		YIELD();
	}
}
