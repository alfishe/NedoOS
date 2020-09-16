        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
        include "8080.asm"

;
;
; Main CC.ASM Source Driver
; (for use with LASM.COM)
;
	;page 76
	;title 'cc.asm v1.6  CP/M 3/10/86'

true:	equ 0ffffh
false:	equ not true

SLRMAC:	equ true;false
LASM:	equ not SLRMAC
CPM:	equ true	;if true, for cp/m
TERM equ 1

ZSYSTEM	equ true

	if not ZSYSTEM
version: equ '6'	;the 'x' in 'v1.x'
updatn:	equ 0		;the `y' in `v1.xy'	 (number)
UPDATY:	equ 0		;the `z' in `v1.xyz', or zero if none (character)
	endif

	if ZSYSTEM
version: equ '2'	;the 'x' in 'vZx.yz'
updatn:	equ 0		;the `y' in `vZx.yz'	 (number)
UPDATY:	equ 0		;the `z' in `vZx.yz', or zero if none (character)
	endif


DEMO:	equ 0		;true for special demo message (must be customized)
IMPURE:	equ 1		;true to generate impure code for parity stripping
			;						option
ALPHA:	equ 0		;true if "alpha-C" version
motu:	equ 0		;true if for Mark of the Unicorn
trs80:	equ 0		;true if  special TRASH-80 version
PREREL:	equ 0		;true if `pre-release' is to be printed on startup
debug:	equ PREREL
marc:	equ  false	;true if MARC-resident version

bigstring: equ false	;true to allow LOTS of preprocessor string space

	if bigstring
strsiz:	equ 3500	;3500 for BIG programs
	endif

	if not bigstring
strsiz: equ 2800	;2800 for normal programs
	endif

	IF NOT CPM
;	Assembling NON-CPM  version		!=
	ENDIF

	IF LASM
	;sym
	ENDIF

ram:	equ 0000h	;start of ram in system

	  if motu
dfstsz:	equ 11*1024	;default symbol table size
	  endif

	  if not motu
dfstsz:	equ 10*1024
	  endif

tbuff:	equ ram+80h	;used under both CP/M and MARC
tpa:	equ PROGSTART;ram+100h	;TPA under both CP/M and MARC

ztack=0
stkchk=ztack-322

	IF CPM
bdos:	equ ram+5
NEDOOSMEMTOP=stkchk;bdosp:	equ ram+6
fcb:	equ ram+5ch
fcbnr:	equ fcb+32
fcbex:	equ fcb+12
secsiz:	equ 128
	ENDIF


negone	equ 0ffh	;negative one, 8 bit 2's complement

	IF CPM
;coninp:		equ 1
;conout:		equ 2
readbuf:	equ 10
;intcon:		equ 11
;select:		equ 14
openfil:	equ 15
closefil:	equ 16
delete:		equ 19
rsequen:	equ 20
wsequen:	equ 21
makfil:		equ 22
;gdisk:		equ 25
sdma:		equ 26
;sguser:		equ 32
	ENDIF

;
; Include file nesting control:
;

fnlen:	equ 12	;length of filename in fcb format ( filename plus disk)
nestmax: equ 5	;max of 5 levels of include file nesting allowed

;
; Equates:
;

nlcd:	equ 0f7h
concd:	equ 0f8h
varcd:	equ 0f9h
lblcd:	equ 0fah
labrc:	equ 0fch
strcd:	equ 0fdh
sttcd:	equ 8bh
period:	equ 0c5h
arrow:	equ 0b4h
swtbc:	equ 0feh
divcd:	equ 0b7h
mulcd:	equ 0b6h
modcd:	equ 0b8h
plus:	equ 0c4h
ancd:	equ 0bbh
letcd:	equ 0beh
newlin:	equ 10
ht:	equ 9
bs:	equ 8
ff:	equ 0ch
chrcd:	equ 80h
regcd:	equ 9eh
shrtcd:	equ 9fh
gotcd:	equ 8dh
rencd:	equ 8eh
brkcd:	equ 90h
cntcd:	equ 91h
ifcd:	equ 92h
elscd:	equ 93h
forcd:	equ 94h
docd:	equ 95h
whlcd:	equ 96h
swtcd:	equ 97h
cascd:	equ 98h
defcd:	equ 99h
uncd:	equ 8ch
lbrcd:	equ 9bh
rbrcd:	equ 9ch
sizcd:	equ 8fh
mincd:	equ 0b5h
dcoln:	equ 0c1h
open:	equ 0c2h
close:	equ 0c3h
semi:	equ 0c6h
comma:	equ 0c7h
openb:	equ 0c8h
closb:	equ 0c9h
colon:	equ 0cah
circum:	equ 0cbh

modbeg:	equ 0f5h
modend:	equ 0f6h


cr:	equ 0dh
lf:	equ 0ah


	;IF LASM
	;link	CCA
	;ENDIF

	org PROGSTART;tpa		;start of CP/M TPA
begin
	;IF SLRMAC
	include "cca.asm"
	include "ccb.asm"
        include "../_sdk/stdio.asm"
	include "cccomp.asm" ;внутри есть org, начинается запарываемая часть
	include "ccd.asm"
	;ENDIF

;
; Data storage used by "readf":
;

datarea: equ $

secbuf:	ds 256		;sector buffer for reading in file
fsp:	ds 2
sptr:	ds 2
incf:	ds 1		; true if in an include file
pndsav:	ds 2
fnbuf:	ds 50		;file name buffer for reading in files
textp:	ds 2
lastc:	ds 1
lastc2:	ds 1
quotf:	ds 1		;true if in a quoted string
newusr:	ds 1		;new disk for #includes (CP/M)
newdsk:	ds 1		;new user area for #includes (CP/M)
atcnt:	ds 2		;last active line count for comment diagnostics
inclstk: equ $		;"include" stack

;
; Data used by "lblpr":
;

	org datarea	;overlap readf's data area with lblpr's data area

lblp:	ds 2
lblt:	equ $

	;IF LASM
	;end
	;ENDIF

end
	savebin "cc.com",begin,end-begin
	
	LABELSLIST "../../us/user.l"
