
#include <stdio.h>
#include <string.h>
#include "..\oscalls.h"

SOCKET soc;
struct sockaddr_in si;
unsigned char dom_name[64];
unsigned char RX_BUF[4*1024]; 
void initMCU(void){
	YIELD();
	OS_SETGFX(6);
}
C_task main (int argc, char *argv[]) 
{
	char *a=argv[1],*n=dom_name;
	int len;
	long htmlLen=-1l;
	initMCU();
	if(argc==1){
		puts("Need more parameters");
		return 1;
	}
	while(1){
		unsigned char ch=*a;
		if(ch=='-' || ch=='.' || (ch>='0' && ch<='9') || (ch>='A' && ch<='z')) {
			*n++=ch;
			a++;
			continue;
		}
		*n=0;
		break;
	}
	si.sin_addr=*dns_resolver(dom_name);
	si.sin_port=80<<8;
	sprintf(RX_BUF, "GET %s HTTP/1.1\r\nConnection: close\r\nHost: %s\r\n\r\n", *a?a:"/", dom_name);
	soc=socket(AF_INET,SOCK_STREAM,0);
	connect(soc, &si, sizeof(si));
	send(soc,RX_BUF,strlen(RX_BUF),0);
	while(htmlLen){
		len=recv(soc,RX_BUF,sizeof(RX_BUF),0);
		if(len!=0){
			if(len<0){
				puts("Connection closed");
				break;
			}else{
				*(RX_BUF+len)=0;
				if(htmlLen==(-1)){
					if((n=strstr(RX_BUF,"Content-Length: "))!=0){
						n+=16;
						sscanf(n,"%lu",&htmlLen);
						n=strstr(n,"\r\n\r\n")+4;
						len=len-(n-RX_BUF);
					}
				}
				htmlLen-=len;
				puts(RX_BUF);
				continue;
			}
		}else{
			YIELD();
		}
	}
	closesocket(soc,0);
	return 0;
}