;
;
; cc2a.asm
;
; 7/18/82: Added Kirkland debugging feature: if kflg (110h) is non-zero,
; 	   we assume it is the proper restart value to be inserted
;	   at the start of each expression that is the first on a line,
;	   to be followed by the line number.
;
; 12/30/85: Added new "modstk" module numbering/naming mechandsm as 
; 	previously implemented in CC.
;



	jp cc2		;jump around data passed from call c,during autoload:

	IF CPM
chainf:	db 0		;true if cc2 being auto-loaded by cc1 (103h)
	ENDIF

	IF NOT CPM
chainf:	db 1		;always being auto-loaded if under MARC
	ENDIF

optimf:	db 1		;true if value-fetch hack is OK to perform (104h)
cccadr:	dw ram+100h	;address of base of run-time package 	(105h)
exaddr:	ds 2		;explicit external address, (if eflag is true) (107h)
eflag:	db 0		;default to no explicit external address (109h)

	IF MARC
fnam:	ds 2		;pointer to filename for use in writing out crl file
	ENDIF

	IF CPM
;spsav:	ds 2		;saved CCP stack pointer under CP/M (10Ah)
        ds 2 ;NU (constant addresses!!!)
	ENDIF

curtop:	ds 2		;current top of memory (10Ch)

	IF MARC
maxmd:	db 0		;maxmem done flag, under MARC
	ENDIF

	IF CPM
ccpok:	db 1		;CCP still intact flag, under CP/M (10Eh)
	ENDIF

	IF CPM
erasub:	db 0		;bit 0: true if erasing submit files on error (10Fh)
			;bit 1: "werrs" true if writing RED file
	ENDIF

	IF NOT CPM
	ds 1		;dummy byte under MARC
	ENDIF

cdbflg: db 0		;CDB flag (-k<n> option to CC1) (110h)

	IF CPM
defsub:	db 0		;where to find submit files (CP/M only) (111h)
conpol:	db 1		;whether or not to poll console for interrupts (112h)
errbyt:	dw errdum	;ZCPR3 error condition flag address (dummy default)
	ENDIF


	IF NOT CPM
	ds 4
	ENDIF

oktort:	db 0		;extracted from ccpok b1 on startup
wboote:	db 1		;extracted from ccpok b2 on startup
zenvf:	db 0		;extracted from ccpok b3 on startup

errdum:	ds 1		;dummy zcpr3 error flag


cc2:	;ld hl,0		;save current SP in HL
	;add hl,sp
	ld sp,0;stack	;set up new stack

	IF CPM
	lda defsub
	inc a
	sta subfile
	ENDIF

	lda chainf	
	or a
	jp z,cc2a		;if not chaining, go initialize stuff

			; UNPACK ccpok:

	lda ccpok	;extract oktort from ccpok
	ld b,a
	and 1		;b0
	sta ccpok	;set ccpok flag

	ld a,b
	and 2		;b1
	rrca
	sta oktort	;set ok to return to ccp flag

	ld a,b
	and 4		;b2
	rrca
	rrca
	sta wboote	;set do warm boot on exit flag

	ld a,b
	and 8		;b3
	rrca
	rrca
	rrca
	sta zenvf	;set ZCPR3 flag

	or a		;Z environment?
	jp nz,cc20a	;if not, go do greeting

	ld hl,errdum	;else set errbyt address to dummy
	shld errbyt

cc20a:	ld de,s00	;print CR-LF if being chained to from cc1
	call pstgco	;if chaining, print CR-LF before sign-on message
	jp cc2b

cc2a:	;shld spsav	;save CCP stack pointer
	ld hl,NEDOOSMEMTOP;lhld ram+6
	shld curtop	;set up current top of memory below CCP
	ld a,1
	sta ccpok	;set CCP not bashed flag
	
cc2b:	lhld errbyt
	ld (hl),0		;no error by default

	ld de,s0	;regular sign-on msg
	call pstgco

	call c2init	;do rest of initialization

cc2c:	call dofun	;process a function
	lhld cdp
	call igshzz	;lde pointer to next function
	shld cdp	;and save text pointer
	ld a,(hl)		;get 1st char of next function
	ld hl,entn	;bump entry count (function count)
	inc (hl)
	or a
	jp nz,cc2c	;are we at EOF?

    	lhld codp	;yes.
	dec hl
	shld eofad	;set this for the "writf" routine

	call errwrp	;wrap up error handling, exit if there were errors

	ld hl,ascb+4	;else do write out a CRL file...
	ld (hl),'K'	;but first give a usage report

	IF CPM
	ld hl,NEDOOSMEMTOP;lhld bdosp	;this is as high as free memory can ever get
	ld l,0
	ENDIF

	ex de,hl
	lhld codp	;and this is as high as we got generating code
	call cmh
	add hl,de
	ld a,h		;divide difference by 1K
	rra
	rra
	and 3fh
	ld l,a		;and print out result
	ld h,0
	dec hl
	xor a
	call prhcs	;print out their difference
	ld de,stgtsp	;with some text
	call pstg	;and...

	call writf	;write out the CRL file

	IF CPM
exit:	QUIT ;lda wboote	;do warm boot on exit?
	;or a
	;jp nz,ram		;if so, go boot

	;lda chainf	;did we chain?
	;or a
	;jp z,ram		;if not, do warm boot in case we're SID-ing

	;lhld spsav	;get possibly saved CCP SP
	;ld sp,hl

	;lda ccpok	;CCP intact?
	;or a
	;ret nz		;return if so

	;lda oktort	;ok to return DESPITE ccpok's value?
	;or a
	;ret nz		;if so, return

	;jp ram		;else warm-boot
	
	ENDIF


;
; Some standard routine addresses within C.CCC, all relative
; to the origin of C.Ccall c,(stored at cccadr at run time)
; These values will change anytime C.Ccall c,is reconfigured.
;

ldei:	equ 04dh	;value-fetch routines
sdei:	equ 05ch
lsei:	equ 06bh
ssei:	equ 077h
ldli:	equ 083h
sdli:	equ 090h


pzinh:	equ 09dh		;flag conversion routines
pnzinh:	equ pzinh+6
pcinh:	equ pzinh+12
pncinh:	equ pzinh+18
ppinh:	equ pzinh+24
pminh:	equ pzinh+30
pzind:	equ pzinh+36
pnzind:	equ pzinh+42
pcind:	equ pzinh+48
pncind:	equ pzinh+54
ppind:	equ pzinh+60
pmind:	equ pzinh+66

eqwel:	equ 0e5h	;relational operator routines

blau:	equ 0ebh
albu:	equ blau+1

bgau:	equ 0f2h
agbu:	equ bgau+1

blas:	equ 0f9h
albs:	equ blas+1

bgas:	equ 104h
agbs:	equ bgas+1


smod:	equ 10fh
usmod:	equ 129h
smul:	equ 13fh	;multaplicative operator routines
usmul:	equ 16bh
usdiv:	equ 189h
sdiv:	equ 1cbh


sderbl:	equ 1e4h	;shift operator routines
shlrbe:	equ sderbl+1
sdelbl:	equ 1f2h
shllbe:	equ sdelbl+1


cmhl:	equ 1fah	;2's complement routines
cmd:	equ 202h



;
; Keyword codes
;

gotcd:	equ 8dh		;goto
rencd:	equ 8eh		;return
sizcd:	equ 8fh		;sizeof
brkcd:	equ 90h		;break
cntcd:	equ 91h		;continue
ifcd:	equ 92h		;if
elscd:	equ 93h		;else
docd:	equ 95h		;do
whlcd:	equ 96h		;while
swtcd:	equ 97h		;switch
lbrcd:	equ 9bh		;{
rbrcd:	equ 9ch		;}
mainc:	equ 9dh		;main
pplus:	equ 0b2h	;++
mmin:	equ 0b3h	;--
arrow:	equ 0b4h	;->
mincd:	equ 0b5h	;-
mulcd:	equ 0b6h	;*
divcd:	equ 0b7h	;/
ancd:	equ 0bbh	;&
letcd:	equ 0beh	;=
notcd:	equ 0bfh	;!
open:	equ 0c2h	;(
close:	equ 0c3h	;)
plus:	equ 0c4h	;+
period:	equ 0c5h	;.
semi:	equ 0c6h	;";"
comma:	equ 0c7h	;,
openb:	equ 0c8h	;[
closb:	equ 0c9h	;]
colon:	equ 0cah	;:
circum:	equ 0cbh	;~
qmark:	equ 0c0h	;?
slcd:	equ 0b0h	;<<
srcd:	equ 0b1h	;>>
lecd:	equ 0aeh	;<=
gecd:	equ 0afh	;>=
eqcd:	equ 0aah	;==
neqcd:	equ 0abh	; <excl.pt.>=
modcd:	equ 0b8h	;%
gtcd:	equ 0b9h	;>
ltcd:	equ 0bah	;<
xorcd:	equ 0bch	;^
orcd:	equ 0bdh	;|
andand:	equ 0ach	;&&
oror:	equ 0adh	;||


;
; Text strings:
;

s1:	db 'Can''t open file+'
s2:	db cr,lf,'Write error+'
s2a:	db 'CRL Dir overflow: break up source file+'
s3:	db 'Missing label+'
s4:	db 'Missing semicolon+'
s4a:	db 'Extra text after statement, before ";"+'
stgms:	equ s4	;a more mnemonic name for this error msg
s5:	db 'Illegal statement+'
s6:	db 'Can''t create CRL file+'
stg7:	db 'Bad operator+'
stg8:	db 'Lvalue required+'
stg8a:	db '++ or -- operator needs Lvalue+'
stg8b:	db 'Bad left operand in assignment expr.+'
stg9:	db 'Mismatched parens+'
stg9a:	db 'Mismatched brackets+'
stg10:	db 'Bad expression+'
stg11:	db 'Bad function name+'
stg13:	db 'Bad arg to unary op+'
stg14:	db 'Expecting ":"+'
stg15:	db 'Bad subscript+'
stg16:	db 'Bad array base+'
stg17:	db 'Bad struct or union spec+'
stg17a:	db 'Using undefined struct type+'
stg18:	db 'Bad type in binary operation+'
stg19:	db 'Bad struct or union member+'
stg20:	db 'Bad member name+'
stg21:	db 'Illegal indirection+'
stgie:	db 'Internal error: garbage in file or bug in C+'
stgom:	db 'Sorry, out of memory. Break it up!+'
stgeof:	db 'Encountered EOF unexpectedly+'
stgbf:	db 'Bad parameter list+'
stgeri:	db cr,lf,'RED error output initiated+'

	IF CPM
stgabo:	db 'Compilation aborted by ^C+'
	ENDIF

	IF NOT CPM
stgabo:	db 'Compilation aborted+'
	ENDIF
 
stgbbo:	db 'Expecting binary op+'
stgeop:	db 'Missing "("+'
stgecp:	db 'Missing ")"+'

stgtsp:	db 'to spare',cr
	IF MARC
	   db lf
	ENDIF
	db 0

stgftb:	db 'The function ',0
stgtb2:	db ' is too complex; break it into smaller ones+'
stgmlb:	db 'Missing "{" in function def''n+'
stgcsn:	db 'Control Structure '
stgetc: db 'Nesting too deep+'

	IF CPM
subfile: db 1,'$$$     SUB',0,0,0,0
	ENDIF

s00:	db cr,lf,0

patch:	dw 0,0,0,0,0,0,0,0,0,0ffffh	;patch space
patch2:	dw 0,0,0,0,0,0,0,0ffffh
patch3:	dw 0,0,0,0,0,0,0ffffh


;
; Special codes
;

nlcd:	equ 0f7h	;new-line (linefeed)
concd:	equ 0f8h	;constant code (followed by 2 byte value)
varcd:	equ 0f9h	;variable code (foll. by 2 byte disp into s.t.)
lblcd:	equ 0fah	;label code (foll. by 2-byte label val)
labrc:	equ 0fch	;label reference (foll. by 2-byte label code value)
strcd:	equ 0fdh	;string code (foll. by 2-byte sting #)
swtbc:	equ 0feh	;byte following `switch(expr)', preceding case table

litrl:	equ 0f7h
endms:	equ 38h

modbeg:	equ 0f5h
modend:	equ 0f6h



minit:	lda optimf	;look at rst7 bit of optimization flag
	and 40h
	ret z		;if not set, don't fudge with macro table
	ld hl,m16bz
	shld mactz
	shld mactz+2
	ld hl,m18z
	shld mactz+4
	shld mactz+6
	ret


;
; Come here on an internal error (if ierror is called instead
; of jumped to, that makes it easier to find out where the
; internal error occurred)
;

ierror:	ld de,stgie	;come here when things are REALLY skewered

;
; Print out error and abort compilation:
;

perrab:	call perr


;
; The general abort entry point...abort submit processing
; and reboot.
;

errab:	push hl
	lhld errbyt
	ld (hl),1		;set zcpr3 error flag (or dummy under CP/M)
	pop hl
	
	lda werrs
	or a
	call nz,errwr2

errab2:
	ld a,7		;ring a bell for errors having occurred
	call outch
	lda erasub	;bother to erase submit files?
	or a
	jp z,exit		;if not, all done

	;ld c,sguser	;get current user
	;ld e,0ffh

	;push af	;save current user

	;ld c,sguser	;select user 0
	;ld e,0
	;lda zenvf	;but only under ZSYSTMS!
	;or a
	;call nz,bdos

	ld de,subfile	;erase pending submit files
	call delf2

	;pop af		;get original user
	;ld e,a
	;ld c,sguser	;select original user
	;call bdos

	jp exit	;all done


;
; Routine that expects a semicolon to be the next non-space
; character in the text. If it isn't, spew an error. If it
; is, pass over it:
;

psemi:	call igsht
	cp semi
	jp nz,psmi2
	inc hl
	ret

psmi2:	push hl
	lhld nlcnt	;get current line number
	ex (sp),hl		;put in on stack, get text ptr in HL
	call fsemi	;advance to semicolon
	ex (sp),hl		;push text ptr onto stack, get old line no. in HL
	ex de,hl		;put old line no. in DE
	lhld nlcnt	;get current line no.
	call cmpdh	
	pop hl		;get back current text ptr
	ld de,s4
	jp nz,psmi3	;if no semicolon on current line, complain about
			; missing semicolon
	ld de,s4a	;else complain about superfluous characters	
psmi3:	call perr
	inc hl		;advance text ptr past semicolon
	ret


;
; Routine to skip everything until a semicolon is found (used
; mainly in error-recovery following the detection of a really
; screwy, non-cleanly-recoverable error):
;

fsemi:	ld a,(hl)
	or a
	jp z,igshe1	;if EOF, bad error
	cp semi
	ret z

	ld de,s5
	cp lbrcd
	jp z,perrab
	cp rbrcd
	jp z,perrab

	cp nlcd
	jp nz,fsemi3
	push hl
	lhld nlcnt
	inc hl
	shld nlcnt
	pop hl
fsemi3:	call cdtst
	jp c,fsemi5
	inc hl
	inc hl
fsemi4:	inc hl
	jp fsemi

fsemi5:	cp modbeg
	jp nz,fsemi4
	push de
	ld de,13
	add hl,de
	pop de
	jp fsemi


;
; Given HL->text, pass by any special codes and white space:
;

pascd:	call igsht
	call cdtst
	ret c
	inc hl
	inc hl
	inc hl
	jp pascd

igcd:	equ pascd

pascd2:	call igshzz
	or a
	ret z
	call cdtst
	jp nc,pscd3
	or a
	ret
pscd3:	inc hl
	inc hl
	inc hl
	or a
	jp pascd2

cdtst:	cp 0f8h
	ret c
	cp 0feh
	ccf
	ret

;
; Ignore white space in text (but acknowledge newlines
;  by bumping line count when they're encountered), and handle
; modbeg/modend:
;

igsht:	call igshzz
	or a
	ret nz
	lda prnflg	;file ends inside parens or brackets?
	or a
	jp z,igshe1

	ld de,stg9	;yes...if prnflag is 1, then use parens message
	dec a
	jp z,igsht0	
	ld de,stg9a	;else use brackets message

igsht0:	lhld prnsav
	shld nlcnt
	jp perrab

igshe1:	ld de,stgeof
igshe2:	jp perrab

igshzz:	ld a,(hl)
	or a
	ret z
	cp nlcd
	jp nz,igsh2
	push hl		;bump newline count
	lhld nlcnt
	inc hl
	shld nlcnt
	pop hl
	inc hl
	jp igshzz

igsh2:	cp lblcd
	jp nz,igsh3
	push de
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	call entl
	pop de
	jp igshzz

igsh3:	cp ' '
	jp nz,igsh4
igsh3a:	inc hl
	jp igshzz

igsh4:	cp modbeg	;module begin?
	jp nz,igsh5
	inc hl
	call pushmn	;push module name on module stack
	jp igshzz

igsh5:	cp modend	;module end?
	ret nz
	call popmn	;pop module name
	jp igsh3a

;
; Push module name at HL onto modstk, save current line number
; after it in the module stack, bump modstc, and reset nlcnt:
;

pushmn:	ex de,hl	;put text ptr in DE
	push hl	;save HL
	ld hl,modstc
	inc (hl)
	lhld modstp
	ld b,12
	call ldrc
	push de
	ex de,hl
	lhld nlcnt
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	shld modstp
	ld hl,0
	shld nlcnt
	pop de
	pop hl
	ex de,hl
	ret
		
;
; Pop modstk entry:
;

popmn:	push hl
	push de
	lhld modstp
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	ex de,hl
	shld nlcnt
	ld hl,-12
	add hl,de
	shld modstp
	ld hl,modstc
	dec (hl)
	pop de
	pop hl
	ret

;
; lde B bytes from (DE) to (HL):
;

ldrc:	push af
ldrc1:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,ldrc1
	pop af
	ret		


;
; Peek forward to next token, without actually processing any
; codes or changing status of the text pointer from the current value:
;

peeknxt:
	push hl		;save text pointer
	push de
	dec hl
peekn1:	inc hl		;look at next char
peekn2:	ld a,(hl)		;if null, done
	or a
	jp z,peekn4
	cp nlcd	;ignore all whitespace and codes
	jp z,peekn1
	call cdtst
	jp c,peekn3
	inc hl
	inc hl
	jp peekn1
peekn3:	cp ' '
	jp z,peekn1
	cp modend
	jp z,peekn1
	cp modbeg
	jp nz,peekn4
	ld de,13
	add hl,de
	jp peekn2	
peekn4:	pop de
	pop hl
	ret


;
; Given that HL->open paren in text, find the matching
; close paren and pass by it (if no matching paren is ever
; found, announce an error ocurring on original line where
; the open paren was found):
;

mtchp:	ld a,1
	sta prnflg
	push hl
	lhld nlcnt
	shld prnsav
	pop hl
	call mtchpz
	push af
	xor a
	sta prnflg
	pop af
	ret

mtchpz:	inc hl
	call igcd
	cp close
	jp nz,mtcp2
	inc hl
	ret

mtcp2:	cp open
	jp nz,mtchpz
	call mtchpz
	dec hl
	jp mtchpz

;
; Similar to mtchp, except for square brackets instead:
;

mtchb:	ld a,2
	sta prnflg
	push hl
	lhld nlcnt
	shld prnsav
	pop hl
	call mtchbz
	push af
	xor a
	sta prnflg
	pop af
	ret


mtchbz:	inc hl
	call igcd
	cp closb
	jp nz,mtcbz2
	inc hl
	ret

mtcbz2:	cp openb
	jp nz,mtchbz
	call mtchbz
	dec hl
	jp mtchbz

;
; Convert ASCII character in A to upper case,
; but don't change value of parity bit!
;

mapuc:	push bc
	ld b,a
	and 7fh
	call mapuc2
	ld c,a
	ld a,b
	and 80h
	or c		;OR in original parity bit
	pop bc
	ret

mapuc2:	cp 61h
	ret c
	cp 7bh
	ret nc
	sub 32
	ret

;
; Return Cy set if (DE < HL)
;


cmpdh:	ld a,d
	cp h
	ret nz
	ld a,e
	cp l
	ret


;
; Print error message, but use the line number saved at "savnlc" instead
; of the standard "nlcnt" count:
;

perrsv:	push	hl		;save current text pointer
	lhld	nlcnt		;save current line count
	push	hl
	lhld	savnlc		;get saved line count
	shld	nlcnt		;make it current just for this
	call	perr
	pop	hl		;now restore everything
	shld	nlcnt
	pop	hl
	ret			;and return


;
; Report error by first printing out the current line number followed
; by a colon and a space, and then printing out the string pointed to
; by DE on entry:
;

perr:	ld a,1
	sta errf
	lda prerrs	;print error msgs?
	or a
	ret z		;return if not
	push hl
	call pmodnc	;print module name, colon, space
	lhld nlcnt
	call prhcs
	call pstg
	pop hl
	ret


;
; Print out current module name, followed by a colon and space
;

pmodnc:	call pmodnm
	push af
	ld a,':'
	call outch
	ld a,' '
	call outch
	pop af
	ret

;
; Print out current module name:
;

pmodnm:	push hl
	push de
	lhld modstp
	ld de,-14
	add hl,de
	ex de,hl
	call pfnam2
	pop de
	pop hl
	ret


;
; Print out filename of fcb at DE:
;


pfnam2:	push bc
	ld a,(de)		;get disk code
	or a
	jp z,pfnm3	;if file on currently logged disk, don't print
			;disk designator.

;	ld c,gdisk	;This section of code commented out to keep
;	push de		;files on the currently logged drive from having
;	call bdos	;a disk designator printed before their names.
;	pop de		;uncomment the code to put this feature back
;	inc a		;into action.

pfnm2:	add a,'@'		;get A = 'A' for drive A, 'B' for B, etc.
	call outch
	ld a,':'
	call outch
pfnm3:	inc de
	ld b,8
	call pnseg
	ld a,(de)
	cp ' '
	ld a,'.'	;print dot only if filename has extension
	call nz,outch
	ld b,3
	call pnseg
	pop bc
	ret

pnseg:	ld a,(de)
	cp ' '
	call nz,outch
	inc de
	dec b
	jp nz,pnseg
	ret


;
; Print out the null-terminated string pointed to by DE:
;

pstg:	ld a,(de)
	or a
	ret z
	cp '+'
	jp nz,pstg2
	ld a,cr
	call outch
	ld a,lf
	jp outch

pstg2:	call outch
	inc de
	jp pstg


;
; Output a string to console only:
;

pstgco:	lda werrs
	push af
	xor a
	sta werrs
	call pstg
	pop af
	sta werrs
	ret

;
; Output a character of text to the console and/or PROGERRS.$$$ file:
;

outch:	push de
	push bc
	push hl
	push af

	ld e,a		;lde char to be output to E register

	lda werrs
	or a		;if not writing errs to PROGERRS file,
	jp z,outch3	;	go write to console
	
	lda errsin
	or a
	jp nz,outch1	;if RED buffer initialized, go handle I/O
			;else initialize RED buffer:
	inc a
	sta errsin

	push de
	ld de,redfcb
	lda fcb
	ld (de),a
	call delf2	;delete previous PROGERRS.$$$
	call create2	;create new one
;	call fopen2	;open for output
	ld hl,redbuf
	shld redbp	;initialize redbuf sector pointer

	ld de,stgeri	;"RED error output initiated"
	call pstgco	;print text to console only
	pop de

outch1:	call redout	;write char to red output file

outch3:	;ld c,conout
	;call bdos
        ld a,e
        PRCHAR

	pop af
	pop hl
	pop bc
	pop de
	ret

; Write a character to RED output buffer, flushing if needed:

redout:	lhld redbp	;get redbuf pointer
	ld (hl),e		;store char
	inc hl		;bump pointer
	shld redbp	;save pointer
	ld a,l		;past end of buffer?
	cp (redbuf+128) and 0ffh
	ret nz		;if not, return



redwrt:	push de
	ld de,redbuf	;set DMA address to redbuf for sector write
	ld c,sdma
	call bdos

	ld de,redfcb
	call writs2	;write sector

	ld de,tbuff	;set DMA address back for normal file i/o
	ld c,sdma
	call bdos

	ld hl,redbuf
	shld redbp	
	pop de
	ret
		

; Wrap up error handling, exit if there were errors:

errwrp:	call errwr1
	xor a
	sta werrs
	ret

errwr1:	lda errf	;were there any errors?
	or a
	ret z		;return if no errors

	lda werrs	;RED output enabled?
	or a
	jp z,errab2	;if not, we're all done.

errwr2:	lda errsin
	or a
	ld hl,stgie	;if errf true but RED buf not initialized,
	call z,perrab	; some kind of internal error
	ld e,1ah	;ascii end-of-file
	call redout
	lhld redbp
	ld a,l
	cp redbuf and 0ffh	;has buffer just been flushed?
	call nz,redwrt	;if not, write buffer one last time
	ld de,redfcb
	call fclose2	;close RED output buffer
	jp errab2


;
; Print a newline to the console:
;

crlf:	push af
	ld a,cr
	call outch
	ld a,lf
	call outch
	pop af
	ret


;
; Print out the value in HL in hex, followed by a colon
; and a space.
; Upon entry, A non-0: print no leading spaces
;	       A == 0: print leading spaces making total textual output 4 chars
;
;

prhcs:	push hl
	push de
	push af
	call prh	;convert HL to ascii at ascb
	pop af
	or a
	ld hl,ascb
	jp z,prhcs3	;if printing leading spaces, go do it

	dec hl
prhcs1:	inc hl
	ld a,(hl)
	cp ' '
	jp z,prhcs1	;if all four digits, no leading spaces needed

prhcs3:	ex de,hl		;put text ptr in DE
	call pstg
	pop de
	pop hl
	ret


;
; Convert Hex value in HL to ASCII, at ASCB, followed by a colon 
; and a space. A kludgey gas-pump algorithm is used, since
; no big numbers are ever printed (only line numbers):
;


prh:	push de
	call prh00
	pop de
	ret

prh00:	push hl
	ld hl,'  '
	shld ascb
	ld hl,' 0'
	shld ascb+2
	pop hl
	inc hl
prh0:	ld a,h
	or l
	ret z
	dec hl
	push hl
	ld hl,ascb+3
prh1:	ld a,(hl)
	cp ' '
	jp nz,prh2
	ld a,'0'
prh2:	inc a
	cp '9'+1
	jp z,prh4
prh3:	ld (hl),a
	pop hl
	jp prh0
prh4:	ld (hl),'0'
	dec hl
	jp prh1


fopen:
	IF CPM
	ld de,fcb

fopen2:	push de
	ld c,openfil
	call bdos
	cp 255
	pop de
	jp z,op2
	push hl	;clear nr field
	ld hl,32
	add hl,de
	ld (hl),0
	pop hl
	ret
	ENDIF

	IF NOT CPM
	ld c,m$open
	call msys
	sta marcfd
	ret z
	jp ferrab
	ENDIF

op2:	ld de,s1
	call pstg
	jp errab

fclose:	ld de,fcb

	IF CPM
fclose2:
	push hl
	ld c,closefil
	call bdos
	ENDIF

	IF NOT CPM
	ld c,m$close
	lda marcfd
	call msys
	jp nz,ferrab
	ENDIF

	pop hl
	ret

writs:
	ld de,fcb

	IF CPM		;write a sector under CP/M
writs2:	push hl
	ld c,wsequen
	call bdos
	pop hl
	or a
	ret z
	ENDIF

	IF NOT CPM
	ld c,m$write
	lda marcfd
	call msys
	ret z
	jp ferrab
	ENDIF

	ld de,s2
	call pstg
	jp errab


reads:	push hl
	
	IF CPM
	ld de,fcb
	ld c,rsequen
	call bdos
	pop hl
	or a
	ret z
	scf
	ret
	ENDIF

	IF NOT CPM
	lda marcfd
	ld c,m$read
	ld hl,tbuff
	ld de,128
	call msys
	jp nz,ferrab
	pop hl
	ld a,e		;end of file?
	or a
	ret nz		;if not, return with Carry not set
	scf		;else set Carry
	ret		;and return
	ENDIF


		
delfil:
	IF CPM
	ld de,fcb
delf2:
	push de
	push hl
	ld hl,12
	add hl,de
	ld (hl),0
	ld c,delete
	call bdos
	pop hl
	pop de
	ret
	ENDIF


create:	ld de,fcb
create2:
	push hl
	push de
	ld hl,12
	add hl,de
	ld (hl),0
	ld c,makfil
	call bdos
	pop de

	ld hl,32
	add hl,de
	ld (hl),0
	pop hl

	cp 255
	ret nz

	ld de,s6
	call pstg
	jp errab

;
; Write out the CRL file to disk:
;

writf:	ld hl,fcb+9	;make the extension "CRL"
	ld (hl),'C'
	inc hl
	ld (hl),'R'
	inc hl
	ld (hl),'L'
	call delfil	;delete old versions
	call create	;create new output file

;	call fopen	;open it under CP/M; under MARC, already open...

	lhld codp
	ex de,hl
	lhld cdao
	add hl,de
	ex de,hl
	lhld dirp
	ld (hl),80h
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	ld hl,direc	;write out CRL directory

	IF CPM
	call copys	;(copy and write 4 sectors under CP/M)
	call writs
	call copys
	call writs
	call copys
	call writs
	call copys
	call writs
	ENDIF

	IF NOT CPM
	ld de,512	;just write it all out under MARC (yey)
	call writs
	ENDIF

	lhld start	;now write out the code

	IF CPM
writ2:	call copys
	push af
	call writs
	pop af
	jp nc,writ2
	call fclose
	ld hl,fcb+10
	ld (hl),'C'	;delete the CCI file, if it exists
	inc hl
	ld (hl),'I'
	ENDIF


	IF NOT CPM
	call cmh
	ex de,hl
	lhld eofad
	add hl,de
	inc hl		;HL is length of file to write out
	ex de,hl
	lhld start
	call writs	;write out the CRL file in one shot (yey for MARC)
	call fclose
	ENDIF

	lda chainf
	or a		;only attempt to delete if not chained
	call z,delfil	;	to from CC1.
	ret

;
; Copy 128 bytes from mem at HL to tbuff:
;	(Return C set on EOF)
;

	IF CPM		;only need this under CP/M
copys:	ld de,tbuff
	ld b,80h
copy1:	ld a,(hl)
	ld (de),a
	push de
	ex de,hl
	lhld eofad
	ld a,h
	cp d
	jp nz,copy2
	ld a,l
	cp e
	jp z,copy5
copy2:	ex de,hl
	pop de
	inc hl
	inc de
	dec b
	jp nz,copy1
	xor a
	ret

copy5:	pop de
copy5a:	dec b
	jp z,copy7
	inc de
	ld a,1ah
	ld (de),a
	jp copy5a

copy7:	scf
	ret
	ENDIF

	IF MARC	;put this here so if the name overshoots, it'll
endnmp:	ds 2		;temporaries used in file renaming routine
dotflg:	ds 1
nambuf:	ds 40	;just write into something we don't need...
	ENDIF

;
; This routine sees if anything has been typed at the console,
; and if so, if it is a ^C then the compilation is aborted:
;TODO

ckabrt:	push hl
	push de
	push bc
	push af
	
	;IF CPM
	;lda conpol	;if not polling console, don't so it.
	;or a
	;jp z,noabrt
	;ld c,intcon
	;call bdos
	;or a
	;jp z,noabrt
	;ld c,coninp
	;call bdos
	;cp 3
	;jp nz,noabrt

	;ld de,stgabo
	;call pstg
	;jp errab	
	;ENDIF

	IF NOT CPM
	;ld c,m$ichec
	;call msys
	ENDIF

noabrt:	pop af
	pop bc
	pop de
	pop hl
	ret

	;IF LASM
	;link cc2b
	;ENDIF
