	DEVICE ZXSPECTRUM128
	org 0x0100
	
startcode:
	di
	ld hl,font866
	ld de,0x2000
	ld bc,2048
	ld a,4
	out (0xbf),a
	ldir
	ld a,0
	out (0xbf),a
	ei
	jp 0x0000
font866:
	incbin "866_code.fnt"
endcode:
	savebin "..\..\bin\setfont.com",startcode,endcode-startcode