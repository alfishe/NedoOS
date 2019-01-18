;startup
TRUE=0xff
FALSE=0x00
	org 0x6000
	jp startup.
_=$
	include "compcode.dcl"
	incbin "compcode.bin"
startup.
	;pop hl
	;push hl
	;ld a,h
	;cp 0x3d
	;jr nz,start.
	;ld hl,start.
	;ld (23834),hl ;адрес запуска
	;ld hl,467 ;выход (иначе возврат в бейсик после RUN "..." CODE невозможен)
	;push hl
	;jp 0x3d2f ;call in DOS
;start.
	LD HL,fnerr.
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_ferr],HL
	LD A,TRUE
	LD [_errs],A

	ld hl,fnbuf.
	ld (compile.fn),hl
	ld hl,(23645) ;CH_ADD
	ld bc,256
	ld a,234 ;REM
	;cpir
	db 0xed,0xb1
loop.
	dec hl
	ld de,fnbuf.-1
l0.
	inc hl
	inc de
	ld a,(hl)
	ld (de),a
	cp ' '+1
	jr nc,l0. ;read until space or CR
	xor a
	ld (de),a ;'\0'

	push hl
	call compile
	pop hl

	ld a,(hl)
	cp 0x0d ;CR
	inc hl
	jr nz,loop.

	LD HL,[_ferr]
	LD [fclose.A.],HL
	CALL fclose

	;ld hl,10072
	;exx
	ret

	include "../_sdk/read.asm"
	include "compile.asm"

fnbuf.
	db "12345678.123"
	db 0
fnerr.
	db "err.f"
	db 0

	include "../_sdk/read.var"
	include "compile.var"
