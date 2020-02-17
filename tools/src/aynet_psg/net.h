#ifndef _NET_H_
#define _NET_H_

#include <stdint.h>

#ifdef _WIN32
	#include <Winsock2.h>
	#include <ws2tcpip.h>
	#define MSG_DONTWAIT 0 //set in ioctlsocket
	#define MSG_NOSIGNAL 0
	#define EWOULDBLOCK WSAEWOULDBLOCK
	#define ECONNRESET WSAECONNRESET
#else
	#include <errno.h>
	#include <sys/types.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <netdb.h>
	#include <netinet/ip.h>
	#include <netinet/tcp.h>
#endif


#define AY_PORT (16729) /* 0x4159 or 'AY' */


int net_init(void);
int net_dispose(void);

int net_test(void);


struct in_addr net_resolve(char *);
int net_connect(struct in_addr);
void net_disconnect(int sock);

int net_recv_bytes(int sock, uint8_t * ptr, size_t recv_size);



#endif // _NET_H_
