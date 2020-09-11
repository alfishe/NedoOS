PRESRV	EQU	TRUE	;True to preserve CRL-file address compatibility
			;	under various ZOPT1-ZOPT7 configurations
			;(changing to FALSE will shorten run-time pkg., but
			;will require re-CASM-ing .CSM files for new DEFF2.CRL)

USAREA	EQU	FALSE;TRUE	;True if "user areas" are implemented on target system

USERST	EQU	FALSE	;True to use a restart vector for CDB interfacing
RSTNUM	EQU	6	;Use "RST n" as default CDB vector (if USERST true)
			;(If used, be sure corresponding ZOPTn below is FALSE)
rstloc	equ    RSTNUM*8	;physical address of debugger restart vector

ZOPT1	EQU	FALSE	;The following five equates control the
ZOPT2	EQU	FALSE	;initialization of restart vectors 1 through 7
ZOPT3	EQU	FALSE	;(rst 1 - rst 7) for use by C programs to achieve
ZOPT4	EQU	FALSE	;optimum space efficiency. If any of these vectors are
ZOPT5	EQU	FALSE	;used by your system for I/O, set them FALSE here!
ZOPT6	EQU	FALSE	; (set FALSE if CDB w/RST 6 is to be used with object.)
ZOPT7	EQU	FALSE	; (set FALSE if DDT or SID are to be used with object.)

;
; The "ld sp,0" instruction at the start of the code is changed by
; CLINK, if the "-t" option is NOT used, into:
;		lhld	base+6
;		ld sp,hl
;
; If "-t <addr>" is used, then the sequence becomes:
;		lxi	sp,<addr>
;		nop
;
; If "-n" is used, to indicate no-warm-boot, then the sequence becomes:
;		jp	snobsp
;		nop
;

	ld sp,0	;These two instructions change depending on whether
	nop		;or not the CLINK "-t" or "-n" options are given.

	nop
	nop

	jp	skpfex	;skip over the following vector (don't ask...)

fexitv:	jp	EXITAD	;final exit vector. If "-n" used, this
			;becomes address of the "nobret" routine.

skpfex:	call	init	;do ARGC & ARGV processing, plus misc. initializations
	call	main	;go crunch!!!!
	jp	vexit	;close open files and reboot

extrns:	ds	2		;set by CLINK to external data base address
cccsiz:	dw	main-ORIGIN	;size of this code (for use by CLINK)
codend:	ds	2		;set by CLINK to (last addr of code + 1)
freram:	ds	2		;set by CLINK to (last addr of externals + 1)

;
; Jump vectors to some file i/o utility routines:
;

error:	jp	verror	;loads -1 into HL and returns
exit:	jp	vexit	;close all open files and reboot

	IF	CPM
close:	jp	vclose	;close a file
setfcb:	jp	vsetfcb	;set up fcb at HL given filename at DE
fgfd:	jp	vfgfd	;return C set if file fd in A not open
fgfcb:	jp	vfgfcb	;compute address of internal fcb for fd in A
setfcu:	jp	vstfcu	;set up FCB and process user number prefix
setusr:	jp	vsetusr ;set user area to upper 5 bits of A, save previous
rstusr:	jp	vrstusr	;restore user area to what it was before setusr call
snobsp: jp	vsnobsp	;set up SP for non-boot ("-tn") CLINK option
nobret:	jp	vnobret	;return to CCP when non-boot ("-tn") in effect.
khack:	jp	vkhack	;Kirkland interrupt vector initialization
	ENDIF

	IF	NOT CPM	;if not under CP/M, file I/O routines
	jp	verror	;are not used.
	jp	verror
	jp	verror
	jp	verror
	jp	verror
	jp	verror
	jp	verror
	jp	verror
	jp	verror
	jp	verror
	ENDIF

clrex:	jp	vclrex	;routine to clear external data area

	ds	9	;reserved

;
; The following routines fetch a variable value from either
; the local stack frame or the external area, given the relative
; offset of the datum required immediately following the call;
; for the "long displacement" routines, the offset must be 16 bits,
; for the "short displacement" routines, the offset must be 8 bits.
;

;
; long-displacement, double-byte external indirection:
;
;	format:	call ldei		; get 16-bit value in HL
;		dw offset_from_extrns	; >= 256
;

ldei:	pop hl	;get address of offset
	ld	e,(hl)	;put offset in DE
	inc hl
	ld	d,(hl)
	inc hl 		
	push hl	;save return address
	lhld	extrns	;add offset to external area base
	add hl,de
mindir:	ld	a,(hl)	;and get the value into HL
	inc hl
	ld	h,(hl)
	ld	l,a
	ret

;
; short-displacement, double-byte external indirection:
;
;	format:		call sdei		; get 16-bit value in L
;			db offset_from_extrns	; < 256
;

sdei:	pop hl
	ld	e,(hl)
	inc hl
	push hl
	ld	d,0
	lhld	extrns
	add hl,de
	ld	a,(hl)
	inc hl
	ld	h,(hl)
	ld	l,a
	ret

;
; long-displacement, single-byte external indirection:
;
;	format:		call	lsei		; get 8-bit value in L
;			dw offset_from_extrns	; >= 256
;

lsei:	pop hl
	ld	e,(hl)
	inc hl
	ld	d,(hl)
	inc hl
	push hl
	lhld	extrns
	add hl,de
	ld	l,(hl)
	ret

;
; short-displacement, single-byte external indirection:
;
;	format:		call	ssei		; get 8-bit value in L
;			db offset_from_externs	; < 256
;

ssei:	pop hl
	ld	e,(hl)	
	inc hl
	push hl
	ld	d,0
	lhld	extrns
	add hl,de
	ld	l,(hl)
	ret

;
; long-displacement, double-byte local indirection:
;
;	format:		call	ldli		; get 16-bit value in HL
;			dw offset_from_BC	; >= 256
;

ldli:	pop hl
	ld	e,(hl)
	inc hl
	ld	d,(hl)
	inc hl
	push hl
	ex de,hl
	add hl,bc
	ld	a,(hl)
	inc hl
	ld	h,(hl)
	ld	l,a
	ret

;
; short-displacement, double-byte local indirection:
;
;	format:		call	sdli		; get 16-bit value in HL
;			db offset_from_BC	; < 256
;

sdli:	pop hl
	ld	e,(hl)
	inc hl
	push hl
	ex de,hl
	ld	h,0
	add hl,bc
	ld	a,(hl)
	inc hl
	ld	h,(hl)
	ld	l,a
	ret

;
; Flag conversion routines:
;

pzinh:	ld hl,1	;return HL = true if Z set
	ret z
	dec hl
	ret

pnzinh:	ld hl,0	;return HL = false if Z set
	ret z
	inc hl
	ret

pcinh:	ld hl,1	;return HL = true if C set
	ret c
	dec hl
	ret

pncinh:	ld hl,0	;return HL = false if C set
	ret c
	inc hl
	ret

ppinh:	ld hl,1	;return HL = true if P (plus) flag set
	ret p
	dec hl
	ret

pminh:	ld hl,1	;return HL = true if M (minus) flag set
	ret m
	dec hl
	ret

pzind:	ld de,1	;return DE = true if Z set
	ret z
	dec de
	ret

pnzind:	ld de,0	;return DE = false if Z set
	ret z
	inc de
	ret

pcind:	ld de,1	;return DE = true if C set
	ret c
	dec de
	ret

pncind:	ld de,0	;return DE = false if C set
	ret c
	inc de
	ret

ppind:	ld de,1	;return DE = true if P (plus) flag set
	ret p
	dec de
	ret

pmind:	ld de,1	;return DE = true if M (minus) flag set
	ret m
	dec de
	ret
	

;	
; Relational operator routines: take args in DE and HL,
; and return a flag bit either set or reset.
;
; ==, >, < :
;

eqwel:	ld	a,l	;return Z if HL == DE, else NZ
	cp	e
	ret nz		;if L <> E, then HL <> DE
	ld	a,h	;else HL == DE only if H == D
	cp	d
	ret

blau:	ex de,hl		;return C if HL < DE, unsigned
albu:	ld	a,d	;return C if DE < HL, unsigned
	cp	h
	ret nz		;if D <> H, C is set correctly
	ld	a,e	;else compare E with L
	cp	l
	ret

bgau:	ex de,hl		;return C if HL > DE, unsigned
agbu:	ld	a,h	;return C if DE > HL, unsigned
	cp	d
	ret nz		;if H <> D, C is set correctly
	ld	a,l	;else compare L with E
	cp	e
	ret

blas:	ex de,hl		;return C if HL < DE, signed
albs:	ld	a,h	;return C if DE < HL, signed
	xor	d
	jp	p,albu	;if same sign, do unsigned compare
	ld	a,d
	or	a
	ret p		;else return NC if DE is positive and HL is negative
	scf		;else set carry, since DE is negative and HL is pos.
	ret

bgas:	ex de,hl		;return C if HL > DE, signed
agbs:	ld	a,h	;return C if DE > HL, signed
	xor	d
	jp	p,agbu	;if same sign, go do unsigned compare
	ld	a,h
	or	a
	ret p		;else return NC is HL is positive and DE is negative
	scf
	ret		;else return C, since HL is neg and DE is pos


;
; Multiplicative operators: *, /, and %:
;

smod:	ld	a,d	;signed MOD routine: return (DE % HL) in HL
	push	af	;save high bit of DE as sign of result
	call	tstn	;get absolute value of args
	ex de,hl
 	call	tstn
	ex de,hl
	call	usmod	;do unsigned mod
	pop	af	;was DE negative?
	or	a	;if not,
	ret p		;	all done
	ld	a,h	;else make result negative
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld	l,a
	inc hl
	ret

	IF PRESRV
	nop		;maintain address compatibility with some
	nop		; pre-release v1.4's.
	ENDIF

usmod:	ld	a,h	;unsigned MOD: return (DE % HL) in HL
	or	l
	ret z
	push de
	push hl
	call	usdiv
	pop de
	call	usmul
	ld	a,h
	cpl
	ld	h,a
	ld	a,l
	cpl 
	ld	l,a
	inc hl
	pop de
	add hl,de
	ret

smul:	jp	usmul	;turns out signed and unsigned multipilication
			; are equivalent for 16 bits, so just do unsigned

			;rst optimization of function entry sequence (ZOPT1):
fentrc:	pop de	;pop  arg byte address into DE
	push 	bc	;save BC
	ld a,(de)	;put stack offset byte value into L, setting up
	ld	l,a	;	HL with negative stack offset
	ld	h,0ffh
	inc de	;DE now points to return address
	add hl,sp	;calculate new SP value
	ld sp,hl		;set new SP value
	ld	b,h	;place into BC as new frame base ptr
	ld	c,l	
	ex de,hl		;put return address in HL
	jp (hl)		;and return
	

smul2:	lda	tmp
	rra
	ret nc
	jp	cmh

	ds	3	;preserve address compatibility with previous versions

tstn:	ld	a,h
	or	a
	ret p
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld	l,a
	inc hl
	lda	tmp
	inc	a
	sta	tmp
	ret

usmul:	push bc	;unsigned multiply: return (DE * HL) in HL
	call	usm2
	pop bc
	ret

usm2:	ld	b,h
	ld	c,l
	ld hl,0
usm3:	ld	a,b
	or	c
	ret z
	ld	a,b
	rra
	ld	b,a
	ld	a,c
	rra
	ld	c,a
	jp nc,usm4
	add hl,de
usm4:	ex de,hl
	add hl,hl
	ex de,hl
	jp	usm3

usdiv:	ld	a,h	;unsigned divide: return (DE / HL) in HL
	or	l	;return 0 if HL is 0
	ret z
	push bc
	call	usd1
	ld	h,b
	ld	l,c
	pop bc
	ret


usd1:	ld	b,1
usd2:	ld	a,h
	or	a
	jp m,usd3
	add hl,hl
	inc	b
	jp	usd2

usd3:	ex de,hl

usd4:	ld	a,b
	ld bc,0
usd5:	push	af
usd6:	call	cmphd
	jp c,usd7
	inc bc
	push de
	ld	a,d
	cpl
	ld	d,a
	ld	a,e
	cpl
	ld	e,a
	inc de
	add hl,de
	pop de
usd7:	xor	a
	ld	a,d
	rra
	ld	d,a
	ld	a,e
	rra
	ld	e,a
	pop	af
	dec	a
	ret z
	push	af
	ld	a,c
	rla
	ld	c,a
	ld	a,b
	rla
	ld	b,a
	jp	usd6

sdiv:	xor	a	;signed divide: return (DE / HL) in HL
	sta	tmp
	call	tstn
	ex de,hl
	call	tstn
	ex de,hl
	call	usdiv
	jp	smul2

cmphd:	ld	a,h	;this returns C if HL < DE
	cp	d	; (unsigned compare only used
	ret c		;  within C.CCC, not from C)
	ret nz
	ld	a,l
	cp	e
	ret

;
; Shift operators  << and >>:
;

sderbl:	ex de,hl		;shift DE right by L bits
shlrbe:	inc	e	;shift HL right by E bits
shrbe2:	dec	e
	ret z
	xor	a
	ld	a,h
	rra
	ld	h,a
	ld	a,l	
	rra
	ld	l,a
	jp	shrbe2

sdelbl:	ex de,hl		;shift DE left by L bits
shllbe:	inc	e	;shift HL left by E bits
shlbe2:	dec	e
	ret z
	add hl,hl
	jp	shlbe2


;
; Routines to 2's complement HL and DE:
;

cmh:	ld	a,h
	cpl
	ld	h,a
	ld	a,l
	cpl
	ld	l,a
	inc hl
	ret

cmd:	ld	a,d
	cpl
	ld	d,a
	ld	a,e
	cpl
	ld	e,a
	inc de
	ret


;
; The following routines yank a formal parameter value off the stack
; and place it in both HL and A (low byte), assuming the caller
; hasn't done anything to its stack pointer since IT was called.
;
; The mnemonics are "lde Arg #n To HL",
; where arg #1 is the third thing on the stack (where the first
; and second things are, respectively, the return address of the
; routine making the call	to here, and the previous return
; address to the routine which actually pushed the args on the
; stack.) Thus, a call	to "ma1toh" would return with the first
; passed parameter in HL and A; "ma2toh" would return the second,
; etc. Note that if the caller has pushed [n] items on the stack
; before calling "ma [x] toh", then the [x-n]th formal parameter
; value will be returned, not the [x]th.
;

ma1toh:	ld hl,4	;get first arg
ma0toh:	add hl,sp
	ld	a,(hl)
	inc hl
	ld	h,(hl)
	ld	l,a
	ret

ma2toh:	ld hl,6	;get 2nd arg
	jp	ma0toh

ma3toh:	ld hl,8	;get 3rd arg
	jp	ma0toh

ma4toh:	ld hl,10	;get 4th arg
	jp	ma0toh

ma5toh:	ld hl,12	;get 5th arg
	jp	ma0toh

ma6toh:	ld hl,14	;get 6th arg
	jp	ma0toh

ma7toh:	ld hl,16	;get 7th arg
	jp	ma0toh

;
; This routine takes the first 7 args on the stack
; and places them contiguously at the "args" ram area.
; This allows a library routine to make one call	to arghak
; and henceforth have all it's args available directly
; through lhld's instead of having to hack the stack as it
; grows and shrinks. Note that arghak should be called as the
; VERY FIRST THING a function does, before even pushing BC.
;

arghak:	ld de,args	;destination for block lde in DE
	ld hl,4	;pass over two return address
	add hl,sp	;source for block lde in HL
	push bc	;save BC
	ld	b,14	;countdown in B
arghk2:	ld	a,(hl)	;copy loop
	ld (de),a
	inc hl
	inc de
	dec	b
	jp nz,arghk2	
	pop bc	;restore BC
	ret

;
; ABSOLUTELY NO CHANGES SHOULD EVER BE MADE TO THE CODE BEFORE
; THIS POINT IN THIS SOURCE FILE (except for customizing the EQU
; statements at the beginning of the file).
;


;
; This routine is called first to do argc & argv processing (if
; running under CP/M) and other initializations:
;

init:	pop hl	;store return address
	shld	tmp2	; somewhere safe for the time being

        OS_HIDEFROMPARENT
        ld e,6 ;textmode
        OS_SETGFX 
        
	IF	CPM
	ld hl,arglst-2	;set up "argv" for the C main program
	ENDIF
	
	IF	NOT CPM
	ld hl,0
	ENDIF

	push hl

			;Initialize storge allocation pointers:
	lhld	freram	;get address after end of externals
	shld	allocp	;store at allocation pointer (for "sbrk.")
	ld hl,1000	;default safety space between stack and
	shld	alocmx	; highest allocatable address in memory 
			; (for use by "sbrk".).

			;Initialize random seed:
	ld hl,59dch	;let's stick something wierd into the
	shld	rseed	;first 16 bits of the random-number seed

			;Initialize I/O hack locations:
	ld	a,0dbh		;"in" op, for "in xx; ret" subroutine
	sta	iohack
	ld	a,0d3h		;"out" op for "out xx; ret" subroutine
	sta	iohack+3
	ld	a,0c9h		;"ret" for above sobroutines
	sta	iohack+2	;the port number is filled in by the
	sta	iohack+5	;"inp" and "outp" library routines.

	IF	CPM
	call	khack		;initialize Kirkland debugger vector
	ENDIF

	IF	CPM	;under CP/M: clear console, process ARGC & ARGV:
	ld	c,cstat ;interrogate console status to see if there
	call	bdos	;  happens to be a stray character there...

	or	a	;(used to be `and 1'...they tell me this works
	nop		; better for certain bizarre CP/M-"like" systems)

	jp z,initzz
	ld	c,conin   ;if input present, clear it
	call	bdos

initzz:	ld hl,tbuff		;if arguments given, process them.
	ld de,comlin	;get ready to copy command line
	;ld	b,(hl)		;first get length of it from loc. base+80h
	;inc hl
	;ld	a,b
	;or	a	;if no arguments, don't parse for argv
	;jp nz,initl
	;ld de,1	;set argc to 1 in such a case.
	;jp	i5

initl:	ld	a,(hl)	;ok, there are arguments. parse...
	ld (de),a	;first copy command line to comlin
         or a
	inc hl
	inc de
	;dec	b
	jp nz,initl
	;xor	a	;place zero following line
	;ld (de),a

	ld hl,comlin	;now compute pointers to each arg
	ld de,1		;arg count
	ld bc,arglst	;where pointers will all go
	xor	a		;clear "in a string" flag
	sta	tmp1
i2:	ld	a,(hl)	;between args...
	inc hl
	cp	' '
	jp z,i2
	or	a
	jp z,i5	;if null byte, done with list
	cp	'"'
	jp nz,i2a	;quote?
	sta	tmp1	;yes. set "in a string" flag
	jp	i2b	

i2a:	dec hl
i2b:	ld	a,l	;ok, HL is a pointer to the start
	ld (bc),a	;of an arg string. store it.
	inc bc
	ld	a,h
	ld (bc),a
	inc bc
	inc de	;bump arg count
i3:	ld	a,(hl)
	inc hl	;pass over text of this arg
	or	a	;if at end, all done
	jp z,i5
	push bc	;if tmp1 set, in a string 
	ld	b,a	; (so we have to ignore spaces)
	lda	tmp1
	or	a
	ld	a,b
	pop bc
	jp z,i3a
	cp	'"'	;we are in a string.
	jp nz,i3	;check for terminating quote
	xor	a	;if found, reset "in string" flag
	sta	tmp1
	dec hl
	ld	(hl),a	;and stick a zero byte after the string
	inc hl	;and go on to next arg
i3a:	cp	' '	;now find the space between args
	jp nz,i3
	dec hl	;found it. stick in a zero byte
	ld	(hl),0
	inc hl
	jp	i2	;and go on to next arg

i5:	push de	;all done finding args. Set argc.

	ld	b,3*nfcbs  ;now initialize all the file info
	ld hl,fdt	;by zeroing the fd table)
i6:	ld	(hl),0
	inc hl
	dec	b
	jp nz,i6
	ENDIF

	IF	NOT CPM	;if not under CP/M, force ARGC value	
	ld hl,1	; of one.
	push hl
	ENDIF

	call	clrex	;clear externals, if CLINK -z option NOT used
	xor	a
	sta	ungetl	;clear the push-back byte,
	sta	errnum	;and file error code

	ld	a,0c3h	;call c,'-Z' optimization initialization

;
; -Z optimization initializations:
;

	IF	ZOPT1
	sta	8	;rst 1: jp fentrc
	ld hl,fentrc
	shld	9
	ENDIF

	IF	NOT ZOPT1 AND PRESRV
	nop
	dw	0,0,0,0		;more NOPs
	ENDIF


	IF	ZOPT2
	sta	10h
	ld hl,fexitc ;rst 2:jp fexitc
	shld	11h
	ENDIF

	IF	NOT ZOPT2 AND PRESRV
	nop
	dw	0,0,0,0		;more NOPs
	ENDIF


	IF	ZOPT5
	sta	28h	;rst5:	jp sdli
	ld hl,sdli
	shld	29h
	ENDIF	

	IF	NOT ZOPT5 AND PRESRV
	nop
	dw	0,0,0,0		;more NOPs
	ENDIF


 	IF	ZOPT6
	sta	30h	;rst6:	jp ldli
	ld hl,ldli
	shld	31h
	ENDIF

	IF	NOT ZOPT6 AND PRESRV
	nop
	dw	0,0,0,0		;more NOPs
	ENDIF


	IF	ZOPT3
	ld hl,237eh	;rst3:	ld a,(hl)
	shld	18h	;	inc hl
	ld hl,6f66h	;	ld h,(hl)
	shld	1ah	;	ld l,a
	ld	a,0c9h	;	ret
	sta	1ch
	ENDIF

	IF	NOT ZOPT3 AND PRESRV
	nop
	dw	0,0,0,0		;more NOPs
	dw	0,0,0,0
	ENDIF


	IF	ZOPT4
	ld hl,2373h	;rst4:	ld (hl),e
	shld	20h	;	inc hl
	ld hl,0c972h ;	ld (hl),d
	shld	22h	;	ret
	ENDIF

	IF	NOT ZOPT4 AND PRESRV
	dw	0,0,0	;lotsa NOPs
	dw	0,0,0
	ENDIF


	IF	ZOPT7
	ld hl,235eh
	shld	38h
	ld hl,0c956h
	shld	3ah

	ld hl,2b72h
	shld	3ch
	ld hl,0c973h
	shld	3eh
	ENDIF

	IF	NOT ZOPT7 AND PRESRV
	dw	0,0,0,0,0,0	;you guessed it -- NOPs
	dw	0,0,0,0,0,0
	ENDIF

	lhld	tmp2
	jp (hl)		;all done initializing.
	
	IF	ZOPT2	;object of rst 2 vector, if enabled
fexitc:	pop de	;get offset address
	ex de,hl		;return value in DE, &offset in HL
	ld	l,(hl)	;put byte offset in HL
	ld	h,0
	add hl,sp	;add to SP
	ld sp,hl
	ex de,hl		;put return value back in HL
	pop bc	;restore BC
	ret		;and return to previous function
	ENDIF

	IF	NOT ZOPT2 AND PRESRV
	dw	0,0,0	;NOPs
	dw	0,0
	ENDIF


;
; The following two routines are used when the "-tn" CLINK option
; is given, in order to preserve the SP value passed to the transient
; command by the CCP and return to the CCP after execution without
; needing to perform a warm-boot.
;

	IF CPM
vsnobsp:
	ld hl,0		;get CCP's SP value in HL
	add hl,sp
	shld	spsav		;save it for later
	lhld	base+6		;get BIOS pointer
	ld de,-2100		;subtract size of CCP plus a fudge
	add hl,de
	ld sp,hl			;make that the new SP value
	jp	tpa+3		;and get things under way...

vnobret:
	lhld	spsav		;restore CCP's SP
	ld sp,hl
	ret			;return to CCP
	ENDIF

;
; The following routine gets called to clear the external
; data area, unless the CLINK "-z" option is used.
;

vclrex:	lhld	freram	;clear externals
	ex de,hl
	lhld	extrns
	call 	cmh
	add hl,de	;HL now holds size of external data area
clrex1:	ld 	a,h	;loop till done
	or	l
	ret z
	dec de
	dec hl
	xor	a
	ld (de),a
	jp	clrex1


;
; Initialize Kirkland interrupt vector... enables
; programs compiled with "-k" to run without the debugger:
;

	IF USERST
vkhack:	ld hl,0E1H+2300H	;pop hl - inc hl
	shld	rstloc		; put at "RST 6" location (or wherever)
	ld hl,023H+0E900H	;inc hl - jp (hl)
	shld	rstloc+2
	ret
	ENDIF

	IF NOT USERST
vkhack:	ret
	ENDIF

	IF NOT USERST AND PRESRV
	ds 12
	ENDIF

;
; General purpose error value return routine:
;

verror:	ld hl,-1	;general error handler...just
	ret		;returns -1 in HL

;
; Here are file I/O handling routines, only needed under CP/M:
;

;
; Close any open files and reboot:
;

vexit:
	IF	CPM		;if under CP/M, close all open files
	ld	a,7+nfcbs	;start with largest possible fd
exit1:	push	af		;and scan all fd's for open files
	call	vfgfd		;is file whose fd is in A open?
	jp c,exit2		;if not, go on to next fd
	ld	l,a		;else close the associated file
	ld	h,0
	push hl
	call	vclose
	pop hl
exit2:	pop	af
	dec	a		;and go on to next one
	cp	7
	jp nz,exit1
	ENDIF

	jp	fexitv		;done closing...now return
				; to CP/M or whatever.


;
; Close the file whose fd is 1st arg:
;

	IF	CPM	;here comes a lot of CP/M stuff...
vclose:
	call	ma1toh	;get fd in A
	call	vfgfd	;see if it is open
	;jp c,verror	;if not, complain ;TODO why fail?
	;ld	a,(hl)
	;call	setusr	;set user area to match current fd
	;and	4	;check if open for writing

	ENDIF

	IF CPM AND NOT MPM2	;if not MP/M, and
	;jp z,close2	;the file isn't open for write, don't bother to close
	ENDIF

	IF CPM AND MPM2	AND PRESRV  ;always close all files under MP/M
	nop
	nop
	nop
	ENDIF

	IF CPM
	push hl	;save fd table entry addr
	call	ma2toh	;get the fd in A again
	push bc
	call	vfgfcb	;get the appropriate fcb address
	ex de,hl		;put it in DE
	ld	c,closec  ;get BDOS function # for close
	call	bdos	;and do it!
	pop bc
	pop hl
close2:	;call	rstusr	;reset user number to original state
	ld	(hl),0	;close the file logically
	cp	255	;if 255 came back from bdos, we got problems
	ld hl,0	
	ret nz		;return 0 if OK
	dec hl	;return -1 on error
	ret

;
; Determine status of file whose fd is in A...if the file
; is open, return Cy clear and with the address of the fd table
; entry for the open file in HL. If the file is not open,
; return Cy set:
;

vfgfd:	ld	d,a
	sub	8
	ret c		;if fd < 8, error
	cp	nfcbs
	ccf		;don't allow too big an fd either
	ret c
	push de
	ld	e,a	;OK, we have a value in range. Now
	ld	d,0	;  see if the file is open or not
	ld hl,fdt
	add hl,de	;offset for 3-byte table entries
	add hl,de
	add hl,de
	ld	a,(hl)
	and	1	;bit 0 is high if file is open
	scf
	pop de
	ld	a,d
	ret z		;return C set if not open
	ccf
	ret		;else reset C and return

;
; Set up a CP/M file control block at HL with the file whose
; simple null-terminated name is pointed to by DE:
; Format for filename must be: "[white space][d:]filename.ext"
; The user number prefix hack is NOT recognized by this subroutine.
;

vsetfcb: push bc
	call	igwsp	;ignore blanks and tabs	
	push hl	;save fcb ptr
	inc de	;peek at 2nd char of filename
	ld a,(de)
	dec de
	cp	':'	;default disk byte value is 0
	ld	a,0	; (for currently logged disk)
	jp nz,setf1
	ld a,(de)	;oh oh...we have a disk designator
	call	mapuc	;make it upper case
	sub	'A'-1	;and fudge it a bit
	inc de	;advance DE past disk designator to filename
	inc de
setf1:	ld	(hl),a	;set disk byte
	inc hl
	ld	b,8
	call	setnm	;set filename, pad with blanks
	call	setnm3	;ignore extra characters in filename
	ld a,(de)
	cp	'.'	;if an extension is given,
	jp nz,setf2
	inc de	;skip the '.'
setf2:	ld	b,3
	call	setnm	;set the extension field and pad with blanks
	xor	a	;and zero the appropriate fields of the fcb
	ld	(hl),a
	ld de,20
	add hl,de
	ld	(hl),a
	inc hl
	ld	(hl),a	;zero random record bytes of fcb
	inc hl
	ld	(hl),a
	inc hl
	ld	(hl),a
	pop de
	pop bc
	ret

;
; This routine copies up to B characters from (DE) to (HL),
; padding with blanks on the right. An asterisk causes the rest
; of the field to be padded with '?' characters:
;

setnm:	push bc
setnm1:	ld a,(de)
	cp	'*'	;wild card?
	ld	a,'?'	;if so, pad with ? characters
	jp z,pad2

setnm2:	ld a,(de)
	call	legfc	;next char legal filename char?
	jp c,pad	;if not, go pad for total of B characters
	ld	(hl),a	;else store
	inc hl
	inc de
	dec	b
	jp nz,setnm1	;and go for more if B not yet zero
	pop bc
setnm3:	ld a,(de)	;skip rest of filename if B chars already found
	call	legfc
	ret c
	inc de
	jp	setnm3

pad:	ld	a,' '	;pad with B blanks
pad2:	ld	(hl),a	;pad with B instances of char in A
	inc hl
	dec	b
	jp nz,pad2
	pop bc
	ret

;
; Process filename having optional user area number prefix of form "<u#>/",
; return the effective user area number of the given filename in the upper
; 5 bits of A, and also store this value at "usrnum". Note that if no user
; number is specified, the current user area is presumed by default. After
; the user area prefix is processed, do a regular "setfcb":
;
; Note: a filename is considered to have a user number if the first char
; 	in the name is a decimal digit and the first non-decimal-digit
;	character in the name is a slash (/).

vstfcu: push bc	;save BC
	push hl	;save vcb pointer
	call	igwsp	;ignore blanks and tabs	
	call	isdec	;decimal digit?
	jp nc,setfc2	;if so, go process

setfc0:	push de	;save text pointer
	;ld	c,gsuser  ;else get current effective user number
	;ld	e,0ffh
	ENDIF

	IF	CPM AND USAREA
	;call	bdos	;get current user area if implemented
         xor a
	ENDIF

	IF	CPM AND NOT USAREA
	ld	a,0
	nop
	ENDIF

	IF	CPM
	pop de	;restore text pointer
setfc1:	rlca		;rotate into upper 5 bits of A
	rlca
	rlca
	sta	usrnum	;and save
	pop hl	;restore junk
	pop bc
	jp	setfcb	;and parse rest of filename

setfc2:	ld	b,0	;clear user number counter
	push de	;save text pointer in case we invalidate user prefix
setfc3:	sub	'0'	;save next digit value
	ld	c,a	; in C
	ld	a,b	;multiply previous sum by 10
	add	a	;*2
	add	a	;*4
	add	a	;*8
	add	b	;*9
	add	b	;*10
	add	c	;add new digit
	ld	b,a	;put sum in B
	inc de	;look at next char in text
	ld a,(de)	;is it a digit?
	call	isdec
	jp nc,setfc3	;if so, go on looping and summing digits
	cp	'/'	;make sure number is terminated by a slash
	jp z,setfc4
	pop de	;if not, entire number prefix is not really a 
	jp	setfc0	; user number, so just ignore it all.

setfc4:	inc de	;ok, allow the user number
	pop hl	;get old text pointer off the stack
	ld	a,b	;get user number value
	jp	setfc1	;and go store it and parse rest of filename


;
; Test if char in A is legal character to be in a filename:
;

legfc:	call	mapuc
	cp	'.'	; '.' is illegal in a filename or extension
	scf
	ret z
	cp	':'	;so is ':'
	scf 	
	ret z
	cp	7fh	;delete is no good
	scf
	ret z
	cp	'!'	;if less than exclamation pt, not legal char
	ret		;else good enough

;
; Map character in A to upper case if it is lower case:
;

mapuc:	cp	'a'
	ret c
	cp	'z'+1
	ret nc
	sub	32	;if lower case, map to upper
	ret

;
; Ignore blanks and tabs at text pointed to by DE:
;

igwsp:	dec de
igwsp1:	inc de
	ld a,(de)
	cp	' '
	jp z,igwsp1
	cp	9
	jp z,igwsp1
	ret

;
; Return Cy if char in A is not a decimal digit:
;

isdec:	cp	'0'
	ret c
	cp	'9'+1
	ccf
	ret


;
; This routine does one of two things, depending
; on the value passed in A.
;
; If A is zero, then it finds a free file slot
;  (if possible), else returns C set.
;
; If A is non-zero, then it returns the address
; of the fcb corresponding to an open file whose
; fd happens to be the value in A, or C set if there
; is no file associated with fd.
;

vfgfcb:	push bc
	or	a	;look for free slot?
	ld	c,a
	jp nz,fgfc2	;if not, go away
	ld	b,nfcbs	;yes. do it...
	ld de,fdt
	ld hl,fcbt
	ld	c,8
fgfc1:	ld a,(de)
	and	1
	ld	a,c
	jp nz,fgfc1a	;found free slot?
	pop bc	;yes. all done.
	ret

fgfc1a:	push de
	ld de,36	;fcb length to accommodate random I/O
	add hl,de
	pop de
	inc de	;bump to next 3-byte table entry
	inc de
	inc de
	inc	c
	dec	b
	jp nz,fgfc1
fgfc1b:	scf
	pop bc
	ret		;return C if no more free slots

fgfc2:	call	vfgfd	;compute fcb address for fd in A:
	;jp c,fgfc1b	;return C if file isn't open ;TODO why fail?

	sub	8
	ld	l,a	;put (fd-8) in HL
	ld	h,0
	add hl,hl	;double it
	add hl,hl	;4*a
	ld	d,h	;save 4*a in DE
	ld	e,l
	add hl,hl	;8*a
	add hl,hl	;16*a
	add hl,hl	;32*a
	add hl,de	;36*a
	ex de,hl		;put 36*a in DE
	ld hl,fcbt	;add to base of table
	add hl,de	;result in HL
	ld	a,c	;and return original fd in A
	pop bc
	ret

;
; The following two subroutines change the current CP/M user area for
; use with file I/O:
;

vsetusr:
	push bc	;SET user number to upper bits of A, save current:
	push hl
	push de
	push	af	;save A
	ld	c,gsuser ;get user code
	ld	e,0ffh
	ENDIF

	IF	CPM AND USAREA
	call	bdos
	ENDIF

	IF 	CPM AND NOT USAREA
	ld	a,0
	nop
	ENDIF

	IF CPM
	sta	curusr	;save current user number
	pop	af	;get new user number byte
	push	af
	rra		;shift user number down to low bits
	rra
	rra
	and	1fh	;and mask off high order garbage
setu0:	ld	e,a
	ld	c,gsuser  ;set user code
	ENDIF

	IF	CPM AND USAREA
	call	bdos
	ENDIF

	IF	CPM AND NOT USAREA AND PRESRV
	nop
	nop
	nop
	ENDIF

	IF	CPM
	pop	af
	pop de
	pop hl
	pop bc
	ret

vrstusr:
	push bc
	push hl
	push de
	push	af
	lda	curusr	;get last saved user number
	jp	setu0	;and go set current user area to that

	ENDIF		;end of CP/M-related file I/O routines


;	IF	NOT CPM
;main:	equ	$	;where main program resides when not under CP/M
			;(under CP/M, the data area comes first)
;	ENDIF


;
; Ram area:
;

	;IF	CPM	; Plug this value into BDS.LIB before CASM'ing
ram	equ	$	; the new library. The "org ram" at the end of this
	;ENDIF		; source file should cause the assembler to print
			; the value of "ram" at the end of the assembly.

	;IF	NOT CPM
	;org	ram	;if not under CP/M, use custom ram area address
	;ENDIF

errnum:	ds	1	;error code from file I/O operations
rseed:	ds	8	;the random generator seed
args:	ds	14	;"arghak" puts args passed on stack here.
iohack:	ds	6	;room for I/O subroutines for use by "inp"
			;and "outp" library routines

allocp:	ds	2	;pointer to free storge for use by "sbrk" func
alocmx:	ds	2	;highest location to be made available to the
			;storge allocator

			;20 bytes of misc. scratch & state variables:
tmp	ds	1
tmp1	ds	1
tmp2	ds 	2
tmp2a	ds	2
unused	ds	2

curusr	ds	1	;used to save current user number during file I/O
usrnum	ds	1	;set by "setfcu" to user number of given filename

			;Console I/O control data:
chmode	db	0	;0: single char mode, 1: line buffered mode
nleft	db	0	;# of chars left in buffer (if chmode == 1)
ungetl	db	0	;"ungetch" data byte (0 if no char pushback)
iobrf	db	1	;check for break on character input/output

spsav	ds	2	;BDOS's saved SP value upon entry from CCP

	ds	4	;total of 20 bytes of misc. data area

;
;--------------------------------------------------------------------------
; The following data areas are needed only if running under CP/M:
;

	IF	CPM
;
; The fcb table (fcbt): 36 bytes per file control block
;

fcbt:	ds	36*nfcbs	;reserve room for fcb's (extra byte for IMDOS)


;
; The fd table: three bytes per file specifying r/w/open as follows:
;   BYTE 1:
; 	bit 0 is high if open, low if closed
; 	bit 1 is high if open for read
; 	bit 2 is high if open for write	 (both b1 and b2 may be high)
;	bits 3-7 contain the user number in which the file is active (0-31)
;   BYTES 2&3:
;	Highest sector number seen so far during I/O (for cfsize calls)
;

fdt:	ds	3*nfcbs

;
; The command line is copied here by init:
;

comlin:	ds	131	;copy of the command line pointed to by entries
			;in arglst


;
; This is where "init" places the array of argument pointers:
;

arglst:	ds	40	;the "argv" paramater points here (well,
			;actually to 2 bytes before arglst). Thus,
			;up to 20 parameters may be passed to "main"
	ENDIF

;
; End of CP/M-only data area
;---------------------------------------------------------------------------

	;IF	CPM
main	equ	$	;where "main" program will be loaded under CP/M
	;ENDIF

	;IF NOT M80
	;org	ram	;set next pc value back to ram origin, so the value
	;ENDIF		;will be displayed by the assembler for convenience

