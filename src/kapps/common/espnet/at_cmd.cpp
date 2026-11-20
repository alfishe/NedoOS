#include <string.h>
#include "at_cmd.h"
#include "host_uart.h"
#include "codec.h"
#include "sockets.h"
#include "wifi_cmd.h"
#include "stats.h"

#if defined(ARDUINO_ARCH_ESP32)
#include <WiFi.h>
#else
#include <ESP8266WiFi.h>
#endif
#include <WiFiClient.h>

#define AT_LINE_MAX 128
#define AT_DATA_MAX 2048

static int s_mode;	 /* 1 = host UART runs the AT text protocol */
static int s_pending;	 /* binary ATMODE acked, switch after reply TX */

static WiFiClient s_client;
static int s_connected;

static char s_line[AT_LINE_MAX];
static uint8_t s_linelen;
static uint8_t s_lf_skip; /* CR ended a command: the LF after it is not data */
static uint8_t s_echo;    /* ATE1: echo command bytes back, ATE0: silent */

static uint32_t s_send_left; /* CIPSEND bytes still to forward */
static uint8_t s_send_fail;

#define AT_TX_CHUNK 256
static uint8_t s_txbuf[AT_TX_CHUNK];
static uint16_t s_txn;
static uint8_t s_tx_lost;

static uint8_t s_ipd[AT_DATA_MAX];

static uint8_t s_ready_wait; /* print "WIFI GOT IP" once STA has an IP */
static uint32_t s_rx_bytes;  /* +IPD bytes forwarded for this connection */

static void at_puts(const char *s)
{
	host_uart_write_buf((const uint8_t *)s, (uint16_t)strlen(s));
}

static void at_reply(const char *s)
{
	at_puts(s);
	at_puts("\r\n");
}

static char ci_lower(char c)
{
	return (c >= 'A' && c <= 'Z') ? (char)(c + 32) : c;
}

static int at_eq(const char *a, const char *b)
{
	while (*a && *b) {
		if (ci_lower(*a++) != ci_lower(*b++))
			return 0;
	}
	return *a == *b;
}

static int at_starts(const char *line, const char *pre)
{
	while (*pre) {
		if (ci_lower(*line++) != ci_lower(*pre++))
			return 0;
	}
	return 1;
}

/* One-byte writes with TCP_NODELAY filled the lwIP segment queue, and
 * WiFiClient::write() answered 0 for the refused byte, which we dropped: the
 * server got a request cut short and waited for the rest instead of replying
 * (recvHead then timed out with no +IPD at all). Feed the socket in chunks
 * and retry a refused write, the way the binary path's do_write() does. */
static void at_tx_flush(void)
{
	uint16_t off = 0;
	uint32_t t0 = millis();

	if (s_txn == 0)
		return;
	while (off < s_txn) {
		size_t w;

		if (!s_client.connected()) {
			s_tx_lost = 1;
			break;
		}
		w = s_client.write(s_txbuf + off, (size_t)(s_txn - off));
		if (w == 0) {
			if ((uint32_t)(millis() - t0) >= 3000u) {
				s_tx_lost = 1;
				break;
			}
			delay(1);
			continue;
		}
		off = (uint16_t)(off + (uint16_t)w);
		stats_wifi_tx((uint16_t)w);
		t0 = millis();
	}
	s_txn = 0;
}

static void at_close(void)
{
	if (s_connected) {
		s_client.stop();
		s_connected = 0;
	}
}

static void at_rst(void)
{
	at_close();
	s_send_left = 0;
	s_send_fail = 0;
	s_txn = 0;
	s_tx_lost = 0;
	s_rx_bytes = 0;
	if (wifi_status_code() == ESPNET_WIFI_GOT_IP) {
		s_ready_wait = 0;
		at_reply("WIFI GOT IP");
	} else {
		/* STA reconnects in the background (wifi_poll). Answer when up. */
		s_ready_wait = 1;
	}
}

static void at_close_cmd(void)
{
	if (s_connected) {
		at_close();
		at_reply("CLOSED");
		at_reply("OK");
	} else {
		at_reply("ERROR");
	}
}

static void at_cipstart(char *line)
{
	char *p = line + 11; /* skip "AT+CIPSTART" */
	char host[ESPNET_DNS_NAME + 1];
	uint16_t hostlen = 0;
	uint16_t port = 0;
	IPAddress ip;
	bool ok;
	int why = 1;
	int i;

	while (*p == '=' || *p == ' ')
		p++;
	if (*p != '"')
		goto bad;
	p++;
	/* only "TCP"; UDP/SSL are not implemented */
	if (ci_lower(p[0]) != 't' || ci_lower(p[1]) != 'c' ||
	    ci_lower(p[2]) != 'p' || p[3] != '"')
		goto bad;
	p += 4; /* "TCP" + closing quote */
	if (*p != ',')
		goto bad;
	p++;
	if (*p != '"')
		goto bad;
	p++;
	hostlen = 0;
	while (*p && *p != '"' && hostlen < ESPNET_DNS_NAME)
		host[hostlen++] = *p++;
	if (*p != '"')
		goto bad;
	host[hostlen] = 0;
	p++;
	if (*p != ',')
		goto bad;
	p++;
	while (*p >= '0' && *p <= '9') {
		port = (uint16_t)(port * 10u + (uint16_t)(*p - '0'));
		p++;
	}
	if (port == 0)
		goto bad;

	at_close();
	/* A WiFi blip or one lost DNS answer used to fail CIPSTART outright: the
	 * client only sees ERROR and getpic throws away a whole espReBoot cycle.
	 * Wait briefly for GOT_IP and re-ask DNS before giving up. */
	why = 2;
	{
		uint32_t t0 = millis();

		while (wifi_status_code() != ESPNET_WIFI_GOT_IP) {
			if ((uint32_t)(millis() - t0) >= 600u)
				goto bad;
			delay(20);
		}
	}
	why = 3;
	ok = false;
	for (i = 0; i < 3 && !ok; i++) {
		if (i)
			delay(100);
		ok = WiFi.hostByName(host, ip);
	}
	if (!ok)
		goto bad;
	why = 4;
	{
		uint32_t t0 = millis();

		/* ESP8266 WiFiClient::connect() does not take a timeout: it copies
		 * the client's read timeout into ClientContext and waits that long
		 * for SYN-ACK. We keep 50 ms there for reads, which turned every
		 * reconnect after the first page into an instant failure
		 * ("AT CIPSTART fail 4", errno-free, ~50 ms). ESP32 passes the
		 * timeout explicitly, so only the 8266 boards were hit. */
		s_client.setTimeout(ESPNET_CONNECT_MS);

#if defined(ARDUINO_ARCH_ESP32)
		ok = s_client.connect(ip, port, ESPNET_CONNECT_MS);
#else
		ok = s_client.connect(ip, port);
#endif
		/* Retry only a quick refusal (RST); a real timeout already ate the
		 * client's patience and a second 8 s wait would make it worse. */
		if (!ok && (uint32_t)(millis() - t0) < 1500u) {
			delay(50);
#if defined(ARDUINO_ARCH_ESP32)
			ok = s_client.connect(ip, port, ESPNET_CONNECT_MS);
#else
			ok = s_client.connect(ip, port);
#endif
		}
	}
	if (!ok)
		goto bad;
	s_client.setNoDelay(true);
	s_client.setTimeout(50);
	s_connected = 1;
	s_rx_bytes = 0;
	slog("AT CIPSTART %s:%u ip %u.%u.%u.%u ok", host, (unsigned)port,
	     (unsigned)ip[0], (unsigned)ip[1], (unsigned)ip[2], (unsigned)ip[3]);
	at_reply("CONNECT");
	at_reply("OK");
	return;

bad:
	at_close();
	slog("AT CIPSTART fail %d", why);
	at_reply("ERROR");
}

static void at_cipsend(char *line)
{
	char *p = line + 10; /* skip "AT+CIPSEND" */
	uint32_t n = 0;

	if (!s_connected || !s_client.connected())
		goto bad;
	while (*p == '=' || *p == ' ')
		p++;
	while (*p >= '0' && *p <= '9') {
		n = n * 10u + (uint32_t)(*p - '0');
		p++;
	}
	if (n == 0)
		goto bad;
	s_send_left = n;
	s_send_fail = 0;
	s_txn = 0;
	s_tx_lost = 0;
	s_rx_bytes = 0;
	slog("AT CIPSEND %u", (unsigned)n);
	at_reply("OK");
	at_puts(">"); /* prompt, no CRLF */
	return;

bad:
	slog("AT CIPSEND rejected");
	at_reply("ERROR");
}

/* AT+LOG: dump the recent log over the host UART. Boards with the ESP soldered
 * on (ESP8266 ZX-WiFi) have no USB console to type AT+WEB, so the ZX itself
 * has to be able to ask what happened. */
static void at_log(void)
{
	unsigned total = stats_log_count();
	unsigned n = total;
	unsigned first;
	unsigned i;

	if (n > ESPNET_LOG_LINES)
		n = ESPNET_LOG_LINES;
	first = total - n;
	for (i = first; i < total; i++)
		at_reply(stats_log_line(i));
	at_reply("OK");
}

static void at_dispatch(char *line)
{
	if (!line[0])
		return;
	if (at_eq(line, "AT"))
		at_reply("OK");
	else if (at_eq(line, "AT+LOG") || at_eq(line, "LOG"))
		at_log();
	else if (at_eq(line, "AT+BIN")) {
		at_reply("OK");
		at_exit();
	} else if (at_eq(line, "ATE0")) {
		s_echo = 0;
		at_reply("OK");
	} else if (at_eq(line, "ATE1")) {
		s_echo = 1;
		at_reply("OK");
	} else if (at_eq(line, "AT+RST"))
		at_rst();
	else if (at_eq(line, "AT+CIPCLOSE"))
		at_close_cmd();
	else if (at_starts(line, "AT+CIPDINFO"))
		at_reply("OK");
	else if (at_starts(line, "AT+CIPMUX"))
		at_reply("OK");
	else if (at_starts(line, "AT+CIPSERVER"))
		at_reply("OK");
	else if (at_starts(line, "AT+CIPRECVMODE"))
		at_reply("OK");
	else if (at_starts(line, "AT+CIPSTART"))
		at_cipstart(line);
	else if (at_starts(line, "AT+CIPSEND"))
		at_cipsend(line);
	else
		at_reply("ERROR");
}

static void at_feed(uint8_t b)
{
	/* A command line ends with CR LF. CIPSEND arms the data mode on the CR,
	 * so the LF that follows must be eaten here: passing it on pushed a
	 * stray 0x0A into the socket ahead of the payload and shortened the
	 * payload by one byte (HTTP 400, then every command one byte late). */
	if (b == '\n' && s_lf_skip) {
		s_lf_skip = 0;
		return;
	}

	if (s_send_left > 0) {
		/* CIPSEND data passthrough, buffered: see at_tx_flush(). */
		if (!s_client.connected())
			s_send_fail = 1;
		s_txbuf[s_txn] = b;
		s_txn++;
		if (s_txn >= AT_TX_CHUNK)
			at_tx_flush();
		s_send_left--;
		if (s_send_left == 0) {
			at_tx_flush();
			if (s_tx_lost)
				s_send_fail = 1;
			s_tx_lost = 0;
			s_client.flush();
			if (!s_send_fail && s_client.connected())
				at_reply("SEND OK");
			else {
				at_reply("SEND FAIL");
				at_close();
			}
			slog("AT sent %s", s_send_fail ? "fail" : "ok");
		}
		return;
	}

	/* ATE1 echo: character by character, CR shown as CRLF. The LF that
	 * terminates the same line is dropped above and is not echoed again. */
	if (s_echo) {
		if (b == '\r')
			at_puts("\r\n");
		else
			host_uart_write_buf(&b, 1);
	}

	if (b == '\r' || b == '\n') {
		if (s_linelen) {
			s_line[s_linelen] = 0;
			at_dispatch(s_line);
			s_linelen = 0;
		}
		s_lf_skip = (b == '\r');
		return;
	}
	s_lf_skip = 0;
	if (s_linelen < AT_LINE_MAX - 1)
		s_line[s_linelen++] = (char)b;
}

static void at_pump_client(void)
{
	int n;
	int rounds;

	if (!s_connected)
		return;

	/* Drain what the stack already buffered before announcing a peer close.
	 * A FIN can flip connected() while unread bytes are still queued, and
	 * stop() throws that tail away: a gopher page has no length header, so
	 * the client silently keeps a truncated page instead of the whole menu.
	 * Bounded per call so a big file cannot starve the web/OTA/loop work. */
	for (rounds = 0; rounds < 8; rounds++) {
		char hdr[16];
		int hl;

		if (s_client.available() <= 0) {
			if (!s_client.connected()) {
				/* remote FIN / radio drop: unsolicited close, like ESP-AT */
				s_connected = 0;
				s_client.stop();
				slog("AT link closed, %lu bytes", (unsigned long)s_rx_bytes);
				at_reply("CLOSED");
			}
			return;
		}
		n = s_client.read(s_ipd, AT_DATA_MAX);
		if (n <= 0)
			return;
		hl = snprintf(hdr, sizeof(hdr), "+IPD,%d:", n);
		if (hl < 0)
			hl = 0;
		if (hl >= (int)sizeof(hdr))
			hl = (int)sizeof(hdr) - 1;
		host_uart_write_buf((const uint8_t *)hdr, (uint16_t)hl);
		host_uart_write_buf(s_ipd, (uint16_t)n);
		stats_wifi_rx((uint16_t)n);
		s_rx_bytes += (uint32_t)n;
		slog("AT IPD %u", (unsigned)n);
	}
}

void at_begin(void)
{
	s_mode = 0;
	s_pending = 0;
	s_connected = 0;
	s_linelen = 0;
	s_lf_skip = 0;
	s_send_left = 0;
	s_send_fail = 0;
	s_txn = 0;
	s_tx_lost = 0;
	s_rx_bytes = 0;
	s_ready_wait = 0;
}

int at_mode(void)
{
	return s_mode;
}

void at_enter(void)
{
	if (s_mode)
		return;
	sockets_close_all(); /* free binary slots; AT uses its own client */
	espnet_rx_reset();	 /* drop any partial binary frame */
	s_client.stop();
	s_connected = 0;
	s_linelen = 0;
	s_lf_skip = 0;
	s_send_left = 0;
	s_send_fail = 0;
	s_txn = 0;
	s_tx_lost = 0;
	s_rx_bytes = 0;
	s_ready_wait = 0;
	s_pending = 0;
	s_mode = 1;
	slog("AT mode on");
}

void at_exit(void)
{
	if (!s_mode)
		return;
	s_client.stop();
	s_connected = 0;
	s_linelen = 0;
	s_lf_skip = 0;
	s_send_left = 0;
	s_send_fail = 0;
	s_txn = 0;
	s_tx_lost = 0;
	s_rx_bytes = 0;
	s_ready_wait = 0;
	s_mode = 0;
	espnet_rx_reset();
	slog("AT mode off");
}

void at_poll(void)
{
	if (!s_mode)
		return;
	if (s_ready_wait && wifi_status_code() == ESPNET_WIFI_GOT_IP) {
		s_ready_wait = 0;
		at_reply("WIFI GOT IP");
	}
	at_pump_client();
	while (s_mode && host_uart_available() > 0) {
		int b = host_uart_read();
		if (b < 0)
			break;
		at_feed((uint8_t)b);
	}
}

uint8_t at_handle_bin(const uint8_t *req, uint16_t req_n, uint8_t *rsp, uint16_t *rsp_n)
{
	uint8_t cmd;

	(void)req_n;
	cmd = (uint8_t)(req[ESPNET_REQ_CMD] & ESPNET_CMD_MASK);
	if (cmd != ESPNET_CMD_ATMODE)
		return 0;
	rsp[ESPNET_RSP_CMD] = ESPNET_CMD_ATMODE;
	rsp[ESPNET_RSP_SOCK] = ESPNET_SOCK_NONE;
	rsp[ESPNET_RSP_STATUS] = 0;
	rsp[ESPNET_RSP_SEQ] = req[ESPNET_REQ_SEQ];
	espnet_put_u16(rsp + ESPNET_RSP_RESULT, 0);
	espnet_put_u16(rsp + ESPNET_RSP_LEN, 0);
	*rsp_n = ESPNET_RSP_HDR;
	s_pending = 1;
	return 1;
}

int at_pending(void)
{
	return s_pending;
}
