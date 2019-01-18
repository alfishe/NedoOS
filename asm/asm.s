;startup
FCB1=0x4800 ;aligned ;len=0x0200*files
DOSBUF=0xff00 ;aligned
	org 0x6000
	LD HL,fnerr.
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_ferr],HL
	LD A,TRUE
	LD [_errs],A

	ld hl,(23645) ;CH_ADD
	ld b,1;bc,256
	ld a,234 ;REM
	;cpir
	db 0xed,0xb1

	ld de,fnbuf.
	ld (asmcompile.fn),de
l0.
	ld a,(hl)
	inc hl
	ld (de),a
	inc de
	cp ' '+1
	jr nc,l0. ;read until space or CR
	dec de
	xor a
	ld (de),a ;'\0'

	call asmcompile

	LD HL,[_ferr]
	LD [fclose.A.],HL
	jp fclose

	include "../_sdk/emit.asm"
	include "asm.asm"
	include "asmloop.asm"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	;include "../_sdk/io.asm"
	include "../_sdk/iofast.i"

fnbuf.
	;db "12345678.123"
	;db 0
fnerr.
	db "asmerr.f"
	db 0
	ds 4 ;for full name 8+3
	ds 12 ;for ../direname/

	;include "../_sdk/io.var"
	include "../_sdk/emit.var"
	include "../_sdk/fmttg.var"
	include "asm.var"
	include "asmloop.var"
