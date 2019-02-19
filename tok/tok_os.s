;startup
FCB1=0xe800 ;aligned ;len=0x0200*files
DOSBUF=0xfe00 ;aligned
	include "../_sdk/sysdefs.asm"
;COMMANDLINE=0x0080
;COMMANDLINE_sz=0x0080
;PROGSTART=0x0100

	org PROGSTART
cmd_begin
	call tokinit
	
	ld hl,fnbuf.
	ld (tokenize.fn),hl
	ld hl,COMMANDLINE
        ld a,' '
        ld bc,COMMANDLINE_sz
        cpir
        jr nz,cmdquit ;если параметров вообще нет
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
	or a ;cp 0x0d ;CR
	inc hl
	jr nz,loop.

	call tokenize_end
cmdquit
	rst 0 ;QUIT

	include "../_sdk/read.ast"
	include "token.ast"
	include "tokenz80.ast"
	include "../_sdk/lib.i"
	include "../_sdk/io_os.i"
	include "../_sdk/str.i"

fnbuf.
	db "12345678.123 "
	ds COMMANDLINE_sz-11;50 ;for long filenames

	include "../_sdk/read.var"
	include "../_sdk/fmttg.var"
	include "token.var"
	include "tokenz80.var"

cmd_end

	;display "tok size ",/d,cmd_end-cmd_begin," bytes"

	;savebin "tok.com",cmd_begin,cmd_end-cmd_begin
