#include "host_uart.h"
#include "stats.h"

#if defined(ARDUINO_ARCH_ESP32)
#include "driver/uart.h"
#include <Preferences.h>
static HardwareSerial HostSerial(ESPNET_UART_NUM);
static Preferences s_prefs;
#else
#include <esp8266_peri.h>
#include <EEPROM.h>
#define ESPNET_EE_MAGIC 0x4E455431UL
#endif

static uint32_t s_baud = ESPNET_BAUD;
static uint32_t s_saved = ESPNET_BAUD;
static uint32_t s_pending;
static uint8_t s_have_pending;

int host_uart_baud_ok(uint32_t baud)
{
	return (baud == 9600u || baud == 19200u || baud == 38400u ||
		baud == 57600u || baud == 115200u) ? 1 : 0;
}

uint32_t host_uart_baud(void)
{
	return s_baud;
}

uint8_t host_uart_saved_eq(void)
{
	return (s_saved == s_baud) ? 1 : 0;
}

static uint32_t load_saved_baud(void)
{
	uint32_t baud;
#if defined(ARDUINO_ARCH_ESP32)
	s_prefs.begin("espnet", true);
	baud = s_prefs.getUInt("baud", ESPNET_BAUD);
	s_prefs.end();
#else
	uint32_t magic;
	EEPROM.begin(8);
	EEPROM.get(0, magic);
	EEPROM.get(4, baud);
	EEPROM.end();
	if (magic != ESPNET_EE_MAGIC)
		baud = ESPNET_BAUD;
#endif
	if (!host_uart_baud_ok(baud))
		baud = ESPNET_BAUD;
	return baud;
}

static void store_saved_baud(uint32_t baud)
{
#if defined(ARDUINO_ARCH_ESP32)
	s_prefs.begin("espnet", false);
	s_prefs.putUInt("baud", baud);
	s_prefs.end();
#else
	uint32_t magic = ESPNET_EE_MAGIC;
	EEPROM.begin(8);
	EEPROM.put(0, magic);
	EEPROM.put(4, baud);
	EEPROM.commit();
	EEPROM.end();
#endif
	s_saved = baud;
}

#if !defined(ARDUINO_ARCH_ESP32)
static void esp8266_hw_flow(void)
{
	/* UART0 CONF0 bit15 = TX flow (CTS). CONF1 bit23 = RX flow (RTS).
	 * Older cores named these URTSE/UCTSE; current peri.h does not. */
	USC0(0) |= ((uint32_t)1 << 15);
	{
		uint32_t c1 = USC1(0);

		c1 &= ~((uint32_t)0x7F << 16);
		c1 |= ((uint32_t)64 << 16);
		c1 |= ((uint32_t)1 << 23);
		USC1(0) = c1;
	}
#if !ESPNET_UART_SWAP
	/* Native UART0: GPIO15 = U0RTS, GPIO13 = U0CTS (ZX-WiFi 16550). */
	pinMode(15, FUNCTION_4);
	pinMode(13, FUNCTION_4);
#endif
}
#endif

static void apply_baud(uint32_t baud)
{
	s_baud = baud;
#if defined(ARDUINO_ARCH_ESP32)
	HostSerial.updateBaudRate(baud);
	uart_set_pin((uart_port_t)ESPNET_UART_NUM, ESPNET_UART_TX, ESPNET_UART_RX,
		     ESPNET_UART_RTS, ESPNET_UART_CTS);
	uart_set_hw_flow_ctrl((uart_port_t)ESPNET_UART_NUM, UART_HW_FLOWCTRL_CTS_RTS, 122);
#else
	Serial.flush();
	Serial.updateBaudRate(baud);
	esp8266_hw_flow();
#endif
}

int host_uart_request_baud(uint32_t baud, int persist)
{
	if (!host_uart_baud_ok(baud))
		return 0;
	if (persist)
		store_saved_baud(baud);
	if (baud != s_baud) {
		s_pending = baud;
		s_have_pending = 1;
	}
	return 1;
}

void host_uart_apply_pending(void)
{
	if (!s_have_pending)
		return;
	s_have_pending = 0;
	delay(50);
	apply_baud(s_pending);
}

int host_uart_set_baud_now(uint32_t baud, int persist)
{
	if (!host_uart_baud_ok(baud))
		return 0;
	if (persist)
		store_saved_baud(baud);
	if (baud != s_baud)
		apply_baud(baud);
	return 1;
}

void host_uart_begin(void)
{
	s_saved = load_saved_baud();
	s_baud = s_saved;
#if defined(ARDUINO_ARCH_ESP32)
	HostSerial.setRxBufferSize(4096);
	HostSerial.setTxBufferSize(1024);
	HostSerial.begin(s_baud, SERIAL_8N1, ESPNET_UART_RX, ESPNET_UART_TX);
	uart_set_pin((uart_port_t)ESPNET_UART_NUM, ESPNET_UART_TX, ESPNET_UART_RX,
		     ESPNET_UART_RTS, ESPNET_UART_CTS);
	uart_set_hw_flow_ctrl((uart_port_t)ESPNET_UART_NUM, UART_HW_FLOWCTRL_CTS_RTS, 122);
	Serial.begin(ESPNET_BAUD);
#else
	Serial.setRxBufferSize(4096);
	Serial.begin(s_baud);
#if ESPNET_UART_SWAP
	Serial.swap();
	/* TX=GPIO15 RX=GPIO13 RTS=GPIO1 CTS=GPIO3 (ESP-AT / D1 mini). */
#else
	/* Native UART0: TX=GPIO1 RX=GPIO3 RTS=GPIO15 CTS=GPIO13 (ZX-WiFi). */
#endif
	esp8266_hw_flow();
	Serial1.begin(ESPNET_BAUD);
#endif
}

void host_uart_idle(void)
{
	yield();
#if defined(ARDUINO_ARCH_ESP8266)
	ESP.wdtFeed();
#endif
}

int host_uart_available(void)
{
#if defined(ARDUINO_ARCH_ESP32)
	return HostSerial.available();
#else
	return Serial.available();
#endif
}

int host_uart_read(void)
{
	int b;
#if defined(ARDUINO_ARCH_ESP32)
	b = HostSerial.read();
#else
	b = Serial.read();
#endif
	if (b >= 0)
		stats_uart_rx(1);
	return b;
}

void host_uart_write(uint8_t b)
{
	host_uart_write_buf(&b, 1);
}

void host_uart_write_buf(const uint8_t *p, uint16_t n)
{
	while (n) {
		int room;
#if defined(ARDUINO_ARCH_ESP32)
		room = HostSerial.availableForWrite();
		if (room > 0) {
			if ((uint16_t)room > n)
				room = (int)n;
			HostSerial.write(p, (size_t)room);
			stats_uart_tx((uint16_t)room);
			p += room;
			n = (uint16_t)(n - room);
			continue;
		}
#else
		room = Serial.availableForWrite();
		if (room > 0) {
			if ((uint16_t)room > n)
				room = (int)n;
			Serial.write(p, (size_t)room);
			stats_uart_tx((uint16_t)room);
			p += room;
			n = (uint16_t)(n - room);
			continue;
		}
#endif
		stats_tx_wait_tick();
		host_uart_idle();
	}
}

Stream &host_debug(void)
{
#if defined(ARDUINO_ARCH_ESP32)
	return Serial;
#else
	return Serial1;
#endif
}
