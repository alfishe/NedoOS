;startup
FCB1=0xe800 ;aligned ;len=0x0200*files
DOSBUF=0xfe00 ;aligned
	include "../../_sdk/sysdefs.asm"
;COMMANDLINE=0x0080
;COMMANDLINE_sz=0x0080
;PROGSTART=0x0100
	org PROGSTART
        ld hl,0xe800 ;FCB1
        ld de,0xe801
        ld bc,0x17ff
        ld [hl],0
        ldir
       
	ld de,fnbuf.
	ld (asmcompile.fn),de
	ld hl,COMMANDLINE
skipword0
        ld a,(hl)
        inc hl
        or a
        jr z,cmdquit ;если параметров вообще нет
        cp ' '
        jr nz,skipword0
skipwordq
        push hl
        push de
        
	LD HL,fnerr.
	LD [openwrite.A.],HL
	CALL openwrite
	LD [_ferr],HL
	LD A,TRUE
	LD [_errs],A

        pop de
        pop hl
        
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
;cmdquit
	LD HL,[_ferr]
	LD [fclose.A.],HL
	call fclose
cmdquit
        rst 0x00 ;QUIT

	include "../_sdk/emit.ast"
	include "asm.ast"
	include "asmloop.ast"
	include "findlbl.i"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	include "../_sdk/io_os.i"

fnbuf.
	;db "12345678.123"
	;db 0
fnerr.
	db "asmerr.f"
	db 0
	ds 4 ;for full name 8+3
	ds COMMANDLINE_sz-11;12 ;for ../direname/

	include "../_sdk/emit.var"
	include "../_sdk/fmttg.var"
	include "asm.var"
	include "asmloop.var"
