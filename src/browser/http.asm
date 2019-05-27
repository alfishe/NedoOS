httphostname=DISKBUF+0x400
dnsbuf=DISKBUF+0x0600

IPPROTO_TCP EQU 6
IPPROTO_UDP EQU 17

AF_UNSPEC EQU 0
AF_INET EQU 2
AF_INET6 EQU 23

SOCK_STREAM EQU 0x01	;tcp/ip
SOCK_DGRAM 	EQU 0x03		;udp/ip

SHUT_RDWR 		EQU 2
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
		

openstream_http
	;display $
;de=filename (without "http://"), slash always presents
;out: A!=0 => error
        ex de,hl
openstream_http_hl
        ld de,httphostname
        push de
        call strcopy
        pop hl
        call findslash
        ;call strlen_tobc_keephl
        ;ld a,'/'
        ;cpir ;TODO ser.ver:port
         ;jr nz,$
        push hl ;filename after ser.ver/
        dec hl ;at slash
        ld (hl),0 ;end of httphostname
        
;httphostname=server name (filename before slash, not including slash)
;top of stack=filename after slash (after ser.ver/)
        
		call dns_resolver
		ld a,l
		or h
		jp z,CONNECTIONERROR
		ld de,host_ia+3
		ld bc,4
		ldir
;create socket:
		ld de,SOCK_STREAM+(AF_INET<<8)
		OS_NETSOCKET
		ld a,l
		or a
		jp m,CONNECTIONERROR;?C_EXIT
		ld (soc1),a
		LD DE,host_ia
		OS_NETCONNECT
                 ld a,l ;DimkaM 12.03.2019
		or a
		jp p,connect_ok
createsoc_err
		ld a,(soc1)
		ld e,0
		OS_NETSHUTDOWN
		jp CONNECTIONERROR
connect_ok
;form GET message in DISKBUF (will be deleted in readstream)
        ld hl,tGET
        ld de,DISKBUF
        call strcopy
        dec de
        
         pop hl ;filename
        call strcopy
        dec de
;amp.dascene.net: убрать пробел в конце url:
        dec de
        ld a,(de)
        sub ' '
        jr z,$+3
        inc de
        
        ld hl,tHTTP_host
        call strcopy
        dec de
        ld hl,httphostname
        call strcopy
        dec de
        ld hl,tGETend
        call strcopy ;with terminator
         dec de ;no terminator?
		ex de,hl
        ld de,0xffff&(-DISKBUF)
        add hl,de

;send message to server:
		LD	a,(soc1)
		LD	DE,DISKBUF
;de=message
;hl=message size       
        ;jr $
		OS_WIZNETWRITE
		bit 7,h
		jr nz,createsoc_err
        
	ld a,1
	ld (http_firstreadflag),a
        
	xor a ;OK
        ret
        
;hl = poi to filename in string
;out: de = after last dot or start
findlastdot
	ld d,h
	ld e,l ;de = after last dot
findlastdot0
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,findlastdot0
	jr findlastdot

tlocation
        db "Location: ",0

readstream_http
	;display $
         ld (readstream_http_requestedsize),hl
	add hl,de
	push de	;начало буфера
	
http_firstreadflag=$+1
	ld a,1
	dec a
	jr nz,readstream_http_nofirstread
;read until cr,lf,cr,lf or EOF or endofbuf
	push hl
	push de
	or a
	sbc hl,de ;размер
        jr readstream_http_headlines0
readstream_http_headretry
        push de
        push hl
        call yieldgetkeynolang
        pop hl
        pop de
        cp key_esc
        jp z,readstream_err

readstream_http_headlines0
         ld (readstream_http_headlineaddr),de
readstream_http_head0
	push de
	push hl ;размер
	ld hl,1
	ld a,(soc1)
	OS_WIZNETREAD
	bit 7,h
         ld a,l
	pop hl
	pop de
	jr nz,readstream_err
         or a
         jr z,readstream_http_head0 ;вдруг ответ не успел прийти
	dec hl ;размер
	ld a,h
	or l
	jr z,readstream_err
	ld b,d
	ld c,e
	inc de
	ld a,(bc)
	cp 0x0a
	jr nz,readstream_http_head0
	dec bc
	ld a,(bc)
	cp 0x0d
	jr nz,readstream_http_head0
	;dec bc
	;ld a,(bc)
	;cp 0x0a
	;jr nz,readstream_http_head0
	;dec bc
	;ld a,(bc)
	;cp 0x0d
	;jr nz,readstream_http_head0
        
;если строка пустая, то readstream_http_headq
readstream_http_headlineaddr=$+1
        ld a,(0)
        cp 0x0d
        jr z,readstream_http_headq
        
        push de
        push hl
        
        ;jr $
        ld hl,(readstream_http_headlineaddr)
        ld de,tlocation
;найти строку Location: <url> (если moved temporarily)
        call strcp_tillde0
        ld b,h
        ld c,l
        pop hl
        pop de
        jr nz,readstream_http_headlines0
;bc=url
        push bc
        call closestream_http
        pop hl
        ld bc,7 ;"http://"
        add hl,bc
        call openstream_http_hl
        
	pop de
	pop hl
        
	pop de ;начало буфера
readstream_http_requestedsize=$+1
        ld hl,0
        ;jr $
        xor a
	ld (http_firstreadflag),a ;почему-то страничка, куда переадресует amp.dascene.net, отдаёт файл без http заголовка!
        jp readstream_http
        
        
readstream_http_headq
	pop de
	pop hl
;TODO переделать: читать как обычно, потом искать заголовок, отрезать его, сдвинуть остаток в начало буфера и прочитать ещё столько же

        xor a
	ld (http_firstreadflag),a
	
readstream_http_nofirstread

        ;jr $
readstream_loop
	push hl	;докуда читать
	push de	;текущий ptr
	or a
	sbc hl,de ;размер
	;ld a,h
	;or l
	jr z,readstream_err
	LD	a,(soc1)
	OS_WIZNETREAD
	bit 7,h
	jr nz,readstream_err
	pop de ;de=куда читали, hl=сколько прочитали
	add hl,de
	ex de,hl ;de=текущий ptr
	pop hl ;докуда читать
	jr readstream_loop
readstream_err:	
	pop hl
	pop de
        
	pop de ;начало буфера
	or a
	sbc hl,de
         ;jr $
	ret
	
		
closestream_http
		ld e,0
		ld a,(soc1)
		OS_NETSHUTDOWN
        ret

host_ia:
	defb 0,0,80,8,8,8,8
;httpslashcurdir
        db '/'
httpcurdir
;server/path (without / in the end)
        ds 128

soc1
        db 0 ;current socket

tGET
        db "GET /",0
tHTTP_host
        db " HTTP/1.0\r\n" ;1.0 DimkaM for nedopc.com
	db "Connection: close\r\n"
	db "Host: ",0
tGETend
        db "\r\n"
        db "User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)\r\n"
        db "\r\n",0

;httpgetstr
	;defb 'GET /cspr/index.htm HTTP/1.1',13,10
	;defb 'Host: dimkam.ru',13,10
	;defb 13,10
dns_resolver:		;DE-domain name
    ld a,25;3
    ld (dns_err_count),a
dns_err_loop
	;push de
	ld hl,dns_head
	ld de,dnsbuf
	ld bc,6
	ldir
	ex de,hl
	ld de,dnsbuf+7
	ld (hl),b;0
	ld  c,256-7
	ldir
	ld de,dnsbuf+12
	ld h,d
	ld l,e
	ld bc, httphostname ;pop bc
name_loop:
	inc hl
	ld a,(bc)
	ld (hl),a
	inc bc
	cp '.'
	jr z,is_dot
	or a
	jr nz,name_loop
is_dot:
	sbc hl,de
	ex de,hl
	dec e
	ld (hl),e
	inc e
	add hl,de
	ld d,h
	ld e,l
	or a
	jr nz,name_loop
	inc a
	inc hl
	inc hl
	ld (hl),a
	inc hl
	inc hl
	ld (hl),a
	inc hl
	push hl
	
	ld de,0x0203
	OS_NETSOCKET
	ld a,l
	ld (soc1),a
	or a
	jp m,dns_exiterr
	LD	DE,dns_ia
	OS_NETCONNECT
                 ld a,l ;DimkaM 12.03.2019
	or a
	jp m,dns_exiterr
	
	pop hl
	push hl
	ld de,0xffff&(-dnsbuf)
	add hl,de
	LD	a,(soc1)
	LD	DE,dnsbuf
	OS_WIZNETWRITE
	bit 7,h
	jr nz,dns_exitcode
dns_err_count=$+1
	ld b,25
	jr recv_wait1
recv_wait:
	;YIELD
        push bc
        call yieldgetkeynolang
        pop bc
recv_wait1:
	push bc
	ld hl,256
	LD	a,(soc1)
	LD	DE,dnsbuf
	OS_WIZNETREAD
	pop bc
	ld a,h
	or l
	jr nz,recv_wait_end
	djnz recv_wait
	;ld a,54	;ERR_CONNRESET
	;ld (errno),a
	jr dns_exiterr
recv_wait_end:
	bit 7,h
	jr nz,dns_exitcode
	;ld a,65		;ERR_HOSTUNREACH
	;ld (errno),a
	ld a,(dnsbuf+3)
	and 0x0f	
	jr nz,dns_exiterr
dns_exitcode:
	LD	a,(soc1)
	LD	E,0
	OS_NETSHUTDOWN
	pop hl
reqpars_l
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	ld de,7
	add hl,de
	ld b,(hl)
	inc hl
	ld c,(hl)
	inc hl
	dec a
	ret z
	cp 4
	jr nz,exiterr1
	add hl,bc
	jr reqpars_l
dns_exiterr:
	pop af
	LD	a,(soc1)
	LD	E,0
	OS_NETSHUTDOWN
    ld a,(dns_err_count)
    add a,a
    ld (dns_err_count),a
    jp nc,dns_err_loop
exiterr1:
    ld hl,0
	ret
dns_head
	defb 0x11,0x22,0x01,0x00,0x00,0x01
dns_ia:
	defb 0,0,53,8,8,8,8
