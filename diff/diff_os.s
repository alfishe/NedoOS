;startup
FCB1=0xe800 ;aligned ;len=0x0200*files
DOSBUF=0xfe00 ;aligned
COMMANDLINE=0x0080
COMMANDLINE_sz=0x0080
PROGSTART=0x0100
_STRLEN=80
_STRMAX=(_STRLEN-1)
	org PROGSTART
        ld e,6 ;textmode
        ;OS_SETGFX
        ld c,0xf9
        call 0x0005
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
	ld (diff.fn1),de
	call copyfn.
	ld de,fn2.
	ld (diff.fn2),de
	call copyfn.

        call diff
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

	include "diff.asm"
	include "../_sdk/lib.i"
	include "../_sdk/print_os.i"
	include "../_sdk/str.i"
	include "../_sdk/io_os.i"

fn1.
	db "nedoasm"
	db 0
        ds 50 ;for long filenames
fn2.
	db "bin.f"
	db 0
        ds 50 ;for long filenames

	include "diff.var"
