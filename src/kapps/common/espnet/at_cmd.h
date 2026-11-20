#ifndef ESPNET_AT_CMD_H
#define ESPNET_AT_CMD_H

#include <Arduino.h>
#include "protocol.h"

/*
 * Minimal ESP-AT compatible text mode on the host UART (the same wire as
 * the binary protocol). Enough for getpic / zxart-radio / netprint / zxdb /
 * calendar / gopher / zifi / updater ESP-COM clients:
 *
 *   AT               -> OK
 *   ATE0 / ATE1      -> OK
 *   AT+RST           -> WIFI GOT IP (once STA has an IP)
 *   AT+CIPCLOSE      -> CLOSED + OK, or ERROR when idle
 *   AT+CIPDINFO=0    -> OK
 *   AT+CIPMUX=0      -> OK
 *   AT+CIPSERVER=0   -> OK
 *   AT+CIPRECVMODE=0 -> OK
 *   AT+CIPSTART="TCP","host",port -> CONNECT + OK (or ERROR)
 *   AT+CIPSEND=n     -> OK + ">" prompt, then n raw bytes are forwarded
 *   AT+BIN           -> OK, back to the binary protocol
 *
 * Incoming TCP data is pushed as "+IPD,<len>:<data>"; a remote close is
 * reported as "CLOSED". No BIND/LISTEN/ACCEPT, no NTP, no echo (ATE0).
 */

void at_begin(void);

/* 1 while the host UART runs the AT text protocol. */
int at_mode(void);

/* Switch the host UART to AT mode (closes binary sockets, resets state). */
void at_enter(void);

/* Switch the host UART back to the binary protocol. */
void at_exit(void);

/* Poll in AT mode: pump the AT socket and process AT command lines. */
void at_poll(void);

/* Binary command ESPNET_CMD_ATMODE: build the ACK reply and mark a pending
 * switch. The loop calls at_enter() after the reply is on the wire.
 * Returns 1 when the command was handled. */
uint8_t at_handle_bin(const uint8_t *req, uint16_t req_n, uint8_t *rsp, uint16_t *rsp_n);

/* 1 if a binary ATMODE command just asked to switch. */
int at_pending(void);

#endif
