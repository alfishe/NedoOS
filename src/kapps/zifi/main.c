/*
 * ZiFi for NedoOS. HTTP/1.0 to the same PHP backends as the TSConf
 * client. Catalog records are 5 CRLF lines: title, url, year, author, city.
 *   title, url, year, author, city
 * File downloads of zips go through:
 *   http://zifi.vtrd.in/unzipremote.php?f=<url>
 * which prefixes the body with ".XXX" (real extension) then raw data.
 *
 * UI is 80x25 text + mouse. Standard 6912 (.scr) is shown on scr1
 * (OS_SETGFX 0x83), same path as getpic/scaview. SXG: sxgview.com overlay.
 * Music: player.ovl overlay (zxartrad path, pages 0..3). Autoplay
 * DROPAPPs like zxart-radio when the PT3 length estimate elapses.
 * Search: / or F, query appended as &s= (CP866 typed, UTF-8 in the URL).
 */
#include <stdio.h>
#include <string.h>
#include <intrz80.h>
#include <stdlib.h>
#include <oscalls.h>
#include <tcp.h>
#include <espnet.h>
#include <osfs.h>

#define true 1
#define false 0

#define KEY_PGUP 246
#define KEY_PGDN 247
#define KEY_LEFT 248
#define KEY_RIGHT 251
#define KEY_DOWN 249
#define KEY_UP 250
#define KEY_ESC 27
#define KEY_ENTER 13
#define KEY_BS 8

#define ACT_NONE 0
#define ACT_LIST 1
#define ACT_TEXT 2
#define ACT_SAVE 3
#define ACT_PLAY 4
#define ACT_GFX 5

#define SEC_FILES 0
#define SEC_GFX 1
#define SEC_MUSIC 2
#define SEC_PRESS 3

#define ST_SITES 0
#define ST_LIST 1
#define ST_TEXT 2

#define DEST_MEM 0
#define DEST_FILE 1
#define DEST_SCR 2

#define SCR_SIZE 6912u
#define OVL_TAIL 0x3F00u
#define OVL_PAGE 0x4000u

#define QUERY_MAX 20
#define MAX_ITEMS 100
#define LIST_ROWS 20
#define LIST_Y0 2
#define LIST_MAX 16383u
#define NETBUF_BYTES sizeof(netbuf)

#define COL_TITLE 207
#define COL_TAB 79
#define COL_TABHI 48
#define COL_FRAME 7
#define COL_LIST 7
#define COL_SEL 48
#define COL_META 6
#define COL_STAT 7
#define COL_ERR 82
#define COL_OK 68
#define COL_HELP 95

#define ROW_STAT 23
#define ROW_HELP 24

#define DIRTY_FULL 1
#define DIRTY_SEL 2
#define DIRTY_LIST 4

#define MX_FACT 4u
#define MY_FACT 8u
#define MX_MAX (79u * MX_FACT)
#define MY_MAX (24u * MY_FACT)
#define LMB_MASK 0x01u

#define UNZIP_HOST "zifi.vtrd.in"
#define UNZIP_PATH "/unzipremote.php?f="

/* ---- UART / esp-com / network.c globals ---- */
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
unsigned long factor, timerok, count = 0;
unsigned int magic = 16;
unsigned char netDriver = 0;
unsigned long contLen;
unsigned int httpErr;
unsigned int headlng;

unsigned char uVer[] = "0.5";
unsigned char curPath[128];
unsigned char g_save_dir[128];
unsigned char cmd[256];
unsigned char crlf[2] = {13, 10};
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char netbuf[4096];
struct sockaddr_in targetadr;
struct readstructure readStruct;
struct sockaddr_in dnsaddress;

union APP_PAGES main_pg;
union APP_PAGES player_pg;
unsigned char pg_app;
unsigned char pg_scr1;
unsigned char pic_shown;
unsigned char g_player_id;
unsigned char g_have_player;
unsigned char g_autoplay;
static unsigned char g_modhdr[128];
static unsigned long g_play_t0;
static unsigned int g_play_secs;
unsigned char appCmd[128];

#define listbuf ((unsigned char *)0xC000)

typedef struct
{
	const char *title;
	const char *url;
	unsigned char action;
} SITE;

typedef struct
{
	unsigned char *title;
	unsigned char *url;
	unsigned char *year;
	unsigned char *author;
	unsigned char *city;
} ITEM;

static const SITE sites_files[] = {
	{"Games: vtrd.in", "http://ex.vtrd.in/vt/export.php?t=g", ACT_SAVE},
	{"Games: prods.tslabs.info", "http://prods.tslabs.info/prods_zifi.php?t=2", ACT_SAVE},
	{"Demos: bbb.retroscene.org", "http://bbb.retroscene.org/zxn_zifi.php?t=0", ACT_SAVE},
	{"  Classic demos", "http://bbb.retroscene.org/zxn_zifi.php?t=1", ACT_SAVE},
	{"  Most liked", "http://bbb.retroscene.org/zxn_zifi.php?t=2", ACT_SAVE},
	{"  Most favorited", "http://bbb.retroscene.org/zxn_zifi.php?t=3", ACT_SAVE},
	{"  ZX Enhanced", "http://bbb.retroscene.org/zxn_zifi.php?t=4", ACT_SAVE},
	{"Demo Packs: vtrd.in", "http://ex.vtrd.in/vt/export.php?t=d", ACT_SAVE},
	{"Demos: prods.tslabs.info", "http://prods.tslabs.info/prods_zifi.php?t=1", ACT_SAVE},
	{"Demos: pouet.net ZX", "http://zifi.vtrd.in/pouet.php?src=pouet_zx", ACT_SAVE},
	{"Demos: pouet.net Enhanced", "http://zifi.vtrd.in/pouet.php?src=pouet_zxe", ACT_SAVE},
	{"System: vtrd.in", "http://ex.vtrd.in/vt/export.php?t=s", ACT_SAVE},
	{0, 0, 0}};

static const SITE sites_gfx[] = {
	{"Graphics: zxart.ee", "http://zxart.ee/zxnet/?a=g", ACT_GFX},
	{"  Most popular", "http://zxart.ee/zxnet/?a=g&o=p", ACT_GFX},
	{"  Top-rated", "http://zxart.ee/zxnet/?a=g&o=r", ACT_GFX},
	{"  First places", "http://zxart.ee/zxnet/?a=g&o=w", ACT_GFX},
	{"  Top of last year", "http://zxart.ee/zxnet/?a=g&o=y", ACT_GFX},
	{"  Multicolour & Timex", "http://zxart.ee/zxnet/?a=g&t=multi", ACT_GFX},
	{"  Colorful pictures", "http://zxart.ee/zxnet/?a=g&t=color", ACT_GFX},
	{"  Lowres graphics", "http://zxart.ee/zxnet/?a=g&t=lowres", ACT_GFX},
	{"  Pixel graphics", "http://zxart.ee/zxnet/?a=g&t=pixel", ACT_GFX},
	{0, 0, 0}};

static const SITE sites_music[] = {
	{"Music: zxart.ee", "http://zxart.ee/zxnet/?a=m", ACT_PLAY},
	{"  Most popular", "http://zxart.ee/zxnet/?a=m&o=p", ACT_PLAY},
	{"  Top-rated", "http://zxart.ee/zxnet/?a=m&o=r", ACT_PLAY},
	{"  First places", "http://zxart.ee/zxnet/?a=m&o=w", ACT_PLAY},
	{"  Top of last year", "http://zxart.ee/zxnet/?a=m&o=y", ACT_PLAY},
	{"  TurboSound", "http://zxart.ee/zxnet/?a=m&f=ts", ACT_PLAY},
	{0, 0, 0}};

static const SITE sites_press[] = {
	{"Hype: hype.retroscene.org", "http://zifi.vtrd.in/get.php?src=hype", ACT_TEXT},
	{"Emags: vtrd.in", "http://ex.vtrd.in/vt/export.php?t=p", ACT_SAVE},
	{"Z80 Telegram Log", "http://zifi.vtrd.in/tlg.php", ACT_TEXT},
	{"IRC Logs", "http://irclog.dimkam.ru/zifi.php?src=z80", ACT_LIST},
	{"RSS Channels", "http://irclog.dimkam.ru/zrss.php", ACT_TEXT},
	{0, 0, 0}};

static const SITE *const section_sites[4] = {
	sites_files, sites_gfx, sites_music, sites_press};

static const char *const section_name[4] = {
	"Files", "Gfx", "Music", "Press"};

static const char *const drv_name[3] = {
	"NedoNET", "ESP-COM", "ESPNET"};

static ITEM items[MAX_ITEMS];
static unsigned int nitems;
static unsigned int list_bytes;

static unsigned char g_sec;
static unsigned char g_state;
static unsigned char g_action;
static unsigned int g_sel;
static unsigned int g_scroll;
static unsigned int g_page;
static unsigned int g_text_off;

static unsigned char g_host[80];
static unsigned char g_path[384];
static unsigned int g_port;
static unsigned char g_httpreq[512];
static unsigned char g_list_url[256];
static unsigned char g_list_base[256];
static unsigned char g_page_url[264];
static unsigned char g_fetch_url[208];
static unsigned char g_dns_host[80];
static unsigned char g_fname[66];
static unsigned char g_ext[4];
static unsigned char g_have_ext;

static unsigned char g_dest;
static unsigned char g_unzip;
static unsigned char g_first;
static unsigned char g_fp_open;
static unsigned long g_got;
static unsigned char g_hdr[512];
static unsigned int g_hdr_n;
static FILE *g_fp;
static unsigned char g_wheel_prev;
static unsigned char g_dirty;
static unsigned int g_sel_old;
static unsigned char m_raw_x, m_raw_y, m_raw_btns;
static unsigned char m_have_sample, m_cursor_on;
static unsigned int m_x_fp, m_y_fp;
static unsigned char m_cell_x, m_cell_y, m_saved_attr;
static unsigned char m_lmb_click;
static unsigned char g_search_on;
static unsigned char g_query[QUERY_MAX + 1];
static unsigned char g_query_len;
static unsigned char g_play_title[40];
static unsigned char g_play_author[20];
static unsigned char g_play_year[8];
static unsigned char g_play_city[16];
static unsigned char g_play_file[66];
static unsigned long g_stat_shown;

static void map_list(void)
{
	SETPG32KHIGH(pg_app);
}

static void map_pic(void)
{
	SETPG32KHIGH(pg_scr1);
}

static void refresh(void);
static void put_trunc(const char *s, unsigned char maxc);
static unsigned char play_item(const char *url);

void clearStatus(void);

///////////////////////////
#include <../common/esp-com.c>
#include <../common/network.c>
#define ESPNET_CLIENT_ONLY 1
#include <../common/espnet.c>
#include <../common/espnet-net.c>
//////////////////////////

static void spaces(unsigned char n)
{
	while (n)
	{
		putchar(' ');
		n--;
	}
}

/* BDOS CMD_RESERV_1 D=0xFF: print E at cursor, no advance (no wrap/scroll). */
static void put_stay(unsigned char ch)
{
	os_reserv_1((void *)(0xFF00u | (unsigned int)ch));
}

static void fill_line(unsigned char y, unsigned char color)
{
	OS_SETCOLOR(color);
	OS_SETXY(0, y);
	spaces(79);
	put_stay(' ');
}

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
	unsigned char a;

	if (m_cursor_on)
		return;
	OS_SETXY(m_cell_x, m_cell_y);
	a = OS_GETATTR();
	m_saved_attr = a;
	OS_PRATTR((unsigned char)(((a & 7) << 3) | ((a >> 3) & 7) | (a & 0xC0)));
	m_cursor_on = 1;
}

static void mouse_poll(void)
{
	unsigned char nx, ny, nb;
	signed char dx, dy;
	int v;

	m_lmb_click = 0;
	nx = mouse_x;
	ny = mouse_y;
	nb = mouse_btns;

	if (!m_have_sample)
	{
		m_raw_x = nx;
		m_raw_y = ny;
		m_raw_btns = nb;
		m_have_sample = 1;
		return;
	}

	dx = (signed char)(nx - m_raw_x);
	dy = (signed char)(m_raw_y - ny);
	m_raw_x = nx;
	m_raw_y = ny;

	if (dx || dy)
	{
		mouse_hide();
		v = (int)m_x_fp + (int)dx;
		if (v < 0)
			v = 0;
		if (v > (int)MX_MAX)
			v = (int)MX_MAX;
		m_x_fp = (unsigned int)v;
		v = (int)m_y_fp + (int)dy;
		if (v < 0)
			v = 0;
		if (v > (int)MY_MAX)
			v = (int)MY_MAX;
		m_y_fp = (unsigned int)v;
		m_cell_x = (unsigned char)(m_x_fp / MX_FACT);
		m_cell_y = (unsigned char)(m_y_fp / MY_FACT);
		mouse_show();
	}

	/* bits 0..2: 0 = pressed */
	if ((m_raw_btns & LMB_MASK) && ((nb & LMB_MASK) == 0))
		m_lmb_click = 1;
	m_raw_btns = nb;
}

void clearStatus(void)
{
	fill_line(ROW_STAT, COL_STAT);
	OS_SETXY(0, ROW_STAT);
}

static void set_status(unsigned char col, const char *msg)
{
	unsigned char i;

	fill_line(ROW_STAT, col);
	OS_SETXY(0, ROW_STAT);
	i = 0;
	while (msg[i] && i < 79)
	{
		putchar(msg[i]);
		i++;
	}
	if (msg[i])
		put_stay(msg[i]);
}

static void copy_field(unsigned char *dst, unsigned int max, const unsigned char *src)
{
	unsigned int n;

	n = 0;
	if (src)
	{
		while (src[n] && src[n] != '\r' && src[n] != '\n' && n + 1 < max)
		{
			dst[n] = src[n];
			n++;
		}
	}
	dst[n] = 0;
}

static unsigned char hexd(unsigned char v)
{
	v = (unsigned char)(v & 15);
	if (v < 10)
		return (unsigned char)('0' + v);
	return (unsigned char)('A' + v - 10);
}

static void url_add_byte(char *dst, unsigned int *n, unsigned int max, unsigned char c)
{
	unsigned char ok;

	if (*n + 4 >= max)
		return;
	ok = 0;
	if ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9'))
		ok = 1;
	if (c == '-' || c == '_' || c == '.' || c == '~')
		ok = 1;
	if (ok)
		dst[(*n)++] = (char)c;
	else if (c == ' ')
		dst[(*n)++] = '+';
	else
	{
		dst[(*n)++] = '%';
		dst[(*n)++] = (char)hexd((unsigned char)(c >> 4));
		dst[(*n)++] = (char)hexd(c);
	}
	dst[*n] = 0;
}

/* Query is typed in CP866; catalogs (zxart) want UTF-8 in &s=. */
static void url_add_query(char *dst, unsigned int max, const unsigned char *q)
{
	unsigned int n;
	unsigned int u;
	unsigned char c;

	n = strlen(dst);
	while (*q)
	{
		c = *q++;
		if (c < 0x80)
			url_add_byte(dst, &n, max, c);
		else
		{
			u = 0;
			if (c >= 0x80 && c <= 0xAF)
				u = 0x0410u + (unsigned int)(c - 0x80);
			else if (c >= 0xE0 && c <= 0xEF)
				u = 0x0440u + (unsigned int)(c - 0xE0);
			else if (c == 0xF0)
				u = 0x0401u;
			else if (c == 0xF1)
				u = 0x0451u;
			if (u == 0)
				url_add_byte(dst, &n, max, c);
			else
			{
				url_add_byte(dst, &n, max, (unsigned char)(0xC0u | (u >> 6)));
				url_add_byte(dst, &n, max, (unsigned char)(0x80u | (u & 0x3Fu)));
			}
		}
	}
}

static void build_list_url(void)
{
	strcpy((char *)g_list_url, (char *)g_list_base);
	if (g_query[0] == 0)
		return;
	if (strchr((char *)g_list_url, '?'))
		strcat((char *)g_list_url, "&s=");
	else
		strcat((char *)g_list_url, "?s=");
	url_add_query((char *)g_list_url, sizeof(g_list_url), g_query);
}

static void set_list_base(const char *url)
{
	strncpy((char *)g_list_base, url, sizeof(g_list_base) - 1);
	g_list_base[sizeof(g_list_base) - 1] = 0;
	g_query[0] = 0;
	g_query_len = 0;
	g_search_on = 0;
	build_list_url();
}

static void draw_search_row(void)
{
	fill_line(ROW_STAT, COL_TABHI);
	OS_SETXY(0, ROW_STAT);
	printf(" Find: %s", g_query);
	putchar('_');
}

static void draw_now_playing(void)
{
	fill_line(ROW_STAT, COL_OK);
	OS_SETXY(0, ROW_STAT);
	putchar('>');
	putchar(' ');
	put_trunc((char *)g_play_title, 32);
	if (g_play_author[0] > 0x20)
	{
		printf("  ");
		put_trunc((char *)g_play_author, 16);
	}
	if (g_play_year[0] > 0x20)
	{
		printf("  ");
		put_trunc((char *)g_play_year, 4);
	}
	if (g_play_city[0] > 0x20)
	{
		printf("  ");
		put_trunc((char *)g_play_city, 12);
	}
}

static void draw_status_row(void)
{
	if (g_search_on)
		draw_search_row();
	else if (g_have_player)
		draw_now_playing();
	else
		clearStatus();
}

static void draw_progress(unsigned long got)
{
	char line[16];

	if (got == 0 || got == g_stat_shown)
		return;
	g_stat_shown = got;
	sprintf(line, "%lu", got);
	set_status(COL_STAT, line);
}

static unsigned char site_count(const SITE *s)
{
	unsigned char n;

	n = 0;
	while (s[n].title)
		n++;
	return n;
}

static const SITE *cur_sites(void)
{
	return section_sites[g_sec];
}

static unsigned int cur_count(void)
{
	if (g_state == ST_SITES)
		return site_count(cur_sites());
	return nitems;
}

static void clamp_view(void)
{
	unsigned int n;

	n = cur_count();
	if (g_state == ST_TEXT)
		return;
	if (n == 0)
	{
		g_sel = 0;
		g_scroll = 0;
		return;
	}
	if (g_sel >= n)
		g_sel = n - 1;
	if (g_sel < g_scroll)
		g_scroll = g_sel;
	if (g_sel >= g_scroll + LIST_ROWS)
		g_scroll = g_sel - LIST_ROWS + 1;
}

static void url_filename(const char *url, char *out)
{
	const char *p;
	const char *slash;
	const char *end;
	unsigned char n;
	unsigned char c;

	slash = url;
	end = url;
	for (p = url; *p && *p != '\r' && *p != '\n'; p++)
	{
		if (*p == '/')
			slash = p + 1;
		if (*p == '?')
			break;
	}
	end = p;
	n = 0;
	while (slash < end && n < 60)
	{
		c = *slash++;
		if (c == '\\' || c == '/' || c == ':' || c == '*' || c == '?' ||
		    c == '"' || c == '<' || c == '>' || c == '|' || c == ' ')
			c = '_';
		out[n] = c;
		n++;
	}
	if (n == 0)
	{
		strcpy(out, "file.bin");
		return;
	}
	out[n] = 0;
}

static void replace_ext(char *name, const char *ext3)
{
	char *dot;
	char *p;

	dot = 0;
	for (p = name; *p; p++)
	{
		if (*p == '.')
			dot = p;
	}
	if (dot == 0)
	{
		p = name + strlen(name);
		p[0] = '.';
		p[1] = ext3[0];
		p[2] = ext3[1];
		p[3] = ext3[2];
		p[4] = 0;
		return;
	}
	dot[1] = ext3[0];
	dot[2] = ext3[1];
	dot[3] = ext3[2];
	dot[4] = 0;
}

/* http://host[:port]/path  or https://...  (we still speak HTTP/1.0:80) */
static unsigned char parse_url(const char *url)
{
	const char *p;
	unsigned int n;
	unsigned int port;

	g_host[0] = 0;
	g_path[0] = '/';
	g_path[1] = 0;
	g_port = 80;

	p = url;
	while (*p && *p != ':')
		p++;
	if (p[0] != ':' || p[1] != '/' || p[2] != '/')
		return 0;
	p += 3;

	n = 0;
	while (*p && *p != '/' && *p != ':' && *p != '?' && n < 78)
	{
		g_host[n] = *p;
		n++;
		p++;
	}
	g_host[n] = 0;
	if (n == 0)
		return 0;

	if (*p == ':')
	{
		p++;
		port = 0;
		while (*p >= '0' && *p <= '9')
		{
			port = (unsigned int)(port * 10 + (*p - '0'));
			p++;
		}
		if (port)
			g_port = port;
	}

	n = 0;
	if (*p == 0 || *p == '\r' || *p == '\n')
	{
		g_path[0] = '/';
		g_path[1] = 0;
		return 1;
	}
	while (*p && *p != '\r' && *p != '\n' && n < 380)
	{
		g_path[n] = *p;
		n++;
		p++;
	}
	g_path[n] = 0;
	return 1;
}

static void build_http_req(void)
{
	sprintf((char *)g_httpreq,
		"GET %s HTTP/1.0\r\n"
		"Host: %s\r\n"
		"User-Agent: ZiFi (NedoOS)\r\n"
		"Accept: */*\r\n"
		"Connection: close\r\n"
		"\r\n",
		g_path, g_host);
}

static unsigned char dns_for_host(void)
{
	if (g_host[0] == 0)
		return 0;
	if (strcmp((char *)g_dns_host, (char *)g_host) == 0)
		return 1;

	if (netDriver == 0)
	{
		if (!dnsResolve((char *)g_host))
			return 0;
	}
	else if (netDriver == 2)
	{
		if (!EspDnsResolve((char *)g_host))
			return 0;
	}
	strcpy((char *)g_dns_host, (char *)g_host);
	return 1;
}

/* Same helper as gopher: zero the prefix recvHead scans for CLOSED/ERROR. */
static void clearNetBuf(unsigned int size)
{
	if (size > sizeof(netbuf))
		size = sizeof(netbuf);
	memset(netbuf, 0, size);
}

static unsigned long parse_contlen(unsigned char *buf, unsigned char *lim)
{
	unsigned char *p;
	unsigned char *q;
	const char *k;
	unsigned char a;

	for (p = buf; p < lim; p++)
	{
		k = "content-length:";
		q = p;
		while (q < lim && *k)
		{
			a = *q;
			if (a >= 'A' && a <= 'Z')
				a = (unsigned char)(a + 32);
			if (a != (unsigned char)*k)
				break;
			q++;
			k++;
		}
		if (*k == 0)
			return (unsigned long)atol((char *)q);
	}
	return 0;
}

static unsigned char *find_eoh(unsigned char *buf, unsigned int n)
{
	unsigned int i;

	if (n < 4)
		return 0;
	for (i = 0; i + 3 < n; i++)
	{
		if (buf[i] == 13 && buf[i + 1] == 10 && buf[i + 2] == 13 && buf[i + 3] == 10)
			return buf + i;
	}
	return 0;
}

static unsigned int http_status_buf(unsigned char *buf)
{
	char *r;

	r = strstr((char *)buf, "HTTP/1.1 ");
	if (r == 0)
		r = strstr((char *)buf, "HTTP/1.0 ");
	if (r == 0)
		return 0;
	return (unsigned int)atol(r + 9);
}

static unsigned char file_create(void)
{
	OS_GETPATH(curPath);
	OS_CHDIR(g_save_dir);
	OS_DELETE(g_fname);
	g_fp = OS_CREATEHANDLE(g_fname, 0x80);
	if (((int)g_fp) & 0xff)
	{
		OS_CHDIR(curPath);
		return 0;
	}
	OS_CLOSEHANDLE(g_fp);
	g_fp = OS_OPENHANDLE(g_fname, 0x80);
	if (((int)g_fp) & 0xff)
	{
		OS_CHDIR(curPath);
		return 0;
	}
	g_fp_open = 1;
	OS_CHDIR(curPath);
	return 1;
}

static unsigned char copy_dest(unsigned char *p, unsigned int n)
{
	unsigned int skip;

	if (n == 0)
		return 1;
	if (g_dest == DEST_MEM)
	{
		skip = n;
		if (g_got + skip > LIST_MAX)
			skip = (unsigned int)(LIST_MAX - g_got);
		if (skip)
		{
			map_list();
			memcpy(listbuf + (unsigned int)g_got, p, skip);
			g_got += skip;
		}
	}
	else if (g_dest == DEST_SCR)
	{
		skip = n;
		if (g_got + skip > SCR_SIZE)
			skip = (unsigned int)(SCR_SIZE - g_got);
		if (skip)
		{
			map_pic();
			memcpy((unsigned char *)0xC000 + (unsigned int)g_got, p, skip);
			g_got += skip;
		}
	}
	else
	{
		OS_WRITEHANDLE(p, g_fp, n);
		g_got += n;
	}
	draw_progress(g_got);
	return 1;
}

static unsigned char begin_body(unsigned char **pp, unsigned int *pn)
{
	unsigned char *p;
	unsigned int n;

	p = *pp;
	n = *pn;
	if (g_unzip && n >= 4 && p[0] == '.')
	{
		g_ext[0] = p[1];
		g_ext[1] = p[2];
		g_ext[2] = p[3];
		g_ext[3] = 0;
		g_have_ext = 1;
		p += 4;
		n -= 4;
		if (contLen >= 4)
			contLen -= 4;
		replace_ext((char *)g_fname, (char *)g_ext);
	}
	if (g_dest == DEST_FILE)
	{
		if (!file_create())
		{
			set_status(COL_ERR, "create file failed");
			return 0;
		}
	}
	*pp = p;
	*pn = n;
	return 1;
}

static unsigned char feed_body(unsigned char *p, unsigned int n)
{
	unsigned char *eoh;
	unsigned int prev;
	unsigned int off;

	if (n == 0)
		return 1;
	if (!g_first)
		return copy_dest(p, n);

	/* Usual case: whole HTTP header is in this +IPD. Scan the packet
	 * itself. Do not copy g_hdr over netbuf: that planted a NUL and
	 * the catalog parser stopped after ~4 lines; SCR got a bad byte. */
	if (g_hdr_n == 0)
	{
		eoh = find_eoh(p, n);
		if (eoh)
		{
			httpErr = http_status_buf(p);
			if (httpErr != 200)
				return 0;
			headlng = (unsigned int)(eoh - p) + 4;
			contLen = parse_contlen(p, eoh);
			g_first = 0;
			if (headlng > n)
				return 0;
			p += headlng;
			n = (unsigned int)(n - headlng);
			if (!begin_body(&p, &n))
				return 0;
			return copy_dest(p, n);
		}
	}

	prev = g_hdr_n;
	if (prev + n >= (unsigned int)(sizeof(g_hdr) - 1))
		return 0;
	memcpy(g_hdr + prev, p, n);
	g_hdr_n = (unsigned int)(prev + n);
	g_hdr[g_hdr_n] = 0;
	eoh = find_eoh(g_hdr, g_hdr_n);
	if (eoh == 0)
		return 1;

	httpErr = http_status_buf(g_hdr);
	if (httpErr != 200)
		return 0;
	headlng = (unsigned int)(eoh - g_hdr) + 4;
	contLen = parse_contlen(g_hdr, eoh);
	g_first = 0;
	if (headlng < prev)
		off = 0;
	else
		off = (unsigned int)(headlng - prev);
	if (off >= n)
		return 1;
	p += off;
	n = (unsigned int)(n - off);
	if (!begin_body(&p, &n))
		return 0;
	return copy_dest(p, n);
}

/* ESP-COM GET: gopher getFileEsp control flow (recvHead until CLOSED). */
static unsigned char http_esp(void)
{
	int todo;
	unsigned char byte;
	unsigned long downloaded;

	downloaded = 0;
	sprintf((char *)cmd, "AT+CIPSTART=\"TCP\",\"%s\",%u", g_host, g_port);
	sendcommand((char *)cmd);
	for (;;)
	{
		getAnswer3();
		if (strstr((char *)netbuf, "CONNECT") != 0)
			break;
		if (strstr((char *)netbuf, "ERROR") != 0)
			return 0;
	}
	getAnswer3();
	sprintf((char *)cmd, "AT+CIPSEND=%u", strlen((char *)g_httpreq));
	sendcommand((char *)cmd);
	getAnswer3();
	do
	{
		byte = (unsigned char)uartReadBlock();
	} while (byte != '>');

	sendcommandNrn((char *)g_httpreq);

	do
	{
		clearNetBuf(128);
		todo = recvHead();
		downloaded = downloaded + (unsigned long)todo;
		if (downloaded == 0)
			return 1;
		if (todo > (int)(sizeof(netbuf) - 1))
			return 0;
		if (!getdataEsp((unsigned int)todo))
			return 0;
		netbuf[todo] = 0;
		if (!feed_body(netbuf, (unsigned int)todo))
			return 0;
	} while (todo != 0);

	return 1;
}

static unsigned char http_net(void)
{
	int socket;
	int todo;
	unsigned char ok;

	if (!dns_for_host())
		return 0;
	targetadr.family = AF_INET;
	targetadr.porth = (unsigned char)(g_port >> 8);
	targetadr.portl = (unsigned char)g_port;

	socket = OpenSock(AF_INET, SOCK_STREAM);
	if (socket < 0)
		return 0;
	todo = netConnect(socket, 3);
	if (todo < 0)
	{
		netShutDown(socket, 0);
		return 0;
	}
	todo = tcpSend(socket, (unsigned int)g_httpreq, strlen((char *)g_httpreq), 3);
	if (todo < 0)
	{
		netShutDown(socket, 0);
		return 0;
	}

	ok = 1;
	do
	{
		headlng = 0;
		todo = tcpRead(socket, 8);
		if (todo <= 0)
			break;
		if (!feed_body(netbuf, (unsigned int)todo))
		{
			ok = 0;
			break;
		}
	} while (1);

	netShutDown(socket, 0);
	return ok;
}

static unsigned char http_espnet(void)
{
	int socket;
	int todo;
	unsigned char ok;

	if (!dns_for_host())
		return 0;
	targetadr.family = AF_INET;
	targetadr.porth = (unsigned char)(g_port >> 8);
	targetadr.portl = (unsigned char)g_port;

	socket = EspOpenSock(AF_INET, SOCK_STREAM);
	if (socket < 0)
		return 0;
	todo = EspConnect((signed char)socket);
	if (todo < 0)
	{
		EspShutDown((signed char)socket, 0);
		return 0;
	}
	todo = EspSend((signed char)socket, (unsigned int)g_httpreq, strlen((char *)g_httpreq));
	if (todo < 0)
	{
		EspShutDown((signed char)socket, 0);
		return 0;
	}

	ok = 1;
	do
	{
		headlng = 0;
		do
		{
			todo = EspRead((signed char)socket);
		} while (todo == 0 - (int)ESPNET_ERR_EAGAIN);
		if (todo < 1)
			break;
		if (!feed_body(netbuf, (unsigned int)todo))
		{
			ok = 0;
			break;
		}
	} while (1);

	EspShutDown((signed char)socket, 0);
	return ok;
}

static unsigned char http_get(const char *url, unsigned char dest, unsigned char unzip)
{
	unsigned char ok;
	char line[80];

	mouse_hide();
	g_dest = dest;
	g_unzip = unzip;
	g_first = 1;
	g_got = 0;
	g_have_ext = 0;
	g_fp_open = 0;
	contLen = 0;
	httpErr = 0;
	headlng = 0;
	g_hdr_n = 0;

	if (unzip)
	{
		strcpy((char *)g_fetch_url, "http://" UNZIP_HOST UNZIP_PATH);
		strncat((char *)g_fetch_url, url, 160);
		url = (char *)g_fetch_url;
	}

	if (!parse_url(url))
	{
		set_status(COL_ERR, "bad url");
		return 0;
	}
	build_http_req();

	g_stat_shown = 0;

	if (netDriver == 1)
		ok = http_esp();
	else if (netDriver == 2)
		ok = http_espnet();
	else
		ok = http_net();

	if (g_fp_open)
	{
		OS_CLOSEHANDLE(g_fp);
		g_fp_open = 0;
	}

	if (g_dest == DEST_MEM)
	{
		map_list();
		if (g_got < LIST_MAX)
			listbuf[(unsigned int)g_got] = 0;
		else
			listbuf[LIST_MAX] = 0;
		list_bytes = (unsigned int)g_got;
	}

	if (!ok)
	{
		if (httpErr && httpErr != 200)
			sprintf(line, "HTTP %u", httpErr);
		else
			strcpy(line, "download failed");
		set_status(COL_ERR, line);
		return 0;
	}
	clearStatus();
	return 1;
}

static unsigned char *skip_eol(unsigned char *p, unsigned char *end)
{
	while (p < end && *p != '\r' && *p != '\n' && *p)
		p++;
	if (p < end && *p == '\r')
	{
		*p = 0;
		p++;
	}
	if (p < end && *p == '\n')
	{
		*p = 0;
		p++;
	}
	return p;
}

static unsigned char looks_utf8(unsigned char *p, unsigned char *end)
{
	unsigned int ok;
	unsigned int bad;
	unsigned char c;

	ok = 0;
	bad = 0;
	while (p < end && *p)
	{
		c = *p++;
		if (c < 0x80)
			continue;
		if ((c & 0xE0) == 0xC0 && p < end && (*p & 0xC0) == 0x80)
		{
			p++;
			ok++;
		}
		else if ((c & 0xF0) == 0xE0 && p + 1 < end &&
			 (p[0] & 0xC0) == 0x80 && (p[1] & 0xC0) == 0x80)
		{
			p += 2;
			ok++;
		}
		else
			bad++;
	}
	return (unsigned char)(ok > 0 && ok >= bad);
}

/* CP866 letters live in 80-AF / E0-EF. CP1251 letters live in C0-FF.
 * 80-AF as 1251 is punctuation, so that range means "already 866". */
static unsigned char looks_cp866(unsigned char *p, unsigned char *end)
{
	unsigned int n866;
	unsigned int n1251;
	unsigned char c;

	n866 = 0;
	n1251 = 0;
	while (p < end && *p)
	{
		c = *p++;
		if (c >= 0x80 && c <= 0xAF)
			n866++;
		else if (c >= 0xC0 && c <= 0xDF)
			n1251++;
	}
	if (n866 == 0 && n1251 == 0)
		return 1;
	return (unsigned char)(n866 >= n1251);
}

static unsigned char uni_to_866(unsigned int u)
{
	if (u < 0x80)
		return (unsigned char)u;
	if (u >= 0x0410u && u <= 0x043Fu)
		return (unsigned char)(u - 0x0410u + 0x80u);
	if (u >= 0x0440u && u <= 0x044Fu)
		return (unsigned char)(u - 0x0440u + 0xE0u);
	if (u == 0x0401u)
		return 0xF0;
	if (u == 0x0451u)
		return 0xF1;
	if (u == 0x00A0u)
		return ' ';
	if (u == 0x2013u || u == 0x2014u)
		return '-';
	if (u == 0x00ABu || u == 0x00BBu || u == 0x201Cu || u == 0x201Du)
		return '"';
	return 0x3F;
}

static unsigned int utf8_to_866(unsigned char *p, unsigned char *end)
{
	unsigned char *s;
	unsigned char *d;
	unsigned char c;
	unsigned int u;

	s = p;
	d = p;
	while (s < end && *s)
	{
		c = *s++;
		if (c < 0x80)
		{
			*d++ = c;
			continue;
		}
		if ((c & 0xE0) == 0xC0 && s < end)
		{
			u = ((unsigned int)(c & 0x1F) << 6) | (unsigned int)(*s & 0x3F);
			s++;
			*d++ = uni_to_866(u);
			continue;
		}
		if ((c & 0xF0) == 0xE0 && s + 1 < end)
		{
			u = ((unsigned int)(c & 0x0F) << 12)
			    | ((unsigned int)(s[0] & 0x3F) << 6)
			    | (unsigned int)(s[1] & 0x3F);
			s += 2;
			*d++ = uni_to_866(u);
			continue;
		}
		if ((c & 0xF8) == 0xF0 && s + 2 < end)
		{
			s += 3;
			*d++ = 0x3F;
			continue;
		}
		*d++ = 0x3F;
	}
	*d = 0;
	return (unsigned int)(d - p);
}

/* vtrd export is already CP866. zxart/modern PHP is often UTF-8. Some old
 * endpoints are CP1251. Do not run 1251->866 on 866: that is how "Компрессор"
 * became "?R|fa?". */
static void fix_list_encoding(void)
{
	unsigned char *p;
	unsigned char *end;
	unsigned int n;

	map_list();
	p = listbuf;
	end = listbuf + list_bytes;
	if (list_bytes >= 3 && p[0] == 0xEF && p[1] == 0xBB && p[2] == 0xBF)
	{
		p += 3;
		list_bytes = (unsigned int)(list_bytes - 3);
		memmove(listbuf, p, list_bytes + 1);
		p = listbuf;
		end = listbuf + list_bytes;
	}
	if (looks_utf8(p, end))
	{
		n = utf8_to_866(p, end);
		list_bytes = n;
		return;
	}
	if (looks_cp866(p, end))
		return;
	conv1251to866(p);
}

static void parse_catalog(void)
{
	unsigned char *p;
	unsigned char *end;
	unsigned char *line;
	unsigned int i;

	map_list();
	nitems = 0;
	fix_list_encoding();
	p = listbuf;
	end = listbuf + list_bytes;

	while (p < end && nitems < MAX_ITEMS)
	{
		if (*p == 0)
			break;
		if (*p == '\r' || *p == '\n')
		{
			p++;
			continue;
		}

		i = nitems;
		items[i].title = p;
		items[i].url = 0;
		items[i].year = 0;
		items[i].author = 0;
		items[i].city = 0;

		line = p;
		p = skip_eol(p, end);
		if (line[0] == 0)
			continue;

		if (p >= end)
		{
			nitems++;
			break;
		}
		items[i].url = p;
		p = skip_eol(p, end);

		if (p < end)
		{
			items[i].year = p;
			p = skip_eol(p, end);
		}
		if (p < end)
		{
			items[i].author = p;
			p = skip_eol(p, end);
		}
		if (p < end)
		{
			items[i].city = p;
			p = skip_eol(p, end);
		}

		if (items[i].url == 0 || items[i].url[0] == 0)
			continue;
		nitems++;
	}
}

static unsigned char fetch_list(unsigned int page)
{
	const char *url;

	if (page <= 1)
	{
		url = (char *)g_list_url;
		g_page = 1;
	}
	else
	{
		sprintf((char *)g_page_url, "%s%cp=%02u",
			g_list_url,
			strchr((char *)g_list_url, '?') ? '&' : '?',
			page);
		url = (char *)g_page_url;
		g_page = page;
	}

	if (!http_get(url, DEST_MEM, 0))
		return 0;

	parse_catalog();
	g_sel = 0;
	g_scroll = 0;
	g_state = ST_LIST;
	g_dirty |= DIRTY_FULL;
	clearStatus();
	return 1;
}

static unsigned char save_url(const char *url, unsigned char unzip)
{
	url_filename(url, (char *)g_fname);
	return http_get(url, DEST_FILE, unzip);
}

static void stop_player(void)
{
	if (g_have_player)
	{
		OS_DROPAPP(g_player_id);
		g_have_player = 0;
	}
}

/* NEWAPP writes pages in DEHL order into the first 4 bytes; re-read with
 * GETAPPMAINPAGES so window_0 is 0000 (code at 0x0100). File bytes:
 *  0x0100..0x3FFF -> window_0 at C100 (OVL_TAIL)
 *  0x4000..0x7FFF -> window_1 at C000
 *  0x8000..0xBFFF -> window_2 at C000
 *  0xC000..0xFFFF -> window_3 at C000
 */
static unsigned char load_ovl_page(unsigned char page, unsigned char *addr, unsigned int maxn, FILE *fp, unsigned char need)
{
	unsigned int n;

	SETPG32KHIGH(page);
	n = OS_READHANDLE(addr, fp, maxn);
	if (need)
		return (unsigned char)(n != 0);
	return 1;
}

static unsigned char load_ovl_pages(const union APP_PAGES *pg, FILE *fp)
{
	if (!load_ovl_page(pg->pgs.window_0, (unsigned char *)0xC100, OVL_TAIL, fp, 1))
		return 0;
	if (!load_ovl_page(pg->pgs.window_1, (unsigned char *)0xC000, OVL_PAGE, fp, 0))
		return 0;
	if (!load_ovl_page(pg->pgs.window_2, (unsigned char *)0xC000, OVL_PAGE, fp, 0))
		return 0;
	if (!load_ovl_page(pg->pgs.window_3, (unsigned char *)0xC000, OVL_PAGE, fp, 0))
		return 0;
	return 1;
}

/* subdir NULL = bin/ (SETSYSDRV). wait=1: WAITPID (gfx viewers). wait=0: keep pid. */
static unsigned char run_overlay(const char *subdir, const char *file, const char *cmd0, const char *arg, unsigned char wait)
{
	FILE *fp2;
	unsigned char childId;
	unsigned int cmdLen;
	char line[80];

	appCmd[0] = 0;
	strncat((char *)appCmd, cmd0, 40);
	if (arg && arg[0])
	{
		strcat((char *)appCmd, " ");
		strncat((char *)appCmd, arg, 80);
	}

	OS_GETPATH(curPath);
	OS_SETSYSDRV();
	if (subdir && subdir[0])
		OS_CHDIR((unsigned char *)subdir);
	fp2 = OS_OPENHANDLE((unsigned char *)file, 0x80);
	if (((int)fp2) & 0xff)
	{
		OS_CHDIR(curPath);
		sprintf(line, "%s not found", file);
		set_status(COL_ERR, line);
		return 0;
	}
	OS_CHDIR(curPath);

	OS_NEWAPP((unsigned int)&player_pg);
	if (player_pg.pgs.error)
	{
		OS_CLOSEHANDLE(fp2);
		map_list();
		set_status(COL_ERR, "OS_NEWAPP failed");
		return 0;
	}
	childId = player_pg.pgs.pId;
	player_pg.l = OS_GETAPPMAINPAGES(childId);

	SETPG32KHIGH(player_pg.pgs.window_0);
	cmdLen = strlen((char *)appCmd) + 1;
	memcpy((unsigned char *)0xC080, appCmd, cmdLen);

	if (!load_ovl_pages(&player_pg, fp2))
	{
		OS_CLOSEHANDLE(fp2);
		OS_DROPAPP(childId);
		map_list();
		set_status(COL_ERR, "overlay load failed");
		return 0;
	}

	OS_CLOSEHANDLE(fp2);
	map_list();
	OS_RUNAPP(childId);
	if (wait)
	{
		OS_WAITPID(childId);
		OS_SETSCREEN(0);
		OS_SETGFX(0x86);
		map_list();
	}
	else
	{
		g_player_id = childId;
		g_have_player = 1;
		g_play_t0 = time();
	}
	return 1;
}

static void remember_play(void)
{
	map_list();
	if (g_sel >= nitems)
		return;
	copy_field(g_play_title, sizeof(g_play_title), items[g_sel].title);
	copy_field(g_play_author, sizeof(g_play_author), items[g_sel].author);
	copy_field(g_play_year, sizeof(g_play_year), items[g_sel].year);
	copy_field(g_play_city, sizeof(g_play_city), items[g_sel].city);
	copy_field(g_play_file, sizeof(g_play_file), g_fname);
}

static unsigned int estimate_track_secs(const char *fname)
{
	FILE *fp;
	unsigned int n;
	unsigned int delay;
	unsigned int npos;
	unsigned long ticks;
	unsigned int secs;

	OS_GETPATH(curPath);
	OS_CHDIR(g_save_dir);
	fp = OS_OPENHANDLE((unsigned char *)fname, 0x80);
	if (((int)fp) & 0xff)
	{
		OS_CHDIR(curPath);
		return 0;
	}
	n = OS_READHANDLE(g_modhdr, fp, sizeof(g_modhdr));
	OS_CLOSEHANDLE(fp);
	OS_CHDIR(curPath);
	if (n < 102)
		return 0;
	if (g_modhdr[0] != 'P' && g_modhdr[0] != 'V')
		return 0;
	delay = g_modhdr[100];
	npos = g_modhdr[101];
	if (delay == 0 || npos == 0)
		return 0;
	/* Usual PT3 pattern height is 64 lines; radio uses JSON length instead. */
	ticks = (unsigned long)npos * 64ul * (unsigned long)delay;
	secs = (unsigned int)(ticks / 50ul);
	if (secs == 0)
		secs = 1;
	return secs;
}

static unsigned char play_item(const char *url)
{
	unsigned char unzip;

	unzip = 1;
	if (strncmp(url, "https://", 8) != 0)
		unzip = 0;
	if (!save_url(url, unzip))
		return 0;
	remember_play();
	g_play_secs = estimate_track_secs((char *)g_fname);
	stop_player();
	clearStatus();
	if (!run_overlay("radio", "player.ovl", "player.com", (char *)g_fname, 0))
		return 0;
	g_autoplay = 1;
	g_dirty |= DIRTY_FULL;
	refresh();
	return 1;
}

/* Same idea as zxart-radio: player.ovl never QUITs, we DROPAPP when
 * the estimated length is over (cutOff 1s). Process death also counts.
 */
static unsigned char player_track_ended(void)
{
	unsigned long elapsed;

	if (!g_have_player)
		return 0;
	errno = 0;
	(void)OS_GETAPPMAINPAGES(g_player_id);
	if (errno)
		return 1;
	if (g_play_secs == 0)
		return 0;
	elapsed = ((unsigned long)time() - g_play_t0) / 50ul;
	if (elapsed + 1ul >= (unsigned long)g_play_secs)
		return 1;
	return 0;
}

static void autoplay_next(void)
{
	unsigned char tries;

	if (!g_autoplay || g_action != ACT_PLAY || g_state != ST_LIST)
		return;
	tries = 0;
	while (tries < 32)
	{
		if (g_sel + 1 < nitems)
			g_sel++;
		else
		{
			if (!fetch_list((unsigned int)(g_page + 1)) || nitems == 0)
			{
				g_autoplay = 0;
				set_status(COL_OK, "playlist end");
				return;
			}
		}
		clamp_view();
		map_list();
		if (items[g_sel].url && items[g_sel].url[0])
		{
			g_dirty |= DIRTY_LIST;
			refresh();
			if (play_item((char *)items[g_sel].url))
				return;
		}
		tries++;
	}
}

static void poll_player(void)
{
	if (!g_have_player)
		return;
	if (!player_track_ended())
		return;
	autoplay_next();
}

/* Search is &s= on the current catalog URL (same as original ZiFi).
 * From the section menu it uses the highlighted site, so you do not have
 * to download a filter list first. ACT_TEXT feeds have no catalog search.
 */
static unsigned char bind_search_catalog(void)
{
	const SITE *s;

	if (g_state == ST_LIST)
		return (unsigned char)(g_list_base[0] != 0);
	if (g_state != ST_SITES)
		return 0;
	s = cur_sites();
	if (s[g_sel].url == 0 || s[g_sel].url[0] == 0)
		return 0;
	if (s[g_sel].action == ACT_TEXT)
		return 0;
	g_action = s[g_sel].action;
	strncpy((char *)g_list_base, s[g_sel].url, sizeof(g_list_base) - 1);
	g_list_base[sizeof(g_list_base) - 1] = 0;
	return 1;
}

static void start_search(void)
{
	if (!bind_search_catalog())
	{
		set_status(COL_ERR, "open a catalog, then /find");
		return;
	}
	g_search_on = 1;
	mouse_hide();
	draw_search_row();
	mouse_show();
}

static void handle_search_key(unsigned int key)
{
	if (key == KEY_ESC)
	{
		g_search_on = 0;
		g_dirty |= DIRTY_FULL;
		return;
	}
	if (key == KEY_ENTER)
	{
		g_search_on = 0;
		if (!bind_search_catalog())
		{
			g_dirty |= DIRTY_FULL;
			return;
		}
		build_list_url();
		fetch_list(1);
		return;
	}
	if (key == KEY_BS)
	{
		if (g_query_len)
		{
			g_query_len--;
			g_query[g_query_len] = 0;
		}
		mouse_hide();
		draw_search_row();
		mouse_show();
		return;
	}
	if (key < 32 || key >= 246)
		return;
	if (g_query_len >= QUERY_MAX)
		return;
	g_query[g_query_len] = (unsigned char)key;
	g_query_len++;
	g_query[g_query_len] = 0;
	mouse_hide();
	draw_search_row();
	mouse_show();
}

static void view_sxg(const char *url)
{
	unsigned char unzip;

	unzip = 1;
	if (strncmp(url, "https://", 8) != 0)
		unzip = 0;
	if (!save_url(url, unzip))
		return;
	clearStatus();
	if (!run_overlay((const char *)0, "sxgview.com", "sxgview.com", (char *)g_fname, 1))
		return;
	g_dirty |= DIRTY_FULL;
	refresh();
	clearStatus();
}

static void put_trunc(const char *s, unsigned char maxc)
{
	unsigned char n;

	if (s == 0)
		return;
	n = 0;
	while (s[n] && n < maxc)
	{
		putchar(s[n]);
		n++;
	}
}

static void draw_frame(void)
{
	unsigned char y;

	OS_SETCOLOR(COL_FRAME);
	OS_SETXY(0, (unsigned char)(LIST_Y0 - 1));
	putchar(201);
	for (y = 0; y < 78; y++)
		putchar(205);
	put_stay(187);
	for (y = 0; y < LIST_ROWS; y++)
	{
		OS_SETXY(0, (unsigned char)(LIST_Y0 + y));
		putchar(186);
		OS_SETXY(79, (unsigned char)(LIST_Y0 + y));
		put_stay(186);
	}
	OS_SETXY(0, (unsigned char)(LIST_Y0 + LIST_ROWS));
	putchar(200);
	for (y = 0; y < 78; y++)
		putchar(205);
	put_stay(188);
}

static void draw_tabs(void)
{
	unsigned char i;
	unsigned char x;
	unsigned char n;
	char right[32];

	fill_line(0, COL_TAB);
	x = 1;
	for (i = 0; i < 4; i++)
	{
		OS_SETXY(x, 0);
		OS_SETCOLOR((unsigned char)(i == g_sec ? COL_TABHI : COL_TAB));
		printf(" [%u]%s ", (unsigned int)(i + 1), section_name[i]);
		x = (unsigned char)(x + 12);
	}

	if (g_state == ST_LIST)
		sprintf(right, "[ZiFi %s] [%s] p=%02u", uVer, drv_name[netDriver], g_page);
	else
		sprintf(right, "[ZiFi %s] [%s]", uVer, drv_name[netDriver]);
	n = (unsigned char)strlen(right);
	if (n == 0)
		return;
	if (n > 29)
		n = 29;
	x = (unsigned char)(80 - n);
	OS_SETXY(x, 0);
	OS_SETCOLOR(COL_TITLE);
	i = 0;
	while ((unsigned char)(i + 1) < n)
	{
		putchar(right[i]);
		i++;
	}
	put_stay(right[i]);
}

static void draw_help(void)
{
	fill_line(ROW_HELP, COL_HELP);
	OS_SETXY(0, ROW_HELP);
	if (g_state == ST_SITES)
		printf(" Enter open  /find  1-4 section  E exit");
	else if (g_state == ST_TEXT)
		printf(" Up/Dn  PgUp/Dn  Esc back");
	else
		printf(" /find  P stop  PgUp/Dn  </>  Enter  Esc back  E exit");
}

static void draw_text_view(void)
{
	unsigned int i;
	unsigned int row;
	unsigned char col;
	unsigned char *p;
	unsigned char *end;

	map_list();
	p = listbuf;
	end = listbuf + list_bytes;
	i = 0;
	while (i < g_text_off && p < end)
	{
		if (*p == '\n')
			i++;
		p++;
	}

	for (row = 0; row < LIST_ROWS; row++)
	{
		OS_SETXY(1, (unsigned char)(LIST_Y0 + row));
		OS_SETCOLOR(COL_LIST);
		spaces(78);
		OS_SETXY(1, (unsigned char)(LIST_Y0 + row));
		col = 0;
		while (p < end && *p && *p != '\n' && col < 78)
		{
			if (*p != '\r')
			{
				putchar(*p);
				col++;
			}
			p++;
		}
		while (p < end && *p && *p != '\n')
			p++;
		if (p < end && *p == '\n')
			p++;
	}
}

static void draw_one_row(unsigned int vis)
{
	unsigned int idx;
	unsigned int n;
	unsigned char y;
	unsigned char sel;
	const SITE *s;

	y = (unsigned char)(LIST_Y0 + vis);
	idx = g_scroll + vis;
	n = cur_count();
	sel = (unsigned char)(idx == g_sel);

	OS_SETXY(1, y);
	if (idx >= n)
	{
		OS_SETCOLOR(COL_LIST);
		spaces(78);
		return;
	}

	if (g_state == ST_LIST)
	{
		map_list();
		OS_SETCOLOR((unsigned char)(sel ? COL_SEL : COL_LIST));
		spaces(78);
		OS_SETXY(2, y);
		put_trunc((char *)items[idx].title, 50);
		if (items[idx].year && items[idx].year[0] > 0x20)
		{
			OS_SETXY(54, y);
			OS_SETCOLOR((unsigned char)(sel ? COL_SEL : COL_META));
			put_trunc((char *)items[idx].year, 4);
		}
		if (items[idx].author && items[idx].author[0] > 0x20)
		{
			OS_SETXY(60, y);
			OS_SETCOLOR((unsigned char)(sel ? COL_SEL : COL_META));
			put_trunc((char *)items[idx].author, 18);
		}
		return;
	}

	s = cur_sites();
	OS_SETCOLOR((unsigned char)(sel ? COL_SEL : COL_LIST));
	spaces(78);
	OS_SETXY(2, y);
	put_trunc(s[idx].title, 54);
	OS_SETXY(58, y);
	OS_SETCOLOR((unsigned char)(sel ? COL_SEL : COL_META));
	if (s[idx].action == ACT_SAVE)
		printf("save");
	else if (s[idx].action == ACT_PLAY)
		printf("play");
	else if (s[idx].action == ACT_GFX)
		printf("gfx");
	else if (s[idx].action == ACT_TEXT)
		printf("text");
	else
		printf("list");
}

static void draw_list(void)
{
	unsigned int row;

	clamp_view();
	if (g_state == ST_TEXT)
	{
		draw_text_view();
		return;
	}
	for (row = 0; row < LIST_ROWS; row++)
		draw_one_row(row);
}

static void draw_screen(void)
{
	draw_tabs();
	draw_frame();
	draw_list();
	draw_status_row();
	draw_help();
}

static void refresh(void)
{
	unsigned int vis;
	unsigned int oldvis;

	if (g_dirty == 0)
		return;
	mouse_hide();
	if (g_dirty & DIRTY_FULL)
		draw_screen();
	else if (g_dirty & DIRTY_LIST)
		draw_list();
	else if (g_dirty & DIRTY_SEL)
	{
		clamp_view();
		oldvis = g_sel_old - g_scroll;
		vis = g_sel - g_scroll;
		if (oldvis < LIST_ROWS)
			draw_one_row(oldvis);
		if (vis < LIST_ROWS && vis != oldvis)
			draw_one_row(vis);
	}
	g_dirty = 0;
	mouse_show();
}

static unsigned char url_ext_is(const char *url, const char *ext)
{
	const char *dot;
	const char *p;
	unsigned char i;
	unsigned char a;
	unsigned char b;

	dot = 0;
	for (p = url; *p && *p != '?' && *p != '\r' && *p != '\n'; p++)
	{
		if (*p == '.')
			dot = p + 1;
	}
	if (dot == 0)
		return 0;
	for (i = 0; ext[i]; i++)
	{
		a = (unsigned char)dot[i];
		b = (unsigned char)ext[i];
		if (a >= 'A' && a <= 'Z')
			a = (unsigned char)(a + 32);
		if (b >= 'A' && b <= 'Z')
			b = (unsigned char)(b + 32);
		if (a != b)
			return 0;
	}
	a = (unsigned char)dot[i];
	return (unsigned char)(a == 0 || a == '?' || a == '&' || a == '\r' || a == '\n');
}

static void gfx_show(void)
{
	clearStatus();
	OS_SETBORDER(0);
	OS_SETGFX(0x83);
	OS_SETSCREEN(1);
	pic_shown = 1;
}

static void gfx_hide(void)
{
	if (!pic_shown)
	{
		map_list();
		return;
	}
	OS_SETSCREEN(0);
	OS_SETGFX(0x86);
	pic_shown = 0;
	map_list();
}

static unsigned char load_gfx(unsigned int idx)
{
	const char *url;
	unsigned char unzip;
	unsigned char b0;
	unsigned char b1;
	char line[80];

	map_list();
	if (idx >= nitems)
		return 0;
	url = (char *)items[idx].url;
	if (url == 0 || url[0] == 0)
		return 0;

	if (url_ext_is(url, "sxg"))
	{
		set_status(COL_ERR, "SXG: open with sxgview");
		return 0;
	}

	url_filename(url, (char *)g_fname);
	unzip = (unsigned char)(strncmp(url, "https://", 8) == 0);
	if (!http_get(url, DEST_SCR, unzip))
	{
		map_list();
		return 0;
	}

	map_pic();
	if (g_got < SCR_SIZE)
	{
		sprintf(line, "not 6912 (%lu bytes)", g_got);
		set_status(COL_ERR, line);
		map_list();
		return 0;
	}

	b0 = *((unsigned char *)0xC000);
	b1 = *((unsigned char *)0xC001);
	if (b0 == '<' || (b0 == 'H' && b1 == 'T'))
	{
		set_status(COL_ERR, "not a screen (HTML?)");
		map_list();
		return 0;
	}
	if (b0 == 0x50 && b1 == 0x4B)
	{
		set_status(COL_ERR, "zip: S saves via unzipremote");
		map_list();
		return 0;
	}
	if (b0 == 0x7F)
	{
		set_status(COL_ERR, "SXG/CLA, not 6912");
		map_list();
		return 0;
	}
	return 1;
}

static unsigned int gfx_step(int dir)
{
	unsigned int i;
	unsigned int tries;

	i = g_sel;
	tries = 0;
	map_list();
	while (tries < nitems)
	{
		if (dir > 0)
		{
			if (i + 1 >= nitems)
				return 0xffffu;
			i++;
		}
		else
		{
			if (i == 0)
				return 0xffffu;
			i--;
		}
		if (!url_ext_is((char *)items[i].url, "sxg"))
			return i;
		tries++;
	}
	return 0xffffu;
}

static void view_gfx_loop(void)
{
	unsigned char key;
	unsigned int nxt;
	unsigned char ok;
	int dir;

	mouse_hide();
	ok = 1;
	if (!load_gfx(g_sel))
		return;
	gfx_show();
	for (;;)
	{
		YIELD();
		key = (unsigned char)OS_GETKEY();
		if (key == 0)
			continue;
		if (key == KEY_UP)
			dir = -1;
		else if (key == KEY_DOWN)
			dir = 1;
		else
			break;
		nxt = gfx_step(dir);
		if (nxt == 0xffffu)
			continue;
		g_sel = nxt;
		clamp_view();
		gfx_hide();
		g_dirty |= DIRTY_FULL;
		refresh();
		if (!load_gfx(g_sel))
		{
			ok = 0;
			break;
		}
		gfx_show();
	}
	gfx_hide();
	if (ok)
		g_dirty |= DIRTY_FULL;
}

static void sel_move(int delta)
{
	unsigned int n;
	unsigned int old_sel;
	unsigned int old_scroll;
	int v;

	n = cur_count();
	if (n == 0)
		return;
	old_sel = g_sel;
	old_scroll = g_scroll;
	v = (int)g_sel + delta;
	if (v < 0)
		v = 0;
	if (v >= (int)n)
		v = (int)n - 1;
	g_sel = (unsigned int)v;
	clamp_view();
	if (g_sel == old_sel && g_scroll == old_scroll)
		return;
	if (g_scroll != old_scroll)
		g_dirty |= DIRTY_LIST;
	else
	{
		g_sel_old = old_sel;
		g_dirty |= DIRTY_SEL;
	}
}

static void open_site(unsigned int idx)
{
	const SITE *s;

	s = cur_sites();
	if (s[idx].title == 0)
		return;
	g_action = s[idx].action;
	strncpy((char *)g_list_url, s[idx].url, sizeof(g_list_url) - 1);
	g_list_url[sizeof(g_list_url) - 1] = 0;
	set_list_base((char *)g_list_url);
	fetch_list(1);
}

static void open_item(unsigned int idx)
{
	const char *url;
	unsigned char unzip;

	if (idx >= nitems)
		return;
	map_list();
	url = (char *)items[idx].url;
	if (url == 0 || url[0] == 0)
		return;

	if (g_action == ACT_LIST)
	{
		strncpy((char *)g_list_url, url, sizeof(g_list_url) - 1);
		g_list_url[sizeof(g_list_url) - 1] = 0;
		set_list_base((char *)g_list_url);
		fetch_list(1);
		return;
	}

	if (g_action == ACT_TEXT)
	{
		if (!http_get(url, DEST_MEM, 0))
			return;
		fix_list_encoding();
		g_state = ST_TEXT;
		g_text_off = 0;
		g_dirty |= DIRTY_FULL;
		refresh();
		set_status(COL_OK, "text  Esc=back");
		return;
	}

	if (g_action == ACT_PLAY)
	{
		play_item(url);
		return;
	}

	if (g_action == ACT_GFX)
	{
		if (url_ext_is(url, "sxg"))
			view_sxg(url);
		else
			view_gfx_loop();
		return;
	}

	unzip = (unsigned char)(g_action == ACT_SAVE);
	if (!unzip && strncmp(url, "https://", 8) == 0)
		unzip = 1;

	save_url(url, unzip);
}

static void activate(void)
{
	if (g_state == ST_SITES)
		open_site(g_sel);
	else if (g_state == ST_LIST)
		open_item(g_sel);
}

static void page_delta(int d)
{
	int p;

	if (g_state != ST_LIST)
	{
		if (d < 0 && g_sec)
			g_sec--;
		else if (d > 0 && g_sec < 3)
			g_sec++;
		g_sel = 0;
		g_scroll = 0;
		g_dirty |= DIRTY_FULL;
		return;
	}
	p = (int)g_page + d;
	if (p < 1)
		p = 1;
	if (p == (int)g_page)
		return;
	fetch_list((unsigned int)p);
}

static void go_back(void)
{
	if (g_state == ST_TEXT)
	{
		fetch_list(g_page);
		return;
	}
	if (g_state == ST_LIST)
	{
		g_state = ST_SITES;
		g_sel = 0;
		g_scroll = 0;
		nitems = 0;
		g_dirty |= DIRTY_FULL;
		clearStatus();
		return;
	}
}

static unsigned char read_net_ini(void)
{
	FILE *fpini;
	unsigned char *p;
	unsigned int curNet;

	curNet = 0;
	OS_GETPATH(curPath);
	OS_SETSYSDRV();
	OS_CHDIR("/");
	OS_CHDIR("ini");
	fpini = OS_OPENHANDLE("network.ini", 0x80);
	if (((int)fpini) & 0xff)
	{
		OS_CHDIR(curPath);
		return 0;
	}
	OS_READHANDLE(netbuf, fpini, sizeof(netbuf) - 1);
	OS_CLOSEHANDLE(fpini);
	p = (unsigned char *)strstr((char *)netbuf, "currentNetwork");
	if (p)
		sscanf((char *)p + 14 + 1, "%u", &curNet);
	OS_CHDIR(curPath);
	if (curNet > 2)
		curNet = 0;
	return (unsigned char)curNet;
}

static void handle_key(unsigned int key)
{
	if (g_search_on)
	{
		handle_search_key(key);
		return;
	}

	if (g_state == ST_TEXT)
	{
		if (key == KEY_UP || key == 'k')
		{
			if (g_text_off)
				g_text_off--;
			g_dirty |= DIRTY_LIST;
		}
		else if (key == KEY_DOWN || key == 'j')
		{
			g_text_off++;
			g_dirty |= DIRTY_LIST;
		}
		else if (key == KEY_PGUP)
		{
			if (g_text_off >= LIST_ROWS)
				g_text_off = (unsigned int)(g_text_off - LIST_ROWS);
			else
				g_text_off = 0;
			g_dirty |= DIRTY_LIST;
		}
		else if (key == KEY_PGDN)
		{
			g_text_off = (unsigned int)(g_text_off + LIST_ROWS);
			g_dirty |= DIRTY_LIST;
		}
		else if (key == KEY_ESC || key == KEY_BS)
			go_back();
		return;
	}

	switch (key)
	{
	case KEY_UP:
	case 'k':
		sel_move(-1);
		break;
	case KEY_DOWN:
	case 'j':
		sel_move(1);
		break;
	case KEY_PGUP:
		sel_move(-(int)LIST_ROWS);
		break;
	case KEY_PGDN:
		sel_move((int)LIST_ROWS);
		break;
	case KEY_LEFT:
		page_delta(-1);
		break;
	case KEY_RIGHT:
		page_delta(1);
		break;
	case KEY_ENTER:
	case ' ':
		activate();
		break;
	case KEY_ESC:
	case KEY_BS:
		go_back();
		break;
	case '1':
		g_sec = SEC_FILES;
		g_state = ST_SITES;
		g_sel = 0;
		g_scroll = 0;
		g_dirty |= DIRTY_FULL;
		break;
	case '2':
		g_sec = SEC_GFX;
		g_state = ST_SITES;
		g_sel = 0;
		g_scroll = 0;
		g_dirty |= DIRTY_FULL;
		break;
	case '3':
		g_sec = SEC_MUSIC;
		g_state = ST_SITES;
		g_sel = 0;
		g_scroll = 0;
		g_dirty |= DIRTY_FULL;
		break;
	case '4':
		g_sec = SEC_PRESS;
		g_state = ST_SITES;
		g_sel = 0;
		g_scroll = 0;
		g_dirty |= DIRTY_FULL;
		break;
	case 'p':
	case 'P':
		g_autoplay = 0;
		stop_player();
		set_status(COL_OK, "stopped");
		break;
	case '/':
	case 'f':
	case 'F':
		if (g_state == ST_LIST || g_state == ST_SITES)
			start_search();
		break;
	case 'r':
	case 'R':
		if (g_state == ST_LIST)
			fetch_list(g_page);
		break;
	case 'e':
	case 'E':
	case 'q':
	case 'Q':
		stop_player();
		exit(0);
		break;
	default:
		break;
	}
}

static void handle_mouse(void)
{
	unsigned char wheel;
	unsigned char y;
	unsigned char x;
	unsigned int idx;

	if (g_search_on)
		return;

	wheel = (unsigned char)((mouse_btns >> 4) & 15);
	x = m_cell_x;
	y = m_cell_y;

	if (wheel != g_wheel_prev)
	{
		if ((unsigned char)(wheel - g_wheel_prev) < 8)
			sel_move(1);
		else
			sel_move(-1);
		g_wheel_prev = wheel;
	}

	if (!m_lmb_click)
		return;

	if (y == ROW_STAT && (g_state == ST_LIST || g_state == ST_SITES))
	{
		start_search();
		return;
	}

	if (y == 0)
	{
		if (x < 13)
			handle_key('1');
		else if (x < 25)
			handle_key('2');
		else if (x < 37)
			handle_key('3');
		else if (x < 49)
			handle_key('4');
		else if (g_state == ST_LIST && x >= 76)
		{
			if (x < 78)
				page_delta(-1);
			else
				page_delta(1);
		}
	}
	else if (y >= LIST_Y0 && y < (unsigned char)(LIST_Y0 + LIST_ROWS))
	{
		idx = g_scroll + (unsigned int)(y - LIST_Y0);
		if (idx < cur_count())
		{
			if (idx == g_sel)
				activate();
			else
			{
				g_sel_old = g_sel;
				g_sel = idx;
				g_dirty |= DIRTY_SEL;
			}
		}
	}
}

void main(void)
{
	signed long gk;
	unsigned char key;

	OS_SETGFX(0x86);
	OS_CLS(0);
	main_pg.l = OS_GETMAINPAGES();
	pg_app = main_pg.pgs.window_3;
	pg_scr1 = (unsigned char)(OS_GETSCR1() >> 8);
	pic_shown = 0;
	g_have_player = 0;
	g_autoplay = 0;
	g_search_on = 0;
	g_query[0] = 0;
	g_query_len = 0;
	g_list_base[0] = 0;
	g_play_title[0] = 0;
	map_list();

	targetadr.family = AF_INET;
	targetadr.porth = 0;
	targetadr.portl = 80;

	OS_SETSYSDRV();
	OS_MKDIR("../downloads");
	OS_MKDIR("../downloads/zifi");
	OS_CHDIR("../downloads/zifi");
	OS_GETPATH(g_save_dir);

	netDriver = read_net_ini();
	g_dns_host[0] = 0;
	if (netDriver == 1)
	{
		OS_GETPATH(curPath);
		loadEspConfig();
		OS_CHDIR(curPath);
		uart_init(divider);
		espReBoot();
	}
	else if (netDriver == 2)
	{
		OS_ESPINIT();
		EspGetDns();
	}
	else
		get_dns();
	OS_CHDIR(g_save_dir);

	g_sec = SEC_FILES;
	g_state = ST_SITES;
	g_sel = 0;
	g_scroll = 0;
	g_page = 1;
	g_wheel_prev = 0;
	m_x_fp = 40u * MX_FACT;
	m_y_fp = 12u * MY_FACT;
	m_cell_x = 40;
	m_cell_y = 12;
	m_raw_btns = LMB_MASK;
	m_have_sample = 0;
	m_cursor_on = 0;
	g_dirty = DIRTY_FULL;
	refresh();

	for (;;)
	{
		YIELD();
		gk = OS_GETKEY();
		key = (unsigned char)gk;
		mouse_poll();
		handle_mouse();
		if (key)
			handle_key((unsigned int)key);
		poll_player();
		refresh();
	}
}
