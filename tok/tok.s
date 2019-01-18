;startup
FCB1=0x4800 ;aligned ;len=0x0200*files
DOSBUF=0xff00 ;aligned
	org 0x6000
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
	call tokinit
	
	ld hl,fnbuf.
	ld (tokenize.fn),hl
	ld hl,(23645) ;CH_ADD
	ld b,1;bc,256
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
	call tokenize
	pop hl

	ld a,(hl)
	cp 0x0d ;CR
	inc hl
	jr nz,loop.

	call tokenize_end

	;ld hl,10072
	;exx
	ret

	include "../_sdk/read.asm"
	include "token.asm"
	include "tokenz80.asm"
	include "../_sdk/lib.i"
	include "../_sdk/io.i"
	include "../_sdk/str.i"
	include "../_sdk/io.asm"

fnbuf.
	db "12345678.123 "
	ds 50 ;for long filenames

	include "../_sdk/io.var"
	include "../_sdk/read.var"
	include "../_sdk/fmttg.var"
	include "token.var"
	include "tokenz80.var"
