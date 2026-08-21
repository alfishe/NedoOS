#ifndef ESPNET_CODEC_H
#define ESPNET_CODEC_H

#include <Arduino.h>
#include "protocol.h"

void espnet_rx_reset(void);
uint8_t espnet_rx_in_frame(void);
/* Feed one UART byte (0x00 is payload). 0 = need more, 1 = frame complete, -1 = bad LEN/CRC. */
int espnet_rx_feed(uint8_t b);
uint8_t *espnet_rx_raw(void);
uint16_t espnet_rx_len(void);
void espnet_tx_frame(const uint8_t *raw, uint16_t n);
void espnet_tx_reply(uint8_t *raw, uint16_t n);

void espnet_put_u16(uint8_t *p, uint16_t v);
uint16_t espnet_get_u16(const uint8_t *p);
void espnet_put_u32(uint8_t *p, uint32_t v);
uint32_t espnet_get_u32(const uint8_t *p);

#endif
