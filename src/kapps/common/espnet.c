/*
 * ESPNET binary UART client (OS_ESP*).
 * Include only in apps talking to ESPNET firmware.
 * AT-Firmware apps use esp-com.c + network.c / esp-com2.c instead.
 * Итого для нового TCP-приложения достаточно одной строки ESPNET_CLIENT_ONLY 1, как у zxdb.
 * ESPNET_UDP 1 ? только если сами шлёте датаграммы.
 */
#include <string.h>
#include <oscalls.h>
#include <intrz80.h>
#include <espnet.h>

#ifndef ESPNET_HOST_MAX
#define ESPNET_HOST_MAX ESPNET_MAX_PAYLOAD
#endif
#ifdef ESPNET_CLIENT_ONLY
#ifndef ESPNET_UDP
#define ESPNET_NO_UDP
#endif
#endif
/* READ/WRITE/SCAN/ECHO payload is the caller's buffer. g_rsp holds the 8-byte
 * reply header plus small bodies (DNS 4, INFO 53, WIFI_STATUS 45). */
#ifndef ESPNET_RSP_MAX
#define ESPNET_RSP_MAX 256
#endif

extern void uart_write(unsigned char data);
extern void uart_setrts(unsigned char mode);
extern void uart_init(unsigned char divisor);
extern void loadEspConfig(void);
extern unsigned long uartBench(void);
extern char portInput(char port);

extern unsigned int comType;
extern unsigned int divider;
extern unsigned int MSR;
extern unsigned int MCR;
extern unsigned int LSR;
extern unsigned int RBR_THR;
extern unsigned long factor, timerok;

#define ESPNET_FAIL(e) ((unsigned int)(0xFF00 | (unsigned char)(e)))

#ifdef ESPNET_EXT_BUFFERS
extern unsigned char g_req[ESPNET_REQ_HDR];
extern unsigned char g_rsp[ESPNET_RSP_HDR + ESPNET_RSP_MAX];
#else
static unsigned char g_req[ESPNET_REQ_HDR];
static unsigned char g_rsp[ESPNET_RSP_HDR + ESPNET_RSP_MAX];
#endif
static unsigned char g_seq;
static unsigned char g_inited;
static unsigned char g_armed; /* 1 = next OS_ESPREAD already sent; ESP may be TXing */

/* Little-endian helpers: protocol integers are always LE on the wire. */
static void put_u16(unsigned char *p, unsigned int v)
{
	p[0] = (unsigned char)v;
	p[1] = (unsigned char)(v >> 8);
}

static unsigned int get_u16(unsigned char *p)
{
	return (unsigned int)p[0] | ((unsigned int)p[1] << 8);
}

#ifndef ESPNET_CLIENT_ONLY
static void put_u32(unsigned char *p, unsigned long v)
{
	p[0] = (unsigned char)v;
	p[1] = (unsigned char)(v >> 8);
	p[2] = (unsigned char)(v >> 16);
	p[3] = (unsigned char)(v >> 24);
}

static unsigned long get_u32(unsigned char *p)
{
	unsigned long v;
	v = (unsigned long)p[0];
	v |= ((unsigned long)p[1] << 8);
	v |= ((unsigned long)p[2] << 16);
	v |= ((unsigned long)p[3] << 24);
	return v;
}
#endif

/* Wait until ESP RTS is high (ZX CTS). ESP RX FIFO is 1-2 bytes; without this
 * we overwrite the coprocessor. ATM2 COM and 16550-AFC skip: they have their
 * own flow. Type 0/3 need it. */
static void wait_cts(void)
{
	unsigned int spins;
	unsigned char msr;
	if (comType == 1 || comType == 2)
		return;
	spins = 0;
	for (;;)
	{
		if (comType == 3)
		{
			disable_interrupt();
			output(0xfb, MSR);
			msr = input(0xfa);
			enable_interrupt();
		}
		else
			msr = (unsigned char)input(MSR); // only 0
		if (msr & 0x10)
			return;
		spins++;
		if ((spins & 0x3F) == 0)
		{
			YIELD();
			if (spins > 20000)
				return;
		}
	}
}

/* One wire byte, after CTS. All TX goes through here. */
static void putb(unsigned char b)
{
	wait_cts();
	uart_write(b);
}

/* Frame: SOF, then raw header+payload (0x00 / 0xA5 are data). */
static void send_bytes(unsigned char *raw, unsigned int n)
{
	while (n)
	{
		putb(*raw);
		raw++;
		n--;
	}
}

/* Statics so IAR does not put the copy loop behind IX. */
static unsigned char r_b;
static unsigned char r_uart;
static unsigned char *r_dst;
static unsigned int r_n;
static unsigned int r_left;
static unsigned int r_spin;

/* 1 = r_b holds a UART byte (including 0). 0 = empty: pulse RTS on type 0/3. */
static unsigned char rx_poll(void)
{
	switch (comType)
	{
	case 0:
		if ((input(LSR) & 1) == 0)
		{
			disable_interrupt();
			output(MCR, 2);
			output(MCR, 0);
			enable_interrupt();
			return 0;
		}
		r_b = input(RBR_THR);
		return 1;
	case 2:
		if ((input(LSR) & 1) == 0)
			return 0;
		r_b = input(RBR_THR);
		return 1;
	case 1:
		disable_interrupt();
		input(0x55fe);
		if (input(0xc2fe) == 0)
		{
			enable_interrupt();
			return 0;
		}
		input(0x55fe);
		r_uart = input(0x02fe);
		enable_interrupt();
		r_b = r_uart;
		return 1;
	case 3:
		output(0xfb, LSR);
		if ((input(0xfa) & 1) == 0)
		{
			disable_interrupt();
			output(0xfb, MCR);
			output(0xfa, 2);
			output(0xfa, 0);
			enable_interrupt();
			return 0;
		}
		output(0xfb, RBR_THR);
		r_b = input(0xfa);
		return 1;
	}
	return 0;
}

/* time() is 50 Hz. READ SOF is milliseconds; DNS/CONNECT/SCAN need tens of seconds. */
#define ESPNET_SOF_TICKS 500
#define ESPNET_SOF_TICKS_LONG 3000 /* 60s: DNS on ESP can take ESPNET_DNS_MS (25s) + retries */
static unsigned int sof_ticks = ESPNET_SOF_TICKS;

static int recv_sof(void)
{
	long until;
	long last_y;
	long now;
	unsigned char idle;
	unsigned char ct;

	uart_setrts(0);
	r_spin = (unsigned int)factor;
	if (r_spin == 0)
		r_spin = 20000;
	until = time() + (long)sof_ticks;
	last_y = time();
	idle = 0;
	ct = (unsigned char)comType;
	for (;;)
	{
		if (ct == 0)
		{
			if ((input(LSR) & 1) == 0)
			{
				disable_interrupt();
				output(MCR, 2);
				output(MCR, 0);
				enable_interrupt();
				goto sof_idle;
			}
			r_b = (unsigned char)input(RBR_THR);
		}
		else if (ct == 2)
		{
			if ((input(LSR) & 1) == 0)
				goto sof_idle;
			r_b = (unsigned char)input(RBR_THR);
		}
		else if (rx_poll() == 0)
			goto sof_idle;
		if (r_b == ESPNET_SOF)
			return 0;
		continue;
	sof_idle:
		idle++;
		if (idle != 0)
			continue;
		now = time();
		if (now != last_y)
		{
			last_y = now;
			YIELD();
		}
		if ((long)(until - now) < 0)
			return -1;
	}
}

/*
 * Raw copy of n bytes to dst. Timeout only while LSR is empty; when DR=1
 * skip r_left reload. Loop uses statics, not the args (IAR IX).
 */
static int recv_fill(unsigned char *dst, unsigned int n)
{
	r_dst = dst;
	r_n = n;

	switch (comType)
	{
	case 0:
		disable_interrupt();
		while (r_n)
		{
			r_left = r_spin;
			while ((input(LSR) & 1) == 0)
			{
				r_left--;
				if (r_left == 0)
				{
					enable_interrupt();
					return -1;
				}
				output(MCR, 2);
				output(MCR, 0);
			}
			*r_dst = input(RBR_THR);
			r_dst++;
			r_n--;
		}
		enable_interrupt();
		return 0;
	case 1:
		while (r_n)
		{
			r_left = r_spin;
			for (;;)
			{
				disable_interrupt();
				input(0x55fe);
				if (input(0xc2fe) != 0)
				{
					input(0x55fe);
					r_uart = input(0x02fe);
					enable_interrupt();
					break;
				}
				enable_interrupt();
				r_left--;
				if (r_left == 0)
					return -1;
			}
			*r_dst = r_uart;
			r_dst++;
			r_n--;
		}
		return 0;
	case 2:
		/* AFC: hardware RTS. DR already set after the timed wait;
		 * a second LSR loop under DI never sees it go empty. */
		disable_interrupt();
		while (r_n)
		{
			r_left = r_spin;
			while ((input(LSR) & 1) == 0)
			{
				r_left--;
				if (r_left == 0)
				{
					enable_interrupt();
					return -1;
				}
			}
			*r_dst = input(RBR_THR);
			r_dst++;
			r_n--;
		}
		enable_interrupt();
		return 0;
	case 3:
		disable_interrupt();
		output(0xfb, LSR);
		while (r_n)
		{
			if ((input(0xfa) & 1) == 0)
			{
				r_left = r_spin;
				do
				{
					r_left--;
					if (r_left == 0)
					{
						enable_interrupt();
						return -1;
					}
					output(0xfb, MCR);
					output(0xfa, 2);
					output(0xfa, 0);
					output(0xfb, LSR);
				} while ((input(0xfa) & 1) == 0);
			}
			output(0xfb, RBR_THR);
			*r_dst = input(0xfa);
			r_dst++;
			r_n--;
		}
		enable_interrupt();
	}
	return 0;
}

/* Discard n UART bytes; uses g_rsp body (header already parsed). */
static int recv_skip(unsigned int n)
{
	unsigned int chunk;

	while (n)
	{
		chunk = n;
		if (chunk > ESPNET_RSP_MAX)
			chunk = ESPNET_RSP_MAX;
		if (recv_fill(g_rsp + ESPNET_RSP_HDR, chunk) < 0)
			return -1;
		n -= chunk;
	}
	return 0;
}

static int recv_rsp(void)
{
	unsigned int plen;

	if (recv_sof() < 0)
		return -1;
	if (recv_fill(g_rsp, ESPNET_RSP_HDR) < 0)
		return -1;
	plen = get_u16(g_rsp + ESPNET_RSP_LEN);
	if (plen > ESPNET_RSP_MAX)
		return -1;
	if (plen)
	{
		if (recv_fill(g_rsp + ESPNET_RSP_HDR, plen) < 0)
			return -1;
	}
	return (int)(ESPNET_RSP_HDR + plen);
}

/* Eat leftover UART bytes after a bad/short frame so the next SOF is clean. */
static void rx_drain(void)
{
	unsigned int silent;
	unsigned int spins;

	silent = 0;
	spins = 0;
	uart_setrts(0);
	while (spins < 1000 && silent < 80)
	{
		if (rx_poll() == 0)
			silent++;
		else
			silent = 0;
		spins++;
	}
}

/* SOF + 8-byte header. 0 = cmd/seq match, *plen_out set. Else 0xFFxx. */
static unsigned int recv_hdr(unsigned char cmd, unsigned int *plen_out)
{
	unsigned int plen;

	if (recv_sof() < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	if (recv_fill(g_rsp, ESPNET_RSP_HDR) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	if ((g_rsp[ESPNET_RSP_CMD] & ESPNET_CMD_MASK) != cmd ||
		g_rsp[ESPNET_RSP_SEQ] != g_seq)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	plen = get_u16(g_rsp + ESPNET_RSP_LEN);
	if (plen > ESPNET_HOST_MAX)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	*plen_out = plen;
	return 0;
}

#ifndef ESPNET_CLIENT_ONLY
/* Copy up to dstmax payload bytes into dst; skip the rest of plen. */
static int recv_payload(unsigned char *dst, unsigned int dstmax, unsigned int plen)
{
	unsigned int take;

	take = plen;
	if (take > dstmax)
		take = dstmax;
	if (dst && take)
	{
		if (recv_fill(dst, take) < 0)
			return -1;
	}
	else if (take)
	{
		if (recv_skip(take) < 0)
			return -1;
	}
	if (plen > take && recv_skip(plen - take) < 0)
		return -1;
	return 0;
}

/* Reply for a command already sent. Payload goes to dst, not g_rsp. */
static unsigned int recv_dst(unsigned char cmd, unsigned char *dst, unsigned int dstmax)
{
	unsigned int plen;
	unsigned int r;

	r = recv_hdr(cmd, &plen);
	if (r != 0)
		return r;
	if (g_rsp[ESPNET_RSP_STATUS] != 0)
	{
		if (plen && recv_skip(plen) < 0)
			rx_drain();
		return ESPNET_FAIL(g_rsp[ESPNET_RSP_STATUS]);
	}
	if (recv_payload(dst, dstmax, plen) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	return 0;
}
#endif

/* Header in g_req (6 bytes). Payload is sent from the caller's buffer. */
static void send_cmd2(unsigned char cmd, unsigned char sock, unsigned char arg,
					  unsigned char *p2, unsigned int n2,
					  unsigned char *p3, unsigned int n3)
{
	unsigned int plen;

	plen = n2 + n3;
	g_seq++;
	g_req[ESPNET_REQ_CMD] = cmd;
	g_req[ESPNET_REQ_SOCK] = sock;
	g_req[ESPNET_REQ_ARG] = arg;
	g_req[ESPNET_REQ_SEQ] = g_seq;
	put_u16(g_req + ESPNET_REQ_LEN, plen);
	uart_setrts(0);
	putb(ESPNET_SOF);
	send_bytes(g_req, ESPNET_REQ_HDR);
	if (n2 && p2)
		send_bytes(p2, n2);
	if (n3 && p3)
		send_bytes(p3, n3);
}

#define send_cmd(cmd, sock, arg, payload, plen) \
	send_cmd2((cmd), (sock), (arg), (payload), (plen), 0, 0)

/* OS_ESPREAD pipelines the next READ. Any other cmd must collect that reply
 * first or seq/SOF desync. Payload may be up to HOST_MAX, so do not use
 * recv_rsp (that rejects plen > ESPNET_RSP_MAX). */
static void drop_armed(void)
{
	unsigned int plen;

	if (!g_armed)
		return;
	g_armed = 0;
	if (recv_sof() < 0)
	{
		rx_drain();
		return;
	}
	if (recv_fill(g_rsp, ESPNET_RSP_HDR) < 0)
	{
		rx_drain();
		return;
	}
	plen = get_u16(g_rsp + ESPNET_RSP_LEN);
	if (plen && recv_skip(plen) < 0)
		rx_drain();
}

/* One request/response. 0 = status 0 (payload already in g_rsp).
 * Else 0xFFxx with errno. ticks = OS timer units (~20ms). */
static unsigned int xfer(unsigned char cmd, unsigned char sock, unsigned char arg,
						 unsigned char *payload, unsigned int plen)
{
	int body;

	if (!g_inited)
		return ESPNET_FAIL(ESPNET_ERR_NOTCONN);
	if (plen > ESPNET_HOST_MAX)
		return ESPNET_FAIL(ESPNET_ERR_EMSGSIZE);
	drop_armed();
	if (cmd == ESPNET_CMD_DNSRESOLVE || cmd == ESPNET_CMD_CONNECT ||
		cmd == ESPNET_CMD_WIFI_CONNECT)
		sof_ticks = ESPNET_SOF_TICKS_LONG;
	else
		sof_ticks = ESPNET_SOF_TICKS;
	send_cmd(cmd, sock, arg, payload, plen);
	body = recv_rsp();
	sof_ticks = ESPNET_SOF_TICKS;
	if (body < ESPNET_RSP_HDR)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	if ((g_rsp[ESPNET_RSP_CMD] & ESPNET_CMD_MASK) != cmd || g_rsp[ESPNET_RSP_SEQ] != g_seq)
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	if (g_rsp[ESPNET_RSP_STATUS] != 0)
		return ESPNET_FAIL(g_rsp[ESPNET_RSP_STATUS]);
	return 0;
}

/* Load espcom.ini, program UART, calibrate empty-read spin (factor). */
unsigned int OS_ESPINIT(void)
{
	loadEspConfig();
	uart_init((unsigned char)divider);
	uart_setrts(0);
	//if (factor == 0)
	//	factor = uartBench();
		factor = 65000;
	g_inited = 1;
	g_seq = 0;
	g_armed = 0;
	/* Short settle: first DNS/CONNECT right after UART init often fails. */
	{
		long until = time() + 25L; /* ~0.5s */
		while (time() < until)
			YIELD();
	}
	return 0;
}

/* Alloc a slot on the ESP. family in high byte, proto in low (WIZNET packing).
 * Success: socket id in the high byte of the return (same as OS_NETSOCKET). */
unsigned int OS_ESPSOCKET(unsigned int family_proto)
{
	unsigned char fam;
	unsigned char proto;
	unsigned char pay[1];
	unsigned int r;

	fam = (unsigned char)(family_proto >> 8);
	proto = (unsigned char)family_proto;
	pay[0] = fam;
	r = xfer(ESPNET_CMD_SOCKET, ESPNET_SOCK_NONE, proto, pay, 1);
	if (r != 0)
		return r;
	return ((unsigned int)g_rsp[ESPNET_RSP_SOCK] << 8);
}

/* TCP connect. Long timeout: ESP may retry internally (~8s). */
unsigned int OS_ESPCONNECT(unsigned char socket, struct sockaddr_in *addr)
{
	return xfer(ESPNET_CMD_CONNECT, socket, 0, (unsigned char *)addr,
				ESPNET_SOCKADDR_SIZE);
}

/* Close slot. type 0 = abort, 1 = FIN (may EAGAIN until TX drains). */
unsigned int OS_ESPSHUTDOWN(unsigned char socket, unsigned char type)
{
	return xfer(ESPNET_CMD_SHUTDOWN, socket, type, 0, 0);
}

#ifndef ESPNET_CLIENT_ONLY
/* Listen path (enet/tools). Telnet/gopher skip these at compile time. */
unsigned int OS_ESPBIND(unsigned char socket, struct sockaddr_in *addr)
{
	return xfer(ESPNET_CMD_BIND, socket, 0, (unsigned char *)addr,
				ESPNET_SOCKADDR_SIZE);
}

/* Mark bound   slot as listening (backlog is on the ESP). */
unsigned int OS_ESPLISTEN(unsigned char socket)
{
	return xfer(ESPNET_CMD_LISTEN, socket, 0, 0, 0);
}

/* New accepted fd is in the high byte of the return. */
unsigned int OS_ESPACCEPT(unsigned char socket)
{
	unsigned int r;
	r = xfer(ESPNET_CMD_ACCEPT, socket, 0, 0, 0);
	if (r != 0)
		return r;
	return ((unsigned int)g_rsp[ESPNET_RSP_SOCK] << 8);
}
#endif

/* TCP recv: payload lands in rs->BufAdr, not g_rsp.
 * After a successful (or empty) read we immediately issue the next READ
 * (g_armed) so ESP TXs during disk I/O. */
unsigned int OS_ESPREAD(struct readstructure *rs)
{
	unsigned char pay[2];
	unsigned char *dst;
	unsigned int want;
	unsigned int n;
	unsigned int plen;
	unsigned char sock;

	if (!g_inited)
		return ESPNET_FAIL(ESPNET_ERR_NOTCONN);
	want = rs->bufsize;
	if (want > ESPNET_HOST_MAX)
		want = ESPNET_HOST_MAX;
	put_u16(pay, want);
	sock = rs->socket;
	if (g_armed)
		g_armed = 0;
	else
		send_cmd(ESPNET_CMD_READ, sock, 0, pay, 2);
	n = recv_hdr(ESPNET_CMD_READ, &plen);
	if (n != 0)
		return n;
	n = get_u16(g_rsp + ESPNET_RSP_RESULT);
	if (g_rsp[ESPNET_RSP_STATUS] != 0)
	{
		if (plen && recv_skip(plen) < 0)
			rx_drain();
		if (g_rsp[ESPNET_RSP_STATUS] == ESPNET_ERR_EAGAIN)
		{
			send_cmd(ESPNET_CMD_READ, sock, 0, pay, 2);
			g_armed = 1;
		}
		return ESPNET_FAIL(g_rsp[ESPNET_RSP_STATUS]);
	}
	if (n == 0 || plen == 0)
	{
		if (plen && recv_skip(plen) < 0)
			rx_drain();
		send_cmd(ESPNET_CMD_READ, sock, 0, pay, 2);
		g_armed = 1;
		return ESPNET_FAIL(ESPNET_ERR_EAGAIN);
	}
	if (n > plen)
		n = plen;
	if (n > rs->bufsize)
		n = rs->bufsize;
	dst = (unsigned char *)rs->BufAdr;
	if (recv_fill(dst, n) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	if (plen > n && recv_skip(plen - n) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	/* Next READ goes out now so ESP TXs while the host writes the disk. */
	send_cmd(ESPNET_CMD_READ, sock, 0, pay, 2);
	g_armed = 1;
	return n;
}

/* TCP send; splits at ESPNET_HOST_MAX. Returns bytes accepted, or 0xFFxx. */
unsigned int OS_ESPWRITE(struct readstructure *rs)
{
	unsigned int left;
	unsigned int sent;
	unsigned int chunk;
	unsigned int r;
	unsigned char *p;

	left = rs->bufsize;
	sent = 0;
	p = (unsigned char *)rs->BufAdr;
	while (left)
	{
		chunk = left;
		if (chunk > ESPNET_HOST_MAX)
			chunk = ESPNET_HOST_MAX;
		r = xfer(ESPNET_CMD_WRITE, rs->socket, 0, p, chunk);
		if (r != 0)
		{
			if (sent)
				return sent;
			return r;
		}
		r = get_u16(g_rsp + ESPNET_RSP_RESULT);
		if (r == 0)
		{
			if (sent)
				return sent;
			return ESPNET_FAIL(ESPNET_ERR_EMSGSIZE);
		}
		sent += r;
		p += r;
		left -= r;
		if (r < chunk)
			return sent;
	}
	return sent;
}

#ifndef ESPNET_NO_UDP
/* UDP recv: sockaddr into *from, data into rs->BufAdr. */
unsigned int OS_ESPREAD_UDP(struct readstructure *rs, struct sockaddr_in *from)
{
	unsigned char pay[2];
	unsigned char *dst;
	unsigned int want;
	unsigned int n;
	unsigned int plen;
	unsigned int skip;

	if (!g_inited)
		return ESPNET_FAIL(ESPNET_ERR_NOTCONN);
	want = rs->bufsize;
	if (want > (ESPNET_HOST_MAX - ESPNET_SOCKADDR_SIZE))
		want = ESPNET_HOST_MAX - ESPNET_SOCKADDR_SIZE;
	put_u16(pay, want);
	drop_armed();
	send_cmd(ESPNET_CMD_READ, rs->socket, 0, pay, 2);
	n = recv_hdr(ESPNET_CMD_READ, &plen);
	if (n != 0)
		return n;
	n = get_u16(g_rsp + ESPNET_RSP_RESULT);
	if (g_rsp[ESPNET_RSP_STATUS] != 0)
	{
		if (plen && recv_skip(plen) < 0)
			rx_drain();
		return ESPNET_FAIL(g_rsp[ESPNET_RSP_STATUS]);
	}
	if (n == 0 || plen < ESPNET_SOCKADDR_SIZE)
	{
		if (plen && recv_skip(plen) < 0)
			rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_EAGAIN);
	}
	if (recv_fill((unsigned char *)from, ESPNET_SOCKADDR_SIZE) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	if (n > rs->bufsize)
		n = rs->bufsize;
	if (ESPNET_SOCKADDR_SIZE + n > plen)
		n = plen - ESPNET_SOCKADDR_SIZE;
	dst = (unsigned char *)rs->BufAdr;
	if (n && recv_fill(dst, n) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	skip = plen - ESPNET_SOCKADDR_SIZE - n;
	if (skip && recv_skip(skip) < 0)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	return n;
}

/* sockaddr then data on the wire; no staging copy in g_rsp. */
unsigned int OS_ESPWRITE_UDP(struct readstructure *rs, struct sockaddr_in *to)
{
	unsigned int dlen;
	int body;

	if (!g_inited)
		return ESPNET_FAIL(ESPNET_ERR_NOTCONN);
	dlen = rs->bufsize;
	if (dlen > (ESPNET_HOST_MAX - ESPNET_SOCKADDR_SIZE))
		return ESPNET_FAIL(ESPNET_ERR_EMSGSIZE);
	drop_armed();
	send_cmd2(ESPNET_CMD_WRITE, rs->socket, 0,
			  (unsigned char *)to, ESPNET_SOCKADDR_SIZE,
			  (unsigned char *)rs->BufAdr, dlen);
	body = recv_rsp();
	if (body < ESPNET_RSP_HDR)
	{
		rx_drain();
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	}
	if ((g_rsp[ESPNET_RSP_CMD] & ESPNET_CMD_MASK) != ESPNET_CMD_WRITE ||
		g_rsp[ESPNET_RSP_SEQ] != g_seq)
		return ESPNET_FAIL(ESPNET_ERR_INTR);
	if (g_rsp[ESPNET_RSP_STATUS] != 0)
		return ESPNET_FAIL(g_rsp[ESPNET_RSP_STATUS]);
	return get_u16(g_rsp + ESPNET_RSP_RESULT);
}
#endif

/* STA DNS server IPv4 (four bytes). Telnet WIZNET path used this; ESPNET
 * apps usually call OS_ESPDNSRESOLVE instead. */
unsigned int OS_ESPGETDNS(unsigned char ip[4])
{
	unsigned int r;
	r = xfer(ESPNET_CMD_GETDNS, ESPNET_SOCK_NONE, 0, 0, 0);
	if (r != 0)
		return r;
	memcpy(ip, g_rsp + ESPNET_RSP_HDR, 4);
	return 0;
}

/* Hostname lookup on the ESP (lwIP). Fills ip[4]; no UDP DNS packet on ZX. */
unsigned int OS_ESPDNSRESOLVE(unsigned char *hostname, unsigned char ip[4])
{
	unsigned int r;
	unsigned int n;

	n = 0;
	while (hostname[n] && n < ESPNET_DNS_NAME - 1)
		n++;
	if (n == 0)
		return ESPNET_FAIL(ESPNET_ERR_HOSTUNREACH);
	r = xfer(ESPNET_CMD_DNSRESOLVE, ESPNET_SOCK_NONE, 0, hostname, n);
	if (r != 0)
		return r;
	memcpy(ip, g_rsp + ESPNET_RSP_HDR, 4);
	return 0;
}

#ifndef ESPNET_CLIENT_ONLY
/* Firmware version / chip / heap / wifi summary for enet UI. */
unsigned int OS_ESPINFO(unsigned char buf[ESPNET_INFO_SIZE])
{
	unsigned int r;
	unsigned int plen;
	r = xfer(ESPNET_CMD_INFO, ESPNET_SOCK_NONE, 0, 0, 0);
	if (r != 0)
		return r;
	plen = get_u16(g_rsp + ESPNET_RSP_LEN);
	if (plen > ESPNET_INFO_SIZE)
		plen = ESPNET_INFO_SIZE;
	memset(buf, 0, ESPNET_INFO_SIZE);
	memcpy(buf, g_rsp + ESPNET_RSP_HDR, plen);
	return 0;
}

/* Loopback of payload; UART/speed check, not used by telnet/gopher. */
unsigned int OS_ESPECHO(unsigned char *data, unsigned int len)
{
	unsigned int r;

	if (!g_inited)
		return ESPNET_FAIL(ESPNET_ERR_NOTCONN);
	if (len > ESPNET_HOST_MAX)
		len = ESPNET_HOST_MAX;
	drop_armed();
	send_cmd(ESPNET_CMD_ECHO, ESPNET_SOCK_NONE, 0, data, len);
	r = recv_dst(ESPNET_CMD_ECHO, data, len);
	if (r != 0)
		return r;
	return get_u16(g_rsp + ESPNET_RSP_LEN);
}

/* AP list. Long timeout: scan + ESP must leave STA reconnect paused.
 * Records land in buf (enet g_scan), not g_rsp. */
unsigned int OS_ESPWIFI_SCAN(unsigned char *buf, unsigned int bufsize)
{
	unsigned int r;

	if (!g_inited)
		return ESPNET_FAIL(ESPNET_ERR_NOTCONN);
	drop_armed();
	sof_ticks = ESPNET_SOF_TICKS_LONG;
	send_cmd(ESPNET_CMD_WIFI_SCAN, ESPNET_SOCK_NONE, 0, 0, 0);
	r = recv_dst(ESPNET_CMD_WIFI_SCAN, buf, bufsize);
	sof_ticks = ESPNET_SOF_TICKS;
	if (r != 0)
		return r;
	return get_u16(g_rsp + ESPNET_RSP_RESULT);
}

/* Join AP; waits until real IP, not just WL_CONNECTED. */
unsigned int OS_ESPWIFI_CONNECT(unsigned char *ssid, unsigned char *pass)
{
	static unsigned char pay[ESPNET_WIFI_CONN_SIZE];
	memset(pay, 0, ESPNET_WIFI_CONN_SIZE);
	if (ssid)
		strncpy((char *)pay, (char *)ssid, ESPNET_SSID_SIZE - 1);
	if (pass)
		strncpy((char *)(pay + ESPNET_SSID_SIZE), (char *)pass, ESPNET_PASS_SIZE - 1);
	return xfer(ESPNET_CMD_WIFI_CONNECT, ESPNET_SOCK_NONE, 0, pay, ESPNET_WIFI_CONN_SIZE);
}

/* Leave AP; sockets on ESP are dropped. */
unsigned int OS_ESPWIFI_DISC(void)
{
	return xfer(ESPNET_CMD_WIFI_DISC, ESPNET_SOCK_NONE, 0, 0, 0);
}

/* SSID, RSSI, IP flags for the status pane. */
unsigned int OS_ESPWIFI_STATUS(unsigned char buf[ESPNET_WIFI_STATUS_SIZE])
{
	unsigned int r;
	unsigned int plen;
	r = xfer(ESPNET_CMD_WIFI_STATUS, ESPNET_SOCK_NONE, 0, 0, 0);
	if (r != 0)
		return r;
	plen = get_u16(g_rsp + ESPNET_RSP_LEN);
	if (plen > ESPNET_WIFI_STATUS_SIZE)
		plen = ESPNET_WIFI_STATUS_SIZE;
	memset(buf, 0, ESPNET_WIFI_STATUS_SIZE);
	memcpy(buf, g_rsp + ESPNET_RSP_HDR, plen);
	return 0;
}

/* Tell ESP the ZX UART speed. ACK is still at the old baud; then both switch.
 * persist=1 writes ESP flash (survives reset). Allowed: 9600,19200,38400,57600,115200. */
unsigned int OS_ESPUART(unsigned long baud, unsigned char persist)
{
	static unsigned char pay[ESPNET_UART_SIZE];
	unsigned int r;

	memset(pay, 0, ESPNET_UART_SIZE);
	put_u32(pay + ESPNET_UART_BAUD, baud);
	if (persist)
		pay[ESPNET_UART_FLAGS] = ESPNET_UART_F_PERSIST;
	r = xfer(ESPNET_CMD_UART, ESPNET_SOCK_NONE, ESPNET_UART_ARG_SET, pay, ESPNET_UART_SIZE);
	if (r != 0)
		return r;
	/* ESP delays 50ms after the reply, then switches. Stay idle until then. */
	{
		long until;
		until = time() + 6;
		while ((long)(until - time()) > 0)
			YIELD();
	}
	return 0;
}

unsigned int OS_ESPGETUART(unsigned long *baud)
{
	unsigned int r;
	r = xfer(ESPNET_CMD_UART, ESPNET_SOCK_NONE, ESPNET_UART_ARG_GET, 0, 0);
	if (r != 0)
		return r;
	if (baud)
		*baud = get_u32(g_rsp + ESPNET_RSP_HDR + ESPNET_UART_BAUD);
	return 0;
}
#endif
