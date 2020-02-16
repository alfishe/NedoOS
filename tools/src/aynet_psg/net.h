#ifndef NET_H
#define NET_H

#ifdef _WIN32
	#include <Winsock2.h>
	#include <ws2tcpip.h>
#else
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <netdb.h>
	#include <netinet/ip.h>
#endif

int net_init(void);
int net_dispose(void);

int net_test(void);


struct in_addr net_resolve(char *);

#endif