MODULE viewScreen6912
PUBLIC viewScreen6912
#include "sysdefs.asm"
RSEG CODE

	macro YIELD
	push bc
	ld c, CMD_YIELD
	push ix
	push iy
	call  BDOS
	pop iy
	pop ix
	pop bc
	endm


viewScreen6912:	
; unsigned int viewScreen6912(unsigned char pause, unsigned int bufAdr);
; DE = buffer adress BC = time in ints out A = key
	xor a
	ld (key), a
	push hl
	push bc ; not for exit 
	push de ; not for exit 

	ld c, CMD_GETMAINPAGES	;d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
	push ix
	push iy
	call BDOS
	pop iy
	pop ix	

	ld (pg4),de
	ld (pgC),hl
display:
	ld e, 0x83
	ld c, CMD_SETGFX
	push ix
	push iy
	halt
	call  BDOS
	pop iy
	pop ix
	
	ld a,(user_scr0_high)
	
	push ix
	push iy
	rst 0x28		;SETPGC000
	pop iy
	pop ix
	
    pop hl			; DE - buffer adress
	ld de, 0xC000
	ld bc, 6912
	ldir
    
	xor a
	out (0xfe), a	;border 0

	pop bc			; tics
	ld a, b
    or c
    jp nz, slideshow	;	tics != 0
	
inkey
	
	YIELD
	
	push ix
	push iy
	rst 0x08		;OS_GETKEY
	pop iy
	pop ix
	halt
	halt
	jp nz, inkey
	ld a,c
	or a
	jp z, inkey

exit3
	ld (key), a
	ld e, 0x86
	ld c, CMD_SETGFX
	push ix
	push iy
	;halt
	call BDOS
	pop iy
	pop ix
	ld a, (pgC)
	push ix
	push iy
	rst 0x28	;SETPGC000
	pop iy
	pop ix
	pop hl
	ld a, (key)
	ret

slideshow ;BC ints
	YIELD
	dec bc
	ld (waiting),bc

	push ix
	push iy
	rst 0x08
	pop iy
	pop ix	
	ld a,c
	or a
    jp nz, exit3	
	halt
	ld bc,(waiting)
	ld a, b
    or c
    jp nz, slideshow
	ld a, 32
	jp exit3	
pg4		defb 0
pg0		defb 0
pgC		defb 0
pg8		defb 0
waiting defw 0
key		defb 0
ENDMOD

MODULE rst0x08
PUBLIC rst0x08
#include "sysdefs.asm"
RSEG CODE
rst0x08:	
	push ix
	push iy
	rst 0x08
	pop iy
	pop ix
	ld a,c
	ret
ENDMOD	

MODULE viewScreen6912NoKeyGraph
PUBLIC viewScreen6912NoKeyGraph
#include "sysdefs.asm"
RSEG CODE

viewScreen6912NoKeyGraph:	
	ld a, d
	ld (waiting), a		; ints
	ld (bufAdr), bc		; bufadr
	ld a, e
	ld (border), a		; border

	ld e, a
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


	push hl

	ld c, CMD_GETMAINPAGES	;d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
	push ix
	push iy
	call BDOS
	pop iy
	pop ix	

	ld (pg4),de
	ld (pgC),hl
display:
	ld a, (curScr)
	or a
	ld a,(user_scr1_high)
	jp z, fillScr
	ld a,(user_scr0_high)

fillScr
	push ix
	push iy
	rst 0x28		;SETPGC000
	pop iy
	pop ix
/*
	ld hl, 0xD800
	ld de, 768
emptybuf
	inc hl
	ld (hl), 0
	dec de
	ld  a, d
	or d
	jp nz, emptybuf
*/
    ld hl, (bufAdr)
	ld de, 0xC000
	ld bc, 6912
	ldir

	ld a, (curScr)
	xor 1
	ld (curScr), a

changeScr
	ld a, (curScr)
	ld e,a
    push bc
	push hl
	push ix
	push iy
	ld c,CMD_SETSCREEN
	call BDOS
	pop iy
	pop ix
	pop hl
	pop bc


slideshow ;BC ints
	ld a, (waiting)
	ld c, a
slideshow2
	halt
	dec c
    jp nz, slideshow2
exit3
	ld a, (pgC)
	push ix
	push iy
	rst 0x28	;SETPGC000
	pop iy
	pop ix
	pop hl
	ret




pg4		defb 0
pg0		defb 0
pgC		defb 0
pg8		defb 0
waiting defw 0
bufAdr  defw 0
border	defw 0
curScr  defb 0

ENDMOD

MODULE rst0x08
PUBLIC rst0x08
#include "sysdefs.asm"
RSEG CODE
rst0x08:	
	push ix
	push iy
	rst 0x08
	pop iy
	pop ix
	ld a,c
	ret
ENDMOD	
END
