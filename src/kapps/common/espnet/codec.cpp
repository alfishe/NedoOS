#include "codec.h"
#include "host_uart.h"
#include "sockets.h"

static uint8_t s_raw[ESPNET_REQ_HDR + ESPNET_MAX_PAYLOAD + 1];
static uint16_t s_got;
static uint16_t s_need;
static uint8_t s_in_frame;
static uint8_t s_had_crc;

static uint8_t crc8(const uint8_t *p, uint16_t n)
{
	uint8_t c = 0;
	while (n--)
		c ^= *p++;
	return c;
}

void espnet_put_u16(uint8_t *p, uint16_t v)
{
	p[0] = (uint8_t)v;
	p[1] = (uint8_t)(v >> 8);
}

uint16_t espnet_get_u16(const uint8_t *p)
{
	return (uint16_t)p[0] | ((uint16_t)p[1] << 8);
}

void espnet_put_u32(uint8_t *p, uint32_t v)
{
	p[0] = (uint8_t)v;
	p[1] = (uint8_t)(v >> 8);
	p[2] = (uint8_t)(v >> 16);
	p[3] = (uint8_t)(v >> 24);
}

uint32_t espnet_get_u32(const uint8_t *p)
{
	return (uint32_t)p[0]
	     | ((uint32_t)p[1] << 8)
	     | ((uint32_t)p[2] << 16)
	     | ((uint32_t)p[3] << 24);
}

void espnet_rx_reset(void)
{
	s_got = 0;
	s_need = 0;
	s_in_frame = 0;
	s_had_crc = 0;
}

uint8_t espnet_rx_in_frame(void)
{
	return s_in_frame;
}

uint8_t *espnet_rx_raw(void)
{
	return s_raw;
}

uint16_t espnet_rx_len(void)
{
	return s_got;
}

static void rx_push(uint8_t b)
{
	if (s_got < sizeof(s_raw))
		s_raw[s_got++] = b;
}

int espnet_rx_feed(uint8_t b)
{
	if (!s_in_frame) {
		if (b == ESPNET_SOF) {
			s_in_frame = 1;
			s_got = 0;
			s_need = 0;
		}
		return 0;
	}

	rx_push(b);

	if (s_need == 0 && s_got >= ESPNET_REQ_HDR) {
		uint16_t plen = espnet_get_u16(s_raw + ESPNET_REQ_LEN);
		if (plen > ESPNET_MAX_PAYLOAD) {
			espnet_rx_reset();
			return -1;
		}
		s_need = (uint16_t)(ESPNET_REQ_HDR + plen);
		if (s_raw[ESPNET_REQ_CMD] & ESPNET_F_CRC)
			s_need++;
	}

	if (s_need != 0 && s_got >= s_need) {
		uint16_t body = s_need;
		s_in_frame = 0;
		s_had_crc = 0;
		if (s_raw[ESPNET_REQ_CMD] & ESPNET_F_CRC) {
			body = (uint16_t)(s_need - 1);
			if (crc8(s_raw, body) != s_raw[body])
				return -1;
			s_got = body;
			s_had_crc = 1;
		}
		return 1;
	}
	return 0;
}

static uint8_t s_txb[64];
static uint8_t s_txn;

static void tx_flush(void)
{
	if (s_txn) {
		host_uart_write_buf(s_txb, s_txn);
		s_txn = 0;
	}
}

static void tx_put(uint8_t b)
{
	s_txb[s_txn++] = b;
	if (s_txn >= sizeof(s_txb))
		tx_flush();
}

void espnet_tx_frame(const uint8_t *raw, uint16_t n)
{
	uint16_t i;

	s_txn = 0;
	tx_put(ESPNET_SOF);
	i = 0;
	while (n--) {
		tx_put(*raw++);
		i++;
		if ((i & 255) == 0) {
			tx_flush();
			host_uart_idle();
			sockets_pump();
		}
	}
	tx_flush();
}

void espnet_tx_reply(uint8_t *raw, uint16_t n)
{
	if (s_had_crc && n >= ESPNET_RSP_HDR) {
		raw[ESPNET_RSP_CMD] |= ESPNET_F_CRC;
		raw[n] = crc8(raw, n);
		n++;
	}
	espnet_tx_frame(raw, n);
}
