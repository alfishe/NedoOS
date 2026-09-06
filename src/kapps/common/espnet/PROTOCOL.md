# ESPNET binary UART protocol

How to flash (Arduino IDE / OTA) and NedoOS includes: README.txt.

ESP32 / ESP8266 act as a W5300-style socket coprocessor over UART.
Host is master: the module never sends unsolicited data (`+IPD` does not exist).
Incoming TCP is buffered on the ESP until `CMD_READ`.

Baud: **115200 8N1**. Hardware RTS/CTS is required.

## Pins

ESP32-WROOM (D1 mini), UART1 to ZX, UART0 = USB debug:

| Function | GPIO |
|----------|------|
| TX | 17 |
| RX | 16 |
| CTS | 15 |
| RTS | 14 |
| USB TX/RX | 1 / 3 |

ESP32-C3 Super Mini (ESP-AT UART1, same as stock AT-Firmware on ATM-COM):

| Function | GPIO |
|----------|------|
| TX | 7 |
| RX | 6 |
| CTS | 5 |
| RTS | 4 |
| USB CDC | Serial |

Board **ESP32C3 Dev Module**, USB CDC On Boot = Enabled. Do not flash the
WROOM image onto C3: GPIO 16/17 do not exist. Auto-selected via
`CONFIG_IDF_TARGET_ESP32C3`.

ESP8266 has two host UART layouts (same chip, different wiring). Auto: Arduino
board **Generic ESP8266 Module** / ESP-12 -> ZX-WiFi native; **LOLIN D1 mini**
and others -> swap. Override in `pins.h`: `ESPNET_BOARD_ZXWIFI` or
`ESPNET_BOARD_D1MINI`. `AT+GMR` prints `uart: ...`.

ESP8266 D1 mini / WROOM-02, UART0 swapped (ESP-AT):

| Function | GPIO |
|----------|------|
| TX | 15 |
| RX | 13 |
| CTS | 3 |
| RTS | 1 |

After swap, USB UART pins become RTS/CTS. Debug log is UART1 TX on GPIO2.

ESP8266 ZX-WiFi v1.6 (ESP-12F + TL16C550), native UART0, **no swap**:

| Function | GPIO | 16550 |
|----------|------|-------|
| TX | 1 (TXD) | SIN via R10 47 ohm |
| RX | 3 (RXD) | SOUT via R11 470 ohm |
| RTS | 15 | CTS via R9 47 ohm |
| CTS | 13 | RTS via R8 470 ohm |

Flash via header X2 (3.3 V TTL). SW1 = ESP. Open X5/X6 while programming so
the 16550 does not fight the adapter; close them for run. Host `comType` 2
(Kondratyev AFC), divider 1 at 1.8432 MHz -> 115200. GPIO2 debug has no header.

ZX RTS -> ESP CTS: Spectrum deasserts RTS on `YIELD`; ESP stops TX, frame is not lost.
ESP RTS -> ZX CTS: host must not overwrite the ESP RX FIFO.

## Wire coding

Each frame is **SOF = 0xA5**, then the raw header and payload as-is. Bytes `0x00`,
`0xA5` and `0xFF` are legal in the body. The host uses UART **LSR DR** (or the
ATM2 byte-count register) to tell empty from data; a zero from RBR is payload.

After SOF the receiver takes **exactly** `header + LEN` bytes (plus CRC if the
flag is set). There is no stuffing and no mid-frame resync on `0xA5`. A lost
byte desyncs that frame; the host drains and waits for the next SOF.

On type 0/3, pulse RTS only while LSR says empty, same as `getDataEsp`. If more
than one byte is already in RBR, LSR keeps DR set until they are read.

## Frames

Multi-byte integers are **little-endian**. `sockaddr_in` is 15 bytes as in `api_net.txt`
(family, port big-endian, IPv4, 8 zero bytes).

Request (6-byte header + payload). End of frame = `len` in the header.

| Offset | Size | Field |
|--------|------|--------|
| 0 | 1 | cmd (`bit7` = CRC follows payload, see below) |
| 1 | 1 | sock (`0xFF` if unused) |
| 2 | 1 | arg |
| 3 | 1 | seq (echoed) |
| 4 | 2 | payload length |
| 6 | len | payload |
| 6+len | 0 or 1 | crc8 if `cmd & 0x80` |

Response (8-byte header + payload):

| Offset | Size | Field |
|--------|------|--------|
| 0 | 1 | cmd (echo, same CRC bit as request) |
| 1 | 1 | sock |
| 2 | 1 | status (`0` or errno from api_net) |
| 3 | 1 | seq |
| 4 | 2 | result (byte count; SOCKET id is in `sock`) |
| 6 | 2 | payload length |
| 8 | len | payload |
| 8+len | 0 or 1 | crc8 if `cmd & 0x80` |

Max payload **2048**. READ/WRITE never return 0 bytes: no data => `ERR_EAGAIN` (35).

### Optional CRC

Firmware still implements this. `CMD_INFO.caps` bit0 (`ESPNET_CAP_CRC`) means
the ESP will check/emit CRC if the host sets `cmd` bit7 (`ESPNET_F_CRC`).

CRC-8 is XOR of every header and payload byte (not SOF, not the CRC byte
itself). It is **not** counted in `len`. Opcode is `cmd & 0x7F`. The ESP
mirrors the request flag: a CRC request gets a CRC reply; a plain request
gets a plain reply.

The NedoOS IAR driver (`espnet.c`) never sets bit7 and has no CRC code.
UART flow control already keeps frames aligned; CRC would be a second pass
over the payload on Z80. A future host can still turn it on without a
firmware change.

## Commands

| cmd | Name | Request payload | Notes |
|-----|------|-----------------|-------|
| 0x01 | SOCKET | family (1) | `arg` = proto. ICMP => `ERR_PROTOTYPE` |
| 0x02 | SHUTDOWN | empty | `arg` 0 = now, 1 = if TX empty |
| 0x03 | CONNECT | sockaddr_in 15 | blocking on ESP ~8s |
| 0x04 | ACCEPT | empty | new sock or EAGAIN |
| 0x05 | BIND | sockaddr_in 15 | |
| 0x06 | LISTEN | empty | |
| 0x07 | READ | u16 maxlen | TCP: data. UDP: 15+data |
| 0x08 | WRITE | TCP: data. UDP: 15+data | |
| 0x09 | GETDNS | empty | 4-byte IP |
| 0x0A | DNSRESOLVE | hostname padded to 64 | 4-byte IP (`hostByName` waits `ESPNET_DNS_MS` 25s; host SOF wait 40s) |
| 0x10 | INFO | empty | 53-byte status (AT+GMR analog) |
| 0x11 | WIFI_SCAN | empty | N x 42-byte AP records |
| 0x12 | WIFI_CONNECT | ssid[33]+pass[65] | stored in NVS, used after reset |
| 0x13 | WIFI_DISC | empty | drops link, keeps saved AP |
| 0x14 | WIFI_STATUS | empty | 45 bytes |
| 0x15 | UART | GET empty / SET 8 bytes | ZX UART baud; see below |
| 0x7E | ECHO | any | loopback |

Sockets: **8** on ESP32, **4** on ESP8266. `CMD_INFO.max_socks` reports the limit.
Ids are 0..n-1. Negative / `status != 0` is an error.

ICMP is not implemented (not a W5300 raw socket on ESP).

## INFO payload (53 bytes)

ver_major, ver_minor, chip (32 or 86), max_socks, wifi_status, rssi,
sock_mask, caps (`bit0` = optional CRC on the ESP), ip[4], mac[6], ssid[33],
free_heap u16. The NedoOS host does not enable CRC; see Optional CRC above.

## UART baud (cmd 0x15)

There is no `AT+UART` on the ZX wire. `CMD_UART` is the host equivalent.

Request `arg`: 0 = GET (empty payload), 1 = SET (8-byte payload).

SET/GET payload:

| Offset | Size | Field |
|--------|------|--------|
| 0 | 4 | baud, little-endian |
| 4 | 1 | flags: `bit0` persist to flash |
| 5 | 3 | reserved 0 |

Allowed baud: 9600, 19200, 38400, 57600, 115200. Other values => `EMSGSIZE`.

SET reply is still at the **old** baud. After TX the ESP waits 50 ms and calls
`updateBaudRate`. The host (`OS_ESPUART`) waits, then `uart_init` to match.
`enet` COM page Enter does this and writes `espcom.ini` `divider`.

Persist stores baud in NVS (ESP32) / EEPROM (ESP8266). Boot uses the saved
value, or 115200 if unset. USB debug stays 115200. Recovery if ZX and ESP
disagree: USB `AT+UART=115200`, then set `divider = 1` on the host.

## Arduino IDE 2 / OTA

Board list, `pins.h`, Upload and ArduinoOTA: README.txt.

USB Serial Monitor understands `AT+GMR`, `AT+STATUS`, `AT+SOCKS`,
`AT+UART`, `AT+UART=115200`, `AT+WEB`, `AT+HELP`.
Do not send AT text on the ZX UART. HTTP dashboard is off until `AT+WEB`.

## WiFi persist

On boot the firmware calls `WiFi.begin()` with the last AP from NVS (ESP32) / flash
(ESP8266) and `setAutoReconnect(true)`. Connect from the host saves the AP.
Disconnect does not erase it.

## Firmware (v1.7) -- 2048-byte payload, pipelined READ, stay up

The module must not reboot or drop WiFi because the Spectrum is idle, writing a
file, or slow to take bytes. Overnight with the PC on is a normal case.

**TCP prefetch.** Each socket keeps at most `ESPNET_MAX_PAYLOAD` (2048) bytes
pulled from lwIP. The rest stays in the TCP stack; the window throttles the
server. The host being slow must not fill ESP RAM.

**CTS / disk wait.** Host UART TX waits on `availableForWrite()` and calls
`yield()` (ESP8266 also feeds the WDT). A long RTS-off while the ZX writes a
file does not reset the chip. While sending a reply, lwIP is pumped every 256
bytes so ACKs still run.

**WiFi drop.** Auto-reconnect every ~8 s if an SSID is saved and the host did
not send `WIFI_DISC`. TCP sockets are **not** stopped on a radio blip: lwIP
keeps the PCB. If the ESP gets the same IP back and the server did not time
out, traffic continues. The host sees `EAGAIN` until then. If lwIP later
aborts (RTO, RST, FIN, keepalive), `READ`/`WRITE` return `NOTCONN` and the
host opens a new `CONNECT`. Explicit `WIFI_DISC` does stop sockets.

**Keepalive / zombie.** A silent NAT or server drop leaves TCP ESTABLISHED with
no data -- the same state as AT-Firmware after a half-read `+IPD`, when only
`AT+RST` helped. Firmware sets TCP keepalive (15 s idle, 2 s x 4 probes). After
that, `connected()` becomes false and the host gets `NOTCONN` instead of
eternal `EAGAIN`. A failed `CONNECT` while WiFi is up reaps dead slots and
retries once (ESP8266 also `stopAllExcept`). USB `AT+STATUS` / `AT+SOCKS`
prints heap and per-slot `st/conn/av/rx`. `connect fail heap=...` is logged on
USB when `CONNECT` fails.

**Host UART.** `recv_rsp` waits until the command deadline even after SOF (a
CTS gap mid-frame used to abort the reply). A timeout drains leftover bytes
so the next command is not desynced. Mid-frame it does **not** `YIELD` (that
dropped RTS and capped the rate at ~2 KB/s). `OS_ESPREAD` sends the next READ
before returning so the ESP can TX while the ZX writes the disk. Firmware TX
writes 64-byte bursts and pumps lwIP every 256 bytes.

**READ errors**

| status | meaning |
|--------|---------|
| 0 | payload, `result` = byte count |
| EAGAIN (35) | TCP PCB still up, no data yet (WiFi may be reconnecting; server may answer in 1 s or 10 s) |
| NOTCONN (57) | TCP closed (server drop / RTO / keepalive / user disc); drain leftover first |
| HOSTUNREACH (65) | new CONNECT/DNS while WiFi is down |

EAGAIN is valid for as long as lwIP still has the TCP connection, including
while the radio is down. It is not returned after the PCB is gone.

**WRITE:** non-blocking. Full send buffer, no window, or WiFi currently down
with TCP still alive -> EAGAIN, not a stall. Partial `result` is success;
the host may write the rest.

Reflash the sketch after this change. Connect once from `enet` so NVS has the AP.
