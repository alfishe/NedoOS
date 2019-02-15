WIZ_BASE_ADDR=0x00ab
WIZ_SOCK0_HNDL=8
WIZ_REGAD_PORT=0x8100+WIZ_BASE_ADDR

WIZ_S_MR=0x01
WIZ_S_CR=0x03
WIZ_S_SSR=0x09
WIZ_S_PORTR_H=0x0a
WIZ_S_PORTR_L=0x0b
WIZ_S_DPORTR_H=0x12
WIZ_S_DPORTR_L=0x13
WIZ_S_DIPR0=0x14
WIZ_S_DIPR1=0x15
WIZ_S_DIPR2=0x16
WIZ_S_DIPR3=0x17
WIZ_S_WRSR_H=0x22
WIZ_S_WRSR_L=0x23
WIZ_S_FSR_H=0x26
WIZ_S_FSR_L=0x27
WIZ_S_RX_RSR_H=0x2a
WIZ_S_RX_RSR_L=0x2b
WIZ_S_TX_H=0x2e
WIZ_S_TX_L=0x2f
WIZ_S_RX_H=0x30
WIZ_S_RX_L=0x31

IPPROTO_TCP=6
IPPROTO_UDP=17

AF_UNSPEC=0
AF_INET=2
AF_INET6=23

SOCK_STREAM=0x01	;tcp/ip
SOCK_DGRAM=0x03		;udp/ip
INVALID_SOCKET=0xff

SHUT_RDWR=2
ERR_INTR=-4
ERR_NFILE=-23
ERR_NOTSOCK=-38
ERR_PROTOTYPE=-41
ERR_AFNOSUPPORT=-47
;struct sockaddr_in {short sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};



;/***************************************/ 
;/* The bit of Sn_MR regsiter defintion */ 
;/***************************************/ 
Sn_MR_ALIGN        =(1 << 8)             ;< Alignment bit of Sn_MR. */
Sn_MR_MULTI        =(1 << 7)             ;< Multicasting bit of Sn_MR. */
Sn_MR_MF           =(1 << 6)             ;< MAC filter bit of Sn_MR. */
Sn_MR_IGMPv        =(1 << 5)             ;< IGMP version bit of Sn_MR. */
Sn_MR_ND           =(1 << 5)             ;< No delayed ack bit of Sn_MR. */
Sn_MR_CLOSE        =0x00                 ;< Protocol bits of Sn_MR. */
Sn_MR_TCP          =0x01                 ;< Protocol bits of Sn_MR. */
Sn_MR_UDP          =0x02                 ;< Protocol bits of Sn_MR. */
Sn_MR_IPRAW        =0x03                 ;< Protocol bits of Sn_MR. */
Sn_MR_MACRAW       =0x04                 ;< Protocol bits of Sn_MR. */
Sn_MR_PPPoE        =0x05                 ;< Protocol bits of Sn_MR. */

;/******************************/ 
;/* The values of CR defintion */ 
;/******************************/

Sn_CR_OPEN         =0x01                 ;< OPEN command value of Sn_CR. */
Sn_CR_LISTEN       =0x02                 ;< LISTEN command value of Sn_CR. */
Sn_CR_CONNECT      =0x04                 ;< CONNECT command value of Sn_CR. */
Sn_CR_DISCON       =0x08                 ;< DISCONNECT command value of Sn_CR. */
Sn_CR_CLOSE        =0x10                 ;< CLOSE command value of Sn_CR. */
Sn_CR_SEND         =0x20                 ;< SEND command value of Sn_CR. */
Sn_CR_SEND_MAC     =0x21                 ;< SEND_MAC command value of Sn_CR. */ 
Sn_CR_SEND_KEEP    =0x22                 ;< SEND_KEEP command value of Sn_CR */
Sn_CR_RECV         =0x40                 ;< RECV command value of Sn_CR */
Sn_CR_PCON         =0x23                 ;< PCON command value of Sn_CR */
Sn_CR_PDISCON      =0x24                 ;< PDISCON command value of Sn_CR */ 
Sn_CR_PCR          =0x25                 ;< PCR command value of Sn_CR */
Sn_CR_PCN          =0x26                 ;< PCN command value of Sn_CR */
Sn_CR_PCJ          =0x27                 ;< PCJ command value of Sn_CR */

;/**********************************/ 
;/* The values of Sn_SSR defintion */ 
;/**********************************/
SOCK_CLOSED        =0x00                 ;< SOCKETn is released */
SOCK_ARP           =0x01                 ;< ARP-request is transmitted in order to acquire destination hardware address. */
SOCK_INIT          =0x13                 ;< SOCKETn is open as TCP mode. */
SOCK_LISTEN        =0x14                 ;< SOCKETn operates as "TCP SERVER" and waits for connection-request (SYN packet) from "TCP CLIENT". */
SOCK_SYNSENT       =0x15                 ;< Connect-request(SYN packet) is transmitted to "TCP SERVER". */
SOCK_SYNRECV       =0x16                 ;< Connect-request(SYN packet) is received from "TCP CLIENT". */
SOCK_ESTABLISHED   =0x17                 ;< TCP connection is established. */
SOCK_FIN_WAIT      =0x18                 ;< SOCKETn is closing. */
SOCK_CLOSING       =0x1A                 ;< SOCKETn is closing. */
SOCK_TIME_WAIT     =0x1B                 ;< SOCKETn is closing. */
SOCK_CLOSE_WAIT    =0x1C                 ;< Disconnect-request(FIN packet) is received from the peer. */
SOCK_LAST_ACK      =0x1D                 ;< SOCKETn is closing. */
SOCK_UDP           =0x22                 ;< SOCKETn is open as UDP mode. */
SOCK_IPRAW         =0x32                 ;< SOCKETn is open as IPRAW mode. */
SOCK_MACRAW        =0x42                 ;< SOCKET0 is open as MACRAW mode. */
SOCK_PPPoE         =0x5F                 ;< SOCKET0 is open as PPPoE mode. */
		
wizlocalport:
		defw 0xc000
wiznet_open
;L-subfunction
		ex af,af'
		dec l
		jp z,w53_socket
		dec l
		jp z,w53_close
		ld a,ERR_INTR	;функция не существует
		ret
w53_socket:
;E-socket type, D-address family
;ищем свободный сокет
		ld a,AF_INET
		cp d
		ld a,ERR_AFNOSUPPORT
		ret nz
		ld l,WIZ_SOCK0_HNDL-1
		ld bc,WIZ_REGAD_PORT
w53_socket0:
		inc l
		ld a,l
		cp WIZ_SOCK0_HNDL+8
		jr nz,w53_socket1
		;ld b,INVALID_SOCKET
		ld a,ERR_NFILE ;все сокеты заняты
		ret
w53_socket1:
		out (c),a
		ld a,WIZ_S_MR
		in a,(WIZ_BASE_ADDR&0xFF)
		or a
		jr nz,w53_socket0
		ld a,e
		ld d,Sn_MR_TCP
		cp SOCK_STREAM
		jr z,w53_socket2
		ld d,Sn_MR_UDP
		cp SOCK_DGRAM
		jr z,w53_socket2
		ld a,ERR_PROTOTYPE
		ret
w53_socket2:
		ld b,WIZ_S_MR
		out (c),d
		ld de,(wizlocalport)
		inc de
		set 6,d
		set 7,d
		ld (wizlocalport),de
		ld b,WIZ_S_PORTR_H
		out (c),d
		inc b
		out (c),e
		ld a,l
        ret

w53_valid_cocket:
		cp WIZ_SOCK0_HNDL
		jr c,w53_invalid_socked
		cp WIZ_SOCK0_HNDL+8
		jr nc,w53_invalid_socked
		ld bc,WIZ_REGAD_PORT
		out (c),a
		ret
w53_invalid_socked:
		pop af
		ld a,ERR_NOTSOCK 
		ret
		
w53_close:
		call w53_valid_cocket
		ld b,WIZ_S_MR
		in a,(c)
		or a	;сокет убит
		ret z
		cp Sn_MR_TCP
		jr nz,w53_close0
w53_close1:
		ld b,WIZ_S_SSR
		in a,(c)
		or a	;уже закрыт
		jr z,w53_close3
		cp SOCK_CLOSE_WAIT	;вторая сторона ждёт закрытия
		jr z,w53_close0
		cp SOCK_INIT
		jr z,w53_close0
		cp SOCK_LISTEN
		jr z,w53_close0
		cp SOCK_ESTABLISHED
		jr nz,w53_closewait
w53_sendFIN:
		ld a,Sn_CR_DISCON
		call w53_cmd
		jr w53_close1
w53_closewait:	;нужно подождать
		ld a,SHUT_RDWR
		ret
w53_close0:
		ld a,Sn_CR_CLOSE
		call w53_cmd
		ld b,WIZ_S_SSR
w53_close2:
		in a,(c)
		or a
		jr nz,w53_close2
w53_close3:
		xor a
		ld b,WIZ_S_MR
		out (c),a
		ret
		
w53_cmd:
		ld b,WIZ_S_CR
		out (c),a
w53_cmd0:
		in a,(c)
		or a
		ret z
		jr w53_cmd0
		
wiznet_close:
        ret
wiznet_read:
        ret
wiznet_write:
        ret
