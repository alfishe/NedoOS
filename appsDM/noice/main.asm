	DEVICE ZXSPECTRUM128
start_hobeta=0x8000
	ORG 0x0100
START
	di
	
	ld sp,0x8000
	ld hl,st_dbg
	ld de,noicemon.RESET
	ld bc,1024
	ldir
	
	jp noicemon.RESET
st_dbg
	disp 0xfc00
	INCLUDE "monz80.asm"
	ENT

ENDPROG
	SAVEBIN "nim.com",START,ENDPROG-START

