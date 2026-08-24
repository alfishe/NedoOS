
    MODULE TIME
    PUBLIC time
	#include "sysdefs.asm"
	RSEG CODE
time:
        push ix
        push iy
    ld c,CMD_GETTIMER ;out: dehl=timer
	call BDOS
        ld b,d
        ld c,e
        pop iy
        pop ix
        ret ;return bchl
        ENDMOD


;unsigned long OS_GETTIME (struct diskOp *); //out: ix=date, hl=time


    MODULE OS_GETTIME
    PUBLIC OS_GETTIME
	#include "sysdefs.asm"
	RSEG CODE
OS_GETTIME:
    push ix
    push iy
    ld c,CMD_GETTIME ;out: ix=date, hl=time
	call BDOS
	di
	push ix
	pop bc
	ei
  	pop iy
    pop ix
    ret ;return bchl
	ENDMOD

	MODULE ERRNOMOD
	PUBLIC errno
	RSEG	NO_INIT
errno:
	defs 1
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
	
	MODULE OS_RESERV_1
	PUBLIC os_reserv_1
	#include "sysdefs.asm"
	RSEG CODE
os_reserv_1:
	push bc
	push ix
	push iy
    ld c,CMD_RESERV_1
	call BDOS
	pop iy
	pop ix
	pop bc
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
	PUBLIC bdosgetkey
	EXTERN scrredraw,exit,YIELD
	#include "sysdefs.asm"
	RSEG CODE
bdosgetkey:
	push de
	push bc
	push ix
	push iy
	ld c,CMD_YIELD
	call BDOS
	rst 0x08
	cp key_esc
	jp z,exit
	cp key_redraw
	call z,scrredraw
	ld l,a
	ld h,0
	pop iy
	pop ix
	pop bc
	pop de
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
	
	MODULE YIELD
	PUBLIC YIELD
	#include "sysdefs.asm"
	RSEG CODE
YIELD:
	push bc
	push de
	push ix
	push iy
	ld c,CMD_YIELD
	call BDOS
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE SETMUSIC
	PUBLIC OS_SETMUSIC
	#include "sysdefs.asm"
	RSEG CODE
OS_SETMUSIC:	;DE - proc_ptr, A - ?
	ld h,d
	ld l,e
	ld a,c
    ex af,af'
	push ix
	push iy
	ld c,CMD_SETMUSIC	;hl=muzaddr (0x4000..0x7fff), a=muzpg
	call BDOS
	pop iy
	pop ix
	ret
	ENDMOD

	MODULE OSPLAYCOVOX
	PUBLIC OS_PLAYCOVOX
	#include "sysdefs.asm"
	RSEG CODE
;void OS_PLAYCOVOX(const OS_COVOX_PLAY *args);
;Legacy C wrapper. No curpgc000 restore. Use OS_PLAYCOVOX_PLAY for new code.
;struct { void *data; void *pagetable; unsigned char delay; }
;BDOS: HL=data (0xC000+), DE=pagetable (0x0000+), HX=delay.
OS_PLAYCOVOX:
	push bc
	push de
	push hl
	push ix
	push iy
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push de			;data
	push bc			;pagetable
	ld a,(hl)		;delay
	ld d,a
	ld ixh,d		; ld hx,d
	ld ixl,0
	pop de			;DE=pagetable
	pop hl			;HL=data
	ld c,CMD_PLAYCOVOX
	call BDOS
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE OSGETCONFIG
	PUBLIC OS_GETCONFIG
	#include "sysdefs.asm"
	RSEG CODE
OS_GETCONFIG:
    push bc
	ld c,CMD_GETCONFIG
	push de
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop de
    pop bc
	ret
	ENDMOD

	MODULE GETMAINPAGES
	PUBLIC OS_GETMAINPAGES,OS_GETAPPMAINPAGES
    EXTERN errno
 	#include "sysdefs.asm"
	RSEG CODE
OS_GETAPPMAINPAGES:
    ld c,CMD_GETAPPMAINPAGES
    jr l1
OS_GETMAINPAGES:
	ld c,CMD_GETMAINPAGES
l1
	push de
	push ix
 	push iy
	call BDOS
	ld b,d ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, a=error
 	ld c,e
 	pop iy
 	pop ix
	pop de
 	LD (errno), a
 	ret
 	ENDMOD

	MODULE SETPG32KHIGH
	PUBLIC SETPG32KHIGH
	#include "sysdefs.asm"
	RSEG CODE
SETPG32KHIGH:
	push bc
	push ix
	push iy
	ld a,e
	rst 0x28
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD

	MODULE OS_SETSCREEN
	PUBLIC OS_SETSCREEN
	#include "sysdefs.asm"
	RSEG CODE
OS_SETSCREEN:
   ;halt
	push bc
	push hl
	push ix
	push iy
	ld c,CMD_SETSCREEN	 ;e=screen=0..1
	call BDOS
	pop iy
	pop ix
	pop hl
	pop bc
	ret
	ENDMOD

	MODULE OS_SETPGC000
	PUBLIC OS_SETPGC000
	#include "sysdefs.asm"
	RSEG CODE
OS_SETPGC000:
	push bc
	push ix
	push iy
	ld a,e
	rst 0x28
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD

	MODULE OS_SETPG8000
	PUBLIC OS_SETPG8000
	#include "sysdefs.asm"
	RSEG CODE
OS_SETPG8000:
	push bc
	push ix
	push iy
	ld a,e
	rst 0x20
	pop iy
	pop ix
	pop bc
	ret
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
skipspaces
	inc de
	ld a,(de)
	or a
	jr z,get_cmd_args_end
	cp ' '
	jr nz,get_cmd_args_l2
	jr skipspaces
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


	MODULE OSDROPAPP
	PUBLIC OS_DROPAPP
	#include "sysdefs.asm"
	RSEG CODE
OS_DROPAPP:	;e=id ; hl=result
	ld c,CMD_DROPAPP
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ret
	ENDMOD

	MODULE OS_SETGFX
	PUBLIC OS_SETGFX
	#include "sysdefs.asm"
	RSEG CODE
OS_SETGFX:	;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	push bc
	push hl
	push ix
	push iy
	ld c,CMD_SETGFX
	halt
	call BDOS
	pop iy
	pop ix
	pop hl
	pop bc
	ld a, e
	ret
	ENDMOD

	MODULE OSGETPAGEOWNER	;e=page ;out: e=owner id (0=free, 0xff=system)
	PUBLIC OS_GETPAGEOWNER
	#include "sysdefs.asm"
	RSEG CODE
OS_GETPAGEOWNER:
    push bc
	push ix
	push iy
	ld c,CMD_GETPAGEOWNER
	call BDOS
	LD a, e
	pop iy
	pop ix
    pop bc
	ret
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

;Kulich Area

	MODULE OS_NEWPAGE	;out: a=0 (OK)/!=0 (fail), e=page
	PUBLIC OS_NEWPAGE
	#include "sysdefs.asm"
	RSEG CODE
OS_NEWPAGE:
    push bc
	ld c,CMD_NEWPAGE
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
    pop bc
	ld h,a			;error
	ld l,e			;page 
	ret
	ENDMOD

	MODULE OS_DELPAGE	;out: a=0 (OK)/!=0 (fail), e=page
	PUBLIC OS_DELPAGE
	#include "sysdefs.asm"
	RSEG CODE
OS_DELPAGE:
    push bc
	push hl
	ld c,CMD_DELPAGE
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
    pop hl
	pop bc
	ret
	ENDMOD

	MODULE OS_GETSCR0	
	PUBLIC OS_GETSCR0
	#include "sysdefs.asm"
	RSEG CODE
OS_GETSCR0:
	
	
	ld a,(user_scr0_high)
	ld h,a
	ld a,(user_scr0_low)
	ld l, a
	ret
	ENDMOD

	MODULE OS_GETSCR1	
	PUBLIC OS_GETSCR1
	#include "sysdefs.asm"
	RSEG CODE
OS_GETSCR1:
	ld a,(user_scr1_high)
	ld h,a
	ld a,(user_scr1_low)
	ld l,a
	ret
	ENDMOD

	MODULE OS_RENAME
	PUBLIC OS_RENAME
	#include "sysdefs.asm"
	RSEG CODE
; BDOS CMD_RENAME: in DE=old, HL=new; out A=FRESULT (0=FR_OK).
; FatFs leaves junk in HL (often a path/dir pointer). IAR unsigned char is L.
; Old wrapper did "ld a,l / pop hl" and returned that leftover, not success.
OS_RENAME:
	ld h,b
	ld l,c
	push ix
	push iy
	ld c,CMD_RENAME
	call BDOS
	pop iy
	pop ix
	ld l,a
	ld h,0
	ret
	ENDMOD

	MODULE OS_SETBORDER	
	PUBLIC OS_SETBORDER
	#include "sysdefs.asm"
	RSEG CODE
OS_SETBORDER:
	push bc
	push hl
	push ix
	push iy
    ld c,CMD_SETBORDER ;e=0..15
	call BDOS
	pop iy
	pop ix
	pop hl
	pop bc
	ret
	ENDMOD

	MODULE OS_DELETE
	PUBLIC OS_DELETE
	#include "sysdefs.asm"
	RSEG CODE
OS_DELETE:
	push bc
	push ix
	push iy
	ld c,CMD_DELETE
	call BDOS
	pop iy
	pop ix
	pop bc
	ld h,0
	ld l,a
	ret
	ENDMOD





	MODULE OS_READSECTORS	;de= pointer to diskOp structure
	PUBLIC OS_READSECTORS
	#include "sysdefs.asm"
	RSEG CODE
OS_READSECTORS:
	push bc
	push de
	push ix
	push iy

	ex de,hl
	ld b,(hl) 	;drive
	inc l
	ld e,(hl) 	;buffer L
	inc l
	ld d,(hl) 	;buffer H
	inc l
	push de
	ld e,(hl) 	;sector L
	inc l
	ld d,(hl) 	;sector H
	inc l
	ld  a,(hl)	;sector X
	ld  ixl,a
	inc l
	ld  a,(hl)	;sector I
	ld  ixh,a
	inc l
	ld  a,(hl)	;count
	pop hl
	ex de,hl
	ld c,CMD_READSECTORS
	ex af,af' ;'
    call BDOS ;c=CMD
	pop iy
	pop ix
	pop de
	pop bc
	ret		;BCHL
	ENDMOD	
	
	MODULE OS_WRITESECTORS	;de= pointer to diskOp structure
	PUBLIC OS_WRITESECTORS
	#include "sysdefs.asm"
	RSEG CODE
OS_WRITESECTORS:
	push bc
	push de
	push ix
	push iy

	ex de,hl
	ld b,(hl) 	;drive
	inc l
	ld e,(hl) 	;buffer L
	inc l
	ld d,(hl) 	;buffer H
	inc l
	push de
	ld e,(hl) 	;sector L
	inc l
	ld d,(hl) 	;sector H
	inc l
	ld  a,(hl)	;sector X
	ld  ixl,a
	inc l
	ld  a,(hl)	;sector I
	ld  ixh,a
	inc l
	ld  a,(hl)	;count
	pop hl
	ex de,hl
	ld c,CMD_WRITESECTORS
	ex af,af' ;'
    call BDOS ;c=CMD
	pop iy
	pop ix
	pop de
	pop bc
	ret		;BCHL	
	ENDMOD

	MODULE OS_GETPATH
	PUBLIC OS_GETPATH
	#include "sysdefs.asm"
	RSEG CODE
OS_GETPATH:
	push hl
	push bc
	push ix
	push iy
	ld c,CMD_GETPATH
	call BDOS
	pop iy
	pop ix
	pop bc
	pop hl
	ret
	ENDMOD

	MODULE OS_SETSYSDRV			
	PUBLIC OS_SETSYSDRV			
	#include "sysdefs.asm"
	RSEG CODE	
OS_SETSYSDRV
	push bc
	push de
	push ix
	push iy
	ld c,CMD_SETSYSDRV
	call BDOS
	pop iy
	pop ix
	pop de
	pop bc
	ld h,a						;h = error l = No of disks
	ret
	ENDMOD

	MODULE OS_CHDIR
	PUBLIC OS_CHDIR
	#include "sysdefs.asm"
	RSEG CODE
OS_CHDIR:
	push bc
	push ix
	push iy
	ld c,CMD_CHDIR				;DE = Pointer to ASCIIZ string. Out A=error
	call BDOS
	pop iy
	pop ix
	pop bc
	ld l,0
	ld h,a						;h = error 
	ret
	ENDMOD


	MODULE OS_NEWAPP
	PUBLIC OS_NEWAPP
	#include "sysdefs.asm"
	RSEG CODE
OS_NEWAPP:
	push bc
	ld (strPtr), de
	push ix
	push iy
	ld c,CMD_NEWAPP				;out: b=id, a=error, dehl=newapp pages in 0000,4000,8000,c000 ;MAKE NEW DISABLED APP
	call BDOS
	pop iy
	pop ix
	ld c,a
	push hl
	ld hl,(strPtr)
	ld (hl),d
	inc hl
	ld (hl),e
	pop hl
	ex de,hl
	ld hl,(strPtr)
	inc hl
	inc hl
	ld (hl),d
	inc hl
	ld (hl),e
	inc hl
	ld (hl),b
	inc hl
	ld (hl),c
	pop bc
	ret
strPtr
	DEFW 0000
	ENDMOD

	MODULE OS_RUNAPP
	PUBLIC OS_RUNAPP
	#include "sysdefs.asm"
	RSEG CODE
OS_RUNAPP:	
	push hl
	push bc
	push ix
	push iy
	ld c,CMD_RUNAPP	;e=id ;ACTIVATE DISABLED APP
	call BDOS
	pop iy
	pop ix
    pop bc
	pop hl
	ret
	ENDMOD

	MODULE OS_WAITPID
	PUBLIC OS_WAITPID
	#include "sysdefs.asm"
	RSEG CODE
OS_WAITPID:
	push bc
	push ix
	push iy
    ld c,CMD_SETWAITING
	call BDOS
	ld c,CMD_YIELD
	call BDOS
	ld c,CMD_GETCHILDRESULT
	call BDOS
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD




	MODULE OS_HIDEFROMPARENT
	PUBLIC OS_HIDEFROMPARENT
	#include "sysdefs.asm"
	RSEG CODE
OS_HIDEFROMPARENT:	
	push bc
	push ix
	push iy
	ld c,CMD_HIDEFROMPARENT
	call BDOS
	pop iy
	pop ix
    pop bc
	ret
	ENDMOD

	MODULE OS_CLS
	PUBLIC OS_CLS
	#include "sysdefs.asm"
	RSEG CODE
OS_CLS:
	push bc
	push hl
	push ix
	push iy
	ld c,CMD_CLS
	call BDOS
	pop iy
	pop ix
	pop hl
	pop bc
	ret
	ENDMOD



	MODULE OS_GETKEY
	PUBLIC OS_GETKEY
	PUBLIC mouse_yx
	PUBLIC mouse_x
	PUBLIC mouse_y
	PUBLIC mouse_btns
	RSEG NO_INIT
mouse_yx:
mouse_x:
	defs 1
mouse_y:
	defs 1
mouse_btns:
	defs 1
	RSEG CODE
OS_GETKEY:
	push ix
	push iy
    rst 0x08	;out: a=key (NOKEY=no key), de=mouse position (y,x), l=mouse buttons (bits 0,1,2: 0=pressed)+mouse wheel (bits 7..4), h=high bits of key|register, bc=keynolang, lx=kempston joystick, nz=no focus (mouse position=0, ignore it!)
	pop iy
	pop ix
	; NZ (no focus) still in F; publish counters for C (oscalls.h).
	push af
	ld (mouse_yx),de
	ld a,l
	ld (mouse_btns),a
	pop af
	ld l,a
	ld h,c
	ld bc,0x8000
	jp nz, focusFalse
	ld bc,0x0000
	focusFalse:
	ret 
	ENDMOD

	MODULE OS_GETMOUSE
	PUBLIC OS_GETMOUSE
	RSEG CODE
OS_GETMOUSE:
	push ix
	push iy
    rst 0x08	;out: a=key (NOKEY=no key), de=mouse position (y,x), l=mouse buttons (bits 0,1,2: 0=pressed)+mouse wheel (bits 7..4), h=high bits of key|register, bc=keynolang, lx=kempston joystick, nz=no focus (mouse position=0, ignore it!)
	pop iy
	pop ix
	ld h,c
	ld b,d
	ld c,e
	ret 
	ENDMOD

	MODULE OS_SETCOLOR
	PUBLIC OS_SETCOLOR
	#include "sysdefs.asm"
	RSEG CODE
OS_SETCOLOR
	push bc
	push hl
	push ix
	push iy
    ld c,CMD_SETCOLOR
	call BDOS
	pop iy
	pop ix
	pop hl
	pop bc
	ret
	ENDMOD


	MODULE OS_OPENDIR
	PUBLIC OS_OPENDIR
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_OPENDIR:
	push hl
	push bc
	ld c,CMD_OPENDIR	
	push ix
	push iy	
	call BDOS
	ld (errno),a
	pop iy
	pop ix
	pop bc
	pop hl
	ret
	ENDMOD


	MODULE OS_READDIR
	PUBLIC OS_READDIR
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_READDIR:
	push hl
	push bc
	ld c,CMD_READDIR	
	push ix
	push iy	
	call BDOS
	ld (errno),a
	pop iy
	pop ix
	pop bc
	pop hl
	ret
	ENDMOD
	
	MODULE OS_DIHALT
	PUBLIC OS_DIHALT
	RSEG CODE
OS_DIHALT:
	DI
	HALT
	ret
	ENDMOD

	; unsigned char OS_GETFILETIME(char *path, unsigned int *date, unsigned int *time)
	; IAR: DE=path, BC=&date, time* on stack at entry SP+2
	; After PUSH IX,IY,BC and POP BC: time* is at SP+6 (IY,IX,ret,time*)
	; BDOS: DE=path, out IX=date, HL=time
	MODULE OS_GETFILETIME
	PUBLIC OS_GETFILETIME
	EXTERN errno
	#include "sysdefs.asm"
	RSEG	NO_INIT
OS_GETFILETIME_DATE:
	DEFS	2
OS_GETFILETIME_TIME:
	DEFS	2
	RSEG CODE
OS_GETFILETIME:
	PUSH	IX
	PUSH	IY
	PUSH	BC
	LD	C,CMD_GETFILETIME
	CALL	BDOS
	LD	(errno),A
	DI
	LD	(OS_GETFILETIME_TIME),HL
	PUSH	IX
	POP	HL
	LD	(OS_GETFILETIME_DATE),HL
	EI
	POP	BC
	LD	HL,(OS_GETFILETIME_DATE)
	LD	A,L
	LD	(BC),A
	INC	BC
	LD	A,H
	LD	(BC),A
	LD	HL,6
	ADD	HL,SP
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,(OS_GETFILETIME_TIME)
	LD	A,L
	LD	(DE),A
	INC	DE
	LD	A,H
	LD	(DE),A
	POP	IY
	POP	IX
	LD	A,(errno)
	LD	L,A
	LD	H,0
	RET
	ENDMOD

	; unsigned char OS_SETFILETIME(char *path, unsigned int date, unsigned int time)
	; IAR: DE=path, BC=date, time on stack at entry SP+2
	; After PUSH IX,IY and date->IX: [IY][IXsave][ret][time] => time at SP+6
	; (Do not use SP+8: that only matched an old redundant PUSH DE.)
	; BDOS: DE=path, IX=date, HL=time
	MODULE OS_SETFILETIME
	PUBLIC OS_SETFILETIME
	EXTERN errno
	#include "sysdefs.asm"
	RSEG CODE
OS_SETFILETIME:
	PUSH	IX
	PUSH	IY
	PUSH	BC
	POP	IX
	LD	HL,6
	ADD	HL,SP
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	C,CMD_SETFILETIME
	CALL	BDOS
	LD	(errno),A
	POP	IY
	POP	IX
	LD	L,A
	LD	H,0
	RET
	ENDMOD

	END
	