#ifndef ESPNET_SOCKETS_H
#define ESPNET_SOCKETS_H

#include <Arduino.h>
#include "protocol.h"
#include "pins.h"

void sockets_begin(void);
void sockets_pump(void);
/* User WIFI_DISC only. A radio blip must not stop TCP. */
void sockets_on_link_lost(void);
void sockets_reap_dead(void);
void sockets_close_all(void);
void sockets_debug(Stream &s);
uint8_t sockets_mask(void);
uint8_t sockets_max(void);

struct SockView {
	uint8_t state;
	uint8_t proto;
	uint8_t conn;
	uint16_t rx_len;
	uint16_t avail;
};
void sockets_view(SockView *v, uint8_t *n);

/* Handle a complete request; fills rsp raw (header+payload).
 * Returns raw length. rsp_cap is size of rsp buffer. */
uint16_t sockets_handle(const uint8_t *req, uint16_t req_n, uint8_t *rsp, uint16_t rsp_cap);

#endif
