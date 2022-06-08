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
;	ld b, e
;	ld a, e
;	add a, 05	; protocol
;	ld e, a		
;	ld a, (de)	;(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip	
;	cp 01
;	jp z, tcpread
;	cp 02
;	jp z, icmpread
;	cp 03
;	jp z, udpread


tcpread:
;	ld e, b 	
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
;	ld e, b 	
;	ex de,hl
;	ld a, (hl) 	;socket
;	inc hl
;	ld (store_ix1), hl
;	ld IX, (store_ix1) 	; buffer HL
;	inc hl
;	inc hl
;	ld c, (hl) 			;size L
;	inc hl
;	ld b, (hl) 			;size H
;	ld l, c
;	ld h, b
;	ex af,af'
;	ld c, CMD_WIZNETREAD
;	push ix
;	push iy
;	call BDOS
;	pop iy
;	pop ix
;	bit 7, h
;	jp z, readok 	;noerror just return
;	ld l, a

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
;	ld b, e
;	ld a, e
;	add a, 05	; protocol
;	ld e, a		
;	ld a, (de)	;(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip	
;	cp 01
;	jp z, tcpsend
;	cp 02
;	jp z, icmpsend
;	cp 03
;	jp z, udpsend

tcpsend:	
;	ld e, b 
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
;	ld e, b 
;	ex de,hl
;	ld a, (hl) 			; socket
;	inc hl
;	ld (store_ix), hl
;	ld IX, (store_ix) 	; buffer HL
;	inc hl
;	inc hl
;	ld c, (hl) 			; size L
;	inc hl
;	ld b, (hl) 			; size H
;	inc hl				; protocol
;	inc hl
;	ex de,hl			; DE-HL now point at sockaddr_in
;	ex af,af'
;	ld c, CMD_WIZNETWRITE
;	push ix
;	push iy
;	call BDOS
;	pop iy
;	pop ix
;	bit 7, h
;	jp z, writeok 		;noerror just return
;	ld l, a
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

END
