
WIZ_BASE_ADDR EQU 0x00ab
WIZ_SOCK0_HNDL EQU 8
WIZ_REGAD_PORT EQU 0x8100+WIZ_BASE_ADDR

WIZ_S_MR EQU 0x01
WIZ_S_CR EQU 0x03
WIZ_S_SSR EQU 0x09
WIZ_S_PORTR_H EQU 0x0a
WIZ_S_PORTR_L EQU 0x0b
WIZ_S_DPORTR_H EQU 0x12
WIZ_S_DPORTR_L EQU 0x13
WIZ_S_DIPR0 EQU 0x14
WIZ_S_DIPR1 EQU 0x15
WIZ_S_DIPR2 EQU 0x16
WIZ_S_DIPR3 EQU 0x17
WIZ_S_WRSR_H EQU 0x22
WIZ_S_WRSR_L EQU 0x23
WIZ_S_FSR_H EQU 0x26
WIZ_S_FSR_L EQU 0x27
WIZ_S_RX_RSR_H EQU 0x2a
WIZ_S_RX_RSR_L EQU 0x2b
WIZ_S_TX_H EQU 0x2e
WIZ_S_TX_L EQU 0x2f
WIZ_S_RX_H EQU 0x30
WIZ_S_RX_L EQU 0x31

IPPROTO_TCP EQU 6
IPPROTO_UDP EQU 17

AF_UNSPEC EQU 0
AF_INET EQU 2
AF_INET6 EQU 23

SOCK_STREAM EQU 0x01	;tcp/ip
SOCK_DGRAM 	EQU 0x03		;udp/ip

SHUT_RDWR 		EQU 2
ERR_EAGAIN		EQU 35		;/* Try again */
ERR_EWOULDBLOCK	EQU ERR_EAGAIN	;/* Operation would block */
ERR_INTR 		EQU 4
ERR_NFILE 		EQU 23
ERR_ALREADY 	EQU 37
ERR_NOTSOCK 	EQU 38
ERR_EMSGSIZE 	EQU 40    ;/* Message too long */
ERR_PROTOTYPE 	EQU 41
ERR_AFNOSUPPORT EQU 47
ERR_HOSTUNREACH EQU 65
ERR_CONNRESET 	EQU 54
ERR_NOTCONN 	EQU 57
;struct sockaddr_in {short sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};

;/***************************************/ 
;/* The bit of Sn_MR regsiter defintion */ 
;/***************************************/ 
Sn_MR_ALIGN         EQU (1 << 8)             ;< Alignment bit of Sn_MR. */
Sn_MR_MULTI         EQU (1 << 7)             ;< Multicasting bit of Sn_MR. */
Sn_MR_MF            EQU (1 << 6)             ;< MAC filter bit of Sn_MR. */
Sn_MR_IGMPv         EQU (1 << 5)             ;< IGMP version bit of Sn_MR. */
Sn_MR_ND            EQU (1 << 5)             ;< No delayed ack bit of Sn_MR. */
Sn_MR_CLOSE         EQU 0x00                 ;< Protocol bits of Sn_MR. */
Sn_MR_TCP           EQU 0x01                 ;< Protocol bits of Sn_MR. */
Sn_MR_UDP           EQU 0x02                 ;< Protocol bits of Sn_MR. */
Sn_MR_IPRAW         EQU 0x03                 ;< Protocol bits of Sn_MR. */
Sn_MR_MACRAW        EQU 0x04                 ;< Protocol bits of Sn_MR. */
Sn_MR_PPPoE         EQU 0x05                 ;< Protocol bits of Sn_MR. */

;/******************************/ 
;/* The values of CR defintion */ 
;/******************************/

Sn_CR_OPEN          EQU 0x01                 ;< OPEN command value of Sn_CR. */
Sn_CR_LISTEN        EQU 0x02                 ;< LISTEN command value of Sn_CR. */
Sn_CR_CONNECT       EQU 0x04                 ;< CONNECT command value of Sn_CR. */
Sn_CR_DISCON        EQU 0x08                 ;< DISCONNECT command value of Sn_CR. */
Sn_CR_CLOSE         EQU 0x10                 ;< CLOSE command value of Sn_CR. */
Sn_CR_SEND          EQU 0x20                 ;< SEND command value of Sn_CR. */
Sn_CR_SEND_MAC      EQU 0x21                 ;< SEND_MAC command value of Sn_CR. */ 
Sn_CR_SEND_KEEP     EQU 0x22                 ;< SEND_KEEP command value of Sn_CR */
Sn_CR_RECV          EQU 0x40                 ;< RECV command value of Sn_CR */
Sn_CR_PCON          EQU 0x23                 ;< PCON command value of Sn_CR */
Sn_CR_PDISCON       EQU 0x24                 ;< PDISCON command value of Sn_CR */ 
Sn_CR_PCR           EQU 0x25                 ;< PCR command value of Sn_CR */
Sn_CR_PCN           EQU 0x26                 ;< PCN command value of Sn_CR */
Sn_CR_PCJ           EQU 0x27                 ;< PCJ command value of Sn_CR */

;/**********************************/ 
;/* The values of Sn_SSR defintion */ 
;/**********************************/
SOCK_CLOSED         EQU 0x00                 ;< SOCKETn is released */
SOCK_ARP            EQU 0x01                 ;< ARP-request is transmitted in order to acquire destination hardware address. */
SOCK_INIT           EQU 0x13                 ;< SOCKETn is open as TCP mode. */
SOCK_LISTEN         EQU 0x14                 ;< SOCKETn operates as "TCP SERVER" and waits for connection-request (SYN packet) from "TCP CLIENT". */
SOCK_SYNSENT        EQU 0x15                 ;< Connect-request(SYN packet) is transmitted to "TCP SERVER". */
SOCK_SYNRECV        EQU 0x16                 ;< Connect-request(SYN packet) is received from "TCP CLIENT". */
SOCK_ESTABLISHED    EQU 0x17                 ;< TCP connection is established. */
SOCK_FIN_WAIT       EQU 0x18                 ;< SOCKETn is closing. */
SOCK_CLOSING        EQU 0x1A                 ;< SOCKETn is closing. */
SOCK_TIME_WAIT      EQU 0x1B                 ;< SOCKETn is closing. */
SOCK_CLOSE_WAIT     EQU 0x1C                 ;< Disconnect-request(FIN packet) is received from the peer. */
SOCK_LAST_ACK       EQU 0x1D                 ;< SOCKETn is closing. */
SOCK_UDP            EQU 0x22                 ;< SOCKETn is open as UDP mode. */
SOCK_IPRAW          EQU 0x32                 ;< SOCKETn is open as IPRAW mode. */
SOCK_MACRAW         EQU 0x42                 ;< SOCKET0 is open as MACRAW mode. */
SOCK_PPPoE          EQU 0x5F                 ;< SOCKET0 is open as PPPoE mode. */
		
wizlocalport:
		defw 0xc000

wiznet_open
;L-subfunction
		dec l
		jp z,w53_socket
		dec l
		jp z,w53_close
		dec l
		jp z,w53_connect
		ld a,ERR_INTR	;функци€ не существует
		ld hl,-1
		ret
w53_socket:
;E-socket type, D-address family
;ищем свободный сокет
		ld l,-1
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
		ld l,-1
		ld a,ERR_NFILE ;все сокеты зан€ты
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
		ld l,-1
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
		;add a,l:ld l,a:adc a,h:sub l:ld h,a
		ld a,l
		add a,a
		add a,a
		add a,0xff&(w53_socflags+2-32)
		ld e,a
		adc a,0xff&((w53_socflags+2-32)>>8)
		sub e
		ld d,a
		xor a
		ld (de),a
		inc de
		ld (de),a
		ld h,a
        ret

w53_valid_socket:
		ex af,af'
		cp WIZ_SOCK0_HNDL
		jr c,w53_invalid_socked
		cp WIZ_SOCK0_HNDL+8
		jr nc,w53_invalid_socked
		ld bc,WIZ_REGAD_PORT
		out (c),a
		add a,a
		add a,a
		ld c,a
		ld b,0
		ld ix,w53_socflags-32
		add ix,bc
		ld bc,WIZ_BASE_ADDR+(WIZ_S_MR<<8)
		in a,(c)
		or a	
		ret
w53_invalid_socked:
		pop af
w53_invalid_socked0:
		ld hl,-1
		ld a,ERR_NOTSOCK 
		ret

w53_connect:
;DE-sockaddr_in
		ld l,-1
		call w53_valid_socket
		jp z,w53_invalid_socked0
		;dec a
		;ld a,ERR_PROTOTYPE
		;ret nz
		ld b,WIZ_S_SSR
		in a,(c)
		or a
		ld a,ERR_ALREADY
		ret nz
		ld a,Sn_CR_OPEN
		call w53_cmd
		ld b,WIZ_S_SSR
w53_connect0:
		in a,(c)
		or a
		jr z,w53_connect0
		call BDOS_preparedepage
		ex de,hl
		inc hl	;пропустим семейство
		ld bc,WIZ_BASE_ADDR+(WIZ_S_DPORTR_L<<8)
		ld a,6
w53_connect1:
		outi
		inc b
		inc b
		dec a
		jr nz,w53_connect1
		ld b,WIZ_S_MR
		in a,(c)
		cp Sn_MR_TCP
		jr nz,w53_connect3
		ld a,Sn_CR_CONNECT
		call w53_cmd
		ld b,WIZ_S_SSR
w53_connect2:
		in a,(c)
		cp SOCK_ESTABLISHED
		jr z,w53_connect3
		or a
		jr nz,w53_connect2
		ld l,-1
		ld a,ERR_HOSTUNREACH
		ret
w53_connect3:
		xor a
		ld l,a
		ret
		
w53_close:
		call w53_valid_socket
		ld l,0
		ret z	;сокет уже убит
		dec l
		ex af,af'
		ld a,e
		or a
		jr z,w53_close_nochk
		ld b,WIZ_S_FSR_L	;проверим пуст ли буфер отправки
		in e,(c)
		jr nz,w53_close_nochk
		dec b
		in a,(c)
		cp 0x20
		jr z,w53_close_nochk
		inc e 
w53_close_nochk:
		ex af,af'
		cp Sn_MR_TCP
		jr nz,w53_close0
w53_close1:
		ld b,WIZ_S_SSR
		in a,(c)
		or a	;уже закрыт
		jr z,w53_close3
		cp SOCK_CLOSE_WAIT	;втора€ сторона ждЄт закрыти€
		jr z,w53_close_wait
		cp SOCK_INIT
		jr z,w53_close0
		cp SOCK_LISTEN
		jr z,w53_close0
		cp SOCK_ESTABLISHED
		jr nz,w53_close0	;w53_closewait
		ld a,e
		or a
		ld a,ERR_EAGAIN
		ret nz
		ld a,Sn_CR_DISCON
		call w53_cmd
		jr w53_close1
w53_close0:
		ld a,e
		or a
		ld a,ERR_EAGAIN
		ret nz
w53_close_wait:
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
		ld l,a
		ret
		
w53_cmd:
		ld b,WIZ_S_CR
		out (c),a
w53_cmd0:
		in a,(c)
		or a
		ret z
		jr w53_cmd0
		
		
wiznet_read:	;a'-сокет, de-Ѕуфер, hl-количество
		call w53_valid_socket
		jp z,w53_invalid_socked0
		;call BDOS_preparedepage
w53_read_min:			;hl-сколько хотим байт
		ld a,h
		or l
		ret z
w53_read55:
		ld c,(ix+2)
		ld b,(ix+3)
		ld a,b
		or c
		jr z,w53_read_new	;старых данных нету, читать новый пакет
		
		;читаем старый пакет
		;bc=min(hl,bc), hl-=min(hl,bc)
		sbc hl,bc		
		jr nc,w53_minimum0
		add hl,bc
		ld b,h
		ld c,l
		ld h,0
		ld l,0
w53_minimum0:
		ld a,(ix+2)
		sub c
		ld (ix+2),a
		ld a,(ix+3)
		sbc a,b
		ld (ix+3),a
		
		push bc				;сколько реально прочтем сохраним
		ex de,hl
		ld d,b
		ld e,c		
		ld c,WIZ_BASE_ADDR
		ld b,(ix+0)
		ld a,WIZ_S_RX_L
		bit 0,b
		jr nz,w53_read_loopl
w53_read_loop:	;что-то надо дочитать de-count, hl-ptr
		ini
		ld b,a
		dec e
		jp z,w53_read_looph
w53_read_loopl:
		ini
		dec e
		jp nz,w53_read_loop
		dec d
		jp p,w53_read_loop
		jp w53_read_loope
w53_read_looph:
		dec d
		jp p,w53_read_loopl
w53_read_loope:		;конец цикла
		ld (ix+0),b	;сохраним следующий регистр RX	
		pop hl					;сколько прочитали
		ld a,(ix+2)				;если в буфере чтото есть,
		or (ix+3)				;то выходим
		ret nz					
		bit 0,b					;иначе команда - пакет забрали
		jr z,w53_read_noblanc
		in a,(c)				;дочитаем холостой байт
w53_read_noblanc:
		ld a,Sn_CR_RECV
		jp w53_cmd	;выходим
		
w53_read_new:		;читать новый пакет
		ld bc,WIZ_BASE_ADDR+(WIZ_S_RX_RSR_L<<8)
		in a,(c)
		jr nz,w53_read_new1
		dec b
		in a,(c)
		jr nz,w53_read_new1
		;в буфере ничего. проверим жив ли сокет
		ld h,a			;ничего не прочитали
		ld l,a
		ld b,WIZ_S_SSR		
		in a,(c)
		cp SOCK_ESTABLISHED
		ret z
		cp SOCK_UDP
		ret nc
		ld h,-1
		ld a,ERR_NOTCONN
		ret
w53_read_new1:
		ld b,WIZ_S_SSR
		in a,(c)
		ld b,WIZ_S_RX_H
		cp SOCK_UDP
		jr nz,w53_read_new2
		in a,(c)
		inc b
		in a,(c)
		dec b
		in a,(c)
		inc b
		in a,(c)
		dec b
		in a,(c)
		inc b
		in a,(c)
		dec b	
w53_read_new2:
		ld (ix+0),b
		in a,(c)
		ld (ix+3),a
		inc b
		in a,(c)
		ld (ix+2),a
		jp w53_read_min

wiznet_close:
wiznet_write:	;a'-сокет, de-Ѕуфер, hl-количество
		call w53_valid_socket
		jp z,w53_invalid_socked0
		;call BDOS_preparedepage
		ld c,WIZ_BASE_ADDR
		ld b,WIZ_S_SSR		;жив ли сокет
		in a,(c)
		cp SOCK_ESTABLISHED
		jr z,w53_write1
		cp SOCK_UDP
		jr nc,w53_write1
		ld a,ERR_NOTCONN	;издох
		ld h,-1
		ret
w53_write1:
		ld b,WIZ_S_FSR_L	;проверим место в буфере
		in a,(c)
		dec b
		sub l
		in a,(c)
		sbc a,h
		jr nc,w53_wr_count_valid
		;pop de
		ld h,-1
		ld a,ERR_EMSGSIZE
		ret
w53_wr_count_valid:	
		ex de,hl
		push de		;чтобы потом сколько отправили вернуть
		dec de
		push de
		pop ix
		ld de,-2
		ld b,WIZ_S_TX_L
		ld a,WIZ_S_TX_L+1
w53_wr_loop:
		outi
		ld b,a
		outi
		add ix,de
		jr c,w53_wr_loop		
		pop hl
		ld b,WIZ_S_WRSR_H
		out (c),h
		inc b
		out (c),l
		ld a,Sn_CR_SEND
		jp w53_cmd
		
		
w53_socflags: ;+0 - RXreg, +1 - TXreg, +2..3 - RXcount
		defw 0,0,0,0,0,0,0,0
		defw 0,0,0,0,0,0,0,0
