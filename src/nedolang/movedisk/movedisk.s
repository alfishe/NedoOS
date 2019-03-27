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
        call movedisk
        ;ld hl,10072
        ;exx
        ret

	include "movedisk.asm"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	include "../_sdk/io.i"
	include "../_sdk/io.asm"

	include "../_sdk/io.var"
	include "movedisk.var"
