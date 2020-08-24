
;
; ccd.asm:
;

;
; preprocessor directive handler:
;

defstr: db '#defin', 'e'+80h
undfst:	db '#unde','f'+80h
ifst:	db '#i','f'+80h
ifdfst:	db '#ifde','f'+80h
ifndst:	db '#ifnde','f'+80h
endfst:	db '#endi','f'+80h
elsest:	db '#els','e'+80h
prepw:	db 'Warning: Ignoring unknown preprocessor directive',cr,lf,0
stgppo:	db 'String overflow; call BDS+'
stgmmp:	db 'EOF found when expecting #endif+'
stgbds:	db 'Bad parameter list syntax+'
stgbd1:	db 'Missing parameter list+'
stgbd2:	db 'Parameter mismatch+'
stgnwc:	db 'Not in a conditional block+'
stgbce:	db 'Conditional expr bad or beyond implemented subset+'

prep:	ld hl,lblt	;set pointer to start of string space table
	shld def2p

	xor a
	sta bcnstf	;supress errors on bad constants till later on...

	ld hl,lblt+strsiz
	shld stp
	ld (hl),0

	call initps	;initialize for pass through text

	xor a		;initialize nested conditional control variables
	sta nestl	;current conditional nesting level
	sta didelse	;didn't see an #else yet in current macro
	sta dstgf	;not in a string (for prlin)
	inc a
	sta active	;currently conditionally active

prep1:	call nextch	;handle bookkeeping
	jp nc,prep1a	;EOF?

	lda nestl	;Yes. In a conditional block?
	or a
	ld hl,stgmmp
	jp nz,perrab	;if so, go complain and abort
	xor a
	sta preflag	;not in preprocessor anymore
	ret		;otherwise done with preprocessor

prep1a:	lhld nlcnt	;save line count
	shld nlcsav
	cp cr		;line only a lone CR?
	jp nz,prep1b	;if not, process the line

	dec hl		;else debump line count
	shld nlcsav
	jp prep2a	;and go wrap up

prep1b:	push de		;process #defined substitutions on current line,
	lda active	;but only if active
	or a
	call nz,prlin
	pop de

	call igwsp
	ld a,(de)		;a preprocessor directive?
	cp '#'
	jp nz,prep2	;if not, don't bother with rest of this stuff

	ld hl,endfst	;#endif?
	call stcmp
	jp z,pendif

	ld hl,elsest	;#else?
	call stcmp
	jp z,pelse

	ld hl,ifdfst	;#ifdef?
	call stcmp
	jp z,pifdef

	ld hl,ifndst	;#ifndef?
	call stcmp
	jp z,pifndef

	ld hl,ifst	;#if?
	call stcmp
	jp z,pif

	lda active
	or a		;if not active, don't do any more processing
	jp z,prep2

	ld hl,defstr	;#define?
	call stcmp
	jp z,pdef

	ld hl,undfst	;#undef?
	call stcmp
	jp z,pundef

	push de		;check for possible '#' on a line by itself; this
prpwlp:	inc de		;should be ignored by turning the line into FF's:
	ld a,(de)
	cp 0ffh	;we'll allow this between # and NL
	jp z,prpwlp
	cp cr		;end of line?
	jp z,prpwrn0

prpwrn:	ld hl,prepw	;print this warning ONLY if
	call pwarn
prpwrn0: pop de
	jp prep2b


;
; Come here when current line is NOT a preprocessor directive:
;

prep2:	lda active	;active?
	or a
	jp z,prep2b
	
prep2a:	call nextch	;find CR or EOF
	ret c
	cp cr
	inc de
	jp nz,prep2a
	jp prep2c

prep2b:	call dellin	;delete line
prep2c:	lhld nlcsav	;bump saved line count
	inc hl
	shld nlcnt
	jp prep1	;and go for more text


;
; Delete current line of text at DE, up to CR:
;	

dellin:	ld a,(de)
	cp cr
	jp nz,dell2
	inc de
	ret

dell2:	ld a,0ffh
	ld (de),a
	inc de
	jp dellin


;
; Process #endif:
;

pendif:	lda nestl	;if not in a conditional, complain
	or a
	jp nz,pendf2
pendf1:	ld hl,stgnwc	;"Not within conditional block"
	jp perrab

pendf2:	dec a		;decrement nest level
	sta nestl

	pop af		;pop old activity state
	sta active
	pop af
	sta didelse

	jp prep2b	

		
;
; Process #else:
;

pelse:	lda nestl	;if not in a conditional block, error
	or a
	jp z,pendf1
	lda didelse	;have we already done an #else this block?
	or a
	jp nz,pendf1	;if so, error

	pop af		;peek at last activity state
	push af
	or a
	jp z,pelse2	;last level active? If not, leave this one inactive

	lda active	;yes. flip current state
	or a
	ld a,1		;was active false?
	jp z,pelse1	;if so, make it true
	xor a		;else was true: make it false
pelse1:	sta active
pelse2:	ld a,1		;set didelse
	sta didelse
	jp prep2b	

;
; Process #ifdef:
;

pifdef:	push de		;save text pointer
	lda active	;if not active, don't bother evaluating identifier
	or a
	jp z,doif
	call defined	;test to see if identifier defined
	jp doif	;go wrap up

;
; Process #ifndef:
;

pifndef: push de		;just like for #ifdef, 
	lda active
	or a
	jp z,doif
	call defined
	cpl		;execpt flip the logical result
	jp doif

;
; Process #if:
;

pif:	push de		;save text pointer
	lda active
	or a
	jp z,doif		;if not active, don't bother evaluating line
	ld hl,3	
	add hl,de
	ex de,hl
	call ifexp	;otherwise evaluate conditional expression
	jp doif

;
; Evaluate conditional expression at DE, having  BNF:
;
;	ifexp :=  <ifexp2> 
;	    (or)  <ifexp2> && <ifexp>
;	    (or)  <ifexp2> || <ifexp>
;
;	ifexp2 := <constant>
;	    (or)  <(ifexp)>
;	    (or)  not<ifexp2>	("not" is an exclamation point)
;

ifexp:	call ifexp1	;evaluate expression
	ld b,a		;save result in B
	call gndch	;make sure there isn't anything after it
	cp cr
	ld a,b		;get back the result
	ret z		;if CR, all done
ifexp0:	ld hl,stgbce	;bad conditional expression
	jp perrab

;
; Recursive entry point for conditional expression evaluator:
;

ifexp1:	call ifexp2	;evaluate subexpression
	jp c,ifexp0	;error if not legal expression
	ld b,a		;put result in B
	call igwsp	;check for operators
	ld c,'&'
	cp c
	jp z,ifxp1a
	ld c,'|'
	cp c
	jp z,ifxp1a
	ld a,b		;no legal operators..return evaluated value.
	ret

ifxp1a:	inc de		;check for second identical character
	ld a,(de)
	cp c
	jp nz,ifexp0	;if not, syntax error
	push bc		;OK, save last result (B) and operator (C)
	inc de		;evaluate next operand
	call ifexp1
	ld l,a		;put result in L
	pop bc		;get back previous result and operator
	ld a,c		;look at operator
	cp '&'		;logical and?
	ld a,b		;get previous result in A
	jp nz,ifxp1b
	and l		;if so, AND the two and return result
	ret
ifxp1b:	or l		;else OR the two and return result
	ret

ifexp2:	call igwsp	;skip leading whitespace
	cp '('		;parenthesized expression?
	jp nz,ifxp2a
	inc de		;yes. pass the opening paren
	call ifexp1	;evaluate inner expression
	ld b,a
	call igwsp	;check for closing paren
	cp ')'
	scf		;return Cy if not closed
	ret nz
	inc de		;otherwise pass the close paren
	ld a,b		;get back result
	ccf		;clear Cy
	ret		;and return

ifxp2a:	cp '!'		;negation operator?
	jp nz,ifxp2b
	inc de		;yes. evaluate operand
	call ifexp2
	ret c		;ignore if error
	or a		;otherwise flip result
	ld a,1
	ret z		;return 1 if result was 0
	dec a		;return 0 if result was 1
	ret

ifxp2b:	call digt	;otherwise must be decimal constant
	ret c		;return error if not
ifxp2c:	ld a,(de)		;check a char of the constant
	call digt	;digit?
	jp nc,ifxp2	;if so, go process
	xor a		;else result is zero.
	ret

ifxp2:	inc de		;bump ptr to next digit
	or a		;was last digit zero?
	jp z,ifxp2c	;if so, go loop
ifxp3:	ld a,(de)		;otherwise find end of value
	call digt
	inc de
	jp nc,ifxp3	;keep looping till we find a non-digit
	dec de		;all done
	xor a		;return no Cy
	inc a		;and a value of 1
	ret


;
; Come here after #if, #ifdef or #ifndef condition has been
; evaluated, with A = <condition>, either 0 or non-0:
;

doif:	ld b,a		;save condition in B
	lda nestl	;bump nesting level
	inc a
	sta nestl

	pop de		;get back text pointer

	lda didelse	;push current activity state
	push af
	lda active
	push af

	or a		;currently active
	jp z,doif2	;if not, remain inactive
	ld a,b		;look at conditional test result
	or a
	jp z,doif2	;if false, active = 0;
	ld a,1		;else active = 1.
doif2:	sta active

	xor a
	sta didelse	;clear didelse for the new level
	jp prep2b	;and go clean up


;
; Process #undef:
;

pundef:	push de
	call defined
	pop de
	jp c,prep2b	;if already not defined, ignore it
	ld (hl),'*'	;otherwise place a strange char there to erase it
	jp prep2b	;and go wrap up

;
; Process #define definition:
;

pdef:	push de		;found #define line. Save text ptr for later deletion.
	call defined	;re-defining an identifier?
	jp c,pdef2
	call prepa	;yes. go do that
	jp pdef3

;
; Install the identifier at DE for the first time:
;

pdef2:	lhld stp
	call prepa	;install identifier
	shld stp
	ld (hl),0

;
; Collect up the substitution text in the string table:
;

pdef3:	push af
	call igwsp
	pop af
	or a		;parameterized?
	jp nz,prargs	;if so, go handle elsewhere

	call gndch	;a null definition?
	cp cr
	jp nz,pdef4a
	ld a,0ffh	;if so, define as a whitespace (FF) byte
	jp pdef4b

pdef4:	call gndch	;else install simple text, till end of line
pdef4a:	ld (bc),a
	inc bc
	cp cr
	jp nz,pdef4
	dec bc		;turn b7 high on last char of replacement text
	dec bc
	ld a,(bc)
	or 80h
pdef4b:	ld (bc),a
	inc bc
	ld h,b		;and replace text table pointer
	ld l,c

pdef5:	shld def2p	;make sure def2p hasn't collided with identifier table
	ld de,lblt+strsiz
	call cmphd	;return C if def2p < end of table2 (ie. no overflow)
	jp c,pdef6	;if no overflow, no problem

	ld hl,stgppo	;preprocessor overflow: complain and abort
	jp pstgab

pdef6:	pop de
	jp prep2b	;go delete line and finish up

;
; Process parameterized substitution text: replace arg keywords with
; special codes (80, 81, etc.) as it is stored in string table:
;

	IF 0
stgflg:	ds 1		;in a string flag, for parameterized definitions
escflg:	ds 1		;escaped char in text string flag
	ENDIF

prargs:	ld h,b		;copy string table address into HL
	ld l,c
	and 7fh		;strip b7 off arg count
	ld c,a		;put in C
	inc c		;C = # of args + 1


prarg0:	call gndch	;see if text at DE matches one of the formal args

	call varch2
	jp nc,prarg2

prarg1:	ld (hl),a		;no match...just store it
	inc hl
	cp cr
	jp nz,prarg0	;and go for more
	jp pdef5	;when done, go wrap up.

prarg2:	dec de		;go back to start of the identifier
	push bc		;get set to search arg text table for match
	push hl
	ld b,80h
	ld hl,deformt
prarg3:	dec c		;done searching list?
	jp z,prarg6
	ld a,(hl)		;no. compare strings
	inc hl
	push hl
	ld h,(hl)
	ld l,a
	push bc
	call idcmp
	jp nz,prarg5	;match?
prarg4:	inc de		;yes.
	dec c		;replace arg with code number
	jp nz,prarg4
	pop bc
	ld a,b		;get code number
	pop hl
	pop hl
	pop bc
	jp prarg1	;and go store it

prarg5:	pop bc		;no match. try next table entry
	pop hl		;get table pointer
	inc hl		;point to next arg string
	inc b		;bump current code number
	jp prarg3

prarg6:	pop hl
	pop bc		;no match. Copy identifier literally
	ld a,(de)
prarg7:	ld (hl),a
	inc hl
	inc de
	ld a,(de)
	call varch	;still part of identifier?
	jp nc,prarg7	;if so, keep on storing
	jp prarg0	;else go for next piece of text
	
;
; Install the identifier at DE in the defined constant id table. For
; parameterized defines, count up formal args and make sure the count
; gets into the table.
;
; On entry, HL points to the spot in the table where the id is to be
; inserted:
;
; Return A == argcount (b7 high if args present), BC --> text area
; where key text is to be stored.
;

prepa:	push hl		;push id table pointer
	lhld stp	;get id table free slot pointer
	ex (sp),hl		;push on stack, get back id table pointer
	shld stp	;make id pointer act as free slot pointer for now
	call instt	;install identifier at DE

	push hl		;save pointer to argcount byte
	ld l,c		;put identifier length in HL
	ld h,0
	add hl,de		;now HL -> char after identifier in text
	ld a,(hl)		;look at it
	cp '('		;parameterized define?
	ld a,0
	jp nz,prepa2	;if not, install 0 in argcount byte position
	call deform	;else go count up formal args, return A = # of args
	jp nc,prepa1
	ld hl,stgbds
	jp perrab

prepa1:	or 80h		;set b7 to indicate parameterized define
prepa2:	ex (sp),hl		;push text pointer from HL, get HL = table pointer
	ld (hl),a		;store argcount value in id table
	inc hl		;bump table pointer to string addr area
	push hl		;save str addr area ptr
	lhld def2p	;get string table free area pointer
	ld b,h		;lde to BC
	ld c,l
	pop hl		;get back str addr area ptr
	ld (hl),c		;save string pointer in id table
	inc hl
	ld (hl),b
	inc hl		;HL now points to next id slot
	pop de		;get back text pointer
	ex (sp),hl		;push text pointer, pop old id table free slot ptr
	shld stp	;save id table free slot ptr

	push de		;check for table overflow...we have one if
	ex de,hl		;stp not less than coda
	lhld coda
	ex de,hl
	push af	;save argcount value
	call cmphd	;return C if stp < coda
	jp nc,instt0	;if stp >= coda, go complain and abort
	pop af		;restore argcount value
	pop de
	pop hl
	ret

;
; Given HL -> formal arg list for parameterized define,
;  1. Put list of pointers to the args at deformt
;  2. put b7 high on last byte of each arg
;  3. return A = # of formal args (0 is legal), and HL -> after list
;
; If A == 0 on entry, allow only identifiers,
; If A <> 0,  allow any type of objects
;

deform:	ld b,a		;save strings_ok flag in B

	xor a		;initialize extra line count
	sta lcnt

	ld c,0		;init arg count
	ex de,hl		;put text pointer in DE
	ld hl,deformt	;init arg ptr list ptr
	inc de		;pass '('
	call igwsp	;ignore trash
	cp ')'		;null list?
	jp nz,defrm2

defrm1a:
	inc de		;yes. pass over ')'
	ex de,hl		;put text ptr back in HL
	ld a,c		;get arg count in A
	ret

defrm2:	call igwsp	;ignore leading trash
	cp cr		;newline character?
	jp nz,defr2a	;if not, assume it's legal starting char
	lda lcnt	;bump extra line count
	inc a
	sta lcnt
	inc de		;go on to next char
	jp defrm2	;and go check for more extra newlines
	
defr2a:	ld (hl),e		;add adress of next arg to list
	inc hl
	ld (hl),d
	inc hl

	ld a,b
	or a		;if allowing identifiers only,
	jp z,defrm4	;then go do that

	xor a		;clear paren nest level
	sta parenc

defr3a:	ld a,(de)		;else process generalized arg: get char of text
	inc de		;bump text pointer
	cp '"'		;quote?
	jp nz,defr3d	;if not, go check for terminators
			;process string arg:
defr3b:	ld a,(de)		;look at next arg of string
	inc de
	cp '\'		;backslash?
	jp nz,defr3c
	inc de		;if so, pass over the next char
	jp defr3b
defr3c:	cp '"'		;closing quote?
	jp nz,defr3b	;if not, keep looping till we find one
	jp defr3a	;found closing quote. go for more of the arg

defr3d:	dec de		;temporrily place txt ptr on current char
	cp ','		;comma?
	jp nz,dfr3d1	;if not, check for close paren
	lda parenc	;in parens?
	or a
	jp z,defr4a	;if not, found end
	jp dfr3d2	;else inside parens, so ignore	

dfr3d1:	cp ')'		;close paren?
	jp nz,dfr3d3	;if not, go check for other special chars
	lda parenc
	or a
	jp z,defr4a	;if already zilch, all done with this paren
	dec a		;else debump paren count
	sta parenc
dfr3d2:	inc de		;else go on with term
	jp defr3a

dfr3d3:	inc de		;advance txt ptr back past current char
	cp ''''	;single quote?
	jp z,defr3e	;if so, go handle
	cp '('		;open paren?
	jp nz,defr3a	;if not, go for next char
	lda parenc	;bump paren count
	inc a	
	sta parenc
	jp defr3a	;and go for more text

defr3e:	ld a,(de)		;process object in single quotes
	inc de
	cp '\'
	jp nz,defr3f
	inc de		;ignore char after backslash
	jp defr3e	
defr3f:	cp ''''	;closing single quote?
	jp nz,defr3e	;if not, keep scanning
	jp defr3a	;else done with single quote object; go for more arg

defrm4:	ld a,(de)		;get character at txt ptr
	call varch2	;legal 1st char of identifier?
	ret c		;if not, error.
defr40:	inc de		;find char after last char of identifier
	ld a,(de)
	call varch
	jp nc,defr40

defr4a:	dec de		;go back to last char of arg
	ld a,(de)		;set b7
	or 80h
	ld (de),a
	inc c		;bump arg count
	inc de		;get next char
	call igwsp
	cp ','		;comma?
	jp nz,defrm5	;if not, go check for ')'
	inc de		;else pass comma and look for identifier
	jp defrm2
	
defrm5:	cp ')'		;now must be either close or an error
	jp z,defrm1a
	scf		;error. set Cy and return
	ret

;
; Test to see if identifier at DE has already been defined in a previous
; #define line. Return Cy clear if previously defined.
;

defined:
	ld l,c		;look at the identifier.
	ld h,0
	add hl,de
	ex de,hl
	call igwsp
	call findd	;is it already defined? set C if not.
	lhld deftmp
	ld a,0ffh	;also A = 0ffh if no carry,
	ret nc
	cpl		;A = 0 if carry
	ret


;
; Process all text substitutions on the line pointed to by DE:
;

prlin:	push de		;save pointer to start of line for later retrieval
	lda dstgf	;and save state of in-string flag
	push af

	or a		;in a string from previous line?
	jp nz,prln0	;if so, don't check for preprocessor directives

	call igwsp	;ignore leading white space, checking for directives
	ld hl,ifst	;line begin with #if?
	call stcmp
	jp z,prln1	
	ld a,(de)		;line start with #?
	cp '#'
	jp z,prl0a	;if so, don't preprocess.
	jp prln0

prln1:	inc de		;line starts with #if. Pass "#if"
	inc de
	inc de
	call igwsp	;process rest of #if line.


prln0: 	dec de
prlin9:	inc de
prlin0:	ld a,(de)		;end of file?
	or a
	jp z,prl0a	;if so, end of line for sure.
	cp cr		;end of line?
	jp nz,prlin1
prl0a:	pop af		;yes. all done. clean up stack (pushed dstgf)
	pop de		;and pop text pointer to start of line
	ret

prlin1:	lda dstgf	;in a string right now?
	or a
	ld a,(de)
	jp z,prlinc
	cp '"'		;yes. close quote?
	jp z,prlinb	;if so, go flip "in string" state
	cp '\'		;no. escape?
	jp nz,prlin9	;if not, just go to next char
	inc de		;if so, skip next character
	jp prlin9

prlinb:	lda dstgf
	cpl
	sta dstgf
	jp prlin9

prlinc:	cp '"'		;not in a string. start of string quote?
	jp z,prlinb	;if so, go flip "in string" state
	cp ''''	;character constant?
	jp nz,prlind
	call chcnst1	;yes. pass over it
	jp prlin0

	
prlind:	call varch2	;identifier?
	jp c,prlin9

prline:	call subst	;yes. do substitutions
	jp c,prlinf	;any done?
	pop af		;yes. restore dstgf
	sta dstgf
	pop de		;and text pointer, then start processing line again.
	jp prlin

prlinf:	inc de		;pass over rest of identifier name
	ld a,(de)
	call varch
	jp nc,prlinf
	jp prlin0	;and go for more stuff.


;
; Search for identifier pointed to by DE in the identifier
; table. Return Cy set if not found, else HL pointing to
; the arg count byte immediately following the name entry
; in the table:
;

findd:	ld hl,lblt+strsiz 	;start of identifier table

findd2:	ld a,(hl)
	or a
	scf
	ret z
	shld deftmp
	call idcmp
	jp nz,findd3
	lhld deftmp
	push bc
	ld bc,8
	add hl,bc
	pop bc
	ret

findd3:	ld bc,11
	add hl,bc
	jp findd2


;
; Ignore white space at DE:
;

igwsp:	ld a,(de)
	inc de
	call twsp
	jp z,igwsp
	dec de
	ret


;
; Do all potential substitutions for the text at DE:
;

subst:	call findd	;is identifier at DE a defined symbol?
	ret c

	ld b,(hl)		;put arg count in B
	inc hl
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a	

	ld a,b		;parameterized?
	or a
	jp z,substs	;if so, go handle simple substitution

	and 7fh		;otherwise put arg count in B
	ld b,a
	push de		;save  ->old text
	call pasvr	;param list?
	call igwsp	;ignore white space between var and possible param list
	cp '('
	jp z,subst2
	ld hl,stgbd1
	jp perrab

subst2:	push hl		;save ->new text
	ex de,hl		;put text ptr in HL
	push bc
	call deform	;build list of param ptrs
	ex de,hl		;put text ptr back in DE
	jp nc,subst3
	ld hl,stgbds
	jp perrab		

subst3:	pop bc
	cp b
	jp z,subst4	;correct # of args?
	ld hl,stgbd2
	call perrab

subst4:	pop hl		;HL ->new text
	push de		;save DE (->after old text)
	ld de,txbuf	;now create new text image at txbuf

	ld a,(hl)		;check for a null text image
	cp cr
	jp nz,subst5	;if not null, handle normally
	ld a,0ffh	;else place null FF byte in text area
	ld (de),a
	jp subst9a

subst5:	ld a,(hl)
	inc hl
	cp cr
	jp z,subst9
	or a
	jp m,subst6	;if arg code, go substitute
	ld (de),a		;otherwise just a char
	inc de
	jp subst5

subst6:	and 7fh		;now substitute an arg for the code byte
	add a
	ld c,a
	ld b,0
	push hl
	ld hl,deformt
	add hl,bc
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a		;HL -> arg text represented by code byte
subst7:	ld a,(hl)
	and 7fh
	ld (de),a
	inc de
	ld a,(hl)
	inc hl
	or a 
	jp subst7	;keep copying till b7 is high on last char
	pop hl
	jp subst5

subst9:	dec de		;turn on b7 of last char of text area
	ld a,(de)
	or 80h
subst9a:
	ld (de),a
	pop de		;all done...now just replace old text with new text
	pop hl
	push hl
	call cmh
	add hl,de
	ld c,l
	pop de
	ld hl,txbuf
	call substs

	lda lcnt	;get extra line count
	ld b,a		;save in B
	cpl		;negate for "mvtxt"
	inc a
	call mvtxt	

substa:	ld a,b
	or a
	ret z	
	ld a,cr
	ld (de),a
	inc de
	dec b
	jp substa

;
; Substitute text at HL for identifier at DE, length of id at DE is in C:
;

substs:	push hl		;save ->new text
	push bc		;save id length
	push hl		;push ->new text
	call cmh	;HL = -(new text addr)
	ex (sp),hl		;push -(new addr), get HL = new addr
subs2:	ld a,(hl)		;compute length of new text
	inc hl
	or a
	jp subs2
	pop bc		;get -(new addr) in BC
	add hl,bc		;HL = length
	ex (sp),hl		;push lengh, HL = id length (in L)
	ld h,0		;HL = id length
	call cmh	;HL = -(id length)
	pop bc
	push bc		;BC = new text length
	add hl,bc		;HL = difference in lengths
	ld a,l		;negate difference
	cpl
	inc a
	call mvtxt	;shift text
	pop bc
	pop hl
	inc bc
subs3:	dec bc		;insert new text
	ld a,b
	or c
	ret z
	ld a,(hl)
	cp 0FFh	;filler byte?
	jp z,subs4
	and 7fh
subs4:	ld (de),a
	inc de
	inc hl
	jp subs3
		

;
; Print out intermediate text if "-p" option given:
;

pitext:
	lda pflag	;return if intermediate text
	or a		;	printout not desired
	ret z

	lda werrs	;output to console only
	push af
	xor a
	sta werrs

	lhld coda
	ex de,hl		;DE points to text
	ld hl,0		;HL holds line count
	call initps	;initialize for pass through text
	sta nlflag	;enable null line numbering

	call crlf	; leading blank lines
	call crlf

ploop:	call gndch	;get next significant character
	or a
	jp nz,ploop1

ploopd:	call crlf	;end of file.
	pop af		;restore RED file output status
	sta werrs
	ret		;all done.

ploop1:	cp cr
	jp nz,ploop2
	call ckabrt	;check for control-C on console
	lda nlflag	;ok to number null lines?
	or a
	jp nz,ploop7	;print empty line number on first null line in	
	ld a,1		; a series of null lines, but not on rest of them.
	sta nlflag
	call number
	jp ploop7

ploop2:	cp modbeg	;start of module?
	jp nz,ploop3
	shld nlcnt	;save line count for pushmn to use
	push de		;save ptr to filename
	call pushmn	;process start of include file.
	call crlf
	call indnt	;indent for new module name
	call indnt	;  extra indentation lines name up with text
	ex de,hl		;save current DE in HL
	pop de		;get filename
	call pfnam2	;print out module name
	ex de,hl		;put text ptr back in DE
	ld a,':'
	call outch
	ld hl,0		;clear new line count
	jp ploop

ploop3:	cp modend	;and of module?
	jp nz,ploop4

	call popmn	;process end-of-module by putting out
	call crlf	;an extra cr-lf for readability.
	lhld nlcnt	;restore line count from where popmn put it
	jp ploop


ploop4:	call number	;number the new line
ploop5:	cp 255
	jp z,ploop6	;don't print filler bytes
	call outch
ploop6:	ld a,(de)		;put out the line
	inc de
	or a
	jp z,ploopd
	cp cr
	jp nz,ploop5
	xor a
	sta nlflag	;enable numbering of next null line

ploop7:	inc hl
	jp ploop

;
; Get next char of text at DE, but if there's nothing but trash
; between it and the end of the line, just return the CR:
;

gndch:	ld a,(de)
	inc de
	cp 255
	jp z,gndch	;ignore FF's
	call twsp	;is next char white space?
	ret nz		;if not, must use it.
	push af	;else if rest of the stuff on the line is trash
	push de
	call tnbcr	;is it?
	jp z,gndch2
	pop de		;no, there's more useful stuff. 
	pop af
	ret

gndch2:	pop af		;no more useful stuff. return a CR
	pop af
	inc de		;and pass over the CR.
	ld a,cr
	ret	


;
; Return Z set if there's nothing but trash until the end of the line:
;

tnbcr:	ld a,(de)
	cp cr		;return?
	ret z		;if so, NOT a garbage character
	call twsp	;white space?	
	ret nz		;if not, not a garbage char
	inc de
	jp tnbcr	;else keep scanning line for cr or non-space.

;
; Number the current pitext line:
;

number:	push af
	call crlf
	call indnt	;indent 2 spaces per module stacking
numb2:	push hl
	xor a		;all line numbers take 4 characters
	call prhcs
	pop hl
	pop af
	ret

;
; Indent according to module stack count (2 spaces per module):
;

indnt:	lda modstc	;get module nesting count
	dec a		;print (A-1)*3 spaces
	ld b,a
	add a
	add b
	inc a
	ld b,a
indnt1:	dec b
	ret z
	ld a,' '
	call outch
	jp indnt1

;
; Perform constant substitutions, keyword encodings,
; and string constant encodings:
;

pass1:	call initps	;initialize for pass
	dec de
ps1a:	inc de
ps1b:	call nextch	;process current char, return Cy on EOF
	ret c		;done if EOF

ps1ba:	cp '"'		;string to be processed?
	jp z,psstg

	push de		;no. constant?
	push bc

	ld a,1		;force error reporting on bad constant
	sta bcnstf
	call const
	ld a,0
	sta bcnstf	;turn bad constant reporting back off

	ld a,c
	pop bc
	pop de

	jp c,ps1c		;if not a constant, do potential keyword substitutions

	sub 3		;it was a constant.  substitute a constant code 
	call mvtxt	; for the text of the constant.
	ld a,concd	;key byte
	ld (de),a
	inc de
	ld a,l		;low order byte of value
	ld (de),a
	inc de
	ld a,h		;high order byte of value
	ld (de),a
	jp ps1a

;
; Try to match the keyword at DE (whose first char
; is in A, already converted to upper case) with an
; entry in the keyword table. Hashing is used on the
; bits 0-3 of the first character. If no match is found
; and the first character was NOT a legal identifier
; character, then a syntax error occurs; else it is
; assumed the string is an identifier and it is left
; alone.
;

ps1c:	ld a,b
	cp 05fh	;underscore?
	jp z,ps1h		;if so, assume identifier
	cp 'A'		;legal identifier char?
	jp c,ps1c3
	cp 'Z'+1
	jp c,ps1c2
	scf		;no. set carry for later.
	jp ps1c3

ps1c2:	xor a		;yes, legal ident. char.
ps1c3:	push af	;now let's do some hashing...
	ld a,b		;get 1st char of test string
	rlca
	and 1eh
	push bc
	ld c,a
	ld b,0		;BC = disp into hash table
	ld hl,khasht	;HL = start of table
	add hl,bc		;HL = address of sublist
	ld a,(hl)	
	inc hl
	ld h,(hl)
	ld l,a		;HL -> sublist
	pop bc
ps1d:	ld a,(hl)		;done searching list?
	cp 255
	jp z,ps1g
	and 7fh		;no. 1st char match?
	cp b		;if not, don't bother comparing
	jp nz,ps1f	;	rest of string
	push bc		;OK, compare rest of string!
	call stcmp
	ld a,c		;save length of strings
	pop bc
	jp nz,ps1f	;if no match, keep searching
	ld c,a		;match...restore length into C
	pop af		;clean up stack
	ld a,(hl)		;get 1 byte code into text
ps1e:	ld (de),a
	inc de	
	dec c
	jp z,ps1b
	ld a,0ffh	;and fill out space with FF's
	jp ps1e

ps1f:	ld a,(hl)		;go to next table entry
	inc hl
	or a
	jp ps1f
	inc hl
	jp ps1d

ps1g:	pop af		;search failed. could it have
	jp nc,ps1h	; been an identifier?
	ld hl,stg99	;no: must be syntax error.
	call perr
	jp ps1a

ps1h:	ld a,(de)		;possible identifier; let it be
	call varch
	jp c,ps1b
	inc de
	jp ps1h


;
; process a string constant:
;

psstg:	push de
psstg1:	call glbl
	ld a,l
	cp 1ah
	jp z,psstg1
	ex de,hl
	lhld eofad
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	shld stgcct
	inc hl
	pop de
	push de
	xor a
	ld c,a
	sta scc
psstg2:	inc de
	ld a,(de)

	or a
	jp z,pstger	;if EOF, REALLY missing quote.

	cp '"'
	jp z,psstg3
	cp cr
	jp z,pstger	;if CR in text, error.
	cp newlin	;same for newlin
	jp z,pstger
	call stgelt
	ld (hl),a
	call ckov
	inc hl
	push hl
	ld hl,scc
	inc (hl)
	pop hl
	jp nz,psstg2

pstger:	ld hl,stgmq
	jp fatal

psstg3:	shld eofad
	ld (hl),1ah
	lhld stgcct
	lda scc
	ld (hl),a		;set length byte for string
	pop hl		;get start of string
	push hl
	call cmh
	add hl,de
	ld de,78
	call cmphd	;is HL < 78?
	jp nc,pstg3a	;if not, do big squish

	ld a,l		;else do normal mvtxt
	sub 2
	pop de
	call mvtxt
	jp pstg3b

pstg3a:	dec hl		;do big squish
	dec hl		;now HL is # of bytes to squish
	pop de
	call bsqsh	;big squish routine

pstg3b:	ld a,strcd
	ld (de),a
	inc de
	lhld lbln
	dec hl
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	inc de

	ld b,0
	lhld nlcnt
	add hl,bc
	shld nlcnt

	inc c
psstg4:	dec c
	jp z,ps1b
	ld a,negone
	push bc
	call mvtxt
	pop bc
	ld a,nlcd
	ld (de),a
	inc de
	jp psstg4

bsqsh:	push de
	ld de,80
	call cmphd	;is HL < 80?	
	jp c,bsqsh2
	ld de,-79
	add hl,de
	pop de
	call bsqsh	;bsqsh(HL-79);
	ld hl,79
	call bsqsh
	ret

bsqsh2:	pop de
	ld a,l
	call mvtxt
	ret

;
; Get next string element, set carry if EOF encountered:
;

stgelt:	cp '\'
	ret nz
	inc de
	ld a,(de)
	cp '"'
	ret z
	cp 0ffh
	jp nz,stglt2
stglt0:	inc de
	ld a,(de)
	cp 0ffh
	jp z,stglt0
	inc c
stglt1:	inc de
	ld a,(de)
	cp 0ffh
	jp z,stglt1
	jp stgelt

stglt2:	push hl
	dec de
	call chkesc
	pop hl
	dec de
	ret

;
; Check for escape sequence at text at DE:
;

chkesc:	ld a,(de)
	cp '\'
	scf
	inc de
	ret nz		;did we see a backslash?
	ld a,(de)		;yes. save the next character for later retrieval
	inc de		;and point to character after that
	sta esctmp
	call mapuc
	cp 'N'		;check for special escape codes. \n?
	jp nz,esc2
	ld a,newlin
	ret
esc2:	cp 'T'		;\t?
	jp nz,esc3
	ld a,ht	;if so, turn into tab
	ret
esc3:	cp 'B'		;\b?
	jp nz,esc4
	ld a,bs	;if so, turn into backspace
	ret
esc4:	cp 'R'		;\r?
	jp nz,esc5
	ld a,cr	;if so, turn into carriage return
	ret
esc5:	cp 'F'		;\f?
	jp nz,esc6
	ld a,ff	;if so, turn into formfeed
	ret
esc6:	cp '\'		;if \\, return \ character
	ret z
	cp 27h		;if \', return ' character
	ret z
	call odig2	;otherwise check for octal digit
	jp nc,esc7
	lda bcnstf	;report constant errors?
	or a
	lda esctmp	;if not octal digit, use the character and ignore the
	ret z		; backslash, unless we need to report an error...
esc6a:	ld hl,stg8a	;bad octal constant error.
	jp cnst2b


esc7:	ld l,a		;OK, we have an octal digit. Put into L
	ld a,(de)		;look at next character
	call odig2	;octal digit?
	ld h,a		;save in H
	ld a,l		;get first digit
	jp c,esc8		;if second character not octal digit, go finish up
	ld a,h		;otherwise get second digit
	inc de		;point to potential third digit
	call shfto	;shift first digit to left
	ld a,(de)		;look at potential third digit
	call odig2	;is it octal?
	ld h,a		;save in H in case it is
	ld a,l		;get total of first two digits
	jp c,esc8		;finish up  if no third digit
	ld a,h		;get third digit
	inc de		;point to character after third digit (closing qoute?)
			;and add third digit to the sum.

shfto:	ld h,a		;this little routine adds the octal digit in H to
	ld a,l		;the octal value in L, after multiplying the value
	rlca		;in L by 8.
	rlca
	rlca
	add h
	ld l,a
	ret

esc8:	push af	;we've seen an illegal octal digit. if bcnstf is
	ld a,(de)		;true and the current character isn't a quote, then
	cp ''''	;report an error. Else just return the value.
	jp z,esc9		;Do we see a quote?
	lda bcnstf	;no...
	or a
	jp z,esc9		;is bcnstf true?
	pop af		;yes, so report error
	jp esc6a

esc9:	pop af		;don't need to report error; simply return value
	ret

odig2:	cp '0'
	ret c
	cp '8'
	ccf
	ret c
	sub '0'
	ret


;
; Look at current text at DE. If a constant is seen, return NC with
; the value of the constant in HL and C containing the length of the
; text of the constant. Else, return C set:
;

const:	ld a,(de)
	cp ''''	;character constant?
	jp z,chcnst	;if so, go handle it elsewhere

	call digt	;a decimal digit?
	ret c		;if not, then it isn't the start of any constant
			;else it is.
	ld c,0		;clear character count
	ld hl,0		;and clear accumulated value
	or a		;first digit a zero?
	jp nz,deccn	;if not, go handle decimal constant
	inc de		;yes. look at next character after the zero.
	ld a,(de)
	inc c		;and bump length count
	call mapuc
	cp 'X'		;hex constant?
	jp z,hexcn	;if so, go handle it
	dec c		;else must be an octal constant or 0. go back to
	dec de		;the zero and let the octal handler take care of it.
	xor a
	jp octcn

cnst2a:	ld hl,stg8	;come here to diagnose constant errors.
cnst2b:	call perr	;print the error
	scf		;set carry to indicate a bad happenning
	ret

hexcn:	inc de		;process a hex constant
	ld a,(de)		;look at next digit
	call tsthd	;hex?
	jp c,cnst2a	;if not, there weren't any legal digits, so complain
	dec de		;otherwise begin accumulating
hexcn1:	inc de		;go to next character
	inc c		;bump count
	ld a,(de)
	call tsthd	;legal hex digit?
	jp c,octcn1	;if not, all done
	add hl,hl		;else shift previous sum left by 4
	add hl,hl
	add hl,hl
	add hl,hl
	add l
	ld l,a		;add new digit
	jp hexcn1	;and go for more

octcn:	add hl,hl		;process an octal constant
	add hl,hl
	add hl,hl
	add l
	ld l,a	
	inc de
	inc c
	ld a,(de)
	call odigt
	jp nc,octcn
	ld a,(de)		;see if this is a hex or decimal digit in an octal #...
	call tsthd
	jp c,octcn1	
	ld hl,stg8a
octcn0: call perr
octcn1:	xor a
	ret

deccn:	push de		;process a decimal constant..push text pointer
	inc c		;bump char count
	ld d,h
	ld e,l		;lde previous sum to DE
	add hl,hl		;multiply previous sum by 10
	add hl,hl
	add hl,de
	add hl,hl
	ld e,a		;add new digit
	ld d,0
	add hl,de
	pop de		;get back text pointer
	inc de
	ld a,(de)		;look at next digit
	call digt
	jp nc,deccn	;decimal digit? if so, go process it
	ld a,(de)		;else check for a common error, a hex digit
	call tsthd
	jp c,octcn1	;if it isn't, no problem
	ld hl,stg8b	;else complain about illegal decimal digit
	jp octcn0

;
; Evaluate character constant at DE, and print an error if no closing
; quote found:
;

chcnst:	call chcnst1
	jp c,cnst2a
	ret

chcnst1:  push de
	ld b,0
	inc de
	call chkesc
	ld c,a
	ld a,(de)
	cp ''''
	jp z,chcns3
	call chkesc
	ld b,a
	ld a,(de)
	cp ''''
	jp z,chcns3
	pop hl
	scf
	ret

chcns3:	inc de
	pop hl
	call cmh
	add hl,de
	ld h,b
	ld b,l
	ld l,c
	ld c,b
	xor a
	ret


digt:	call mapuc
	sub '0'
	cp 10
	ccf
	ret

tsthd:	call digt
	ret nc
	sub 7
	cp 10
	ret c
	cp 16
	ccf
	ret

odigt:	call digt
	ret c
	cp 8
	ccf
	ret



;
; This routine gets next character from text area, returning Cy set
; if EOF encountered, Z set if byte is to be ignored,  and properly
; handling MODBEG, MODEND and line count via NLCNT:
;

nextch:	ld a,(de)
	cp 0ffh	;ignore FF (filler) bytes
	jp z,nextc5

	or a		;zero byte indicates EOF
	scf		;set Cy for EOF
	ret z

	cp modbeg	;adjust line number processing for include files
	jp nz,nextc2
	inc de
	call pushmn
	jp nextch	;and go for next char

nextc2:	cp modend
	jp nz,nextc3
	call popmn
	jp nextc5	;and go for 'nother char

nextc3:	call mapuc
	ld b,a
	cp cr
	jp nz,nextc4	;if not CR, all done...return the char

	call ckabrt	;found CR: check for abortion at end of every line
	call bumpnl
nextc4:	or a		;clear Cy
	ret

nextc5:	inc de		;internal looping point for nextch
	jp nextch


;
; Process all labels in the source file.
;

lblpr:
	ld a,1
	sta mapucv	;DON'T map to upper case in stcmp routine
	call initps
	dec de
lblp1:	inc de
	call pascd
	cp lbrcd	; '{' for start of new function?
	jp nz,lblp2
	push de		;yes. 
	lhld nlcnt
	shld savnlc	;save line number of function start for error reports
	push hl
	call flblp	;find labels
	pop hl
	shld nlcnt
	pop de
	call flblv	;resolve labels.
	call ckabrt	;check for using typing control-C
	jp lblp1

lblp2:	or a		;EOF?
	jp nz,lblp1	;if not, go for more text.
	xor a
	sta mapucv	;restore stcmp to normal map-to-upper-case mode
	ret		;yes. all done.

;
; Find labels in a function.
;

flblp:	ld hl,lblt
	shld lblp
	ld (hl),0
	xor a
	sta clev
	dec de
flp0:	inc de
flp1:	call pascd
	jp nz,flp1a	;EOF before function ends?
			;if so...
lblerr:	lhld savnlc	;put start of function into line number register
	shld nlcnt
	lhld modstp	;advance module stack ptr to cancel popping at EOF
	ld de,14
	add hl,de
	shld modstp
	ld hl,stgsuf	;screwed-up function message
	jp fatal

flp1a:	cp lbrcd	; '{'?
	jp nz,flp2
	ld hl,clev	;yes. bump level count.
	inc (hl)
	jp flp4

flp2:	cp rbrcd	; '}' ?
	jp nz,flp3
	ld hl,clev	;yes. decrement level count.
	dec (hl)
	jp nz,flp4	;done with funciton?
	ret		;if so, return.

flp3:	cp elscd	;look for keywords.
	jp z,flp4
	cp docd
	jp z,flp4
	cp semi
	jp nz,flp0	;pass expressions.

flp4:	inc de		;check for identifier.
	call igsht
	call varch	;legal first char?
	jp c,flp1
	push de		;yes. save text ptr.
	ld c,0		;init char count
flp5:	inc de
	ld a,(de)
	inc c
	call varch	;still an ident?
	jp nc,flp5
flpwsp:	cp 255		;no. ignore trailing spaces
	jp nz,flpcln	;if no more spaces, check for colon	
	inc de		;else pass over the space
	ld a,(de)		;get next char
	inc c		;bump count
	jp flpwsp	;and keep looking for non-space

flpcln:	cp colon	;no. followed by a colon?
	pop hl		;pop start of label into HL
	jp nz,flp1
	ex de,hl		;put start of label ptr into DE
	push de		;push it
	push bc		;push count
	push bc		; a few times
	push de		;and push label ptr again
	xor a
	sta sf
	call flbl
	pop de		;restore label ptr in DE
	pop bc		;restore count into C
	jp c,flp5a
	ld hl,stgml	;all labels must be unique
	call perr
	ld hl,sf
	inc (hl)
flp5a:	lhld lblp	;store the label away
flp6:	ld a,(de)
	dec c
	jp z,flp7
	cp 255		;don't save space as part of the name
	jp z,flp6a	
	ld (hl),a
	inc hl
flp6a:	inc de
	jp flp6

flp7:	cp 255		;last char space?
	jp nz,flp7a	;if not, treat normally
	dec hl
	ld a,(hl)		;else get last legit char	
flp7a:	or 80h
	ld (hl),a
	inc hl
	ex de,hl
	lhld lbln
	ex de,hl
	ld (hl),e	
	inc hl
	ld (hl),d
	inc hl
	lda sf
	or a
	jp nz,flp8
	shld lblp
	ld (hl),0
flp8:	pop bc
	pop de
	ld a,c
	sub 2
	call mvtxt
	call glbl
	ld a,lblcd
	ld (de),a
	inc de
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	jp flp4

stgml:	db 'Duplicate label+'

;
; Resolve label references:
;

flblv:	dec de
	xor a
	sta clev
flv0:	inc de
	call pascd
	jp z,lblerr	;if EOF, go complain

	cp lbrcd
	jp nz,flv1
	ld hl,clev
	inc (hl)
	jp flv0

flv1:	cp rbrcd
	jp nz,flv2
	ld hl,clev
	dec (hl)
	jp nz,flv0
	ret

flv2:	cp gotcd	;"goto" keyword?
	jp nz,flv0
	inc de		;yes.
	call flbl	;label entered in table?
	jp nc,flv5	;if so, go process
	ld hl,stg26
	call perr
	push de
	ld c,0
flv3:	ld a,(de)
	call varch
	jp c,flv4
	inc de
	inc c
	jp flv3

flv4:	pop de
flv5:	call lblsb	;do substitution
	jp flv0

;
; Find label in label table:

flbl:	call igsht
	ld hl,lblt
flbl2:	ld a,(hl)
	or a
	scf
	ret z
	call stcmp
	ret z

flbl3:	ld a,(hl)		
	or a
	inc hl
	jp flbl3
	inc hl
	inc hl
	jp flbl2

lblsb:	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	ld a,c
	sub 3
	push hl
	call mvtxt
	pop hl
	ld a,labrc
	ld (de),a
	inc de	
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	ret


stcmp:	push de
	push hl
	ld c,1
stcp1:	ld a,(hl)
	and 7fh
	call mapuc0
	ld b,a
	ld a,(de)
	call mapuc0
	cp b
	jp z,stcp2
stcp1a:	pop hl
	pop de
	xor a
	inc a
	ret
stcp2:	ld a,(hl)
	or a
	inc hl
	jp m,stcp3
	inc de
	inc c
	jp stcp1
stcp3:	ld a,b
	call varch
	jp nc,stcp4
stcp3a:	xor a
	pop de
	pop de
	ret
stcp4:	inc de
	ld a,(de)
	call varch
	ccf
	jp c,stcp1a
	jp stcp3a


;
; This section of code (PASS X) goes through the code and
; simplifies all constant expressions. Any code following
; an open bracket ("["), open parenthesis, "case" keyword,
; or assignment operator is checked to see if it is a 
; constant expression. If so, it is replaced by its simple
; constant equivalent. 
;

passx:	call initps
	dec de
psx1:	inc de
	call igsht
	call cdtst
	jp c,psx1z
	inc de
	inc de
	jp psx1
psx1z:	inc de
	or a
	ret z
	cp comma
	jp z,psx1a
	cp openb
	jp z,psx1a
	cp open
	jp z,psx1a
	cp cascd
	jp z,psx1a
	cp rencd
	jp z,psx1a
	call asgnop
	jp z,psx1a
	dec de	
	jp psx1

psx1a:	call ckabrt	;check for using typing control-C
	push de
	ld hl,opstk
	shld opstp
	ld (hl),0
	ld hl,valstk
	shld valsp
	call ckce
	jp nc,psx2
	pop de
	call igsht
	call cdtst	
	jp c,psx1
	inc de
	inc de
	jp psx1

psx2:	ex (sp),hl
	ex de,hl
	dec hl
	dec de
	ld c,0

psx2a:	inc de
	ld a,(de)
	cp nlcd
	jp nz,psx2b
	inc c
psx2b:	ld a,0ffh
	ld (de),a
	ld a,l
	cp e
	jp nz,psx2a
	ld a,h
	cp d
	jp nz,psx2a
	pop hl
	ld a,concd
	dec de
	dec de
	ld (de),a
	inc de
	ld a,l
	ld (de),a
	inc de
	ld a,h
	ld (de),a
	ld a,c
	or a
	jp z,psx1
	inc de
	ld a,c
	cpl
	inc a
	push bc
	push hl
	call mvtxt
	pop hl
	pop bc
	ld a,nlcd

psx2c:	ld (de),a
	inc de
	dec c	
	jp nz,psx2c
	dec de
	jp psx1

;
; This routine looks at text at DE and returns C reset
; if there is a legal constant expression there, with
; the value in HL; else C is set. DE is left pointing to
; the end of the expression, or wherever it became illegal.
;

ckce:	call ckce2
	ret c
	call igsht
	cp 0c0h
	jp z,qexpr
	or a
	ret

ckce2:	push de
	call psce
	pop de
	ret c
	call binop
	jp z,bexpr
	call sce
	ret

;
; Pass over a simple constant expression:
;	unop sce
;	sce
;

psce:	call igsht
	cp mincd
	jp z,psce2
	cp circum
	jp z,psce2
	call pvsce
	ret

psce2:	inc de
	jp psce

;
; Pass very simple constant expression:
;	(ce)
;	constant
;

pvsce:	cp open
	jp nz,pvsce2
	call mtchp
	call igsht
	or a
	ret

pvsce2:	cp concd
	scf
	ret nz
	inc de
	inc de
	inc de
	call igsht
	or a
	ret

;
; process ?: expression:
;

qexpr:	inc de
	ld a,h
	or l
	jp z,qexp2
	call ckce
	ret c
	cp colon
	scf
	ret nz
	inc de
	push hl
	call ckce
	pop hl
	ret

qexp2:	call psce
	cp colon
	scf
	ret nz
	inc de
	call ckce
	ret

;
; process simple constant expression:
;	unop sce
;	sce
;

sce:	call igsht
	cp mincd
	jp nz,sce2
	inc de
	call sce
	ret c
	call cmh
	or a
	ret

sce2:	cp circum
	jp nz,sce3
	inc de
	call sce
	ret c
	call cmh
	dec hl
	or a
	ret

sce3:	call vsce
	ret

;
; process very simple constant expression:
;	constant
;	(ce)
;

vsce:	cp open
	jp nz,vsce2
	inc de
	call ckce
	ret c
	call igsht
	cp close
	scf
	ret nz
	inc de
	ccf
	ret

vsce2:	cp concd
	scf
	ret nz
	inc de
	ld a,(de)
	ld l,a
	inc de
	ld a,(de)
	ld h,a
	inc de
	call igsht
	or a
	ret

;
; handle binary expression:
;  sce binop sce binop sce ...
;

bexpr:	xor a
	call oppsh
	call sce
	ret c
	call pshh
	call oppop
bxprab:	call igsht
	call binop
	jp z,bxpr2

bxpr1:	call tstop
	jp z,bxpr5
	call popb
	call poph
	call oppop
	call alugen
	call pshh
	jp bxpr1

bxpr2:	call tstop
	jp z,bxpr3
	ld c,b
	call binop
	ld a,c
	cp b
	jp z,bxpr4
	jp c,bxpr4

bxpr3:	ld a,(de)
	call oppsh
	inc de
	jp bexpr

bxpr4:	call popb
	call poph
	call oppop
	call alugen
	call pshh
	jp bxprab

bxpr5:	call poph
	xor a
	ret

oppsh:	push hl
	lhld opstp
	inc hl
	shld opstp
	ld (hl),a
	pop hl
	ret

oppop:	push hl
	lhld opstp
	ld a,(hl)
	dec hl
	shld opstp
	pop hl
	ret

tstop:	push hl
	lhld opstp
	ld a,(hl)
	or a
	pop hl
	ret

popb:	push hl
	call poph
	ld b,h
	ld c,l
	pop hl
	ret

poph:	lhld valsp
	push de
	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	shld valsp
	ex de,hl
	pop de
	ret

pshh:	push de
	ex de,hl
	lhld valsp
	inc hl
	ld (hl),e
	inc hl
	ld (hl),d
	shld valsp
	ex de,hl
	pop de
	ret




binop:	ld b,9
	cp mulcd
	ret z
	cp divcd
	ret z
	cp modcd
	ret z
	dec b
	cp plus
	ret z
	cp mincd
	ret z
	dec b
	cp 0b0h
	ret z
	cp 0b1h
	ret z
	dec b
	cp 0b9h
	ret z
	cp 0bah
	ret z
	cp 0aeh
	ret z
	cp 0afh
	ret z
	dec b
	cp 0aah
	ret z
	cp 0abh
	ret z
	dec b
	cp ancd
	ret z
	dec b
	cp 0bch
	ret z
	dec b
	cp 0bdh
	ret

asgnop:	cp letcd
	ret z
	cp 0a0h
	ret c
	cp 0aah
	jp c,asgn2
	xor a
	inc a
	ret

asgn2:	xor a
	ret


alugen:	cp mulcd	;*
	jp nz,alu2
alu1s:	call initsn	;initialize sign memory
	push de
	ex de,hl
	ld hl,0
alu1a:	ld a,b
	or c
	jp nz,alu1b
	call aplysn	;apply sign memory to result
	jp adone
alu1b:	add hl,de
	dec bc
	jp alu1a

initsn:	xor a
	sta signm	;clear sign memory
	push hl

	ld h,b
	ld l,c
	call tests	;test BC for negativity
	ld b,h
	ld c,l

	pop hl
	call tests	;test HL for negativity
	ret

aplysn:	lda signm	;if signm true, negate HL
	or a
	ret z
	call cmh
	ret

tests:	ld a,h		;if HL is positive, do nothing
	or a
	ret p
	call cmh	;else negate HL
	lda signm	;and reverse sense of sign memory byte
	or a
	ld a,1
	jp z,tests2
	xor a
tests2:	sta signm
	ret	

alu2:	cp divcd	;/
	jp nz,alu3
alu2s:	call initsn
	push de
	ex de,hl
	ld hl,0
alu2a:	ld a,d
	cp b
	jp c,alu2c
	jp nz,alu2b
	ld a,e
	cp c
	jp c,alu2c
alu2b:	push hl
	ld h,b	
	ld l,c
	call cmh
	add hl,de
	ex de,hl
	pop hl
	inc hl
	jp alu2a
alu2c:	call aplysn
	jp adone

adone:	pop de
	ret

alu3:	cp modcd	;%
	jp nz,alu4
	ld a,h
	or a		;check sign of 1st operand
	push af	;save for final result sign computation

	call initsn	;make sure mod is computed on positive numbers
	xor a		;zero sign memory to force unsigned result
	sta signm
	push de
	push hl
	push bc
	call alu2s
	pop bc
	call alu1s
	call cmh
	pop de
	add hl,de
	pop de

	pop af		;get sign of original 2nd operand
	ret p		;if it was positive, leave result positive
	call cmh	;otherwise negate result	
	ret

alu4:	cp plus	;+
	jp nz,alu5
	add hl,bc
	ret

alu5:	cp mincd	;-
	jp nz,alu6
	push de
	ex de,hl
	ld h,b
	ld l,c
	call cmh
	add hl,de
	pop de
	ret

alu6:	cp 0b0h	;<<
	jp nz,alu7
alu6a:	ld a,b
	or c
	ret z
	add hl,hl
	dec bc
	jp alu6a

alu7:	cp 0b1h	;>>
	jp nz,alu8
alu7a:	ld a,b
	or c
	ret z
	ld a,h
	rra 	
	ld h,a	
	ld a,l
	rra
	ld l,a
	dec bc	
	jp alu7a

alu8:	cp 0bah		;<
	jp nz,alu9
alu8a:	ld a,h
	cp b
	ld a,l
	ld hl,1
	ret c
	dec hl
	ret nz
	cp c
	ret nc
	inc l
	ret

alu9:	cp 0b9h	;>
	jp nz,alu10
alu9a:	ld a,b
	cp h
	ld b,l
	ld hl,1
	ret c
	dec hl
	ret nz
	ld a,c
	cp b
	ret nc
	inc l
	ret

alu10:	cp 0aeh	;<=
	jp nz,alu11
	call alu9a
alu10a:	ld a,h
	or l
	dec hl
	ret nz
	inc hl
	inc hl
	ret

alu11:	cp 0afh	;>=
	jp nz,alu12
	call alu8a
	jp alu10a

alu12:	cp ancd
	jp nz,alu13
	ld a,h
	and b
	ld h,a
	ld a,l
	and c
	ld l,a
	ret

alu13:	cp 0bch	;^
	jp nz,alu14
	ld a,h
	xor b
	ld h,a
	ld a,l
	xor c
	ld l,a
	ret

alu14:	cp 0bdh	;|
	jp nz,alu15
	ld a,h
	or b
	ld h,a
	ld a,l
	or c
	ld l,a	
	ret


alu15:	cp 0aah	;==
	jp nz,alu16
	ld a,h
	cp b
	jp nz,fals
	ld a,l
	cp c
	jp nz,fals
tru:	ld hl,1
	ret

alu16:	ld a,h		;<not>=
	cp b
	jp nz,tru
	ld a,l
	cp c
	jp nz,tru
fals:	ld hl,0
	ret


;
; Table of hash addresses for each of the 16
; keyword sub-tables:
;

khasht:	dw tbl0,tbl1,tbl2,tbl3
	dw tbl4,tbl5,tbl6,tbl7
	dw tbl8,tbl9,tbla,tblb
	dw tblc,tbld,tble,tblf

p:	equ 80h

tbl0:	db ' '+p,0ffh	;spaces turn into FF's
	db  255
		

tbl1:	db '!','='+p,0abh
	db '!'+p,0bfh
	db 255

tbl2:	db 'RETUR','N'+p,8eh
	db 'BREA','K'+p,90h
	db 'REGISTE','R'+p,9eh
	db 'BEGI','N'+p,9bh
	db 255

tbl3:	db 'CHA','R'+p,80h
	db 'CONTINU','E'+p,91h
	db 'CAS','E'+p,98h
	db 'STRUC','T'+p,8bh
	db 'SWITC','H'+p,97h
	db 'SIZEO','F'+p,8fh
	db 'SHOR','T'+p,9fh
	db 255

tbl4:	db 'D','O'+p,95h
	db 'DEFAUL','T'+p,99h
	db 255

tbl5:	db 'ELS','E'+p,93h
	db '%','='+p,0a4h
	db '%'+p,0b8h
	db 'UNSIGNE','D'+p,82h
	db 'UNIO','N'+p,8ch
	db 'EN','D'+p,9ch
	db 255

tbl6:	db '&','&'+p,0ach
	db '&','='+p,0a7h
	db 'FO','R'+p,94h
	db '&'+p,0bbh
	db 'VOI','D'+p,81h		;synonym for "int"
	db 255

tbl7:	db 'WHIL','E'+p,96h
	db 'GOT','O'+p,8dh	;boo-hissssss
	db 255

tbl8:	db '('+p,0c2h
	db 255

tbl9:	db ht+p,0ffh
	db ')'+p,0c3h
	db 'I','F'+p,92h
	db 'IN','T'+p,81h
	db 255

tbla:	db ':'+p,0cah
	db '*','='+p,0a2h
	db '*'+p,0b6h
	db 255

tblb:	db ';'+p,0c6h
	db '{'+p,9bh
	db '['+p,0c8h
	db '+','+'+p,0b2h
	db '+','='+p,0a0h
	db '+'+p,0c4h
	db 255

tblc:	db ','+p,0c7h
	db '|','|'+p,0adh
	db '|','='+p,0a9h
	db '|'+p,0bdh
	db '<<','='+p,0a6h
	db '<','='+p,0aeh
	db '<','<'+p,0b0h
	db '<'+p,0bah
	db 255

tbld:	db cr+p,nlcd
	db ']'+p,0c9h
	db '}'+p,9ch
	db '=','='+p,0aah
	db '='+p,0beh
	db '-','>'+p,0b4h
	db '-','-'+p,0b3h
	db '-','='+p,0a1h
	db '-'+p,0b5h
	db 255

tble:	db '>>','='+p,0a5h
	db '>','='+p,0afh
	db '>','>'+p,0b1h
	db '>'+p,0b9h
	db '^','='+p,0a8h
	db '.'+p,0c5h
	db '^'+p,0bch
	db '~'+p,0cbh
	db 255

tblf:	db '?'+p,0c0h
	db '/','='+p,0a3h
	db '/'+p,0b7h
	db 255

;
; Data storge used by "readf":
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
