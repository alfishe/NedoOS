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
static unsigned char oldcfg[20];
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

static unsigned char port_in3(unsigned char idx)
{
	unsigned char v;

	disable_interrupt();
	output(0xfb, idx);
	v = (unsigned char)input(0xfa);
	enable_interrupt();
	return v;
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
		input(0x03fe); /* DTR+RTS stay on: ESP GPIO15 CTS */
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

/*
 * Byte-level UART access for the AT/BIN switch. The kernel API only sends the
 * opcodes it knows, and ESPNET_CMD_ATMODE is not one of them, so the frame
 * goes out as raw bytes. Register sequences follow ../common/esp-com.c. On
 * Kondratyev (0) and ATM2IOESP (3) the ESP only answers while RTS strobes,
 * so a read polls LSR and pulses MCR, as the kernel esp_fill* loops do, and
 * a write waits CTS first, as the kernel esp_putb does.
 */
static void uart_wait_cts(void)
{
	unsigned int n;

	if ((unsigned char)comType == 1 || (unsigned char)comType == 2)
		return;
	for (n = 0; n < 20000; n++) {
		if ((unsigned char)comType == 3) {
			if (port_in3(reg8(MSR)) & 0x10)
				return;
		} else if (input(MSR) & 0x10)
			return;
	}
}

static void uart_put(unsigned char data)
{
	uart_wait_cts();
	switch ((unsigned char)comType) {
	case 1:
		disable_interrupt();
		do {
			input(0x55fe);
		} while ((input(0x42fe) & 32) == 0);
		input(0x55fe);
		input(0x03fe);
		input(((unsigned int)data << 8) | 0x00fe);
		enable_interrupt();
		break;
	case 3:
		while ((port_in3(reg8(LSR)) & 32) == 0) {
		}
		port_out3(reg8(RBR_THR), data);
		break;
	default:
		while ((input(LSR) & 32) == 0) {
		}
		output(RBR_THR, data);
		break;
	}
}

/* 1 = byte in *out, 0 = nothing waiting. Never blocks. */
static unsigned char uart_try(unsigned char *out)
{
	unsigned char v;
	unsigned char q;

	switch ((unsigned char)comType) {
	case 1:
		disable_interrupt();
		input(0x55fe);
		q = (unsigned char)input(0xc2fe);
		if (q == 0) {
			input(0x55fe);
			input(0x43fe);
			input(0x03fe);
			input(0x55fe);
			input(0x43fe);
			input(0x00fe);
			input(0x55fe);
			q = (unsigned char)input(0xc2fe);
		}
		if (q == 0) {
			enable_interrupt();
			return 0;
		}
		input(0x55fe);
		*out = (unsigned char)input(0x02fe);
		enable_interrupt();
		return 1;
	case 3:
		v = port_in3(reg8(LSR));
		if ((v & 1) == 0) {
			port_out3(reg8(MCR), 2);
			port_out3(reg8(MCR), 0);
			v = port_in3(reg8(LSR));
			if ((v & 1) == 0)
				return 0;
		}
		*out = port_in3(reg8(RBR_THR));
		return 1;
	default:
		v = (unsigned char)input(LSR);
		if ((v & 1) == 0 && (unsigned char)comType != 2) {
			output(MCR, 2);
			output(MCR, 0);
			v = (unsigned char)input(LSR);
			if ((v & 1) == 0)
				return 0;
		}
		if ((v & 1) == 0)
			return 0;
		*out = (unsigned char)input(RBR_THR);
		return 1;
	}
}

static void uart_drain(void)
{
	unsigned int guard;
	unsigned char v;

	guard = 0;
	while (uart_try(&v)) {
		if (++guard > 4096)
			break;
	}
}

/* Collect until `ticks` expire or the line goes quiet for 2 ticks (40 ms). */
static unsigned int uart_collect(unsigned char *buf, unsigned int max, long ticks)
{
	long start;
	long last;
	unsigned int n;
	unsigned char v;

	n = 0;
	start = time();
	last = start;
	while ((time() - start) < ticks) {
		if (!uart_try(&v)) {
			YIELD();
			if (n != 0 && (time() - last) >= 2)
				break;
			continue;
		}
		buf[n] = v;
		n++;
		last = time();
		if (n >= max)
			break;
	}
	return n;
}

#define MODE_OK 0
#define MODE_NO_REPLY 1
#define MODE_BAD_REPLY 2
#define MODE_STATUS 3

/* AT+LOG: ask the ESP for its recent log lines over the same UART. A board
 * with the module soldered on (ESP8266 ZX-WiFi) has no USB console, so this
 * is the only way to read what the firmware saw. */
static unsigned int esp_log_dump(void)
{
	static unsigned char buf[1024];
	static const char cmd[] = "AT+LOG\r\n";
	unsigned int i;
	unsigned int n;

	uart_drain();
	for (i = 0; i < 8; i++)
		uart_put((unsigned char)cmd[i]);
	n = uart_collect(buf, sizeof(buf) - 1, 100);
	for (i = 0; i < n; i++)
		putchar((char)buf[i]);
	return n;
}

/* Binary ATMODE frame: ESP acks it, then its host UART speaks AT. */
static unsigned char esp_enter_at(void)
{
	unsigned char req[7];
	unsigned char buf[16];
	unsigned int i;
	unsigned int n;

	uart_drain();
	req[0] = ESPNET_SOF;
	req[1] = ESPNET_CMD_ATMODE;
	req[2] = ESPNET_SOCK_NONE;
	req[3] = 0;	/* arg */
	req[4] = 1;	/* seq */
	req[5] = 0;	/* len lo */
	req[6] = 0;	/* len hi */
	for (i = 0; i < 7; i++)
		uart_put(req[i]);
	n = uart_collect(buf, sizeof(buf), 50);
	for (i = 0; i + 9 <= n; i++) {
		if (buf[i] != ESPNET_SOF || buf[i + 1] != ESPNET_CMD_ATMODE)
			continue;
		return buf[i + 3] ? MODE_STATUS : MODE_OK;
	}
	return n ? MODE_BAD_REPLY : MODE_NO_REPLY;
}

/* AT side: text is the only way back, the binary parser is off. */
static unsigned char esp_enter_bin(void)
{
	unsigned char buf[16];
	unsigned int i;
	unsigned int n;

	uart_drain();
	uart_put('A');
	uart_put('T');
	uart_put('+');
	uart_put('B');
	uart_put('I');
	uart_put('N');
	uart_put('\r');
	uart_put('\n');
	n = uart_collect(buf, sizeof(buf), 50);
	for (i = 0; i + 1 < n; i++)
		if (buf[i] == 'O' && buf[i + 1] == 'K')
			return MODE_OK;
	return n ? MODE_BAD_REPLY : MODE_NO_REPLY;
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
	unsigned char dns[4];

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
	putchar(' ');
	OS_GETDNS(dns);
	kv_begin("DNS");
	printf("%u.%u.%u.%u",
	       (unsigned int)dns[0], (unsigned int)dns[1],
	       (unsigned int)dns[2], (unsigned int)dns[3]);
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

static void print_mode(unsigned char at, unsigned char r)
{
	kv_s("mode", at ? "AT" : "BIN", r == MODE_OK ? SGR_OK : SGR_ERR);
	if (r != MODE_OK) {
		putchar(' ');
		kv_u("err", (unsigned int)r);
	}
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
	unsigned char a_set;
	unsigned char b_set;
	unsigned char l_set;
	unsigned char r;
	unsigned int logn;

	os_initstdio();

	silent = 0;
	m_set = 0;
	a_set = 0;
	b_set = 0;
	l_set = 0;
	for (i = 1; i < argc; i++) {
		s = argv[i];
		if (s == 0 || (s[0] != '-' && s[0] != '/'))
			continue;
		if (s[1] == 'S' || s[1] == 's')
			silent = 1;
		else if (s[1] == 'A' || s[1] == 'a')
			a_set = 1;
		else if (s[1] == 'B' || s[1] == 'b')
			b_set = 1;
		else if (s[1] == 'L' || s[1] == 'l')
			l_set = 1;
		else if (s[1] == 'H' || s[1] == 'h') {
			puts("Usage: espcfg.com [-S] [-M n] [-a|-b] [-l]");
			puts("Read /ini/espcom.ini, init 16550, write UART+pktMax to kernel.");
			puts("No args: print kernel UART, firmware version, WiFi/IP/SSID.");
			puts("-S  silent (autoexec)");
			puts("-M n  payload cap 64..2048 (overrides pktMax= in ini)");
			puts("-a  switch ESP to AT (text) mode: sends binary ATMODE 0x16");
			puts("    (the API stops answering there: at mode UART holds AT)");
			puts("-b  switch back to binary: sends AT+BIN, then prints status");
			puts("-l  dump the ESP log (AT+LOG) over the UART, no USB needed");
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

	if (a_set && b_set) {
		puts("espcfg: -a and -b are mutually exclusive");
		exit(1);
	}

	load_ini();
	if (m_set)
		pktMax = m_val;
	clamp_pktmax();

	pack_cfg();
	memset(oldcfg, 0, 20);
	OS_GETUART(oldcfg);
	if (memcmp(oldcfg, cfg, 20) != 0 || a_set || b_set) {
		uart_init((unsigned char)divider);
		settle();
		OS_SETUART(cfg);
		settle();
	} else if (l_set) {
		/* Only the UART registers are needed to talk AT: skip SETUART so
		 * the kernel does not push a binary frame into the AT parser. */
		uart_init((unsigned char)divider);
		settle();
	}

	if (a_set || b_set) {
		r = a_set ? esp_enter_at() : esp_enter_bin();
		uart_init((unsigned char)divider);
		settle();
		if (!silent)
			print_mode(a_set, r);
		if (a_set || r != MODE_OK)
			exit(r == MODE_OK ? 0 : 1);
		/* -b is back on the binary API: fall through to the usual status. */
	}

	if (l_set) {
		logn = esp_log_dump();
		if (logn == 0 && !silent)
			puts("no reply to AT+LOG (ESP is in binary mode?)");
		exit(logn ? 0 : 1);
	}

	if (!silent) {
		memset(cfg, 0, 20);
		OS_GETUART(cfg);
		print_cfg(cfg);
		i = (int)OS_GETINFO(info);
		if (i != 0) {
			sgr(SGR_ERR);
			printf("no reply GETINFO=%d\r\n", i);
			sgr(SGR_DIM);
		} else
			print_wifi(info);
	}
	exit(0);
}
