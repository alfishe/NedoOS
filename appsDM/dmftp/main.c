
#include <stdio.h>
#include <string.h>
#include "..\oscalls.h" 

unsigned char kbd_buf[128];

void delayms(unsigned char ms);
#define DELAYMS(tick_) delayms((tick_+20)/20)

unsigned char RX_BUF[4*1024];  
unsigned char TX_BUF[4*1024];
unsigned char *rptr=RX_BUF;
const unsigned char strip[]="%d.%d.%d.%d:%d";


unsigned long int_count;   
static unsigned char irc_dom[64];
struct sockaddr_in ftp_ia;
unsigned int ftp_port;
unsigned int data_port;
unsigned int dns_makequery(void);

SOCKET cmds=0;
SOCKET datasoc=0;


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

#include <icclbutl.h> 
void put_c_in_string(char c, void *ptr){
  *(*(char **) ptr)++ = c;
}

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
	//output(0x81ab,soc);
	ftp_ia.sin_port=htons(port);
	while(i--){
		*soc=socket(AF_INET,SOCK_STREAM,0);
		if(*soc<0)continue;
		if(connect(*soc, &ftp_ia, sizeof(ftp_ia))<0){
			closesocket(*soc,0);
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

void delayms(unsigned char ms){
	while(ms--) YIELD();
}

void cmdOpen(void){
	unsigned char i;
	unsigned int req;
	printf("(to) ");
	gets(kbd_buf);
	i=sscanf(kbd_buf,strip,&ftp_ia.sin_addr.S_un.S_un_b.s_b1,&ftp_ia.sin_addr.S_un.S_un_b.s_b2
	,&ftp_ia.sin_addr.S_un.S_un_b.s_b3,&ftp_ia.sin_addr.S_un.S_un_b.s_b4,&ftp_port);
	if(i!=5){
		if(i!=4){
			puts("ftp: connect: Connection timed out");
			return;
		}
		ftp_port=21;
	}
	if(reconnect(&cmds, ftp_port)){
		puts("ftp: connect: Connection timed out");
		return;
	}
	req=waitRequestCMD(150);
	while(req!=0){
		if(req==220){
			printf("Name: ");
			gets(kbd_buf);
			req=wiz_printf_cmd("USER %s",kbd_buf);
		}else if(req==331){
			printf("Password: ");
			gets(kbd_buf);
			req=wiz_printf_cmd("PASS %s",kbd_buf);
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
	if(msg_send_const("PWD")!=257) return;
	if(getDataSoc()==1)return;
	if(msg_send_const("TYPE A")!=200){
		closesocket(datasoc,0);
		return;
	}
	if(msg_send_const("LIST")!=125){
		closesocket(datasoc,0);
		return;
	}
	while(1){
		len=recv(datasoc,RX_BUF,sizeof(RX_BUF),0);
		if(len<0){
			closesocket(datasoc, 0);
			break;
		}else if(len!=0){
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
	if(msg_send_const("PWD")!=257) return;
	if(getDataSoc()==1)return;
	if(msg_send_const("TYPE I")!=200){
		closesocket(datasoc, 0);
		return;
	}
	if(wiz_printf_cmd("RETR %s",kbd_buf+4)!=125){
		closesocket(datasoc, 0);
		return;
	}
	file=OS_CREATEHANDLE(kbd_buf+4,0x80);
	if(file&0xff){
		closesocket(datasoc, 0);
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
		}
	}
	closesocket(datasoc, 0);
	OS_CLOSEHANDLE(file);
	waitRequestCMD(100);
}

void cmdStor(void){
	int res;
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
	if(wiz_printf_cmd("STOR %s",kbd_buf+4)!=125){
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
	OS_CLOSEHANDLE(file);
	waitRequestCMD(100);
}

void main(void)
{
    initMCU(); 
	printf("dmftp v.%s %s\r\n",__DATE__,__TIME__);
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
					return;
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
				puts("open - connect to server, close - close connection, quit - quit to OS");
				puts("dir  - view directory,    cd    - change directory, mkd  - create directory");
				puts("rmd  - remove directory,  del   - delete file");
			break;
		} 
	}
}   
