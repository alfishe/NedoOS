#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <intrz80.h>
#include <oscalls.h>
#include <osfs.h>
#include <tcp.h>
#include "../common/espnet/protocol.h"

#include "../common/ini.c"

static unsigned int RBR_THR = 0xF8EF;
static unsigned int IER = 0xF9EF;
static unsigned int IIR_FCR = 0xFAEF;
static unsigned int LCR = 0xFBEF;
static unsigned int MCR = 0xFCEF;
static unsigned int LSR = 0xFDEF;
static unsigned int MSR = 0xFEEF;
static unsigned int SR = 0xFFEF;
static unsigned int divider = 1;
static unsigned int comType = 0;
static unsigned int pktMax = 192;

static unsigned char cfg[20];
static unsigned char info[ESPNET_INFO_SIZE];
static unsigned char oldpath[256];
static unsigned char ini_val[32];
static unsigned char silent;
static unsigned char m_set;
static unsigned int m_val;

static void put_le16(unsigned char *p, unsigned int v)
{
	p[0] = (unsigned char)v;
	p[1] = (unsigned char)(v >> 8);
}

static unsigned int get_le16(unsigned char *p)
{
	return (unsigned int)p[0] | ((unsigned int)p[1] << 8);
}

static unsigned char ini_u16(unsigned char *key, unsigned int *dst)
{
	if (!ini_get_param((unsigned char *)"espcom.ini", key, ini_val, sizeof(ini_val)))
		return 0;
	*dst = ini_parse_uint(ini_val);
	return 1;
}

static void load_ini(void)
{
	FILE *fp;
	static unsigned int leg[12];

	OS_GETPATH(oldpath);
	OS_SETSYSDRV();
	OS_CHDIR((unsigned char *)"../ini");
	fp = OS_OPENHANDLE((unsigned char *)"espcom.ini", 0x80);
	if (((int)fp) & 0xff) {
		OS_CHDIR(oldpath);
		fp = OS_OPENHANDLE((unsigned char *)"espcom.ini", 0x80);
		if (((int)fp) & 0xff)
			return;
		OS_CLOSEHANDLE(fp);
	} else {
		OS_CLOSEHANDLE(fp);
	}

	if (ini_u16((unsigned char *)"RBR_THR", &RBR_THR)) {
		ini_u16((unsigned char *)"IER", &IER);
		ini_u16((unsigned char *)"IIR_FCR", &IIR_FCR);
		ini_u16((unsigned char *)"LCR", &LCR);
		ini_u16((unsigned char *)"MCR", &MCR);
		ini_u16((unsigned char *)"LSR", &LSR);
		ini_u16((unsigned char *)"MSR", &MSR);
		ini_u16((unsigned char *)"SR", &SR);
		ini_u16((unsigned char *)"divider", &divider);
		ini_u16((unsigned char *)"comType", &comType);
		ini_u16((unsigned char *)"pktMax", &pktMax);
	} else if (ini_legacy_u16s((unsigned char *)"espcom.ini", leg, 12)) {
		RBR_THR = leg[0];
		IER = leg[1];
		IIR_FCR = leg[2];
		LCR = leg[3];
		MCR = leg[4];
		LSR = leg[5];
		MSR = leg[6];
		SR = leg[7];
		divider = leg[8];
		comType = leg[9];
	}
	OS_CHDIR(oldpath);
}

static unsigned char reg8(unsigned int port)
{
	unsigned char hi;

	hi = (unsigned char)(port >> 8);
	if (hi >= 0xF8)
		return (unsigned char)(hi - 0xF8);
	return (unsigned char)port;
}

static void port_out3(unsigned char idx, unsigned char data)
{
	disable_interrupt();
	output(0xfb, idx);
	output(0xfa, data);
	enable_interrupt();
}

/* Same sequence as userland uart_init (type 3 uses 16550 index). */
static void uart_init(unsigned char div)
{
	switch ((unsigned char)comType) {
	case 1:
		disable_interrupt();
		input(0x55fe);
		input(0xc3fe);
		input(((unsigned int)div << 8) | 0x00fe);
		input(0x55fe);
		input(0x43fe);
		input(0x00fe);
		enable_interrupt();
		break;
	case 3:
		port_out3(reg8(IIR_FCR), 0x87);
		port_out3(reg8(LCR), 0x83);
		port_out3(reg8(RBR_THR), div);
		port_out3(reg8(IER), 0);
		port_out3(reg8(LCR), 3);
		port_out3(reg8(IER), 0);
		port_out3(reg8(MCR), 0x22);
		break;
	default:
		output(IIR_FCR, 0x87);
		output(LCR, 0x83);
		output(RBR_THR, div);
		output(IER, 0);
		output(LCR, 3);
		output(IER, 0);
		output(MCR, 0x2f);
		break;
	}
}

static void pack_cfg(void)
{
	cfg[0] = (unsigned char)comType;
	cfg[1] = (unsigned char)divider;
	put_le16(cfg + 2, RBR_THR);
	put_le16(cfg + 4, IER);
	put_le16(cfg + 6, IIR_FCR);
	put_le16(cfg + 8, LCR);
	put_le16(cfg + 10, MCR);
	put_le16(cfg + 12, LSR);
	put_le16(cfg + 14, MSR);
	put_le16(cfg + 16, SR);
	put_le16(cfg + 18, pktMax);
}

/* TTY SGR subset: ESC[nm. 30-37 ink, 40-47 paper, 90-97 bright ink. */
#define SGR_KEY 36
#define SGR_EQ  90
#define SGR_VAL 93
#define SGR_OK  92
#define SGR_ERR 91
#define SGR_DIM 37
#define SGR_PAPER 40

static void sgr(unsigned char n)
{
	putchar(27);
	putchar('[');
	putchar('0' + (char)(n / 10));
	putchar('0' + (char)(n % 10));
	putchar('m');
}

static void kv_begin(const char *key)
{
	sgr(SGR_KEY);
	printf("%s", key);
	sgr(SGR_EQ);
	putchar('=');
	sgr(SGR_VAL);
}

static void kv_u(const char *key, unsigned int v)
{
	kv_begin(key);
	printf("%u", v);
	sgr(SGR_DIM);
}

static void kv_x(const char *key, unsigned int v)
{
	kv_begin(key);
	printf("%04X", v);
	sgr(SGR_DIM);
}

static void kv_s(const char *key, const char *v, unsigned char valcol)
{
	sgr(SGR_KEY);
	printf("%s", key);
	sgr(SGR_EQ);
	putchar('=');
	sgr(valcol);
	printf("%s", v);
	sgr(SGR_DIM);
}

static void print_cfg(unsigned char *p)
{
	sgr(SGR_PAPER);
	kv_u("comType", p[0]);
	putchar(' ');
	kv_u("divider", p[1]);
	printf("\r\n");
	kv_x("RBR", get_le16(p + 2));
	putchar(' ');
	kv_x("IER", get_le16(p + 4));
	putchar(' ');
	kv_x("IIR", get_le16(p + 6));
	putchar(' ');
	kv_x("LCR", get_le16(p + 8));
	printf("\r\n");
	kv_x("MCR", get_le16(p + 10));
	putchar(' ');
	kv_x("LSR", get_le16(p + 12));
	putchar(' ');
	kv_x("MSR", get_le16(p + 14));
	putchar(' ');
	kv_x("SR", get_le16(p + 16));
	printf("\r\n");
	kv_u("pktMax", get_le16(p + 18));
	printf("\r\n");
}

static void clamp_pktmax(void)
{
	if (pktMax == 0)
		pktMax = 192;
	else if (pktMax < 64)
		pktMax = 64;
	else if (pktMax > 2048)
		pktMax = 2048;
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

static unsigned char wifi_valcol(unsigned char st)
{
	switch (st) {
	case ESPNET_WIFI_GOT_IP:
		return SGR_OK;
	case ESPNET_WIFI_CONNECTING:
		return SGR_VAL;
	case ESPNET_WIFI_AP:
		return SGR_KEY;
	default:
		return SGR_ERR;
	}
}

static void print_wifi(unsigned char *p)
{
	char *ssid;
	unsigned char st;

	kv_begin("fw");
	printf("%u.%u",
	       (unsigned int)p[ESPNET_INFO_VER_MAJOR],
	       (unsigned int)p[ESPNET_INFO_VER_MINOR]);
	sgr(SGR_DIM);
	printf("\r\n");
	st = p[ESPNET_INFO_WIFI];
	kv_s("WiFi", wifi_name(st), wifi_valcol(st));
	putchar(' ');
	kv_begin("rssi");
	printf("%d", (int)(signed char)p[ESPNET_INFO_RSSI]);
	sgr(SGR_DIM);
	printf("\r\n");
	kv_begin("IP");
	printf("%u.%u.%u.%u",
	       (unsigned int)p[ESPNET_INFO_IP],
	       (unsigned int)p[ESPNET_INFO_IP + 1],
	       (unsigned int)p[ESPNET_INFO_IP + 2],
	       (unsigned int)p[ESPNET_INFO_IP + 3]);
	sgr(SGR_DIM);
	printf("\r\n");
	ssid = (char *)(p + ESPNET_INFO_SSID);
	p[ESPNET_INFO_SSID + 32] = 0;
	if (ssid[0] == 0)
		kv_s("SSID", "(none)", SGR_EQ);
	else
		kv_s("SSID", ssid, SGR_OK);
	printf("\r\n");
	sgr(SGR_DIM);
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

C_task main(int argc, char *argv[])
{
	int i;
	char *s;

	os_initstdio();

	silent = 0;
	m_set = 0;
	for (i = 1; i < argc; i++) {
		s = argv[i];
		if (s == 0 || (s[0] != '-' && s[0] != '/'))
			continue;
		if (s[1] == 'S' || s[1] == 's')
			silent = 1;
		else if (s[1] == 'H' || s[1] == 'h') {
			puts("Usage: espcfg.com [-S] [-M n]");
			puts("Read /ini/espcom.ini, init 16550, write UART+pktMax to kernel.");
			puts("No args: print kernel UART, firmware version, WiFi/IP/SSID.");
			puts("-S  silent (autoexec)");
			puts("-M n  payload cap 64..2048 (overrides pktMax= in ini)");
			exit(0);
		} else if (s[1] == 'M' || s[1] == 'm') {
			m_set = 1;
			if (s[2] != 0)
				m_val = (unsigned int)atoi(s + 2);
			else if (i + 1 < argc) {
				i++;
				m_val = (unsigned int)atoi(argv[i]);
			} else
				m_val = 0;
		}
	}

	load_ini();
	if (m_set)
		pktMax = m_val;
	clamp_pktmax();

	uart_init((unsigned char)divider);
	settle();
	pack_cfg();
	OS_SETUART(cfg);
	settle();

	if (!silent) {
		memset(cfg, 0, 20);
		OS_GETUART(cfg);
		print_cfg(cfg);
		if (OS_GETINFO(info) != 0) {
			sgr(SGR_ERR);
			puts("no reply");
			sgr(SGR_DIM);
		} else
			print_wifi(info);
	}
	exit(0);
}
