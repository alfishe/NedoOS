
#include <stdio.h>
#include <Intrz80.h>
#include <string.h>
#include "w5300.h" 
#include "..\oscalls.h" 

unsigned char kbd_buf[128];

void delayms(unsigned char ms);
#define DELAYMS(tick_) delayms((tick_+20)/20)

unsigned char RX_BUF[4*1024];  
unsigned char TX_BUF[4*1024];
unsigned char *rptr=RX_BUF;
const unsigned char strip[]="%d.%d.%d.%d:%d";

static unsigned char ch_hash[16]={0};

unsigned long int_count;   
static unsigned char dns_serv[]={8,8,8,8};
static unsigned char irc_dom[64]="irc.forestnet.org";
static unsigned char ftp_ip[4];
unsigned int ftp_port;
static unsigned char data_ip[4];
unsigned int data_port;
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

void socClose(void){
	WR_S_CR(Sn_CR_CLOSE);
	WR_S_MR(Sn_MR_CLOSE);
}

unsigned int receive(void){
	unsigned int len;
	if(!(len=RD_S_RX_RSR())) return len;
	while(len!=RD_S_RX_RSR())
		len=RD_S_RX_RSR();
	PACK_SIZE(0,len);
	WIZ_READ_BUF(0, RX_BUF, len);
	//conv1251to866(rptr);
	return len;
}

char * gets(char *str)  {
	char *tstr=str;
	//OS_SETXY(0,24);
	while(1)
	{
		char ch=getchar();
		unsigned char x=OS_GETXY();
		YIELD();
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
 
void int_proc(void){  
	int_count++; 
} 
  
unsigned int dns_makequery(void){
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

unsigned int waitRequestCMD(unsigned char i){
	unsigned int len;
	while(1){
		i--;
		if(RD_S_SSR()!=SOCK_ESTABLISHED){
			puts("ftp: connect: Connection timed out");
			socClose();
			return 0;
		}
		if(i==0){
			return 0;
		}
		if(len=receive()) break;
		YIELD();
	}
	*(RX_BUF+len)=0;
	sscanf(RX_BUF,"%d",&len);
	conv1251to866(RX_BUF);
	puts(RX_BUF);
	return len;
}

void msg_send(unsigned char * tbuf){
	strcat(tbuf,"\r\n");
    WIZ_WRITE_BUF(tbuf,strlen(tbuf));
}

unsigned int msg_send_const(const unsigned char * tbuf){
	sprintf(TX_BUF,"%s\r\n",tbuf);
    WIZ_WRITE_BUF(TX_BUF,strlen(TX_BUF));
	return waitRequestCMD(150);
}

#include <icclbutl.h> 
void put_c_in_string(char c, void *ptr)  /* Low-level output */
{
  *(*(char **) ptr)++ = c;
}

unsigned int wiz_printf_cmd(const char *format, ...)   
{                     
    va_list ap;   
    int i;
    char *buf_pft=RX_BUF;   
                    
    va_start(ap, format);      /* Variable argument begin */
    i = _formatted_write(format, put_c_in_string, (void *) &buf_pft, ap);
    va_end(ap);                /* Variable argument end */
	if(i<0) return 0;
	
    *(buf_pft++) = '\r'; 
    *(buf_pft++) = '\n'; 
    *buf_pft = '\0';                 /* String should be terminated with NUL */
    
    WIZ_WRITE_BUF(TX_BUF,i+2); 
       
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

unsigned char reconnect(unsigned int port){
	unsigned char i=3;
	while(i--){
		iinchip_source_port++; 
		WIZ_SOCKET(0, Sn_MR_TCP, iinchip_source_port);
		WIZ_CONNECT(0,ftp_ip,port);
		while (RD_S_SSR()!=SOCK_ESTABLISHED) 
			if(RD_S_SSR()==SOCK_CLOSED) 
				break; 
		return 0;
	}
	socClose();
	return 1;
}

void initMCU(void){
	YIELD();
	OS_SETGFX(6);
	//OS_CLS(7);
	OS_SETXY(0,24);
	*kbd_buf=0x00;
}

void delayms(unsigned char ms){
	while(ms--) YIELD();
}

void cmdOpen(void){
	unsigned char i;
	unsigned int req;
	printf("(to) ");
	gets(kbd_buf);
	i=sscanf(kbd_buf,strip,ftp_ip,ftp_ip+1,ftp_ip+2,ftp_ip+3,&ftp_port);
	if(i!=5){
		if(i!=4){
			puts("ftp: connect: Connection timed out");
			return;
		}
		ftp_port=21;
	}
	output(0x81ab,0x0a);		//socket 2
	if(reconnect(ftp_port)){
		puts("ftp: connect: Connection timed out");
		return;
	}
	while(1){
		req=waitRequestCMD(150);
		if(req==0){
			return;
		}
		if(req==220){
			printf("Name: ");
			gets(kbd_buf);
			sprintf(TX_BUF,"USER %s",kbd_buf);
			msg_send(TX_BUF);		
		}else if(req==331){
			printf("Password: ");
			gets(kbd_buf);
			sprintf(TX_BUF,"PASS %s",kbd_buf);
			msg_send(TX_BUF);		
		}else if(req==230){
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
		data_ip,data_ip+1,data_ip+2,data_ip+3,&req,&data_port);
	if(i!=6) return 1;
	data_port+=req<<8;
	output(0x81ab,0x0b);
	i = reconnect(data_port);
	output(0x81ab,0x0a);
	return i;
}

void cmdDir(void){
	unsigned int len;
	if(msg_send_const("PWD")!=257) return;
	if(getDataSoc()==1)return;
	if(msg_send_const("TYPE A")!=200){
		output(0x81ab,0x0b);
		socClose();
		output(0x81ab,0x0a);
		return;
	}
	if(msg_send_const("LIST")!=125){
		output(0x81ab,0x0b);
		socClose();
		output(0x81ab,0x0a);
		return;
	}
	output(0x81ab,0x0b);
	while(1){
		if((len=receive())==0){
			if(RD_S_SSR()!=SOCK_ESTABLISHED) break;
		}
		*(RX_BUF+len)=0;
		conv1251to866(RX_BUF);
		puts(RX_BUF);
	}
	socClose();
	output(0x81ab,0x0a);
	waitRequestCMD(100);
}

void cmdRetr(void){
	unsigned int len;
	//unsigned int file;
	if(msg_send_const("PWD")!=257) return;
	if(getDataSoc()==1)return;
	if(msg_send_const("TYPE I")!=200){
		output(0x81ab,0x0b);
		socClose();
		output(0x81ab,0x0a);
		return;
	}
	if(msg_send_const("RETR")!=125){
		output(0x81ab,0x0b);
		socClose();
		output(0x81ab,0x0a);
		return;
	}
	//file=OS_CREATEHANDLE();
	output(0x81ab,0x0b);
	while(1){
		if((len=receive())==0){
			if(RD_S_SSR()!=SOCK_ESTABLISHED) break;
		}
		*(RX_BUF+len)=0;
		conv1251to866(RX_BUF);
		puts(RX_BUF);
	}
	socClose();
	output(0x81ab,0x0a);
	waitRequestCMD(100);
}

//extern unsigned char cmdlist[256];
void main(void)
{
    initMCU(); 
	printf("dmftp v.%s %s\r\n",__DATE__,__TIME__);
	output(0x82ab,0x50);
	output(0x81ab,0x0a);		//socket 2
	socClose();
	while(1){
		output(0x81ab,0x0a);
		if(waitRequestCMD(1))continue;
		printf("ftp> ");
		gets(kbd_buf);
		if(*kbd_buf==0x00)continue;
		switch(*kbd_buf){
			case 'd':
				if(!strcmp(kbd_buf,"dir")){
					cmdDir();
				}else if(!strncmp(kbd_buf,"del ",4)){
					sprintf(TX_BUF,"DELE %s",kbd_buf+4);
					msg_send(TX_BUF);
					waitRequestCMD(150);
				}
				break;
			case 'c':
				if(!strncmp(kbd_buf,"cd ",3)){
					sprintf(TX_BUF,"CWD %s",kbd_buf+3);
					msg_send(TX_BUF);
					waitRequestCMD(150);
				}else if(!strcmp(kbd_buf,"close")){
					msg_send_const("QUIT");
					waitRequestCMD(1);
				}
				break;
			case 'm':
				if(!strncmp(kbd_buf,"mkd ",4)){
					sprintf(TX_BUF,"MKD %s",kbd_buf+4);
					msg_send(TX_BUF);
					waitRequestCMD(150);
				}
				break;
			case 'q':
				if(!strcmp(kbd_buf,"quit")){
					msg_send_const("QUIT");
					return;
				}
				break;
			case 'r':
				if(!strncmp(kbd_buf,"rmd ",4)){
					sprintf(TX_BUF,"RMD %s",kbd_buf+4);
					msg_send(TX_BUF);
					waitRequestCMD(150);
				}
				break;
			case 'o':
				if(!strcmp(kbd_buf,"open")){
					cmdOpen();
				}
				break;
			default:
				puts("open - connect to server, close - close connection, quit - quit to OS");
				puts("dir  - view directory,    cd    - change directory, mkd  - create directory");
				puts("rmd  - remove directory,  del   - delete file");
			break;
		} 
	}
}   
