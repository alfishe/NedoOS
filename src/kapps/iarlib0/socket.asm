
	MODULE OS_NETSOCKET
	PUBLIC OS_NETSOCKET,OS_NETCONNECT,OS_NETCLOSE
	PUBLIC OS_ACCEPT,OS_BIND,OS_LISTEN
	PUBLIC os_getdns,os_setdns
	EXTERN errno
	#include "sysdefs.asm"
	RSEG	CODE
os_getdns:
	ld l,0x08
	jr OS_NETSOCKET1
os_setdns:
	ld l,0x07
	jr OS_NETSOCKET1
OS_LISTEN:
	ld l,0x06
	jr OS_NETSOCKET1
OS_BIND:
	ld l,0x05
	jr OS_NETSOCKET1
OS_ACCEPT:
	ld l,0x04
	jr OS_NETSOCKET1
OS_NETCONNECT:
	ld l,0x03
	jr OS_NETSOCKET1
OS_NETCLOSE:
	ld l,0x02
	jr OS_NETSOCKET1
OS_NETSOCKET:
	ld l,0x01
OS_NETSOCKET1:
	push ix
	push iy	
	ld a,c
	ex af,af'
	ld c,CMD_WIZNETOPEN
	call BDOS
	ld (errno),a
	ld a,l
	pop iy
	pop ix
	ret
	ENDMOD
		
	MODULE HTONS
	PUBLIC htons
	RSEG	CODE
htons:
	ld h,e
	ld l,d
	ret
	ENDMOD
	
	MODULE OS_NETRECV
	PUBLIC OS_NETRECV,OS_NETSEND
	EXTERN errno
	#include "sysdefs.asm"
	RSEG	CODE
OS_NETSEND:
	ld a,c
	ld c,CMD_WIZNETWRITE
	jr OS_NET_RW
OS_NETRECV:
	ld a,c
	ld c,CMD_WIZNETREAD	
OS_NET_RW:
	ex af,af'
	pop af
	pop hl
	push hl
	push af
	push ix
	push iy
	call BDOS
	ld (errno),a
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE OS_NETUDP
	PUBLIC OS_NETRECVFROM,OS_NETSENDTO
	EXTERN errno
	#include "sysdefs.asm"
	RSEG	CODE
OS_NETSENDTO:
	ld a,c
	ld c,CMD_WIZNETWRITE
	jr OS_NET_RW
OS_NETRECVFROM:
	ld a,c
	ld c,CMD_WIZNETREAD	
OS_NET_RW:
	ld (store_ix),ix
	ex af,af'
	pop af
	pop hl
	pop ix
	push ix
	push hl
	push af
	push iy
	call BDOS
	ld (errno),a
	pop iy
store_ix=$+2
	ld ix,0
	ret
	END
	