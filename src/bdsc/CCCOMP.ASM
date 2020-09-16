;
; ccc.asm:
;

;
; This is the declaration parser....
;

bst:	xor a
	sta stelf
	sta unflg
	sta forml
	sta clevb
	sta sf
	sta newid
	inc a
	sta clevt
	call initst
	ld hl,0
	shld stor
	shld stno
	ld hl,st
	shld stp
	call initps
	dec de

bst1:	inc de
bst2:	call pascd
	jp nz,bst2a
	lda clev
	or a
	ret nz
	lhld stor
	shld extsa
	ret

bst2a:	cp lbrcd	;open curly-brace?
	jp nz,bst3

	call ckabrt	;a convenient place to check for abortion...

	lda forml	;yes. have we been processing a formal declaration
	or a		;list?
	jp nz,bst2b	;if so, switch state to being out of formal area.

	lda clevb	;else if still at top level, then there
	or a		; is an error here somewhere.
	jp nz,bst2c	;at top level? if not, all OK.

	ld hl,stgilc	;if at top level, bad curly-brace encountered.
fatal:	jp perrab

bst2b:	ld hl,0
	shld stor

bst2c:	xor a		;turn off formal flag
	sta forml
	ld hl,clevb
	inc (hl)		;bump curly count
	jp bst1	;and go for more

bst3:	cp rbrcd	;right curly bracket?
	jp nz,bst5
	lda clevb	;yes.
	or a		; were we already at top level?
	jp nz,bst4
	ld hl,stg12	;if so, then error.
	jp fatal

bst4:	dec a		;debump curly-count
	sta clevb
	jp nz,bst1	;and go loop if not back to top level
	lda clev	;now at top level. bump func count
	inc a
	sta clevt
	xor a		;set clev to zero (external)
	sta clev
	lhld stor	;set local stack frame size for func just completed
	ld b,h		; processing.
	ld c,l
	lhld fndad	;this is the address of where the sf size will go
	inc hl
	inc hl
	ld (hl),c		;well, now it is. store it.
	inc hl
	ld (hl),b
	lhld extsa	;and restore the external storge allocation value
	shld stor	;to the storge allocator.
	jp bst1	;and go for more external stuff.


bst5:	call tstty	;no. a type specifier?
	jp nc,bst5a
	cp regcd	;no. "register"?
	jp z,bst5b
	cp shrtcd
	jp nz,bst6
bst5b:	push de		;yes.
	lhld nlcnt	;ignore it.
	push hl
	inc de
	call igsht
	pop hl
	shld nlcnt
	pop de
	call tstty	;if not followed by type, assume "int"
	jp nc,bst5z
	ld a,81h	;"int" code
	ld (de),a
	jp bst5a

bst5z:	ld a,0ffh	;delete "register" code
	ld (de),a
	jp bst1

bst5a:	call declp	;process declarations of this type
	jp bst1	;and loop for more text

bst6:	ld a,(de)		;not a declaration. an identifier?
	call varch
	jp c,bst1		;if not, then not interesting. look for something else
	call finds	;yes. is it in the symbol table?
	jp c,bst8
	lda clev	;yes. are we processing externals?
	or a
	jp nz,bst6a
	ld a,negone	;if so, might be typeless function def; insert "int".
	call mvtxt
	ld a,81h	;"int" code
	ld (de),a
	jp bst5a

bst6a:	call cknex	;not external. make sure it isn't an external
	push hl		; redeclaration.
	ld a,c		;relde text of identifier and replace it with
	sub 3		; the special 3-byte symbol table pointer.
	call mvtxt
	pop hl
	call bstz2
	lda flev
	or a
	jp nz,bst1	;ignore if already local
	push de		;else must create local instance of an identifier
	ld de,st+8	;having an external namesake...
	add hl,hl
	add hl,hl	
	add hl,hl
	add hl,hl
	add hl,de
	ld a,(hl)
	and 1
	jp nz,bst6f	;go do it if needed.
	pop de		;else already declared locally. nothing else to do.
	jp bst1	;go process some more text

;
; So, now we know we have a usage of a function defined
; externally... let's make an st entry for it locally:
;

bst6f:	ld de,-8
	add hl,de	;HL--> ext def.
	ex de,hl
	lhld stp
	ld b,16
bst6f1:	ld a,(de)
	ld (hl),a
	inc hl
	inc de
	dec b
	jp nz,bst6f1

	ld de,-8
	add hl,de
	ld a,(hl)
	or 3
	ld (hl),a
	inc hl
	ld a,(hl)
	and 0e0h
	ld b,a
	lda clev
	add b
	ld (hl),a
	inc hl
	pop de
	dec de
	dec de
	jp bstf3


cknex:	push af
	lda clev
	or a
	jp z,ck2
	pop af
	ret

ck2:	ld hl,stg15
	call perr
	call fsemi
	pop hl
	pop hl
	jp bst1

bst8:	push de
	lhld nlcnt
	push hl
	call pasvr
	pop hl
	shld nlcnt
	pop de
	cp open
	jp z,bstf
	call cknex
	cp openb
	jp z,bste
	cp arrow
	jp z,bste
;	cp period
;	jp nz,bst10

bste:	call bvarm	;bad variable message
	call pasvr
	jp bst1

;bst10:	call bvarm
;	call bstl
;	jp bst1

bstl:	call instt
	ld a,c
	sub 3
	sta tmpbs
	call mvtxt
	lda forml	;if formal, set formal bit
	rlca
        rlca
        and 04h
	or 10h		;always set to int type
	ld (hl),a
	inc hl
	lda clev
	or a
	jp nz,bstlb

bstla:	ld hl,stg15
	call perr
	jp bst1

bstlb:	ld (hl),a
	inc hl
	push hl
	lhld stor
	ld b,h
	ld c,l
	inc hl
	inc hl
	shld stor

bstlc:	pop hl
	call bstz
	ret


bstf:	lda clev
	or a
	jp nz,bstf2
	call fnnt
	jp bst1

bstf2:	call instt
	ld a,c
	sub 3
	call mvtxt
	ld (hl),13h
	inc hl
	lda clev
	or a
	jp z,bstla
	ld (hl),a
	inc hl
bstf3:	push hl
	lhld fnc
	ld b,h
	ld c,l
	inc hl
	shld fnc
	pop hl
	call bstz
	jp bst1


bstz:	ld (hl),c
	inc hl
	ld (hl),b
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	shld stp
	lhld stno
	push hl
	inc hl
	shld stno
	pop hl

bstz2:	ld a,varcd
	ld (de),a
	inc de
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	ret

fnnt:	push de
	ld a,-1 and 255
	call mvtxt
	ld a,81h
	jp dclp1

declp:	xor a
	sta what	;"what" defaults to variable
	inc a
	sta type	;"type" defaults to int (bug fix 11/19/80)
	ld a,(de)
	push de
	cp uncd
	jp z,dclp0
	cp sttcd
	jp nz,dclp1
dclp0:	call decs
	jp dclp1c

dclp1:	sub 80h
	sta type
	inc de
	call igsht
	cp regcd	;ignore "register" keyword
	jp nz,dclp1b
	inc de
dclp1b:	xor a
	sta what
	call declst

dclp1c:	ld a,(de)
	cp semi
	jp nz,decf
	pop hl
	dec hl
dclp2:	inc hl
	ld a,(hl)
	cp nlcd
	jp z,dclp3
	ld (hl),0ffh
dclp3:	call cmphd
	jp nz,dclp2
	ret

; Relde text between start of function def
; and start of formal param list:

decf:	lda lind	;check for illegal func def of type struct or union
	or a
	jp nz,decf00
	lda type
	cp 6
	jp nz,decf00

	ld hl,stgbft	;bad function type (function cannot return a struct)
	call perr
	
decf00:	lhld opena
	ex de,hl		;put start of formal param list ptr in DE
	pop hl		;get --> start of declaration
decf01:	call cmphd
	jp z,decf03
	ld a,(hl)		;except for newlines, that is...
	cp nlcd
	jp z,decf02
	ld (hl),0ffh
decf02:	inc hl
	jp decf01

decf03:	ld a,-3 and 255 ;make room for function code
	call mvtxt

decf0:
	ld a,varcd
	ld (de),a
	inc de
	lhld stno
	dec hl
	lda pdfd	;use original st# if declared previously
	or a
	jp z,decf1
	lhld pdfdno
decf1:	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	inc de
	call igsht	;now find param list
	inc de
	ld a,1
	sta forml	;set formal flag
	lhld stor
	shld extsa	;save external storge count
	ld hl,1		;reset local function count number
	shld fnc
	dec hl		;and clear local storge allocator
	shld stor
decf2:	call igsht	;scan formal parm list
decf3:	cp close	;end?
	ret z		;if so, all done
	call varch	;else legal identifier?
	jp nc,decf4
	ld hl,stg23	;if not, complain
	call perr
	ld a,close	;and skip rest of list
	call findc
	ret

decf4:	call finds	;does identifier already exist?
	jp nc,decf5
decf4a:	call bstl	;no. install as simple formal int
	jp decf6	;and go for more

decf5:	lda flev	;exists already. External in its formal
	or a	 	;incarnation?
	jp z,decf4a	;if so, simply ignore external one.
	push hl	
	push bc
	ld hl,stg24	;else redeclaration error (only possibility
	call bvarm2	;is an identical id earlier in parm list)
	pop bc
	ld a,c
	sub 3
	call mvtxt
	pop hl
	call bstz2
decf6:	inc de		;go on to next parm
	call igsht
	cp comma
	jp nz,decf3		
	inc de
	jp decf2


;
; Process structure declaration:
;

decs:	sta tmpsu
	ld a,1
	sta modaf
decs0:	inc de
	call igsht
	cp regcd	;ignore "register" keyword
	jp z,decs0

	cp lbrcd	;immediate structure listing?
	jp z,decsl
	call finds	;if not, must be struct identifier
	jp nc,decse	;if known identifier, go handle it
	call instt	;otherwise install new struct identifier name
	ld a,1
	sta newid
	call pasvr
	jp decs1

decsl:	push de		;if no identifier given, use a dummy name
	ld de,stgdu
	call instt
	pop de

decs1:	lda forml	;save state of formal, since it is meandngless
	push af	;for a structure type definition
	lda what
	push af
	ld a,2
	sta what
	ld hl,0
	shld dmsiz
	dec hl
	shld size
	xor a
	sta forml
	sta lind
	sta ptfnf
	call wrapup
	pop af
	sta what
	pop af
	sta forml
	lhld stno
	dec hl
	shld size

decsf:	call igsht	;see what follows the identifier
	cp lbrcd	;left brace?
	jp z,decsd	;if so, go handle definition
	jp decsd6	;else go process declarator list

decse:	xor a
	sta newid
	shld size
	push hl
	push de
	call getsz
	ex de,hl
	shld strsz
	pop de
	pop hl
	push hl
	call cvtst
	and 3
	cp 2
	jp z,decse2
	pop hl
	ld hl,stg28

decse1:	call perr
	call fsemi
	ret

decse2:	push hl
	push de
	lhld nlcnt
	push hl
	call pasvr	
	pop hl
	shld nlcnt
	pop de
	pop hl
	cp lbrcd
	jp nz,decse3

	inc hl
	inc hl
	inc hl
	inc hl	
	inc hl
	ld a,(hl)
	cp 255
	jp z,decse3
	ld hl,stg24
	call bvarm2	;"redeclaration of: name"

decse3:	pop hl
	call pasvr
	jp decsf


decsd:	lda forml
	push af
	xor a
	sta forml
	push hl
	lhld stor
	push hl
	lhld mxsiz
	push hl
	lda stelf
	push af
	lda unflg
	push af
	ld hl,0
	shld stor
	shld mxsiz
	ld a,1
	sta stelf
	xor a
	sta unflg
	inc de
	lda tmpsu
	cp uncd
	jp nz,decsd2
	sta unflg

decsd2:	call igsht
	cp rbrcd
	jp z,decsd4
	call tstty
	jp nc,decsd3
	ld hl,stg16
	call perr
	call fsemi
	inc de
	jp decsd2

decsd3:	call declp
	jp decsd2

decsd4:	inc de
	lda unflg
	or a
	jp z,decsd5
	lhld mxsiz
	shld stor
decsd5:	pop af
	sta unflg
	pop af
	sta stelf
	lhld stor
	shld strsz
	ld b,h
	ld c,l
	pop hl
	shld mxsiz
	pop hl
	shld stor
	pop hl
	shld size
	push de
	call getsz
	ld (hl),c
	inc hl	
	ld (hl),b
	pop de
	pop af
	sta forml
	xor a
	sta newid	;identifier no longer new after definition

decsd6:	ld a,6
	sta type
	call declst
	xor a
	sta newid	;clear newid flag
	ret

getsz:	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,st+12
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)	
	dec hl
	ret



declst:	call igsht
	cp semi
	ret z

decls1:	lda what
	push af
	call dec

;
; Check for forward references to undefined structures:
;

	lda type
	cp 6
	jp nz,decls0	;structure?
	lda lind	;yes. indirection?
	or a
	jp nz,decls0
	lda newid	;no. brand new, undefined struct id?
	or a
	jp z,decls0
	ld hl,stg28a	;using undefined structure id
	call perr

decls0:	call igsht
	cp comma
	inc de
	jp nz,decls2
	pop af
	sta what
	jp decls1

decls2:	dec de
	pop bc	;clean up stack
	cp semi
	ret z
	lda what
	cp 1
	ret z
	ld hl,stg25
	call perr
	call fsemi
	ret

dec:	xor a
	sta ptfnf
	sta lind
	sta sf
	inc a
	sta modaf
	ld hl,0
	shld dmsiz
	shld tmpa
	lhld stor
	shld adrs
	xor a
	sta frmrf
	sta pdfd
	call decr
	lda pdfd
	or a
	call z,wrapup
	lda frmrf	;was it a formal resolution?
	or a
	jp z,dec2
	lhld savsta	;yes. restore storge allocation count
	shld stor
dec2:	lda funcf
	or a
	ret z
	lda clevt
	sta clev
	cp 64		;max # of funcs specifiable in 6 bits
	ret c
	ld hl,stgtmf	
	jp pstgab

decr:	xor a
	sta funcf
	call igsht
	cp open
	jp nz,decr1
	inc de
	call decr
	cp close
	inc de
	jp z,deca
	ld hl,stg16

decr0:	call perr
	call fsemi
	ret

decr1:	cp mulcd
	jp nz,decr2
	inc de
	call decr
	ld hl,lind
	inc (hl)
	ld a,(hl)
	cp 4
	jp c,deca
	ld de,stgtmi	;too much indirection
	call perr
	jp deca

decr2:	call varch
	jp nc,decr3
	ld hl,stg17
	jp decr0

decr3:	call finds	;symbol exist already?
	jp nc,dec3a

	lda forml	;no. are we processing formal declarations?
	or a
	jp z,decr3a	;if not, no problem
			;OK, we're definitely doing formal declarations:
	lda stelf	;processing structure definition?
	or a
	jp nz,decr3a	;if so, allow it (wierd but OK, I guess...)

decr3e:	ld hl,stgbfd	;else error.
	call bvarm2	; "idendtifier not in formal list: name"
	jp decr3a

dec3a:	shld pdfdno
	lda clev	;are we at external level?
	or a
	jp z,decr3x	;if so, go handle that case
	lda flev	;we're local. Is identifier also an external
	or a		;variable?
	jp nz,decr3z

	lda stelf	;if in a structure def, don't look too hard...
	or a
	jp nz,decr3a

	lda forml	;yes. If we're formal, bad news.
	or a
	jp nz,decr3e
	jp decr3a	;else just make a local instance of the identifier.

decr3z:	lda stelf	;now we know: we're local & we have a previously
	or a		; defined local identifier to process.
	jp nz,dr3za	;are we processing a structure definition?

	lda forml	;if not, it BETTER be a formal parameter decl...
	or a
	jp z,dec3ze	;if not, it is a redeclaration error.

	ld a,0		;else must set things up specially for wrapup
	sta modaf	;make sure stp and stno aren't bumped in wrapup
	inc a
	sta frmrf	;set formal resolution flag

	lhld stor	;save current storge allocator
	shld savsta	;to be restored AFTER the wrapup

	lhld inadsv	;get pointer to ST entry of formal parameter
	dec hl
	shld tempd
	inc hl
	inc hl
	ld a,(hl)		;get address from ST entry
	inc hl
	ld h,(hl)
	ld l,a
	shld adrs	;make current for wrapup
	jp decr4	;and handle rest of declaration normally

dr3za:	lhld inadsv
	dec hl
	shld tempd
	lda what
	or a
	jp nz,dec3ze
	ld a,(hl)
	and 8
	jp z,dec3ze
	ld a,(hl)
	rlca
	rlca
	rlca
	rlca
	and 7
	ld b,a
	lda type
	cp b
	jp nz,dec3z1
	inc hl
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	lhld stor
	ld a,b
	cp h
	jp nz,dec3z1
	ld a,c
	cp l
	jp nz,dec3z1
	xor a
	sta modaf
	jp decr4

dec3ze:	ld hl,stg24
	call bvarm2
	call fsemi
	ret

dec3z2:	call perr
	call fsemi
	ret

dec3z1:	ld hl,stgbsd
	jp dec3z2

decr3x:	call cvtst
	shld tempdp
	and 3
	cp 3		;is previously declared identifier a function ref?
	jp z,decr3y	;if so, go handle as a "previously declared func def"f
	ld a,(hl)		;else is it a structure element?
	and 8
	jp nz,decr3z	;if so, handle as such and let errors happen there
	call dec3ze	;else barf on it.
	jp errab

decr3y:	ld a,1
	sta pdfd
	ld a,(hl)
	and 0fdh	;change from func ref to func def
	ld (hl),a
	jp decr4

decr3a:	call instt	;install new identifier
decr4:	lhld nlcnt
	push hl
	call pasvr
	pop hl
	cp open
	jp z,decr4a
	lda pdfd
	or a
	jp nz,dec3ze
	jp deca

decr4a:	ex de,hl
	shld opena
	ex de,hl
	push hl
	call mtchp
	pop hl
	cp semi
	jp z,decr5
	cp comma
	jp nz,decr7

decr5:	shld nlcnt
	lhld opena
	ex de,hl
	jp deca

decr7:	lda clev	;found a function definition--process it
	or a
	jp z,decr8
	ld hl,stg19
	jp decr0

decr8:	ld a,1
	sta funcf
	sta what
	shld nlcnt	;restore line count at start of func name ident
	ld hl,0	
	shld adrs
	lhld tempd
	lda pdfd
	or a
	jp z,decr9
	lhld tempdp
decr9:	shld fndad
	ret

deca:	call igsht
	cp open
	jp nz,deca3
	lda lind
	or a
	jp z,deca2
	dec a
	sta lind
	ld a,1
	sta ptfnf
	call mtchp
	ret

deca2:	ld a,3
	sta what
	lhld fnc
	shld adrs
	inc hl
	shld fnc
	call mtchp
	ret

deca3:	cp openb
	ret nz
	lda lind
	sta sf
	ld hl,1
	call gdim
	shld tmpa
	lda forml
	or a
	jp nz,deca4
	lda csf
	or a
	jp nz,deca4

dca3a:	ld hl,stg20
	call gdim1a

deca4:	call igsht
	cp openb
	jp z,deca5
	ld hl,0ff00h
	shld dmsiz
	ret

deca5:	call gdim
	call multa
	lda csf
	or a
	jp z,dca3a
	call igsht
	cp openb
	jp nz,deca6

deca5a:	ld hl,stg21
	call gdim1a

deca6:	shld dmsiz
	ret

gdim:	inc de
	xor a
	sta csf
	call igsht
	inc de
	cp closb
	ret z
	dec de
	ld a,1
	sta csf
	ld a,(de)
	cp concd
	jp z,gdim2

gdim1:	ld hl,stg22
gdim1a:	call perr
	call fsemi
	pop hl
	pop hl
	ret

gdim2:	inc de
	ld a,(de)
	ld l,a
	inc de
	ld a,(de)
	ld h,a
	inc de
	call igsht
	cp closb
	inc de
	ret z
	jp gdim1


mult:	push de
	ld d,h
	ld e,l
	ld hl,0

mult2:	add hl,de
	dec bc
	ld a,b
	or c
	jp nz,mult2
	pop de
	ret

multa:	push hl
	ld b,h
	ld c,l
	lhld tmpa
	call mult
	shld tmpa
	pop hl
	ret


wrapup:	push de
	lda what
	ld b,a
	lda forml
	add a
	add a
	add b
	ld b,a
	lda stelf
	add a
	add a
	add a
	add b
	ld b,a
	lda type
	add a
	add a
	add a
	add a
	add b
	ld b,a
	lda ptfnf
	rrca
	add b
	lhld tempd
	ld (hl),a
	inc hl
	lda lind
	rrca
	rrca
	and 0c0h
	ld b,a
	lda clev
	add b
	ld (hl),a
	inc hl
	ex de,hl
	lhld adrs
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	ex de,hl
	lhld size
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	ex de,hl
	lhld dmsiz
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	lda modaf
	or a
	jp z,wrap2
	shld stp
	lhld stno
	inc hl
	shld stno
wrap2:	pop de
	lda what
	or a
	ret nz

	ld bc,1
	lhld tmpa
	ld a,h
	or l
	jp z,wrapf
	lda sf
	or a
	jp nz,wrapf
	lda forml
	or a
	jp nz,wrapf
	ld b,h
	ld c,l

wrapf:	ld h,b
	ld l,c

	lda lind
	or a
	ld bc,2		;if any levels of indirection, make object size
	jp nz,wrpf3	;equal to two

	lda ptfnf	;pointer to function is a special case of indirection
	or a
	jp nz,wrpf3
	
	lda forml
	or a
	jp nz,wrpf3
	lda type
	cp 6
	jp nz,wrpf2
	push hl
	lhld strsz
	ld b,h
	ld c,l
	pop hl
	ld a,b
	cp 0ffh
	jp nz,wrpf3
	push hl
	ld hl,stg28
	call perr
	ld bc,1
	pop hl
	jp wrpf3

wrpf2:	dec bc
	or a
	jp z,wrpf3
	inc bc
	cp 3
	jp c,wrpf3
	inc bc
	inc bc
	cp 5
	jp c,wrpf3
	inc bc
	inc bc
	inc bc
	inc bc

wrpf3:	call mult
	ld b,h
	ld c,l
	lhld stor
	lda unflg
	or a
	jp z,wrpf4
	lhld mxsiz
	call max
	shld mxsiz
	ld hl,0
	jp wrpf5
wrpf4:	add hl,bc
wrpf5:	shld stor
	xor a
	sta sf
	ret

max:	ld a,b
	cp h
	ret c
	jp z,max2

max1:	ld h,b
	ld l,c
	ret

max2:	ld a,c
	cp l
	ret c
	ld h,b
	ld l,c
	ret


;
; Definitions of some scratch variables and buffers
; used by passc: Since passc happens after bst is all
; done, we put all passc's temp space on top of the bst
; code:
;

cntt:	equ bst		;(ds 220)
cntp:	equ bst+220	;(ds 2)
swtc:	equ bst+222	;(ds 1)
swtt:	equ bst+223	;(ds 800)
swtp:	equ bst+1023	;(ds 2)
defp:	equ bst+1025	;(ds 2)
defflg:	equ bst+1027	;(ds 1)
tmpnl:	equ bst+1028	;(ds 2)
fbuf:	equ bst+1030	;(ds 350)
;
; "Expendable" routines: the following code gets
; overwritten by the symbol table after it is used...
;

	ds 4
st:	equ ($+15) and 0fff0h


stg11:	db 'Illegal colon+'
stg26:	db 'Undefined label used+'
stg99:	db 'Syntax error+'
stg8:	db 'Bad constant+'
stg8a:	db 'Bad octal digit+'
stg8b:	db 'Bad decimal digit+'
stgsuf:	db 'Curly-braces mismatched somewhere in this definition+'

;
; The following strings used only by "readf", so their storge
; areas may be used by other routines afterwards...
;

stg4:	db 'Disk read error+'
stgie:	db 'Cannot open ',0
stgine:	db '#include files nested too deep+'
stgnua:	db 'No user area prefix allowed+'
stgucc:	db 'Unterminated comment begins here+'

	IF NOT ALPHA
stg0:	db 'BD Software C Compiler '
	ENDIF

	IF ZSYSTEM
	db '(for ZCPR3) '
	ENDIF

	IF ALPHA
stg0:	db 'BDS Alpha-C Compiler '
	ENDIF

	if not ZSYSTEM
	db 'v1.'
	db version
	db updatn+'0'
	endif

	if ZSYSTEM
	db 'vZ'
	db version
	db '.'
	db updatn+'0'
	ENDIF

	IF UPDATY			;if there is a secondary update number,
	     db updaty			;then specify it,
	     db ' '
	ENDIF

	IF NOT UPDATY
	     db '  '
	ENDIF

	db '(part I)'
	
	IF PREREL
	   db '  pre-release'
	ENDIF

	db cr,lf

	IF	DEMO
	db	'	==== DEMO COPY ====    **** NOT FOR DISTRIBUTION ****'
	db cr,lf
	db	'	This compiler package is available through this store,'
	db cr,lf
	db	'	or directly from:',		cr,lf
	db	'		BD Software, Inc.',	cr,lf
	db	'		P.O. Box 2368',		cr,lf
	db	'		Cambridge, Ma. 02238',	cr,lf
	db	'		Phone: (617) 576-3828',	cr,lf
	db	'		Price:    $150 (8" SSSD format)',cr,lf
	ENDIF

	db 0

	IF CPM
stg1:	db 'Usage: ',cr,lf
	db 'call c,<source_file> [-p] [-o] [-a <x>] [-d <x>]'
	ENDIF

	IF CPM AND NOT ALPHA
	db ' [-m <addr>]'
	ENDIF

	IF CPM
	db ' [-e <addr>] [-r <n>]'
	ENDIF

	db '+'

savadr:	equ $		;this is where readf will go....


;
; The following storage is for routines in the expendable portion of 
; the program. The sections for each (independent) pass are org-ed to
; start at "stg4", to conserve memory
;

	org stg4	; "prep" data area:

deformt: ds 50		; (prep) for scratch space later on
txbuf:	ds 200		; (prep) scratch space
nlcsav:	ds 2		; (prep) nlcnt gets saved here while text is hacked
def2p:	ds 2		; (prep) string table pointer for preprocessor
deftmp:	ds 2		; (prep)
dstgf:	ds 1		; (prep)
nestl:	ds 1		; (prep) nesting level for preprocessor
active: ds 1		; (prep) active conditional compilation flag
didelse: ds 1		; (prep) true if "#else" already done
parenc:	ds 1		; (prep) paren nesting count, used by "deform"

	org stg4	; "passx" and "lblpr" data area:

opstp:	ds 2		; (passx) op stack pointer for constant expr evaluator
opstk:	ds 30		; (passx) operator stack for const. expr evaluator
valsp:	ds 2		; (passx) val stack ptr for const. expr eval.
valstk:	ds 50		; (passx) val stack for const. expr. eval.
savnlc:	ds 2		; (lblpr) for saving function starting line #s


;
; Read in the source file from disk, process
; #includes on the fly, recursively
;

	org savadr

readf:	ld hl,st	;initialize code address to follow
	ex de,hl		;	variable-sized symbol table
	lhld stsiz
	add hl,de
	shld coda

	ld hl,inclstk	;set up #include processing stack after code ends
	shld fsp
	lhld coda
	shld textp

	IF CPM
	xor a		;don't put out user number on main filename
	sta udiag
	inc a		;allow automatic ".c" tacking for main file
	sta dodotc
	ENDIF

	call initps

;gen fcb from filename
filenameaddr=$+1
        ld de,0
        push de
readf_fspac:
	ld a,(de)
	or a
	jr z,readf_fspac_skip
	inc de
	cp ' '
	jr nz,readf_fspac
        dec de
        xor a
        ld (de),a
readf_fspac_skip
        pop de
        ld hl,fcb+1;fcb_filename ;Pointer to 11 byte buffer
        OS_PARSEFNAME

        ;ld hl,fcbwas
        ;ld de,fcb
        ;ld bc,FCB_sz
        ;ldir

	call readm
	or a		;successful?
	jp z,errab	;go abort if not
	ld (hl),0
	inc hl
	ld (hl),1ah
	shld eofad
	shld meofad
	ret

;fcbwas
;        db 0
;fcbwas_filename
;        db "ex      c  "
;        ds fcbwas+FCB_sz-$

;
; Read in a source module from disk. Filename and user number have
; been preset by calling routine (file info at default fcb):
;

readm:	push de
	ld de,fcb
	call openg
	pop de
	jp nz,rm2		;if no error, goto rm2

	IF CPM		;try ".c" if no extension given.
	lda dodotc	;allowing automatic ".C" tacking?
	or a
	jp z,reade	;if not, then open simply failed.

	ld de,fcb+9	;else try tacking ".C" if no extension given.
	ld a,(de)
	cp ' '
	jp nz,reade	;if extension given, simple error.
	ld a,'C'	;else tack on the .C extension
	ld (de),a
	jp readm	;and go try opening it THAT way
	ENDIF

reade:	lda modstc	;at top level?
	or a
	ld hl,stgie	;"Cannot open: "
	push af
	call z,pstg
	pop af
	call nz,perr
	call prfnm	;<filename>
	call crlf
	xor a		;return zero to indicate failure
	lhld textp	;return HL still valid so we don't botch up memory
	ret

prfnm:
	IF CPM
	lda udiag	;printing user number as part of filename?
	or a
	jp z,prfnm2
	lda defusr
	cp 0ffh	;if default user area is always the current one,
	lda curusr	;   don't mention it in error report
	call nz,prads	;print decimal number and slash
prfnm2:
	ENDIF
	call pfnam
	ret

;
; Module opened OK. Set up for reading:
;

rm2:	xor a		;initialize comment nesting level count
	sta cmntf
	sta quotf	;not in a quoted string

	IF CPM
	sta dodotc	;don't append ".C" on first try
	ENDIF

	IF NOT ALPHA
	inc a
	ENDIF

	sta udiag	;print user number in filename diagnostics from now on
	ld hl,tbuff+secsiz-1	;set up sector buffer so the next call to

	IF NOT CPM
	ld hl,secbuf+secsiz-1
	ENDIF

	shld sptr	;init sector pointer

	ld hl,0		;clear line number for unmatched comment diagnostics
	shld nlcnt
	shld atcnt	;clear active text line counter, also for above

	lhld textp
	ld (hl),modbeg	;install module-begin code and filename in text...
	inc hl
	push hl
	call insrtm	;install module name into text
	pop de
	call pushmn	;push module name onto modstk
	ex de,hl	

rm2a:	ld a,cr
	sta lastc

rm3:	call getc	;get a character
	jp c,rm3ab0	;on EOF, go check for last-line CR and close the file

rm3aa:	call kludge	;reverse cr's and lf's for some strange reason...
	ld a,c		;always save CR's
	cp cr
	jp nz,rm3ab

	call bumpnl	;bump line count
	call ckabrt	;check once in a while for abortions
	jp storc

rm3ab:
	cp 1ah		;if control-Z, check for proper final line termination
	jp nz,rm3ac

;
; Perform end-of-file consistency check, to make sure final line of the
; file was properly terminated with a newline:
;

rm3ab0:	push hl		;save text pointer
rm3ab1:	dec hl
	ld a,(hl)
	cp cr
	jp z,rm3ab2	;if found CR, last line was properly terminated...
	cp 0ffh
	jp z,rm3ab1	;ignore FF's
	pop hl		;else last line was NOT properly terminated. insert CR
	ld (hl),cr
	inc hl
	jp rm3ab3	;and go close file

rm3ab2:	pop hl
rm3ab3:	call closef
	ld (hl),modend	;module-end marker
	inc hl
	call popmn	;pop module name off module stack

	lda cmntf
	or a		;file ends in the middle of a comment?
	ld a,1		;return success code if not
	ret z
	push hl

	call pfnam	;print file name
	ld a,':'
	call outch
	ld a,' '
	call outch

	lhld atcnt	;get last active line number
	call prhcs
	ld hl,stgucc	;"UNCLOSED COMMENT" diagnostic
	call pstg
	pop hl
	xor a		;return 0 -- error condition
	ret

rm3ac:	cp 0ch		;formfeeds turn into nulls
	jp z,storff

	cp lf		;so do linefeeds
	jp z,storff

	or a		;nulls are totally ignored
	jp z,rm3

	lda cmntf
	or a		;are we in a comment?
	jp nz,rm3ac2	;if so, go test for in-comment conditions

	push hl		;save line number as last active line number
	lhld nlcnt
	shld atcnt
	pop hl
	jp storc	;and go save character in memory

rm3ac2:	ld a,c		;we're in a comment.
	cp '/'		;have we encountered a close comment?
	jp nz,rm3a
	lda lastc
	cp '*'
	ld a,'/'
	jp nz,rm3a
	lda cmntf	;yes. decrement comment count.
	dec a
	cp 255
	jp z,rm2a		;don't store back if too many closes!
	sta cmntf
	jp rm2a

rm3a:	cp '*'		;have we encountered another open comment?
	jp nz,rm3b
	lda lastc
	cp '/'
	ld a,'*'
	jp nz,rm3b	
	lda cnflag	;do comments nest?
	or a
	jp z,rm2a		;if not, ignore this new open comment.
	lda cmntf	;yes. bump comment count.
	inc a
	sta cmntf
	jp rm2a

rm3b:	sta lastc	;still in comment. keep scanning.
	jp rm3

storc:	ld (hl),c		;not in a comment. store the character
	
	ld a,c
	call mapuc
	cp '#'		;preprocessor directive?
	jp nz,rm4
	lda lastc	;get char before "#" for later check
	sta lastc2	;to make sure it is a CR.
	shld pndsav
	ld a,'#'
rm3r:	inc hl
rm3s:	sta lastc
	jp rm3

storff:	ld a,0ffh
	ld (hl),a
	jp rm3r

rm4:	cp '"'		;check for quote
	jp nz,rm4b
	lda quotf	;is this a closing or opening quote?
	or a
	jp nz,rm40	;if closing, don't check for '"' case
	lda lastc	;was last char a single quote?
	cp ''''
	jp z,rm6
rm40:	lda quotf	;found one. Already in a string?
	or a
	ld a,1	
	jp z,rm4a		;if not, set the string flag
	xor a		;else clear the string flag
rm4a:	sta quotf	;set "in a string" flag
	ld a,'"'
	jp rm6	

rm4b:	cp '\'		;check for backslash in quoted string
	jp nz,rm4c

	lda quotf	;in a quoted string?
	or a
	ld a,'\'
	jp z,rm6		;if not, ignore backslash
	inc hl
	call getcef
	cp '"'
	jp z,rm4ba
	cp '\'
	jp z,rm4ba
	jp rm3aa

rm4ba:	ld (hl),a
	jp rm6

rm4c:	cp '*'		;have we encountered an open comment?
	jp nz,rm5
	lda lastc	;maybe...we have a '*'
	cp '/'		;was last character a '/'?
	ld a,'*'	;if not, just store the '*'
	jp nz,rm6
			;OK, we found a '/*' sequence...
	lda quotf	;in a quoted string?
	or a
	ld a,'*'	;if so, don't regard the '/*' as a comment delimiter
	jp nz,rm6

	dec hl		;definitely a comment delimiter. kill the '/'
	ld a,1		;and set comment count.
	sta cmntf
	jp rm2a

rm5:	cp 'I'		;possibly part of "include" keyword?
	jp nz,rm6
	lda lastc2	;if a possible #include, make sure
	cp cr		;the char before the "#" was a CR..
	jp nz,rm6
	xor a
	sta lastc2
	lda lastc
	cp '#'
	jp z,doincl

rm6:	sta lastc
	inc hl
	jp rm3


;
; Handle "#include":
;
; At this point, we've seen "#i"...let's make sure
; we see at least another "n", then skip the rest, and
; then process the file...
;

angleu:	ds 1		;true if angle bracket surrounds filename

doincl:	xor a
	sta angleu
	shld textp
	inc hl
doin0:	call getcef
	ld c,a
	call mapuc
	cp 'N'
	jp nz,storc
	
	call getcef
	call mapuc
	cp 'C'
	jp nz,rm6		;just makin' sure we got "#inc"...

doinz:	call getcef	;pass by rest of "#include" keyword
	call twsp
	jp nz,doinz

doinz2:	call getcef	;find filename argument
	call twsp
	jp z,doinz2

	IF CPM
	push af
	lda curdsk	;by default, new disk and user area
	sta newdsk	;are the same as current disk and user
	lda curusr	;area.
	sta newusr
	pop af
	ENDIF

	ld de,fnbuf	;copy name to buffer
	push de

	cp '"'		;ignore 1st char if quote
	jp z,doin1
	cp '<'
	jp nz,doin1a	;if angle bracket, assume a special directory is
			;to be searched (under CP/M, a disk and user area)
			;	<< Handle Angle Brackets now: >>
	IF CPM
	sta angleu	;note that angle bracket was found
	lda defdsk	;get default disk drive for file yanking
	cp 0ffh	;default to current?
	jp nz,doiny1	;if not, use as is

	lda origdsk	;get current disk drive when compiler invoked
;	lda curdsk	;if so, make it the new disk

doiny1:	sta newdsk

	lda defusr	;set new user area
	cp 0ffh	;default to current?
	jp nz,doiny2

	lda origusr	;get current user number when compiler invoked
;	lda curusr	;if so, make new user area the current one

doiny2:	sta newusr
	ENDIF	

doin1:	push de
	call getc	
	pop de
	jp c,closef

doin1a:	cp lf		;CR,LF,space,tab,", and > all terminate name.
	jp nz,doin1b
	push hl
	lhld sptr
	dec hl
	shld sptr
	pop hl
	jp doin2

doin1b:	cp cr
	jp z,doin2
	call twsp
	jp z,doin2
	cp '>'
	jp z,doin2
	cp '"'
	jp z,doin2
	ld (de),a
	inc de
	jp doin1


			;simplified 12/27/85
	IF 0
doin2:
	cp lf
	call z,bumpnl	;bump line count
	jp z,doin3
			;ignore rest of line, but treat a comment
			;as a special case because of lousy design...
doin20:	call getcsd
	cp '/'		;possible start of comment?
	jp nz,doin2	;if not, keep on throwing away the line
	call getcsd	;yes. next character
	cp '*'		;a star?
	jp nz,doin2	;if not, keep throwing line away...

doin2a:	call getcsd	;else look for closing comment characters, and preserve
	cp lf		;linefeeds.
	jp nz,doin2b	;a linefeed?
	call bumpnl
	lhld pndsav	;if so, store it and bump pointer...
	ld (hl),cr
	inc hl
	shld pndsav
	jp doin2a	;and go on processing comment
	
doin2b:	cp '*'		;possible end of comment?
	jp nz,doin2a	;if not, keep on scanning comment
	call getcsd	;yes...followed by a slash?
	cp '/'
	jp nz,doin2b	;if not, might have been a star...
	jp doin2	;else done with comment. go process rest of this line.


getcsd:	push de
	call getc
	pop de
	ret nc
	pop bc
	jp closef
	ENDIF

twsp:	cp ' '
	ret z
	cp 0ffh
	ret z
	cp 9
	ret

doin2:	
doin3:	xor a
	ld (de),a
	call pushf

	pop de		;check for explicit user area prefix on filename
	push de		;save ptr in case of no legal user number prefix
	call gdec	;test for decimal number (gdec sets Cy if none)
	jp c,doin3a	;if no prefix, don't futz with user number
	ld a,(de)		;check for trailing slash
	cp '/'
	jp nz,doin3a	;if none, not a legal user number
	ld a,b		;else it is. Make it the new user number
	sta newusr
	inc de		;bump text pointer past user number prefix
	pop hl		;discard pushed text pointer from stack
	jp doin3b	;and go process remainder of filename		

doin3a:	pop de		;under CP/M, set up default fcb with filename
doin3b:	ld hl,fcb
	call setfcb	;set up fcb, return Cy if explicit drive name given
	jp c,doin3d	;if explicit drive given, don't be intelligent...
			;at this point: no explicit drive name given. Only
			;allow the source file disk to determine new-disk for
			;the included file IFF no angle bracket was used...
	lda angleu	;was angle bracket used?
	or a		
	jp nz,doin3e	;if so, IGNORE default source disk (sdisk)
			;inserted by setfcb.
			;If no <...> used, allow sdisk to determine source disk
doin3d:	lda fcb		;see if explicit disk given in #include op
	or a		;if non-zero, an explicit disk was given,
	jp nz,doin3c	;	so go log that in as new current disk
	
doin3e:	lda newdsk	;if no disk designator given, set disk byte
	inc a		;with appropriately offset new disk value
	sta fcb	;TODO remove?

doin3c:	dec a		;change fcb-based disk code to BDOS call disk code
	sta newdsk
doin4:	;ld e,a
	;ld c,select
	;call bdos	;select disk

	lda curdsk	;save current disk and user area on stack
	push af
	lda curusr
	push af

	lda newdsk	;and set up new disk and user area for this file
	sta curdsk
	lda newusr
	sta curusr
	
	ld e,a		;select new user area

	IF NOT ALPHA
	;lda nouser
	;or a
	;jp nz,doin40	;skip setting user area if 'nouser' true
	;ld c,sguser 
	;call bdos
	ENDIF

	IF NOT CPM
	pop hl		;else put filename in HL
	shld fnam	;and save for pfnam printout (on error only)
	ENDIF


doin40:	lhld nlcnt	;save line count
	push hl

	lhld pndsav
	shld textp

	call readm	;read in the included file

	sta okflag	;save return condition from readm in okflag

	ex de,hl		;save HL in DE
	pop hl		;restore line count
	shld nlcnt
	shld atcnt	;match active text to current line number
	ex de,hl		;restore text ptr into HL

	pop af		;they were before the include file was being processed.
	sta curusr	;first the user number:
	push hl		;save HL during BDOS calls
	ld e,a

	IF NOT ALPHA
	;lda nouser
	;or a
	;jp nz,doin5a	;skip setting user area if 'nouser' true
	;ld c,sguser
	;call bdos
	ENDIF

doin5a:	pop hl		;pop HL so we can get at pushed psw...
	pop af		;and then set the current disk:
	sta curdsk
	;push hl		;save HL for BDOS call
	;ld e,a
	;ld c,select
	;call bdos	;select disk
	;pop hl		;restore HL after BDOS futzing

	call popf	
	lda okflag	;was the readm successful?
	or a
	jp nz,rm3		;if so, go on
	jp errab	;and  all done

;
; Get next char from current file, and go close file and return to
; caller one level higher if EOF encountered:
;

getcef:	call getc
	jp c,getcf2
	cp 1ah		;end of file character?
	ret nz
getcf2:	pop bc
	jp closef

;
; Get next character from current text input file:
;

getc:
	ex de,hl		;save text pointer in DE
	lhld sptr	;get sector pointer in HL
	inc hl		;bump it
	ld a,l		;exhausted current sector? look at low byte of ptr

	IF CPM	
	or a		;check for 00 (end of tbuff) under CP/M
	ENDIF

	jp nz,getc1
	call reads	;yes. read in next sector

	IF CPM
	ld hl,tbuff	;and reset sector pointer
	ENDIF

	IF NOT CPM
	ld hl,secbuf
	ENDIF

	ex de,hl		;put text pointer back in HL in case of return...
	ret c		;if EOF, restore textp into HL and return

	call ckov	;check HL for memory overflow
	ex de,hl		;put text ptr in DE, get sector pointer in HL

getc1:	ld a,(hl)		;get next char from sector buffer

stripp:	and 7fh		;strip parity -- substitute "nop-or a" for "and 7fh"
			;		to allow bit 7 to be high on input text
	shld sptr	;save sector pointer
	ex de,hl		;get back text pointer in HL
	ret


;
; Install current filespec (from default fcb) into text buffer at HL,
; and bump HL past the filename:
;

insrtm:	push bc
	push hl
	push de
	ld b,12
	ld de,fcb
	call ldrc
	pop de
	pop hl
	pop bc
	ret


pushf:	push hl
	push de
	ld c,0
	lhld fsp
	call ldstf
	shld fsp
	pop de
	pop hl
	ret

popf:	push hl
	push de
	ld c,1
	lhld fsp

	IF CPM
	ld de,-164	; 33 (fcb) + 128 (buffer) + 2 (ptr) + 1 (rederf) = 164
	ENDIF

	add hl,de
	shld fsp
	call ldstf	
	pop de
	pop hl
	ret

ldstf:
	IF CPM
	ld de,fcb
	ld b,33
	call ldram
	ld de,tbuff
	ld b,128
	call ldram
	ld de,sptr
	ld b,3
	call ldram
	ret
	ENDIF

	IF CPM		;set default FCB, return Cy set if explicit drive used:
setfcb:	ld b,8
	push hl
	inc de
	ld a,(de)
	dec de
	cp ':'
	lda sdisk	;default disk is disk source file came from
	scf
	ccf
	push af	;push Cy reset in case explicit disk not given
	jp nz,setf1
	pop af
	scf
	push af	;push Cy set, since explicit disk IS given
	ld a,(de)
	call mapuc
	sub '@'
	inc de
	inc de
setf1:	ld (hl),a
	inc hl
	call setnm
	ld a,(de)
	cp '.'
	jp nz,setfcb2
	inc de
setfcb2:ld b,3
	call setnm
	ld (hl),0
	ld de,20
	add hl,de
	ld (hl),0
	pop af		;restore return flag (Cy set if d: given)
	pop de		;restore fcb address in DE for BDOS call forthcoming
	ret

setnm:	push bc
setnm2:	ld a,(de)
	call legfc
	jp c,pad
	ld (hl),a
	inc hl
	inc de
	dec b	
	jp nz,setnm2
	pop bc
setnm3:	ld a,(de)
	call legfc
	ret c
	inc de
	jp setnm3

pad:	ld a,' '
	ld (hl),a
	inc hl
	dec b	
	jp nz,pad
	pop bc
	ret

legfc:	call mapuc
	cp '.'
	scf
	ret z
	or a
	scf
	ret z
	ccf
	ret

	ENDIF

reads:
	IF CPM		;read a sector of 128 bytes under CP/M
	push hl
	push de
	 ld de,0x0080
	 ld c,sdma
	 call bdos
	ld de,fcb
	ld c,rsequen
	call bdos
	or a
	pop de
	pop hl
	ret z ;ok, full sector
         cp 128 ;EOF in NedoOS
         jr z,reads_eof
;CP/M has eofs in the end of last sector?
;do this by hand:
;a=128+bytes loaded
        neg
;a=128-bytes loaded
        push de
        ld b,a
	ld de,0x0080+127	; Point to buffer end
        ld a,0x1a
        ld (de),a
        dec de
        djnz $-2
        pop de
        or a
        ret ;ok, not full sector
reads_eof
	;cp 1
	;jp nz,rds2 ;???
	scf ;error
	ret
	ENDIF

rds2:
	ld hl,stg4
	jp pstgab


kludge:	cp cr
	ld c,lf
	ret z
	cp lf
	ld c,cr
	ret z
	ld c,a
	ret

	;IF LASM
	;link ccd
	;ENDIF
