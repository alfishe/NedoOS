# ESPNET binary UART protocol (firmware 1.20)

How to flash (Arduino IDE / OTA) and NedoOS includes: README.txt.

ESP32 / ESP32-C3 / ESP8266 act as a W5300-style socket coprocessor over UART.
Host is master: the module never sends unsolicited data (`+IPD` does not exist).
Incoming TCP is buffered on the ESP until `CMD_READ`.

Baud: 115200 8N1. Hardware RTS/CTS is required.

Version is `ESPNET_VER_MAJOR.ESPNET_VER_MINOR` in protocol.h (currently 1.20).
`CMD_INFO` reports the same numbers.


## Pins

Flash / board names: README.txt. Auto-selected via `CONFIG_IDF_TARGET_ESP32C3`
or the Arduino board. ESP8266 wiring cannot be detected: `ESPNET_BOARD_ZXWIFI`
or `ESPNET_BOARD_D1MINI` in pins.h. `AT+GMR` prints `uart: ...`.

  Function     ESP32 WROOM   ESP32-C3 Super Mini   ESP8266 D1 mini   ZX-WiFi ESP-12F
  -----------  ------------  --------------------  ----------------  ---------------
  TX           17            7                     15 (swap)         1  (16550 SIN)
  RX           16            6                     13 (swap)         3  (16550 SOUT)
  CTS          15            5                     3                 13 (16550 RTS)
  RTS          14            4                     1                 15 (16550 CTS)
  USB debug    UART0 1/3     USB CDC               GPIO2 TX          GPIO2, no header

ESP32-C3: board ESP32C3 Dev Module, USB CDC On Boot = Enabled. Do not flash
the WROOM image onto C3 (GPIO 16/17 do not exist).

ZX-WiFi v1.6: flash via X2 (3.3 V TTL), SW1 = ESP. Open X5/X6 while programming
so the 16550 does not fight the adapter; close them for run. Host `comType` 2
(Kondratyev AFC), `divider` 1 at 1.8432 MHz -> 115200.

### RTS/CTS and YIELD (host)

ZX RTS -> ESP CTS: host is ready to take bytes. ESP RTS -> ZX CTS: host must
not overwrite the ESP RX FIFO.

The NedoOS kernel does **not** touch RTS/CTS. `YIELD` is only "give the rest
of this timeslice to the kernel". If RTS is asserted (ESP may TX) and the
task `YIELD`s, incoming UART bytes are lost: nobody is reading the port.

That is why the host copies a frame under `DI` (C: `disable_interrupt()` in
`recv_fill`; asm: `di` in `esp_fill*`). Mid-frame: no `YIELD`.
`YIELD` is used while waiting for SOF / CTS / a command timeout, when it is
safe to leave the UART.

Type 0/3 (no hardware AFC): pulse RTS only while LSR says empty, same as
`getDataEsp`. If more than one byte is already in RBR, LSR keeps DR set
until they are read.


## Wire coding

Each frame is SOF = 0xA5, then the raw header and payload as-is. Bytes 0x00,
0xA5 and 0xFF are legal in the body. The host uses UART LSR DR (or the ATM2
byte-count register) to tell empty from data; a zero from RBR is payload.

After SOF the receiver takes exactly `header + LEN` bytes (plus CRC only if
the request set bit7 - see below). No stuffing, no mid-frame resync on 0xA5.
A lost byte desyncs that frame; the host drains and waits for the next SOF.


## Frames

Multi-byte integers are little-endian. `sockaddr_in` is 15 bytes as in
api_net.txt (family, port big-endian, IPv4, 8 zero bytes). CONNECT ignores
family (WIZNET copies port+IP; browser may send family=0).

Request (6-byte header + payload). End of frame = `len` in the header.

  Off  Sz  Field
  ---  --  -----
  0    1   cmd (bit7 = optional CRC follows payload; default 0)
  1    1   sock (0xFF if unused)
  2    1   arg
  3    1   seq (echoed)
  4    2   payload length
  6    len payload
  6+len    crc8, only if cmd bit7 was set

Response (8-byte header + payload):

  Off  Sz  Field
  ---  --  -----
  0    1   cmd (echo; same CRC bit as the request)
  1    1   sock
  2    1   status (0 or errno from api_net)
  3    1   seq
  4    2   result (byte count; SOCKET id is in sock)
  6    2   payload length
  8    len payload
  8+len    crc8, only if the request had bit7

Max payload 2048. READ/WRITE never return 0 bytes: no data => ERR_EAGAIN (35).

### Optional CRC (off by default)

CRC is optional. NedoOS does **not** use it.

- Default on the wire: cmd bit7 = 0, no CRC byte, no check.
- NedoOS host (`espnet.c`, `_sdk/espnet.asm`) never sets `ESPNET_F_CRC`
  and has no CRC code.
- Firmware still implements CRC if a host sets bit7. `CMD_INFO.caps` bit0
  (`ESPNET_CAP_CRC`) means "ESP can check/emit CRC", not "CRC is on".
- If the request has bit7: CRC-8 is XOR of every header and payload byte
  (not SOF, not the CRC byte). It is not counted in `len`. Opcode is
  `cmd & 0x7F`. The ESP mirrors the flag: CRC request -> CRC reply;
  plain request -> plain reply.

UART RTS/CTS already keeps frames aligned. CRC would be a second pass over
the payload on Z80. A future host can turn it on without a firmware change.


## Commands

  cmd   Name          Request payload      Notes
  ----  ------------  -------------------  -----
  0x01  SOCKET        family (1)           arg = proto. ICMP => ERR_PROTOTYPE.
                                           UDP: WiFiUDP.begin(0) (WIZNET-style
                                           ephemeral port; sendto without BIND)
  0x02  SHUTDOWN      empty                arg 0 = now, 1 = if TX empty.
                                           sock 0xFF = close all (ZX reboot)
  0x03  CONNECT       sockaddr_in 15       blocking on ESP ~8s; family ignored
  0x04  ACCEPT        empty                new sock or EAGAIN
  0x05  BIND          sockaddr_in 15       UDP: skip if already begin(0) and port 0
  0x06  LISTEN        empty                frees any other slot already bound
                                           to this port (stale after ZX reboot)
  0x07  READ          u16 maxlen           TCP: data. UDP: 15+data
  0x08  WRITE         TCP: data            UDP: 15+data. TCP waits up to
                                           ESPNET_WRITE_WAIT_MS for sndbuf
                                           (WIZNET-style full send)
  0x09  GETDNS        empty                4-byte IP
  0x0A  DNSRESOLVE    hostname pad 64      4-byte IP (ESP hostByName ESPNET_DNS_MS
                                           25s; host SOF wait ~40s)
  0x10  INFO          empty                53-byte status (AT+GMR analog)
  0x11  WIFI_SCAN     empty                N x 42-byte AP records
  0x12  WIFI_CONNECT  ssid[33]+pass[65]    stored in NVS, used after reset
  0x13  WIFI_DISC     empty                drops link, keeps saved AP
  0x14  WIFI_STATUS   empty                45 bytes
  0x15  UART          GET empty / SET 8    ZX UART baud; see below
  0x7E  ECHO          any                  loopback

Sockets: 8 on ESP32/C3, 4 on ESP8266. `CMD_INFO.max_socks` reports the limit.
Ids are 0..n-1. Negative / `status != 0` is an error.

ICMP is not implemented (not a W5300 raw socket on ESP).


## INFO payload (53 bytes)

  Off  Sz  Field
  ---  --  -----
  0    1   ver_major
  1    1   ver_minor
  2    1   chip: 32 = ESP32, 3 = ESP32-C3, 86 = ESP8266
  3    1   max_socks
  4    1   wifi_status
  5    1   rssi (signed)
  6    1   sock_mask
  7    1   caps: bit0 = ESPNET_CAP_CRC (firmware can do CRC; host still off)
  8    4   ip
  12   6   mac
  18   33  ssid
  51   2   free_heap u16


## UART baud (cmd 0x15)

There is no `AT+UART` on the ZX wire. `CMD_UART` is the host equivalent.

Request `arg`: 0 = GET (empty payload), 1 = SET (8-byte payload).

  Off  Sz  Field
  ---  --  -----
  0    4   baud, little-endian
  4    1   flags: bit0 persist to flash
  5    3   reserved 0

Allowed baud: 9600, 19200, 38400, 57600, 115200. Other values => EMSGSIZE.

SET reply is still at the old baud. After TX the ESP waits 50 ms and calls
`updateBaudRate`. The host (`OS_ESPUART`) waits, then `uart_init` to match.
`enet` COM page Enter does this and writes `espcom.ini` `divider`.

Persist stores baud in NVS (ESP32) / EEPROM (ESP8266). Boot uses the saved
value, or 115200 if unset. USB debug stays 115200. Recovery if ZX and ESP
disagree: USB `AT+UART=115200`, then set `divider = 1` on the host.


## Arduino IDE 2 / OTA

Board list, pins.h, Upload and ArduinoOTA: README.txt.

USB Serial Monitor understands `AT+GMR`, `AT+STATUS`, `AT+SOCKS`,
`AT+UART`, `AT+UART=115200`, `AT+WEB`, `AT+HELP`.
Do not send AT text on the ZX UART.

After STA has an IP, ArduinoOTA starts. HTTP dashboard is off until USB
`AT+WEB`. mDNS hostname (pins.h): `espnet-ESP32` / `espnet-C3` / `espnet-8266`.
OTA password: `espnet`. While OTA runs, ZX UART/TCP are paused.


## WiFi persist

On boot: `WiFi.begin()` with the last AP from NVS (ESP32) / flash (ESP8266),
`setAutoReconnect(true)`. Connect from the host saves the AP. Disconnect
does not erase it.

Do not call `WiFi.reconnect()` from the poll loop: that drops every TCP
socket (OTA, gopher) and fights the SDK.

ESP8266 PHY country RU, channels 1-13 (US default is 1-11; many RU/EU APs
sit on 12/13). WIFI_SCAN temporarily stops STA so a missing saved AP does
not make `scanNetworks` return 0. ESP8266 CONNECT uses channel+BSSID from
the last scan when the SSID matches.


## Firmware 1.20 - stay up, pipelined READ

The module must not reboot or drop WiFi because the Spectrum is idle, writing
a file, or slow to take bytes. Overnight with the PC on is a normal case.

TCP prefetch. Each socket keeps at most ESPNET_MAX_PAYLOAD (2048) bytes
pulled from lwIP. The rest stays in the TCP stack; the window throttles the
server. The host being slow must not fill ESP RAM.

CTS / disk wait. Host UART TX waits on `availableForWrite()` and calls
`yield()` (ESP8266 also feeds the WDT). A long RTS-off while the ZX writes a
file does not reset the chip. While sending a reply, lwIP is pumped every
256 bytes so ACKs still run. Firmware TX writes 64-byte bursts.

WiFi drop. SDK auto-reconnect if an SSID is saved and the host did not send
WIFI_DISC. TCP sockets are not stopped on a radio blip: lwIP keeps the PCB.
If the ESP gets the same IP back and the server did not time out, traffic
continues. The host sees EAGAIN until then. If lwIP later aborts (RTO, RST,
FIN, keepalive), READ/WRITE return NOTCONN and the host opens a new CONNECT.
Explicit WIFI_DISC does stop sockets.

Keepalive / zombie. A silent NAT or server drop leaves TCP ESTABLISHED with
no data - the same state as AT-Firmware after a half-read `+IPD`, when only
`AT+RST` helped. Firmware sets TCP keepalive (15 s idle, 2 s x 4 probes) and
`setNoDelay(true)`. After keepalive fails, `connected()` becomes false and
the host gets NOTCONN instead of eternal EAGAIN. A failed CONNECT while WiFi
is up reaps dead slots and retries once (ESP8266 also `stopAllExcept`).
USB `AT+STATUS` / `AT+SOCKS` prints heap and per-slot `st/conn/av/rx`.
`connect fail heap=...` is logged on USB when CONNECT fails.

Host UART. `recv_rsp` waits until the command deadline even after SOF (a CTS
gap mid-frame used to abort the reply). A timeout drains leftover bytes so
the next command is not desynced. Mid-frame it does not YIELD (see RTS/CTS
above). `OS_ESPREAD` sends the next READ before returning so the ESP can TX
while the ZX writes the disk.

UDP. SOCKET already calls `WiFiUDP.begin(0)`. BIND to port 0 is a no-op
(stop+begin(0) again races lwIP). After UDP stop, firmware delays ~15 ms
before the PCB is reusable.

READ errors

  status          meaning
  --------------  -----
  0               payload, result = byte count
  EAGAIN (35)     TCP PCB still up, no data yet (WiFi may be reconnecting;
                  server may answer in 1 s or 10 s)
  NOTCONN (57)    TCP closed (server drop / RTO / keepalive / user disc);
                  drain leftover first
  HOSTUNREACH (65) new CONNECT/DNS while WiFi is down

EAGAIN is valid for as long as lwIP still has the TCP connection, including
while the radio is down. It is not returned after the PCB is gone.

WRITE: non-blocking. Full send buffer, no window, or WiFi currently down
with TCP still alive -> EAGAIN, not a stall. Partial `result` is success;
the host may write the rest.

Connect once from `enet` so NVS has the AP.
