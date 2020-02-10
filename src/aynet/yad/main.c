
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <stdlib.h>

no_init unsigned char buf_rx[8*1024+1];  
no_init APP_PAGES app_pages;
no_init	int 			len;

SOCKET 					cmds = 0;
SOCKET 					datasoc = 0;
char					grmod =0;

no_init struct sockaddr_in web_ia;

no_init unsigned char * ptr;

void exit(int e){
	if(cmds)closesocket(cmds,0);
	if(datasoc)closesocket(datasoc,0);
	if(e!=0){	
		OS_SETGFX(6);
		puts((char*)e);
		puts("Press any key");
		getchar();
	}
	((void(*)(int))0x0000)(e);
}

void initMCU(void){
	YIELD();
	app_pages = OS_GETMAINPAGES();
	//OS_SETGFX(6);
}

void putserr(const char * s1,const char * s2){
	if(grmod==0){
		OS_SETGFX(6);
		grmod=1;
	}
	printf("Error: %s %s!",s1,s2);
}


C_task main (int argc, char *argv[]) 
{
	int l=1;
    initMCU();
	web_ia.sin_port=htons(0x4159);
	while(l!=argc){
		char * p=argv[l];
		if(p[0]!='-') exit((int)"Wrong parameter");
		switch (p[1]&0xdf){
			case 'P':
				web_ia.sin_port=htons(strtoul(p+2,&ptr,10));
				break;
			default:
				exit((int)"Wrong parameter");
		}
		l++;
	}
	cmds=socket(AF_INET,SOCK_STREAM,0);
	bind(cmds,&web_ia,sizeof(web_ia));
	listen(cmds,0);
	while(1){
		if(datasoc==0){
			datasoc=accept(cmds,0,0);
			if((datasoc<=0) && (errno!=ERR_EAGAIN))datasoc=accept(cmds,0,0);
			if((datasoc<=0) && (errno!=ERR_EAGAIN))datasoc=accept(cmds,0,0);
			if(datasoc<0){
				datasoc=0;
				if(errno!=ERR_EAGAIN){
					closesocket(cmds,0);
					cmds=socket(AF_INET,SOCK_STREAM,0);
					bind(cmds,&web_ia,sizeof(web_ia));
					listen(cmds,0);
				}else{
					YIELD();
				}
				continue;
			}
		}
		l=recv(datasoc,buf_rx,sizeof(buf_rx),0);
		if(l<0){
			closesocket(datasoc,0);
			datasoc=0;
			//ka=0;
			continue;
		}else if(l==0){
			YIELD();
			continue;
		}
		//тут складываем пакет в буфер
		
		
	}
}   
