;startup
FCB1=0x4800 ;aligned ;len=0x0200*files
DOSBUF=0xff00 ;aligned
CH_ADD=23645
;PARADDR=0x5801
RUNADDR=0x6000
	org 64000
        ld hl,start.
        ld (23834),hl ;адрес запуска
        ld hl,467 ;выход (иначе возврат в бейсик после RUN "..." CODE невозможен)
        push hl
        jp 0x3d2f ;call in DOS
start.
	 ld hl,(CH_ADD)
	 push hl
	 ld hl,PARADDR-1
	 ld (hl),0xea ;REM
	 ld (CH_ADD),hl
	;ld hl,fn
	;ld (batch.fn),hl
        call batch
	 pop hl
	 ld (CH_ADD),hl
        ld hl,10072
        exx
        ld hl,(23672)
        add hl,hl
        ld b,h
        ld c,l ;centiseconds
        ret

	include "batch.asm"
	;include "../_sdk/lib.i"
TRUE=0xff
FALSE=0x00
_JPHL.
	jp (hl)
	include "../_sdk/iofast.i"

fn
	db "compile.bat"
	db 0
	ds 1 ;for full name 8+3
	ds 12 ;for ../direname/

PARADDR
	ds 200 ;parameters in commandline

	include "batch.var"
