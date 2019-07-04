;startup
TRUE=0xff
FALSE=0x00
	include "../../_sdk/sysdefs.asm"
;COMMANDLINE=0x0080
;COMMANDLINE_sz=0x0080
;PROGSTART=0x0100
	org PROGSTART
	jp startup. ;3 байта!
_=$
	include "compc_os.dcl"
	incbin "compc_os.bin"
startup.
        ld hl,0xe800 ;FCB1
        ld de,0xe801
        ld bc,0x17ff
        ld [hl],0
        ldir

	LD HL,fnerr.
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_ferr],HL
	LD A,TRUE
	LD [_errs],A

	ld hl,fnbuf.
	ld (compile.fn),hl
        
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
	call compile
	pop hl

	ld a,(hl)
	or a ;cp 0x0d ;CR
	inc hl
	jr nz,loop.

	LD HL,[_ferr]
	LD [fclose.A.],HL
	CALL fclose
cmdquit
	;QUIT
	rst 0x00

	include "../_sdk/read.ast"
	include "compile.ast"

fnbuf.
	ds COMMANDLINE_sz;db "12345678.123"
	;db 0
fnerr.
	db "err.f"
	db 0

	include "../_sdk/read.var"
	include "compile.var"
