#ifndef ATELNET_NETGLUE_H
#define ATELNET_NETGLUE_H

#include <tcp.h>

#define ATELNET_NETBUF_SIZE 896u

#define OS_CALL_OK(todo) ((todo) <= 32767)
#define OS_CALL_ERR(todo) ((unsigned char)((todo) & 255))
#define OS_CALL_SOCKET(todo) ((signed char)(((todo) >> 8) & 255))

extern unsigned char netbuf[ATELNET_NETBUF_SIZE];
extern struct sockaddr_in targetadr;
extern struct sockaddr_in dnsaddress;
extern struct readstructure readStruct;

/* 0 = WIZNET OK. 1/2 = ESP (unsupported). */
unsigned char net_init(void);
int net_resolve_host(const char *host);
signed char net_connect_tcp(unsigned int port, unsigned char retry);

char netShutDown(signed char socket, unsigned char type);
int tcpSend(signed char socket, unsigned int messageadr, unsigned int size, unsigned char retry);
int telnet_tcp_read(signed char socket);

#endif
