#ifndef ESPNET_PINS_H
#define ESPNET_PINS_H

#include "protocol.h"

#define ESPNET_BAUD 115200
#define ESPNET_WEB_USER "espnet"
#define ESPNET_WEB_PASS "espnet"
/*
190 - ATM2COM - 38400!
*/
/*
 * ESP8266 host UART. ESP-12F and D1 mini are the same chip; wiring cannot
 * be detected at runtime. Force a layout, or leave both commented for auto:
 *
 *   Arduino board "Generic ESP8266 Module" (ESP-12) -> ZX-WiFi, native UART0
 *   Arduino board "LOLIN D1 mini" and others        -> ESP-AT, Serial.swap()
 */

#define ESPNET_BOARD_ZXWIFI
//#define ESPNET_BOARD_D1MINI




#if defined(CONFIG_IDF_TARGET_ESP32C3)
/* ESP-AT C3 / Super Mini: UART1 to host, USB CDC = Serial debug. */
#define ESPNET_UART_TX 7
#define ESPNET_UART_RX 6
#define ESPNET_UART_CTS 5
#define ESPNET_UART_RTS 4
#define ESPNET_UART_NUM 1
#define ESPNET_UART_SWAP 0
#define ESPNET_UART_LAYOUT_STR "ESP32-C3 UART1 7/6 AT"
#define ESPNET_OTA_HOSTNAME "espnet-C3"
#define ESPNET_CHIP_ID ESPNET_CHIP_ESP32C3
#define ESPNET_MAX_SOCKS ESPNET_MAX_SOCKS_ESP32
#define ESPNET_RX_SIZE ESPNET_MAX_PAYLOAD
#elif defined(ARDUINO_ARCH_ESP32)
#define ESPNET_UART_TX 17
#define ESPNET_UART_RX 16
#define ESPNET_UART_CTS 15
#define ESPNET_UART_RTS 14
#define ESPNET_UART_NUM 1
#define ESPNET_UART_SWAP 0
#define ESPNET_UART_LAYOUT_STR "ESP32 UART1 17/16"
#define ESPNET_OTA_HOSTNAME "espnet-ESP32"
#define ESPNET_CHIP_ID ESPNET_CHIP_ESP32
#define ESPNET_MAX_SOCKS ESPNET_MAX_SOCKS_ESP32
#define ESPNET_RX_SIZE ESPNET_MAX_PAYLOAD
#else
#if defined(ESPNET_BOARD_ZXWIFI)
#define ESPNET_UART_SWAP 0
#elif defined(ESPNET_BOARD_D1MINI)
#define ESPNET_UART_SWAP 1
#elif defined(ARDUINO_ESP8266_GENERIC) || defined(ARDUINO_ESP8266_ESP12)
#define ESPNET_UART_SWAP 0
#else
#define ESPNET_UART_SWAP 1
#endif
#if ESPNET_UART_SWAP
#define ESPNET_UART_TX 15
#define ESPNET_UART_RX 13
#define ESPNET_UART_CTS 3
#define ESPNET_UART_RTS 1
#define ESPNET_UART_LAYOUT_STR "ESP8266 swap D1mini"
#else
#define ESPNET_UART_TX 1
#define ESPNET_UART_RX 3
#define ESPNET_UART_CTS 13
#define ESPNET_UART_RTS 15
#define ESPNET_UART_LAYOUT_STR "ESP8266 native ZX-WiFi"
#endif
#define ESPNET_OTA_HOSTNAME "espnet-8266"
#define ESPNET_CHIP_ID ESPNET_CHIP_ESP8266
#define ESPNET_MAX_SOCKS ESPNET_MAX_SOCKS_ESP8266
#define ESPNET_RX_SIZE ESPNET_MAX_PAYLOAD
#endif

#endif
