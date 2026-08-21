#ifndef ESPNET_WIFI_CMD_H
#define ESPNET_WIFI_CMD_H

#include <Arduino.h>
#include "protocol.h"

void wifi_cmd_begin(void);
void wifi_poll(void);
uint8_t wifi_status_code(void);
int8_t wifi_rssi_val(void);
void wifi_fill_ip(uint8_t *dst);
void wifi_fill_mac(uint8_t *dst);
void wifi_fill_ssid(uint8_t *dst);

uint8_t wifi_handle(const uint8_t *req, uint16_t req_n, uint8_t *rsp, uint16_t *rsp_n);

void usb_debug_poll(void);
void usb_print_gmr(void);
void usb_print_status(void);

#endif
