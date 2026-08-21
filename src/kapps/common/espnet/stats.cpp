#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include "stats.h"
#include "codec.h"
#include "host_uart.h"

static EspnetStats s_st;
static char s_log[ESPNET_LOG_LINES][ESPNET_LOG_WIDTH];
static uint8_t s_head;
static uint8_t s_count;
static uint16_t s_eagain_run;

void stats_begin(void)
{
	memset(&s_st, 0, sizeof(s_st));
	s_head = 0;
	s_count = 0;
	s_eagain_run = 0;
}

void slog(const char *fmt, ...)
{
	char *dst = s_log[s_head];
	unsigned sec = (unsigned)(millis() / 1000u);
	int n;
	va_list ap;

	n = snprintf(dst, ESPNET_LOG_WIDTH, "%u ", sec);
	if (n < 0)
		n = 0;
	if (n >= ESPNET_LOG_WIDTH)
		n = ESPNET_LOG_WIDTH - 1;
	va_start(ap, fmt);
	vsnprintf(dst + n, (size_t)(ESPNET_LOG_WIDTH - n), fmt, ap);
	va_end(ap);
	dst[ESPNET_LOG_WIDTH - 1] = 0;
	s_head = (uint8_t)((s_head + 1) % ESPNET_LOG_LINES);
	if (s_count < ESPNET_LOG_LINES)
		s_count++;
	host_debug().println(dst);
}

void slog_clear(void)
{
	s_head = 0;
	s_count = 0;
	s_eagain_run = 0;
}

unsigned stats_log_count(void)
{
	return s_count;
}

const char *stats_log_line(unsigned i)
{
	unsigned start;

	if (i >= s_count)
		return "";
	start = (s_count < ESPNET_LOG_LINES) ? 0 : s_head;
	return s_log[(start + i) % ESPNET_LOG_LINES];
}

void stats_uart_rx(uint16_t n)
{
	s_st.uart_rx += n;
	s_st.last_uart_ms = millis();
}

void stats_uart_tx(uint16_t n)
{
	s_st.uart_tx += n;
	s_st.last_uart_ms = millis();
}

void stats_wifi_rx(uint16_t n)
{
	s_st.wifi_rx += n;
	s_st.last_wifi_rx_ms = millis();
}

void stats_wifi_tx(uint16_t n)
{
	s_st.wifi_tx += n;
	s_st.last_wifi_tx_ms = millis();
}

void stats_tx_wait_tick(void)
{
	s_st.tx_wait++;
}

void stats_resync(void)
{
	s_st.uart_resync++;
}

void stats_busy(uint8_t on)
{
	s_st.busy = on ? 1 : 0;
}

const EspnetStats *stats_get(void)
{
	return &s_st;
}

const char *stats_cmd_name(uint8_t cmd)
{
	switch (cmd & ESPNET_CMD_MASK) {
	case ESPNET_CMD_SOCKET: return "SOCKET";
	case ESPNET_CMD_SHUTDOWN: return "SHUT";
	case ESPNET_CMD_CONNECT: return "CONN";
	case ESPNET_CMD_ACCEPT: return "ACPT";
	case ESPNET_CMD_BIND: return "BIND";
	case ESPNET_CMD_LISTEN: return "LSTN";
	case ESPNET_CMD_READ: return "READ";
	case ESPNET_CMD_WRITE: return "WRITE";
	case ESPNET_CMD_GETDNS: return "GDNS";
	case ESPNET_CMD_DNSRESOLVE: return "DNS";
	case ESPNET_CMD_INFO: return "INFO";
	case ESPNET_CMD_WIFI_SCAN: return "SCAN";
	case ESPNET_CMD_WIFI_CONNECT: return "WCON";
	case ESPNET_CMD_WIFI_DISC: return "WDIS";
	case ESPNET_CMD_WIFI_STATUS: return "WSTA";
	case ESPNET_CMD_UART: return "UART";
	case ESPNET_CMD_ECHO: return "ECHO";
	default: return "???";
	}
}

const char *stats_err_name(uint8_t err)
{
	switch (err) {
	case 0: return "ok";
	case ESPNET_ERR_INTR: return "INTR";
	case ESPNET_ERR_NFILE: return "NFILE";
	case ESPNET_ERR_EAGAIN: return "EAGAIN";
	case ESPNET_ERR_ALREADY: return "ALREADY";
	case ESPNET_ERR_NOTSOCK: return "NOTSOCK";
	case ESPNET_ERR_EMSGSIZE: return "EMSGSIZE";
	case ESPNET_ERR_PROTOTYPE: return "PROTOTYPE";
	case ESPNET_ERR_AFNOSUPPORT: return "AFNOSUPPORT";
	case ESPNET_ERR_ECONNABORTED: return "ABORTED";
	case ESPNET_ERR_CONNRESET: return "RESET";
	case ESPNET_ERR_NOTCONN: return "NOTCONN";
	case ESPNET_ERR_HOSTUNREACH: return "HOSTUNREACH";
	default: return "ERR";
	}
}

void stats_on_reply(const uint8_t *req, const uint8_t *rsp, uint16_t rsp_n)
{
	uint8_t cmd;
	uint8_t st;
	uint16_t res;
	uint16_t plen;

	if (!req || !rsp || rsp_n < ESPNET_RSP_HDR)
		return;
	cmd = (uint8_t)(req[ESPNET_REQ_CMD] & ESPNET_CMD_MASK);
	st = rsp[ESPNET_RSP_STATUS];
	res = espnet_get_u16(rsp + ESPNET_RSP_RESULT);
	plen = espnet_get_u16(rsp + ESPNET_RSP_LEN);
	s_st.cmds++;
	s_st.last_cmd = cmd;
	s_st.last_sock = rsp[ESPNET_RSP_SOCK];
	s_st.last_seq = rsp[ESPNET_RSP_SEQ];
	s_st.last_status = st;
	s_st.last_result = res;
	s_st.last_plen = plen;
	s_st.last_cmd_ms = millis();
	if (st == ESPNET_ERR_EAGAIN) {
		s_st.cmds_eagain++;
		s_eagain_run++;
		return;
	}
	if (s_eagain_run) {
		slog("EAGAIN x%u (quiet)", (unsigned)s_eagain_run);
		s_eagain_run = 0;
	}
	if (st == 0)
		s_st.cmds_ok++;
	else
		s_st.cmds_err++;
	/* READ/WRITE stay counters-only: slog+USB Serial on every 2KB chunk
	 * sat in front of ZX UART TX and capped the download. */
	if (cmd == ESPNET_CMD_READ || cmd == ESPNET_CMD_WRITE)
		return;
	slog("%s s%u seq=%u %s res=%u plen=%u", stats_cmd_name(cmd),
	     (unsigned)s_st.last_sock, (unsigned)s_st.last_seq,
	     stats_err_name(st), (unsigned)res, (unsigned)plen);
}
