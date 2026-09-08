#ifndef ESPNET_H
#define ESPNET_H

#include <tcp.h>
#include "../common/espnet/protocol.h"

#define ESPNET_C_OK(v) ((v) <= 32767)
#define ESPNET_C_ERR(v) ((unsigned char)((v) & 255))
#define ESPNET_C_SOCK(v) ((signed char)(((v) >> 8) & 255))

unsigned int OS_ESPINIT(void);

unsigned int OS_ESPSOCKET(unsigned int family_proto);
unsigned int OS_ESPCONNECT(unsigned char socket, struct sockaddr_in *addr);
unsigned int OS_ESPREAD(struct readstructure *rs);
unsigned int OS_ESPWRITE(struct readstructure *rs);
unsigned int OS_ESPREAD_UDP(struct readstructure *rs, struct sockaddr_in *from);
unsigned int OS_ESPWRITE_UDP(struct readstructure *rs, struct sockaddr_in *to);
unsigned int OS_ESPBIND(unsigned char socket, struct sockaddr_in *addr);
unsigned int OS_ESPLISTEN(unsigned char socket);
unsigned int OS_ESPACCEPT(unsigned char socket);
unsigned int OS_ESPSHUTDOWN(unsigned char socket, unsigned char type);
unsigned int OS_ESPGETDNS(unsigned char ip[4]);
unsigned int OS_ESPDNSRESOLVE(unsigned char *hostname, unsigned char ip[4]);
unsigned int OS_ESPINFO(unsigned char buf[ESPNET_INFO_SIZE]);
unsigned int OS_ESPECHO(unsigned char *data, unsigned int len);
unsigned int OS_ESPWIFI_SCAN(unsigned char *buf, unsigned int bufsize);
unsigned int OS_ESPWIFI_CONNECT(unsigned char *ssid, unsigned char *pass);
unsigned int OS_ESPWIFI_DISC(void);
unsigned int OS_ESPWIFI_STATUS(unsigned char buf[ESPNET_WIFI_STATUS_SIZE]);
unsigned int OS_ESPUART(unsigned long baud, unsigned char persist);
unsigned int OS_ESPGETUART(unsigned long *baud);

int EspOpenSock(unsigned char family, unsigned char protocol);
int EspShutDown(signed char socket, unsigned char type);
int EspConnect(signed char socket);
int EspSend(signed char socket, unsigned int messageadr, unsigned int size);
int EspRead(signed char socket);
int EspReadHeader(signed char socket);
int EspSendTo(signed char socket, unsigned int messageadr, unsigned int size,
	      struct sockaddr_in *to);
int EspRecvFrom(signed char socket, struct sockaddr_in *from);
unsigned char EspDnsResolve(const char *domainName);
void EspGetDns(void);

#endif
