
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <stdlib.h>

extern unsigned char 	buf_rx[6*1024];  
extern unsigned char *	ptr_in_rx; 
extern unsigned char *	ptr_out_rx;
extern unsigned char	u32_intcount[4];
extern unsigned char	flag_play;
extern unsigned char 	msg_hello[9];
extern unsigned char 	msg_framesync[5];

no_init union APP_PAGES app_pages;
no_init	int 			len;

SOCKET 					cmds = 0;
SOCKET 					datasoc = 0;
char					grmod =0;

no_init struct sockaddr_in web_ia;

no_init unsigned char * ptr;

void int_play(void);
void int_null(void);



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
	app_pages.l = OS_GETMAINPAGES();
	//OS_SETMUSIC(int_play, app_pages.pgs.window_1);
	//OS_SETGFX(6);
}

void putserr(const char * s1,const char * s2){
	if(grmod == 0){
		OS_SETGFX(6);
		grmod = 1;
	}
	printf("Error: %s %s!",s1,s2);
}


C_task main (int argc, char *argv[]) 
{
	int l=1;
    initMCU();
	ptr_out_rx =  buf_rx;
	ptr_in_rx = buf_rx + sizeof(buf_rx);
	web_ia.sin_port=htons(16729); //'AY' chars
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
				OS_SETMUSIC(int_play, app_pages.pgs.window_1);
				if(errno!=ERR_EAGAIN){
					closesocket(cmds,0);
					cmds=socket(AF_INET,SOCK_STREAM,0);
					bind(cmds,&web_ia,sizeof(web_ia));
					listen(cmds,0);
				}else{
					YIELD();
				}
				continue;
			}else{//to do else
				send(datasoc, msg_hello, 9, 0);
				OS_SETMUSIC(int_play, app_pages.pgs.window_1);
			}
		}
		if(flag_play){
			send(datasoc, msg_framesync, 5, 0);
			flag_play = 0;
		}
		l=recv(datasoc,buf_rx,sizeof(buf_rx),0);
		if(l<0){
			closesocket(datasoc,0);
			OS_SETMUSIC(int_play, app_pages.pgs.window_1);
			datasoc=0;
			continue;
		}else if(l==0){
			YIELD();
			continue;
		}else{//echo
			send(datasoc, buf_rx, l, 0);
		}
		//тут складываем пакет в буфер
		
	}
}   
