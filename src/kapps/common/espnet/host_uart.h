#ifndef ESPNET_HOST_UART_H
#define ESPNET_HOST_UART_H

#include <Arduino.h>
#include "pins.h"

void host_uart_begin(void);
int host_uart_read(void);
void host_uart_write(uint8_t b);
void host_uart_write_buf(const uint8_t *p, uint16_t n);
int host_uart_available(void);
void host_uart_idle(void);
Stream &host_debug(void);

uint32_t host_uart_baud(void);
uint8_t host_uart_saved_eq(void);
int host_uart_baud_ok(uint32_t baud);
/* Queue ZX UART baud after the current reply is on the wire. persist writes NVS. */
int host_uart_request_baud(uint32_t baud, int persist);
void host_uart_apply_pending(void);
/* USB AT+UART=: switch now (no in-flight ZX frame). */
int host_uart_set_baud_now(uint32_t baud, int persist);

#endif
