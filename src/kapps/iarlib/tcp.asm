MODULE OS_NETSOCKET
PUBLIC OS_NETSOCKET
#include "sysdefs.asm"
RSEG CODE

OS_NETSOCKET:	
;D - AF_INET
;E - (0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip
;------
;L - SOCKET
;A - ErrNo
	push bc
	ld l,0x01
	ld c, CMD_WIZNETOPEN
	ex af,af'
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop bc
	ld h, l
	ld l, a
	
	ret
ENDMOD

MODULE OS_NETCONNECT
PUBLIC OS_NETCONNECT
#include "sysdefs.asm"
RSEG CODE

OS_NETCONNECT:	
;A  - Socket
;DE - Pointer to adrstruct
;------
;L - <0 err
;H - ErrNo
;CMD_WIZNETOPEN=0xdb ;A=SOCKET, L=subfunction (see sys_h.asm)
	push bc
	ld a, e
	ld d, b
	ld e, c
	ex af,af'
	ld c, CMD_WIZNETOPEN
	ld l,0x03
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ld h, l
	LD l, a
	pop bc
	ret
ENDMOD

MODULE OS_WIZNETREAD
PUBLIC OS_WIZNETREAD
#include "sysdefs.asm"
RSEG CODE
;if TCP: A=SOCKET, de=buffer_ptr, 		HL=sizeof(buffer)
;else:	 A=SOCKET, de=sockaddr_in ptr,	HL=sizeof(buffer), IX=buffer_ptr,
;out: HL=count if HL < 0 then A=error 
OS_WIZNETREAD:	
	push bc
	ld b, e
	ld a, e
	add a, 05	; protocol
	ld e, a		
	ld a, (de)	;(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip	
	cp 01
	jp z, tcpread
	cp 02
	jp z, icmpread
	cp 03
	jp z, udpread


tcpread:
	ld e, b 	
	ex de,hl
	ld a, (hl) 	;socket
	inc hl
	ld e, (hl) 	;buffer L
	inc hl
	ld d, (hl) 	;buffer H
	inc hl
	ld c, (hl) 	;size L
	inc hl
	ld b, (hl) 	;size H
	ld l, c
	ld h, b
	ld c, CMD_WIZNETREAD
	push ix
	push iy
	ex af,af'
	call BDOS
	pop iy
	pop ix
	bit 7, h
	jp z, readok 	;noerror just return
	ld l, a
	jp readnot

icmpread:
udpread:
	ld e, b 	
	ex de,hl
	ld a, (hl) 	;socket
	inc hl
	ld (store_ix1), hl
	ld IX, (store_ix1) 	; buffer HL
	inc hl
	inc hl
	ld c, (hl) 			;size L
	inc hl
	ld b, (hl) 			;size H
	ld l, c
	ld h, b
	ex af,af'
	ld c, CMD_WIZNETREAD
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	bit 7, h
	jp z, readok 	;noerror just return
	ld l, a

readok:
readnot:
	pop bc
	ret
store_ix1:
defb 0,0,0,0,0,0,0,0
ENDMOD

MODULE OS_WIZNETWRITE
PUBLIC OS_WIZNETWRITE
#include "sysdefs.asm"
RSEG CODE
;if TCP: A=SOCKET, de=buffer_ptr, 		HL=sizeof(buffer)
;else:	 A=SOCKET, de=sockaddr_in ptr,	HL=sizeof(buffer), IX=buffer_ptr,
;out: HL=count if HL < 0 then A=error 
OS_WIZNETWRITE	
	push bc
	ld b, e
	ld a, e
	add a, 05	; protocol
	ld e, a		
	ld a, (de)	;(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip	
	cp 01
	jp z, tcpsend
	cp 02
	jp z, icmpsend
	cp 03
	jp z, udpsend

tcpsend:	
	ld e, b 
	ex de,hl
	ld a, (hl) 			;socket
	inc hl
	ld e, (hl) 			;buffer L
	inc hl
	ld d, (hl) 			;buffer H
	inc hl
	ld c, (hl) 			;size L
	inc hl
	ld b, (hl) 			;size H
	ld l, c
	ld h, b
	push ix
	push iy
	ld c, CMD_WIZNETWRITE
	ex af,af'
	call BDOS
	pop iy
	pop ix
	bit 7, h
	jp z, writeok 		;noerror just return
	ld l, a
	jp writenot
	
udpsend:
icmpsend:
	ld e, b 
	ex de,hl
	ld a, (hl) 			; socket
	inc hl
	ld (store_ix), hl
	ld IX, (store_ix) 	; buffer HL
	inc hl
	inc hl
	ld c, (hl) 			; size L
	inc hl
	ld b, (hl) 			; size H
	inc hl				; protocol
	inc hl
	ex de,hl			; DE-HL now point at sockaddr_in
	ex af,af'
	ld c, CMD_WIZNETWRITE
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	bit 7, h
	jp z, writeok 		;noerror just return
	ld l, a
writeok:
writenot:
	pop bc
	ret
store_ix:
defb 0,0,0,0,0,0,0,0
ENDMOD

MODULE OS_BIND
PUBLIC OS_BIND
#include "sysdefs.asm"
RSEG CODE
;  A - SOCKET
;  DE - указатель на структуру sockaddr_in содержащую номер исходящего порта.
;   (остальные поля структуры не используются, но обязаны присутствовать)
; Возвращаемые значения в регистрах:
;  L - При отрицательном значении - функция завершилась с ошибкой.
;  А - errno при ошибке
OS_BIND:	
	push bc
	ld a, e
	ld d, b
	ld e, c
	ld l,0x05
    ld c,CMD_WIZNETOPEN
	push ix
	push iy
	ex af,af'
	call BDOS
	pop iy
	pop ix
	ld h, l
	ld l, a
	pop bc
	ret
ENDMOD

MODULE OS_LISTEN
PUBLIC OS_LISTEN
#include "sysdefs.asm"
RSEG CODE
; A - SOCKET
; Возвращаемые значения в регистрах:
; L - При отрицательном значении - функция завершилась с ошибкой.
; А - errno при ошибке.
OS_LISTEN:	
	push bc
	push de
	ld a, e
	ld l,0x06
    ld c,CMD_WIZNETOPEN
	ex af,af'
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop de
	pop bc
	ld h, l
	ld l, a
	ret
ENDMOD


MODULE OS_ACCEPT
PUBLIC OS_ACCEPT
#include "sysdefs.asm"
RSEG CODE
; A - SOCKET
; Возвращаемые значения в регистрах:
; L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
; А - errno при ошибке.
OS_ACCEPT:	
	push bc
	push de
	ld a, e
	ld l,0x04
    ld c,CMD_WIZNETOPEN
	ex af,af'
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ld h, l
	ld l, a
	pop de
	pop bc
	ret
ENDMOD



MODULE OS_NETSHUTDOWN
PUBLIC OS_NETSHUTDOWN
#include "sysdefs.asm"
RSEG CODE
; A - SOCKET
; Возвращаемые значения в регистрах:
; L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
; А - errno при ошибке.
OS_NETSHUTDOWN:	
	push bc
	push de
	ld a, e
	ld l,0x02
    ld c,CMD_WIZNETOPEN
	ex af,af'
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ld h, l
	ld l, a
	pop de
	pop bc
	ret
ENDMOD

;  DE - указатель на строку с адресом для резолвинга.
MODULE OS_DNSRESOLVE
PUBLIC OS_DNSRESOLVE
#include "sysdefs.asm"
EXTERN YIELD
EXTERN OS_NETSOCKET, OS_WIZNETWRITE, OS_WIZNETREAD, OS_NETSHUTDOWN
RSEG CODE
OS_DNSRESOLVE:		;DE-domain name
	ld de,zxartadr
	 
	push ix
	push de
    ld de,dns_ia + 3
    call OS_GETDNS
	ld hl,dns_head
	ld de,dnsbuf
	ld bc,6
	ldir
	ex de,hl
	ld de,dnsbuf+7
	ld (hl),0
	ld bc,256-7
	ldir
	ld de,dnsbuf+12
	ld h,d
	ld l,e
	pop bc
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
	call OS_NETSOCKET
	ld (dnssoc),a
	or a
	jp m,exiterr
	pop hl
	push hl
	ld de,0xffff&(-dnsbuf)
	add hl,de
	PUSH	HL
	LD	bc,(dnssoc)
	LD	ix,dnsbuf
	ld	de,dns_ia
	CALL	OS_WIZNETWRITE
	pop af
	bit 7,h
	jr nz,exitcode
	ld b,50
	push bc
	jr recv_wait1
recv_wait:
	push bc
	call YIELD
recv_wait1:
	ld hl,256
	PUSH	HL
	LD	bc,(dnssoc)
	LD	DE,dnsbuf
	LD	ix,dnsbuf
	CALL	OS_WIZNETREAD
	pop af
	pop bc
	bit 7,h
	jr z,recv_wait_end
	djnz recv_wait
	ld a,54	;ERR_CONNRESET
	ld (errno),a
	jr exiterr
recv_wait_end:
	ld a,65		;ERR_HOSTUNREACH
	ld (errno),a
	bit 7,h
	jr nz,exitcode
	ld a,(dnsbuf+3)
	and 0x0f	
	jr nz,exiterr
exitcode:
	LD	BC,(dnssoc)
	LD	E,0
	CALL	OS_NETSHUTDOWN
	pop hl
	pop ix
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
	
exiterr:
	pop af
	ld a,(errno)
	push af
	LD	BC,(dnssoc)
	LD	E,0
	CALL	OS_NETSHUTDOWN
	pop af
	ld (errno),a
	pop ix
exiterr1:
	ld hl,0
	ret

OS_GETDNS:
	ld l,0x07
	push ix
	push iy	
	ld a,c
	ex af,af'
	ld c,CMD_WIZNETOPEN
	call BDOS
	ld a,l
	pop iy
	pop ix
	ret
dns_head
	defb 0x11,0x22,0x01,0x00,0x00,0x01
dns_ia:
	defb 0,0,53,8,8,8,8
dnssoc:
	DEFS 1	
errno:
	defb 0
zxartadr:
	defb "zxart.ee", 0
dnsbuf:
	DEFS 256
ENDMOD

MODULE OS_GETDNS
PUBLIC OS_GETDNS
#include "sysdefs.asm"
OS_GETDNS:
	ld l,0x07
	push ix
	push iy	
	ld a,c
	ex af,af'
	ld c,CMD_WIZNETOPEN
	call BDOS
	ld a,l
	pop iy
	pop ix
	ret
ENDMOD




END
