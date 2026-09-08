/*
 * ESPNET socket helpers for apps (netDriver == 2).
 * Calls OS_ESP* only. UART / espcom.ini stay inside espnet.c.
 * Do not include from AT-Firmware or ZXNETUSB-only apps.
 */

#ifndef NETBUF_BYTES
#define NETBUF_BYTES sizeof(netbuf)
#endif

#ifndef ESPNET_DNS_TRIES
#define ESPNET_DNS_TRIES 4
#endif
#ifndef ESPNET_CONN_TRIES
#define ESPNET_CONN_TRIES 3
#endif

static void espnet_pause(unsigned int ticks)
{
	long until;

	until = time() + (long)ticks;
	while (time() < until)
		YIELD();
}

int EspOpenSock(unsigned char family, unsigned char protocol)
{
	unsigned int todo;

	todo = OS_ESPSOCKET(((unsigned int)family << 8) + protocol);
	if (!ESPNET_C_OK(todo))
		return 0 - (int)ESPNET_C_ERR(todo);
	return (int)ESPNET_C_SOCK(todo);
}
int EspShutDown(signed char socket, unsigned char type)
{
	unsigned int todo;
	todo = OS_ESPSHUTDOWN((unsigned char)socket, type);
	if (ESPNET_C_OK(todo))
		return (int)socket;
	return 0 - (int)ESPNET_C_ERR(todo);
}

int EspConnect(signed char socket)
{
	unsigned int todo;
	unsigned char try;

	for (try = 0; try < ESPNET_CONN_TRIES; try++)
	{
		todo = OS_ESPCONNECT((unsigned char)socket, &targetadr);
		if (ESPNET_C_OK(todo))
			return 0;
		if (try + 1u < ESPNET_CONN_TRIES)
			espnet_pause(50); /* ~1s @ 50Hz */
	}
	return 0 - (int)ESPNET_C_ERR(todo);
}

int EspSend(signed char socket, unsigned int messageadr, unsigned int size)
{
	unsigned int todo;
	readStruct.socket = (unsigned char)socket;
	readStruct.BufAdr = messageadr;
	readStruct.bufsize = size;
	readStruct.protocol = SOCK_STREAM;
	todo = OS_ESPWRITE(&readStruct);
	if (ESPNET_C_OK(todo))
		return todo;
	return 0 - ESPNET_C_ERR(todo);
}

int EspRead(signed char socket)
{
	unsigned int todo;
	readStruct.socket = (unsigned char)socket;
	readStruct.BufAdr = (unsigned int)&netbuf;
	readStruct.bufsize = NETBUF_BYTES;
	readStruct.protocol = SOCK_STREAM;

	todo = OS_ESPREAD(&readStruct);
	if (ESPNET_C_OK(todo))
		return todo;
	return 0 - ESPNET_C_ERR(todo);
}

int EspReadHeader(signed char socket)
{
	unsigned int got;
	unsigned int todo;
	unsigned int room;

	got = 0;
	netbuf[0] = 0;
	for (;;)
	{
		if (strstr((char *)netbuf, "\r\n\r\n") != 0)
			return (int)got;
		room = NETBUF_BYTES - 1 - got;
		if (room == 0)
			return 0 - (int)ESPNET_ERR_EMSGSIZE;
		readStruct.socket = (unsigned char)socket;
		readStruct.BufAdr = (unsigned int)(netbuf + got);
		readStruct.bufsize = room;
		readStruct.protocol = SOCK_STREAM;
		todo = OS_ESPREAD(&readStruct);
		if (ESPNET_C_OK(todo))
		{
			got += todo;
			netbuf[got] = 0;
			continue;
		}
		if (ESPNET_C_ERR(todo) == ESPNET_ERR_EAGAIN)
		{
			YIELD();
			continue;
		}
		return 0 - (int)ESPNET_C_ERR(todo);
	}
}

#ifndef ESPNET_NO_UDP
int EspSendTo(signed char socket, unsigned int messageadr, unsigned int size,
	      struct sockaddr_in *to)
{
	unsigned int todo;

	readStruct.socket = (unsigned char)socket;
	readStruct.BufAdr = messageadr;
	readStruct.bufsize = size;
	readStruct.protocol = SOCK_DGRAM;
	todo = OS_ESPWRITE_UDP(&readStruct, to);
	if (ESPNET_C_OK(todo))
		return todo;
	return 0 - ESPNET_C_ERR(todo);
}

int EspRecvFrom(signed char socket, struct sockaddr_in *from)
{
	unsigned int todo;

	readStruct.socket = (unsigned char)socket;
	readStruct.BufAdr = (unsigned int)&netbuf;
	readStruct.bufsize = NETBUF_BYTES;
	readStruct.protocol = SOCK_DGRAM;
	todo = OS_ESPREAD_UDP(&readStruct, from);
	if (ESPNET_C_OK(todo))
		return todo;
	return 0 - ESPNET_C_ERR(todo);
}
#endif

unsigned char EspDnsResolve(const char *domainName)
{
	unsigned char ip[4];
	unsigned int r;
	unsigned char try;

	if (domainName[0] == 0)
		return 0;
	/* After TCP close the ESP DNS resolver often fails for ~1s (lwIP). */
	espnet_pause(15);
	for (try = 0; try < ESPNET_DNS_TRIES; try++)
	{
		r = OS_ESPDNSRESOLVE((unsigned char *)domainName, ip);
		if (ESPNET_C_OK(r))
		{
			targetadr.family = AF_INET;
			targetadr.b1 = ip[0];
			targetadr.b2 = ip[1];
			targetadr.b3 = ip[2];
			targetadr.b4 = ip[3];
			return 1;
		}
		if (try + 1u < ESPNET_DNS_TRIES)
			espnet_pause(50); /* ~1s between DNS attempts */
	}
	return 0;
}

void EspGetDns(void)
{
	unsigned char ip[4];
	unsigned int r;

	r = OS_ESPGETDNS(ip);
	if (!ESPNET_C_OK(r))
		return;
	dnsaddress.family = AF_INET;
	dnsaddress.porth = 0;
	dnsaddress.portl = 53;
	dnsaddress.b1 = ip[0];
	dnsaddress.b2 = ip[1];
	dnsaddress.b3 = ip[2];
	dnsaddress.b4 = ip[3];
}
