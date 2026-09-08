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
readok:
readnot:
	pop bc
	ret
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
writeok:
writenot:
	pop bc
	ret
ENDMOD

/*
  A - SOCKET
  DE - указатель на структуру sockaddr_in, в неё помещается(ядром) IP-адрес и порт хоста отправившего данные.
  IX - указатель на буфер для принятия данных
  HL - размер буфера(в байтах)
 Возвращаемые значения в регистрах:
  HL - при отрицательном значении функция завершилась с ошибкой,
   про значении больше нуля возвращается действительный размер(в байтах) принятых данных,
   нулевого значения вызов не возвращает.
  А - errno при ошибке.
 Возможные ошибки:
  ERR_NOTSOCK - не действительный дескриптор сокета
  ERR_EAGAIN - входящих данных пока нет
  ERR_NOTCONN - сокет с неустановленным\пропавшем соединением(при протоколе TCP/IP)

Если количество параметров неопределённо (printf(...) и т.п.), то все параметры передаются через стек.
Иначе первый параметр передаётся в E, DE, CDE или BCDE, в зависимости от разрядности значения. 
Если первый и второй параметры не шире 16 бит каждый, то второй параметр передаётся в регистрах B или BC, иначе через стек. 
Возвращаемое значение из функции передаётся в регистрах A (L при банкинге), HL, CHL или BCHL, в зависимости от разрядности значения.
Сохранять надо ix и iy обязательно.
DE и  BC сохранять если они не юзаются в качестве параметров

struct readstructure
			{
			unsigned char  	socket; 
			unsigned int	BufAdr;
			unsigned int 	bufsize;
			unsigned char	protocol;
			};

*/


MODULE OS_WIZNETWRITE_UDP
PUBLIC OS_WIZNETWRITE_UDP
#include "sysdefs.asm"
RSEG CODE
OS_WIZNETWRITE_UDP	
; DE - readstructure BC - sockaddr_in
	ex de,hl			;HL - sockaddr_in, DE - garbage
	ld a, (hl) 			;A  - socket
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push de
	ld (store_ix),ix
	pop ix				;IX - BufAdr
	ld e, (hl) 			;E - Bufsize L
	inc hl
	ld d, (hl) 			;D  - Bufsize H
	ex de,hl			;HL - Bufsize
	ld d,b				;DE - sockaddr_in
	ld e,c				
	ex af,af'
/*
  A  - SOCKET
  DE - указатель на структуру sockaddr_in, в неё необходимо поместить IP-адрес и порт хоста получателя
  IX - указатель на буфер с данными
  HL - размер данных(в байтах), в текущей реализации максимум 8192 байта
 Возвращаемые значения в регистрах:
  HL - при отрицательном значении функция завершилась с ошибкой,
  иначе возвращается действительный размер(в байтах) отправленных данных,
  А  - errno при ошибке.
*/
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
	ld ix,(store_ix)
	ret
store_ix:
	defb 0,0,0

ENDMOD

MODULE OS_WIZNETREAD_UDP
PUBLIC OS_WIZNETREAD_UDP
#include "sysdefs.asm"
RSEG CODE
OS_WIZNETREAD_UDP:	
; DE - readstructure BC - sockaddr_in
	ex de,hl			;HL - readstructure, DE - garbage
	ld a, (hl) 			;A  - socket
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push de
	ld (store_ix),ix
	pop ix
	ld e, (hl) 			;E - Bufsize L
	inc hl
	ld d, (hl) 			;D  - Bufsize H
	ex de,hl			;HL - Bufsize
	ld d,b				;DE - sockaddr_in
	ld e,c				;
	ex af,af'
/*
  A - SOCKET
  DE - указатель на структуру sockaddr_in, в неё помещается(ядром) IP-адрес и порт хоста отправившего данные.
  IX - указатель на буфер для принятия данных
  HL - размер буфера(в байтах)
 Возвращаемые значения в регистрах:
  HL - при отрицательном значении функция завершилась с ошибкой,
   про значении больше нуля возвращается действительный размер(в байтах) принятых данных,
   нулевого значения вызов не возвращает.
  А - errno при ошибке.
*/
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
	ld ix,(store_ix)
	ret
store_ix:
	defb 0,0,0
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
; E - Варианты закрытия, 0 - закрыть немедленно, 1 - закрыть только если буфер отправки пуст.
; Возвращаемые значения в регистрах:
; L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
; А - errno при ошибке.
OS_NETSHUTDOWN:	
	push bc
	push de
	ld a, e
	ld e, b
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

MODULE OS_GETDNS
PUBLIC OS_GETDNS

#include "sysdefs.asm"
RSEG CODE
OS_GETDNS:
	ld l,0x08
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

MODULE OS_SETDNS
PUBLIC OS_SETDNS
#include "sysdefs.asm"
RSEG CODE
OS_SETDNS:
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

MODULE OS_SETUART
PUBLIC OS_SETUART
#include "sysdefs.asm"
RSEG CODE
OS_SETUART:
	ld l,0x09
	push ix
	push iy
	ld a,c
	ex af,af'
	ld c,CMD_WIZNETOPEN
	call BDOS
	pop iy
	pop ix
	ret
ENDMOD

MODULE OS_GETUART
PUBLIC OS_GETUART
#include "sysdefs.asm"
RSEG CODE
OS_GETUART:
	ld l,0x0a
	push ix
	push iy
	ld a,c
	ex af,af'
	ld c,CMD_WIZNETOPEN
	call BDOS
	pop iy
	pop ix
	ret
ENDMOD

MODULE OS_GETINFO
PUBLIC OS_GETINFO
#include "sysdefs.asm"
RSEG CODE
OS_GETINFO:
	ld l,0x0b
	push ix
	push iy
	ld a,c
	ex af,af'
	ld c,CMD_WIZNETOPEN
	call BDOS
	pop iy
	pop ix
	ret
ENDMOD
END
