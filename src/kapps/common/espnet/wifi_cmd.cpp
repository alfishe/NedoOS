#include <string.h>
#include "wifi_cmd.h"
#include "sockets.h"
#include "codec.h"
#include "host_uart.h"
#include "pins.h"
#include "stats.h"
#include "webui.h"

#if defined(ARDUINO_ARCH_ESP32)
#include <WiFi.h>
#else
#include <ESP8266WiFi.h>
#include <user_interface.h>
#endif

static char s_line[96];
static uint8_t s_linelen;
static uint8_t s_hold_disc;
static uint8_t s_pause_sta;

/* Last SCAN: ESP8266 joins much more reliably with channel+BSSID. */
static char s_scan_ssid[ESPNET_SCAN_MAX][ESPNET_SSID_SIZE];
static uint8_t s_scan_bssid[ESPNET_SCAN_MAX][6];
static uint8_t s_scan_ch[ESPNET_SCAN_MAX];
static int8_t s_scan_rssi[ESPNET_SCAN_MAX];
static uint8_t s_scan_n;

static int wifi_has_ip(void)
{
	IPAddress ip = WiFi.localIP();
	return (ip[0] | ip[1] | ip[2] | ip[3]) ? 1 : 0;
}

#if defined(ARDUINO_ARCH_ESP8266)
static void wifi_8266_radio(void)
{
	wifi_country_t c;

	/* US PHY is 1?11; RU/EU routers often sit on 12/13. ESP32 still sees them. */
	memset(&c, 0, sizeof(c));
	c.cc[0] = 'R';
	c.cc[1] = 'U';
	c.schan = 1;
	c.nchan = 13;
	c.policy = WIFI_COUNTRY_POLICY_MANUAL;
	wifi_set_country(&c);
	wifi_set_phy_mode(PHY_MODE_11N);
}
#endif

void wifi_cmd_begin(void)
{
	WiFi.persistent(true);
	WiFi.mode(WIFI_STA);
#if defined(ARDUINO_ARCH_ESP32)
	WiFi.setHostname(ESPNET_OTA_HOSTNAME);
	WiFi.setSleep(WIFI_PS_NONE);
	WiFi.setAutoReconnect(true);
#else
	WiFi.hostname(ESPNET_OTA_HOSTNAME);
	WiFi.setSleepMode(WIFI_NONE_SLEEP);
	WiFi.setAutoReconnect(true);
	WiFi.setAutoConnect(true);
	wifi_8266_radio();
#endif
	s_hold_disc = 0;
	s_pause_sta = 0;
	s_scan_n = 0;
	WiFi.begin();
	slog("wifi STA begin ssid='%s'", WiFi.SSID().c_str());
}

void wifi_poll(void)
{
	static uint8_t last_st = 0xFF;
	wl_status_t st;
	uint8_t code;

	if (s_hold_disc || s_pause_sta)
		return;
	st = WiFi.status();
	code = wifi_status_code();
	if (code != last_st) {
		uint8_t ip[4];
		wifi_fill_ip(ip);
		slog("link %s wifi=%d rssi=%d ip=%u.%u.%u.%u",
		     (code == ESPNET_WIFI_GOT_IP) ? "GOT_IP" :
		     (code == ESPNET_WIFI_CONNECTING) ? "connecting" : "idle",
		     (int)st, (int)wifi_rssi_val(),
		     (unsigned)ip[0], (unsigned)ip[1], (unsigned)ip[2], (unsigned)ip[3]);
		last_st = code;
	}
	/* Do not call WiFi.reconnect() here. SDK setAutoReconnect(true) in
	 * wifi_cmd_begin() is enough. Manual reconnect() drops every TCP socket
	 * (OTA on 8266, gopher) and fights the SDK every 8 s. */
}

uint8_t wifi_status_code(void)
{
	wl_status_t st = WiFi.status();
	if (st == WL_CONNECTED && wifi_has_ip())
		return ESPNET_WIFI_GOT_IP;
	if (st == WL_CONNECTED)
		return ESPNET_WIFI_CONNECTING;
	if (st == WL_IDLE_STATUS)
		return ESPNET_WIFI_IDLE;
	if (st == WL_DISCONNECTED || st == WL_CONNECTION_LOST || st == WL_NO_SSID_AVAIL)
		return ESPNET_WIFI_IDLE;
	return ESPNET_WIFI_CONNECTING;
}

int8_t wifi_rssi_val(void)
{
	if (WiFi.status() != WL_CONNECTED)
		return 0;
	return (int8_t)WiFi.RSSI();
}

void wifi_fill_ip(uint8_t *dst)
{
	IPAddress ip = WiFi.localIP();
	dst[0] = ip[0];
	dst[1] = ip[1];
	dst[2] = ip[2];
	dst[3] = ip[3];
}

void wifi_fill_mac(uint8_t *dst)
{
	WiFi.macAddress(dst);
}

void wifi_fill_ssid(uint8_t *dst)
{
	String ss = WiFi.SSID();
	memset(dst, 0, ESPNET_SSID_SIZE);
	ss.toCharArray((char *)dst, ESPNET_SSID_SIZE);
}

static uint16_t rsp_hdr(uint8_t *rsp, uint8_t cmd, uint8_t sock, uint8_t status,
			uint8_t seq, uint16_t result, uint16_t plen)
{
	rsp[ESPNET_RSP_CMD] = cmd;
	rsp[ESPNET_RSP_SOCK] = sock;
	rsp[ESPNET_RSP_STATUS] = status;
	rsp[ESPNET_RSP_SEQ] = seq;
	espnet_put_u16(rsp + ESPNET_RSP_RESULT, result);
	espnet_put_u16(rsp + ESPNET_RSP_LEN, plen);
	return (uint16_t)(ESPNET_RSP_HDR + plen);
}

static uint16_t rsp_err(uint8_t *rsp, uint8_t cmd, uint8_t seq, uint8_t err)
{
	return rsp_hdr(rsp, cmd, ESPNET_SOCK_NONE, err, seq, 0, 0);
}

static uint16_t do_info(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t *p = rsp + ESPNET_RSP_HDR;
	uint32_t heap;
	memset(p, 0, ESPNET_INFO_SIZE);
	p[ESPNET_INFO_VER_MAJOR] = ESPNET_VER_MAJOR;
	p[ESPNET_INFO_VER_MINOR] = ESPNET_VER_MINOR;
	p[ESPNET_INFO_CHIP] = ESPNET_CHIP_ID;
	p[ESPNET_INFO_MAX_SOCKS] = sockets_max();
	p[ESPNET_INFO_WIFI] = wifi_status_code();
	p[ESPNET_INFO_RSSI] = (uint8_t)wifi_rssi_val();
	p[ESPNET_INFO_SOCKMASK] = sockets_mask();
	p[ESPNET_INFO_RESERVED] = ESPNET_CAP_CRC;
	wifi_fill_ip(p + ESPNET_INFO_IP);
	wifi_fill_mac(p + ESPNET_INFO_MAC);
	wifi_fill_ssid(p + ESPNET_INFO_SSID);
	heap = ESP.getFreeHeap();
	if (heap > 65535u)
		heap = 65535u;
	espnet_put_u16(p + ESPNET_INFO_HEAP, (uint16_t)heap);
	return rsp_hdr(rsp, ESPNET_CMD_INFO, ESPNET_SOCK_NONE, 0, seq, 0, ESPNET_INFO_SIZE);
}

static uint16_t do_scan(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	int n;
	int i;
	uint8_t *rec;

	/*
	 * After flash the chip keeps reconnecting to the last AP. If that AP
	 * is gone (phone hotspot off), scanNetworks returns 0 until STA is idle.
	 */
	WiFi.setAutoReconnect(false);
	WiFi.scanDelete();
	WiFi.disconnect(false);
#if defined(ARDUINO_ARCH_ESP8266)
	delay(500);
	wifi_8266_radio();
	WiFi.mode(WIFI_OFF);
	delay(100);
	WiFi.mode(WIFI_STA);
	delay(200);
	n = WiFi.scanNetworks(false, true, 0);
#else
	delay(200);
	n = WiFi.scanNetworks(false, true);
#endif
	if (n < 0) {
		delay(300);
#if defined(ARDUINO_ARCH_ESP8266)
		n = WiFi.scanNetworks(false, true, 0);
#else
		n = WiFi.scanNetworks(false, true);
#endif
	}
	if (n < 0)
		n = 0;
	if (n > ESPNET_SCAN_MAX)
		n = ESPNET_SCAN_MAX;
	s_scan_n = (uint8_t)n;
	for (i = 0; i < n; i++) {
		rec = rsp + ESPNET_RSP_HDR + i * ESPNET_SCAN_REC;
		memset(rec, 0, ESPNET_SCAN_REC);
		strncpy((char *)(rec + ESPNET_SCAN_SSID), WiFi.SSID(i).c_str(), ESPNET_SSID_SIZE - 1);
		rec[ESPNET_SCAN_RSSI] = (uint8_t)WiFi.RSSI(i);
		rec[ESPNET_SCAN_ENC] = (uint8_t)WiFi.encryptionType(i);
		{
			uint8_t *bssid = WiFi.BSSID(i);
			if (bssid)
				memcpy(rec + ESPNET_SCAN_BSSID, bssid, 6);
		}
		rec[ESPNET_SCAN_CH] = (uint8_t)WiFi.channel(i);
		memset(s_scan_ssid[i], 0, ESPNET_SSID_SIZE);
		strncpy(s_scan_ssid[i], WiFi.SSID(i).c_str(), ESPNET_SSID_SIZE - 1);
		if (WiFi.BSSID(i))
			memcpy(s_scan_bssid[i], WiFi.BSSID(i), 6);
		else
			memset(s_scan_bssid[i], 0, 6);
		s_scan_ch[i] = (uint8_t)WiFi.channel(i);
		s_scan_rssi[i] = (int8_t)WiFi.RSSI(i);
	}
	WiFi.scanDelete();
	/* Scan had to drop STA. Bring the saved AP back in the background
	 * and answer now ? do not leave autoReconnect off until power-on. */
	s_pause_sta = 0;
	if (!s_hold_disc) {
		WiFi.setAutoReconnect(true);
		WiFi.mode(WIFI_STA);
		WiFi.begin();
	}
	slog("SCAN n=%d", n);
	return rsp_hdr(rsp, ESPNET_CMD_WIFI_SCAN, ESPNET_SOCK_NONE, 0, seq, (uint16_t)n,
		       (uint16_t)(n * ESPNET_SCAN_REC));
}

static uint16_t do_wconnect(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	char ssid[ESPNET_SSID_SIZE];
	char pass[ESPNET_PASS_SIZE];
	const char *psk;
	unsigned passlen;

	if (plen < ESPNET_WIFI_CONN_SIZE || req_n < ESPNET_REQ_HDR + ESPNET_WIFI_CONN_SIZE)
		return rsp_err(rsp, ESPNET_CMD_WIFI_CONNECT, seq, ESPNET_ERR_EMSGSIZE);
	memset(ssid, 0, sizeof(ssid));
	memset(pass, 0, sizeof(pass));
	memcpy(ssid, req + ESPNET_REQ_HDR, ESPNET_SSID_SIZE - 1);
	memcpy(pass, req + ESPNET_REQ_HDR + ESPNET_SSID_SIZE, ESPNET_PASS_SIZE - 1);
	passlen = 0;
	while (pass[passlen] && passlen < ESPNET_PASS_SIZE - 1)
		passlen++;
	WiFi.persistent(true);
	WiFi.setAutoReconnect(true);
	s_hold_disc = 0;
	s_pause_sta = 0;
	psk = passlen ? pass : 0;
	/* No channel/BSSID lock: a stale scan lock failed here while
	 * WiFi.begin() on boot (NVS, no BSSID) joined the same AP.
	 * No join wait: the UART reply must leave before DHCP. */
#if defined(ARDUINO_ARCH_ESP8266)
	wifi_8266_radio();
	WiFi.mode(WIFI_STA);
#else
	WiFi.mode(WIFI_STA);
	WiFi.disconnect(false);
	WiFi.config(INADDR_NONE, INADDR_NONE, INADDR_NONE, INADDR_NONE);
#endif
	WiFi.begin(ssid, psk);
	slog("WCON start ssid='%s' passlen=%u", ssid, passlen);
	return rsp_hdr(rsp, ESPNET_CMD_WIFI_CONNECT, ESPNET_SOCK_NONE, 0, seq, 0, 0);
}

static uint16_t do_wdisc(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	s_hold_disc = 1;
	WiFi.setAutoReconnect(false);
	sockets_on_link_lost();
	WiFi.disconnect(false);
	slog("WDIS");
	return rsp_hdr(rsp, ESPNET_CMD_WIFI_DISC, ESPNET_SOCK_NONE, 0, seq, 0, 0);
}

static uint16_t do_wstatus(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t *p = rsp + ESPNET_RSP_HDR;
	uint8_t flags = 0;
	memset(p, 0, ESPNET_WIFI_STATUS_SIZE);
	wifi_fill_ip(p + ESPNET_WSTAT_IP);
	wifi_fill_mac(p + ESPNET_WSTAT_MAC);
	wifi_fill_ssid(p + ESPNET_WSTAT_SSID);
	p[ESPNET_WSTAT_RSSI] = (uint8_t)wifi_rssi_val();
	if (WiFi.status() == WL_CONNECTED && wifi_has_ip())
		flags |= ESPNET_WSTAT_F_CONNECTED;
	if (wifi_has_ip())
		flags |= ESPNET_WSTAT_F_HASIP;
	p[ESPNET_WSTAT_FLAGS] = flags;
	return rsp_hdr(rsp, ESPNET_CMD_WIFI_STATUS, ESPNET_SOCK_NONE, 0, seq, 0, ESPNET_WIFI_STATUS_SIZE);
}

static uint16_t do_uart(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t arg = req[ESPNET_REQ_ARG];
	uint8_t *p = rsp + ESPNET_RSP_HDR;
	uint32_t baud;
	uint8_t persist;

	memset(p, 0, ESPNET_UART_SIZE);
	if (arg == ESPNET_UART_ARG_GET) {
		espnet_put_u32(p + ESPNET_UART_BAUD, host_uart_baud());
		if (host_uart_saved_eq())
			p[ESPNET_UART_FLAGS] = ESPNET_UART_F_PERSIST;
		return rsp_hdr(rsp, ESPNET_CMD_UART, ESPNET_SOCK_NONE, 0, seq, 0, ESPNET_UART_SIZE);
	}
	if (arg != ESPNET_UART_ARG_SET ||
	    req_n < (uint16_t)(ESPNET_REQ_HDR + ESPNET_UART_SIZE))
		return rsp_err(rsp, ESPNET_CMD_UART, seq, ESPNET_ERR_EMSGSIZE);
	baud = espnet_get_u32(req + ESPNET_REQ_HDR + ESPNET_UART_BAUD);
	persist = (uint8_t)(req[ESPNET_REQ_HDR + ESPNET_UART_FLAGS] & ESPNET_UART_F_PERSIST);
	if (!host_uart_request_baud(baud, persist))
		return rsp_err(rsp, ESPNET_CMD_UART, seq, ESPNET_ERR_EMSGSIZE);
	slog("UART set %lu persist=%u", (unsigned long)baud, (unsigned)persist);
	espnet_put_u32(p + ESPNET_UART_BAUD, baud);
	p[ESPNET_UART_FLAGS] = persist;
	return rsp_hdr(rsp, ESPNET_CMD_UART, ESPNET_SOCK_NONE, 0, seq, 0, ESPNET_UART_SIZE);
}

uint8_t wifi_handle(const uint8_t *req, uint16_t req_n, uint8_t *rsp, uint16_t *rsp_n)
{
	uint8_t cmd = (uint8_t)(req[ESPNET_REQ_CMD] & ESPNET_CMD_MASK);
	switch (cmd) {
	case ESPNET_CMD_INFO:
		*rsp_n = do_info(req, rsp);
		return 1;
	case ESPNET_CMD_WIFI_SCAN:
		*rsp_n = do_scan(req, rsp);
		return 1;
	case ESPNET_CMD_WIFI_CONNECT:
		*rsp_n = do_wconnect(req, req_n, rsp);
		return 1;
	case ESPNET_CMD_WIFI_DISC:
		*rsp_n = do_wdisc(req, rsp);
		return 1;
	case ESPNET_CMD_WIFI_STATUS:
		*rsp_n = do_wstatus(req, rsp);
		return 1;
	case ESPNET_CMD_UART:
		*rsp_n = do_uart(req, req_n, rsp);
		return 1;
	default:
		return 0;
	}
}

void usb_print_gmr(void)
{
	Stream &s = host_debug();
	s.print(F("ESPNET "));
	s.print(ESPNET_VER_MAJOR);
	s.print('.');
	s.println(ESPNET_VER_MINOR);
	s.print(F("host uart: "));
	s.println(host_uart_baud());
#if defined(CONFIG_IDF_TARGET_ESP32C3)
	s.println(F("chip: ESP32-C3"));
#elif defined(ARDUINO_ARCH_ESP32)
	s.println(F("chip: ESP32"));
#else
	s.println(F("chip: ESP8266"));
#endif
	s.print(F("uart: "));
	s.println(F(ESPNET_UART_LAYOUT_STR));
	s.print(F("ota: "));
	s.println(F(ESPNET_OTA_HOSTNAME));
	s.print(F("max_socks: "));
	s.println(sockets_max());
	s.print(F("heap: "));
	s.println(ESP.getFreeHeap());
	s.print(F("sdk: "));
	s.println(ESP.getSdkVersion());
}

void usb_print_status(void)
{
	Stream &s = host_debug();
	uint8_t ip[4];
	uint8_t mac[6];
	uint8_t ssid[ESPNET_SSID_SIZE];
	wifi_fill_ip(ip);
	wifi_fill_mac(mac);
	wifi_fill_ssid(ssid);
	s.print(F("wifi: "));
	s.println(wifi_status_code());
	s.print(F("ssid: "));
	s.println((char *)ssid);
	s.print(F("ip: "));
	s.print(ip[0]);
	s.print('.');
	s.print(ip[1]);
	s.print('.');
	s.print(ip[2]);
	s.print('.');
	s.println(ip[3]);
	s.print(F("mac: "));
	{
		uint8_t i;
		for (i = 0; i < 6; i++) {
			if (mac[i] < 16)
				s.print('0');
			s.print(mac[i], HEX);
			if (i < 5)
				s.print(':');
		}
	}
	s.println();
	s.print(F("rssi: "));
	s.println(wifi_rssi_val());
	sockets_debug(s);
}

static int at_eq(const char *a, const char *b)
{
	while (*a && *b) {
		char ca = *a++;
		char cb = *b++;
		if (ca >= 'a' && ca <= 'z')
			ca = (char)(ca - 32);
		if (cb >= 'a' && cb <= 'z')
			cb = (char)(cb - 32);
		if (ca != cb)
			return 0;
	}
	return *a == *b;
}

static int at_starts(const char *line, const char *pre)
{
	while (*pre) {
		char ca = *line++;
		char cb = *pre++;
		if (ca >= 'a' && ca <= 'z')
			ca = (char)(ca - 32);
		if (cb >= 'a' && cb <= 'z')
			cb = (char)(cb - 32);
		if (ca != cb)
			return 0;
	}
	return 1;
}

static void usb_handle_line(char *line)
{
	if (!line[0])
		return;
	if (at_eq(line, "AT+GMR") || at_eq(line, "GMR"))
		usb_print_gmr();
	else if (at_eq(line, "AT+STATUS") || at_eq(line, "STATUS"))
		usb_print_status();
	else if (at_eq(line, "AT+SOCKS") || at_eq(line, "SOCKS"))
		sockets_debug(host_debug());
	else if (at_starts(line, "AT+UART")) {
		const char *p = line + 7;
		if (*p == '=' ) {
			uint32_t baud = 0;
			p++;
			while (*p >= '0' && *p <= '9')
				baud = baud * 10u + (uint32_t)(*p++ - '0');
			if (host_uart_set_baud_now(baud, 1)) {
				host_debug().print(F("OK "));
				host_debug().println(host_uart_baud());
			} else
				host_debug().println(F("ERROR"));
		} else {
			host_debug().print(F("+UART:"));
			host_debug().println(host_uart_baud());
		}
	} else if (at_eq(line, "AT+WEB") || at_eq(line, "WEB")) {
		webui_http_enable();
		host_debug().println(F("OK"));
	} else if (at_eq(line, "AT+HELP") || at_eq(line, "HELP")) {
		host_debug().println(F("AT+GMR AT+STATUS AT+SOCKS AT+UART AT+UART=115200 AT+WEB AT+HELP"));
		host_debug().println(F("OTA espnet.local pass espnet  http off until AT+WEB"));
	} else {
		host_debug().println(F("ERROR"));
	}
}

void usb_debug_poll(void)
{
	Stream &s = host_debug();
	while (s.available()) {
		char c = (char)s.read();
		if (c == '\r' || c == '\n') {
			s_line[s_linelen] = 0;
			if (s_linelen)
				usb_handle_line(s_line);
			s_linelen = 0;
		} else if (s_linelen < sizeof(s_line) - 1) {
			s_line[s_linelen++] = c;
		}
	}
}
