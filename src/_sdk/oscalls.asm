
	MODULE OSSYSDRV
	PUBLIC syspath
	#include "syssets.asm"
	RSEG	CONST
syspath:
	defb SYSDRV+'0',":/bin"
	ENDMOD

	MODULE ERRNOMOD
	PUBLIC errno
	RSEG	NO_INIT
errno:
	defs 1
	ENDMOD
	
	MODULE OS_NETSOCKET
	PUBLIC OS_NETSOCKET,OS_NETCONNECT,OS_NETCLOSE
	PUBLIC OS_ACCEPT,OS_BIND,OS_LISTEN
	EXTERN errno
	#include "sysdefs.asm"
	RSEG	CODE
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
	
	MODULE OSOPENHANDLE
	PUBLIC OS_CLOSEHANDLE,OS_OPENHANDLE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_OPENHANDLE:
	ld a,c
    ex af,af'
	ld c,CMD_OPENHANDLE	
	jr label1
OS_CLOSEHANDLE:
	ld b,d
	ld c,CMD_CLOSEHANDLE
label1:
	push ix
	push iy	
	call BDOS
	ld (errno),a
	ld h,b
	ld l,a
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE OSDIRCALLS
	PUBLIC OS_SETDTA,OS_FSEARCHFIRST,OS_FSEARCHNEXT,OS_CHDIR
	PUBLIC OS_MKDIR,OS_DELETE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_DELETE:
	ld c,CMD_DELETE	
	jr label1
OS_MKDIR:
	ld c,CMD_MKDIR	
	jr label1
OS_CHDIR:
	ld c,CMD_CHDIR	
	jr label1
OS_FSEARCHNEXT:
	ld c,CMD_FSEARCHNEXT	
	jr label1
OS_FSEARCHFIRST:
	ld c,CMD_FSEARCHFIRST	
	jr label1
OS_SETDTA:
	ld c,CMD_SETDTA
label1:
	push ix
	push iy	
	call BDOS
	ld (errno),a
	pop iy
	pop ix
	ret
	ENDMOD
	
	
	MODULE OSWRITEHANDLE
	PUBLIC OS_WRITEHANDLE,OS_READHANDLE,OS_GETPATH
	PUBLIC OS_GETFILESIZE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_GETFILESIZE:
	ld c,CMD_GETFILESIZE
	ld b,d
	jr label1
OS_GETPATH:
	ld c,CMD_GETPATH	
	jr label1
OS_READHANDLE:
	ld c,CMD_READHANDLE	
	jr label1
OS_WRITEHANDLE:
	ld c,CMD_WRITEHANDLE
label1:
	pop af
	pop hl
	push hl
	push af
	push ix
	push iy	
	call BDOS
	ld (errno),a
	ld b,d
	ld c,e
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE OSCREATEHANDLE
	PUBLIC OS_CREATEHANDLE
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_CREATEHANDLE:
	push ix
	push iy
	ld a,c
	and 0x80
	ld b,a
	ld a,c
	and 0x7f
    ex af,af'
	ld c,CMD_CREATEHANDLE	
	call BDOS
	ld (errno),a
	ld h,b
	ld l,a
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE OSSETXY
	PUBLIC OS_SETXY,OS_GETXY,OS_CLS,OS_SETGFX,OS_SCROLLUP
	#include "sysdefs.asm"
	RSEG CODE
OS_SCROLLUP:
	ld h,b
	ld l,c
	ld c,CMD_SCROLLUP
	jr label1
OS_SETGFX:
	ld c,CMD_SETGFX
	jr label1
OS_CLS:
	ld c,CMD_CLS
	jr label1
OS_GETXY:
	ld c,CMD_GETXY	;de=yx ;GET CURSOR POSITION
	jr label1
OS_SETXY:
	ld d,c
	ld c,CMD_SETXY	;de=yx ;SET CURSOR POSITION
label1:
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ret			;h-y l-x
	ENDMOD
	
	MODULE PUTS
	PUBLIC puts
	RSEG CODE
puts:
	push ix
	push iy
	push de
ploop:
	pop hl
	ld a,(hl)
	or a
	jr z,pexit
	inc hl
	push hl
	rst 0x10
	jr ploop
pexit:
	ld a,'\r'
	rst 0x10
	ld a,'\n'
	rst 0x10
	ld hl,0x0000
	pop iy
	pop ix
	ret
	ENDMOD
	
	MODULE MYGETCHAR
	PUBLIC getchar
	EXTERN _low_level_get
	RSEG CODE
getchar:
	call _low_level_get
	or a
	jr z,getchar
	ld l,a
	ld h,0
	ret	
	ENDMOD
	
	MODULE SCRREDRAW
	PUBLIC scrredraw
	RSEG CODE
scrredraw:
	xor a
	ret	
	ENDMOD
	
	MODULE OSLOWGET
	PUBLIC _low_level_get
	EXTERN scrredraw,exit,YIELD
	#include "sysdefs.asm"
	RSEG CODE
_low_level_get:
	call YIELD
	push ix
	push iy
	rst 0x08
	cp key_redraw
	call z,scrredraw
	cp csSpace
	jp z,exit
	ld l,a
	ld h,0
	pop iy
	pop ix
	ret
	ENDMOD

	MODULE conv1251to866
	PUBLIC conv1251to866, t1251to866
	RSEG CODE
conv1251to866:	;DE-string
	push de
ploop:
	ld a,(de)
	or a
	jr z,pexit
	cp 128
	jr c,asci
	add a,low(t1251to866-128)
	ld l,a
	ld a,0
	adc a,high(t1251to866-128)
	ld h,a
	ld a,(hl)
	ld (de),a
asci:
	inc de
	jr ploop
pexit:
	pop de
	ret
	RSEG	CONST
t1251to866:
	DEFB 0x3F, 0x3F, 0x27, 0x3F, 0x22, 0x3A, 0xC5, 0xD8, 0x3F, 0x25, 0x3F, 0x3C, 0x3F, 0x3F, 0x3F, 0x3F 
	DEFB 0x30, 0x3F, 0x27, 0x27, 0x22, 0x22, 0x07, 0x2D, 0x2D, 0x54, 0x3F, 0x3E, 0x3F, 0x3F, 0x3F, 0x3F 
	DEFB 0xFF, 0xF6, 0xF7, 0x3F, 0xFD, 0x3F, 0xB3, 0x15, 0xF0, 0x63, 0xF2, 0x3C, 0xBF, 0x2D, 0x52, 0xF4 
	DEFB 0xF8, 0x2B, 0x3F, 0x3F, 0x3F, 0xE7, 0x14, 0xFA, 0xF1, 0xFC, 0xF3, 0x3E, 0x3F, 0x3F, 0x3F, 0xF5 
	DEFB 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F 
	DEFB 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F 
	DEFB 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7, 0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF 
	DEFB 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7, 0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF
	ENDMOD
	
	MODULE OSPRCHAR
	PUBLIC putchar
	RSEG CODE
putchar:
	push de
	push ix
	push iy
	ld a,e
	rst 0x10
	pop iy
	pop ix
	pop hl
	ret
	ENDMOD

	MODULE YIELD
	PUBLIC YIELD
	#include "sysdefs.asm"
	RSEG CODE
YIELD:
	push bc
	push de
	push ix
	push iy
	ld c,0xf2
	call 0x0005
yield_loop:
	ld c,0xf1
	call 0x0005
    ld hl,(oldtimer)
    ld (oldtimer),de
    or a
    sbc hl,de
    jr z,yield_loop
	pop iy
	pop ix
	pop de
	pop bc
	ret
	RSEG	UDATA0
oldtimer:
	defs 2 
	ENDMOD
	
	MODULE MAIN_ARGS
	PUBLIC main_args
	RSEG CODE
main_args
	ld hl,args
	ld de,0x0080
get_cmd_args_l2
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	dec de
get_cmd_args_l
	inc de
	ld a,(de)
	or a
	jr z,get_cmd_args_end
	cp ' '
	jr nz,get_cmd_args_l
	xor a
	ld (de),a
	inc de
	jr get_cmd_args_l2
get_cmd_args_end:
	ld bc,args
	sbc hl,bc
	ex de,hl
	srl e
	ret
	RSEG	NO_INIT
args:
	defs 32
	ENDMOD
	
	MODULE	my_im2
	PUBLIC	my_im2_init
	RSEG	INTJP
	DEFS 3
	RSEG	INTTABLE
	DEFS 257
	RSEG	CODE
my_im2_init
	di
	ld a,0xc3
	ld (SFB(INTJP)),a
	ld (SFB(INTJP)+1),de
	ld a,HIGH(SFB(INTTABLE))
	ld i,a
	inc a
	ld hl,SFB(INTTABLE)-1
tloop
	inc hl
	ld (hl),HIGH(SFB(INTJP))
	cp h
	jr nz,tloop
	im 2
	ret
	ENDMOD
	
	NAME	CSTARTUP
	EXTERN	main_args,exit			; where to begin execution
	EXTERN	?C_EXIT,main			; where to go when program is done
	RSEG	CSTACK
	DEFS	0			; a bare minimum !
	RSEG	UDATA0
	RSEG	IDATA0
	RSEG	ECSTR
	RSEG	TEMP
	RSEG	DATA0
	RSEG	WCSTR
	RSEG	CDATA0
	RSEG	CCSTR
	RSEG	CONST
	RSEG	CSTR
	ASEG
	ORG	0x0100
init_A
	JP	init_C
	RSEG	RCODE
init_C
	LD	SP,.SFE.(CSTACK-1)	; from high to low address
	CALL	seg_init
	call 	main_args
	CALL	main			; non-banked call to main()
	JP	exit
	
seg_init
	LD	HL,.SFE.(UDATA0)
	LD	DE,.SFB.(UDATA0)
	CALL	zero_mem
	LD	DE,.SFB.(IDATA0)		;destination address
	LD	HL,.SFE.(CDATA0)
	LD	BC,.SFB.(CDATA0)
	CALL	copy_mem
	LD	DE,.SFB.(ECSTR)			;destination address
	LD	HL,.SFE.(CCSTR)
	LD	BC,.SFB.(CCSTR)
copy_mem
	XOR	A
	SBC	HL,BC
	PUSH	BC
	LD	C,L
	LD	B,H				; BC - that many bytes
	POP	HL				; source address
	RET	Z				; If block size = 0 return now
	LDIR
	RET
zero_mem
	XOR	A
again	PUSH	HL
	SBC	HL,DE
	POP	HL
	RET	Z
	LD	(DE),A
	INC	DE
	JR	again
	COMMON	INTVEC
	ENDMOD	init_A
	
	MODULE	exit
	PUBLIC	exit
	PUBLIC	?C_EXIT
	RSEG	RCODE
?C_EXIT
exit	EQU	?C_EXIT
	jp 0x0000			; loop forever
	END

	