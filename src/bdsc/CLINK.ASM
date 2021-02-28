        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"
        include "8080.asm"

;
; Main driver file for CLINK.ASM
; (for use with LASM.COM)

	;page 77
	;title 'BDS Clink v1.6 3/86'

true:	equ 0ffffh
false:	equ not true

SLRMAC:	equ true;false
LASM:	equ not SLRMAC

PREREL:	equ 0		;'pre-release', uses current drive/user area
TESTING: equ 0		;enables printf hack debugging statements
TESTING2: equ 0		;enables the "test" stack-stuffing routine at end
TESTING3: equ 0		;enables fcbs printout diagnostic for obscure debugging

MARC:	equ false	;true if MARC version
CPM:	equ true	;true for CP/M version
ZSYS:	equ false;true	;true if assembling for Z-SYSTEMS version
ALPHA:	equ false	;true for Alpha-C

	IF NOT CPM
;	Assembling NON-CPM version !=
	ENDIF

FORCE:	equ 1		;have it work like L2, forcing loading of all funcs
version: equ '2'	;'x' in v1.xy

	IF NOT ZSYS
update: equ  '0'	;'y' in v1.xy
	ENDIF

	IF ZSYS
update: equ  '0'	;'y' in v1.xy
	ENDIF

trs80:	equ 0		;true if 4200h version of compiler

codend:	equ 19h		;The following 4 addresses are relative
freram:	equ 1bh		; to the start of C.CCC (** NOT "ram" **):
extrns:	equ 0015h	;Where address of externals is stored
cccsiz:	equ 0017h	;Where size of C.CCC is stored within C.CCC
clrex:	equ 0041h	;Jump vector to external clearing subroutine

;			offsets for key bytes in runtime package:
noboot:	equ 0011h
start:	equ 048dh	;startup code
lxiloc:	equ start+8

	
	IF MARC
mhackl:	equ 258h	;where "call marc" goes if -m given
thackl:	equ 35dh	;where "-t" sequence (ld hl,xxxx nop nop) goes
	ENDIF

	;IF LASM
	;sym
	;ENDIF

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


_rrn=0x21 ;shift to random record number in FCB (outsize FCB_sz!!!)

        
ram:	equ 0000h	;where CLINK resides while running
dt1siz:	equ 1500	;default ref table (tab1) size

	IF CPM
bdos:	equ ram+5	;entry point to bdos
NEDOOSMEMTOP=0xff00;bdosp:	equ ram+6
fcb:	equ ram+5ch
nr:	equ fcb+32
	ENDIF

tpa:	equ PROGSTART;ram+100h
tbuff:	equ ram+80h
cr:	equ 0dh
lf:	equ 0ah
bell:	equ 7
newlin:	equ lf
tab:	equ 9

	IF MARC
m$error:  equ 12
m$fsize:  equ 30
m$close:  equ 6
m$creat: equ 55
m$exit:	  equ 1
m$memory: equ 5
m$open:	  equ 2
m$read:	  equ 3
m$seek:	  equ 25
m$tell:	  equ 34
m$unlink: equ 11
m$write:  equ 4
m$getcf:  equ 19
m$putcf:  equ 36
m$ichec:  equ 27
m$maxmem: equ 49
msys:	  equ 50h
	ENDIF


	;IF LASM
	;link clinka
	;ENDIF

	org PROGSTART;ram+100h	;start of TPA
begin	
	;IF SLRMAC
	include "clinka.asm"
        include "../_sdk/stdio.asm"
	include "clinkb.asm" ;killable?
	;ENDIF

end
	savebin "clink.com",begin,end-begin
	
	LABELSLIST "../../us/user.l"
