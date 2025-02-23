        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

        org PROGSTART
cmd_begin:

	ld	bc,0xfffd
	ld	a,0xfe
	out	(c),a
	call	shut_ay

	ld	bc,0xfffd
	out	(c),b
	call 	shut_ay

	ld	hl,0
	QUIT

shut_ay:
	ld	hl,tbl

	ld	a,4
.loop
	ld	b,0x00
	outi
	ld	b,0xc0
	outi
	dec	a
	jr	nz,.loop

	ret

tbl:	
	db	7,0xFF
	db	8,0
	db	9,0
	db	10,0
	

cmd_end:

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "shay.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
