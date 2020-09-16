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
NEDOOSMEMTOP=0xff00;bdosp:	equ ram+6
fcb:	equ ram+5ch
nr:	equ fcb+32
	ENDIF

tbuff:	equ ram+80h
extbas:	equ 0015h	;external base pointer in C.CCC

fnlen:	equ 12
nestmax: equ 5


	IF CPM
;coninp:		equ 1
;conout:		equ 2
;readbuf:	equ 10
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

	org PROGSTART;ram+100h	;start of TPA
begin	
	;IF SLRMAC
	include cc2a.asm
	include cc2b.asm
	include cc2c.asm
	include cc2d.asm
	include cc2e.asm
        include "../_sdk/stdio.asm"
	;ENDIF

;
; Initialization code, placed over table storge not used until
; after completion of initialization
;

c2init:

	IF CPM
	ld de,tbuff
	ld c,sdma
	call bdos	;set default DMA buffer
	ENDIF

	lda erasub	;bit 1 of erasub is werrs flag
	ld b,a
	and 2
	sta werrs	;set werrs
	ld a,b
	and 1
	sta erasub	
	

	ld a,1
	sta prerrs	;print out errors
	sta entn
	sta codflg	;enable code generation
	dec a
	sta errf	;no errors yet
	sta prnflg	;not inside parentheses
	sta modstc	;clear module nesting count
	sta errsin

	call clrdir	;clear 512 byte directory area
	call opsin	;initailize operator stacks
	call minit	;adjust macro table for -z optimizations

	call readf	;read in CCI file, or copy down from hi ram
	shld eofad	;set EOF address

	ld hl,direc	;init directory pointer
	shld dirp

	lhld st-4
	push hl
	ld b,3
cc21:	xor a		;compute # of entries in symbol table
	ld a,h		;by dividing size of table by 8
	rra
	push af
	and 7fh
	ld h,a
	pop af
	ld a,l
	rra
	ld l,a
	dec b
	jp nz,cc21
	shld stno	;and store # of entries
	pop hl		;HL is size of symbol table

	ld de,st	;get base of sym tab in DE
	add hl,de		;now HL is base of func name tab
	shld fntb
	ex de,hl		;put in DE
	lhld st-2	;get length of sym tab
	add hl,de		;now HL is start of CCI code
	push hl		;as well as base of generated code area. Save it
	shld start	;on stack and at "start"

	dec h		;compute code area offset, which
	dec h		; when added to a pointer to an absolute
	call cmh	; location in generated code during code
	shld cdao	; generation, yields final addr of that code
			; in the generated CRL file.
	pop hl		;get start of CCI code area
	push hl
	call mvup	;lde CCI code up to high memory
	shld cdp	;Save pointer to CCI code at "cdp".
	pop hl		;get back code area pointer

	lda eflag	;has -e option been used?
	or a
	jp z,cc22		;if not, go put zeroes in the first 3 bytes of code

	ld (hl),0bdh	;else stick in a famous "BD" byte to indicate
	inc hl		;an explicit external address for CLINK
	ex de,hl
	lhld exaddr	;get the explicit external address
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	jp cc23	;and rejoin the mainstream.
	
cc22:	xor a		;fill first 3 bytes of 5th sector with zeros
	ld (hl),a		;if explicit external starting address not given.
	inc hl
	ld (hl),a
	inc hl
	ld (hl),a

cc23:	inc hl
	ex de,hl
	lhld st-6	;get external data area size
	ex de,hl		;and put it here at 4th byte of 5th sector
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	shld codp	;save code area pointer

	ld hl,lblt	;Initialize label table
	shld lblp

	ld hl,modstk	;initialize module stack
	shld modstp

	call fstgs	;find the collected text strings

	ld hl,ltab	;initialize logical conditional branch label table
	shld ltabp	;(first 5 bytes aren't used, but why play with fire?)

	ld hl,pshptb	;initialize "push optimization" table
	shld pshpp

	ld hl,8000h	;and "symbolic label" name (number) generator
	shld lbln

	ld hl,modstk	;initialize module stack
	shld modstp

	ld hl,0
	shld nlcnt	;initialize line count
	ret


	IF NOT ALPHA
s0:	db 'BD Software C Compiler'
	ENDIF

	IF ALPHA
s0:	db 'BDS Alpha-C Compiler'
	ENDIF

	IF NOT ZSYSTEM
	db ' v1.'
	db version
	db updatn + '0'
	ENDIF

	IF ZSYSTEM
	db ' (for ZCPR3) vZ'
	db version
	db '.'
	db updatn + '0'
	ENDIF

	db ' (part II)+'

;
; Clear new directory for the CRL file about to be created:
;

clrdir:	ld bc,512
	ld hl,direc
clrdr2:	ld (hl),0
	inc hl
	dec bc
	ld a,b
	or c
	jp nz,clrdr2
	ret


        if 1==0 ;killed by a bug!!!
;
; Initialize operator stack and operand
; information stack:
;

opsin:	push hl
	ld hl,opstk
	shld opstp
	ld (hl),0ffh
	ld hl,infstk
	shld infsp
	pop hl
	ret
        endif

;
; Read in the CCI file from disk, or lde it down from high
; memory if left there by CC1:
;

readf:	lda chainf		;chained to from CC1?
	or a

	IF CPM
	  jp z,readf0		;if not, load cci file under CP/M
	ENDIF

	lhld curtop		;yes. copy down to low ram
	ld de,-35
	add hl,de
	push hl			;save last addr + 1
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a			;HL = first address
	inc hl			;or rather, it does now
	ld b,h
	ld c,l			;BC = 1st address of text
	ld a,st/256		;make sure we have enough room...
	cp b			;hi byte of symbol table area must be less 
	jp nc,rdf4		;than high byte of cci code area

	call cmh
	pop de
	add hl,de
	ex de,hl			;DE = length
	ld hl,st-6		;HL = destination
rloop:	ld a,(bc)
	ld (hl),a
	inc hl
	inc bc
	dec de
	ld a,d
	or e
	jp nz,rloop
	shld eofad	;save end address
	ld (hl),1ah
	ret


readf0:
	IF CPM
	ld hl,fcb+9
	ld (hl),'C'
	inc hl
	ld (hl),'C'
	inc hl
	ld (hl),'I'

	call fopen

	ld hl,st-6
rdf2:	call reads
	jp nc,rdf2a
	call fclose
	ret

rdf2a:	ld de,tbuff
	ld b,80h
rdf3:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,rdf3

	lda curtop+1
	ld c,a
	dec c
	ld a,h
	cp c
	jp c,rdf2
	ENDIF

rdf4:	ld de,stgom
	call perrab



;
; lde the CCI code up out of the way to make room for
; code generation:
;

mvup:	call cmh	;put -(base of cci code)...
	ex de,hl		;  ...into DE
	lhld eofad	;end of cci code
	push hl		;save end of source area
	add hl,de		;end of cci code - base of cci code
	inc hl		;end of code - base of code + 1
	ld b,h		;this is the length of the code;
	ld c,l		;block length in  BC

	pop de		;DE is end of source area

	lhld curtop	;HL is end of memory (destination area)
	dec hl		;just below BDOS
	dec hl		; but one more for good measure

mvup2:	ld a,2		;check to see if we're on a Z80
	inc a
	jp pe,mvup80

	ex de,hl		;Z80. put source in HL and destination in DE
	db 0edh,0b8h	;Z80 block lde
	ex de,hl		;flip registers again
	jp mvup3

mvup80:	ld a,(de)		;get byte of source
	ld (hl),a		;lde up
	dec hl		;debump dest
	dec de		;and source
	dec bc		;and count
	ld a,b
	or c	
	jp nz,mvup80	;loop till done

mvup3:	inc hl		;restore HL to first character of CCI code
	ret		;and return with HL pointing to start of CCI code




;
; Find the location of the string constant table in
; the just-read-in .CCI file:
;

fstgs:	lhld cdp
fstg1:	call pascd2
	push af
	cp swtcd
	jp nz,fstg2
	inc hl
	call igsht
	call mtchp
fstg1a:	ld a,(hl)
	cp nlcd
	inc hl
	jp z,fstg1a
	ld e,(hl)
	ld d,0
	inc hl
	add hl,de
	add hl,de
	add hl,de
	add hl,de
	inc hl
fstg2:	pop af
	inc hl
	jp nz,fstg1
	shld stgad
	ret


;
; The following data storge is overlayed on pass 2 initialization code:
;

	;org c2init

opstk=c2init ;:	ds 40		;operator stack for expression evaluation
infstk=opstk+40;:	ds 250		;info stack for expression evaluation (where
			;info on each value is pushed and popped as
			;needed.)

relt=infstk+250;:	ds 1600		;relocation table

        ds relt+1600-$

lblt:	ds 1700		;label table

lbrt: 	ds 1600		;label reference table

;	ds 300
;stack:	equ $

strsz:	equ 200

strtb:	ds strsz+3	;up to (strsz/4) intelligently handled  strings

ltab:	ds 200		;logical label table
ltabp:	ds 2		;logical label table pointer

pshptb:	ds 30		;push-optimization history table
pshpp:	ds 2		;push-optimization table pointer

direc:	ds 512		;area where CRL directory is built up
endir:	equ $

;
; This is where the .CCI file gets loaded:
;

	ds 6
st:	equ $


	;IF LASM
	;end
	;ENDIF

end
	savebin "cc2.com",begin,end-begin
	
	LABELSLIST "../../us/user.l"
