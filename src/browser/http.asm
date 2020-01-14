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

proxserv
	db "nedoos.ru/s/?https://",0
	display "openstream_http = ",$
openstream_http
	;display $
;de=filename (without "http://"), slash always presents
;out: A!=0 => error
        ex de,hl
openstream_http_hl
		push hl
        ld de,httphostname
		ld a,(curprotocol)
		cp 3
		jr nz,nonhttps
		ld hl,proxserv
		call strcopy
		dec de
nonhttps
		pop hl
        ;push de
        call strcopy
        ld hl,80*256 ;BIG ENDIAN
        ld a,(curprotocol)
        cp 2
        jr nz,$+4 ;1/3=http
        ld h,70 ;2=gopher
        ld (curport),hl
        ld hl,httphostname ;pop hl
        ;call findslash
openstream_http_findslash0
         ld a,(hl)
         cp ':'
         jr z,openstream_http_setport
         cp '/'
         jr z,openstream_http_slash
         or a
         jr z,openstream_http_slash
         inc hl
         jr openstream_http_findslash0
openstream_http_setport
        ld (hl),0 ;end of httphostname
;decode port
        ld de,0 ;oldport
openstream_http_decodeport0
        inc hl
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,openstream_http_decodeportq
        push hl
        ld h,d
        ld l,e
        add hl,hl
        add hl,hl
        add hl,de
        add hl,hl ;hl=oldport*10
        add a,l
        ld e,a
        adc a,h
        sub e
        ld d,a ;de=port
        pop hl
        jr openstream_http_decodeport0
openstream_http_decodeportq
;de=port
        ld a,d
        ld d,e
        ld e,a
        ld (curport),de ;BIG ENDIAN
;hl=delimiter after ser.ver:NNN
openstream_http_slash
;hl=at delimiter after hostname and maybe port
        xor a
        cp (hl)
        ld (hl),a ;end of httphostname
        jr z,$+3
        inc hl ;after delimiter
        push hl ;filename after ser.ver/
        
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
        ld de,DISKBUF

         ;ld a,0xfe
         ;in a,(0xfe)
         ;rra
         ld a,(curprotocol)
;TODO что-то сделать с типом 3 - ничего
         cp 2
         jr nz,connect_nogopher ;http=1, gopher=2
         pop hl ;filename
         call strcopy
         dec de
         ld a,0xd
         ld (de),a
         inc de
         ld a,0xa
         ld (de),a
         inc de
         jr connect_makeheaderq
connect_nogopher

        ld hl,tGET
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
         
connect_makeheaderq
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
	jp nz,readstream_http_nofirstread
curprotocol=$+1
         ld a,0;(curprotocol)
         cp 2
         jr z,readstream_http_nohead ;2=gopher
         ;ld a,0xfe
         ;in a,(0xfe)
         ;rra
         ;jr nc,readstream_http_nohead ;Caps Shift - show headers
        
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
        ;ld bc,7 ;"http://"
        ;add hl,bc
         call isprotocolpresent
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

readstream_http_nohead
        xor a
	ld (http_firstreadflag),a
	
readstream_http_nofirstread

readstream_loop
	push hl	;докуда читать
	push de	;текущий ptr
	or a
	sbc hl,de ;размер
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
	ret
	
		
closestream_http
		ld e,0
		ld a,(soc1)
		OS_NETSHUTDOWN
        ret

curport=$+1
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

;struct sockaddr_in {unsigned char sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};
dns_ia:
	defb 0
        db 0,53 ;port (big endian)
        db 8,8,8,8 ;ip (big endian)
