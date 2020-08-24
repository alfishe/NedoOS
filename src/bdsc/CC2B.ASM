
;
; cc2b.asm:
;
; Expression evaluator (code generator)
;  The text pointer is always assumed to be in HL
;  when evaluating expressions...
;
; Note that several of the high-level routines have
;  several entry points, some of which "force a value
;  result" (if the name ends with "v") and some that don't.
;  This is to allow optimization for expressions which don't
;  really need to produce a value; for example, the statement:
;		foo++;
;  obviously doesn't need to produce a result that was the old
;  value of foo, as if it were being used in a larger expression.
;  Thus, whenever possible, we try to detect stuff like this and
;  avoid needless code generation by using the appropriate entry
;  point within the expression evaluation routines.

;
; Top level expression evaluation entry point. Called
; from expression-statement processor only (never need return
; value when expression is entire statement):
;

exprnv:	xor a
	sta val		;allow optimizing for no ret val
	jp expr0

;
; General expression evaluator entry point from outside
; itself (i.e from within the statement processor as opposed to
; 	  from within expr itself):
;  Note that we might need a value here, if for example this
;  gets called from the "if" statement processor...
;

expr:	call ckabrt	;check for abortion of complilation
	ld a,1
	sta val		;we want a resulting value
expr0:	
	push hl		;save current line count for general error diagnosis
	lhld nlcnt
	shld savnlc
	pop hl

	call opsin	;initialize operator stack
	xor a
	sta faflg	;clear func-arg flag
	sta lflg	;clear logical-expr flag
	call expr1	;evaluate
	call igsht	;skip trailing gunk (white space)
	ret

;
; Recursive entry point. Handles:
;	expr
;	expr,expr (except when in fun arg list or 3rd ?: expr)
;
;	Upon entry, register A tells what we want:
;		00 = rvalue
;		01 = lvalue if possible
;		02 = must have lvalue
;	(this convention remains active down to many of the
;	 lower level routines also...)

;
; Special entry point to force value result:
;

expr1v:	ld b,a		;save old A value
	lda val		;and old val value
	push af
	or 01h		;force value result
	sta val
	ld a,b		;restore A value
	call expr1	;evaluate
	ld b,a		;save next char of text
	pop af		;restore old val value
	sta val
	ld a,b		;get back next char of text
	ret		;and done

;
; Normal entry point:
;

expr1:	push af

exp1a:	call expr2	;process expression
	lda faflg	;in arg list?
	or a		;if so, don't recognize comma operator
	jp nz,exp1b
			;process comma operator:
	call igsht	;no. check for , operator
	cp comma
	jp nz,exp1ay	;if none, go on
			;else process rest of comma expression:
	inc hl		;pass over the comma
	call rpshp	;reset push-op not to conflict with info from
	pop af		;get back result-type-needed flag     \first sub-expr
	push af
	call expr1	;call recursively to handle rest of comma expr
	call ppshp	;restore push-opt table

exp1ay:	call asgnop	;check for assignment operator (covers hole
	jp nz,exp1b	;	in expr syntax parser)
	ld de,stg8b
	jp perrab

exp1b:	pop af
	ret

;
; Secondary entry point...
; Handles:
;	expr
;	expr ? expr : expr
;

;
; Call this if we must generate a value
;

expr2v:	ld b,a
	lda val
	push af
	or 01h		;force value result
	sta val
	ld a,b
	call expr2
	ld b,a
	pop af
	sta val
	ld a,b
	ret

;
; Or call this if we don't care
;

expr2:	push af
	call pxpr3	;peek past binary expression
	cp qmark	;?: expression?
	jp nz,expr2a
	call ltabmp	;yes, bump logical branch table
	call expr3
	jp qexpr	;and go finish up in ?: handler

expr2a:	pop af
	push af
	call expr3
	pop af		;else done
	ret

;
; Little kludge routine to pass over simple and/or binary expressions:
;

pxpr3:	push hl		;save text ptr and line count
	lhld nlcnt
	ex (sp),hl
	push hl
pxpr3a:	call sexpas	;pass by simple expression
	call binop	;followed by binop?
	jp z,morpp3
	call igsht	;make sure we get next char in A
	pop hl		;no--all done
	ex (sp),hl		;restore text ptr and line count
	shld nlcnt
	pop hl
	ret

morpp3:	inc hl		;yes--pass it and keep scanning
	jp pxpr3a


;
; Handles:
;	sexpr binop sexpr
;	sexpr asgnop sexpr
;	sexpr
;
;	Note: "sexpr" means "simple expression", defined here as
;	      an expression having no binary, assignment, or ternary
;	      operators at the top level (although it may have them
;	      within parentheses)	

expr3:	push af
	call sexpasl	;peek at token past simple expr
	jp nc,expr3b	;carry from sexpasl indicates illegal
	pop af		;  simple expression: error.
	ret

expr3b:
	call binop	;binary operator?
	jp z,bexpr	;if so, go handle binary expression
	call asgnop	;assignment operator?
	jp nc,aexpr	;if so, go handle assignment expression
	cp qmark	; ?-: expr?
	jp nz,expr3a
	pop af		;yes. don't care if lvalue wanted
	lda val
	push af	;save old val
	ld a,1		;force value result, but don't force flag
	sta val		;   result to be converted to hard value
	xor a		;force rvalue of first expr
	call sgenv
	pop af
	sta val		;restore val
	ret

expr3a:	pop af		;not ?: expr.
	call sgen	;evaluate simple expression
	ret

sexpasl: push hl		;peek past sexpr to see next
	lhld nlcnt	;non-white-space character
	ex (sp),hl
	push hl
	call sexpas
	pop hl
	ex (sp),hl
	shld nlcnt
	pop hl
	ret


;
; Process simple (non-binary operator involved) expression
; of form:
;	* sexpr
;	& sexpr
;	- sexpr
;	! sexpr
;	~ sexpr
;	sizeof expr
;	pexpr	(primary expression)
;

;
; Recursive entry point to force value result:
;

sgenv:	ld b,a
	lda val
	push af
	or 01h
	sta val
	ld a,b
	call sgen
	ld b,a
	pop af
	sta val
	ld a,b
	ret

;
; Normal entry point:
;

sgen:	call sgen0
	call igsht
	ret

sgen0:	push af
	shld cdp	;update code buffer pointer

	xor a
	sta klujf	;clear short-cut-fetch-kludge flag

	call igsht	;check for unary ops
	cp mulcd	;indirection operator?
	jp nz,sgen3
	inc hl
	xor a
	call rpshp
	call sgenv	;yes. evaluate operand.
	call ppshp
	xor a
	sta value
	pop af
	push af
	or a		;need an address?
	jp nz,sgen2	;if so, don't gen indirection
	call t2dim	;else do. 2-dim array?
	jp z,sgen2a	;if so, generate no code
	call tptrf
	jp z,sgen2a	;same for ptr to func
	call tsptr	;simple ptr?
	jp z,sgen0a	;if so, go handle indirection
	call flshh1
	call maca0c	;else get value of ptr to ptr
	jp sgen2a	;and do internal indirection once only

maca0c:	push af
	lda optimf	;optimizing mem indirection?
	and 4
	jp z,maca0e
	ld a,0dfh	;rst3: ld a,(hl);inc hl;ld h,(hl);ld l,a;ret
	call genb
maca0d:	pop af
	ret
maca0e:	ld de,maca0
	call mcrog
	pop af
	ret

sgen0a:	lda typ1	;ptr to struct?
	and 7
	cp 6
	jp z,sgen2a	;if so, no code
sgen2:	call indir	;do internal indirection on data type
	ld a,1		;force a val result, so code such as: "*foo;" by itself
	sta val		;used to clear a memory-mapped status port, works.
	jp sgen8	;and wrap-up.

sgen2a:	call indir
	pop af
	ret

sgen3:	cp ancd	;address-of operator?
	jp nz,sgen4
	ld a,2		;if so, get address of operand
	inc hl		;now HL -> operand
	call rpshp
	call sgenv	;evaluate
	call ppshp
	call tptrf	;ptr to func?
	jp z,sgen3b	;if so, obscure.
	call tstar	;array?
	jp z,sgen3b	;if so, we can't represent it. just smirk.
	lda indc1	;else bump indirection count
	inc a
	sta indc1
sgen3b:	pop af		;we don't care what was asked for here.
	ret

sgen4:	cp mincd	;minus operator?
	jp nz,sgen5
	inc hl
	xor a
	call rpshp
	call sgenv	;yes. eval argument
	call ppshp
	pop af
	call ckvok	;make sure we don't need lvalue
	call tcnst1
	jp nz,sgen4a	;constant?
	push hl		;yes...
	lhld svv1
	call cmh
	shld svv1
	pop hl
	ret

sgen4a:	call flshh1
	call tschr	;simple char value to negate?
	ld de,mac0e
	jp nz,mcrog	;if not, assume a 2 byte value
	ld de,mac01	;else character. turn into "int"
	ld a,1
	sta typ1
	jp mcrog	;and negate.

sgen5:	cp notcd	;logical negation?
	jp nz,sgen6

	pop bc		;get saved value code
	lda notklg	;save notkludge
	push af
	push bc		;and push saved value code back on stack

	xor a
	sta notklg	;by default, no notkludge is to be performed

	inc hl		;bump txt ptr to arg of !
	call igsht	;check for "(" for a special case...
	cp open
	jp nz,sgen5z	;if not, go handle normally
	lda val
	or a
	jp sgen5z	;if don't need value, also go handle normally
	ld a,81h
;	sta val		;turn into high force factor 
	sta notklg	;set "notkludge" flag

sgen5z:	lda val		;get result-type-needed flag
	cp 81h		;if we need a value, then make sure we don't jump
	call z,ltabmp	; out of range of the following expression

	call ltbflp	;flip ltab label entries and used bit bits. (No effect
			;if a value is needed, since both T & F addrs are same)
	xor a
	call rpshp
	call sgenv
	call ppshp
	call ltbflp	;flip ltab entries back to normal (if val is false)
	call ckaok	;make sure arg is val or ptr

	lda val
	cp 81h		;was a value needed?
	jp nz,sgen50	;if not, don't clean up the range restriction
	call ltabtd	;otherwise clean up possible jump references
	call ltabfd
	call ltabpp

sgen50:	pop af
	call ckvok	;details, details.

	call tcnst1	;was expr a constant?
	jp nz,sgen5a
	push hl		;yes. invert the logic.
	lhld svv1
	ld a,h
	or l
	jp z,sgn50a
	ld hl,-1
sgn50a:	inc hl
	shld svv1
	pop hl
	pop af		;restore notkluge
	sta notklg
	ret

sgen5a:	lda notklg	;was notkludge flag set?
	or a
	jp z,sgen5y	
			;OK--now we have to explicitly force into HL the value
			;that resulted from the expression...
	pop af
	sta notklg	;first restore the kludge flag

	lda sval1	;result a flag setting?
	and 4
	jp nz,sgn5ba	;if so, make sure not to flush it!

	jp sgen5b	;otherwise don't skip the flushing business.

sgen5y:	pop af		;restore old notkludge flag
	sta notklg

	lda sval1	;was result of expr a flag being set?
	and 4	
	jp z,sgen5b

	lda sbmap1	;yes. simply invert the logic of the flag setting
	xor 1
	sta sbmap1
	lda val		;absolutely need value?
	cp 81h
	ret nz
	lda sval1	;if so, make sure we convert current flag setting
	and 0dfh	;into an absolute value
	sta sval1
	call cvtlvh
	ret

sgen5b:	
	call flshh1
sgn5ba:	call tschr	;character argument?
	ld de,mcn11	;"ld a,l - or a"
	jp nz,sgen5c
	lda typ1	;if so, make into int
	inc a
	sta typ1
	jp sgen5d
sgen5c:	ld de,mcn10	;else int.
sgen5d:	call mcrog
	lda sval1	;tell that flag is now set
	or 4
	sta sval1
	xor a		;flags: Z true
	sta sbmap1
	lda val		;need a REAL value in HL?
	or a
	ret p		;if not, all done.
	ld de,macf1	;else gen call to routine to set HL to 1 if
	call mcrog	;Z is true
	lda sval1
	or 20h		;tell that value is in HL as well as in flags
	sta sval1
	ld a,1
	sta typ1
	ret

ltbflp:	push hl		;hack routine to flip the true and false ltab
	push bc		;entries, so that the not operator is real efficient
	lhld ltabp
	ld de,-5
	add hl,de		;get HL pointing to start of current ltab entry
	ld e,(hl)		;get true entry in DE
	inc hl
	ld d,(hl)
	inc hl
	push de		;save it on stack
	ld e,(hl)		;get false entry in DE
	inc hl
	ld d,(hl)
	inc hl
	ld a,(hl)		;get flag byte
	call flpa	;flip bits 0 and 7 of flag byte
	ld (hl),a		;save it back
	dec hl
	pop bc		;put back true entry where false entry was
	ld (hl),b
	dec hl
	ld (hl),c
	dec hl
	ld (hl),d		;and put back false entry where true entry was
	dec hl
	ld (hl),e
	pop bc
	pop hl
	ret
;
; Switch bits 0 and 7 of the value in A:
;

flpa:	ld b,0
	or a		;is bit 7 on?
	jp flpa2
	inc b
flpa2:	and 1		;is bit 0 on?
	ld a,b
	ret z		;if not, return with b7 of result off also
	or 80h		;else turn on b7 of result
	ret

sgen6:	cp circum	;bitwise negate?
	jp nz,sgen7
	inc hl
	xor a
	call rpshp
	call sgenv
	call ppshp
	call ckval	;you get this all by now, right?
	pop af
	call ckvok
	call tcnst1
	jp nz,sgen6a
	push hl
	lhld svv1
	call cmh
	dec hl
	shld svv1
	pop hl
	ret

sgen6a:	call flshh1
	call tschr
	ld de,mac1b
	jp nz,mcrog
	ld de,mac1a
	jp mcrog	;was 'jp sgen5a'...why?

sgen7:	cp sizcd	;sizeof?
	jp nz,sgen7b
	pop af		;clean up stack
	inc hl
	lda codflg
	push af
	xor a
	sta codflg	;don't generate any code while doing this
	ld a,1		;get lvalue if possible
	call sgenv
	pop af
	sta codflg	;restore code generation flag
	push hl
	call analyz	;set asize equal to size of object
	lhld asize
	call tptr	; was it a pointer?
	jp nz,sgen7a
	ld hl,2		;if so, size is always gonna be 2 bytes
sgen7a:	shld sr0
	shld svv1
	ld hl,100h	;set indc1 to 0 and typ1 to 1
	shld indc1
	dec h
	shld dimsz1	;and zero dim size
	pop hl
	ld a,1
	sta sval1	;make result a constant
	ret
	
sgen7b:	pop af		;well... no unary operator. must be
	push af	;just a plain ole' primary expr
	call rpshp
	call primg	;evaluate it
	call ppshp

sgen8:	pop af		;need address?
	cp 2
	jp nz,sgen8a
	call analyz	;yes. Let's see if we got one...
	lda aadrf
	or a
	ret nz		;if so, all ok.
	ld de,stg8	;else look out!
	jp perr

sgen8a:	ld b,a		;address not mandatory.
	lda val		;need we bother with value?
	and 1
	ret z		;if not, we don't.
	lda value	;pre-processed value?
	or a
	ret nz		;if so, leave it alone
	call tsval	;else...simple value?
	ret z		;if so, fine.
	ld a,b
	dec a		;else, is an lvalue OK?
	ret z		;if so, done
	call tsptr	;simple pointer?
	jp z,sgen8c	;if so, OK.
	call tstar	;array?
	jp z,sgen8c	;that's OK too.
	call tsstr	;structure?
	ret z		;if so, just grin and bear it {It MIGHT
			; be something like (foo).bar}
			;is it a function? (i.e., a function name
	call tfun	;without being a call or having addr taken?)
	ret z		;if so, leave it alone.

sgen8c:	call tptrf	;ptr to func?
	jp z,sgen8g

	call tstar	;array?
	jp nz,sgen8d

	lda frml1	;yes. formal array?
	or a
	ret z		;if not, all done.
	xor a		;else make it NOT formal
	sta frml1	;and indirect to get real base addr
	jp sgen8g

sgen8d:	call tptr	;pointer?
	jp z,sgen8g	;if so, 2 byte indirect

	xor a		;else must be simple lvalue.
	sta indc1	;make it an rvalue
	call tschr	;char?
	jp nz,sgen8g	;if not, do full 2 byte indirection

;
; handle a character lvalue indirection:
;

	lda sval1	;external char?
	and 8
	jp z,sgn8d4	;if not, don't bother with kluge-fetch

	lda sval1	;yes.
	and 1		;abs lvalue?
	jp z,sgn8d3	;if not, go do call hack

sgn8d9:	ld de,mac40	;yes. do lhld sr0, even tho we only need a char
	push hl		;get address, stick in sr0
	lhld svv1
	shld sr0
	pop hl
	call mcrog
	xor a
	sta sval1
	ret


sgn8d3:	lda optimf	;optimize for space?
	or a
	jp z,sgn8d4	;if not, go do normal speed optimization

	lda sval1	;do we have a const lvalue to do it on?
	and 3
	jp nz,sgn8d5	;if so, go do it

			;no.
sgn8d4:	call flshh1	;generate address of char, the hard way
	ld a,6eh	;do an indirection
	call genb
	xor a
	sta sval1	;all done
	ret

sgn8d5:	lda svv1+1
	or a
	jp nz,sgn8d7	
	ld de,ssei
sgn8d6:	ld a,0cdh
	call genb
	call addccc
	call gende
	jp sgen8j

sgn8d7:	ld de,lsei
	jp sgn8d6

sgn8d8:	call genb
	jp sgen8j	


;
; Handle 16 bit lvalue indirection:
;

sgen8g:	lda sval1	;if we have abs external object, always use lhld
	and 1
	jp nz,sgn8d9

	lda optimf	;not abs external; ok to do c.ccall c,fetch optimization?
	or a
	jp z,sgn8g0	;if so, go deal with it

	lda sval1	;ok to optimize for space, if an lvalue const
	and 3		;is it an lvalue constant?
	jp nz,sgn8g1	;if not, go do the hard way

sgn8g0:	call flshh1	;else get address the hard way
	call maca0c	;and do hard indirection
	ret

sgn8g1:	lda sval1	;external variable?
	and 8
	jp z,sgn8g3

	lda svv1+1
	or a
	jp nz,sgn8g2

	ld de,sdei
	jp sgn8d6

sgn8g2:	ld de,ldei
	jp sgn8d6

sgn8g3:	lda svv1+1	;short or long displacement?
	or a
	jp z,sgn8g4
	ld de,ldli
	lda optimf
	and 20h
	jp z,sgn8d6
	ld a,0f7h	;rst 6: jp ldli
	jp sgn8d8

sgn8g4:	ld de,sdli
	lda optimf
	and 10h
	jp z,sgn8d6
	ld a,0efh	;rst 5: jp sdli
	jp sgn8d8


sgen8j:	lda svv1	;now generate displacement.
	call genb	;always do low order byte.
	lda svv1+1	;but do high-order only if non-zero.
	or a
	call nz,genb
	xor a
	sta sval1
	ret


gende:	push de		;generate code equal to DE:	
	ld a,e	
	call genb
	pop de
	ld a,d
	call genb
	ret

	
addccc:	push hl
	lhld cccadr
	add hl,de
	ex de,hl
	pop hl
	ret


;
; Evaluate primary expression of form:
;	++pexpr
;	--pexpr
;	pexpr++
;	pexpr--
;	pexpr[expr]
;	pexpr(arg list opt)
;	pexpr.identifier
;	pexpr->identifier
;	spexpr	(i.e, simple primary expr)
;
;  Note that whenever possible, this routine generates the
;  address of the object. Only special cases like constants
;  and functions may evaluate to constant values.
;

primg:	ld c,a
	xor a
	sta value	;clear pre-processed-value flag
	sta indc1
	sta frml1
	sta klujf
	sta sbmap1
	xor a
	sta sval1
	push hl
	ld hl,0
	shld svv1
	shld dimsz1	;clear array size
	pop hl
	call igsht
	cp pplus	;leading ++ ?
	ld b,0
	jp z,prmg2a
primg2:	cp mmin	;leading -- ?
	jp nz,primg3
	ld b,2		;yes.
prmg2a:	push bc
	inc hl
	ld a,2
	call sgenv	;evaluate the lvalue
	pop bc	
	call tsclv	;if character lvalue,
	jp z,prmg2b	;  always get address into HL before doing ++ or --
	lda sval1	
	and 1
	jp nz,prim30	;if abs external lvalue, DON'T flush addr into HL
	
prmg2b:	call flshh1	;flush to get lvalue in HL if not abs external non-char
	jp prim30	;and perform the ++ or -- operation

primg3:	call sprimg	;process simple primary expr
primg4:	call igsht	;check for primary expr op
	cp open	;function call?
	jp z,primf
	cp openb	;subscripting?
	jp z,primb
	cp period	; . ?
	jp z,primp
	cp arrow	; -> ?
	jp z,prima
primg6:	call igsht
	cp pplus	;trailing ++ ?
	jp nz,primg7
	ld b,1
	jp primg8

primg7:	cp mmin	;trailing -- ?
	jp z,prmg7a

	cp varcd	;primary expression followed by a name? if not,
	ret nz		;all done with this primary expression.
	
	ld de,s4	;probably a missing semicolon
	call perrsv
	ret
	
prmg7a:	ld b,3
primg8:	inc hl
	call tsclv	;if simple character lvalue, always flush addr	
	jp z,primg9
	lda sval1	;if abs external lvalue, DON'T flush
	and 1
	jp nz,prmg10
	
primg9:	call flshh1	;flush into HL for prim30
prmg10:	call prim30	;yes. perform post-decrement
	jp primg4




;
; Evaluate simple primary expression of form:
;	(expr)
;	string constant
;	numeric constant
;	identifier (variable name, that is)
;

sprimg:	call igsht
	cp open	;left parenthesis?
	jp nz,sprms
	ld b,c
	call sprmp	;yes. process expr in parens
	call igsht
	ret

;
; Process expression in parentheses:
;

trbnop:	ds 1		;trailing-binop flag, for use by sprmp

sprmp:	lda faflg	;save old fun-arg flag
	push af
	lda trbnop
	push af	;save trailing binop flag
	xor a
	sta faflg	;clear fun-arg flag
	sta trbnop	;clear trailing binop flag
	lda val
	push af
	push hl		;peek after (), looking for a primop
	lhld nlcnt
	ex (sp),hl
	push hl
	call mtchp
	call igsht
	cp pplus
	jp z,sprmp2
	cp mmin
	jp nz,sprmp3
sprmp2:	lda val		;we found a ++ or --; force lvalue result
	or 1		;and thus force value result
	sta val
	ld a,2
	jp sprmp6

sprmp3:	push bc
	call binop	;() followed by binary operator?
	pop bc
	jp nz,sprmp4
	call lbinop	;yes...if logical, don't worry about it
	jp z,sprmp4
	call ltabmp	;not logical. bump ltab,
	ld a,81h
	sta val		; and force value result
	sta trbnop	;set trailing binop flag (so that
	ld a,b		;restore evaluation code
	jp sprmp6	; ltab will be popped later)

sprmp4:	call primop
	ld a,b		;if other primop
	jp nz,sprmp6
	lda val
	or 1
	sta val		;force result
	xor a		;get rvalue no matter what

sprmp6:	pop hl
	ex (sp),hl		;restore text pointer and line count
	shld nlcnt	;to what they were before the
	ex (sp),hl		;peek-ahead
	inc hl
	call expr1	;evaluate inside of parens
	pop de
	pop af
	sta val		;restore old val
	lda trbnop	;trailing binop flag set?
	or a
	jp z,sprmp7

	call ltabtd	;if so, define true and false ltab entries
	call ltabfd
	call ltabpp	;and pop off the ltab entry

sprmp7:	pop af
	sta trbnop	;restore former trailing binop flag
	pop af
	sta faflg	;restore old fun arg flag
	push de
	call igsht
	cp close	;check for matching )
	jp z,sprmp8
	ex (sp),hl		;if none, error.
	push hl
	lhld nlcnt
	ex (sp),hl
	shld nlcnt
	ld de,stg9
	call perr
	pop hl
	shld nlcnt
	pop hl
	call psemi
	ret

sprmp8:	pop de		;wrap up
	inc hl
	ld a,1	
	sta value
	ret

;
; If string constant, put string in-line, generate a 
; pointer to it and a jump around it:
;

sprms:	cp strcd	;string constant?
	jp nz,sprmc
	xor a		;yes. make type "pointer to chars"
	sta typ1
	ld a,2		;and set up other type info
	sta indc1
	sta value
	inc hl		;get the string code number in DE
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push hl		;save text pointer
	lhld stgad	;now search for the given string in the string pool
sprms1:	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	ld a,b
	cp d
	jp nz,sprms2
	ld a,c
	cp e
	jp z,sprms3	;found string code match?
sprms2:	push de		;no. try next string in pool
	ld e,(hl)
	ld d,0
	inc de
	add hl,de
	pop de
	jp sprms1

sprms3:	push hl		;found string. check for folding potential and
	call entstr	;enter into table if a new unique string...
	pop hl
	jp c,sprms4	;was the table out of space?
	ex de,hl		;no. put label code for the string into HL
	shld sr0
	ld de,mac98a	;ld hl,sr0 (with a forward reference)
	call mcrog
	pop hl		;restore text pointer
	ret		;all done

sprms4:	push hl		;generate ld hl,foo - jp bar - foo: <text>,0 - bar:
	call glbl	;set up some symolic labels
	shld sr0
	call glbl
	shld sr1
	ld de,mac98
	call mcrog
	pop hl
	ld b,(hl)		;found it. B holds length; now generate the
sprms5:	inc hl		;string characters.
	ld a,b
	or a
	jp z,sprms6	;done?
	ld a,(hl)		;no. generate next byte
	call genb
	dec b
	jp sprms5	;and go for more

sprms6:	xor a		;generate trailing null byte
	call genb
	lhld sr1	;and define the symbolic label
	ex de,hl		;at the end of the string (this is the object
	call entl	;of the jump after the ld hl,string instruction
	pop hl
	ret

entstr:	push hl		;calculate label code for a new string
	ld hl,strtb	;if already in table, return old code, else enter it.
ntstr0:	ld e,(hl)		;get next label # from table into DE
	inc hl
	ld d,(hl)
	inc hl
	ld a,d		;end of table?
	or e
	jp nz,ntstr0

	push hl		;yes. check to see if table is full
	push de
	call cmh	;HL := -(table pointer)
	ld de,strtb+strsz
	add hl,de		;calcualate (end - current_pointer)
	pop de
	ld a,h
	pop hl
	or a		;overflow?
	jp ntstr1
	pop hl		;yes.
	scf		;return carry
	ret

ntstr1:	ex de,hl		;there is room for another entry
	call glbl	;get new label code
	ex de,hl		;put into DE
	dec hl
	ld (hl),d		;enter label code in table
	dec hl
	ld (hl),e
	inc hl
	inc hl		;now enter pointer to text
	pop bc		;which was on the stack
	ld (hl),c
	inc hl
	ld (hl),b
	inc hl		;and clear next field as end flag
	xor a
	ld (hl),a
	inc hl
	ld (hl),a
	ret		;all done.


	IF 0		;disable string-folding, since it isn't standard...

ntstr2:	ld c,(hl)		;compare current table entry with given text
	inc hl
	ld b,(hl)		;BC :=  --> current table entry text
	inc hl
	ex (sp),hl		;HL := new string entry being processed
	push hl		;save the starting addr of the label
	push de		;save the label code
	ld a,(bc)		;check length bytes against each other
	cp m
	jp z,ntstr4	;same length?
ntstr3:	pop de		;no, so a mismatch right off.
	pop hl
	ex (sp),hl		;restore stuff for another try
	jp ntstr0

ntstr4:	ld d,a		;ok, lengths match. now compare text
	inc d		;D holds char count
ntstr5:	dec d		;done?
	jp nz,ntstr6
	pop de		;yes...we have a match. use old label code (in DE now)
	pop hl
	pop hl		;restore HL
	ret		;and done

ntstr6:	inc bc		;keep on comparing the two strings
	inc hl
	ld a,(bc)
	cp m
	jp z,ntstr5	;still matching? if so, keep going.
	jp ntstr3	;no. go on to next entry

	ENDIF


;
; If numeric consant, generate "ld hl,whatever"
;

sprmc:	cp concd	;constant?
	jp nz,sprmv
	inc hl		;yes. get the value in DE
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl		;generate ld hl,value
	shld svv1
	ex de,hl
	ld a,1		;make type integer
	sta typ1
	sta sval1	;make it a constant
	call igsht
	ret

;
; Process an identifier. If not an identifier, error.
;

sprmv:	cp varcd	;identifier?
	jp z,sprmv2
	ld de,stg10	;no. At this point it can't be anything
	call perrsv	;else except an error. Find the next semicolon
	call fsemi	;and attempt to keep going from there.
	ret

sprmv2:	call lookup	;look up the identifier in the symbol table.
	ex de,hl
	shld sr0	;save displacement for later code generating use
	shld svv1
	ex de,hl		;and leave in DE also
	lda typ1	;is it a struct or union element?
	and 80h
	jp z,sprmv3
	ld de,stg20	;if so, error.
	call perr
sprmv3:	lda typ1	;is it a function?
	and 40h
	jp z,sprmv5
	sta simpf	;yes. set "simple function" (as opposed to a pointer
	lda indc1	; to a function) flag. Then fudge the indirection
	or a		; count if necessary.
	jp z,sprmv4
	inc a
	sta indc1
sprmv4:	call igsht	;followed by an open paren?
	cp open
	ret z		;if so, is a simple function and may be ignored.
	push hl		;else is not so simple.
	lhld dimsz1	; used to generate ld hl,addr; NOW generate:
	inc hl		;		lhld addr+1
	shld sr0
	ld hl,0
	shld dimsz1
	ld de,mac40r	; lhld sr0 (relocated)
	call mcrog
	pop hl
	xor a		;and reset the simple function call flag.
	sta simpf
	ret

sprmv5:	call tptrf	;pointer to func?
	jp z,sprv5a	;if so, don't touch indir count
	lda indc1	;else do.
	inc a
	sta indc1
sprv5a:	ld a,2
	sta sval1
	lda vext	;external?
	or a		;if not, all done
	ret z

	ld a,0ah	;yes; make it external and an lvalue
	sta sval1	;set the external bit.
	lda eflag	;absolute external mode enabled?
	or a
	ret z		;if not, all done

	push hl		;if absolute externals enabled,
	lhld exaddr	;get the base address
	add hl,de		;add to offset
	shld svv1	;and make that the value
	ex de,hl		;leave it in DE also
	pop hl
	ld a,0bh	;now: external, an lvalue, and a constant!
	sta sval1	
	ret

genllv:	push hl
	lhld sr0
	ld a,h
	or l
	pop hl
	jp z,genlv2
	ld de,mac41
	call mcrog
	ret

genlv2:	ld a,60h	;if has local displacement of zero,
	call genb	;can skip the "ld hl,disp add hl,bc" and
	ld a,69h	;just do a "ld h,b  ld l,c" instead.
	call genb	;(a little optimization here, a bit there...)
	ret

;
; Process subscript expression (on entry, HL -> "[")
;

primb:	call analyz	;check for pointer base
	lda amathf	; (weed out illegal bases)
	or a
	jp z,prmb2a
	call tstar	;array?
	jp z,prmb1	;if so, not pointer base.
	lda value	;pre-processed value?
	or a
	jp nz,prmb1
	call tptr	;no. pointer?
	jp nz,prmb1
	call indnoc
prmb1:	xor a
	sta value
	inc hl
	lda frml1
	or a
	jp z,prmb2
	call tstar
	jp nz,prmb2
	call indnoc
	xor a
	sta frml1

prmb2:	call tptr
	jp z,prmb3
prmb2a:	ld de,stg16	;illegal array base error
	call perr

prmb3:	ex de,hl
	lhld indc1
	push hl
	lhld dimsz1
	push hl
	lhld strsz1
	push hl
	lhld asize
	push hl
	lhld sval1
	push hl
	lhld svv1
	push hl
	ex de,hl
	lda faflg
	push af
	xor a
	sta faflg
	call tcnst1
	call z,rpshp
	call nz,spshp
	xor a
	call expr1v	;evaluate subscript
	lda sval1
	sta ssval
	and 1
	call z,flshh1	;if not constant, flush subscript
	xor a
	sta value
	pop af
	sta faflg
	xor a
	sta frml1
	call tsval
	lda typ1
	ex de,hl
	lhld svv1
	shld subval
	pop hl
	shld svv1
	pop hl
	shld sval1
	pop hl
	shld asize
	pop hl
	shld strsz1
	pop hl
	shld dimsz1
	pop hl
	shld indc1
	ex de,hl
	jp z,prmb4
	ld de,stg15
	call perr
	inc hl
	jp primg4

prmb4:	push hl
	push af
	lda ssval
	and 1		;was subscript a constant?
	jp z,prmb4b
	call ppshp	;yes.
	lda sval1	;is base a constant too?
	and 3
	jp z,prmb4a
	lhld asize	;yes; entire expression can be constant
	call mult
	ex de,hl
	lhld svv1
	add hl,de
	shld svv1
	pop af
	jp prmb6d

prmb4a:	pop af
	lhld asize	;we have const subscript, but NOT constant base
	call mult	;entire subscrip expr can be a constant
	push hl		;..add it to the base.	
	call flshh1	;generate code for the base
	pop de
	call maddd	;and code to add subscript to it
	jp prmb6c	;and go wrap up

prmb4b:	pop af		;NOT constant subscript; has been flushed into HL
	or a		;char value?
	jp nz,prmb5
	ld de,mac61	;yes, clear H
	call mcrog

prmb5:	lhld asize	;get final subscript value into HL
	call gnmulh	;gen code to mult HL by asize
	call ppshp
	call tcnst1	;was base a constant lvalue?
	jp z,prmbts	;if so, go handle that scwewy case.
			;this stuff commented out for now; perhaps forever.

	call gpopd	;gen code to pop base into DE

prmbad:	ld a,19h	;"add hl,de"
	call genb

prmb6c:	xor a		;result in HL
	sta sval1

prmb6d:	pop hl		;clean up.
	inc hl
	call indir
	jp primg4

indnoc:	call flshh1
	call maca0c
	ret

prmbts:	lhld svv1
	shld sr0
	lda sval1
	and 8
	jp nz,prbts2
	call gexdehl	;'ex de,hl' subscript into DE
	call genllv
	jp prmbad

prbts2:	lda sval1
	and 1
	jp z,prbts3
	ld de,mac0c
	call mcrog
	jp prmb6c

prbts3:	ld a,h		;save adjusted subscript on stack, unless base 
	or l		; address of array is zero...
	call nz,gpushh	;either save adjusted subscript 
	call z,gexdehl	;or just put it in DE for a while
	ld de,mac6a
	call mcrog	;do 'lhld extbas'
	ex de,hl		;add relative external address to extbas
	push de
	call maddd
	pop hl
	ld a,h
	or l		;now, if subscript was pushed on the stack,
	call nz,gpopd	;get back adjusted subscript (else don't)
	jp prmbad	;and go add it


;
; Process function call:
;

primf:	call tfun	;was thing before '(' a function?
	jp z,prmf2
	ld de,stg11	;if not, error.
	call perr
	call mtchp
	jp primg4

prmf2:	xor a
	sta argcnt	;clear arg count
	lda simpf	;OK...is it a simple function call?
	or a
	jp z,prmf4
	call sargs	;yes. process args
	ld de,mac08	;generate "call" op

prmf3:	call mcrog

	lda argcnt	;now restore stack. more than 6 args?
	cp 7
	jp c,prmf3a

	push hl		;yes. use the long sequence.
	ld l,a
	ld h,0		;HL = argcnt
	add hl,hl		;HL = # of bytes of stack used
	shld sr0
	pop hl
	ld de,mac8ar	;long code sequence to reset SP
	call mcrog	
	jp prmf3c

prmf3a:	ld b,a		;save count in B
	inc b
prmf3b:	dec b
	jp z,prmf3c
	call gpopd	;"pop de" for each arg
	jp prmf3b	

prmf3c:	lda typ1	;set type of returned value
	and 0bfh
	sta typ1
	ld a,1
	sta value
	call igsht
	jp primg4

prmf4:	call flshh1
	call gpushh	;handle non-simple function call
			;gen code to push func address
	call sargs	;process args
	lda argcnt	;bump arg count to account for pushed func addr
	inc a		;   later when we reset the SP after returning
	sta argcnt	

	push hl		;generate code to retrieve function addr we
	ld l,a		;pushed before processing args.
	ld h,0
	add hl,hl		
	shld sr1	;special displacement needed by mac8a
	pop hl

	ld de,mac8a	;special non-simple function call code sequence
	jp prmf3

; 
; Process function argument list:
;

sargs:	ex de,hl		;save HL
	lhld dimsz1
	push hl
	lhld indc1
	push hl
	lhld strsz1
	push hl
	lhld sval1
	push hl
	lhld svv1
	push hl
	lda simpf
	push af

	ex de,hl		;restore HL

;
; Now push the beginning address of the text of each function
; argument: (# of addresses pushed will end up in argcnt)
;

srgs0:	inc hl
srgs1:	call igsht
	cp close
	jp z,srgs3	;if end of arg list, go backtrack and evaluate...

srgs2:	push hl		;else another arg to push text address of.

	ex de,hl		;save text ptr in DE
	lhld nlcnt	;save the line number associated with the arg text
	push hl
	ex de,hl		;restore text ptr

	push bc
	lda argcnt
	inc a
	sta argcnt
			;pass over an arg. This is much neater than the old
	call pasarg	;way of disabling code generation and evaluating the
			;arg!
	pop bc
	call igsht
	cp comma	;arg followed by comma?
	inc hl
	jp z,srgs2	;if so, bump text pointer and look for more args
	dec hl		;else look for close paren

srgs2a:	cp close
	call nz,plerr	;if not followed by a close paren, error

srgs3:	push hl
	lhld nlcnt
	shld savcnt	;save line count for end of list
	pop hl

;
; Now, for each saved address, generate the code for
; the argument and push it:
;

srgs4:	shld savtxt	;save text pointer to end of list

	lda argcnt	;get arg count	
srgs5:	or a
	jp z,srgs6	;done?
	push af	;save argcount
	call igsht	;if not, we'd better be staring at a comma!
	cp comma
	jp z,srgs5a
	cp close
	call nz,plerr	;tell about it if we aren't
srgs5a:	pop af		;get back argcount
	pop hl		;restore the line number matching the arg
	shld nlcnt
	pop hl		;get text of previous arg and evaluate
	push af	;save argcnt

	lda val
	push af	;save current state of val
	or 81h		;force value result even for logical expressions
	sta val
	call doarg
	call igsht
	pop af
	sta val		;restore former state of val

	lda sval1
	and 0c0h
	call z,gpushh	;generate "push hl" if value in HL
	call nz,gpushd	;else "push de" is called for

	pop af		;get back argcnt
	dec a		;de-bump
	jp srgs5	;and go do next arg	

;
; Come here to diagnose a parameter list error:
;

plerr:	ld de,stgbf	;else must've been a parameter list error
	call perr
	call fsemi
	dec hl
	ret

;
; This routine passes over the text of a function arg--all parens,
; brackets get matched, and first comma or close paren at upper
; level terminates the scan.
;

pasarg:	call pascd2	;ignore codes and cruft
	cp openb	;if [,
	jp nz,pasrg2
	call mtchb	;find matching ]
	jp pasarg	;and go on

pasrg2:	cp open	;if (,
	jp nz,pasrg3	;find matching )
	call mtchp
	jp pasarg	;and go on

pasrg3:	cp comma	;if comma
	ret z		;found end
	cp close	;same for top level )
	ret z
	call badxch	;is character OK in an expression?
	ret c		;return w/carry set if no good
pasrg4:	inc hl		;else scan to next character
	jp pasarg

;
; Return C set if keyword code in A is illegal within an expr:
;

badxch:	cp semi	;semicolon no good
	scf
	ret z
	cp sizcd	;sizeof OK
	ret z
	cp rbrcd+2	;if <= maincode, no good
	ret

;
; Restore everything and prepare to generate calling sequence:
;

srgs6:	pop af
	sta simpf
	lhld savcnt	;get line count for end of list
	shld nlcnt	;resotre as current count
	pop hl
	shld svv1
	pop hl
	shld sval1
	pop hl
	shld strsz1
	pop hl
	shld indc1
	pop hl
	shld sr3
	ld hl,0
	shld dimsz1
	lhld sfsiz
	shld sr0
	call glbl
	shld sr2

	lhld savtxt	;get back text pointer
	inc hl
	ret

;
; Process the arg at HL, either generating code or not depending
; on the state of codflg:
;

doarg:	lda faflg	;bump funarg flag so commas are treated
	inc a		;as terminators instead of operators.
	sta faflg

	lda argcnt
	push af

	ex de,hl
	lhld savtxt
	push hl
	lhld savcnt
	push hl
	lhld nlcnt	;save nlcnt of START of arg for error reports
	push hl
	ex de,hl

	call rpshp
	call ltabmp	;bump ltab, to keep logical branches from escaping
	xor a		;evaluate arg
	call expr1v
	
	call igsht	;make sure arg is followed by comma or close paren
	cp comma
	jp z,doarg1	;if comma, OK
	cp close

	ex de,hl		;get nlcnt that was valid at START of arg, so error
	pop hl		;report points to beginning of illegally-terminated
	shld nlcnt	;parameter
	push hl
	ex de,hl

	call nz,plerr	;if nor comma or close paren, complain

doarg1:	call ltabfd	;come here whether false
	call ltabtd	;		of true
	call ltabpp	;value results from arg expression
	call ppshp

	lda sval1	;if a constant,
	and 3
	call nz,flshh1	;flush into HL
			;else might be in either HL or DE
	ex de,hl		;restore state
	pop hl		;clean up stack (pushed nlcnt earlier)
	pop hl
	shld savcnt
	pop hl
	shld savtxt
	
	ex de,hl

	pop af
	sta argcnt

	call tschr	;and generate code to zero high byte 
	jp nz,doarg2	;if arg is a char
	lda sval1	;clear H if value in HL
	and 0c0h
	ld de,mac61
	call z,mcrog
	ld de,mac62	;else clear D
	call nz,mcrog

doarg2:	lda faflg	;reset funarg flag to handle commas correctly
	dec a
	sta faflg
	ret

;
; Handle -> operator:
;

prima:	inc hl
	call analyz
	call tptrf
	jp z,prmae	;ptr to func no good as base
	lda amathf
	or a
	jp z,prmae	;base no good if can't do math on it
	lda aadrf	
	or a
	jp z,prma2	;if not an address, don't need to indirect
	lda avar
	or a
	jp z,prma0	;if not a variable, also don't need to indirect
	call tschr	;no characters allowed as base
	jp z,prmae

prma0:	call tstar	;is the base an array?
	jp nz,prma1
	lda frml1	;yes...a formal one?
	or a
	jp z,prma2	;if not, don't indirect
prma1:	lda value	;if base already a value, don't indirect
	or a
	jp nz,prma2
	call sgen8g	;else get the value of the pointer on left of ->
	jp prma2	;and go add the member address

prmae:	ld de,stg17	
	call perr

prma2:	call igsht
	cp varcd
	jp z,prma3

prmae2:	call sexpas
	ld de,stg19
	jp perr

prma3:	call lookup
	lda typ1
	and 80h
	jp nz,prma4
prma3b:	ld de,stg19	;bad member name found
	call perr
	jp primg4

prma4:	call primap
	call tcnst1	;now, if base is a constant, don't bother generating
	jp nz,prma5	;any code. is it a constant?
	push hl
	lhld svv1	;yes. Add member offset to svv1.
	add hl,de
	shld svv1	;now wasn't that easy?
	pop hl
	jp primg4	;go skip over the code generation part

prma5:	push de
	call flshh1	;make sure base is in HL
	pop de
	call maddd
prma6:	xor a
	sta sval1
	jp primg4

;
; Handle "." operator:
;

primp:	call tsval
	jp nz,primp2
	ld de,stg17
	call perr
primp2:	inc hl
	call igsht
	cp varcd
	jp nz,prmae2
	call lookup
	lda typ1
	and 80h
	jp z,prma3b
	call tcnst1
	jp z,primp3
	push de
	call flshh1	;if not constant, get base in HL
	pop de
	jp prma4	;and go add member displacement value

primp3:	push hl
	lhld svv1
	add hl,de
	shld svv1
	pop hl
	call primap
	jp primg4

primap:	lda typ1
	and 7fh
	sta typ1

;	and 20h
;	ret nz

	nop
        nop
        nop

	lda indc1
	inc a
	sta indc1
	xor a
	sta value
	ret


;
; Handle ++ and -- operation on lvalue:
;

prim30:	lda val
	or a		;check if we need result value
	jp nz,prim30b	;if so, get it.
	call igsht	;else no value explicitly needed
	call primop	;trailing primary operator?
	jp z,prim30a	;if so, play safe & force value
	ld a,b		;else optimize for no result value!
	and 0feh	;and make post ops into pre ops
	ld b,a
	jp prim30b

prim30a: ld a,1
	 sta val

prim30b: call prm30
	xor a
	sta frml1
	ret

prm30:	ld a,1
	sta value
	call analyz
	lda asnokf
	or a
	jp z,p30err
	lda amathf
	or a
	jp nz,p30a
p30err:	ld de,stg8a
	jp perr

p30a:	lda avar
	or a
	jp z,p30b
	xor a
	sta indc1
	lda typ1
	or a
	jp nz,p30a2
	lda val
	ld c,0
	or a
	jp z,domac
	inc c
	jp domac

p30a2:	lda sval1	;abs external addr?
	and 1
	jp nz,p30a3

	ld c,2		;no.
	call domac
	inc c
	lda val
	or a
	call nz,domac
	ld a,40h
	sta sval1
	ret

p30a3:	push hl		;yes.
	lhld svv1
	shld sr0
	pop hl
	ld c,8
	call domac
	inc c
	lda val
	or a
	call nz,domac
	xor a
	sta sval1
	ret


p30b:	lda sval1	;abs external addr?
	and 1
	jp nz,p30g

	ld de,m20	;no.
	lda optimf	;-z7 in effect?
	and 40h
	jp z,p30ba
	ld de,m20z

p30ba:	call mcrog
	lda val
	or a
	jp z,p30c
	call ckle2
	jp z,p30c
	ld c,4
	call domac
p30c:	call ckle2
	jp nz,p30d
	ld c,5
	call domac
	lda asize
	dec a
	jp z,p30e
	ld c,5
	call domac
	jp p30e

p30d:	push hl
	lhld asize
	shld sr0
	ld a,l
	sta sr1+1
	ld a,h
	sta sr2+1
	ld a,0d6h
	sta sr1
	ld a,0deh
	sta sr2
	pop hl
	ld c,6
	call domac
p30e:	ld de,m28
	call mcrog
	ld a,40h
	sta sval1
	lda val
	or a
	ret z

	call ckle2
	jp z,p30f
	ld c,7
	jp domac

p30f:	ld c,3
	call domac
	lda asize
	dec a
	ld c,3
	call nz,domac
	ret

p30g:	push hl		;yes, abs external addr.
	lhld svv1
	shld sr0
	pop hl
	ld de,mac40	;do 'lhld foo'
	call mcrog
	lda val		;need value result?
	or a
	jp z,p30h
	call ckle2	;yes.
	jp z,p30h
	ld c,10	;push old value
	call domac
p30h:	call ckle2
	jp nz,p30i
	ld c,11
	call domac
	lda asize
	dec a
	jp z,p30j
	ld c,11
	call domac
	jp p30j

p30i:	push hl
	lhld asize
	shld sr1
	call cmh
	shld sr2
	pop hl
	ld c,12
	call domac
p30j:	ld de,mac09	;do: 'shld foo'
	call mcrog
	xor a
	sta sval1	;result in HL
	lda val		;need result?
	or a
	ret z		;if not, all done
	call ckle2	;else restore former value...
	jp z,p30k
	ld c,13
	jp domac

p30k:	ld c,9
	call domac
	lda asize
	dec a
	ld c,9
	call nz,domac
	ret


ckgt2:	lda asize+1
	or a
	jp nz,invrt
	lda asize
	cp 3
	ret c
	xor a
	ret

ckle2:	call ckgt2
	jp invrt

mact:	dw m12a,m12a,m14a,m14a		;c = 0
	dw m12,m13,m14,m15		;c = 1
mactz:	dw m16b,m16b,m18,m18		;c = 2
	dw mnul,m23,mnul,m22		;c = 3
	dw mnul,m21,mnul,m21		;c = 4
	dw m22,m22,m23,m23		;c = 5
	dw m26,m26,m27,m27		;c = 6
	dw mnul,m30,mnul,m30		;c = 7

	dw me16b,me16b,me18,me18	;c = 8
	dw mnul,me23,mnul,me22		;c = 9
	dw mnul,me21,mnul,me21		;c = 10
	dw me22,me22,me23,me23		;c = 11
	dw me26,me26,me27,me27		;c = 12
	dw mnul,me30,mnul,me30		;c = 13


;
; New ALU code generator for v1.4
;	info2 OP inf1 --> destination
;
; where info2 is either: a) in a reg, b) a constant, or c) on the stack,
;  and  info1 is either: a) in a reg, b) a constant, or c) a flag setting
;  and  destination is either a register or a constant.
;

alugen:	sta op		;save operator code
	xor a		;clear "make result type that of info2" flag
	sta par2pf	;and clear "two pointers" flag
	call nolvs	;make sure there aren't any flag settings
	call tpshd	;info2 pushed?
	jp nz,alugo	;if not, all set to compute
	call tcnst1	;yes. is info1 a constant?
	jp z,alu1		;if so, go pop info2 into DE
	lda sval1	;no...is info1 value in HL?
	and 0c0h
	jp nz,alu2	;if not, pop info2 into HL
alu1:	call gpopd	;pop info2 into DE
	ld a,40h
	jp alu3
alu2:	call gpoph	;pop info2 into HL
	xor a
alu3:	sta sval2	;tell that value is now in the appropriate reg
	jp alugo


;
; Make sure we don't have any flag settings to bum around with
;

nolvs:	lda sval1	;info1 a flag setting?
	and 4
	jp z,nolvs2
	lda sval1	;yes. value too?
	and 24h
	cp 24h
	jp nz,nolvs1
	lda sval1	;yes-make value only (preserving register bits)
	and 0c0h
	sta sval1
	jp nolvs2

nolvs1:	lda sval2	;info1 is flag only. is info2 in HL?	
	and 0c3h
	jp z,flshd1	;if so, put value in DE
	jp flshh1	;else put it in HL

nolvs2:	lda sval2	;info2 a flag setting?
	and 4
	ret z
	lda sval2	;yes. do we have a value already?
	and 24h
	cp 24h
	jp nz,nolvs3
	lda sval2	;yes. make value only, preserving register
	and 0c0h
	sta sval2
	ret

nolvs3:	lda sval1	;info2 is flag only. info1 in HL?
	and 0c3h
	jp z,flshd2	;if so, put value in DE
	jp flshh2	;else put in HL

;
; Flush all relative constants into registers
;

flrcn:	lda sval1	;info1 a rel const?
	and 2
	jp z,frcn2	;if not, go check out info2
	call tcnst2	;info2 a constant?
	jp nz,frcn1

	call flshh1	;yes-flush info1 into HL
	jp flrcn	;and go take care of info2

frcn1:	lda sval2	;info1 is rel lv. bummer. push info2
	and 0c0h
	call z,gpushh
	call nz,gpushd
	call flshh1	;flush info1 into HL
	call gpopd	;get info2 back into DE
	ld a,40h	;tell that info2 is in DE
	sta sval2
	ret


frcn2:	lda sval2	;info1 NOT a rel constant. info2 a rel const lv?
	and 2
	ret z		;if not, all done

	call tcnst1	;yes--info1 an abs constant?
	jp nz,frcn3
	call flshh2	;yes, so flush info2 into HL
	ret	

frcn3:	lda sval1	;info2 is rel lv. bummer. push info1
	and 0c0h
	call z,gpushh
	call nz,gpushd
	call flshh2	;flush info2 into HL
	call gpopd	;get info2 back into DE
	ld a,40h	;tell that info2 is in DE
	sta sval1
	ret


alugo:	push hl		;do this to preserve text ptr in HL
	xor a
	sta wierdp
	call alugo1
	pop hl
	ret

wierdp:	ds 1		;true for: (info2 - info1), when info2 ptr & info1 val

alugo1:	lhld svv1
	shld sr0
	lhld svv2
	shld sr1
	lda op

	cp eqcd	;== and not= are special
	jp z,alueq
	cp neqcd
	jp z,alune

	call analyz
	lda amathf
	or a
	jp z,parerr

	call anal2
	lda amathf
	or a
	jp z,parerr

	xor a
	sta hbn1cf

	lhld indc1	;turn all characters into
	call aluadj	;integers, and adjust attributes
	shld indc1	;as required.
	call z,clhbn1
	lhld indc2
	call aluadj
	shld indc2
	call z,clhbn2

	lda op
	cp mulcd
	jp nz,aludiv


	call usuals	;handle `*' op
	ld de,smmulu
	jp z,spcash
	ld de,smmuls
	jp spcash

aludiv:	cp divcd
	jp nz,alumod
	call usuals	;handle `/' op
	ld de,smdivu
	jp z,spcash
	ld de,smdivs
	jp spcash

alumod:	cp modcd
	jp nz,aluadd
	call usuals	;handle `%' op
	ld de,smmodu
	jp z,spcash
	ld de,smmods
	jp spcash

aluadd:	cp plus
	jp nz,alusub
	call nolvwr	;permit no rel-lvalue/reg-value combinations
	call paradj	;handle `+' op

	call tbabsc
	ld de,smadd
	jp nz,spcash

	lhld svv1	;handle simple constants here
	ex de,hl
	lhld svv2
	add hl,de
	shld svv1
	lda wierdp	;need to copy sval2 to sval1?
	or a
	ret z

aluad3:	lda sval2
	and 3fh
	ld b,a
	lda sval1
	and 0c0h
	or b
	sta sval1	;yes, so do it
	ret

;
; Make sure we don't end up with one operand being a relative lvalue
; constant and the other a value in a register:
;

nolvwr:	lda sval1
	and 3		;info1 in a reg?
	jp z,flrcn	;if so, go flush info2 if it is a rel lvalue
	lda sval2
	and 3		;info2 in a reg?
	jp z,flrcn	;if so, go flush info1 if it is a rel lvalue
	ret

alusub:	cp mincd
	jp nz,alusr
	call nolvwr	;permit no rel-lvalue/reg-value combinations
	call paradj	;handle `-' op
	call tbabsc
	ld de,smsub
	call nz,spcash
	lhld svv1	;do this just in case we had two constants
	call cmh
	ex de,hl
	lhld svv2
	add hl,de
	shld svv1

	lda par2pf	;two pointers?
	or a
	jp nz,alus1	;if so, go scale result by object size
	
	lda wierdp	;no. Was it an (ptr - val) expression?
	or a
	jp nz,aluad3	;if so, go set info1 to type of info2
	ret		;else info1 is correct type-all done.


alus1:	lhld asize	;we've gotta scale result by object size
	shld sr0
	dec hl
	ld a,h
	or l		;size = 1?
	jp z,alus2	;if so, don't do nuthin'
	ld de,macad3	;else gen code to divide by object size
	call tbabsc
	call nz,mcrog	;but don't bother if both constants
	call z,divs1a	;in case they're constants, calculate value here
alus2:	ld hl,0
	shld dimsz1
	xor a
	sta indc1
	inc a
	sta typ1
	call tbabsc	;if both were abs constants,
	ret nz
	ld a,1
	sta sval1	;result is ABS constant (even if both args were lv's)
	ret

alusr:	cp srcd
	jp nz,alusl
	call ckval2	;handle `>>' op
	call flrcn
	call tbabsc
	ld de,smsr
	jp nz,spcash
	lhld svv2	;do constant case
	lda svv1
	ld b,a
	inc b
alusr2:	dec b
	jp z,alusl3
	xor a
	ld a,h
	rra 	
	ld h,a
	ld a,l
	rra
	ld l,a
	jp alusr2


alusl:	cp slcd
	jp nz,alugt
	call ckval2	;handle `<<' op
	call flrcn
	call tbabsc
	ld de,smsl
	jp nz,spcash
	lhld svv2	;do constant case
	lda svv1
	inc a
alusl2:	dec a
	jp z,alusl3
	add hl,hl
	jp alusl2

alusl3:	shld svv1
	ret

alugt:	cp gtcd
	jp nz,aluge
alugt2:	call usual2	;do '>' op
	ld de,smgtu
	jp z,spcash
	ld de,smgts
	jp spcash

aluge:	cp gecd
	jp nz,alult
	call alult2	;do '>=' (simply inverse of '<')
	jp alune1

alult:	cp ltcd
	jp nz,alule
alult2:	call usual2	;do '<' op
	ld de,smltu
	jp z,spcash
	ld de,smlts
	jp spcash

alule:	cp lecd
	jp nz,aluand
	call alugt2	;do '<=' (simply inverse of '>')
	jp alune1

aluand: cp ancd
	jp nz,aluxor
	call ckval2	;do '&' op
	call flrcn
	call tbabsc
	ld de,smand
	jp nz,spcash
	lhld svv1	;handle trivials constant case
	lda svv2
	and l
	ld l,a
	lda svv2+1
	and h
	ld h,a
	shld svv1
	ret

aluxor:	cp xorcd
	jp nz,aluor
	call ckval2	;do '^' op
	call flrcn
	call tbabsc
	ld de,smxor
	jp nz,spcash
	lhld svv1	;do simple constants case
	lda svv2
	xor l
	ld l,a
	lda svv2+1
	xor h
	ld h,a
	shld svv1
	ret

aluor:	cp orcd

	push de
	ld de,stgbbo	;'expecting binary operator'
	call nz,perrab	;no other operators; better be '|'
	pop de

	call ckval2
	call flrcn
	call tbabsc
	ld de,smor
	jp nz,spcash
	lhld svv1	;do trivial constants case
	lda svv2
	or l
	ld l,a
	lda svv2+1
	or h
	ld h,a
	shld svv1
	ret

alune:	call alueq	;for not=, first call the == routine
alune1:	lda sval1	;and invert the result.
	and 4		;was it a flag setting?
	jp z,alune2
	lda sbmap1	;yes-invert bit 0
	xor 1
	sta sbmap1
	ret

alune2:	lda sval1
	and 3		;result a constant?
	call z,ierror	;if not, must've screwed up somewhere
	lhld svv1	;get result of == test
alun2a:	ld a,h
	or l
	ld hl,0		;was it zero?
	jp nz,alune3	;if not, new result IS zero
	inc hl		;if so, new result is 1
alune3:	shld svv1
	ret
			;handle == operator:
alueq:	call flrcn	;flush rel lvalue constants
	call tbabsc
	jp nz,alueq2	;both constants?
	lhld svv1	;yes.
	ex de,hl
	lhld svv2	;compare them
	call cmh
	add hl,de		;set HL to zero if two are equal
	jp alun2a

alueq2:	lda sval1
	sta ssval
	call tschr	;info1 a simple char?
	jp nz,aleq3
	call tschr2	;yes. info2 also a char?
	jp nz,aleq2b
	ld de,mac71c	;yes--do simple ld a,e-cp l
	call mcrog
aleq20:	xor a
aleq2a:	sta sbmap1
	ld a,4
	sta sval1
	ret

aleq2b:	call tcnst2	;info1 is a char, info2 isn't..
	jp nz,aleq2e	;is info2 a constant?
	lhld svv2
	shld svv1	;if so, xfer value over to common area
alq2b2:	lda svv1+1	;info1 is a char. is info2 (const) <= 255?
	or a
	jp nz,aleq2d
	lda ssval	;yes.
	and 0c0h	;get low byte of non-constant into A
	ld a,7dh
	call z,genb		;if non-constant in H, do "ld a,l"
	ld a,7bh
	call nz,genb	;else do "ld a,e"
	lda svv1	;special case constant of 0?
	or a
	jp nz,aleq2g
	ld a,0b7h	;if so, do "or a"
	call genb
	jp aleq20

aleq2g:	ld a,0feh	;do 'cp value'
	call genb
	lda svv1
	call genb
	jp aleq20

aleq2d:	ld hl,0		;if char value and two byte constant,
	shld svv1	;can't possibly be equal
	ld a,1
	sta sval1
	ret

aleq2e:	ld de,mac61	;zero high-order byte of char value
	lda ssval
	and 0c0h
	call z,mcrog
	ld de,mac62
	call nz,mcrog
	ld de,mac71
	call mcrog
	jp aleq20

aleq3:	call tschr2	;info1 NOT char, but is info2?
	jp nz,aleq4
	lda sval2	;yes--set up info2 attributes in common area
	sta ssval
	call tcnst1	;if info1 not constant, go zero high byte of
	jp nz,aleq2e	;info2 and do 16-bit test
	jp alq2b2	;else optimize for character constant

aleq4:	ld de,smeq	;do the normal macro for 2 values or one constant
	jp spcash	;and one big value.




;
; If one or two pointers appear in a + or - operation, scale
; the non-pointer by the size of the object the pointer points to:
;

paradj: call unsadj	;adjust for unsigned operands
	call tptr2	;info2 a pointer?
	jp z,prdj2
	call tptr	;no. info1 a pointer?
	ret nz		;if not, nothin' to do.
	lda op
	cp mincd
	jp z,parerr	;2nd arg can't be pointer in binary `-' operation
	call analyz
	lhld svv2
	shld subval
	lhld asize
	shld sr0
	lda sval2
	call sclabh	;scale object described by A by HL bytes
	shld svv2	;save value in case of constant (such as array base)
	ret

prdj2:	call tptr	;info2 is ptr-is info1 ptr too?
	jp nz,prdj3
	lda op		;yes. Can only subtract 2 ptrs if op is `-'
	cp mincd
	jp nz,parerr
	call analyz
	push hl
	lhld asize
	push hl		;save size of object 1
	call anal2
	lhld asize	;get size of object 2 in HL
	pop de		;get size of object 1 in DE
	ld a,h		;compare size of both objects--must be =
	cp d
	ld a,l
	pop hl
	jp nz,parerr
	cp e
	jp nz,parerr
	ld a,1
	sta par2pf
	ret

prdj3:	call anal2	;info2 is a pointer.
	lhld svv1
	shld subval
	lhld asize
	shld sr0
	lda sval1
	call sclabh	;scale asize by HL
	shld svv1

	lhld indc2	;lde info2 info into info1, but
	shld indc1	;preserve info1's old sval1 and svv1
	lhld dimsz2	;for register allocation/optimization
	shld dimsz1	;purposes.
	lhld strsz2
	shld strsz1
	ld a,1
	sta wierdp
	ret

sclabh:	ld b,a		;object to scale a constant?
	and 3
	jp z,scl2
	call mult	;yes--simple
	ret

scl2:	ld a,h		;multiply by 0?
	or l
	ret z		;if so, just grin and scratch hair.
	dec hl		;multiply by 1?
	ld a,h
	or l
	ret z		;if so, don't do a darned thing
	ld a,b		;else, is value to scale in HL?
	and 0c0h
	jp nz,sclde
	call trydad	;yes, try to do it with 'add hl,hl's
	ret z		;all done if it worked
	ld de,macad2	;else scale HL the hard way
	call mcrog
	ret

sclde:	lda codflg	;if value in DE, first see if we can use 'add hl,hl's
	push af
	xor a
	sta codflg	;disable code generation the first time...
	push hl
	call trydad
	pop hl	
	jp nz,sclde2	;can we use "add hl,hl"'s?
	pop af		;yes. restore codeflag
	sta codflg
	call gexdehl	;get the value from DE into HL
	call trydad	;do the add hl,hl's for real
	lda op		;if + operator, don't worry about restoring
	cp plus	;proper registers (leave them switched)
	call nz,gexdehl	;but put them back if - operator
	ret

sclde2:	pop af		;restore codflg
	sta codflg
	ld de,macad1	;and scale DE the hard way
	call mcrog
	ret


trydad:	ld a,h
	or a		;if high byte is non-zero, forget about
	ret nz		;using add hl,hl's!
	ld c,29h
	ld a,l
	dec a
	jp z,dad1		;if HL was originally 2, go do single add hl,hl
	sub 2
	jp z,dad2		;if it was 4, do two add hl,hl's
	sub 4
	jp z,dad3		;if it was 8, do three add hl,hl's
	sub 8		;if wasn't 16, give up
	ret nz
	ld a,c
	call genb	;it was 16--do four add hl,hl's
dad3:	ld a,c
	call genb
dad2:	ld a,c
	call genb
dad1:	ld a,c
	call genb
	ret



;
; svv1 <-- svv1/asize, signed
;

divs1a:	lhld svv1
	ld a,h
	or a
	jp divpos	;svv1 positive? if so, do simple unsigned divide
	call cmh	;else negate to make it positive,
	call divpos	;do the divide
	lhld svv1	;and negate the result
	call cmh
	shld svv1
	ret

;
; svv1 <-- HL/asize, unsigned:
;

divpos:	ld bc,-1	;quotient result
	ex de,hl
	lhld asize
	call cmh
	ex de,hl		;put -asize in DE
divtst:	ld a,h
	or a		;if HL negative, all done
	jp keepon
	ld h,b
	ld l,c
	shld svv1	;store quotient
	ret

keepon:	add hl,de		;subtract asize again
	inc bc
	jp divtst	;and test for negative numerator


;
; Some common tests performed by alugen operator handlers:
;

usuals:	call ckval2
usual2:	call flrcn
	call tbabsc
	call z,fcnsts
	call unsadj
	ret

;
; Clear high byte of info1's register:
;

clhbn1:	ld a,0afh	;get 'xor a'
	call genb
	lda sval1
clhb1a:	and 0c0h	
	ld a,67h	;'ld h,a'
	call z,genb
	ld a,57h	;'ld d,a'
	call nz,genb
	sta hbn1cf
	ret

;
; Clear high byte of info2's register:
;

clhbn2:	lda hbn1cf
	or a
	lda sval2	;if info1 already cleared, use the 0 in A again
	jp nz,clhb1a
	ld de,mac61	;else generate ld x,0
	and 0c0h
	call z,mcrog	;ld h,0 if value in HL
	ld de,mac62
	call nz,mcrog	;else ld d,0
	ret

;
; Return Z set if both info1 and info2 are constants of some kind:
;

tbabsc:	lda sval1
	and 3
	jp z,invrt
	lda sval2
	and 3
	jp invrt

;
; Flush any and all constants into registers
;

fcnsts:	lda sval1	;info1 a const?
	and 3
	jp z,fcn2		;if not, go check out info2
	lda sval2	;yes. info2 a const?
	and 3
	jp z,fcn1
	call flshd1	;yes-flush info1 into DE
	jp fcnsts	;and go take care of info2

fcn1:	lda sval1	;info1 constant, info2 isn't. info1 absolute?
	and 1
	jp z,fcn1a
	lda sval2	;yes, so flush into wherever info2 isn't...
	and 0c0h
	jp z,flshd1	;either DE, if info2 in HL
	jp flshh1	;or into HL if info2 in DE

fcn1a:	lda sval2	;info1 is rel lv. bummer. push info2
	and 0c0h
	call z,gpushh
	call nz,gpushd
	call flshh1	;flush info1 into HL
	call gpopd	;get info2 back into DE
	ld a,40h	;tell that info2 is in DE
	sta sval2
	ret


fcn2:	lda sval2	;info1 NOT a constant. info2 a const?
	and 3
	ret z		;if not, all done
	lda sval2	;yes. absolute constant?
	and 1
	jp z,fcn2a
	lda sval1	;yes-flush into wherever info1 isn't
	and 0c0h
	jp z,flshd2	;into DE if info1 in HL
	jp flshh2	;into HL if info1 in DE

fcn2a:	lda sval1	;info2 is rel lv. bummer. push info1
	and 0c0h
	call z,gpushh
	call nz,gpushd
	call flshh2	;flush info2 into HL
	call gpopd	;get info2 back into DE
	ld a,40h	;tell that info2 is in DE
	sta sval1
	ret

	;IF LASM
	;link cc2c
	;ENDIF
