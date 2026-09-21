/*
 * enet - ESPNET WiFi setup for NedoOS
 * UI chrome follows ngsplay (title / double frame / hint).
 * UART init: esp-com.c. Protocol via kernel BDOS (same as espcfg), not userland UART.
 */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <tcp.h>
#include <espnet.h>
#include <intrz80.h>

#define NET_OK(v) ((int)(v) >= 0)

#define true 1
#define false 0

#define COL_LIST 103
#define COL_CURSOR 188
#define COL_STAT 223
#define COL_BTN 79
#define COL_ERR ((unsigned char)(0xC0 | PAPER_RED | INK_WHITE))
#define COL_OK ((unsigned char)(0x40 | PAPER_BLACK | INK_GREEN))
#define COL_FIELD ((unsigned char)(0x40 | PAPER_BLACK | INK_YELLOW))

#define KEY_ENTER 13
#define KEY_ESC 27
#define KEY_TAB 9
#define KEY_LEFT 248
#define KEY_RIGHT 251
#define KEY_UP 250
#define KEY_DOWN 249
#define KEY_DEL 252
#define KEY_HOME 28
#define KEY_END 30

#define COL_INP ((unsigned char)(0xC0 | PAPER_BLUE | INK_YELLOW))
#define DLG_X 18
#define DLG_Y 8
#define DLG_W 44
#define DLG_H 5
#define FLD_X 20
#define FLD_Y 10
#define FLD_W 40

#define SCR_HOME 0
#define SCR_SCAN 1
#define SCR_PORT 2

#define WIN_X 3
#define WIN_Y 3
#define WIN_W 74
#define WIN_H 12
#define ST_X 3
#define ST_Y 17
#define ST_W 74
#define ST_H 4
#define COLS_SAFE 79
#define SCAN_ROWS ((unsigned char)(WIN_H - 2u))
#define SCAN_Y0 ((unsigned char)(WIN_Y + 2u))
#define PORT_Y_TYPE ((unsigned char)(WIN_Y + 3u))
#define PORT_Y_SPD ((unsigned char)(WIN_Y + 5u))

unsigned char netbuf[1024];
unsigned char curPath[128];
const unsigned char gotWiFi[] = "WIFI GOT IP";
unsigned char uVer[] = "1.2";

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

void clearStatus(void)
{
}

#include "../common/esp-com.c"

static unsigned char g_cfg[20];
static unsigned char g_wpay[ESPNET_WIFI_CONN_SIZE];
static unsigned char g_info[ESPNET_INFO_SIZE];
static unsigned char g_scan[ESPNET_SCAN_MAX * ESPNET_SCAN_REC];
static unsigned char g_wst[ESPNET_WIFI_STATUS_SIZE];
static unsigned char g_ssid[ESPNET_SSID_SIZE];
static unsigned char g_pass[ESPNET_PASS_SIZE];
static unsigned char g_msg[72];
static unsigned int g_scan_n;
static unsigned int g_sel;
static unsigned int g_scroll;
static unsigned char g_scr;
static unsigned char g_info_ok;
static unsigned char g_wifi_ok;
static unsigned char g_port_f;
static unsigned char g_watch;
static unsigned int g_edit_type;
static unsigned int g_edit_div;

static void spaces(unsigned char n)
{
	while (n) {
		putchar(' ');
		n--;
	}
}

static void fill_bar(unsigned char y, unsigned char color)
{
	OS_SETCOLOR(color);
	OS_SETXY(0, y);
	spaces(COLS_SAFE);
}

static void draw_dframe(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color)
{
	unsigned char q;

	OS_SETCOLOR(color);
	OS_SETXY(x - 1, y - 1);
	putchar(201);
	for (q = 0; q < w; q++)
		putchar(205);
	putchar(187);
	for (q = 0; q < h; q++) {
		OS_SETXY(x - 1, y + q);
		putchar(186);
		OS_SETXY(x + w, y + q);
		putchar(186);
	}
	OS_SETXY(x - 1, y + h);
	putchar(200);
	for (q = 0; q < w; q++)
		putchar(205);
	putchar(188);
}

static void clear_win(unsigned char x, unsigned char y, unsigned char w, unsigned char h, unsigned char color)
{
	unsigned char q;

	OS_SETCOLOR(color);
	for (q = 0; q < h; q++) {
		OS_SETXY(x, y + q);
		spaces(w);
	}
}

static void set_msg(const char *s)
{
	strncpy((char *)g_msg, s, sizeof(g_msg) - 1);
	g_msg[sizeof(g_msg) - 1] = 0;
}

static void set_msg_err(unsigned int r)
{
	unsigned char e;

	e = (unsigned char)r;
	if ((int)r < 0)
		e = ESPNET_ERR_INTR;
	if (e == ESPNET_ERR_INTR)
		sprintf((char *)g_msg, "Error %u UART timeout (no ESP reply)", (unsigned int)e);
	else if (e == ESPNET_ERR_HOSTUNREACH)
		sprintf((char *)g_msg, "Error %u no IP (AP reject / DHCP)", (unsigned int)e);
	else
		sprintf((char *)g_msg, "Error %u", (unsigned int)e);
}

static const char *com_name(unsigned int t)
{
	switch (t) {
	case 0:
		return "16550 no AFC";
	case 1:
		return "ATM2 COM";
	case 2:
		return "16550 AFC";
	case 3:
		return "ATM2IOESP";
	default:
		return "unknown";
	}
}

static unsigned long com_baud(unsigned int div)
{
	if (div == 0)
		return 115200UL;
	return 115200UL / div;
}

static const char *wifi_name(unsigned char st)
{
	switch (st) {
	case ESPNET_WIFI_CONNECTING:
		return "connecting";
	case ESPNET_WIFI_GOT_IP:
		return "got IP";
	case ESPNET_WIFI_AP:
		return "AP";
	default:
		return "idle";
	}
}

static void paint_row(unsigned char x, unsigned char y, unsigned char w, unsigned char color)
{
	OS_SETCOLOR(color);
	OS_SETXY(x, y);
	spaces(w);
	OS_SETXY(x, y);
}

static void draw_chrome(void)
{
	OS_CLS(0);
	fill_bar(0, COL_STAT);
	OS_SETXY(1, 0);
	OS_SETCOLOR(COL_STAT);
	printf(" ESPNET %s ", uVer);
	fill_bar(23, COL_STAT);
	OS_SETXY(1, 23);
	OS_SETCOLOR(COL_STAT);
	printf("[C] Connect  [D] Disconnect  [S] Scan  [P] Port  [R] Refresh  [Esc] Quit");
	draw_dframe(WIN_X, WIN_Y, WIN_W, WIN_H, COL_LIST);
	draw_dframe(ST_X, ST_Y, ST_W, ST_H, COL_STAT);
}

static void draw_status(void)
{
	clear_win(ST_X, ST_Y, ST_W, ST_H, COL_STAT);
	OS_SETXY(ST_X, ST_Y);
	OS_SETCOLOR(COL_STAT);
	printf("%s", g_msg);
	OS_SETXY(ST_X, ST_Y + 2);
	printf("COM %u  %s  %lu baud  div %u",
	       comType, com_name(comType), com_baud(divider), divider);
}

static void put_le16(unsigned char *p, unsigned int v)
{
	p[0] = (unsigned char)v;
	p[1] = (unsigned char)(v >> 8);
}

static void settle(void)
{
	long start;
	unsigned int guard;

	start = time();
	guard = 0;
	while ((time() - start) < 25L) {
		YIELD();
		if (++guard == 0)
			break;
	}
}

/* Port screen only. Startup must not SETUART: it re-inits the UART,
 * drops ESP sockets, and GETINFO right after that times out (espcfg waits). */
static void apply_uart(void)
{
	OS_GETUART(g_cfg);
	g_cfg[0] = (unsigned char)comType;
	g_cfg[1] = (unsigned char)divider;
	put_le16(g_cfg + 2, RBR_THR);
	put_le16(g_cfg + 4, IER);
	put_le16(g_cfg + 6, IIR_FCR);
	put_le16(g_cfg + 8, LCR);
	put_le16(g_cfg + 10, MCR);
	put_le16(g_cfg + 12, LSR);
	put_le16(g_cfg + 14, MSR);
	put_le16(g_cfg + 16, SR);
	uart_init((unsigned char)divider);
	OS_SETUART(g_cfg);
	settle();
}

static unsigned int g_fetch_err;

static unsigned char fetch_quiet(void)
{
	unsigned int r;

	g_info_ok = 0;
	g_wifi_ok = 0;
	g_fetch_err = 0;
	r = OS_GETINFO(g_info);
	if (!NET_OK(r)) {
		g_fetch_err = r;
		return 0;
	}
	g_info_ok = 1;
	r = OS_WIFISTATUS(g_wst);
	if (NET_OK(r))
		g_wifi_ok = 1;
	return 1;
}

static void fetch_net(void)
{
	if (!fetch_quiet())
		set_msg_err(g_fetch_err);
}

static void draw_home(void)
{
	unsigned int heap;
	unsigned char st;
	signed char rssi;
	char *ssid;
	char *chipname;

	clear_win(WIN_X, WIN_Y, WIN_W, WIN_H, COL_LIST);

	paint_row(WIN_X, WIN_Y, WIN_W, COL_LIST);
	if (!g_info_ok) {
		printf("Firmware: no reply  (check port / flash ESPNET)");
	} else {
		heap = (unsigned int)g_info[ESPNET_INFO_HEAP] |
		       ((unsigned int)g_info[ESPNET_INFO_HEAP + 1] << 8);
		chipname = "ESP32";
		if (g_info[ESPNET_INFO_CHIP] == ESPNET_CHIP_ESP8266)
			chipname = "ESP8266";
		else if (g_info[ESPNET_INFO_CHIP] == ESPNET_CHIP_ESP32C3)
			chipname = "ESP32-C3";
		printf("Firmware  v%u.%u   %s   socks %u   heap %u",
		       (unsigned int)g_info[ESPNET_INFO_VER_MAJOR],
		       (unsigned int)g_info[ESPNET_INFO_VER_MINOR],
		       chipname,
		       (unsigned int)g_info[ESPNET_INFO_MAX_SOCKS],
		       heap);
	}

	paint_row(WIN_X, WIN_Y + 2, WIN_W, COL_LIST);
	printf("Wi-Fi");
	if (!g_info_ok && !g_wifi_ok)
		printf("     --");
	else {
		st = g_wifi_ok ? g_wst[ESPNET_WSTAT_FLAGS] : 0;
		rssi = g_wifi_ok ? (signed char)g_wst[ESPNET_WSTAT_RSSI]
				 : (signed char)g_info[ESPNET_INFO_RSSI];
		if (g_info_ok)
			printf("     %s   rssi %d",
			       wifi_name(g_info[ESPNET_INFO_WIFI]), (int)rssi);
		if (g_wifi_ok) {
			if (st & ESPNET_WSTAT_F_HASIP)
				printf("   IP ok");
		}
	}

	paint_row(WIN_X, WIN_Y + 3, WIN_W, COL_LIST);
	ssid = "";
	if (g_wifi_ok)
		ssid = (char *)(g_wst + ESPNET_WSTAT_SSID);
	else if (g_info_ok)
		ssid = (char *)(g_info + ESPNET_INFO_SSID);
	if (ssid[0] == 0)
		ssid = "(none)";
	printf("SSID      %.32s", ssid);

	paint_row(WIN_X, WIN_Y + 4, WIN_W, COL_LIST);
	if (g_wifi_ok) {
		printf("IP        %u.%u.%u.%u     MAC %02X:%02X:%02X:%02X:%02X:%02X",
		       (unsigned int)g_wst[ESPNET_WSTAT_IP],
		       (unsigned int)g_wst[ESPNET_WSTAT_IP + 1],
		       (unsigned int)g_wst[ESPNET_WSTAT_IP + 2],
		       (unsigned int)g_wst[ESPNET_WSTAT_IP + 3],
		       (unsigned int)g_wst[ESPNET_WSTAT_MAC],
		       (unsigned int)g_wst[ESPNET_WSTAT_MAC + 1],
		       (unsigned int)g_wst[ESPNET_WSTAT_MAC + 2],
		       (unsigned int)g_wst[ESPNET_WSTAT_MAC + 3],
		       (unsigned int)g_wst[ESPNET_WSTAT_MAC + 4],
		       (unsigned int)g_wst[ESPNET_WSTAT_MAC + 5]);
	} else if (g_info_ok) {
		printf("IP        %u.%u.%u.%u",
		       (unsigned int)g_info[ESPNET_INFO_IP],
		       (unsigned int)g_info[ESPNET_INFO_IP + 1],
		       (unsigned int)g_info[ESPNET_INFO_IP + 2],
		       (unsigned int)g_info[ESPNET_INFO_IP + 3]);
	} else
		printf("IP        --");

	paint_row(WIN_X, WIN_Y + 6, WIN_W, COL_LIST);
	printf("Port      type %u  %s", comType, com_name(comType));
	paint_row(WIN_X, WIN_Y + 7, WIN_W, COL_LIST);
	printf("          %lu baud   divider %u   RBR 0x%04X",
	       com_baud(divider), divider, RBR_THR);

	paint_row(WIN_X, WIN_Y + 9, WIN_W, COL_LIST);
	if (g_info_ok)
		printf("Caps      0x%02x%s",
		       (unsigned int)g_info[ESPNET_INFO_RESERVED],
		       (g_info[ESPNET_INFO_RESERVED] & ESPNET_CAP_CRC) ? "  CRC fw" : "");
	else
		printf("Caps      --");

	draw_status();
}

static void draw_scan_row(unsigned int idx)
{
	unsigned char *rec;
	unsigned char color;
	unsigned char y;
	unsigned char slot;
	char name[33];
	unsigned int n;

	if (idx < g_scroll)
		return;
	slot = (unsigned char)(idx - g_scroll);
	if (slot >= SCAN_ROWS)
		return;
	y = (unsigned char)(SCAN_Y0 + slot);
	if (idx >= g_scan_n) {
		paint_row(WIN_X, y, WIN_W, COL_LIST);
		return;
	}
	rec = g_scan + idx * ESPNET_SCAN_REC;
	n = 0;
	if (rec[0] == 0)
		strcpy(name, "(hidden)");
	else {
		while (n < 32 && rec[n]) {
			name[n] = (char)rec[n];
			n++;
		}
		name[n] = 0;
	}
	color = (idx == g_sel) ? COL_CURSOR : COL_LIST;
	paint_row(WIN_X, y, WIN_W, color);
	printf(" %2u  %.32s", idx + 1, name);
	n = 0;
	while (name[n])
		n++;
	while (n < 32) {
		putchar(' ');
		n++;
	}
	printf("  %4d dBm  ch %u",
	       (int)((signed char)rec[ESPNET_SCAN_RSSI]),
	       (unsigned int)rec[ESPNET_SCAN_CH]);
}

static void draw_scan_list(void)
{
	unsigned int i;

	for (i = 0; i < SCAN_ROWS; i++)
		draw_scan_row(g_scroll + i);
}

static void scan_clamp(void)
{
	if (g_scan_n == 0) {
		g_sel = 0;
		g_scroll = 0;
		return;
	}
	if (g_sel >= g_scan_n)
		g_sel = g_scan_n - 1;
	if (g_sel < g_scroll)
		g_scroll = g_sel;
	if (g_sel >= g_scroll + SCAN_ROWS)
		g_scroll = g_sel - (SCAN_ROWS - 1u);
}

static void scan_move(unsigned char down)
{
	unsigned int old;
	unsigned int oldsc;

	if (g_scan_n == 0)
		return;
	old = g_sel;
	oldsc = g_scroll;
	if (down) {
		if (g_sel + 1 < g_scan_n)
			g_sel++;
	} else if (g_sel)
		g_sel--;
	if (g_sel == old)
		return;
	scan_clamp();
	if (g_scroll != oldsc)
		draw_scan_list();
	else {
		draw_scan_row(old);
		draw_scan_row(g_sel);
	}
}

static void draw_scan(void)
{
	clear_win(WIN_X, WIN_Y, WIN_W, WIN_H, COL_LIST);
	paint_row(WIN_X, WIN_Y, WIN_W, COL_LIST);
	printf("Access points  %u   Enter=connect  Esc=back", g_scan_n);

	if (g_scan_n == 0) {
		paint_row(WIN_X, WIN_Y + 2, WIN_W, COL_LIST);
		printf("No APs. Esc=back");
		draw_status();
		return;
	}
	scan_clamp();
	draw_scan_list();
	draw_status();
}

static void draw_port_fields(void)
{
	unsigned char c0;
	unsigned char c1;

	c0 = (g_port_f == 0) ? COL_CURSOR : COL_LIST;
	c1 = (g_port_f == 1) ? COL_CURSOR : COL_LIST;
	paint_row(WIN_X, PORT_Y_TYPE, WIN_W, c0);
	printf("  Type      %u  %s", g_edit_type, com_name(g_edit_type));
	paint_row(WIN_X, PORT_Y_SPD, WIN_W, c1);
	printf("  Speed     %lu baud   divider %u",
	       com_baud(g_edit_div), g_edit_div);
}

static void draw_port(void)
{
	clear_win(WIN_X, WIN_Y, WIN_W, WIN_H, COL_LIST);
	paint_row(WIN_X, WIN_Y, WIN_W, COL_LIST);
	printf("COM port    Left/Right change    Tab field    Enter save    Esc cancel");
	draw_port_fields();
	paint_row(WIN_X, WIN_Y + 8, WIN_W, COL_LIST);
	printf("  0 Evo 16550    1 ATM2    2 16550 AFC    3 ATM2IOESP");
	paint_row(WIN_X, WIN_Y + 9, WIN_W, COL_LIST);
	printf("  divider 1=115200  2=57600  3=38400  6=19200  12=9600");
	paint_row(WIN_X, WIN_Y + 10, WIN_W, COL_LIST);
	printf("  Enter also sets ESP baud (fw 1.10+) and saves it on the module");
	draw_status();
}

static void redraw(void)
{
	if (g_scr == SCR_SCAN)
		draw_scan();
	else if (g_scr == SCR_PORT)
		draw_port();
	else
		draw_home();
}

static void watch_net(void)
{
	static unsigned char pace;
	unsigned char ip0, flags;

	if (!g_watch || g_scr != SCR_HOME)
		return;
	pace++;
	if (pace & 15)
		return;
	ip0 = g_wst[ESPNET_WSTAT_IP];
	flags = g_wst[ESPNET_WSTAT_FLAGS];
	if (!fetch_quiet())
		return;
	if (g_wifi_ok && (g_wst[ESPNET_WSTAT_FLAGS] & ESPNET_WSTAT_F_HASIP)) {
		g_watch = 0;
		set_msg("Connected.");
		redraw();
		return;
	}
	if (g_wst[ESPNET_WSTAT_IP] != ip0 || g_wst[ESPNET_WSTAT_FLAGS] != flags)
		redraw();
}

static void do_refresh(void)
{
	set_msg("Query firmware...");
	draw_status();
	fetch_net();
	if (g_info_ok)
		set_msg("Ready.");
	g_scr = SCR_HOME;
	redraw();
}

static unsigned char inv_attr(unsigned char a)
{
	return (unsigned char)(((a & 7u) << 3) | ((a >> 3) & 7u) | (a & 0xC0u));
}

static void dlg_paint_field(unsigned char *dst, unsigned int n, unsigned int curs,
			    unsigned int vis, unsigned char hide)
{
	unsigned int i;
	unsigned int idx;
	unsigned char ch;
	unsigned char cx;

	OS_SETCOLOR(COL_INP);
	OS_SETXY(FLD_X, FLD_Y);
	for (i = 0; i < FLD_W; i++) {
		idx = vis + i;
		if (idx < n) {
			ch = hide ? '*' : dst[idx];
			if (ch < 32)
				ch = '.';
			putchar((char)ch);
		} else
			putchar(' ');
	}
	if (curs < vis)
		cx = 0;
	else if (curs - vis >= FLD_W)
		cx = (unsigned char)(FLD_W - 1);
	else
		cx = (unsigned char)(curs - vis);
	OS_SETXY((unsigned char)(FLD_X + cx), FLD_Y);
	OS_PRATTR(inv_attr(COL_INP));
}

static unsigned char edit_line(const char *title, unsigned char *dst, unsigned int maxn,
			       unsigned char hide)
{
	unsigned int n;
	unsigned int curs;
	unsigned int vis;
	unsigned int k;
	unsigned int i;

	n = (unsigned int)strlen((char *)dst);
	if (n >= maxn)
		n = maxn - 1;
	dst[n] = 0;
	curs = n;
	vis = 0;

	draw_dframe(DLG_X, DLG_Y, DLG_W, DLG_H, COL_STAT);
	clear_win(DLG_X, DLG_Y, DLG_W, DLG_H, COL_STAT);
	OS_SETXY(DLG_X + 1, DLG_Y);
	OS_SETCOLOR(COL_STAT);
	printf("%.42s", title);
	OS_SETXY(DLG_X + 1, DLG_Y + 4);
	printf("Enter=OK   Esc=cancel");

	for (;;) {
		if (curs < vis)
			vis = curs;
		if (curs >= vis + FLD_W)
			vis = curs - FLD_W + 1;
		dlg_paint_field(dst, n, curs, vis, hide);
		for (;;) {
			YIELD();
			k = _low_level_get();
			if (k == 0)
				continue;
			if (k == KEY_ENTER)
				return 1;
			if (k == KEY_ESC) {
				dst[0] = 0;
				return 0;
			}
			if (k == KEY_LEFT && curs)
				curs--;
			else if (k == KEY_RIGHT && curs < n)
				curs++;
			else if (k == KEY_HOME)
				curs = 0;
			else if (k == KEY_END)
				curs = n;
			else if ((k == 8 || k == 127) && curs) {
				for (i = curs - 1; i < n; i++)
					dst[i] = dst[i + 1];
				n--;
				curs--;
			} else if (k == KEY_DEL && curs < n) {
				for (i = curs; i < n; i++)
					dst[i] = dst[i + 1];
				n--;
			} else if (k >= 32 && k < KEY_LEFT && n + 1 < maxn) {
				for (i = n; i > curs; i--)
					dst[i] = dst[i - 1];
				dst[curs] = (unsigned char)k;
				n++;
				dst[n] = 0;
				curs++;
			}
			break;
		}
	}
}

static void do_scan(void)
{
	unsigned int n;

	g_watch = 0;
	set_msg("Scanning...");
	draw_status();
	n = OS_WIFISCAN(g_scan);
	if (!NET_OK(n)) {
		g_scan_n = 0;
		set_msg_err(n);
		g_scr = SCR_HOME;
		redraw();
		return;
	}
	g_scan_n = n;
	g_sel = 0;
	g_scroll = 0;
	sprintf((char *)g_msg, "%u AP found", n);
	g_scr = SCR_SCAN;
	redraw();
}

static void do_connect_sel(void)
{
	unsigned char *rec;
	unsigned int r;

	if (g_sel >= g_scan_n)
		return;
	rec = g_scan + g_sel * ESPNET_SCAN_REC;
	memset(g_ssid, 0, ESPNET_SSID_SIZE);
	memset(g_pass, 0, ESPNET_PASS_SIZE);
	if (rec[0] == 0) {
		if (!edit_line("SSID", g_ssid, ESPNET_SSID_SIZE, 0) || g_ssid[0] == 0) {
			set_msg("Cancelled.");
			redraw();
			return;
		}
	} else
		strncpy((char *)g_ssid, (char *)rec, ESPNET_SSID_SIZE - 1);

	sprintf((char *)g_msg, "Password  %.20s  (empty=open)", g_ssid);
	if (!edit_line((char *)g_msg, g_pass, ESPNET_PASS_SIZE, 1)) {
		set_msg("Cancelled.");
		redraw();
		return;
	}
	sprintf((char *)g_msg, "Connecting to %.24s  (%u chars)", g_ssid,
		(unsigned int)strlen((char *)g_pass));
	draw_status();
	memset(g_wpay, 0, ESPNET_WIFI_CONN_SIZE);
	{
		unsigned int i;
		for (i = 0; i < ESPNET_SSID_SIZE - 1 && g_ssid[i]; i++)
			g_wpay[i] = g_ssid[i];
		for (i = 0; i < ESPNET_PASS_SIZE - 1 && g_pass[i]; i++)
			g_wpay[ESPNET_SSID_SIZE + i] = g_pass[i];
	}
	r = OS_WIFICONNECT(g_wpay);
	if (!NET_OK(r)) {
		set_msg_err(r);
		fetch_net();
		g_scr = SCR_HOME;
		redraw();
		return;
	}
	/* Join is already running on the ESP. Keep reading status from the
	 * main loop so DHCP can fill IP without another key. */
	g_watch = 1;
	set_msg("Waiting for DHCP...");
	g_scr = SCR_HOME;
	redraw();
}

static void do_disc(void)
{
	unsigned int r;

	set_msg("Disconnecting...");
	draw_status();
	g_watch = 0;
	r = OS_WIFIDISC();
	if (!NET_OK(r))
		set_msg_err(r);
	else
		set_msg("Disconnected.");
	fetch_net();
	g_scr = SCR_HOME;
	redraw();
}

static unsigned int next_div(unsigned int d, unsigned char dir)
{
	static unsigned int tab[5] = {1, 2, 3, 6, 12};
	unsigned char i;

	i = 0;
	while (i < 5 && tab[i] != d)
		i++;
	if (i >= 5)
		i = 0;
	if (dir) {
		if (i < 4)
			i++;
	} else {
		if (i > 0)
			i--;
	}
	return tab[i];
}

static unsigned char saveEspConfig(void)
{
	static unsigned char buf[48];
	FILE *espcom;

	OS_SETSYSDRV();
	OS_CHDIR("../ini");
	espcom = OS_CREATEHANDLE("espcom.ini", 0x80);
	if (((int)espcom) & 0xff)
		return 0;
	sprintf((char *)buf, "RBR_THR = 0x%04X\r\n", RBR_THR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "IER = 0x%04X\r\n", IER);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "IIR_FCR = 0x%04X\r\n", IIR_FCR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "LCR = 0x%04X\r\n", LCR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "MCR = 0x%04X\r\n", MCR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "LSR = 0x%04X\r\n", LSR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "MSR = 0x%04X\r\n", MSR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "SR = 0x%04X\r\n", SR);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "divider = %u\r\n", divider);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "comType = %u\r\n", comType);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "espType = %u\r\n", espType);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	sprintf((char *)buf, "espRetry = %u\r\n", espRetry);
	OS_WRITEHANDLE(buf, espcom, (unsigned int)strlen((char *)buf));
	OS_CLOSEHANDLE(espcom);
	return 1;
}

static void do_port_key(unsigned int key)
{
	if (key == KEY_TAB)
		g_port_f = (unsigned char)(g_port_f ^ 1);
	else if (key == KEY_LEFT || key == KEY_RIGHT) {
		if (g_port_f == 0) {
			if (key == KEY_RIGHT) {
				if (g_edit_type < 3)
					g_edit_type++;
			} else if (g_edit_type)
				g_edit_type--;
		} else
			g_edit_div = next_div(g_edit_div, (unsigned char)(key == KEY_RIGHT));
	} else if (key == KEY_ENTER) {
		comType = g_edit_type;
		divider = g_edit_div;
		apply_uart();
		if (!saveEspConfig())
			set_msg("espcom.ini write error");
		else
			sprintf((char *)g_msg, "Saved.  %s  %lu baud",
				com_name(comType), com_baud(divider));
		fetch_net();
		g_scr = SCR_HOME;
		draw_chrome();
		redraw();
		return;
	} else if (key == KEY_ESC) {
		set_msg("Cancelled.");
		g_scr = SCR_HOME;
		redraw();
		return;
	}
	draw_port_fields();
}

C_task main(void)
{
	unsigned int key;

	OS_HIDEFROMPARENT();
	OS_SETGFX(0x86);
	OS_CLS(0);

	espcom_silent = 1;
	g_msg[0] = 0;
	g_scr = SCR_HOME;
	g_port_f = 0;
	g_watch = 0;

	loadEspConfig();
	OS_GETUART(g_cfg);
	comType = g_cfg[0];
	divider = g_cfg[1];
	draw_chrome();
	set_msg("Query ESP...");
	draw_status();
	fetch_net();
	if (g_info_ok)
		set_msg("Ready.");
	redraw();

	for (;;) {
		YIELD();
		watch_net();
		key = _low_level_get();
		if (key == 0)
			continue;
		if (g_scr == SCR_PORT) {
			do_port_key(key);
			continue;
		}
		if (g_scr == SCR_SCAN) {
			if (key == KEY_ESC) {
				g_scr = SCR_HOME;
				set_msg("Ready.");
				redraw();
			} else if (key == KEY_UP)
				scan_move(0);
			else if (key == KEY_DOWN)
				scan_move(1); else if (key == KEY_ENTER)
				do_connect_sel();
			continue;
		}
		if (key == 'q' || key == 'Q' || key == KEY_ESC)
			break;
		if (key == 'r' || key == 'R')
			do_refresh();
		else if (key == 's' || key == 'S' || key == 'c' || key == 'C')
			do_scan();
		else if (key == 'd' || key == 'D')
			do_disc();
		else if (key == 'p' || key == 'P') {
			g_edit_type = comType;
			g_edit_div = divider;
			if (g_edit_div == 0)
				g_edit_div = 1;
			g_port_f = 0;
			g_scr = SCR_PORT;
			set_msg("Port setup");
			redraw();
		}
	}
	exit(0);
}
