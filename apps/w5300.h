
#define WIZ_BASE_ADDR 0x00ab

#define WR_MR0(_v) output(0x00ab,_v)
#define RD_MR0() input(0x00ab)
#define WR_MR1(_v) output(0x01ab,_v)
#define RD_MR1() input(0x01ab)


#define WR_S_MR(_v) output(0x01ab,_v)
#define RD_S_MR() input(0x01ab)
#define WR_S_CR(_v) output(0x03ab,_v)
#define RD_S_CR() input(0x03ab)
#define RD_S_SSR() input(0x09ab)
#define WR_S_DPORTR(_v) output(0x12ab,(_v)>>8);output(0x13ab,_v)
#define RD_S_DPORTR() ((input(0x12ab)<<8)|input(0x13ab))
#define WR_S_DIPR0(_v) output(0x14ab,_v)
#define WR_S_DIPR1(_v) output(0x15ab,_v)
#define WR_S_DIPR2(_v) output(0x16ab,_v)
#define WR_S_DIPR3(_v) output(0x17ab,_v)
#define WR_S_PORTR(_v) output(0x0aab,(_v)>>8);output(0x0bab,_v)
#define RD_S_PORTR() ((input(0x0aab)<<8)|input(0x0bab))
#define WR_S_WRSR(_v) output(0x22ab,(_v)>>8);output(0x23ab,_v)
#define RD_S_WRSR() ((input(0x22ab)<<8)|input(0x23ab))
#define RD_S_FSR() ((input(0x26ab)<<8)|input(0x27ab))
#define RD_S_RX_RSR() ((input(0x2aab)<<8)|input(0x2bab))
#define WR_S_TX0(_v) output(0x2eab,_v)
#define WR_S_TX1(_v) output(0x2fab,_v)
#define RD_S_RX0() input(0x30ab)
#define RD_S_RX1() input(0x31ab)

#define IPPROTO_TCP 6
#define IPPROTO_UDP 17

typedef enum {
	INVALID_SOCKET=0, 
	WIZ_SOCKET_0=8, WIZ_SOCKET_1=9, WIZ_SOCKET_2=10, WIZ_SOCKET_3=11,
	WIZ_SOCKET_4=12, WIZ_SOCKET_5=13, WIZ_SOCKET_6=14, WIZ_SOCKET_7=15
}SOCKET;

//#define S_MR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0201))
//#define S_CR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0203))
//#define S_IMR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0204))
//#define S_IR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0206))
//#define S_SSR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0209))
//#define S_PORTR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x020a))
//#define S_DHAR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x020c))
//#define S_DHAR2(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x020E))
//#define S_DHAR4(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x0210))
//#define S_DPORTR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x0212))
//#define S_DIPR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0214))
//#define S_DIPR1(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0215))
//#define S_DIPR2(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0216))
//#define S_DIPR3(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0217))
//#define S_MSSR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x0218))
//#define S_KPALVTR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x021A))
//#define S_PROTOR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x021B))
//#define S_TOSR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x021C))
//#define S_TTLR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x021E))
//#define S_TX_WRSR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x0222))
//#define S_TX_FSR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x0226))
//#define S_RX_RSR(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x022A))
//#define S_FRAGR(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x022C))
//#define S_TX(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x022E))
//#define S_TX1(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x022f))
//#define S_RX(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0230))
//#define S_RX1(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x40+0x0231))
//#define S_RX_LEN(soc_) ((unsigned int*)(WIZ_BASE_ADDR+soc_*0x40+0x0230))
//#define S_RX_FAKE(soc_) ((unsigned char*)(WIZ_BASE_ADDR+soc_*0x0200+0x3000))
/************************************/
/* The bit of MR regsiter defintion */
/************************************/
#define MR_DBW             (1 << 15)            /**< Data bus width bit of MR. */
#define MR_MPF             (1 << 14)            /**< Mac layer pause frame bit of MR. */
#define MR_WDF(X)          ((X & 0x07) << 11)   /**< Write data fetch time bit of  MR. */
#define MR_RDH             (1 << 10)            /**< Read data hold time bit of MR. */
#define MR_FS              (1 << 8)             /**< FIFO swap bit of MR. */
#define MR_RST             (1 << 7)             /**< S/W reset bit of MR. */
#define MR_MT              (1 << 5)             /**< Memory test bit of MR. */
#define MR_PB              (1 << 4)             /**< Ping block bit of MR. */
#define MR_PPPoE           (1 << 3)             /**< PPPoE bit of MR. */
#define MR_DBS             (1 << 2)             /**< Data bus swap of MR. */
#define MR_IND             (1 << 0)             /**< Indirect mode bit of MR. */


/***************************************/ 
/* The bit of Sn_MR regsiter defintion */ 
/***************************************/ 
#define Sn_MR_ALIGN        (1 << 8)             /**< Alignment bit of Sn_MR. */
#define Sn_MR_MULTI        (1 << 7)             /**< Multicasting bit of Sn_MR. */
#define Sn_MR_MF           (1 << 6)             /**< MAC filter bit of Sn_MR. */
#define Sn_MR_IGMPv        (1 << 5)             /**< IGMP version bit of Sn_MR. */
#define Sn_MR_ND           (1 << 5)             /**< No delayed ack bit of Sn_MR. */
#define Sn_MR_CLOSE        0x00                 /**< Protocol bits of Sn_MR. */
#define Sn_MR_TCP          0x01                 /**< Protocol bits of Sn_MR. */
#define Sn_MR_UDP          0x02                 /**< Protocol bits of Sn_MR. */
#define Sn_MR_IPRAW        0x03                 /**< Protocol bits of Sn_MR. */
#define Sn_MR_MACRAW       0x04                 /**< Protocol bits of Sn_MR. */
#define Sn_MR_PPPoE        0x05                 /**< Protocol bits of Sn_MR. */

/******************************/ 
/* The values of CR defintion */ 
/******************************/

#define Sn_CR_OPEN         0x01                 /**< OPEN command value of Sn_CR. */
#define Sn_CR_LISTEN       0x02                 /**< LISTEN command value of Sn_CR. */
#define Sn_CR_CONNECT      0x04                 /**< CONNECT command value of Sn_CR. */
#define Sn_CR_DISCON       0x08                 /**< DISCONNECT command value of Sn_CR. */
#define Sn_CR_CLOSE        0x10                 /**< CLOSE command value of Sn_CR. */
#define Sn_CR_SEND         0x20                 /**< SEND command value of Sn_CR. */
#define Sn_CR_SEND_MAC     0x21                 /**< SEND_MAC command value of Sn_CR. */ 
#define Sn_CR_SEND_KEEP    0x22                 /**< SEND_KEEP command value of Sn_CR */
#define Sn_CR_RECV         0x40                 /**< RECV command value of Sn_CR */
#define Sn_CR_PCON         0x23                 /**< PCON command value of Sn_CR */
#define Sn_CR_PDISCON      0x24                 /**< PDISCON command value of Sn_CR */ 
#define Sn_CR_PCR          0x25                 /**< PCR command value of Sn_CR */
#define Sn_CR_PCN          0x26                 /**< PCN command value of Sn_CR */
#define Sn_CR_PCJ          0x27                 /**< PCJ command value of Sn_CR */

/**********************************/ 
/* The values of Sn_SSR defintion */ 
/**********************************/
#define SOCK_CLOSED        0x00                 /**< SOCKETn is released */
#define SOCK_ARP           0x01                 /**< ARP-request is transmitted in order to acquire destination hardware address. */
#define SOCK_INIT          0x13                 /**< SOCKETn is open as TCP mode. */
#define SOCK_LISTEN        0x14                 /**< SOCKETn operates as "TCP SERVER" and waits for connection-request (SYN packet) from "TCP CLIENT". */
#define SOCK_SYNSENT       0x15                 /**< Connect-request(SYN packet) is transmitted to "TCP SERVER". */
#define SOCK_SYNRECV       0x16                 /**< Connect-request(SYN packet) is received from "TCP CLIENT". */
#define SOCK_ESTABLISHED   0x17                 /**< TCP connection is established. */
#define SOCK_FIN_WAIT      0x18                 /**< SOCKETn is closing. */
#define SOCK_CLOSING       0x1A                 /**< SOCKETn is closing. */
#define SOCK_TIME_WAIT     0x1B                 /**< SOCKETn is closing. */
#define SOCK_CLOSE_WAIT    0x1C                 /**< Disconnect-request(FIN packet) is received from the peer. */
#define SOCK_LAST_ACK      0x1D                 /**< SOCKETn is closing. */
#define SOCK_UDP           0x22                 /**< SOCKETn is open as UDP mode. */
#define SOCK_IPRAW         0x32                 /**< SOCKETn is open as IPRAW mode. */
#define SOCK_MACRAW        0x42                 /**< SOCKET0 is open as MACRAW mode. */
#define SOCK_PPPoE         0x5F                 /**< SOCKET0 is open as PPPoE mode. */


extern unsigned int rx_rd;
	
#define WIZ_RD_BUF(buf_,len_) {\
	unsigned int i=(len_+1)>>1;\
	unsigned char* buf__=buf_;	\
	while (i){					\
		i--;					\
		*(buf__++)=RD_S_RX0();	\
		*(buf__++)=RD_S_RX1();}}	

#define WIZ_READ_BUF(buf_,len_) WIZ_RD_BUF(buf_,len_);	\
	WR_S_CR(Sn_CR_RECV);\
	while(RD_S_CR());
			
#define WIZ_WRITE_BUF(buf_,len_) {unsigned int i=(len_);unsigned char* buf__=(buf_);\
	if(i&1)i++;\
	while (i){\
		i--;i--;\
		WR_S_TX0(*buf__);\
		buf__++; \
		WR_S_TX1(*buf__);\
		buf__++;}}\
	WR_S_WRSR(len_);\
	WR_S_CR(Sn_CR_SEND);\
	while(RD_S_CR());
	
#define WIZ_SOCKET(soc_,smode_,port_) do{	\
    	WR_S_CR(Sn_CR_CLOSE);\
		WR_S_MR(smode_); /* sets TCP mode */\
		WR_S_PORTR(port_); /* sets source port number */\
		WR_S_CR(Sn_CR_OPEN); /* sets OPEN command */\
		while(RD_S_CR());\
	}while(RD_S_SSR() != SOCK_INIT)
	
#define WIZ_LISTEN(soc_) *S_CR(soc_) = Sn_CR_LISTEN

#define WIZ_DISCONNECT(soc_) {*S_CR(soc_) = Sn_CR_DISCON;while(*S_CR(soc_));}

#define WIZ_CLOSE(soc_) *S_CR(soc_) = Sn_CR_CLOSE

#define PACK_SIZE(soc_,len_) {((unsigned char*)(&len_))[1]=RD_S_RX0();\
	((unsigned char*)(&len_))[0]=RD_S_RX1();}
	
#define WIZ_SOC_IPSET(soc_,ip_,port_)	\
	WR_S_DIPR0(ip_[0]);  /* set TCP SERVER IP address*/\
	WR_S_DIPR1(ip_[1]);  /* set TCP SERVER IP address*/\
	WR_S_DIPR2(ip_[2]);  /* set TCP SERVER IP address*/\
	WR_S_DIPR3(ip_[3]);  /* set TCP SERVER IP address*/\
	WR_S_DPORTR(port_)  /* set TCP SERVER listen port number*/
	
		
#define WIZ_CONNECT(soc_,ip_,port_)	\
	WIZ_SOC_IPSET(soc_,ip_,port_);\
	WR_S_CR(Sn_CR_CONNECT);\
	while(RD_S_CR());
	