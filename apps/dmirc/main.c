
#include <stdio.h>
#include <Intrz80.h>
#include <string.h>
#include "w5300.h" 
#include "..\oscalls.h" 
//#include "irc.h"   

/*  
********************************************************************************  
Define Part  
********************************************************************************  
*/   
//#define TX_RX_MAX_BUF_SIZE    (2048+16)        /* maximum size of Rx buffer. */   
   
/*  
********************************************************************************  
Local Variable Declaration Section  
********************************************************************************  
*/   
//const u_char * rx_buf= (u_char *)(0x2000);   /* Rx buffer for Application */   
struct keybuffer{
	unsigned char * ptr;
	unsigned char buf[256];
}kbd_buf;

void delayms(unsigned char ms);
#define DELAYMS(tick_) delayms((tick_+20)/20)

unsigned char RX_BUF[4*1024];  
unsigned char TX_BUF[4*1024];
unsigned char *rptr=RX_BUF;
const unsigned char strip[]="%d.%d.%d.%d";

static unsigned char ch_hash[16]={0};

unsigned long int_count;   
   
static unsigned char dns_serv[]={8,8,8,8};
static unsigned char irc_dom[64]="irc.forestnet.org";
static unsigned char irc_ip[4]={185,117,153,103};
static unsigned char irc_nick[64]="ircNedoOS";
static unsigned char irc_ch[64]="#mhm";
unsigned int iinchip_source_port=25;
unsigned int dns_makequery(void);
#define FLS_LGN 0x08
unsigned char fls=0;
static struct {
	unsigned char * nxt;
	unsigned char * src;
	unsigned char * com;
	unsigned char * dst;
	unsigned char * msg;
}pars;


char * gets(char *str)  
{
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
	unsigned char i;
	while(i)
	{
		putchar(' ');
		puts("\r\nConfig:"); 
		printf("\r\n1->IRC server: ");
		printf(strip,irc_ip[0],irc_ip[1],irc_ip[2],irc_ip[3]); 
		printf("\r\n2->Channel: %s",irc_ch);
		printf("\r\n3->Nick : %s",irc_nick);
		puts("\r\n0->Start IRC");
		
		switch((char)getchar())
		{
			case '1':
				dns_makequery();
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
                
void int_proc(void)
{  
	int_count++; 
} 
  
unsigned int dns_makequery(void)
{
	/*
	unsigned char* query;
    unsigned int len;
    unsigned char qname[64];
    puts("domain name (NOT IP):"); 
    scanf("%s",qname);
	iinchip_source_port++; 
    //WIZ_SOCKET(0, Sn_MR_UDP, iinchip_source_port);  
    do{
    	*S_CR(0) =Sn_CR_CLOSE;
    	while(*S_CR(0));
		*S_MR(0) = Sn_MR_UDP; // sets TCP mode
		*S_PORTR(0) = iinchip_source_port; // sets source port number
		*S_CR(0) = Sn_CR_OPEN; // sets OPEN command
		while(*S_CR(0));
	}while(*S_SSR(0) != SOCK_UDP);
	// Make Qurey Header 
	memcpy(TX_BUF,DNS_HEAD,6);
	memset(TX_BUF+6,0,512);
	strcpy(TX_BUF + 13,qname);
	query = TX_BUF + 13;

	// Make Question Section 
	while(1)	// fill in QNAME filed with domain_name 
	{
		unsigned char* domain_tok;
		unsigned char domain_len;
		domain_tok = (unsigned char*)strchr((char*)query,'.');
		if(domain_tok)	domain_len = ((unsigned int)domain_tok - (unsigned int)query) & 0xFF;   
		else domain_len = strlen(query);
		if(domain_len > 63)
		{
			return 0;		// since the label must begin with two zero bits because labels are restricted to 63 octets or less.
		}
		*(query-1) = domain_len;
		//memcpy(query,qname,domain_len);
		//qname += domain_len+1;
		query += domain_len+1;
		if(!domain_tok) break;
	}
	// *query++;// = '\0';			// terminate QNAME field with 'NULL'
	
	// fill in QTYPE field, for host address
	*query++ = 0;
	*query++ = 1;
	
	// fill in QCLASS field, for internet
	*query++ = 0;
	*query++ = 1;
	
	WIZ_SOC_IPSET(0,dns_serv,53);
    puts("Connected to DNS");
    WIZ_WRITE_BUF(0,TX_BUF,(int)(query - TX_BUF));
      
    while (1)   
    {   
    	len=*S_RX_RSR(0);
    	if(!len) continue;
    	if(len==*S_RX_RSR(0))
    		break; 
    }
    WIZ_RD_BUF(0,RX_BUF,6);
    PACK_SIZE(0,len);  
    WIZ_READ_BUF(0, RX_BUF, len);
    WIZ_CLOSE(0);
    
    //dns_parse_reponse();
    query=RX_BUF+(query-TX_BUF);
    while(1){
    	if(*query==0)break;
    	if((*query&0xc0)==0xc0){
    		query++;
    		break;
    	}
    	query++;
    }
    query+=11;
    memcpy(irc_ip,query,4);
    puts("\r\nDNS response OK");   
    //printf(strip,query[0],query[1],query[2],query[3]); 
    //puts(""); 
	*/
	return 1;		// return the size of generated query
}

void msg_send(unsigned char * tbuf){
	strcat(tbuf,"\r\n");
    WIZ_WRITE_BUF(0,tbuf,strlen(tbuf));
}

unsigned char receive(void){
	unsigned int len;
	unsigned char pred=79;
	if(!(len=RD_S_RX_RSR())) return 1;
	//printf("rsr %d ",len);
	while(len!=RD_S_RX_RSR())
		len=RD_S_RX_RSR();
	//printf("rsr %d ",len);
	PACK_SIZE(0,len);
	WIZ_READ_BUF(0, rptr, len);
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
	if(!strcmp(pars.com,"JOIN")){
		printf("%s %s %s\r\n",pars.src,pars.com,pars.msg);
		continue;
	}
	printf("%s> %s\r\n",pars.src,pars.msg);
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
	printf("%s> %s\r\n",irc_nick,kbd_buf.buf);
	while(*p){
		if(*p>=128) 
			*p=*(t866to1251-128+*p);
		p++;
	};
	if(*kbd_buf.buf=='/'){
		msg_send(kbd_buf.buf+1);
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
	printf("Connect to server..");
	iinchip_source_port++; 
    WIZ_SOCKET(0, Sn_MR_TCP, iinchip_source_port);
    WIZ_CONNECT(0,irc_ip,7000);
    while (RD_S_SSR()!=SOCK_ESTABLISHED); 
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
}

void delayms(unsigned char ms)
{
	while(ms--) YIELD();
}

void main(void)
{
    initMCU(); 
    puts("ZX-Evo W5300 test.");
	output(0x82ab,0x50);
	output(0x81ab,0x08);		//socket 0
    config();
	while(1){
	
		if(RD_S_SSR()!=SOCK_ESTABLISHED) {
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
