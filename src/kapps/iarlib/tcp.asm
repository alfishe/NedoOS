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
	push ix
	push iy
	ld a,c
	ex af,af'
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
	ld a, e
	ld d, b
	ld e, c
	push ix
	push iy
	;ld a,c
	ex af,af'
	ld c, CMD_WIZNETOPEN
	ld l,0x03
	call BDOS
	pop iy
	pop ix
	ld h, l
	LD l, a
	
	ret
ENDMOD

MODULE OS_WIZNETREAD
PUBLIC OS_WIZNETREAD
#include "sysdefs.asm"
RSEG CODE
;	A=SOCKET, de=buffer_ptr, HL=sizeof(buffer) ; 
;	out: HL=count if HL < 0 then A=error
OS_WIZNETREAD:	
	push bc
	push de
	push ix
	push iy

	ex de,hl
	ld a, (hl) 	;socket
	inc l
	ld e, (hl) 	;buffer L
	inc l
	ld d, (hl) 	;buffer H
	inc l
	ld c, (hl) 	;size L
	inc l
	ld b, (hl) 	;size H
	ld l, c
	ld h, b
	ex af,af'
	ld c, CMD_WIZNETREAD
	call BDOS
	bit 7, h
	jp z, readok 	;noerror just return
	ld l, a


readok:	
	pop iy
	pop ix
	pop de
	pop bc
	ret
ENDMOD

MODULE OS_WIZNETWRITE
PUBLIC OS_WIZNETWRITE
#include "sysdefs.asm"
RSEG CODE
;CMD_WIZNETWRITE=0xde
;if TCP: A=SOCKET, de=buffer_ptr, HL=sizeof(buffer)
;else:	 A=SOCKET, IX=buffer_ptr, HL=sizeof(buffer), de=sockaddr_in ptr
;out: HL=count if HL < 0 then A=error 
OS_WIZNETWRITE	
	push bc
	push ix
	push iy
;E - (0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip	
	
	ld b, e
	ld a, e
	add a, 05
	ld e, a
	ld a, (de)
	cp 01
	jp z, tcpsend
	cp 02
	jp z, icmpsend
	cp 03
	jp z, udpsend

tcpsend:	
	ld e, b 
	ex de,hl
	ld a, (hl) 	;socket
	inc l
	ld e, (hl) 	;buffer L
	inc l
	ld d, (hl) 	;buffer H
	inc l
	ld c, (hl) 	;size L
	inc l
	ld b, (hl) 	;size H
	ld l, c
	ld h, b
	ex af,af'
	ld c, CMD_WIZNETWRITE
	call BDOS	
	pop iy
	pop ix
	pop bc
	ret
	
udpsend:
icmpsend:






			ex de,hl
			ld a, (hl)
			ld hl, 0
			ld l, a
			pop iy
			pop ix
			pop bc



;При протоколе отличном от TCP/IP все аргументы в регистрах:
;  A - SOCKET
;  DE - указатель на структуру sockaddr_in, в неё необходимо поместить IP-адрес и порт хоста получателя
;  IX - указатель на буфер с данными
;  HL - размер данных(в байтах), в текущей реализации максимум 8192 байта
; Возвращаемые значения в регистрах:
;  HL - при отрицательном значении функция завершилась с ошибкой,
;   иначе возвращается действительный размер(в байтах) отправленных данных,

ret
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
	ld a, e
	ld d, b
	ld e, c
	push ix
	push iy
	ld l,0x05
    ld c,CMD_WIZNETOPEN
	ex af,af'
	call BDOS
	pop iy
	pop ix
	
	ld h, l
	ld l, a
	ret
ENDMOD



















END
