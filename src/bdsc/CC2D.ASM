

;
; cc2d.asm:
;
; Utility routines for expression evaluator:
;

;
; Lookup the identifier pointed to by HL in the
; symbol table, and set the following values
; according to the symbol table entry:
;	INDC1:	indirection count
;	TYP1:	type
;	STRSZ1:	size of structure (if structure)
;	DIMSZ1:	array information (if array), else
;		address of function (if function)
;	FRML1:	1 if formal argument, else 0
;	(DE):	relative address (relative to BC or extad)
;

lookup:	ld a,(hl)
	cp varcd
	call nz,ierror
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	call lookp2
	call igsht
	ret

lookp2:	push bc
	push hl
	ex de,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld de,st
	add hl,de
	ld a,(hl)

	push af	;flag using structure types as expressions
	and 3
	cp 2
	ld de,stg10
	call z,perr
	pop af

	rrca
	rrca
	rrca
	rrca
	and 87h
	ld b,a
	ld a,(hl)
	rrca
	rrca
	push af
	and 60h
	or b
	sta typ1
	pop af
	and 1
	sta frml1
	inc hl
	ld a,(hl)
	rlca
	rlca
	and 3
	sta indc1
	ld a,(hl)
	and 3fh
	ld a,1
	jp z,lp3
	dec a
lp3:	sta vext
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	push de
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl
	shld strsz1
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl
	shld dimsz1

	pop de
	lda frml1	;formal?
	or a
	jp z,lp3a		;if not, displacement value is OK
	lhld sfsiz	;else add sfsiz+4 to it
	add hl,de		;HL = sfsiz + local_addr
	ld de,4
	add hl,de		;HL = sfsiz + local_addr + 4
	ex de,hl		;put value back in DE

lp3a:	ld hl,0
	add hl,de
	add hl,de
	add hl,de
	lda typ1
	and 40h
	jp z,lp4
	shld dimsz1

lp4:	pop hl
	pop bc
	ret

;
; Push operator in A on operator stack:
;

oppsh:	push hl
	lhld opstp
	inc hl
	ld (hl),a
	shld opstp
	pop hl
	ret

;
; Pop off top entry in operator stack; Error
; if no operators on it:
;

oppop:	push hl
	lhld opstp
	ld a,(hl)
	cp 255
	jp z,opop1
	or a
	jp nz,opop2
opop1:	ld de,stg7
	call perr
	call fsemi
	pop hl
	ret

opop2:	dec hl
	shld opstp
	pop hl
	ret

;
; Pop off dummy op
;

oppops:	push hl
	lhld opstp
	dec hl
	shld opstp
	pop hl
	ret

;
; Look at top of operator stack. Return Z set
; (Z true) if no operators on the stack:
;

tstops:	push hl
	lhld opstp
	ld a,(hl)
	or a
	pop hl
	ret z
	cp 255
	ret


;
; Push information about operand 1 on the
; operand information stack:
;

pshn1:	push hl
	push af

	lhld indc1
	ex de,hl
	lhld infsp	;the info-SP
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld strsz1
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld dimsz1
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld sval1
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld svv1
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	lda frml1
	ld (hl),a
	inc hl

	shld infsp
	call chkovn	;check for info table overflow
	pop af
	pop hl
	ret

;
; Push information about operand 2 on the
; operand information stack:
;

pshn2:	push hl
	push af

	lhld indc2
	ex de,hl
	lhld infsp	;the info-SP
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld strsz2
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld dimsz2
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld sval2
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	ex de,hl
	lhld svv2
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl

	lda frml2
	ld (hl),a
	inc hl

	shld infsp
	call chkovn	;check for info table overflow
	pop af
	pop hl
	ret

;
; Check for info-table overflow by seeing if the pointer
; has overlapped into the relocation table area:
;

chkovn:	ld a,h
	cp relt/255	;if info pointer (hi) is less than the addr of the
	ret c		;rel table (hi), then no overflow
	jp nz,chkove	;if not same, then it has overflown
	ld a,l		;if same, check low order byte
	cp relt and 255
	ret c		;if not less than rel table low byte, error

chkove:	ld de,stgetc	;sub-expressions too deeply nested; complain and 
	jp perrab	;give up.

;
; Pop off operand information from the operand
; information stack; make it operand 1:
;

ppn1:	push hl
	push af
	lhld infsp
	dec hl

	ld a,(hl)
	sta frml1
	dec hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld svv1
	ex de,hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld sval1
	ex de,hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld dimsz1
	ex de,hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld strsz1
	ex de,hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	shld infsp
	ex de,hl

	shld indc1
	pop af
	pop hl
	ret

;
; Pop off information on operand 2:
;

ppn2:	push hl
	push af
	lhld infsp
	dec hl

	ld a,(hl)
	sta frml2
	dec hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld svv2
	ex de,hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld sval2
	ex de,hl

	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld dimsz2
	ex de,hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	dec hl
	ex de,hl
	shld strsz2
	ex de,hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	shld infsp
	ex de,hl
	shld indc2
	pop af
	pop hl
	ret

;
; lde operand 1 info into operand 2:
;

mvn12:	call pshn1
	call ppn2
	ret

;
; lde operand 2 info info operand 1:
;

mvn21:	call pshn2
	call ppn1
	ret


;
; Analyze the expression characterized by the variables
;	indc1,typ1,strsz1,dimsz1,frml1
; by setting the following variables accordingly:
;	AADRF:	true (non-zero) if an address;
;	ASNOKF:	true if it can be assigned to;
;	AMATHF:	true if it can have math done on it;
;	ASIZE:	if a pointer, size of the object pointed at;
;	AVAR:	true if a variable address (but not a pointer)
;

analyz:	push hl		;save text pointer
	call anal1	;perform analysis
	pop hl		;restore text pointer
	ret

anal1:	ld hl,1		;assume simple things at first.
	shld asize	;size of 1 byte
	shld subval	;initialize mulitplication accumulator
	xor a
	sta avar	;not a variable
	inc a
	sta amathf	;can do math
	sta asnokf	;ok to assign to it
	sta aadrf	;has an address

	call tstar	;is it an array?
	jp z,anal6
	call tptr	;no. pointer?
	jp z,anal6
	call tsval	;no. simple constant value?
	jp nz,anal3
	xor a		;yes. can't assign to it...
	sta asnokf
	sta aadrf	;and it aint an address.
	jp anal5a	;make size of it: 2

anal3:	call tsstr	;is it a simple struct base?
	jp nz,anal4	;if so,
	call anal8a	;set asize = size of one structure
anal3a:	xor a		;can't assign or do math to it.
	sta asnokf
	sta amathf
	ret

anal4:	call tptrf	;pointer to function?
	ret z		;all set if so.

anal5:	call tfun	;is it a function?
	jp z,anal11	;if so, set stuff appropriately.
	ld a,1		;else, must be a variable address.
	sta avar
	lda typ1
	or a
	ret z		;if char, return with asize = 1
anal5a:	ld hl,asize
	inc (hl)		;else bump asize to 2
	ret

anal6:	call t2dim	;2-dimensional array?
	jp nz,anal7
	lhld dimsz1	;yes. scale size of obj by 1st dim size
	shld subval
anal7:	lda typ1
	and 20h		;pointer to function?
	jp nz,anal7a
	lda indc1	;no.
	cp 3		;if pointer to pointer...
	jp nc,anal7a
	call tstar	;array of pointers?
	jp nz,anal8
	lda indc1
	cp 2
	jp nz,anal8
anal7a:	ld hl,2		;double object size
	call mult
	jp anal10

anal8:	lda typ1	;structure?
	cp 6
	jp nz,anal9

anal8a: lhld strsz1	;yes. scale obj size by size of struct
	call getsz	;look up size in symbol table
	call mult	;multiply by old object size
	jp anal10

anal9:	or a		;character?
	jp z,anal10
	ld hl,2		;no. must be 2-byte object.
	call mult
anal10:	lhld subval	;at last we have a final size.
	shld asize	;(subval was just an accumulator for
	call tstar	; the mult routine.)
	ret nz		;if not array, all done.
	lda frml1	;if so, only allow it to be assigned to
	or a		;if it isn't a formal parameter.
	ret nz
anal11:	xor a
	sta asnokf	;woops, its formal. Disallow assignment
	ret

;
; Perform same analysis for 2nd operand, leaving
; 1st operand info intact:
;

anal2:	call pshn1
	call mvn21
	call analyz
	call ppn1
	ret


;
; Perform internal indirection on the object as characterized
; above. By "internal" I mean that no code is generated;
; rather, pointers become lvalues, 2-dim arrays become 1-dim
; arrays, etc. Error if object isn't SOME kind of object that
; can have indirection performed on it; i.e, a constant.
;

indir:	push hl
	call ind1
	pop hl
	ret

ind1:	call tstar	;array?
	jp nz,ind3
	call t2dim	;yes. 2-dim?
	ld hl,0
	jp nz,ind2
	ld hl,0ff00h	;yes. change into 1-dim
ind2:	shld dimsz1
	ret

ind3:	call tptrf	;pointer to function?
	jp nz,ind4
	lda typ1	;yes. make into an actual function
	and 0dfh	;strip off ptr to func bit
	or 40h		;turn on function bit
	sta typ1	;and store new type
	xor a
	sta simpf	;NOT a simple function instance!
	ret

ind4:	call tfun	;is it a function?
	jp z,ind5		;if so, bad news.
	call tptr	; a pointer?
	jp nz,ind5
	lda indc1	;yes. de-bump indirection count by 1.
	dec a
	sta indc1
	ret

ind5:	ld de,stg21	;something is screwy in the state of
	jp perr	;confusion. (?)


;
; Type Testing functions....each of the following routines
; tests for some particular property, and returns Z true if
; the property is true for the expression described by
; INDC1,TYP1,etc...
;

tstar:	call tfun	;is expr an array?
	jp z,invrt	;if function, then not array.
	push hl		;look at dim size.
	lhld dimsz1
	ld a,h
	or l
	pop hl		; now Z set if NOT array

invrt:	jp z,invrt2	;invert Z flag.
	xor a		; if wasn't zero,
	ret		; set zero and return.
invrt2:	xor a		;else reset zero by clearing
	inc a		;and incrementing A.
	ret

;
; Test if expr is a 2 dimensional array
;

t2dim:	call tstar	;array?
	ret nz		;if not, certainly not a 2-dim array.
	lda dimsz1+1	;else look at high byte of dim size
	cp 0ffh	;this is special code for 1-dim array
	jp invrt	;if 1-dim, not 2-dim, and vice versa!

;
; Test if expr is a pointer to function (special case)
;

tptrf:	call tstar	;an array?
	jp z,invrt	;if so, not pointer to function
	call tfun	;if function,
	jp z,invrt	;not a pointer to one!
	lda typ1	;else look at the crucial bit
	and 20h
	jp invrt	;if set, then is a pointer to function

;
; Test if expr is any kind of pointer (including an array)
;

tptr:	call tfun	;function?
	jp z,invrt	;if so, not a pointer.
	call tptrf	;pointer to function?
	ret z		;if so, definitely a pointer
	call tstar	;array?
	ret z		;if so, implicitly a pointer.
	lda indc1	;else check indirection count
	cp 2
	ret c		;if <2, not pointer.
	xor a		;else is a pointer.
	ret

;
; Same as above for operand 2:
;

tptr2:	call pshn1
	call mvn21
	call tptr
	call ppn1
	ret

;
; Test if expr is a simple pointer (not pointer-to-pointer)
;
  
tsptr:	call tfun	;if function,
	jp z,invrt	;not pointer.
	call t2dim	;2-dim array?
	jp z,invrt	;if so, not simple pointer
	call tstar	;array?
	ret z		;if so, simple pointer.
	call tptrf	;pointer to function?
	ret z		;if so, simple pointer.
	lda indc1	;check indirection count
	cp 2		;if == 2, simple pointer.
	ret

;
; Test if expr is simple value (not address):
;

tsval:	call tstar	;if array,
	jp z,invrt	;not value.
	call tfun
	jp z,invrt	;no functions allowed.
	call tptr
	jp z,invrt	;no pointer either.
	call tsstr	;structure?
	jp z,invrt	;if so, sorry.
	lda indc1
	or a		;true only if no indirection.
	ret

;
; Same as above for 2nd operand:
;

tsval2:	call pshn1
	call mvn21
	call tsval
	call ppn1
	ret

;
; Test if simple character value
;

tschr:	call tsval	;if not simple value, not likely to
	ret nz		;be simple char value!
	lda typ1
	or a
	ret		;else is only if type is char.

;
; Same for 2nd operand
;

tschr2:	call tsval2
	ret nz
	lda typ2
	or a
	ret


;
; Test if expr is structure base
;

tsstr:	call tstar
	jp z,invrt	;if array, not structure.
	lda typ1
	cp 6
	ret nz		;if not struct, no good.
	lda indc1
	cp 2
	jp c,tstr1	;pointer?
	xor a		;yes. no good.
	inc a	
	ret
tstr1:	xor a		;no pointer; ok.
	ret


;
; Test if expr is a function
;

tfun:	lda typ1
	and 40h		;look at function bit.
	jp invrt	;if set, is a function.

;
; Test if expr is simple pointer to characters
;

tsptrc:	call tsptr	;simple pointer?
	ret nz		;if not, no good.
	call tptrf	;pointer to function?
	jp z,invrt	;if so, not pointer to char.
	lda typ1
	or a
	ret		;true only if type == char.

;
; Test if simple lvalue (as opposed to array or pointer)
;

tslv:	call tstar
	jp z,invrt	;arrays no good
	call tptrf
	jp z,invrt	;neither are ptrs to funcs
	lda indc1
	dec a
	ret nz		;no good if not lvalue
	lda typ1
	cp 6
	jp invrt	;and no good if struct.

;
; Test if simple character lvalue
;

tsclv:	call tslv
	ret nz		;no good if not simple lvalue
	lda typ1
	or a
	ret		;or if type not char

;
; The following routines "check" for some property, and
; spew an error message if the property is found to be
; lacking...
;

;
; Test to see if expr is a pointer or a value, and give
;   "Bad use of unary op" error if not. Obviously, this
;   routine is called from the unary operator processor.
;

ckaok:	call tptr	;pointer?
	ret z		;if so, OK

; This is the entry point for the check for "simple value only"

ckval:	call tsval	;simple value?
	ret z		;if so, OK
	ld de,stg13
	jp perr


;
; If A==2, it means that an lvalue was called for from an
; operator which cannot provide it. Bad news.
;

ckvok:	cp 2
	ret nz
	ld de,stg8
	call perr

;
; Give an error if both operands are not simple values.
;

ckval2:	call tsval	;is 1st a value?
	jp nz,ckv2e	;if not, trouble.
	call pshn1	;save info on 1st operand
	call mvn21	;give 1st operand 2nd operand's info
	call tsval	;so we can call tsval.
	call ppn1	;restore 1st operand's info
	ret z		;return if 2nd operand was value
ckv2e:	ld de,stg18	;woops.
	jp perr

;
; Logical branch table handler routines:
;

ltabmp:	push de		;bump ltab with new entry
	push hl
	lhld ltabp	;get logical table pointer  in HL
	ex de,hl		;put in DE

	ld hl,ltabp-5	;get pointer to end of logical table in HL
	call cmpdh	;make sure pointer is well below end of table
	jp c,ltbmp2	;if so, no problem...
	ld de,stgcsn	;control structure too deeply nested
	jp perrab
	
ltbmp2:
	call glbl
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	ex de,hl
	call glbl
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	ld (hl),0
	inc hl
	shld ltabp
	pop hl
	pop de
	ret

;
; Define true label at current position in code, if used bit
; for that entry is set:
;

ltabtd:	push hl
	push de
	lhld ltabp
	dec hl
	ld a,(hl)
	and 1
	jp z,ltbtd1
ltbtd0:	dec hl
	dec hl
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	call entl
ltbtd1:	pop de
	pop hl
	ret

;
; Force definition of true ltab entry:
;

fltbtd:	push hl
	push de
	lhld ltabp
	dec hl
	jp ltbtd0

;
; Define false label entry if appropriate used bit is set:
;

ltabfd:	push hl
	push de
	lhld ltabp
	dec hl
	ld a,(hl)
	or a
	jp p,ltbfd1
ltbfd0:	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	call entl
ltbfd1:	pop de
	pop hl
	ret

;
; Force definition of false label entry:
;

fltbfd:	push hl
	push de
	lhld ltabp
	dec hl
	jp ltbfd0

;
; Pop last entry off the ltab:
;

ltabpp:	push hl
	push de
	lhld ltabp
	ld de,-5
	add hl,de
	shld ltabp
	pop de
	pop hl
	ret

;
; Convert logical flag setting to value in DE:
;

cvtlvd:	lda sval1
	and 4
	ret z		;ignore if no flag set
	lda sval1	;(just fixed:OK -lz)
	and 20h		;if already have a value, put into DE if not 
	jp z,cvtvd1	;already there. so, do we have a value?
	lda sval1
	and 0c0h	;yes. is it already in DE?
	ret nz
	call gexdehl	;no, put it there
	lda sval1
	or 40h
	sta sval1	;tell that it's in DE
	ret
	
cvtvd1:	lda sbmap1	;else get the flag setting
	and 7
	add a,6
cvtvd2:	push de
	ld e,a
	ld d,0
	push hl
	ld hl,flagct
	add hl,de
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	call mcrog
	pop hl
	pop de
	ld a,1
	sta typ1
	lda sval1
	or 60h		;tell that we have a value in addition to
	sta sval1	;a flag setting.
	ret

;
; Convert logical flag setting to value in HL:
;

cvtlvh:	lda sval1
	and 4
	ret z
	lda sval1	;do we already have a value in a reg?
	and 20h
	jp z,cvtlh1
	lda sval1	;yes. if in HL, leave it there
	and 0c0h
	ret z
	call gexdehl	;else put into HL
	lda sval1
	and 3fh		;tell that result is in HL
	sta sval1
	ret

cvtlh1:	lda sbmap1
	and 7
	call cvtvd2
	and 3fh
	sta sval1
	ret

flagct:	dw macf1,macf2,macf3,macf4,macf4a,macf4b
	dw macf5,macf6,macf7,macf8,macf8a,macf8b

cjoptb:	db 0cah,0c2h,0dah,0d2h,0f2h,0fah,0c3h

;
; Generate conditional jump-on-true:
;

gncjt:	push hl
	lhld ltabp
	dec hl
	ld a,(hl)
	or 1
	ld (hl),a
	dec hl
	dec hl
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	ex de,hl
	shld sr0
	lda sval1		;constant?
	and 1
	jp z,gncjt2
	lhld svv1		;yes. do jump if true, else don't
	ld a,h
	or l
	pop hl
	ret z
gncjt1:	ld a,6
	jp gncjt3

gncjt2:	lda sval1		;flag setting?
	and 4
	pop hl
	jp z,gncjt4
	lda sbmap1		;yes. find which one and do it.
	and 7
gncjt3:	push hl
	ld e,a
	ld d,0
	ld hl,cjoptb
	add hl,de
	ld a,(hl)
	call genb
	ld de,mac36a
	call mcrog
	pop hl
	ret

gncjt4:	lda sval1		;lvalue?
	and 2
	jp nz,gncjt1		;if so, always generate a jump
	lda sval1		;value in DE?
	and 0c0h
	jp nz,gncjt6		;if so, go handle
	ld de,mac33		;do "ld a,h - or l - jp nz,sr0" if not char
	call tschr
	jp nz,gncjt5
	ld de,mac7a		;if char, do "ld a,l - or a - jp nz,sr0"
gncjt5:	call mcrog
	ret

gncjt6:	ld de,mac33d
	call tschr
	jp nz,gncjt5
	ld de,mac7ad
	jp gncjt5

;
; Generate conditional jump-on-false:
;

gncjf:	push hl
	lhld ltabp
	dec hl
	ld a,(hl)
	or 80h
	ld (hl),a
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	ex de,hl
	shld sr0
	lda sval1		;constant?
	and 1
	jp z,gncjf2
	lhld svv1		;yes. either jump or don't.
	ld a,h
	or l
	pop hl
	ret nz
gncjf1:	ld a,6
	jp gncjt3

gncjf2:	lda sval1		;not a constant. flag setting?
	and 4
	pop hl
	jp z,gncjf4
	lda sbmap1		;yes. do appropriate cond'l jp
	and 7
	xor 1
	jp gncjt3

gncjf4:	lda sval1		;not a flag or constant; must be value.
	and 2
	ret nz			;ignore if lvalue (can't be "false")
	lda sval1		;value in DE?
	and 0c0h
	jp nz,gncjf6		;if so, go handle
	ld de,mac0d		;do "ld a,h - or l - jp z,sr0" if not char
	call tschr
	jp nz,gncjf5
	ld de,mac07		;use "ld a,l - or a - jp z,sr0" if char
gncjf5:	call mcrog
	ret

gncjf6:	ld de,mac0dd
	call tschr
	jp nz,gncjf5
	ld de,mac07d
	jp gncjf5


;
; "Or" the current and last "false-label-used" bits:
;

ltabfo:	push hl
	lhld ltabp
	dec hl
	ld a,(hl)
	and 80h
ltbfo1:	dec hl
	dec hl
	dec hl
	dec hl
	dec hl
	or (hl)
	ld (hl),a
	pop hl
	ret

;
; "Or" the current and last "true-label-used" bits:
;

ltabto:	push hl
	lhld ltabp
	dec hl
	ld a,(hl)
	and 1
	jp ltbfo1

;
; Routine to generate a forward jump and push the label value
; used on the stack before returning:
;

gfjp:	ex (sp),hl		;put text pointer on stack, get HL = ret address
	shld retadd	;save return address
	push af
	call glbl	;get a label
	shld sr0
	pop af
	ex (sp),hl		;put it on stack, get text pointer back in HL
	push af
	ld de,mac36
	call mcrog	;generate the jump
	pop af
	push hl		;save text pointer
	lhld retadd	;get return address
	ex (sp),hl		;put ret addr on stack, get HL=text pointer 	
	ret		;and all done. Tricky, huh?	

;
; Routine to pop label value off stack and define the label at the
; current code position:
;

plvdl:	ex (sp),hl		;get return address in HL, put text pointer on stack
	shld retadd	;save return address
	pop hl		;get HL = text pointer
	pop de		;get label value in DE
	push hl		;put text pointer back on stack
	push af
	call entl	;enter the label value
	pop af
	lhld retadd	;get return addr back in HL
	ex (sp),hl		;push ret address on stack, get HL = text ptr
	ret		;all done.

;
; Routine to get a new symbolic label, define it at current position
; in code, and push it on the stack for later use:
;

glvdl:	ex (sp),hl		;put text ptr on stack, get HL = ret addr
	shld retadd	;save return address
	push af
	call glbl	;get a new label
	ex de,hl		;put in DE
	call entl	;define it here
	ex de,hl		;put label value back in HL
	pop af
	ex (sp),hl		;push label on stack, get HL = text pointer
	push hl		;push text pointer on stack
	lhld retadd	;get return address
	ex (sp),hl		;put ret addr on stack, get HL = text ptr
	ret		;all done.
	
;
; Routine to pop a label value off the stack and generate a jump
; to it:
;

plvgj:	ex (sp),hl		;get ret addr in HL, push text ptr on stack
	shld retadd	;save return address
	pop de		;get back text ptr in DE
	pop hl		;get label value to generate jump to in HL
	shld sr0
	ex de,hl		;put text pointer back in HL
	ld de,mac36
	call mcrog	;generate the jump
	push hl		;save text pointer on stack
	lhld retadd	;get return address
	ex (sp),hl		;put ret addr on stack, get text ptr back in HL
	ret		;all done.

;
; Routine to flush info1 into HL; i.e, make sure that the object
; evaluated into info1 has a value generated in the HL register:
;

flshh1:	push af
	push bc
	lda sval1
	ld b,a
	push hl
	lhld svv1
	shld sr0
	pop hl
	ld a,b		;constant of some kind?
	and 3
	jp z,fls1a
	ld a,b		;yes. simple constant?
	and 1
	jp z,fls0
	ld de,mac04	;yes. do ld hl,sr0
	call mcrog
fls00:	xor a
	sta sval1
	jp fls1c

fls0:	ld a,b		;relative lv const. local?
	and 8
	jp nz,fls0a
	call genllv	;yes.
	jp fls00

fls0a:	ld de,mac6a	;no: external
	call mcrog
	push hl
	lhld svv1
	ex de,hl
	call maddd
	pop hl
	jp fls00

fls1a:	ld a,b		;flag setting?
	and 4
	jp z,fls1b

fls1v:	call cvtlvh	;yes. turn it into a value in HL (if ;???
	jp fls00

fls1b:	ld a,b		;value in DE ?
	and 0c0h
	jp z,fls1c
	call gexdehl	;yes. do 'ex de,hl'
	jp fls00

fls1c:	pop bc		;fine as it is.
	pop af
	ret


;
; Flush info1 into DE:
;

flshd1:	push af
	push bc
	lda sval1
	ld b,a
	push hl
	lhld svv1
	shld sr0
	pop hl
	ld a,b
	and 3
	jp z,flsd1a
	ld a,b
	and 1
	jp z,flsd0
	ld de,mac4a
	call mcrog
	jp flsd00

flsd0x:	call gexdehl
flsd00:	ld a,40h
	sta sval1
	jp flsd1c

flsd0:	ld a,b
	and 8
	jp nz,flsd0a
	call genllv
	jp flsd0x

flsd0a:	ld de,mac6a
	call mcrog
	push hl
	lhld svv1
	ex de,hl
	call maddd
	pop hl
	jp flsd0x

flsd1a:	ld a,b
	and 4
	jp z,flsd1b
flsd1v:	call cvtlvd
	jp flsd00

flsd1b:	ld a,b
	and 0c0h
	jp z,flsd0x
flsd1c:	pop bc
	pop af
	ret

flshh2:	call pshn1
	call mvn21
	call flshh1
	call mvn12
	call ppn1
	ret

flshd2:	call pshn1
	call mvn21
	call flshd1
	call mvn12
	call ppn1
	ret

;
; Put info1 value into DE if currently in HL:
;

pn1ind:	push bc
	push af
	lda sval1
	ld b,a
	and 4
	jp nz,flsd1v
	ld a,b
	and 3
	jp nz,flsd1c
	jp flsd1b

;
; Put info1 value in HL if in DE:
;

pn1inh:	push bc
	push af
	lda sval1
	ld b,a
	and 4
	jp nz,fls1v
	ld a,b
	and 3
	jp nz,flsd1c
	jp fls1b


pn2ind:	call pshn1
	call mvn21
	call pn1ind
	call mvn12
	call ppn1
	ret


;
; Push Optimization handlers:
;

rpshp:	push hl
	push af
	push bc
	lhld pshpp
	ld a,(hl)		;get pushop flag at current level
	and 8
	ld b,a		;save masked off register designator bit in B
	ld a,(hl)		;get back flag
	inc hl
	and 0a0h
	jp z,rpsh1
	ld a,20h
	or b
rpsh1:	pop bc
rpsh2:	ld (hl),a
	shld pshpp
	pop af
	pop hl
	ret

spshp:	push hl
	push af
	lhld pshpp
	ld a,(hl)
	and 3fh
	or 80h		;set push bit, but preserve pushed bits (b4)
	call orincg	;set b3 if DE holds value that needs to be pushed
	ld (hl),a		;set current level push-op flag to "set"
	inc hl		;now set next level for subordinate routine
	ld a,20h	;lower-level "set push-op"
	call orincg	;or in the register designation
	jp rpsh2	;and go set in the pushop table.

orincg:	push bc		;set b3 if sval1 indicates DE holds value
	ld b,a
	lda sval1
	and 0c0h
	ld a,b
	pop bc
	ret z
	or 8
	ret

ppshp:	push hl
	push af
	lhld pshpp
	ld a,(hl)
	dec hl
	and 50h
	jp z,ppsh2
	ld a,(hl)
	and 80h
	jp z,ppsh1
	ld a,(hl)
	and 3fh
	or 40h
	jp rpsh2
ppsh1:	ld a,(hl)
	and 0c0h
	or 10h
	jp rpsh2
ppsh2:	ld a,(hl)
	and 7fh
	ld (hl),a
	shld pshpp
	pop af
	pop hl
	ret

tpshd:	push hl
	lhld pshpp
	ld a,(hl)
	pop hl
	and 40h
	jp invrt

genpsh:	push bc
	ld b,(hl)
	cp 80h
	ld a,40h
	jp z,genp2
	ld a,10h
genp2:	ld (hl),a
	ld a,b
	and 08h
	ld a,0e5h
	jp z,genp3
	ld a,0d5h
genp3:	call genb
	pop bc
	ret

;
; Special hacks to generate come super-common op codes:
;

gpushh:	push af
	ld a,0e5h
gpshh1:	call genb
	pop af
	ret

gpoph:	push af
	ld a,0e1h
	jp gpshh1

gpushd:	push af
	ld a,0d5h
	jp gpshh1

gpopd:	push af
	ld a,0d1h
	jp gpshh1

gexdehl:	push af
	ld a,0ebh
	jp gpshh1

tcnst1:	lda sval1
	and 3
	jp invrt

tcnst2:	lda sval2
	and 3
	jp invrt


;
; The actual macros:
;

	IF I80
mcend:	equ 38h		;end of macro: mcend
mcerp:	equ 0cbh	;enter relocation parameter: mcerp 
mcesr:	equ 0efh	;enter symbolic reference: mcesr <srn>

mcsr0:	equ 8h		;substitute value in sr0
mcsr1:	equ 10h		;		  in sr1
mcsr2:	equ 18h		;		  in sr2
mcsr3:	equ 20h		;		  in sr3
mcsr4:	equ 28h		;		  in sr4
mcsr5:	equ 30h		;		  in sr5

mcdr0:	equ 0c7h	;define label	in sr0
mcdr1:	equ 0cfh	;		in sr1
mcdr2:	equ 0d7h	;		in sr2
mcdr3:	equ 0dfh	;		in sr3
mcdr4:	equ 0e7h	;		in sr4

;litrl:	equ 0f7h
	ENDIF




;
; The actual macros:
;

;
; New macro sequeces added for the 1.4 optimizer (especially the
; new alugen):
;

macih4:	inc hl
macih3:	inc hl
macih2:	inc hl
macih1:	inc hl
	db mcend

macid4:	inc de
macid3:	inc de
macid2:	inc de
macid1:	inc de
	db mcend

macdh4:	dec hl
macdh3:	dec hl
macdh2:	dec hl
macdh1:	dec hl
	db mcend

macdd4:	dec de
macdd3:	dec de
macdd2:	dec de
macdd1:	dec de
	db mcend

mache5:	dec hl
mache4:	dec hl
mache3:	dec hl
mache2:	dec hl
mache1:	dec hl
mache0:	ld a,h
	or l
	db mcend

macde5:	dec de
macde4:	dec de
macde3:	dec de
macde2:	dec de
macde1:	dec de
macde0:	ld a,d
	or e
	db mcend

mchen5:	inc hl
mchen4:	inc hl
mchen3:	inc hl
mchen2:	inc hl
mchen1:	inc hl
	ld a,h
	or l
	db mcend

mcden5:	inc de
mcden4:	inc de
mcden3:	inc de
mcden2:	inc de
mcden1:	inc de
	ld a,d
	or e
	db mcend

mcddd1:	ex de,hl
	add hl,hl
	db mcend

mcddd2:	ex de,hl
	add hl,hl
	add hl,hl
	db mcend

mcddd3:	ex de,hl
	add hl,hl
	add hl,hl
	add hl,hl
	db mcend

mcddd4:	ex de,hl
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	db mcend

mcddd5:	ex de,hl
mcddh5:	add hl,hl
mcddh4:	add hl,hl
mcddh3:	add hl,hl
mcddh2:	add hl,hl
mcddh1:	add hl,hl
	db mcend

mac0ca:	add hl,de
	db mcend

macsb1:	db 11h,mcsr2,19h,mcend		;ld de,sr2-add hl,de

mcsb1a: db 11h,mcsr2,19h,7ch,0b5h,mcend	;ld de,sr2-add hl,de-ld a,h-or l

macsb2:	db 21h,mcsr2,19h,mcend		;ld hl,sr2-add hl,de

mcsb1b:	db 21h,mcsr2,19h,7ch,0b5h,mcend	;ld hl,sr2-add hl,de-ld a,h-or l

macsb3:	db 0cdh				;call cmh-add hl,de
	db litrl
	dw cmhl
	add hl,de
	db mcend

macsb4:	db 0cdh				;call cmd-add hl,de
	db litrl
	dw cmd
	add hl,de
	db mcend

macsb5:	db 11h,mcsr4,19h,mcend		;ld de,sr4-add hl,de
macsb6:	db 21h,mcsr4,19h,mcend		;ld hl,sr4-add hl,de

macsb7:	db 11h,mcsr4		;ld de,sr4
	add hl,de
	ld a,h
	rla
	db mcend

macsb8:	db 21h,mcsr4		;ld hl,sr4
	add hl,de
	ld a,h
	rla
	db mcend

macsb9:	db 11h,mcsr2		;ld de,sr2
	add hl,de
	ld a,h
	rla
	db mcend

macsba:	db 21h,mcsr2		;ld hl,sr2
	add hl,de
	ld a,h
	rla
	db mcend

macac1:	xor a
	ld (hl),a
	inc hl
	ld (hl),a
	db mcend

macac3:	db 11h,mcsr0		;ld de,sr0
	ld (hl),e
	inc hl
	ld (hl),d
	db mcend

macac4:	ld (hl),e
	inc hl
	ld (hl),0
	db mcend

macac5:	ld d,0
	ld (hl),e
	inc hl
	ld (hl),d
	db mcend

macacb:	db 32h,mcsr0,mcend		;sta sr0

macacc:	db 21h,mcsr1,22h,mcsr0,mcend	;ld hl,sr1-shld sr0


;
; Macros for function entry and exit:
;

		;entry code for frame size non-zero OR  formal parms
mfntry:	push bc
	db 21h,mcsr0	;ld hl,sr0
	add hl,sp
	ld sp,hl
	ld b,h
	ld c,l
	db mcend

		;as above, but no ld sp,hl 'cause frame size is 0. This
		; is just to set new BC value. entire system could
		;use improvment, say to know to just dec bc twice for
		;each parameter up until 2...
mfntr2:	push bc	
	db 21h, mcsr0	;ld hl,sr0
	add hl,sp
	ld b,h
	ld c,l
	db mcend


mfex1:	db mcdr1	;define exit label
	db mcend

		;exit code for frame size > 6
mfex2:	ex de,hl
	db 21h,mcsr0	;sr1: ex de,hl - ld hl,sr0 -
	add hl,sp			
	ld sp,hl
	ex de,hl
mfex3:	pop bc	;used in stret: routine for quick return (n);
mfex4:	ret	;processing when not at end of function
	db mcend


;
; Macros for ++ and -- operator processing:
;

m12:	inc (hl)
	ld l,(hl)
	db mcend

m12a:	inc (hl)
	db mcend

m13:	ld a,(hl)
	inc (hl)
	ld l,a
	db mcend

m14:	dec (hl)
	ld l,(hl)
	db mcend

m14a:	dec (hl)
	db mcend

m15:	ld a,(hl)
	dec (hl)
	ld l,a
	db mcend

m16b:	ld e,(hl)
	inc hl
	ld d,(hl)
	inc de
	ld (hl),d
	dec hl
	ld (hl),e
	db mcend

m16bz:	rst 0x38;7		;substitute for m16b if -z7 in effect
	inc de
	ld (hl),d
	dec hl
	ld (hl),e
	db mcend

me16b:	db 2ah,mcsr0	 	;lhld sr0- inc hl- shld sr0
	inc hl
	db 22h,mcsr0
	db mcend

m18:	ld e,(hl)
	inc hl
	ld d,(hl)
	dec de
	ld (hl),d
	dec hl
	ld (hl),e
	db mcend

m18z:	rst 0x38;7
	dec de
	ld (hl),d
	dec hl
	ld (hl),e
	db mcend

me18:	db 2ah,mcsr0,2bh,22h,mcsr0,mcend	; lhld sr0- dec hl- shld sr0

m20:	ld e,(hl)
	inc hl
	ld d,(hl)
	db mcend

m20z:	rst 0x38;7
	db mcend

m21:	push de
	db mcend

me21:	push hl
	db mcend

m22:	inc de
	db mcend

me22:	inc hl
	db mcend

m23:	dec de
	db mcend

me23:	dec hl
	db mcend

m26:	push hl
	db 21h,mcsr0		;ld hl,sr0
	add hl,de
	ex de,hl
	pop hl
	db mcend

me26:	db 11h,mcsr1,19h,mcend	; ld de,sr1- add hl,de

m27:	db 7bh,mcsr1,5fh,7ah,mcsr2,57h,mcend
				; ld a,e-sr1-ld e,a-ld a,d-sr2-
				; ld d,a  (sr1 and sr2 will contain
				; code sequences like `sub value')

me27:	db 11h,mcsr2	;ld de,sr2
	add hl,de
	db mcend

m28:	ld (hl),d
	dec hl
	ld (hl),e
	db mcend

m30:	pop de
	db mcend

me30:	pop hl
	db mcend

mnul:	db mcend			; null (generates nothing)

macn:	equ mnul		; an alias for `null'

;
; Misc. utility sequences:
;

mac6e:	ld l,(hl)
	db mcend

mac38:	db 0c3h,0,0,mcend		; jp 0	(used to create the jump
				; vector at start of functions)

mac40:	db 2ah,mcsr0,mcend		; lhld sr0

mac40r:	db 2ah,mcerp,mcsr0,mcend	; lhld sr0 (relocate the address)

mac41:	db 21h,mcsr0,9,mcend		; ld hl,sr0-add hl,bc

mac42:	ld (hl),e
	inc hl
	ld (hl),d
	db mcend

mcn10:	equ mache0

mcn11:	ld a,l
	or a
	db mcend

mcn12:	ld a,e
	or a
	db mcend

mcn13:	ld a,h
	or a
	db mcend

mcn14:	ld a,d
	or a
	db mcend

macrdl:	ld a,d
	rla
	db mcend

macrhl:	ld a,h
	rla
	db mcend

mac0d:	ld a,h
	or l
	db 0cah,mcesr,mcsr0,mcend ; jp z,foo

mac33:	ld a,h
	or l
	db 0c2h,mcesr,mcsr0,mcend ; jp nz,foo


mac07:	ld a,l
	or a
	db 0cah,mcesr,mcsr0,mcend   ; ld a,l-or a-jp z,sr0

mac0dc:	equ mac07		; another alias

mac7a:	ld a,l
	or a
	db 0c2h,mcesr,mcsr0,mcend   ; ld a,l-or a-jp nz,sr0

mac33c:	equ mac7a		; gotta get that ole' USE FACTOR up there!

mac33d:	ld a,d
	or e
	db 0c2h,mcesr,mcsr0,mcend	;jp nz,sr0

mac0dd:	ld a,d
	or e
	db 0cah,mcesr,mcsr0,mcend	;jp z,sr0

mac7ad:	ld a,e
	or a
	db 0c2h,mcesr,mcsr0,mcend	;jp nz,sr0

mac07d:	ld a,e
	or a
	db 0cah,mcesr,mcsr0,mcend	;jp z,sr0

mac35:	db mcsr0,0bdh,0c2h,mcesr,mcsr1,mcsr2
	db 0bch,0cah,mcesr,mcsr3,mcdr1,mcend
				; sr0-cp l-jp nz,bar-sr1-cp h-
				; jp z,sr3-bar: ...

mac35d:	db mcsr0,0bbh,0c2h,mcesr,mcsr1,mcsr2
	db 0bah,0cah,mcesr,mcsr3,mcdr1,mcend
				; sr0-cp e-jp nz,bar-sr1-cp d-
				; jp z,sr3-bar: ...

mac35c:	db mcsr0,0cah,mcesr,mcsr3,mcend
				; sr0-jp z,sr3

mac71c:	ld a,l
	cp e
	db mcend

mac36:	db 0c3h,mcesr,mcsr0,mcend	; jp sr0

mac36a:	db mcesr,mcsr0,mcend		; just "sr0", with a relocation parm

mac37:	equ mac36		; alias for mac36

maca0:	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	db mcend

mac04:	db 21h,mcsr0,mcend		; ld hl,sr0

mac4a:	db 11h,mcsr0,mcend		; ld de,sr0

mac6a:	db 2ah			; lhld extbas
	db litrl		; (gets base-of-external-data-area
	dw extbas		; pointer into HL)
	db mcend


mac09:	db 22h,mcsr0,mcend		; shld sr0

;
; Macros for function call generation
;

mac08:	db 0cdh,mcerp,mcsr3,mcend    ; call sr3  (note the `cb'
				; causes a reloc parameter to be generated)
				;(Note: this is the code generated for
				;function calls)

mac8a:	db 21h,mcesr,mcsr2	; ld hl,foo
	push hl
	db 21h,mcsr1		; ld hl,sr1
	add hl,sp
	ld a,(hl)
	inc hl
	ld h,(hl)
	ld l,a
	jp (hl)
	db mcdr2,mcend		; foo: ...
				;(generated for calls to non-simple funcs)

mac8ar:	ex de,hl
	db 21h,mcsr0	; ld hl,sr0
	add hl,sp
	ld sp,hl
	ex de,hl
	db mcend		;(cleans up stack on return from func call)

;
; More misc. stuff:
;

mac61:	ld h,0
	db mcend

mac62:	ld d,0
	db mcend

maca1:	ld (hl),e
	inc hl
	ld (hl),d
	db mcend

maca9:	ld (hl),e
	inc hl
	xor a
	ld (hl),a
	db mcend

;
; Here are some macros to generate calls to routines
; within the C.CCC runtime utility package:
;

macf1:	db 0cdh		;call pzinh
	db litrl
	dw pzinh
	db mcend

macf2:	db 0cdh		;call pnzinh
	db litrl
	dw pnzinh
	db mcend

macf3:	db 0cdh		;call pcinh
	db litrl
	dw pcinh
	db mcend

macf4:	db 0cdh		;call pncinh
	db litrl
	dw pncinh
	db mcend

macf4a:	db 0cdh		;call ppinh
	db litrl
	dw ppinh
	db mcend

macf4b:	db 0cdh		;call pminh
	db litrl
	dw pminh
	db mcend

macf5:	db 0cdh		;call pzind
	db litrl
	dw pzind
	db mcend

macf6:	db 0cdh		;call pnzind
	db litrl
	dw pnzind
	db mcend

macf7:	db 0cdh		;call pcind
	db litrl
	dw pcind
	db mcend

macf8:	db 0cdh		;call pncind
	db litrl
	dw pncind
	db mcend

macf8a:	db 0cdh		;call ppind
	db litrl
	dw ppind
	db mcend

macf8b:	db 0cdh		;call pmind
	db litrl
	dw pmind
	db mcend


mcumul:
mac63u:	db 0cdh			; call usmul
	db litrl
	dw usmul
	db mcend

mcsmul:
mac63s:	db 0cdh			; call smul
	db litrl
	dw smul
	db mcend

mcdiv5:	ex de,hl
mcudiv:
mac64u:	db 0cdh			; call usdiv
	db litrl
	dw usdiv
	db mcend

mcdiv7:	ex de,hl
mcsdiv:
mac64s:	db 0cdh			; call sdiv
	db litrl
	dw sdiv
	db mcend

mcmod5:	ex de,hl
mcumod:
mac79u:	db 0cdh			; call usmod
	db litrl
	dw usmod
	db mcend

mcmod7:	ex de,hl
mcsmod:
mac79s:	db 0cdh			; call smod
	db litrl
	dw smod
	db mcend

mcalbu:
mac68:	db 0cdh			; call albu (DE < HL unsigned?)
	db litrl
	dw albu
	db mcend

mcagbu:
mac69:	db 0cdh			; call agbu (DE > HL unsigned?)
	db litrl
	dw agbu
	db mcend

mcalbs:
mac68s:	db 0cdh			; call albs (DE <= HL signed?)
	db litrl
	dw albs
	db mcend

mcagbs:
mac69s:	db 0cdh			; call agbs (DE > HL signed?)
	db litrl
	dw agbs
	db mcend

mcbgau:	db 0cdh
	db litrl
	dw bgau
	db mcend

mcbgas:	db 0cdh
	db litrl
	dw bgas
	db mcend

mcblau:	db 0cdh
	db litrl
	dw blau
	db mcend

mcblas:	db 0cdh
	db litrl
	dw blas
	db mcend


mceq:
mac71:	db 0cdh			; tests equality of DE and HL
	db litrl
	dw eqwel
	db mcend

maccom:	db 0cdh			;2's complement HL
	db litrl
	dw cmhl
	db mcend

maccmd:	db 0cdh			;2's complement DE
	db litrl
	dw cmd
	db mcend

macsad:	equ mac0ca

macslh:	db 0cdh,litrl		;shift HL left by E bits
	dw shllbe
	db mcend

macsld:	db 0cdh,litrl		;shift DE left by L bits
	dw sdelbl
	db mcend

macsrh:	db 0cdh,litrl		;shift HL right by E bits
	dw shlrbe
	db mcend

macsrd:	db 0cdh,litrl		;shift DE right by L bits
	dw sderbl
	db mcend

mcssbh:	db 0cdh,litrl		;subtract HL from DE, result in HL
	dw cmhl			;call cmhl
	add hl,de
	db mcend

mcssbd:	db 0cdh,litrl		;subract DE from HL, result in HL
	dw cmd
	add hl,de
	db mcend


;
; bitwise operator macros:
;

mcand:
mac73:	ld a,h
	and d
	ld h,a
	ld a,l
	and e
	ld l,a
	db mcend

mcxor:
mac74:	ld a,h
	xor d
	ld h,a
	ld a,l
	xor e
	ld l,a
	db mcend

mcor:
mac75:	ld a,h
	or d
	ld h,a
	ld a,l
	or e
	ld l,a
	db mcend

mac0a:	db 11h,mcsr0,0cdh		; ld de,sr0-call usmul
	db litrl		;  (used for subscript calculation)
	dw usmul
	db mcend

mac0c:	db 11h,mcsr0	; ld de,sr0
	add hl,de
	db mcend

mac98a:	db 21h,mcesr,mcsr0,mcend  ;ld hl,foo (foo to be defined later on)

mac98:	db 21h,mcesr,mcsr0	;ld hl,foo
	db 0c3h,mcesr,mcsr1	;jp sr1
	db mcdr0,mcend		; foo:

mac01:	ld a,l
	cpl
	ld l,a
	inc l
	ld h,0ffh
	db mcend

mac0e:	db 0cdh
	db litrl
	dw cmhl
	db mcend

macad1:	db 0e5h,21h,mcsr0,0cdh	; push hl-ld hl,sr0-
	db litrl		; call usmul
	dw usmul		; (used to scale value in DE before
	pop de
	db mcend		; adding it to pointer in HL)

macd1a:	ex de,hl
	add hl,hl
	ex de,hl
	db mcend

macad2:	db 0d5h,11h,mcsr0,0cdh	; push de-ld de,sr0-
	db litrl		; call usmul
	dw usmul		; (used to scale value in HL before
	pop de
	db mcend		; adding it to pointer in DE)

macad3:	ex de,hl
	db 21h,mcsr0,0cdh	; ex de,hl-ld hl,sr0-
	db litrl		; call usdiv
	dw usdiv		; (used to scale result after two
	db mcend			; pointers are subtracted

macad4:	xor a
	ld a,h
	rra
	ld h,a
	ld a,l
	rra
	ld l,a
	db mcend

mac1a:	ld a,l
	cpl
	ld l,a
	ld h,0ffh
	db mcend

mac1b:	ld a,l
	cpl
	ld l,a
	ld a,h
	cpl
	ld h,a
	db mcend

mac05:	db 21h,mcerp,mcsr0	; ld hl,sr0
	db mcend		; (creates a relocation parameter for
				;  the data field of the lxi)


mac65m:	equ mcssbh		; HL <-- DE - HL

mac65b:	equ macsrd		; >>

mac67:	equ macsld		; <<

;
; **** END OF MACROS ****
;

	;IF LASM
	;link cc2e
	;ENDIF
