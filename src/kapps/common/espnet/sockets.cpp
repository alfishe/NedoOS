#include <string.h>
#include "sockets.h"
#include "codec.h"
#include "wifi_cmd.h"
#include "host_uart.h"
#include "stats.h"

#if defined(ARDUINO_ARCH_ESP32)
#include <WiFi.h>
#include <lwip/sockets.h>
#else
#include <ESP8266WiFi.h>
#endif
#include <WiFiUdp.h>
#include <WiFiClient.h>
#include <WiFiServer.h>

#define ST_FREE 0
#define ST_TCP_IDLE 1
#define ST_TCP 2
#define ST_UDP 3
#define ST_LISTEN 4

struct Slot {
	uint8_t state;
	uint8_t proto;
	uint16_t local_port;
	WiFiClient tcp;
	WiFiUDP udp;
	WiFiServer *srv;
	uint8_t rx[ESPNET_RX_SIZE];
	uint16_t rx_len;
};

static Slot s_slot[ESPNET_MAX_SOCKS];

static uint16_t sa_port(const uint8_t *sa)
{
	return ((uint16_t)sa[1] << 8) | sa[2];
}

static IPAddress sa_ip(const uint8_t *sa)
{
	return IPAddress(sa[3], sa[4], sa[5], sa[6]);
}

static void sa_fill(uint8_t *sa, IPAddress ip, uint16_t port)
{
	memset(sa, 0, ESPNET_SOCKADDR_SIZE);
	sa[0] = ESPNET_AF_INET;
	sa[1] = (uint8_t)(port >> 8);
	sa[2] = (uint8_t)port;
	sa[3] = ip[0];
	sa[4] = ip[1];
	sa[5] = ip[2];
	sa[6] = ip[3];
}

static void tcp_tune(WiFiClient &c)
{
	c.setNoDelay(true);
	c.setTimeout(50);
#if defined(ARDUINO_ARCH_ESP8266)
	/* seconds: idle, interval, probes. Silent NAT/server drop -> NOTCONN. */
	c.keepAlive(15, 2, 4);
#else
	{
		int yes = 1;
		int idle = 15;
		int intvl = 2;
		int cnt = 4;
		c.setSocketOption(SOL_SOCKET, SO_KEEPALIVE, (char *)&yes, sizeof(yes));
#ifdef TCP_KEEPIDLE
		c.setSocketOption(IPPROTO_TCP, TCP_KEEPIDLE, (char *)&idle, sizeof(idle));
#endif
#ifdef TCP_KEEPINTVL
		c.setSocketOption(IPPROTO_TCP, TCP_KEEPINTVL, (char *)&intvl, sizeof(intvl));
#endif
#ifdef TCP_KEEPCNT
		c.setSocketOption(IPPROTO_TCP, TCP_KEEPCNT, (char *)&cnt, sizeof(cnt));
#endif
	}
#endif
}

static void slot_free(uint8_t i)
{
	Slot *s = &s_slot[i];
	if (s->state == ST_TCP || s->state == ST_TCP_IDLE)
		s->tcp.stop();
	if (s->state == ST_UDP) {
		s->udp.stop();
		/* Arduino WiFiUDP.stop() returns before lwIP recycles the PCB.
		 * Rapid SOCKET/BIND begin(0) then failed with NOTSOCK until a pause. */
		delay(15);
	}
	if (s->srv) {
		s->srv->stop();
		delete s->srv;
		s->srv = 0;
	}
	s->state = ST_FREE;
	s->proto = 0;
	s->local_port = 0;
	s->rx_len = 0;
}

static int find_free(void)
{
	uint8_t i;
	for (i = 0; i < ESPNET_MAX_SOCKS; i++) {
		if (s_slot[i].state == ST_FREE)
			return i;
	}
	return -1;
}

static int sock_ok(uint8_t sock)
{
	return sock < ESPNET_MAX_SOCKS && s_slot[sock].state != ST_FREE;
}

void sockets_begin(void)
{
	uint8_t i;
	for (i = 0; i < ESPNET_MAX_SOCKS; i++) {
		s_slot[i].state = ST_FREE;
		s_slot[i].proto = 0;
		s_slot[i].local_port = 0;
		s_slot[i].srv = 0;
		s_slot[i].rx_len = 0;
	}
}

uint8_t sockets_max(void)
{
	return ESPNET_MAX_SOCKS;
}

uint8_t sockets_mask(void)
{
	uint8_t m = 0;
	uint8_t i;
	for (i = 0; i < ESPNET_MAX_SOCKS; i++) {
		if (s_slot[i].state != ST_FREE)
			m |= (uint8_t)(1 << i);
	}
	return m;
}

void sockets_view(SockView *v, uint8_t *n)
{
	uint8_t i;
	uint8_t maxn = ESPNET_MAX_SOCKS;

	if (!v || !n)
		return;
	for (i = 0; i < maxn; i++) {
		v[i].state = s_slot[i].state;
		v[i].proto = s_slot[i].proto;
		v[i].rx_len = s_slot[i].rx_len;
		v[i].conn = 0;
		v[i].avail = 0;
		if (s_slot[i].state == ST_TCP || s_slot[i].state == ST_TCP_IDLE) {
			v[i].conn = s_slot[i].tcp.connected() ? 1 : 0;
			v[i].avail = (uint16_t)s_slot[i].tcp.available();
		}
	}
	*n = maxn;
}

static void pump_one(uint8_t i)
{
	Slot *s = &s_slot[i];
	int avail;
	int n;
	uint16_t room;

	if (s->state != ST_TCP)
		return;
	if (s->rx_len >= ESPNET_RX_SIZE)
		return;
	/* Drain even after FIN/WiFi drop: leftover bytes stay for CMD_READ. */
	avail = s->tcp.available();
	if (avail <= 0)
		return;
	room = (uint16_t)(ESPNET_RX_SIZE - s->rx_len);
	if (avail > (int)room)
		avail = (int)room;
	n = s->tcp.read(s->rx + s->rx_len, (size_t)avail);
	if (n > 0) {
		s->rx_len = (uint16_t)(s->rx_len + n);
		stats_wifi_rx((uint16_t)n);
	}
}

void sockets_pump(void)
{
	uint8_t i;
	for (i = 0; i < ESPNET_MAX_SOCKS; i++)
		pump_one(i);
}

void sockets_on_link_lost(void)
{
	uint8_t i;
	slog("WIFI_DISC stop sockets");
	for (i = 0; i < ESPNET_MAX_SOCKS; i++) {
		if (s_slot[i].state == ST_TCP)
			pump_one(i);
		if (s_slot[i].state == ST_TCP || s_slot[i].state == ST_TCP_IDLE)
			s_slot[i].tcp.stop();
		if (s_slot[i].state == ST_UDP)
			s_slot[i].udp.stop();
	}
}

void sockets_reap_dead(void)
{
	uint8_t i;
	for (i = 0; i < ESPNET_MAX_SOCKS; i++) {
		if (s_slot[i].state == ST_TCP && !s_slot[i].tcp.connected() &&
		    s_slot[i].rx_len == 0)
			slot_free(i);
	}
}

void sockets_close_all(void)
{
	uint8_t i;
	for (i = 0; i < ESPNET_MAX_SOCKS; i++)
		slot_free(i);
}

void sockets_debug(Stream &s)
{
	uint8_t i;
	s.print(F("heap "));
	s.println(ESP.getFreeHeap());
	s.print(F("socks 0x"));
	s.println(sockets_mask(), HEX);
	for (i = 0; i < ESPNET_MAX_SOCKS; i++) {
		s.print(i);
		s.print(F(" st="));
		s.print(s_slot[i].state);
		s.print(F(" conn="));
		s.print(s_slot[i].tcp.connected() ? 1 : 0);
		s.print(F(" av="));
		s.print(s_slot[i].tcp.available());
		s.print(F(" rx="));
		s.println(s_slot[i].rx_len);
	}
}

static uint16_t rsp_hdr(uint8_t *rsp, uint8_t cmd, uint8_t sock, uint8_t status,
			uint8_t seq, uint16_t result, uint16_t plen)
{
	rsp[ESPNET_RSP_CMD] = cmd;
	rsp[ESPNET_RSP_SOCK] = sock;
	rsp[ESPNET_RSP_STATUS] = status;
	rsp[ESPNET_RSP_SEQ] = seq;
	espnet_put_u16(rsp + ESPNET_RSP_RESULT, result);
	espnet_put_u16(rsp + ESPNET_RSP_LEN, plen);
	return (uint16_t)(ESPNET_RSP_HDR + plen);
}

static uint16_t rsp_err(uint8_t *rsp, uint8_t cmd, uint8_t sock, uint8_t seq, uint8_t err)
{
	return rsp_hdr(rsp, cmd, sock, err, seq, 0, 0);
}

static uint16_t do_socket(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t proto = req[ESPNET_REQ_ARG];
	uint8_t family = ESPNET_AF_INET;
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	int id;

	if (req_n < ESPNET_REQ_HDR)
		return rsp_err(rsp, ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, seq, ESPNET_ERR_INTR);
	if (plen >= 1)
		family = req[ESPNET_REQ_HDR];
	if (family != ESPNET_AF_INET)
		return rsp_err(rsp, ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, seq, ESPNET_ERR_AFNOSUPPORT);
	if (proto == ESPNET_SOCK_ICMP)
		return rsp_err(rsp, ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, seq, ESPNET_ERR_PROTOTYPE);
	if (proto != ESPNET_SOCK_STREAM && proto != ESPNET_SOCK_DGRAM)
		return rsp_err(rsp, ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, seq, ESPNET_ERR_PROTOTYPE);
	id = find_free();
	if (id < 0) {
		sockets_reap_dead();
		id = find_free();
	}
	if (id < 0)
		return rsp_err(rsp, ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, seq, ESPNET_ERR_NFILE);
	s_slot[id].proto = proto;
	s_slot[id].local_port = 0;
	s_slot[id].rx_len = 0;
	if (proto == ESPNET_SOCK_STREAM) {
		s_slot[id].state = ST_TCP_IDLE;
		return rsp_hdr(rsp, ESPNET_CMD_SOCKET, (uint8_t)id, 0, seq, 0, 0);
	}
	/* WIZNET socket() already programs an ephemeral local port. WiFiUDP
	 * needs begin() before beginPacket(); myip / dnsResolve never BIND. */
	if (!s_slot[id].udp.begin(0)) {
		delay(20);
		if (!s_slot[id].udp.begin(0)) {
			s_slot[id].proto = 0;
			return rsp_err(rsp, ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, seq,
				       ESPNET_ERR_ECONNABORTED);
		}
	}
	s_slot[id].state = ST_UDP;
	return rsp_hdr(rsp, ESPNET_CMD_SOCKET, (uint8_t)id, 0, seq, 0, 0);
}

static uint16_t do_shutdown(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	uint8_t arg = req[ESPNET_REQ_ARG];

	if (!sock_ok(sock))
		return rsp_err(rsp, ESPNET_CMD_SHUTDOWN, sock, seq, ESPNET_ERR_NOTSOCK);
	if (arg == 1 && s_slot[sock].state == ST_TCP && s_slot[sock].tcp.connected()) {
#if defined(ARDUINO_ARCH_ESP32)
		if (s_slot[sock].tcp.availableForWrite() < 1024)
			return rsp_err(rsp, ESPNET_CMD_SHUTDOWN, sock, seq, ESPNET_ERR_EAGAIN);
#endif
		s_slot[sock].tcp.flush();
	}
	slot_free(sock);
	return rsp_hdr(rsp, ESPNET_CMD_SHUTDOWN, sock, 0, seq, 0, 0);
}

static uint16_t do_connect(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	const uint8_t *sa;
	uint16_t port;
	IPAddress ip;
	bool ok;

	if (!sock_ok(sock) || s_slot[sock].proto != ESPNET_SOCK_STREAM)
		return rsp_err(rsp, ESPNET_CMD_CONNECT, sock, seq, ESPNET_ERR_NOTSOCK);
	if (s_slot[sock].state == ST_TCP && s_slot[sock].tcp.connected())
		return rsp_err(rsp, ESPNET_CMD_CONNECT, sock, seq, ESPNET_ERR_ALREADY);
	if (plen < ESPNET_SOCKADDR_SIZE || req_n < ESPNET_REQ_HDR + ESPNET_SOCKADDR_SIZE)
		return rsp_err(rsp, ESPNET_CMD_CONNECT, sock, seq, ESPNET_ERR_INTR);
	sa = req + ESPNET_REQ_HDR;
	/* WIZNET copies port+IP and ignores family; browser host_ia.family=0. */
	ip = sa_ip(sa);
	port = sa_port(sa);
	s_slot[sock].tcp.stop();
	s_slot[sock].tcp.setTimeout(ESPNET_CONNECT_MS);
#if defined(ARDUINO_ARCH_ESP32)
	ok = s_slot[sock].tcp.connect(ip, port, ESPNET_CONNECT_MS);
#else
	ok = s_slot[sock].tcp.connect(ip, port);
#endif
	if (!ok) {
		s_slot[sock].tcp.stop();
		sockets_reap_dead();
#if defined(ARDUINO_ARCH_ESP8266)
		WiFiClient::stopAllExcept(&s_slot[sock].tcp);
#endif
		host_debug().print(F("connect fail heap="));
		host_debug().print(ESP.getFreeHeap());
		host_debug().print(F(" wifi="));
		host_debug().println((int)WiFi.status());
		slog("CONN fail sock=%u %u.%u.%u.%u:%u wifi=%d heap=%u",
		     (unsigned)sock,
		     (unsigned)ip[0], (unsigned)ip[1], (unsigned)ip[2], (unsigned)ip[3],
		     (unsigned)port, (int)WiFi.status(), (unsigned)ESP.getFreeHeap());
		if (WiFi.status() == WL_CONNECTED) {
			s_slot[sock].tcp.setTimeout(ESPNET_CONNECT_MS);
#if defined(ARDUINO_ARCH_ESP32)
			ok = s_slot[sock].tcp.connect(ip, port, ESPNET_CONNECT_MS);
#else
			ok = s_slot[sock].tcp.connect(ip, port);
#endif
		}
	}
	if (!ok)
		return rsp_err(rsp, ESPNET_CMD_CONNECT, sock, seq, ESPNET_ERR_HOSTUNREACH);
	tcp_tune(s_slot[sock].tcp);
	s_slot[sock].state = ST_TCP;
	s_slot[sock].rx_len = 0;
	slog("CONN sock=%u %u.%u.%u.%u:%u ok", (unsigned)sock,
	     (unsigned)ip[0], (unsigned)ip[1], (unsigned)ip[2], (unsigned)ip[3],
	     (unsigned)port);
	return rsp_hdr(rsp, ESPNET_CMD_CONNECT, sock, 0, seq, 0, 0);
}

static uint16_t do_bind(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	const uint8_t *sa;

	if (!sock_ok(sock))
		return rsp_err(rsp, ESPNET_CMD_BIND, sock, seq, ESPNET_ERR_NOTSOCK);
	if (plen < ESPNET_SOCKADDR_SIZE || req_n < ESPNET_REQ_HDR + ESPNET_SOCKADDR_SIZE)
		return rsp_err(rsp, ESPNET_CMD_BIND, sock, seq, ESPNET_ERR_INTR);
	sa = req + ESPNET_REQ_HDR;
	s_slot[sock].local_port = sa_port(sa);
	if (s_slot[sock].proto == ESPNET_SOCK_DGRAM) {
		/* SOCKET already called begin(0). stop+begin(0) again races lwIP. */
		if (s_slot[sock].state == ST_UDP && s_slot[sock].local_port == 0)
			return rsp_hdr(rsp, ESPNET_CMD_BIND, sock, 0, seq, 0, 0);
		s_slot[sock].udp.stop();
		if (!s_slot[sock].udp.begin(s_slot[sock].local_port))
			return rsp_err(rsp, ESPNET_CMD_BIND, sock, seq, ESPNET_ERR_ECONNABORTED);
		s_slot[sock].state = ST_UDP;
	}
	return rsp_hdr(rsp, ESPNET_CMD_BIND, sock, 0, seq, 0, 0);
}

static uint16_t do_listen(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	Slot *s;

	if (!sock_ok(sock) || s_slot[sock].proto != ESPNET_SOCK_STREAM)
		return rsp_err(rsp, ESPNET_CMD_LISTEN, sock, seq, ESPNET_ERR_NOTSOCK);
	s = &s_slot[sock];
	if (s->state == ST_TCP && s->tcp.connected())
		return rsp_err(rsp, ESPNET_CMD_LISTEN, sock, seq, ESPNET_ERR_ALREADY);
	if (s->local_port == 0)
		return rsp_err(rsp, ESPNET_CMD_LISTEN, sock, seq, ESPNET_ERR_NOTSOCK);
	if (s->srv) {
		s->srv->stop();
		delete s->srv;
		s->srv = 0;
	}
	s->srv = new WiFiServer(s->local_port);
	if (!s->srv)
		return rsp_err(rsp, ESPNET_CMD_LISTEN, sock, seq, ESPNET_ERR_NFILE);
	s->srv->begin();
	s->state = ST_LISTEN;
	return rsp_hdr(rsp, ESPNET_CMD_LISTEN, sock, 0, seq, 0, 0);
}

static uint16_t do_accept(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	WiFiClient c;
	int id;
	Slot *s;

	if (!sock_ok(sock) || s_slot[sock].state != ST_LISTEN || !s_slot[sock].srv)
		return rsp_err(rsp, ESPNET_CMD_ACCEPT, sock, seq, ESPNET_ERR_NOTSOCK);
	c = s_slot[sock].srv->available();
	if (!c)
		return rsp_err(rsp, ESPNET_CMD_ACCEPT, sock, seq, ESPNET_ERR_EAGAIN);
	id = find_free();
	if (id >= 0) {
		s_slot[id].proto = ESPNET_SOCK_STREAM;
		s_slot[id].state = ST_TCP;
		s_slot[id].tcp = c;
		s_slot[id].tcp.setNoDelay(true);
		tcp_tune(s_slot[id].tcp);
		s_slot[id].rx_len = 0;
		s_slot[id].local_port = 0;
		return rsp_hdr(rsp, ESPNET_CMD_ACCEPT, (uint8_t)id, 0, seq, 0, 0);
	}
	/* No free slot: listen socket becomes the connection (api_net). */
	s = &s_slot[sock];
	s->srv->stop();
	delete s->srv;
	s->srv = 0;
	s->tcp = c;
	tcp_tune(s->tcp);
	s->state = ST_TCP;
	s->rx_len = 0;
	return rsp_hdr(rsp, ESPNET_CMD_ACCEPT, sock, 0, seq, 0, 0);
}

static uint16_t do_read(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	uint16_t maxlen = ESPNET_MAX_PAYLOAD;
	uint16_t n;
	Slot *s;

	if (!sock_ok(sock))
		return rsp_err(rsp, ESPNET_CMD_READ, sock, seq, ESPNET_ERR_NOTSOCK);
	if (plen >= 2 && req_n >= ESPNET_REQ_HDR + 2)
		maxlen = espnet_get_u16(req + ESPNET_REQ_HDR);
	if (maxlen == 0)
		return rsp_err(rsp, ESPNET_CMD_READ, sock, seq, ESPNET_ERR_EAGAIN);
	if (maxlen > ESPNET_MAX_PAYLOAD)
		maxlen = ESPNET_MAX_PAYLOAD;
	s = &s_slot[sock];

	if (s->proto == ESPNET_SOCK_DGRAM) {
		int pkt = s->udp.parsePacket();
		uint8_t *out;
		if (pkt <= 0)
			return rsp_err(rsp, ESPNET_CMD_READ, sock, seq, ESPNET_ERR_EAGAIN);
		n = (uint16_t)pkt;
		if (n > maxlen)
			n = maxlen;
		if (n > (uint16_t)(ESPNET_MAX_PAYLOAD - ESPNET_SOCKADDR_SIZE))
			n = (uint16_t)(ESPNET_MAX_PAYLOAD - ESPNET_SOCKADDR_SIZE);
		out = rsp + ESPNET_RSP_HDR;
		sa_fill(out, s->udp.remoteIP(), s->udp.remotePort());
		n = (uint16_t)s->udp.read(out + ESPNET_SOCKADDR_SIZE, n);
		if (n > 0)
			stats_wifi_rx(n);
		if (pkt > (int)n)
			s->udp.flush();
		if (n == 0)
			return rsp_err(rsp, ESPNET_CMD_READ, sock, seq, ESPNET_ERR_EAGAIN);
		return rsp_hdr(rsp, ESPNET_CMD_READ, sock, 0, seq, n,
			       (uint16_t)(ESPNET_SOCKADDR_SIZE + n));
	}

	pump_one(sock);
	if (s->rx_len == 0) {
		/* WiFi blip: keep the PCB. Host waits with EAGAIN until
		 * lwIP says the TCP is gone (server drop / RTO). */
		if (s->state != ST_TCP || !s->tcp.connected())
			return rsp_err(rsp, ESPNET_CMD_READ, sock, seq, ESPNET_ERR_NOTCONN);
		return rsp_err(rsp, ESPNET_CMD_READ, sock, seq, ESPNET_ERR_EAGAIN);
	}
	n = s->rx_len;
	if (n > maxlen)
		n = maxlen;
	memcpy(rsp + ESPNET_RSP_HDR, s->rx, n);
	s->rx_len = (uint16_t)(s->rx_len - n);
	if (s->rx_len)
		memmove(s->rx, s->rx + n, s->rx_len);
	return rsp_hdr(rsp, ESPNET_CMD_READ, sock, 0, seq, n, n);
}

static uint16_t do_write(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint8_t sock = req[ESPNET_REQ_SOCK];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	const uint8_t *data;
	uint16_t dlen;
	Slot *s;
	size_t w;

	if (!sock_ok(sock))
		return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_NOTSOCK);
	if (req_n < ESPNET_REQ_HDR + plen)
		plen = (uint16_t)(req_n - ESPNET_REQ_HDR);
	s = &s_slot[sock];

	if (s->proto == ESPNET_SOCK_DGRAM) {
		const uint8_t *sa;
		if (plen < ESPNET_SOCKADDR_SIZE)
			return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_EMSGSIZE);
		sa = req + ESPNET_REQ_HDR;
		data = sa + ESPNET_SOCKADDR_SIZE;
		dlen = (uint16_t)(plen - ESPNET_SOCKADDR_SIZE);
		if (!s->udp.beginPacket(sa_ip(sa), sa_port(sa))) {
			if (!s->udp.begin(s->local_port))
				return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_ECONNABORTED);
			s->state = ST_UDP;
			if (!s->udp.beginPacket(sa_ip(sa), sa_port(sa)))
				return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_HOSTUNREACH);
		}
		if (dlen)
			s->udp.write(data, dlen);
		if (!s->udp.endPacket())
			return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_EAGAIN);
		if (dlen == 0)
			return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_EMSGSIZE);
		stats_wifi_tx(dlen);
		return rsp_hdr(rsp, ESPNET_CMD_WRITE, sock, 0, seq, dlen, 0);
	}

	if (s->state != ST_TCP || !s->tcp.connected())
		return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_NOTCONN);
	data = req + ESPNET_REQ_HDR;
	dlen = plen;
	if (dlen == 0)
		return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_EMSGSIZE);
	{
		int room = s->tcp.availableForWrite();
		if (room > 0 && dlen > (uint16_t)room)
			dlen = (uint16_t)room;
	}
	w = s->tcp.write(data, dlen);
	if (w == 0)
		return rsp_err(rsp, ESPNET_CMD_WRITE, sock, seq, ESPNET_ERR_EAGAIN);
	stats_wifi_tx((uint16_t)w);
	return rsp_hdr(rsp, ESPNET_CMD_WRITE, sock, 0, seq, (uint16_t)w, 0);
}

static uint16_t do_getdns(const uint8_t *req, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	IPAddress ip = WiFi.dnsIP();
	uint8_t *p = rsp + ESPNET_RSP_HDR;
	p[0] = ip[0];
	p[1] = ip[1];
	p[2] = ip[2];
	p[3] = ip[3];
	return rsp_hdr(rsp, ESPNET_CMD_GETDNS, ESPNET_SOCK_NONE, 0, seq, 0, 4);
}

static uint16_t do_dns(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);
	char name[ESPNET_DNS_NAME + 1];
	IPAddress ip;
	uint8_t *p;

	if (plen == 0 || req_n < ESPNET_REQ_HDR + 1)
		return rsp_err(rsp, ESPNET_CMD_DNSRESOLVE, ESPNET_SOCK_NONE, seq, ESPNET_ERR_HOSTUNREACH);
	if (plen > ESPNET_DNS_NAME)
		plen = ESPNET_DNS_NAME;
	memset(name, 0, sizeof(name));
	memcpy(name, req + ESPNET_REQ_HDR, plen);
	name[ESPNET_DNS_NAME] = 0;
#if defined(ARDUINO_ARCH_ESP8266)
	if (WiFi.hostByName(name, ip, (uint32_t)ESPNET_DNS_MS) != 1)
#else
	/* ESP32 Arduino 3.x: only 2-arg hostByName; lwIP getaddrinfo blocks
	 * until the resolver finishes. Host SOF wait is 40s. */
	if (WiFi.hostByName(name, ip) != 1)
#endif
		return rsp_err(rsp, ESPNET_CMD_DNSRESOLVE, ESPNET_SOCK_NONE, seq, ESPNET_ERR_HOSTUNREACH);
	p = rsp + ESPNET_RSP_HDR;
	p[0] = ip[0];
	p[1] = ip[1];
	p[2] = ip[2];
	p[3] = ip[3];
	slog("DNS %s -> %u.%u.%u.%u", name,
	     (unsigned)ip[0], (unsigned)ip[1], (unsigned)ip[2], (unsigned)ip[3]);
	return rsp_hdr(rsp, ESPNET_CMD_DNSRESOLVE, ESPNET_SOCK_NONE, 0, seq, 0, 4);
}

static uint16_t do_echo(const uint8_t *req, uint16_t req_n, uint8_t *rsp)
{
	uint8_t seq = req[ESPNET_REQ_SEQ];
	uint16_t plen = espnet_get_u16(req + ESPNET_REQ_LEN);

	if (req_n < ESPNET_REQ_HDR + plen)
		plen = (uint16_t)(req_n - ESPNET_REQ_HDR);
	if (plen > ESPNET_MAX_PAYLOAD)
		plen = ESPNET_MAX_PAYLOAD;
	if (plen)
		memcpy(rsp + ESPNET_RSP_HDR, req + ESPNET_REQ_HDR, plen);
	return rsp_hdr(rsp, ESPNET_CMD_ECHO, req[ESPNET_REQ_SOCK], 0, seq, plen, plen);
}

uint16_t sockets_handle(const uint8_t *req, uint16_t req_n, uint8_t *rsp, uint16_t rsp_cap)
{
	uint8_t cmd;
	uint8_t seq;
	(void)rsp_cap;
	if (req_n < ESPNET_REQ_HDR)
		return 0;
	cmd = (uint8_t)(req[ESPNET_REQ_CMD] & ESPNET_CMD_MASK);
	seq = req[ESPNET_REQ_SEQ];
	switch (cmd) {
	case ESPNET_CMD_SOCKET:
		return do_socket(req, req_n, rsp);
	case ESPNET_CMD_SHUTDOWN:
		return do_shutdown(req, rsp);
	case ESPNET_CMD_CONNECT:
		return do_connect(req, req_n, rsp);
	case ESPNET_CMD_ACCEPT:
		return do_accept(req, rsp);
	case ESPNET_CMD_BIND:
		return do_bind(req, req_n, rsp);
	case ESPNET_CMD_LISTEN:
		return do_listen(req, rsp);
	case ESPNET_CMD_READ:
		return do_read(req, req_n, rsp);
	case ESPNET_CMD_WRITE:
		return do_write(req, req_n, rsp);
	case ESPNET_CMD_GETDNS:
		return do_getdns(req, rsp);
	case ESPNET_CMD_DNSRESOLVE:
		return do_dns(req, req_n, rsp);
	case ESPNET_CMD_ECHO:
		return do_echo(req, req_n, rsp);
	default:
		return rsp_err(rsp, cmd, req[ESPNET_REQ_SOCK], seq, ESPNET_ERR_PROTOTYPE);
	}
}
