MODULE viewScreen6912
PUBLIC viewScreen6912
#include "sysdefs.asm"
RSEG CODE

viewScreen6912:	
; unsigned int viewScreen6912(unsigned char pause, unsigned int bufAdr);
; DE = buffer adress
	push hl
	push bc
	push de
	ld c, CMD_GETMAINPAGES
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
	call  BDOS
	pop iy
	pop ix
	
	ld a,(user_scr0_high)
	
	push ix
	push iy
	rst 0x28
	pop iy
	pop ix
	
    pop hl
	ld de, 0xC000
	ld bc, 6912
	ldir
    xor a
	out (0xfe), a
 
inkey
	ld c, CMD_YIELD
	push ix
	push iy
	call  BDOS
	pop iy
	pop ix
	
	push ix
	push iy
	rst 0x08
	pop iy
	pop ix	
	
	ld a,c
	ld (pg0), a
	cp 00
	jp z, inkey
	ld l, c	
	ld e, -1
	ld c, CMD_SETGFX
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	ld a, (pgC)
	push ix
	push iy
	rst 0x28
	pop iy
	pop ix
	pop bc
	pop hl
	ld a, (pg0)
	ret
pg4		defb 0
pg0		defb 0
pgC		defb 0
pg8		defb 0
ENDMOD
END
