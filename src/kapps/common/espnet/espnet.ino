/*
 * ESPNET - binary socket firmware for ESP32, ESP32-C3, and ESP8266.
 *
 * Arduino IDE 2:
 *   Open this folder as a sketch.
 *   ESP32 D1 mini:     "WEMOS D1 MINI ESP32" / "ESP32 Dev Module"
 *   ESP32-C3 Super Mini (ATM-COM AT layout): "ESP32C3 Dev Module"
 *     USB CDC On Boot = Enabled.
 *   ESP8266 ZX-WiFi / bare ESP-12F: "Generic ESP8266 Module", 4MB OTA.
 *   ESP8266 D1 mini / ESP-AT:  "LOLIN(WEMOS) D1 R2 & mini"
 *
 * Same ESP8266 chip; UART wiring differs (see pins.h). Force with
 * ESPNET_BOARD_ZXWIFI or ESPNET_BOARD_D1MINI if the board name is wrong.
 * USB Serial: AT+GMR / AT+STATUS. After WiFi: http://espnet.local  OTA.
 */

#include "protocol.h"
#include "pins.h"
#include "host_uart.h"
#include "codec.h"
#include "sockets.h"
#include "wifi_cmd.h"
#include "webui.h"
#include "stats.h"

static uint8_t s_rsp[ESPNET_RSP_HDR + ESPNET_MAX_PAYLOAD + 1];

void setup()
{
	host_uart_begin();
	wifi_cmd_begin();
	sockets_begin();
	espnet_rx_reset();
	webui_begin_log();
	host_debug().println(F("ESPNET ready"));
	usb_print_gmr();
	usb_print_status();
}

void loop()
{
	if (webui_ota_active()) {
		webui_poll();
#if defined(ARDUINO_ARCH_ESP8266)
		ESP.wdtFeed();
#endif
		yield();
		return;
	}

	sockets_pump();
	while (host_uart_available() > 0) {
		int b = host_uart_read();
		int r;
		if (b < 0)
			break;
		r = espnet_rx_feed((uint8_t)b);
		if (r < 0) {
			stats_resync();
			espnet_rx_reset();
			continue;
		}
		if (r == 1) {
			uint8_t *req = espnet_rx_raw();
			uint16_t req_n = espnet_rx_len();
			uint16_t n = 0;
			stats_busy(1);
			if (!wifi_handle(req, req_n, s_rsp, &n))
				n = sockets_handle(req, req_n, s_rsp, sizeof(s_rsp));
			if (n >= ESPNET_RSP_HDR && n <= sizeof(s_rsp) - 1) {
				espnet_tx_reply(s_rsp, n);
				stats_on_reply(req, s_rsp, n);
			}
			stats_busy(0);
			host_uart_apply_pending();
			espnet_rx_reset();
		}
	}

	usb_debug_poll();
	wifi_poll();
	webui_poll();
	yield();
}
