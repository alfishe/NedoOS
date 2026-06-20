#ifndef ATELNET_NETGLUE_H
#define ATELNET_NETGLUE_H

#include <tcp.h>

#define ATELNET_NETBUF_SIZE 896u

extern unsigned char netbuf[ATELNET_NETBUF_SIZE];
extern struct sockaddr_in targetadr;
extern struct sockaddr_in dnsaddress;
extern struct readstructure readStruct;

void net_init(void);
int net_parse_ipv4(const char *host, unsigned char *out4);
int net_resolve_host(const char *host);
signed char net_connect_tcp(unsigned int port, unsigned char retry);

char netShutDown(signed char socket, unsigned char type);
int tcpSend(signed char socket, unsigned int messageadr, unsigned int size, unsigned char retry);
int tcpRead(signed char socket, unsigned char retry);
int telnet_tcp_read(signed char socket);

#endif
