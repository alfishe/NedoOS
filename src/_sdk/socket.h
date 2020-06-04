#ifndef SOCKET_H
#define SOCKET_H

typedef signed char SOCKET;
struct in_addr {
	union {
		struct {unsigned char s_b1; unsigned char s_b2;
			unsigned char s_b3; unsigned char s_b4;} S_un_b;
		struct {unsigned short s_w1; unsigned short s_w2;} S_un_w;
		unsigned long S_addr;
	} S_un;
};

struct sockaddr_in {
        unsigned char   sin_family;
        unsigned short sin_port;
        struct  in_addr sin_addr;
        char    sin_zero[8];
};

SOCKET  OS_NETSOCKET(unsigned int);
#define socket(domain, type, protocol) OS_NETSOCKET((domain<<8)+type)

int OS_NETRECV(unsigned char * buffer, SOCKET socket, unsigned int buf_size);
#define recv(socket, buffer, buf_size, flags) OS_NETRECV(buffer, socket, buf_size)

int OS_NETSEND(unsigned char * buffer, SOCKET socket, unsigned int length);
#define send(socket, buffer, length, flags) OS_NETSEND(buffer, socket, length)

int OS_NETSENDTO(const struct sockaddr_in * addr, SOCKET socket, unsigned int length, unsigned char * buffer);
#define sendto(socket, buffer, length, flags, sain, sain_l) OS_NETSENDTO(sain, socket, length, buffer)

int OS_NETRECVFROM(const struct sockaddr_in * addr, SOCKET socket, unsigned int length, unsigned char * buffer);
#define recvfrom(socket, buffer, length, flags, sain, sain_l) OS_NETRECVFROM(sain, socket, length, buffer)

signed char  OS_NETCLOSE(unsigned char,SOCKET);
#define closesocket(socket,how) OS_NETCLOSE(how,socket)


signed char OS_NETCONNECT(const struct sockaddr_in * addr, SOCKET socket);
#define connect(socket, addr, address_len) OS_NETCONNECT(addr,socket)
signed char OS_LISTEN(int, SOCKET socket);
#define listen(socket, backlog) OS_LISTEN(backlog,socket)
signed char OS_BIND(const struct sockaddr_in * addr, SOCKET socket);
#define bind(socket, addr, address_len) OS_BIND(addr,socket)
SOCKET OS_ACCEPT(const struct sockaddr_in * addr, SOCKET socket);
#define accept(socket, addr, address_len) OS_ACCEPT(addr,socket)
unsigned short htons(unsigned short hostshort);

struct in_addr * dns_resolver(char *);

#define IPPROTO_TCP 6
#define IPPROTO_UDP 17

#define AF_UNSPEC 0
#define AF_INET 2
#define AF_INET6 23

#define SOCK_STREAM 0x01	//tcp/ip
#define SOCK_DGRAM 	0x03		//udp/ip

#endif