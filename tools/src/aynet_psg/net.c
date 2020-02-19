#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "net.h"
unsigned char buf_rx[2048];

int net_test(void){
	int soc;
	struct sockaddr_in server_addr;
	
	memset(&server_addr, 0, sizeof(server_addr));
	server_addr.sin_family = AF_INET;
	server_addr.sin_addr.s_addr = inet_addr("127.0.0.1");
	server_addr.sin_port = htons(16729);
	
	soc = socket(AF_INET, SOCK_STREAM, 0);
	if (soc < 0) {
		puts("error: socket()");
		return -1;
	}
	
    if (connect(soc, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0) {
    	puts("error: connect()");
		close(soc);
		return -1;
    }
	puts("Wait to receive...");
	int l = recv(soc, buf_rx, sizeof(buf_rx), 0);
	for(int i = 0; i < l; i++){
		printf("0x%X ",buf_rx[i]);
	}
	puts("");
	shutdown(soc, 0);
	close(soc);
	return 0;
}


#ifdef _WIN32
WSADATA wsaData;
#endif

int net_init(void){
#ifdef _WIN32
	WORD wVersionRequested = MAKEWORD(2, 2);
	int err = WSAStartup(wVersionRequested, &wsaData);
	if (err != 0) {
		fprintf(stderr,"WSAStartup failed with error: %d\n", err);
		exit(1);
	}
#endif
	return 0;
}

int net_dispose(void){
#ifdef _WIN32
	WSACleanup();
#endif
	return 0;
}





struct in_addr net_resolve(char * name)
{
	struct hostent * h;
	struct in_addr a;


	h = gethostbyname(name);
	
	if( !h )
	{
		fprintf(stderr,"%s: Can't resolve name <%s>\n",__PRETTY_FUNCTION__,name);
		exit(1);
	}

	if( h->h_addrtype != AF_INET || h->h_length != 4 )
	{
		fprintf(stderr,"%s: Name <%s> doesn't resolve into IPv4 address!\n",__PRETTY_FUNCTION__,name);
		exit(1);
	}

	a = *((struct in_addr *)h->h_addr_list[0]);

	return a;
}


int net_connect(struct in_addr resolved_address)
{
	int sock = socket(AF_INET, SOCK_STREAM, 0);
	struct sockaddr_in addr;


	sock = socket(AF_INET, SOCK_STREAM, 0);
	
	if( sock==(-1) )
	{
		fprintf(stderr,"%s: Can't create socket!\n",__PRETTY_FUNCTION__);
		exit(1);
	}

	memset(&addr,0,sizeof(addr));

	addr.sin_family = AF_INET;
	addr.sin_port   = htons(AY_PORT);
	addr.sin_addr   = resolved_address;

	if( connect(sock,(const struct sockaddr *)&addr, sizeof(addr)) )
	{
		fprintf(stderr,"%s: Can't connect()!\n",__PRETTY_FUNCTION__); // TODO: add more diagnostics depending on errno
		exit(1);
	}

	
	// set TCP_NODELAY option for sending to ZX
#ifdef _WIN32
	char dummy = 1;
	u_long non_blocked = 1;
	ioctlsocket(sock, FIONBIO, &non_blocked);
	setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &dummy, sizeof(dummy));
#else
	int dummy = 1;
	setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, &dummy, sizeof(dummy));
#endif


	return sock;
}


void net_disconnect(int sock)
{
#ifdef _WIN32
	u_long non_blocked = 0;
	ioctlsocket(sock, FIONBIO, &non_blocked);
	shutdown(sock, SD_BOTH);
	closesocket(sock);
#else
	shutdown(sock, SHUT_RDWR);
	close(sock);
#endif
}


// receive exactly the given number of bytes, which must be >0.
// works only with a blocking socket (EAGAIN or EWOULDBLOCK currently terminate the program)
// returns 0 if connection is closed, otherwise 1
// any error (recv() returns (-1)) currently terminates the program
int net_recv_bytes(int sock, uint8_t * ptr, size_t recv_size)
{
	if( !recv_size )
	{
		fprintf(stderr,"%s: Requested size to receive is zero!\n",__PRETTY_FUNCTION__);
		exit(1);
	}

	ssize_t curr_size;
	

	while( recv_size )
	{
#ifdef _WIN32
		while(1){
			curr_size=recv(sock, ptr, recv_size, 0);
			if(curr_size > 0)break;
			if(WSAGetLastError() != WSAEWOULDBLOCK) break;
		}
#else
		curr_size=recv(sock, ptr, recv_size, 0);
#endif
		if( curr_size==0 ) // connection closed
		{
			return 0;
		}
		else if( curr_size<0 )
		{
#ifdef _WIN32
			fprintf(stderr,"%s: recv() returned (-1), WSAGetLastError() gave: %d!\n",__PRETTY_FUNCTION__,WSAGetLastError());
			net_disconnect(sock);
			net_dispose();
#else
			fprintf(stderr,"%s: recv() returned (-1), strerror() gave: %s!\n",__PRETTY_FUNCTION__,strerror(errno));
#endif
			exit(1);
		}
		else if( curr_size > recv_size )
		{
			fprintf(stderr,"%s: recv() received more bytes than requested!\n",__PRETTY_FUNCTION__);
			exit(1);
		}

		recv_size -= curr_size;
		ptr       += curr_size;
	}

	
	return 1;
}

