
#include <stdio.h>
#include <string.h>
#include "..\oscalls.h" 

no_init unsigned char kbd_buf[128];

no_init unsigned char RX_BUF[4*1024];  
no_init unsigned char TX_BUF[4*1024];
unsigned char *rptr=RX_BUF;
  
no_init unsigned char irc_dom[64];
struct sockaddr_in ftp_ia;
no_init unsigned int ftp_port;
no_init unsigned int data_port;
unsigned int dns_makequery(void);

SOCKET cmds=0;
SOCKET datasoc=0;

no_init unsigned char glargc;
no_init char * * glargv;

void exit(void){
	if(cmds)closesocket(cmds,0);
	if(datasoc)closesocket(datasoc,0);
	((void(*)(void))0x0000)();
}

char * gets(char *str)  {
	char *tstr=str;
	//OS_SETXY(0,24);
	while(1)
	{
		char ch=getchar();
		unsigned char x=OS_GETXY();
		if(ch==0x08){
			if(tstr==str) continue;
			OS_SETXY(x-1,24);
			putchar(' ');
			OS_SETXY(x-1,24);
			if(x)tstr--;
			continue;
		}
		if(x==79)continue;
		if (ch==13) {
			puts("");
			break;
		}
		if(ch < ' ') continue;
  		putchar(ch);
		*tstr=ch;
		tstr++;
		
	}
	*tstr=0;
	return str;
}
  
int waitRequestCMD(unsigned char i){
	int len;
	while(i){
		len=recv(cmds,RX_BUF,sizeof(RX_BUF),0);
		if(len!=0){
			if(len<0){
				puts("ftp: connect: Connection timed out");
				closesocket(cmds,0);
				cmds=0;
				return 0;
			}else{
				*(RX_BUF+len)=0;
				sscanf(RX_BUF,"%d",&len);
				conv1251to866(RX_BUF);
				puts(RX_BUF);
				return len;
			}
		}else{
			YIELD();
			i--;
		}
	}
	return 0;
}

void msg_send(unsigned char * tbuf){
	strcat(tbuf,"\r\n");
    send(cmds,tbuf,strlen(tbuf),0);
}

unsigned int msg_send_const(const unsigned char * tbuf){
	strcpy(TX_BUF,tbuf);
	msg_send(TX_BUF);
	return waitRequestCMD(150);
}

void put_c_in_string(char c, void *ptr){
  *(*(char **) ptr)++ = c;
}

#include <icclbutl.h> 
unsigned int wiz_printf_cmd(const char *format, ...){                     
    va_list ap;   
    int i;
    char *buf_pft=TX_BUF;   
                    
    va_start(ap, format);      /* Variable argument begin */
    i = _formatted_write(format, put_c_in_string, (void *) &buf_pft, ap);
    va_end(ap);                /* Variable argument end */
	if(i<0) return 0;
	
    *buf_pft = '\0';                 /* String should be terminated with NUL */
    msg_send(TX_BUF);
       
    return waitRequestCMD(150);   
}  

const unsigned char t866to1251[128] = {
	0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7, 0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 
	0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7, 0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 
	0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 
	0x2D, 0x2D, 0x2D, 0xA6, 0x2B, 0xA6, 0xA6, 0xAC, 0xAC, 0xA6, 0xA6, 0xAC, 0x2D, 0x2D, 0x2D, 0xAC, 
	0x4C, 0x2B, 0x54, 0x2B, 0x2D, 0x2B, 0xA6, 0xA6, 0x4C, 0xE3, 0xA6, 0x54, 0xA6, 0x3D, 0x2B, 0xA6, 
	0xA6, 0x54, 0x54, 0x4C, 0x4C, 0x2D, 0xE3, 0x2B, 0x2B, 0x2D, 0x2D, 0x2D, 0x2D, 0xA6, 0xA6, 0x2D, 
	0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7, 0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF, 
	0xA8, 0xB8, 0xAA, 0xBA, 0xAF, 0xBF, 0xA1, 0xA2, 0xB0, 0x95, 0xB7, 0x76, 0xB9, 0xA4, 0xA6, 0xA0
};

unsigned char reconnect(SOCKET * soc, unsigned int port){
	unsigned char i=3;
	if(*soc){
		closesocket(*soc,0);
		*soc=0;
	}
	//output(0x81ab,soc);
	ftp_ia.sin_port=htons(port);
	while(i--){
		*soc=socket(AF_INET,SOCK_STREAM,0);
		if(*soc<0)continue;
		if(connect(*soc, &ftp_ia, sizeof(ftp_ia))<0){
			closesocket(*soc,0);
			*soc=0;
		}else{
			return 0;
		}
	}
	return 1;
}

void initMCU(void){
	YIELD();
	OS_SETGFX(6);
	//OS_CLS(7);
	OS_SETXY(0,24);
	*kbd_buf=0x00;
	memcpy(kbd_buf,TX_BUF,25);
}

void cmdOpen(void){
	unsigned char i;
	unsigned int req;
	printf("(to) ");
	if(glargc>1){
		strcpy(kbd_buf,glargv[1]);
		puts(kbd_buf);
	}else{
		gets(kbd_buf);
	}
	i=sscanf(kbd_buf,"%[^:]:%d",TX_BUF,&ftp_port);
	if(i==1){
		ftp_port=21;
	}
	i=sscanf(TX_BUF,"%d.%d.%d.%d",&ftp_ia.sin_addr.S_un.S_un_b.s_b1,&ftp_ia.sin_addr.S_un.S_un_b.s_b2
		,&ftp_ia.sin_addr.S_un.S_un_b.s_b3,&ftp_ia.sin_addr.S_un.S_un_b.s_b4);
	if(i!=4){
		ftp_ia.sin_addr=*dns_resolver(TX_BUF);
		if(!ftp_ia.sin_addr.S_un.S_addr){
			puts("error: domain name not resolved");
			return;			
		}
	}
	if(reconnect(&cmds, ftp_port)){
		puts("ftp: connect: Connection timed out");
		return;
	}
	req=waitRequestCMD(150);
	while(req!=0){
		if(req==220){
			printf("Name: ");
			if(glargc>2){
				strcpy(kbd_buf,glargv[2]);
				puts(kbd_buf);
			}else{
				gets(kbd_buf);
			}
			req=wiz_printf_cmd("USER %s",kbd_buf);
		}else if(req==331){
			printf("Password: ");
			if(glargc>3){
				strcpy(kbd_buf,glargv[3]);
				puts(kbd_buf);
			}else{
				gets(kbd_buf);
			}
			req=wiz_printf_cmd("PASS %s",kbd_buf);
		}else if(req==230){
			return;		
		}else if(req>=500){
			closesocket(cmds,0);
			cmds=0;
			return;
		}
	}
}

unsigned char getDataSoc(void){
	unsigned int req;
	unsigned char i;
	strcpy(TX_BUF,"PASV");
	msg_send(TX_BUF);
	req=waitRequestCMD(150);
	if(req!=227) return 1;
	i=sscanf(RX_BUF,"227 Entering Passive Mode (%d,%d,%d,%d,%d,%d).",
		&ftp_ia.sin_addr.S_un.S_un_b.s_b1,&ftp_ia.sin_addr.S_un.S_un_b.s_b2,
		&ftp_ia.sin_addr.S_un.S_un_b.s_b3,&ftp_ia.sin_addr.S_un.S_un_b.s_b4,
		&req,&data_port);
	if(i!=6) return 1;
	data_port+=req<<8;
	i = reconnect(&datasoc, data_port);
	return i;
}

void cmdDir(void){
	int len;
	unsigned char req;
	if(msg_send_const("PWD")!=257) return;
	if(getDataSoc()==1)return;
	if(msg_send_const("TYPE A")!=200){
		closesocket(datasoc,0);
		datasoc=0;
		return;
	}
	req=msg_send_const("LIST");
	if((req!=125)&&(req!=150)){
		closesocket(datasoc,0);
		datasoc=0;
		return;
	}
	while(1){
		len=recv(datasoc,RX_BUF,sizeof(RX_BUF),0);
		if(len==0){
			YIELD();
		}else if(len<0){
			closesocket(datasoc, 0);
			datasoc=0;
			break;
		}else{
			*(RX_BUF+len)=0;
			conv1251to866(RX_BUF);
			puts(RX_BUF);
		} 
	}
	waitRequestCMD(100);
}

void cmdRetr(void){
	int len;
	unsigned int pr=0;
	unsigned int file;
	unsigned char req;
	if(msg_send_const("PWD")!=257) return;
	if(getDataSoc()==1)return;
	if(msg_send_const("TYPE I")!=200){
		closesocket(datasoc, 0);
		datasoc=0;
		return;
	}
	req=wiz_printf_cmd("RETR %s",kbd_buf+4);
	if((req!=125)&&(req!=150)){
		closesocket(datasoc, 0);
		datasoc=0;
		return;
	}
	file=OS_CREATEHANDLE(kbd_buf+4,0x80);
	if(file&0xff){
		closesocket(datasoc, 0);
		datasoc=0;
		puts("Open local file error");
		return;
	}
	while(1){
		len=recv(datasoc,RX_BUF,sizeof(RX_BUF),0);
		if(len!=0){
			if(len<0) break;
			pr++;
			OS_WRITEHANDLE(RX_BUF,file,len);
			printf("\r%d packets",pr);
		}else{
			YIELD();
		}
	}
	closesocket(datasoc, 0);
	datasoc=0;
	OS_CLOSEHANDLE(file);
	waitRequestCMD(100);
}

void cmdStor(void){
	int res;
	unsigned char req;
	unsigned int len,pr=0;
	unsigned int file;
	if(msg_send_const("PWD")!=257) return;
	file=OS_OPENHANDLE(kbd_buf+4,0x00);
	if(file&0xff){
		puts("Open local file error");
		return;
	}
	if(msg_send_const("TYPE I")!=200){
		goto endstor;
	}
	if(getDataSoc()==1)return;
	req=wiz_printf_cmd("STOR %s",kbd_buf+4);
	if((req!=125)&&(req!=150)){
		goto endstor;
	}
	while(1){
		if((len=OS_READHANDLE(TX_BUF,file,2048))==0){
			break;
		}else{
			pr++;
			while(1){
				res=send(datasoc,TX_BUF,len,0);
				if(res<0){
					if(errno==ERR_EMSGSIZE){
						YIELD();
						continue;
					}
					goto endstor;
				}
				break;
			}
			printf("\r%d packets",pr);
		}
	}
endstor:
	while(closesocket(datasoc,pr?1:0));
	datasoc=0;
	OS_CLOSEHANDLE(file);
	waitRequestCMD(100);
}

extern void dns_resolve(void);

C_task main (int argc, char *argv[]) 
{
    initMCU(); 
	printf("dmftp v.%s %s\r\n",__DATE__,__TIME__);
	glargc=argc;
	glargv=argv;
	if(glargc>1){
		cmdOpen();
		glargc=1;
	}
	while(1){
		if(waitRequestCMD(1))continue;
		printf("ftp> ");
		gets(kbd_buf);
		if(*kbd_buf==0x00)continue;
		switch(*kbd_buf){
			case 'd':
				if(!strcmp(kbd_buf,"dir")){
					cmdDir();
				}else if(!strncmp(kbd_buf,"del ",4)){
					wiz_printf_cmd("DELE %s",kbd_buf+4);
				}
				break;
			case 'c':
				if(!strncmp(kbd_buf,"cd ",3)){
					wiz_printf_cmd("CWD %s",kbd_buf+3);
				}else if(!strcmp(kbd_buf,"close")){
					msg_send_const("QUIT");
					waitRequestCMD(1);
					closesocket(cmds,0);
					closesocket(datasoc,0);
					cmds=0;
					datasoc=0;
				}
				break;
			case 'g':
				if(!strncmp(kbd_buf,"get ",4)){
					cmdRetr();
				}
				break;
			case 'm':
				if(!strncmp(kbd_buf,"mkd ",4)){
					wiz_printf_cmd("MKD %s",kbd_buf+4);
				}
				break;
			case 'p':
				if(!strncmp(kbd_buf,"put ",4)){
					cmdStor();
				}
				break;
			case 'q':
				if(!strcmp(kbd_buf,"quit")){
					msg_send_const("QUIT");
					closesocket(cmds,0);
					closesocket(datasoc,0);
					cmds=0;
					return 0;
				}
				break;
			case 'r':
				if(!strncmp(kbd_buf,"rmd ",4)){
					wiz_printf_cmd("RMD %s",kbd_buf+4);
				}
				break;
			case 'o':
				if(!strcmp(kbd_buf,"open")){
					cmdOpen();
				}
				break;
			default:
				puts("cmd parameters: dmftp.com domain.name.ru [loginname [password]]");
				puts("open - connect to server, close - close connection, quit - quit to OS");
				puts("dir  - view directory,    cd    - change directory, mkd  - create directory");
				puts("rmd  - remove directory,  del   - delete file");
				puts("get  - get file,          put   - put file");
			break;
		} 
	}
}   
