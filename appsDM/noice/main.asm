	DEVICE ZXSPECTRUM128
start_hobeta=0x8000
	ORG 0x0100
START
	di
	
	ld sp,0x8000
	ld a,0xc3
	ld (0x0030),a	
	ld hl,BRK_POINT
	ld (0x0031),hl
	ld hl,st_dbg
	ld de,0xfc00
	ld bc,1024
	ldir
	
	jp RESET
st_dbg
	disp 0xfc00
	INCLUDE "monz80.asm"
	ENT

ENDPROG
	;display ENDPROG
	SAVEBIN "nim.com",START,ENDPROG-START
	;org start_hobeta
	;INCBIN "../utils/us/aa"
	;SAVEHOB  "noice.$c","noice.C",start_hobeta,ENDPROG-START
	;LABELSLIST  "../utils/us/user.l"

