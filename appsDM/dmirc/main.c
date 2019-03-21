
#include <stdio.h>
#include <Intrz80.h>
#include <string.h>
#include "..\oscalls.h" 
   
no_init struct keybuffer{
	unsigned char * ptr;
	unsigned char buf[256];
}kbd_buf;

void delayms(unsigned char ms);
#define DELAYMS(tick_) delayms((tick_+20)/20)

no_init unsigned char RX_BUF[3*1024];  
no_init unsigned char TX_BUF[1*1024]; 
no_init unsigned char SCR_BUF[2*1024];

unsigned char *rptr=RX_BUF;
unsigned char *txtptr=SCR_BUF;

const unsigned char strip[]="%d.%d.%d.%d";

static unsigned char irc_dom[64]="irc.forestnet.org:7000";
static unsigned char irc_nick[64]="ircNedoOS";
static unsigned char irc_ch[64]="#mhm";

SOCKET ircsoc=0;
struct sockaddr_in irc_ia;

#define FLS_LGN 0x08
unsigned char fls=0;
static struct {
	unsigned char * nxt;
	unsigned char * src;
	unsigned char * com;
	unsigned char * dst;
	unsigned char * msg;
}pars;

void exit(void){
	if(ircsoc)closesocket(ircsoc,0);
	((void(*)(void))0x0000)();
}

void puts_with_buf(char *str){
	char * ptr=str;
	while(*ptr){
		putchar(*txtptr=*ptr);
		ptr++;
		txtptr++;
		if(txtptr==(SCR_BUF+sizeof(SCR_BUF))){
			txtptr=SCR_BUF;
		}
	}
}	

unsigned char scrredraw(void){
	char * ptr=txtptr;
	while(1){
		putchar(*ptr);
		if((++ptr)==(SCR_BUF+sizeof(SCR_BUF))){
			ptr=SCR_BUF;
		}
		if(ptr==txtptr) break;
	}
	OS_SETXY(0,24);
	printf("%s",kbd_buf.buf);
	return 0;
}

char * gets(char *str)  {
	char *tstr=str;
	OS_SETXY(0,24);
	while(1)
	{
		char ch=getchar();
		unsigned char x=tstr-str;
		if(ch==0x08){
			if(x==0) continue;
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

void config(void){
	unsigned char i=1;
	while(i)
	{
		//putchar(' ');
		puts_with_buf("\r\nConfig:\r\n1->IRC server: "); 
		puts_with_buf(irc_dom);
		puts_with_buf("\r\n2->Channel: ");
		puts_with_buf(irc_ch);
		puts_with_buf("\r\n3->Nick : ");
		puts_with_buf(irc_nick);
		puts_with_buf("\r\n0->Start IRC\r\n");
		
		switch((char)getchar())
		{
			case '1':
				printf("Server: ");
				gets(irc_dom);
				break;
			case '2':
				printf("Channel: ");
				gets(irc_ch);
			break;
			case '3':
				printf("Nick: ");
				gets(irc_nick);
				break;
			case '0':
				i=0;
				break;
		}
	}
}
                  
void msg_send(unsigned char * tbuf){
	strcat(tbuf,"\r\n");
    send(ircsoc,tbuf,strlen(tbuf),0);
    //WIZ_WRITE_BUF(tbuf,strlen(tbuf));
}

unsigned char receive(void){
	int len;
	unsigned char pred=79;
	len=recv(ircsoc,rptr,rptr-(RX_BUF+sizeof(RX_BUF)),0);
	if(len==0) return 1;
	if(len<0){
		closesocket(ircsoc,0);
		ircsoc=0;
		return 1;
	}
	*(rptr+len)=0;
	conv1251to866(rptr);
	pars.nxt=RX_BUF;
	
	OS_SETXY(0,24);
	while(--pred)putchar(' ');
	OS_SETXY(0,24);
	while(1){
	if(!(*pars.nxt)){
		*RX_BUF=0;
		rptr=RX_BUF;
		break;
	}
	rptr=pars.nxt;
	*(pars.nxt=strstr(rptr,"\r\n"))=0;
	
	if(!pars.nxt){
		strcpy(RX_BUF,rptr);
		rptr=RX_BUF;
		while(*rptr)rptr++;
		break;
	}

	pars.nxt+=2;
	if(*rptr==':') {
		pars.src=rptr+1;
		pars.com=strchr(pars.src,' ');
		*(pars.com++)=0;
		*(strchr(pars.src,'!'))=0;
	}
	else {
		pars.com=rptr;
		pars.src=0;
	}
	if(pars.dst=strchr(pars.com,' '))
		*(pars.dst++)=0;
	if(*(pars.dst)==':'){
		pars.msg=pars.dst;
		pars.dst=0;
	}
	else if(pars.msg=strchr(pars.dst,' '))
		*(pars.msg++)=0;
		
	if(*(pars.msg)==':'){
		pars.msg++;
	}
	if((!pars.src)&&(!strcmp(pars.com,"PING"))){
		sprintf(TX_BUF,"PONG %s",pars.msg);
		msg_send(TX_BUF);
		continue;
	}
	puts_with_buf(pars.src);
	puts_with_buf(strcmp(pars.com,"JOIN")?"> ":pars.com);
	puts_with_buf(pars.msg);
	puts_with_buf("\r\n");
	//printf("%s> %s\r\n",pars.src,pars.msg);
	}
	OS_SETXY(0,24);
	printf("%s",kbd_buf.buf);
	return 0;
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

void kbd_pars(void){
	unsigned char * p=kbd_buf.buf;
	OS_SETXY(0,24);
	puts_with_buf(irc_nick);
	puts_with_buf("> ");
	puts_with_buf(kbd_buf.buf);
	puts_with_buf("\r\n");
	//printf("%s> %s\r\n",irc_nick,kbd_buf.buf);
	while(*p){
		if(*p>=128) 
			*p=*(t866to1251-128+*p);
		p++;
	};
	if(*kbd_buf.buf=='/'){
		msg_send(kbd_buf.buf+1);
		if((kbd_buf.buf[1]&~('A'^'a'))=='Q'){
			closesocket(ircsoc,0);
			exit();
		}
	}
	else {
		sprintf(TX_BUF,"PRIVMSG %s :%s",irc_ch,kbd_buf.buf);
		msg_send(TX_BUF);
	}
}

void kbd_read(void){
	unsigned char data=_low_level_get();
	if(!data)return;
  	{
		unsigned char x=kbd_buf.ptr-kbd_buf.buf;
		OS_SETXY(x,24);
		if(data==0x08){			
			if(kbd_buf.ptr!=kbd_buf.buf){
				kbd_buf.ptr--;
				OS_SETXY(x-1,24);
				putchar(' ');
				OS_SETXY(x-1,24);
			}
		}else if (data==13){
			*(kbd_buf.ptr)=0;
			//OS_SETXY(x,24);
			kbd_buf.ptr=kbd_buf.buf;
			//fls=fls&(FLS_KBD^0xff)|FLS_STR;
			kbd_pars();
			//msg_send(kbd_buf.buf);
			//*kbd_buf.buf=0;
			
			while(x--)putchar(' ');
		}else if(x!=79 && data>=' '){
			*(kbd_buf.ptr)=data;
			kbd_buf.ptr++;
  			putchar(data);
		}
		*kbd_buf.ptr=0;
	}
  	//_cur_win=ptr;
  	//inv^=0xff;
}

void login(unsigned char start){
	static unsigned char login_prc;
	
	if(start){
		login_prc=0;
    	fls|=FLS_LGN;
		return;
	}
	switch(login_prc)
	{
		case 0:
			sprintf(TX_BUF,"NICK %s",irc_nick);
			msg_send(TX_BUF);
			login_prc=1;
			break;
		case 1:
			sprintf(TX_BUF,"USER %s 0 0 :%s",irc_nick,irc_nick);
			msg_send(TX_BUF);
			login_prc=2;
			break;
		case 2:
			sprintf(TX_BUF,"JOIN %s",irc_ch);
			msg_send(TX_BUF);
			fls&=(FLS_LGN^0xff);
			break;
	}
}

void reconnect(void){
	unsigned char i;
	unsigned int irc_port;
	printf("Connect to server..");
	i=sscanf(irc_dom,"%[^:]:%d",TX_BUF,&irc_port);
	
	
	if(i==1){
		irc_port=7000;
	}else if(i==2){
		irc_ia.sin_port=htons(irc_port);
	}else{
		puts("Wrong servername!");
		exit();
	}
	i=sscanf(TX_BUF,"%d.%d.%d.%d",&irc_ia.sin_addr.S_un.S_un_b.s_b1,&irc_ia.sin_addr.S_un.S_un_b.s_b2
		,&irc_ia.sin_addr.S_un.S_un_b.s_b3,&irc_ia.sin_addr.S_un.S_un_b.s_b4);
	if(i!=4){
		irc_ia.sin_addr=*dns_resolver(TX_BUF);
		if(!irc_ia.sin_addr.S_un.S_addr){
			puts("ftp: connect: Connection timed out");
			return;			
		}
	}
	i=3;
	while(i--){
		ircsoc=socket(AF_INET,SOCK_STREAM,0);
		if(ircsoc<0){
			puts("Net error!");
			exit();
		}
		if(connect(ircsoc, &irc_ia, sizeof(irc_ia))<0){
			closesocket(ircsoc,0);
			ircsoc=0;
			YIELD();
		}else{
			break;
		}
		if(1==0){
			i=255;
			while(i--) YIELD();
			return;
		}
	}
    puts("OK");
    *RX_BUF=0;
    rptr=RX_BUF;
	login(1);
    //sprintf(TX_BUF,"JOIN #%s\r\n",irc_ch);
    //puts
}

void initMCU(void){
	YIELD();
	OS_SETGFX(6);
	OS_CLS(7);
	OS_SETXY(0,24);
	kbd_buf.ptr=kbd_buf.buf;
	*kbd_buf.buf=0x00;
	memset(SCR_BUF,' ',sizeof(SCR_BUF));
	*txtptr=0x00;
}

void delayms(unsigned char ms)
{
	while(ms--) YIELD();
}

void main(void)
{
	initMCU(); 
	printf("dmirc ver.%s %s\r\n",__DATE__,__TIME__);
	config();
	while(1){
		if(ircsoc==0) {
			reconnect();
			DELAYMS(2000);
			continue;
		}
		else if(!receive()){
			continue;
		}
		else if(fls&FLS_LGN){
			login(0);
			DELAYMS(1000);
			continue;
		}
		//if(fls&FLS_STR) {
		//	kbd_pars();
		//	msg_send(kbd_buf.buf);
		//	continue;
		//}
		//if(fls&FLS_CURS) flash_cursor();
		YIELD();
		//if(fls&FLS_KBD) 
		kbd_read();
	}
   
}   
