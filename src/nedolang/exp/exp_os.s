;startup
FCB1=0xe800 ;aligned ;len=0x0200*files
DOSBUF=0xfe00 ;aligned
	include "../../_sdk/sysdefs.asm"
;COMMANDLINE=0x0080
;COMMANDLINE_sz=0x0080
;PROGSTART=0x0100
_STRLEN=80
_STRMAX=(_STRLEN-1)
	org PROGSTART
        ld hl,0xe800 ;FCB1
        ld de,0xe801
        ld bc,0x17ff
        ld [hl],0
        ldir

	ld hl,COMMANDLINE
skipword0
        ld a,(hl)
        inc hl
        or a
        jr z,cmdquit ;если параметров вообще нет
        cp ' '
        jr nz,skipword0
skipwordq
        
	ld de,fn1.
	ld (asmexport.fn),de
	call copyfn.

        call asmexport
cmdquit
        rst 0x00 ;QUIT

copyfn.
l0.
	ld a,(hl)
	inc hl
	ld (de),a
	inc de
	cp ' '+1
	jr nc,l0. ;read until space or CR
	xor a
	dec de
	ld (de),a ;'\0'
	ret

	include "export.ast"
	include "exporttg.ast"
	include "../_sdk/lib.i"
	include "../_sdk/str.i" ;for io
	include "../_sdk/io_os.i"
	;include "../_sdk/print.i"

fn1.
	db "tok.f"
	db 0
        ds 50 ;for long filenames

	include "../_sdk/fmttg.var"
	include "export.var"
	include "exporttg.var"
