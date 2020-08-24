        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
        include "8080.asm"

;
; Main source driver for CC2.ASM:
;

	;page 76
	;title 'CC2.ASM v1.6  3/86'

true:	equ 0ffffh
false:	equ not true

ZSYSTEM	equ true
SLRMAC:	equ true;false
LASM:	equ not SLRMAC

trs80:	equ false 	;true if TRS-80 (org 4200h) version

ALPHA:	equ false	;true for Alpha-C version
MARC:	equ false	;true if MARC version
CPM:	equ not MARC	;true if CPM version

	if not ZSYSTEM
version: equ '6'	;the 'x' in 'v1.x'
updatn:	equ 0		;the `y' in `v1.xy'	 (number)
updaty:	equ 0		;the `z' in `v1.xyz', or zero if none (character)
	endif

	if ZSYSTEM
version: equ '2'	;the 'x' in 'vZx.yz'
updatn:	equ 0		;the `y' in `vZx.yz'	 (number)
updaty:	equ 0		;the `z' in `vZx.yz', or zero if none (character)
	endif

debug:	equ false
I80:	equ true
I86:	equ false


	IF LASM
	;sym
	ENDIF


ram:	equ 0		;start of ram area (either 0 or 4200h) for compiler

cr:	equ 0dh
lf:	equ 0ah

	IF CPM
bdos:	equ ram+5
bdosp:	equ ram+6
fcb:	equ ram+5ch
nr:	equ fcb+32
	ENDIF

tbuff:	equ ram+80h
extbas:	equ 0015h	;external base pointer in C.CCC

fnlen:	equ 12
nestmax: equ 5


	IF CPM
coninp:		equ 1
conout:		equ 2
readbuf:	equ 10
intcon:		equ 11
select:		equ 14
openfil:	equ 15
closefil:	equ 16
delete:		equ 19
rsequen:	equ 20
wsequen:	equ 21
makfil:		equ 22
gdisk:		equ 25
sdma:		equ 26
sguser:		equ 32
	ENDIF

	org PROGSTART;ram+100h	;start of TPA
begin	
	;IF SLRMAC
	include cc2a.asm
	include cc2b.asm
	include cc2c.asm
	include cc2d.asm
	include cc2e.asm
	;ENDIF

	;IF LASM
	;link cc2a.asm
	;ENDIF

end
	savebin "cc2.com",begin,end-begin
	
	;LABELSLIST "../../us/user.l"
