	
	MODULE RST8CALL
	PUBLIC rst8call,trdvars
	EXTERN save_pg,exret
	EXTERN errno
	RSEG CODE
trdvars=0x5c00
rst8call:
	di
	pop af
	pop hl
	push hl
	push af
	push ix
	push iy
	ld (funcn),de
	push bc
	ld a,0x03
	ld bc,0x3ff7
	out (c),a
	pop bc
	ld a,c
	rst 8
funcn:
	defb 0x50,0x03
	ld a,0
	adc a,a
	ld (errno),a
	ld (exret),hl
	ld a,0x7f
	ld bc,0x3ff7
	out (c),a
	ld a,(save_pg)
	ld bc,0x37f7
	out (c),a
	ei
	ex de,hl
	pop iy
	pop ix
	ret
	
	END
	