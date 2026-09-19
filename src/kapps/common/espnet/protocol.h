#ifndef ESPNET_PROTOCOL_H
#define ESPNET_PROTOCOL_H

/*
 * ESPNET binary UART protocol. Shared by Arduino firmware and NedoOS C.
 * Multi-byte fields are little-endian. sockaddr_in is 15 bytes (api_net).
 *
 * Wire: unescaped SOF, then raw header+payload (zeros and 0xA5 allowed).
 * Empty UART is LSR DR=0 on the host, not a reserved data byte.
 * After SOF the receiver takes exactly header+LEN bytes; no destuff, no
 * mid-frame resync. A lost byte desyncs the frame (drain + next SOF).
 * Optional CRC-8 (cmd bit7 / ESPNET_F_CRC) is implemented on the ESP.
 * The NedoOS host never sets the bit, never checks CRC, and compares
 * cmd as-is (no 0x7F mask). UART RTS/CTS already keeps frames aligned.
 */

#define ESPNET_VER_MAJOR 1
#define ESPNET_VER_MINOR 25

#define ESPNET_SOF 0xA5

#define ESPNET_SOCK_NONE 0xFF
#define ESPNET_MAX_PAYLOAD 2048
#define ESPNET_MAX_SOCKS_ESP32 8
#define ESPNET_MAX_SOCKS_ESP8266 4

#define ESPNET_REQ_CMD 0
#define ESPNET_REQ_SOCK 1
#define ESPNET_REQ_ARG 2
#define ESPNET_REQ_SEQ 3
#define ESPNET_REQ_LEN 4
#define ESPNET_REQ_HDR 6

#define ESPNET_RSP_CMD 0
#define ESPNET_RSP_SOCK 1
#define ESPNET_RSP_STATUS 2
#define ESPNET_RSP_SEQ 3
#define ESPNET_RSP_RESULT 4
#define ESPNET_RSP_LEN 6
#define ESPNET_RSP_HDR 8

#define ESPNET_CMD_SOCKET 0x01
#define ESPNET_CMD_SHUTDOWN 0x02
#define ESPNET_CMD_CONNECT 0x03
#define ESPNET_CMD_ACCEPT 0x04
#define ESPNET_CMD_BIND 0x05
#define ESPNET_CMD_LISTEN 0x06
#define ESPNET_CMD_READ 0x07
#define ESPNET_CMD_WRITE 0x08
#define ESPNET_CMD_GETDNS 0x09
#define ESPNET_CMD_DNSRESOLVE 0x0A
#define ESPNET_CMD_INFO 0x10
#define ESPNET_CMD_WIFI_SCAN 0x11
#define ESPNET_CMD_WIFI_CONNECT 0x12
#define ESPNET_CMD_WIFI_DISC 0x13
#define ESPNET_CMD_WIFI_STATUS 0x14
#define ESPNET_CMD_UART 0x15
#define ESPNET_CMD_ECHO 0x7E
#define ESPNET_CMD_MASK 0x7F
#define ESPNET_F_CRC 0x80
#define ESPNET_CAP_CRC 0x01

#define ESPNET_AF_INET 2
#define ESPNET_SOCK_STREAM 0x01
#define ESPNET_SOCK_ICMP 0x02
#define ESPNET_SOCK_DGRAM 0x03

#define ESPNET_ERR_OK 0
#define ESPNET_ERR_INTR 4
#define ESPNET_ERR_NFILE 23
#define ESPNET_ERR_EAGAIN 35
#define ESPNET_ERR_ALREADY 37
#define ESPNET_ERR_NOTSOCK 38
#define ESPNET_ERR_EMSGSIZE 40
#define ESPNET_ERR_PROTOTYPE 41
#define ESPNET_ERR_AFNOSUPPORT 47
#define ESPNET_ERR_ECONNABORTED 53
#define ESPNET_ERR_CONNRESET 54
#define ESPNET_ERR_NOTCONN 57
#define ESPNET_ERR_HOSTUNREACH 65

#define ESPNET_SOCKADDR_SIZE 15
#define ESPNET_DNS_NAME 64
#define ESPNET_SSID_SIZE 33
#define ESPNET_PASS_SIZE 65
#define ESPNET_WIFI_CONN_SIZE 98
#define ESPNET_SCAN_REC 42
#define ESPNET_INFO_SIZE 53
#define ESPNET_WIFI_STATUS_SIZE 45
#define ESPNET_UART_SIZE 8
#define ESPNET_UART_ARG_GET 0
#define ESPNET_UART_ARG_SET 1
#define ESPNET_UART_BAUD 0
#define ESPNET_UART_FLAGS 4
#define ESPNET_UART_F_PERSIST 0x01

#define ESPNET_INFO_VER_MAJOR 0
#define ESPNET_INFO_VER_MINOR 1
#define ESPNET_INFO_CHIP 2
#define ESPNET_INFO_MAX_SOCKS 3
#define ESPNET_INFO_WIFI 4
#define ESPNET_INFO_RSSI 5
#define ESPNET_INFO_SOCKMASK 6
#define ESPNET_INFO_RESERVED 7
#define ESPNET_INFO_IP 8
#define ESPNET_INFO_MAC 12
#define ESPNET_INFO_SSID 18
#define ESPNET_INFO_HEAP 51

#define ESPNET_WIFI_IDLE 0
#define ESPNET_WIFI_CONNECTING 1
#define ESPNET_WIFI_GOT_IP 2
#define ESPNET_WIFI_AP 3

#define ESPNET_CHIP_ESP32 32
#define ESPNET_CHIP_ESP32C3 3
#define ESPNET_CHIP_ESP8266 86

#define ESPNET_SCAN_SSID 0
#define ESPNET_SCAN_RSSI 33
#define ESPNET_SCAN_ENC 34
#define ESPNET_SCAN_BSSID 35
#define ESPNET_SCAN_CH 41

#define ESPNET_WSTAT_IP 0
#define ESPNET_WSTAT_MAC 4
#define ESPNET_WSTAT_SSID 10
#define ESPNET_WSTAT_RSSI 43
#define ESPNET_WSTAT_FLAGS 44
#define ESPNET_WSTAT_F_CONNECTED 0x01
#define ESPNET_WSTAT_F_HASIP 0x02

#define ESPNET_CONNECT_MS 8000
/* TCP WRITE: wait for sndbuf (3ws send() does not retry short writes). */
#define ESPNET_WRITE_WAIT_MS 3000
/* hostByName: ESP32 default is 5s and often NXDOMAIN/timeout on slow DNS. */
#define ESPNET_DNS_MS 25000
/* STA join + DHCP. Must stay below host ESPNET_SOF_TICKS_LONG (~40s). */
#define ESPNET_WIFI_JOIN_MS 35000
#define ESPNET_SCAN_MAX 24

#endif
