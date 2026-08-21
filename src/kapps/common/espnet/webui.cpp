/*
 * Low-priority HTTP status + ArduinoOTA.
 *
 * HTTP/OTA run only when the ZX UART has been quiet. During OTA the main
 * loop yields the chip (no UART, no gopher). Do not meta-refresh: one
 * extra TCP pcb on ESP8266 stalls Spectrum transfers.
 */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "webui.h"
#include "pins.h"
#include "stats.h"
#include "sockets.h"
#include "wifi_cmd.h"
#include "host_uart.h"
#include "codec.h"

#if defined(ARDUINO_ARCH_ESP32)
#include <WiFi.h>
#include <WiFiUdp.h>
#include <WebServer.h>
#include <ESPmDNS.h>
#include <ArduinoOTA.h>
#include <Update.h>
static WebServer s_http(80);
#else
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ESP8266mDNS.h>
#include <ArduinoOTA.h>
#include <Updater.h>
static ESP8266WebServer s_http(80);
#endif

static uint8_t s_up;
static uint8_t s_ota;
static uint8_t s_http_live;
static uint32_t s_sid;
static uint32_t s_last_http_ms;
static uint32_t s_last_mdns_ms;

static const char LOGIN_HTML[] PROGMEM =
	"<!doctype html><html><head><meta charset=utf-8><title>ESPNET login</title>"
	"<style>body{font:16px sans-serif;max-width:22em;margin:3em auto;background:#111;color:#ddd}"
	"input{width:100%;padding:.4em;margin:.3em 0;box-sizing:border-box}"
	"button{padding:.5em 1em}</style></head><body>"
	"<h2>ESPNET</h2><form method=post action=/login>"
	"<input name=u placeholder=user autofocus>"
	"<input name=p type=password placeholder=password>"
	"<button>Log in</button></form>"
	"<p style=color:#888>Default espnet / espnet</p></body></html>";

static const char ROOT_HTML[] PROGMEM =
	"<!doctype html><html><head><meta charset=utf-8><title>ESPNET</title>"
	"<style>body{font:14px/1.35 sans-serif;background:#111;color:#ddd;margin:1em}"
	"pre{background:#000;padding:.6em;white-space:pre-wrap}"
	"a{color:#8cf}</style></head><body>"
	"<h2>ESPNET</h2>"
	"<p><a href=/log>log</a> &nbsp; "
	"<form style=display:inline method=post action=/clear>"
	"<button>clear log</button></form></p>"
	"<pre id=s>idle poll, wait...</pre>"
	"<script>"
	"(function(){"
	"function t(){"
	"fetch('/stat',{cache:'no-store'}).then(function(r){if(!r.ok)throw 1;return r.text()})"
	".then(function(x){document.getElementById('s').textContent=x;setTimeout(t,3000)})"
	".catch(function(){document.getElementById('s').textContent+='\\n[poll paused ? ZX busy or WiFi]';"
	"setTimeout(t,8000)});"
	"}"
	"t();"
	"})();"
	"</script></body></html>";

int webui_ota_active(void)
{
	if (s_ota)
		return 1;
#if defined(ARDUINO_ARCH_ESP8266) || defined(ARDUINO_ARCH_ESP32)
	if (Update.isRunning())
		return 1;
#endif
	return 0;
}

static uint32_t new_sid(void)
{
	uint32_t v;
#if defined(ARDUINO_ARCH_ESP32)
	v = esp_random();
#else
	v = millis() ^ (uint32_t)ESP.getChipId() ^ (uint32_t)ESP.getCycleCount();
#endif
	if (v == 0)
		v = 1;
	return v;
}

static void hdr_close(void)
{
	s_http.sendHeader("Connection", "close");
	s_http.sendHeader("Cache-Control", "no-store");
}

static int cookie_sid_ok(void)
{
	String c = s_http.header("Cookie");
	int i;
	unsigned long got;

	if (s_sid == 0)
		return 0;
	i = c.indexOf("sid=");
	if (i < 0)
		return 0;
	got = strtoul(c.c_str() + i + 4, 0, 10);
	return (uint32_t)got == s_sid;
}

static void send_login(int code)
{
	hdr_close();
	s_http.send_P(code, "text/html", LOGIN_HTML);
}

static void handle_login(void)
{
	if (s_http.method() == HTTP_POST) {
		if (s_http.arg("u") == ESPNET_WEB_USER &&
		    s_http.arg("p") == ESPNET_WEB_PASS) {
			char setc[48];
			s_sid = new_sid();
			snprintf(setc, sizeof(setc), "sid=%lu; Path=/", (unsigned long)s_sid);
			s_http.sendHeader("Set-Cookie", setc);
			hdr_close();
			s_http.sendHeader("Location", "/");
			s_http.send(302, "text/plain", "ok");
			slog("web login ok");
			return;
		}
		slog("web login fail");
	}
	send_login(200);
}

static int need_auth(void)
{
	if (cookie_sid_ok())
		return 0;
	send_login(401);
	return 1;
}

static const char *wifi_name(uint8_t st)
{
	switch (st) {
	case ESPNET_WIFI_GOT_IP: return "GOT_IP";
	case ESPNET_WIFI_CONNECTING: return "connecting";
	case ESPNET_WIFI_AP: return "AP";
	default: return "idle";
	}
}

static const char *sock_st_name(uint8_t st)
{
	switch (st) {
	case 1: return "idle";
	case 2: return "tcp";
	case 3: return "udp";
	case 4: return "listen";
	default: return "free";
	}
}

static int fill_stat(char *dst, int cap)
{
	const EspnetStats *st;
	SockView sv[ESPNET_MAX_SOCKS];
	uint8_t ns = 0;
	uint8_t i;
	uint8_t ip[4];
	uint8_t ssid[ESPNET_SSID_SIZE];
	uint32_t now;
	int n;
	unsigned k;
	unsigned lc;
	unsigned start;

	st = stats_get();
	now = millis();
	sockets_view(sv, &ns);
	wifi_fill_ip(ip);
	wifi_fill_ssid(ssid);
	n = snprintf(dst, (size_t)cap,
		"ESPNET %u.%u  up %lus  heap %u  ota %u\n"
		"busy %u  in_frame %u\n"
		"WiFi %s rssi %d  %s  %u.%u.%u.%u\n"
		"UART %s %lu baud  ZX rx %lu tx %lu  last %lums\n"
		"WiFi rx %lu tx %lu  last rx %lums tx %lums\n"
		"cmds %lu ok %lu err %lu eagain %lu resync %lu cts_wait %lu\n"
		"last %s sock %u seq %u %s n=%u plen=%u  %lums ago\n"
		"OTA: %s.local  pass %s  (close this page while flashing)\n\n"
		"sockets\n",
		(unsigned)ESPNET_VER_MAJOR, (unsigned)ESPNET_VER_MINOR,
		(unsigned long)(now / 1000u),
		(unsigned)ESP.getFreeHeap(),
		(unsigned)s_ota,
		(unsigned)st->busy,
		(unsigned)espnet_rx_in_frame(),
		wifi_name(wifi_status_code()),
		(int)wifi_rssi_val(),
		(char *)ssid,
		(unsigned)ip[0], (unsigned)ip[1], (unsigned)ip[2], (unsigned)ip[3],
		ESPNET_UART_LAYOUT_STR,
		(unsigned long)host_uart_baud(),
		(unsigned long)st->uart_rx, (unsigned long)st->uart_tx,
		(unsigned long)(st->last_uart_ms ? (now - st->last_uart_ms) : 0),
		(unsigned long)st->wifi_rx, (unsigned long)st->wifi_tx,
		st->last_wifi_rx_ms ? (unsigned long)(now - st->last_wifi_rx_ms) : 0UL,
		st->last_wifi_tx_ms ? (unsigned long)(now - st->last_wifi_tx_ms) : 0UL,
		(unsigned long)st->cmds, (unsigned long)st->cmds_ok,
		(unsigned long)st->cmds_err, (unsigned long)st->cmds_eagain,
		(unsigned long)st->uart_resync, (unsigned long)st->tx_wait,
		stats_cmd_name(st->last_cmd),
		(unsigned)st->last_sock, (unsigned)st->last_seq,
		stats_err_name(st->last_status),
		(unsigned)st->last_result, (unsigned)st->last_plen,
		st->last_cmd_ms ? (unsigned long)(now - st->last_cmd_ms) : 0UL,
		ESPNET_OTA_HOSTNAME, ESPNET_WEB_PASS);
	if (n < 0)
		n = 0;
	if (n >= cap)
		n = cap - 1;
	for (i = 0; i < ns && n < cap - 48; i++) {
		int w = snprintf(dst + n, (size_t)(cap - n),
				 " %u %s proto=%u conn=%u av=%u rx=%u\n",
				 (unsigned)i, sock_st_name(sv[i].state),
				 (unsigned)sv[i].proto, (unsigned)sv[i].conn,
				 (unsigned)sv[i].avail, (unsigned)sv[i].rx_len);
		if (w > 0)
			n += w;
	}
	if (n < cap - 8)
		n += snprintf(dst + n, (size_t)(cap - n), "\nlog (newest)\n");
	lc = stats_log_count();
	start = 0;
	if (lc > 12)
		start = lc - 12;
	for (k = start; k < lc && n < cap - 8; k++) {
		int w = snprintf(dst + n, (size_t)(cap - n), "%s\n", stats_log_line(k));
		if (w > 0)
			n += w;
	}
	if (n >= cap)
		n = cap - 1;
	dst[n] = 0;
	return n;
}

static void handle_root(void)
{
	if (need_auth())
		return;
	hdr_close();
	s_http.send_P(200, "text/html", ROOT_HTML);
}

static void handle_stat(void)
{
	static char buf[1400];

	if (need_auth())
		return;
	fill_stat(buf, (int)sizeof(buf));
	hdr_close();
	s_http.send(200, "text/plain; charset=utf-8", buf);
}

static void handle_log(void)
{
	static char buf[1600];
	unsigned i;
	unsigned nlog;
	unsigned start;
	int n;

	if (need_auth())
		return;
	nlog = stats_log_count();
	start = 0;
	if (nlog > 20)
		start = nlog - 20;
	n = 0;
	buf[0] = 0;
	for (i = start; i < nlog && n < (int)sizeof(buf) - 8; i++) {
		int w = snprintf(buf + n, sizeof(buf) - (size_t)n, "%s\n",
				 stats_log_line(i));
		if (w > 0)
			n += w;
	}
	hdr_close();
	s_http.send(200, "text/plain; charset=utf-8", buf);
}

static void handle_clear(void)
{
	if (need_auth())
		return;
	slog_clear();
	slog("log cleared");
	hdr_close();
	s_http.sendHeader("Location", "/");
	s_http.send(302, "text/plain", "ok");
}

static void handle_favicon(void)
{
	hdr_close();
	s_http.send(204, "text/plain", "");
}

static void handle_404(void)
{
	hdr_close();
	s_http.send(404, "text/plain", "no");
}

static void ota_begin(void)
{
	s_ota = 1;
	sockets_close_all();
	if (s_http_live)
		s_http.stop();
#if defined(ARDUINO_ARCH_ESP32)
	WiFi.setAutoReconnect(false);
#else
	WiFi.setAutoReconnect(false);
#endif
	slog("OTA start - http/sockets off");
}

static void ota_end(void)
{
	s_ota = 0;
#if defined(ARDUINO_ARCH_ESP32)
	WiFi.setAutoReconnect(true);
#else
	WiFi.setAutoReconnect(true);
#endif
	if (s_up && s_http_live)
		s_http.begin();
	slog("OTA done");
}

static void start_services(void)
{
	ArduinoOTA.setHostname(ESPNET_OTA_HOSTNAME);
	ArduinoOTA.setPassword(ESPNET_WEB_PASS);
	ArduinoOTA.onStart([]() { ota_begin(); });
	ArduinoOTA.onEnd([]() { ota_end(); });
	ArduinoOTA.onError([](ota_error_t e) {
		s_ota = 0;
#if defined(ARDUINO_ARCH_ESP32)
		WiFi.setAutoReconnect(true);
#else
		WiFi.setAutoReconnect(true);
#endif
		if (s_up && s_http_live)
			s_http.begin();
		slog("OTA err %u", (unsigned)e);
	});
	ArduinoOTA.begin();
	MDNS.begin(ESPNET_OTA_HOSTNAME);
	slog("OTA on (http off, USB AT+WEB to enable)");
}

static void start_http(void)
{
#if defined(ARDUINO_ARCH_ESP32)
	const char *hdrs[] = { "Cookie" };

	s_http.collectHeaders(hdrs, 1);
#else
	s_http.collectHeaders("Cookie");
#endif
	s_http.on("/", HTTP_GET, handle_root);
	s_http.on("/stat", HTTP_GET, handle_stat);
	s_http.on("/login", HTTP_GET, handle_login);
	s_http.on("/login", HTTP_POST, handle_login);
	s_http.on("/log", HTTP_GET, handle_log);
	s_http.on("/clear", HTTP_POST, handle_clear);
	s_http.on("/favicon.ico", HTTP_GET, handle_favicon);
	s_http.onNotFound(handle_404);
	s_http.begin();
	s_http_live = 1;
	slog("web http://%s.local/", ESPNET_OTA_HOSTNAME);
}

void webui_http_enable(void)
{
	if (!s_up || s_http_live)
		return;
	start_http();
}

void webui_begin_log(void)
{
	stats_begin();
	slog("boot ESPNET %u.%u heap %u",
	     (unsigned)ESPNET_VER_MAJOR, (unsigned)ESPNET_VER_MINOR,
	     (unsigned)ESP.getFreeHeap());
}

static int wifi_ready(void)
{
	IPAddress ip = WiFi.localIP();
	return (WiFi.status() == WL_CONNECTED && (ip[0] | ip[1] | ip[2] | ip[3])) ? 1 : 0;
}

void webui_poll(void)
{
	const EspnetStats *st;
	uint32_t now;

	if (!s_up) {
		if (!wifi_ready())
			return;
		start_services();
		s_up = 1;
	}
	now = millis();
	if (webui_ota_active()) {
		if (!s_ota && Update.isRunning())
			ota_begin();
		ArduinoOTA.handle();
		return;
	}
	/* During ZX UART traffic skip OTA UDP ? it ran every loop() before
	 * sockets_pump / UART and stole the TCP+TX window. */
	st = stats_get();
	if (host_uart_available() > 0)
		return;
	if (st->last_uart_ms && (now - st->last_uart_ms) < 300u)
		return;
	ArduinoOTA.handle();
	if (!s_http_live)
		goto mdns_only;
	if (host_uart_available() > 0)
		goto mdns_only;
	st = stats_get();
	if (st->last_uart_ms && (now - st->last_uart_ms) < 300u)
		goto mdns_only;
	if ((now - s_last_http_ms) < 50u)
		goto mdns_only;
	s_last_http_ms = now;
	s_http.handleClient();
mdns_only:
#if defined(ARDUINO_ARCH_ESP8266)
	if ((now - s_last_mdns_ms) > 1000u) {
		s_last_mdns_ms = now;
		MDNS.update();
	}
#endif
}
