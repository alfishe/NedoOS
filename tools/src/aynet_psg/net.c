
#include <stdio.h>
#include <unistd.h>
#include <string.h>

#ifdef _WIN32
	#include <Winsock2.h>
	#include <ws2tcpip.h>
#else
	#include <sys/socket.h>
	#include <netinet/in.h>
#endif
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
        printf("WSAStartup failed with error: %d\n", err);
    }
	return err;
#else
	return 0;
#endif
}

int net_dispose(void){
#ifdef _WIN32
	WSACleanup();
#endif
	return 0;
}

