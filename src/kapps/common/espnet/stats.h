#ifndef ESPNET_STATS_H
#define ESPNET_STATS_H

#include <Arduino.h>
#include "protocol.h"

#if defined(ARDUINO_ARCH_ESP32)
#define ESPNET_LOG_LINES 80
#define ESPNET_LOG_WIDTH 96
#else
#define ESPNET_LOG_LINES 40
#define ESPNET_LOG_WIDTH 80
#endif

struct EspnetStats {
	uint32_t uart_rx;
	uint32_t uart_tx;
	uint32_t wifi_rx;
	uint32_t wifi_tx;
	uint32_t cmds;
	uint32_t cmds_ok;
	uint32_t cmds_err;
	uint32_t cmds_eagain;
	uint32_t uart_resync;
	uint32_t tx_wait;
	uint32_t last_uart_ms;
	uint32_t last_wifi_rx_ms;
	uint32_t last_wifi_tx_ms;
	uint32_t last_cmd_ms;
	uint8_t last_cmd;
	uint8_t last_sock;
	uint8_t last_seq;
	uint8_t last_status;
	uint16_t last_result;
	uint16_t last_plen;
	uint8_t busy;
};

void stats_begin(void);
void slog(const char *fmt, ...);
void slog_clear(void);
unsigned stats_log_count(void);
const char *stats_log_line(unsigned i); /* 0 = oldest */

void stats_uart_rx(uint16_t n);
void stats_uart_tx(uint16_t n);
void stats_wifi_rx(uint16_t n);
void stats_wifi_tx(uint16_t n);
void stats_tx_wait_tick(void);
void stats_resync(void);
void stats_busy(uint8_t on);
void stats_on_reply(const uint8_t *req, const uint8_t *rsp, uint16_t rsp_n);

const EspnetStats *stats_get(void);
const char *stats_cmd_name(uint8_t cmd);
const char *stats_err_name(uint8_t err);

#endif
