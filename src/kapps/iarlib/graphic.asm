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
	ld (pg0), a
	push hl
	push bc ; not for exit 
	push de ; not for exit 
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
	halt
	call  BDOS
	pop iy
	pop ix
	
	ld a,(user_scr0_high)
	
	push ix
	push iy
	rst 0x28
	pop iy
	pop ix
	
    pop hl			; DE - buffer adress
	ld de, 0xC000
	ld bc, 6912
	ldir
    xor a
	out (0xfe), a

	pop bc			; tics
	ld a, b
    or c
    jp nz, slideshow
	
inkey
	
	YIELD
	
	push ix
	push iy
	rst 0x08
	pop iy
	pop ix
	halt
	halt
	jp nz, inkey
	ld a,c
	or a
	jp z, inkey

exit3
	ld (pg0), a
	ld e, -1
	ld c, CMD_SETGFX
	push ix
	push iy
	halt
	call BDOS
	pop iy
	pop ix
	ld a, (pgC)
	push ix
	push iy
	rst 0x28
	pop iy
	pop ix
	pop hl
	ld a, (pg0)
	halt
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
