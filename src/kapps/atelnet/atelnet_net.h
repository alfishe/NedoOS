#ifndef ATELNET_NET_H
#define ATELNET_NET_H

void at_net_init(void);
int at_net_resolve_host(const char *host);
signed char at_net_connect_tcp(unsigned int port, unsigned char retry);
int at_telnet_tcp_read(signed char socket);
int at_tcpSend(signed char socket, unsigned int messageadr, unsigned int size, unsigned char retry);
char at_netShutDown(signed char socket, unsigned char type);

#endif
