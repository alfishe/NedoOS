;startup
FCB1=0x4800 ;aligned ;len=0x0200*files
DOSBUF=0xff00 ;aligned
	org 0x6000
        ld hl,0
        ld (23672),hl
        ld hl,start.
        ld (23834),hl ;адрес запуска
        ld hl,467 ;выход (иначе возврат в бейсик после RUN "..." CODE невозможен)
        push hl
        jp 0x3d2f ;call in DOS
start.
	ld hl,fntok.
	ld (asmexport.fn),hl
        call asmexport
        ld hl,10072
        exx
        ld hl,(23672)
        add hl,hl
        ld b,h
        ld c,l
        ret

	include "export.asm"
	include "exporttg.asm"
	include "../_sdk/lib.i"
	include "../_sdk/str.i" ;for io
	include "../_sdk/io.i"
	include "../_sdk/io.asm"
	;include "../_sdk/print.i"

fntok.
	db "tok.f"
	db 0

	include "../_sdk/io.var"
	include "../_sdk/fmttg.var"
	include "export.var"
	include "exporttg.var"
