
#include <stdio.h>
#include <string.h>
#include <stdio.h>
#include <intrz80.h>
#include "w5300.h" 
#include "..\oscalls.h" 
    
void my_im2_init(void *);
const unsigned char mac[]={0x02,0x02,0x6A,0x6A,0x3B,0x3B};
unsigned char ip[4];
unsigned char mask[4];
unsigned char gw[4];
unsigned char dns[4];
unsigned char dhcps[4];
unsigned long TrID=0x51e7baab; 
unsigned char buf_rx[2*1024];
unsigned char buf_tx[2*1024];
unsigned char save_pg;
const unsigned char strip[]="%d.%d.%d.%d\r\n";

void sd_wr_next(unsigned int);
void sd_wr_stop(void);
	
void DelayMs(unsigned int nFactor)   {    
	nFactor=nFactor/20;
    while(nFactor)   
    {   
    	nFactor--;
		halt();
    } 
}   

void wiz_reset(void){
	save_pg=(input(0x0abe)&0x10)?input(0x02be):input(0x06be);
	output(0xbff7,0);
	output(0x83ab,0);
	DelayMs(10);
	output(0x83ab,0x10);
	DelayMs(50);
	output(0x82ab,0x46);
	*(WMR+1)=0x80;
	while(*(WMR+1)&0x80);
	//DelayMs(500);
	//*WMR=0x00;
}

interrupt void myint(void){
}

unsigned int lenp;
unsigned char ch;
void socinit(void){
	while(1){
		*S_CR(0)=Sn_CR_CLOSE;
		while(*S_CR(0)!=0);
	
		*S_MR(0)=Sn_MR_UDP;
		*S_PORTR(0)=68<<8;
		*S_CR(0)=Sn_CR_OPEN;
		while(*S_CR(0)!=0);
		ch=*S_SSR(0);
		if(*S_SSR(0)==SOCK_UDP){
			break;
		}
	}
}

unsigned int fillstruct(void){
	unsigned char *tx=buf_tx+240;
	memset(tx,0x00,240);
	*buf_tx=1;		//Message type: Boot Request (1)
	*(buf_tx+1)=0x01;		//Hardware type: Ethernet (0x01)
	*(buf_tx+2)=6;		//Hardware address length: 6
	*((unsigned long*)(buf_tx+4))=TrID;	//Transaction ID: 0x51e7baab
	*((unsigned int*)(buf_tx+10))=0x0080;	//Bootp flags: 0x8000 (Broadcast)
	memcpy(buf_tx+28,mac,6);			//Client MAC address
	*((unsigned long*)(buf_tx+236))=0x63538263;	//Magic cookie: DHCP
	*((unsigned long*)tx)=0x00010135;	//Option: (53) DHCP Message Type
	tx+=3;
	*((unsigned long*)tx)=0x06010337;	//Option: (55) Parameter Request List
	tx+=4;
	*tx=0x03;	//rooter & DNS
	tx++;
	*((unsigned long*)tx)=0x0001073d;	//
	tx+=3;
	memcpy(tx,mac,6);
	tx+=6;
	*((unsigned int*)tx)=0x050c;	//
	tx+=2;
	memcpy(tx,"ZXEvo",5);
	tx+=5;
	
	*tx=0xff;
	tx++;
	return tx-buf_tx;
}

void sendp(void){
	unsigned int i=lenp;
	unsigned char *tx=buf_tx;
	unsigned long t;
	*((unsigned long*)S_DHAR(0))=0xffffffff;	
	*((unsigned int*)(S_DHAR(0)+2))=0xffff;	
	*((unsigned long*)S_DIPR(0))=0xffffffff;	
	t=*((unsigned long*)S_DIPR(0));
	*S_DPORTR(0)=67<<8;
	while(i>1){
		i-=2;
		*S_TX(0)=*tx;
		tx++;
		*S_TX1(0)=*tx;
		tx++;
	}
	if(i){
		*S_TX(0)=*tx;
		*S_TX1(0)=0;
	}
	*S_TX_WRSR(0)=(lenp>>8)+(lenp<<8);
	
	*S_CR(0)=Sn_CR_SEND;
	while(*S_CR(0)!=0);
	while(*S_TX_FSR(0)!=0x0020);
}
	
unsigned int recvp(void){
	unsigned int i=32;
	unsigned char *rx=buf_rx;
	
	while(1){
		if((--i)==0)return 0;
		if(*S_RX_RSR(0))break;
		DelayMs(100);
	}
	i=*S_RX_LEN(0);
	i=*S_RX_LEN(0);
	i=*S_RX_LEN(0);
	i=*S_RX_LEN(0);
	i=(i>>8)+(i<<8);
	while(i>1){
		i-=2;
		*rx=*S_RX(0);
		rx++;
		*rx=*S_RX1(0);
		rx++;
	}
	if(i){
		*rx=*S_RX(0);
		rx++;
		*rx=*S_RX1(0);
	}
	*S_CR(0)=Sn_CR_RECV;
	while(*S_CR(0)!=0);
	if(*((unsigned long*)(buf_rx+4))!=TrID) return 1;
	if(memcmp(mac,buf_rx+28,6)) return 1;
	return 2;
}
	
unsigned int fillstruct2(void){
	unsigned char *tx=buf_tx+240;
	*((unsigned long*)tx)=0x00030135;	//Option: (53) DHCP Message Type
	tx+=3;
	
	*((unsigned int*)tx)=0x0436;	//
	tx+=2;
	memcpy(tx,dhcps,4);
	tx+=4;
	*((unsigned int*)tx)=0x0432;	//
	tx+=2;
	memcpy(tx,ip,4);
	tx+=4;
	*((unsigned long*)tx)=0x0001073d;	//
	tx+=3;
	memcpy(tx,mac,6);
	tx+=6;
	*((unsigned int*)tx)=0x050c;	//
	tx+=2;
	memcpy(tx,"ZXEvo",5);
	tx+=5;
	
	*tx=0xff;
	tx++;
	return tx-buf_tx;
}

void parseOffer(void){
	unsigned char *rx=buf_rx+240;
	memcpy(ip,buf_rx+16,4);
	while(1){
		if(*rx==0xff)break;
		
		switch(*rx){
			case 0x36:
				memcpy(dhcps,rx+2,4);
				break;
			case 0x06:
				memcpy(dns,rx+2,4);
				break;
			case 0x03:
				memcpy(gw,rx+2,4);
				break;
			case 0x01:
				memcpy(mask,rx+2,4);
				break;
		}
		rx+=*(rx+1)+2;
	}
}

void main(void){ 
	unsigned char st=0;
	YIELD();
	printf("dhcpc v.%s %s",__DATE__,__TIME__);
	my_im2_init(myint);
	enable_interrupt();
	wiz_reset();
	memcpy(SHAR,mac,6); 
	lenp=*WID;
	memset(GAR,0x00,12);
	DelayMs(1000);
	//socinit();
	//lenp=2;
	//lenp=fillstruct();
	//sendp();
	while(1){
		if(st==0){
			TrID++;
			socinit();
			lenp=fillstruct();
			sendp();
			st=1;
			continue;
		}else if(st==1){
			st=recvp();
			continue;
		}else if(st==2){
			parseOffer();
			lenp=fillstruct2();
			sendp();
			st=recvp();
			break;
		}
		
	}
	*S_CR(0)=Sn_CR_CLOSE;
	while(*S_CR(0)!=0);
	memcpy(GAR,gw,4);
	memcpy(SUBR,mask,4);
	memcpy(SIPR,ip,4);
	disable_interrupt();
	output(0x82ab,0x40);
	output(0xb7f7,save_pg);
	interrupt_mode_1();
	enable_interrupt();
	
    printf("\r\ngateway ");   
    printf(strip,gw[0],gw[1],gw[2],gw[3]);  
    printf("mask ");   
    printf(strip,mask[0],mask[1],mask[2],mask[3]); 
    printf("ip ");   
    printf(strip,ip[0],ip[1],ip[2],ip[3]); 
    printf("dns ");   
    printf(strip,dns[0],dns[1],dns[2],dns[3]); 
}

