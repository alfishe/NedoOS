

;
; cc2c.asm:
;
; This is the binary expression special case list interpreter
; for version 1.4:
;

spcash:	push af
	call spcs2
	pop af
	ret

spcs2:	lhld svv1	;if INFO1 is the constant:
	shld sr0	;<constant value> into sr0
	call cmh
	shld sr2	;-<constant value> into sr2
	dec hl
	shld sr4	;-<constant value + 1> into sr4

	lda sval2
	sta ssval
	call tcnst2
	jp nz,spcs2a
	lhld svv2	;if INFO2 is the constant:
	shld sr0	;<constant value> into sr0
	shld svv1
	call cmh
	shld sr2	;-<constant value> into sr2
	dec hl
	shld sr4	;-<constant value + 1> into sr4
	lda sval1
	sta ssval
spcs2a:	ex de,hl
spcs3:	ld a,(hl)
	or a
	ret z
	sta key
	ld b,a
	inc hl
	ld e,(hl)
	inc hl
	ld d,(hl)	
	inc hl
	ld c,0
	and 7
	cp 7
	jp nz,spcs3a
	push hl
	call spcs2	;perform a recursive list evaluation
	pop hl
	jp z,spcs3	;if not match found in subordinate list, resume search
	ret		;else a match was found - done.
	
spcs3a:	ex de,hl
	shld spval
	ex de,hl
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ex de,hl
	shld spmac
	ex de,hl
	and 7
	dec a		;key = 1?
	jp nz,sptst2

sptry1:	call tcnst1	;yes.
	jp z,sptr1a	;fit template?
	inc c		;no-commutative?
	ld a,b
	and 20h
	jp nz,sptry3	;if so, go try key=3 case
	jp spcs3	;else no match yet

sptr1a:	lda sval2	;fits key=1 template if info2 in HL
	and 0c0h
	jp nz,spcs3
	jp spfnd

sptst2:	dec a		;key = 2?
	jp nz,sptst3
sptry2:	call tcnst1	;yes.
	jp z,sptr2a	;fit template?
	inc c		;no. commutative?
	ld a,b
	and 20h
	jp nz,sptry4	;if so, try key=4	
	jp spcs3	;else no match

sptr2a:	lda sval2	;fits key=2 template if info2 in HL
	and 0c0h
	jp z,spcs3
	jp spfnd

sptst3:	dec a		;key = 3?
	jp nz,sptst4
sptry3:	call tcnst2	;yes
	jp nz,spcs3	;no good unless info2 a constant
sptr3a:	lda sval1	;OK, good only if info1 in HL	
	and 0c0h
	jp nz,spcs3
	jp spfnd

sptst4:	dec a		;key = 4?
	jp nz,sptst5
sptry4:	call tcnst2	;yes
	jp nz,spcs3	;good only if info2 is a constant
sptr4a:	lda sval1	;OK, good only if info1 in DE
	and 0c0h
	jp z,spcs3
	jp spfnd

sptst5:	push hl		;set "constant value doesn't matter" flag
	ld hl,5500h
	shld spval	;this is so no auto-lxi is done
	pop hl
	dec a
	jp nz,sptst6	;key = 5?
	call tcnst1	;yes. check to make sure there are no constants
	jp z,spcs3
	call tcnst2
	jp z,spcs3
	ld a,b		;commutative?
	and 20h
	jp nz,spfnd	;if so, we know enough to match
	jp sptr3a	;else go check to make sure info1 is in HL

sptst6:	dec a		;key = 6?
	call nz,ierror	;better be!
	call tcnst1	;make sure we have no constants
	jp z,spcs3
	call tcnst2
	jp z,spcs3
	jp sptr4a	;if OK, make sure info1 is in DE

spfnd:	push hl
	lhld spval
	ld a,h
	cp 55h		;wild card constant test?
	jp z,spgo		;if so, don't bother to compare constant values
	ex de,hl		;no. must match value
	lhld svv1
	ld a,h
	cp d
	jp nz,spfnd1
	ld a,l
	cp e		;all 16 bits match?
	jp z,spgo		;if so, go do the special case!
spfnd1:	pop hl		;no good. go for more list searching
	jp spcs3

spgo:	ld a,l		;do we need to do an auto-lxi?
	cp 55h
	jp nz,spgo1	;if not 55h, we DO NOT want to do it; else
	ld de,mac04	;yes. do either ld hl,sr0 or ld de,sr0
	lda ssval
	and 0c0h
	jp nz,spgo0
	ld de,mac4a
spgo0:	call mcrog
spgo1:	pop hl
	lhld spmac	;get the macro
	ex de,hl
	call mcrog	;do it

	ld b,0		;now set all the resultant infox attributes
	lda key		;register B will accumulate new sval1 value
	ld c,a
	and 8		;result in a register?
	jp z,spgo2
	ld a,c		;yes. if in DE, set b6 of reg B accordingly
	or a
	jp spgo2
	ld b,40h

spgo2:	ld a,c
	and 10h		;result a flag?
	jp z,spgo3
	ld a,c		;yes. set bmap1 and reg B (sval1) accordingly
	rlca
	rlca
	and 3
	sta sbmap1
	ld b,4		;this becomes sval1--a flag setting.

spgo2a:	xor a	
	sta indc1
	sta typ1

spgo3:	ld a,c		;result a constant?
	and 18h
	jp nz,spgo4
	ld a,c		;yes. FFFF?
	and 0c0h
	ld hl,0ffffh
	cp 0c0h
	jp z,spgo3a	;if so, go set
	inc hl		;0000?
	or a
	jp z,spgo3a	;if so, go set that
	inc hl
	cp 40h		;0001?
	call nz,ierror	;if not, something's screwy in the state of confusion
spgo3a:	shld svv1
	ld b,1

spgo4:	ld a,b		;set new sval1
	sta sval1
	xor a		;clear Z bit so we'll know we're done if this
	inc a		;is a recursive call to spcash
	ret

;
; The list structures representing all possible special cases of
; binary operators:
;

;
; First define some common constant values:
;

r:	equ 8h		;result in a register (key bit flag)
f:	equ 10h		;result is a flag (key bit flag)
con0:	equ 0		;result is constant value of 0
con1:	equ 40h		;result is constant value of 1
conff:	equ 0c0h	;result is constant value of FFFFh
fz:	equ f+000h	;result is Z flag set on true (Z true)
fnz:	equ f+040h	;result is Z flag reset on true (NZ true)
fc:	equ f+080h	;result is C flag set on true (C true)
fnc:	equ f+0c0h	;result is C flag reset on true (NC true)
k:	equ 20h		;operator is commutative
rd:	equ r+80h	;result in DE
rh:	equ r+00h	;result in HL
endlst:	equ 0		;end of list or sub-list

			;wild-card constant value entries:
dolxi:	equ 05555h	;do auto-lxi of constant value into free register
nolxi:	equ 05500h	;wild card value, but no lxi

smadd:	db 1+rh+k
	dw 0,mnul		; + operator

	db 2+rd+k
	dw 0,mnul

	db 1+rh	
	dw 1,macih1

	db 1+rh	
	dw 2,macih2

	db 1+rh	
	dw 3,macih3

	db 1+rh	
	dw 4,macih4

	db 1+rh	
	dw -1,macdh1

	db 1+rh	
	dw -2,macdh2

	db 1+rh	
	dw -3,macdh3

	db 1+rh	
	dw -4,macdh4

	db 2+rd	
	dw 1,macid1

	db 2+rd	
	dw 2,macid2

	db 2+rd	
	dw 3,macid3

	db 2+rd	
	dw 4,macid4

	db 2+rd	
	dw -1,macdd1

	db 2+rd	
	dw -2,macdd2

	db 2+rd	
	dw -3,macdd3

	db 2+rd	
	dw -4,macdd4

	db 1+rh+k
	dw dolxi,mac0ca

	db 2+rh+k
	dw dolxi,mac0ca

	db 5+rh+k
	dw nolxi,mac0ca

	db endlst


smsub:	db 1+rh	
	dw 0,mnul		; - operator

	db 2+rd	
	dw 0,mnul

	db 3+rh	
	dw 0,maccom

	db 4+rd	
	dw 0,maccmd

	db 1+rh	
	dw 1,macdh1

	db 1+rh	
	dw 2,macdh2

	db 1+rh	
	dw 3,macdh3

	db 1+rh	
	dw 4,macdh4

	db 1+rh	
	dw -1,macih1

	db 1+rh	
	dw -2,macih2

	db 1+rh	
	dw -3,macih3

	db 1+rh	
	dw -4,macih4

	db 2+rd	
	dw 1,macdd1

	db 2+rd	
	dw 2,macdd2

	db 2+rd	
	dw 3,macdd3

	db 2+rd	
	dw 4,macdd4

	db 2+rd	
	dw -1,macid1

	db 2+rd	
	dw -2,macid2

	db 2+rd	
	dw -3,macid3

	db 2+rd	
	dw -4,macid4

	db 1+rh	
	dw nolxi,macsb1

	db 2+rh	
	dw nolxi,macsb2

	db 3+rh	
	dw dolxi,macsb3

	db 4+rh	
	dw dolxi,macsb4

	db 5+rh	
	dw nolxi,mcssbh

	db 6+rh	
	dw nolxi,mcssbd

	db endlst


smmul:	db 1+con0+k
	dw 0,mnul		;common cases for both

	db 2+con0+k
	dw 0,mnul		;signed and unsigned

	db 1+rh+k
	dw 1,mnul		;multiplication

	db 2+rd+k
	dw 1,mnul

	db 1+rh+k
	dw -1,maccom

	db 2+rd+k
	dw -1,maccmd

	db 1+rh+k
	dw 2,mcddh1

	db 1+rh+k
	dw 4,mcddh2

	db 1+rh+k
	dw 8,mcddh3

	db 1+rh+k
	dw 16,mcddh4

	db 2+rh+k
	dw 2,mcddd1

	db 2+rh+k
	dw 4,mcddd2

	db 2+rh+k
	dw 8,mcddd3

	db 2+rh+k
	dw 16,mcddd4

	db endlst


smmulu:	db 7	
	dw smmul		;unsigned *

	db 1+rh+k
	dw dolxi,mcumul

	db 2+rh+k
	dw dolxi,mcumul

	db 5+rh+k
	dw nolxi,mcumul

	db endlst


smmuls:	db 7	
	dw smmul		;signed *

	db 1+rh+k
	dw dolxi,mcsmul

	db 2+rh+k
	dw dolxi,mcsmul

	db 5+rh+k
	dw nolxi,mcsmul

	db endlst


smdiv:	db 1+con0+k
	dw 0,mnul		;common cases for both

	db 2+con0+k
	dw 0,mnul		;signed and unsigned

	db 1+rh	
	dw 1,mnul		;division

	db 2+rd	
	dw 1,mnul

	db 1+rh	
	dw -1,maccom

	db 1+rd	
	dw -1,maccmd

	db endlst


smdivu:	db 7	
	dw smdiv		; unsigned / operator

	db 1+rh	
	dw dolxi,mcdiv5

	db 2+rh	
	dw dolxi,mcudiv

	db 3+rh	
	dw dolxi,mcudiv

	db 4+rh	
	dw dolxi,mcdiv5

	db 5+rh	
	dw nolxi,mcudiv

	db 6+rh	
	dw nolxi,mcdiv5

	db endlst


smdivs:	db 7	
	dw smdiv		;signed / operator

	db 1+rh	
	dw dolxi,mcdiv7

	db 2+rh	
	dw dolxi,mcsdiv

	db 3+rh	
	dw dolxi,mcsdiv

	db 4+rh	
	dw dolxi,mcdiv7

	db 5+rh	
	dw nolxi,mcsdiv

	db 6+rh	
	dw nolxi,mcdiv7

	db endlst


smmod:	db 1+con0+k
	dw 0,mnul		;common % operator cases

	db 2+con0+k
	dw 0,mnul

	db endlst


smmodu:	db 7	
	dw smmod		;unsigned % operator

	db 1+con0
	dw 1,mnul

	db 2+con0
	dw 1,mnul

	db 1+rh	
	dw dolxi,mcmod5

	db 2+rh	
	dw dolxi,mcumod

	db 3+rh	
	dw dolxi,mcumod

	db 4+rh	
	dw dolxi,mcmod5

	db 5+rh	
	dw nolxi,mcumod

	db 6+rh	
	dw nolxi,mcmod5

	db endlst


smmods:	db 7	
	dw smmod		;signed % operator

	db 1+rh	
	dw dolxi,mcmod7

	db 2+rh	
	dw dolxi,mcsmod

	db 3+rh	
	dw dolxi,mcsmod

	db 4+rh	
	dw dolxi,mcmod7

	db 5+rh	
	dw nolxi,mcsmod

	db 6+rh	
	dw nolxi,mcmod7

	db endlst


smsr:	db 1+rh	
	dw 0,mnul		; >> operator

	db 2+rd	
	dw 0,mnul

	db 1+rh	
	dw dolxi,macsrh

	db 2+rh	
	dw dolxi,macsrd

	db 3+rh	
	dw dolxi,macsrd

	db 4+rh	
	dw dolxi,macsrh

	db 5+rh	
	dw nolxi,macsrd

	db 6+rh	
	dw nolxi,macsrh

	db endlst


smsl:	db 1+rh	
	dw 0,mnul		; << operator

	db 2+rd	
	dw 0,mnul

	db 1+rh	
	dw 1,mcddh1

	db 1+rh	
	dw 2,mcddh2

	db 1+rh	
	dw 3,mcddh3

	db 1+rh	
	dw 4,mcddh4

	db 1+rh	
	dw 5,mcddh5

	db 2+rh	
	dw 1,mcddd1

	db 2+rh	
	dw 2,mcddd2

	db 2+rh	
	dw 3,mcddd3

	db 2+rh	
	dw 4,mcddd4

	db 2+rh	
	dw 5,mcddd5

	db 1+rh	
	dw dolxi,macslh

	db 2+rh	
	dw dolxi,macsld

	db 3+rh	
	dw dolxi,macsld

	db 4+rh	
	dw dolxi,macslh

	db 5+rh	
	dw nolxi,macsld

	db 6+rh	
	dw nolxi,macslh

	db endlst


smgtu:	db 1+fnz
	dw 0,mcn10		; unsigned ">" operator

	db 2+fnz
	dw 0,macde0

	db 3+con0
	dw 0,mnul

	db 4+con0
	dw 0,mnul

	db 1+fc
	dw nolxi,macsb5

	db 2+fc	
	dw nolxi,macsb6

	db 3+fnc	
	dw nolxi,macsb1

	db 4+fnc	
	dw nolxi,macsb2

	db 5+fc	
	dw nolxi,mcagbu

	db 6+fc	
	dw nolxi,mcbgau

	db endlst


smgts:	db 1+fnc		;signed ">" operator
	dw -1,macrhl

	db 2+fnc	
	dw -1,macrdl

	db 3+fc
	dw 0,macrhl

	db 4+fc
	dw 0,macrdl

	db 1+fc
	dw dolxi,mcbgas

	db 2+fc
	dw dolxi,mcagbs

	db 3+fc	
	dw dolxi,mcagbs

	db 4+fc	
	dw dolxi,mcbgas

	db 5+fc	
	dw nolxi,mcagbs

	db 6+fc	
	dw nolxi,mcbgas

	db endlst


smltu:	db 1+con0		;unsigned "<" operator
	dw 0,mnul

	db 2+con0
	dw 0,mnul

	db 3+fnz
	dw 0,mcn10

	db 4+fnz
	dw 0,macde0

	db 1+fnc	
	dw nolxi,macsb1

	db 2+fnc	
	dw nolxi,macsb2

	db 3+fc	
	dw nolxi,macsb5

	db 4+fc	
	dw nolxi,macsb6

	db 5+fc	
	dw nolxi,mcalbu

	db 6+fc	
	dw nolxi,mcblau

	db endlst


smlts:	db 1+fc			;signed "<" operator
	dw 0,macrhl

	db 2+fc
	dw 0,macrdl

	db 3+fnc
	dw -1,macrhl

	db 4+fnc
	dw -1,macrdl

	db 1+fc	
	dw dolxi,mcblas

	db 2+fc	
	dw dolxi,mcalbs

	db 3+fc	
	dw dolxi,mcalbs

	db 4+fc	
	dw dolxi,mcblas

	db 5+fc	
	dw nolxi,mcalbs

	db 6+fc	
	dw nolxi,mcblas

	db endlst


smeq:	db 1+fz+k
	dw 0,mcn10		; == operator

	db 2+fz+k
	dw 0,macde0

	db 1+fz+k
	dw 1,mache1

	db 1+fz+k
	dw 2,mache2

	db 1+fz+k
	dw 3,mache3

	db 1+fz+k
	dw 4,mache4

	db 2+fz+k
	dw 1,macde1

	db 2+fz+k
	dw 2,macde2

	db 2+fz+k
	dw 3,macde3

	db 2+fz+k
	dw 4,macde4

	db 1+fz+k
	dw -1,mchen1

	db 1+fz+k
	dw -2,mchen2

	db 1+fz+k
	dw -3,mchen3

	db 2+fz+k
	dw -1,mcden1

	db 2+fz+k
	dw -2,mcden2

	db 2+fz+k
	dw -3,mcden3

	db 1+fz+k
	dw nolxi,mcsb1a

	db 2+fz+k
	dw nolxi,mcsb1b

	db 5+fz+k
	dw nolxi,mceq

	db endlst


smand:	db 1+con0+k
	dw 0,mnul		; & operator

	db 2+con0+k
	dw 0,mnul

	db 1+rh+k
	dw -1,mnul

	db 2+rd+k
	dw -1,mnul

	db 1+rh+k
	dw dolxi,mcand

	db 2+rh+k
	dw dolxi,mcand

	db 5+rh+k
	dw nolxi,mcand

	db endlst


smor:	db 1+rh+k
	dw 0,mnul		; | operator

	db 2+rd+k
	dw 0,mnul

	db 1+conff+k
	dw -1,mnul	

	db 2+conff+k
	dw -1,mnul

	db 1+rh+k
	dw dolxi,mcor

	db 2+rh+k
	dw dolxi,mcor

	db 5+rh+k
	dw nolxi,mcor

	db endlst


smxor:	db 1+rh+k
	dw 0,mnul

	db 2+rd+k
	dw 0,mnul

	db 1+rh+k
	dw dolxi,mcxor

	db 2+rh+k
	dw dolxi,mcxor

	db 5+rh+k
	dw nolxi,mcxor

	db endlst





;
; This routine returns Z true if both operands are chars,
; else returns not Z and clears the high order byte of
; any of the two operands which aren't chars:
;

chradj:	call tschr	;first operand a char?
	jp nz,chrdj2
	call tschr2	;yes. 2nd?
	ret z		;if so, return Z true
	ld de,mac61	;else clear hi byte of HL
chrdj1:	call mcrog
	xor a
	inc a		;and return Z false
	ret
chrdj2:	call tschr2	;2nd operand char?
	ret nz		;if not, done
	ld de,mac62	;if so, clear hi byte of DE
	jp chrdj1


parerr:	ld de,stg18
	jp perr

unsadj:	call tptr
	jp z,unsdj2
	call tptr2
	jp z,unsdj2
	call tsval
	ret nz
	call tsval2
	ret nz
	lda typ1
	cp 2
	ret z
	lda typ2
	cp 2
	ret nz
	sta typ1
	ret

unsdj2:	xor a
	ret

;
; Routine to "pass over" a simple expression in text:
;

sexpas:	call igsht
	inc hl
	cp mulcd	;check for unary ops
	jp z,sexpas
	cp ancd
	jp z,sexpas
	cp mincd
	jp z,sexpas
	cp notcd
	jp z,sexpas
	cp circum
	jp z,sexpas
	cp pplus
	jp z,sexpas
	cp mmin
	jp z,sexpas
	cp sizcd
	jp z,sexpas
	dec hl		;else pass primary expr
	call ppas
	ret

ppas:	call sppas	;pass simple primary expr
	ret c		;abort if error
ppas2:	call igsht	;check for primary ops
	cp open
	jp nz,ppas3
ppas2a:	call mtchp
	jp ppas2

ppas3:	cp openb
	jp nz,ppas4
	call mtchb
	jp ppas2

ppas4:	inc hl
	cp arrow
	jp z,ppas5
	cp period
	jp z,ppas5
	cp pplus
	jp z,ppas2
	cp mmin
	jp z,ppas2
	dec hl		;all done.
	scf
	ccf
	ret

ppas5:	call igsht
	cp varcd
	jp nz,ppase
ppas6:	inc hl
	inc hl
	inc hl
	jp ppas2

sppas:	cp open
	jp z,ppas2a
	cp strcd
	jp z,ppas6
	cp varcd
	jp z,ppas6
	cp concd
	jp z,ppas6

ppase:	ld de,stg10
	call perrsv
	scf
	ret

 

;
; Routine to "look ahead" past the current text, and
; return the next non-space character, restoring old
; text pointer and line count:
;

looka:	push hl
	lhld nlcnt
	ex (sp),hl
	push hl
	inc hl
	call igsht
	pop hl
	ex (sp),hl
	shld nlcnt
	pop hl
	ret


domac:	ld a,c
	add a
	add a
	add a
	add b
	add b
	push hl
	ld hl,mact
	ld e,a
	ld d,0
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	call mcrog
	pop hl
	ret

aluadj:	ld a,l
	or a
	ret nz
	ld a,h
	or a
	ret nz
	ld h,1
	ret


mult:	push bc
	push de
	ld b,h
	ld c,l
	lhld subval
	ex de,hl
	ld hl,0

mult1:	ld a,b
	or c
	jp z,mult2
	add hl,de
	dec bc
	jp mult1

mult2:	shld subval
	pop de
	pop bc
	ret

maddd:	ld a,d
	or a
	jp nz,maddd2
	ld a,e
	cp 4
	jp nc,maddd2
maddd1:	ld a,d
	or e
	ret z
	ld a,23h
	call genb
	dec de
	jp maddd1

maddd2:	ex de,hl
	shld sr0
	ex de,hl
	ld de,mac0c
	call mcrog
	ret


;
; Return Z set if keyword in A is a binary operator:
;

binop:	ld b,15
	cp 0b6h
	ret z
	cp 0b7h
	ret z
	cp 0b8h
	ret z
	dec b
	cp 0c4h
	ret z
	cp 0b5h
	ret z
	dec b
	cp 0b0h
	ret z
	cp 0b1h
	ret z
	dec b
	cp 0bah
	ret z
	cp 0b9h
	ret z
	cp 0afh
	ret z
	cp 0aeh
	ret z
	dec b
	cp 0aah
	ret z
	cp 0abh
	ret z
	dec b
	cp 0bbh
	ret z
	dec b
	cp 0bch
	ret z
	dec b
	cp 0bdh
	ret z
	dec b
	cp 0ach
	ret z
	dec b
	cp 0adh
	ret

;
; Return Z if keyword in A is logical binary op (&& or ||):
;

lbinop:	cp oror
	ret z
	cp andand
	ret

;
; Return Z if keyword is ++ or --:
;

ppormm:	cp pplus
	ret z
	cp mmin
	ret

;
; Return Z if keyword in A is asignment operator:
;


asgnop:	cp 0beh
	ret z
	cp 0a0h
	ret c
	cp 0ach
	ccf
	ret

cnvsop:	sub 0a0h
	push hl
	push de
	ld hl,sopt
	ld e,a
	ld d,0
	add hl,de
	ld a,(hl)
	pop de
	pop hl
	ret

sopt:	db 0c4h,0b5h,0b6h,0b7h,0b8h
	db 0b1h,0b0h,0bbh,0bch,0bdh

primop:	cp open
	ret z
	cp openb
	ret z
	cp arrow
	ret z
	cp period
	ret

prmop2:	call primop
	ret z
	cp pplus
	ret z
	cp mmin
	ret

;
; Handle a binary expression, with HL pointing to the first arg:
;

lcflag:	ds 1 		;controls optimizing for constant logical subexpr.
			;=10h when no lbinop activity,
			;=20h when pending next (noted) lbinop result
			;b6 hi when abs logical value of binexp determined
			;if b6 true, b7 is: 1 for TRUE, 0 for FALSE

lflag:	ds 1		;true if &&/|| expression

bexpr:	lda codflg
	push af
	lda arith
	push af
	ld a,10h	;initialize lcflag to: "no activity"
	sta lcflag
	xor a
	sta arith
	sta lflag
bxpr00:	call rpshp
bxpr0:	xor a
	call oppsh
	call sexpasl
	push hl
	lhld ltabp
	cp andand	; Do special ltab hackery if NEXT operator is || or &&
	jp nz,bxpr0a	;&& operator?
	push hl		;yes. propogate last false branch table label,
	dec hl		;add new true label
	dec hl
	ld d,(hl)
	dec hl
	ld e,(hl)
	pop hl
	push de
	ex de,hl
	call glbl
	ex de,hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	pop de
	jp bxpr0b

bxpr0a:	cp oror
	jp nz,bxpr0c	;|| operator?
	push hl		;yes. propogate last true branch table label,	
	ld de,-5	;add new false label.
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	pop hl
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	ex de,hl
	call glbl
	ex de,hl
bxpr0b:	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	inc hl
	shld ltabp

	lda lcflag	;first activity?
	cp 10h
	jp nz,bxpr0c	;if not, don't change this here
	ld a,20h	;if not, prime for some activity
	sta lcflag	

bxpr0c:	pop hl

	lda value
	push af

	lda arith
	push af
	or a		;was arith set?
	call nz,ltabmp	;if so, bump ltable to keep branches local...

	lda lcflag	;save logical constant flag
	push af
	lda lflag	;save logical expression flag
	push af

	xor a
	call sgenv	;evaluate the operand.

	pop af
	sta lflag	;restore logical expr flag

	pop af		;get old lcflag in A
	ld b,a		;save in B
	or a		;was old lcflag cleared?
	jp z,lchck1	;if so, keep it that way.
	and 30h		;was it primed or inactive?
	ld a,b
	jp nz,lchck2	;if so, let newer one be propogated
			;else...
lchck1:	sta lcflag	;restore logical constant flag

lchck2:	pop af
	sta arith

	pop af
	or a
	jp z,bxpr1
	sta value	;logical `or' "value" with old "value"

bxpr1:	lda arith	;was last term preceded by arith operator?
	or a
	jp z,bxpr1a	;if not, don't clean up
	xor a		;yes; reset arith flag
	sta arith
	call ltabtd	;define all possible branches as here
	call ltabfd
	call ltabpp	;clean up branch table
	pop af		;and restore old value of val
	sta val

bxpr1a:	call oppops

bxpr2:	ld a,(hl)	
	call binop	;next thing in text a binary op?
	jp z,bxpr4

bxpr3:	call tstops	;no. any old ops on stack?
	jp z,bxpr9
			;yes. generate operations.
	call ppshp
	call oppop	
	call ppn2
	call alugen
	jp bxpr3

bxpr4:	call tstops	;ok, we have a new binop to process.
	jp nz,bxpr7	;any old stuff on stack?
	ld a,(hl)		;no. Let's handle && and || specially...
	cp andand	; && operator?
	jp nz,bxpr5
	sta lflag	;set, set logical expression flag
	call ppshp

	lda lcflag	;see if it's OK to check for constants
	and 0f0h
	jp z,bxpr4a	;only test for constants if lcflag cooperates.

	call tcnst1	;was arg a constant?
	jp z,bxpr40
	lda lcflag	;if not, clear lcflag if not already finalized
	and 0c0h
	sta lcflag
	jp bxpr4a

bxpr40:	lda lcflag	;was lcflag primed?
	cp 20h
	jp nz,bxpr41
	ld a,10h	;if so, un-prime in case we don't score the right
	sta lcflag	;polarity on this constant.

bxpr41:	call tcnsz	;we have a constant. zero?
	jp nz,bxpr4b	;if not, skip the cond'l jump, but keep evaluating
bxpr42:	xor a		;yes...
	sta codflg	; don't bother generating any more code for the bexpr
	ld a,40h
	sta lcflag	;set logical constant flag to "yes, false"
	jp bxpr4b

bxpr4a:	lda val
	cp 81h		;if must force value, do it:
	call z,lv01th	; get 0 or 1 into HL, no matter WHAT.
	call gncjf	;generate conditional jump on false
bxpr4b:	call ltabtd
	call ltabfo
	jp bxpr5c

bxpr5:	cp oror
	jp nz,bxpr6	; || operator?
	sta lflag	;yes, set logical expression flag
	call ppshp

	lda lcflag	;see if it's OK to check for constants
	and 0f0h
	jp z,bxpr5a	;only test for constants if lcflag cooperates.

	call tcnst1	;was arg a constant?
	jp z,bxpr50
	lda lcflag	;if not, clear lcflag if not already finalized
	and 0c0h
	sta lcflag
	jp bxpr5a

bxpr50:	lda lcflag	;was lcflag primed?
	cp 20h
	jp nz,bxpr51
	ld a,10h	;if so, un-prime in case we don't score the right
	sta lcflag	;polarity on this constant.

bxpr51:	call tcnsz	;we have a constant. zero?
	jp z,bxpr5b	;if so, skip the cond'l jump, but keep evaluating

	xor a		;no...thus true, so
	sta codflg	;don't bother generating any more code for the bexpr
	ld a,0c0h	;set logical constant flag to "yes, true"
	sta lcflag
	jp bxpr5b

bxpr5a:	lda val
	cp 81h		;if must force value, do it:
	call z,lv01th	; get 0 or 1 in HL no matter WHAT.
	call gncjt	;generate conditional jump on true
bxpr5b:	call ltabfd
	call ltabto

bxpr5c:	call ltabpp
	inc hl
	jp bxpr00

tcnsz:	lda sval1	;set Z flag if constant value of zero
	and 1
	jp z,invrt	;if not absolute constant, not value of zero
	push hl		;save text pointer
	lhld svv1
	ld a,h
	or l
	pop hl		;now Z set if zero value
	ret


bxpr6:	lda sval1	;if logical bit set, turn it into actual value here
	and 4		;so stuff like: " <Bang>kbhit() & a<5 " works.
	call nz,cvtlvh

	lda val
	cp 81h		;if must force value, do it:
	call z,cvtlvh	; make sure flag settings turn into values in HL

	call tcnst1
	call nz,spshp
	call z,rpshp
	call pshn1
	ld a,(hl)
	call oppsh
	inc hl

	call igsht	;next term a complex expression in parens?
	cp open
	jp nz,bxpr0

	lda val		;if so, assume it needs complete evaluation
	push af
	ld a,81h	;force value result
	sta val
	ld a,1		;set arith mode while evaluating
	sta arith	;   next operand of binary op,
	jp bxpr0	;and go evaluate next arg

bxpr7:	call oppop
	call oppsh
	ld c,b
	call binop

	push de
	ld de,stgbbo
	call nz,perrab	;no other operators; better be '|'
	pop de

	ld a,c
	cp b
	jp z,bxpr8
	jp nc,bxpr6

bxpr8:	call ppshp
	call oppop
	call ppn2
	call alugen
	jp bxpr2

bxpr9:	call ppshp
	lda val		;absolutely need a value?
	cp 81h
	jp nz,bxpr90

	lda lflag	;was it a logical expression (with && and ||) ?
	or a
	jp z,bxpr91
	call lv01th	;if so, go convert into 0 or 1 in HL, no matter WHAT
	jp bxpr90

bxpr91:	call cvtlvh	;else just flush logical flag values into HL

bxpr90:	pop af
	sta arith	;restore arith flag
	pop af
	sta codflg	;restore code flag.
	lda lcflag	;result a logical constant?
	and 0c0h
	jp z,bxpr9b	;if not, don't create constant return value

	or a		;set Z flag if constant of 0
	ld a,1
	sta sval1	;yes--set constant flag
	push hl
	ld hl,0		;constant value of zero?
	jp bxpr9a	;if so, go store
	inc hl		;else make it 1
bxpr9a:	shld svv1
	pop hl

bxpr9b:	pop af
	cp 2
	ret nz
	ld de,stg8
	jp perr
	
;
; This makes sure that the result of the current
; expression is a hard value of 0 or 1 in HL, no matter WHAT.
;

lv01th:	lda sval1	;logical flag?
	and 4
	jp nz,cvtlvh	;if so, go convert
	lda sval1
	and 1		;constant?
	jp z,lv01b
	push hl		;yes. turn into 0 or 1 in HL
	lhld svv1
	ld a,h
	or l
lv01d:	ld hl,0
	jp z,lv01a
	inc hl
lv01a:	shld svv1
	pop hl
	call flshh1	;flush constant into HL
	ret

lv01b:	lda sval1	;not abs constant-is it rel lv?	
	and 2
	jp z,lv01c
	ld a,1		;if so, turn into constant equal to 0
	sta sval1
	push hl
	xor a		;set Z to force constant value of 0
	jp lv01d	;and go wrap up

lv01c:	lda sval1	;not any kind of constant, so must be val in reg
	and 0c0h	;in DE?
	jp z,lv01e
	ld de,macde0	;yes. char?
	call tschr
	call nz,mcrog	;if not, do 16-bit test
	ld de,mcn12
	call z,mcrog	;else do 8-bit test
	jp lv01f	;and go convert into HL value

lv01e:	ld de,mache0	;value in HL. char?
	call tschr
	call nz,mcrog	;if not, do 16-bit test
	ld de,mcn11
	call z,mcrog	;else do 8-bit test

lv01f:	ld de,macf2	;now convert NZ flag state into HL value
	call mcrog
	ld a,24h	;set flag and value result
	sta sval1
	ld a,1		;set flag value of NZ true
	sta sbmap1
	ret



;
; Process assignment expression, given HL -> left
; element of assignment. This might be either a simple
; assignment or an op= type assignment:
;

aexpr:	call igsht	;check for leading & or ++ or --, so that
	cp ancd	;some common invalid lvalues that can't be
	jp z,badlv	;detected by analyz can be diagnosed properly.
	call ppormm	;is it ++ or --?
	jp z,badlv	;if so, bad lvalue
	cp varcd	;a variable name?
	jp nz,aexpr0	;if not, all done checking for special cases
	inc hl
	inc hl
	inc hl
	ld a,(hl)
	call ppormm	;is it an expr of form foo++ or foo-- ?
	dec hl
	dec hl
	dec hl
	jp nz,aexpr0

badlv:	ld de,stg8b
	call perr

aexpr0:	call rpshp
	ld a,2		;generate address of left arg
	call sgenv
	call ppshp
	cp letcd	; simple '=' assignment?
	jp z,aexpl	;if so, go do it.
	call cnvsop	;convert op= to just op
	push af	;and save the op for later
	lda sval1	;no. abs const lvalue?
	and 1
	jp z,aexp0
	call glvcv	;yes. get value of left operand
	call pshn1	;save info on lvalue before it was indirected
	xor a
	sta sval1	;after indirection, it's a simple value
	jp aexp2a

aexp0:	call flshh1	;not abs const lvalue. flush into HL
	call pshn1
	call gpushh	;gen. push instr. to save address of left arg
	call tsclv	;test for char value. Is it?
	jp z,aexp2	;if so, go do single byte indirection

	call maca0c	;else do double byte indirection, perhaps RST'ed
	jp aexp2a

aexp2:	ld de,mac6e	;if a char, just do "ld l,(hl)"
	call mcrog

aexp2a:	call tslv	;was left arg a simple lvalue?
	jp nz,aexp2b
	lda indc1	;if so, de-bump indirection count
	dec a		; (corresponding to the just-done indirection)
	sta indc1
aexp2b:	call pshn1	;save info on the left arg
	inc hl
	call spshp
	call evala
	call ppshp
	call ppn2	;pop info on left arg
	pop af		;get back the operator code
	call alugen	;now perform the operation
aexp3:	call ppn2	;peek at original lvalue info
	call pshn2
	lda sval2	;was lvalue an abs lv const?
	and 10h
	jp nz,aexp3b	;if so, don't pop or do ANYTHING messy.

aexp3a:	call pn1ind	;else make sure the alugen result is in DE
	call gpoph	;gen 'pop hl' to get addr of left arg back in HL

aexp3b:	call mvn12	;and put the info on the left and right args into
	call ppn1	;  info1 and info2, respectively
	jp letgen	;and go generate the assignment code

aexpl:	call pshn1	;come here to handle simple '=' operator
	inc hl
	lda sval1
	push af	;save info1 optimization byte
	call tcnst1
	call nz,spshp
	call z,rpshp
	call evala	;evaluate rvalue
	call ppshp
	call tpshd
	jp nz,aexpl2
	pop af
	jp aexp3a

aexpl2:	lda sval1
	and 2
	jp nz,aexpl3
	pop af
	jp aexp3b

aexpl3:	pop af
	ld b,a		;save left operand into in B
	and 3		;left operand in a register?
	jp z,aexpl4
	call flshd1	;no...flush right operand into DE
	jp aexp3b	;and go process assignment

aexpl4:	ld a,b		;left operand in a register.
	and 0c0h	;push the appropriate register on stack
	call z,gpushh
	call nz,gpushd
	call flshd1	;evaluate right operand into DE
	call gpoph	;pop left operand into HL
	call mvn12	;set up for assignment processor
	call ppn1
	lda sval1	;but force left operand data to indicate in HL
	and 3fh
	sta sval1
	jp letgen

evala:	lda val
	push af
	ld a,81h
	sta val
	call ltabmp	;bump logical table to make sure we stay in this
	xor a		;statement no matter what the (maybe) logical value is
	call expr2v
	call ltabtd	;come here if true
	call ltabfd	;and come here if false, too.
	call ltabpp	;and pop ltab entry
	pop af
	sta val
	ret


letgen:	call analyz	;ok to assign to the lvalue given?
	lda asnokf
	or a
	jp nz,lg2
letbad:	ld de,stg8b	;no. error.
	call perr
	pop af
	ret

lg2:	push hl		;yup. abs lvalue constant?
	lda sval1
	and 11h
	jp nz,palvc	;if so, go handle

	lda sval1	;no. relative lvalue constant?
	and 2
	jp nz,prlvc	;if so, go handle that.

	lda sval2	;OK, we have lvalue in HL, rvalue somewhere
	and 1		;rvalue a constant?
	jp z,lgncon	;if not, go handle

	call flshh1	;OK, put lvalue into HL if it is in DE

lg3:	lda val		;yes, rvalue is constant.
	or a
	jp nz,lg5		;need result?
	call tsclv
	jp nz,lg4b	;8 bit value?
	ld a,36h	;yes. do "ld (hl),vaue"
	call genb
	lda svv2
	call genb
	jp lgdone

lg4b:	lhld svv2	;16-bit value.
	ld a,h
	or l		;zero special case?
	jp nz,lg4c
	ld de,macac1	;yes.
	call mcrog
	jp lgdone

lg4c:	ld a,36h
	call genb	
	lda svv2
	call genb
	ld a,23h
	call genb
	ld a,36h
	call genb
	lda svv2+1
	call genb
	jp lgdone

lg5:	lhld svv2	;we need value result.
	shld sr0
	call tsclv
	jp nz,lg5b
	ld a,1eh
	call genb
	lda svv2
	call genb
	ld a,73h
	call genb
lg5a:	ld a,40h	;set result in DE flag
	sta sval1
	jp lgdone

lg5b:	ld de,macac3
	call mcrog
	jp lg5a

;
; Come here after all assignemnts have been done
;

lgdone:	call tslv
	jp nz,lgdn2
	lda indc1
	dec a
	sta indc1
lgdn2:	pop hl
	pop af
	call ckvok
	ret

;
; Handle assignment of value in DE to lvalue in HL:
;

lgncon:	call tsclv
	jp nz,lgnc5	;char lvalue?
	ld a,73h	;yes.
	call genb
	jp lg5a

lgnc5:	call tschr2	;no. char rvalue?
	jp nz,lgnc6
	ld de,macac4	;yes--so we're assigning a char to an int lvalue.
	lda val		;need value result?
	or a
	jp z,lgnc5a
	ld de,macac5	;if so, make sure high-order byte is zeroed in result
lgnc5a:	call mcrog
	jp lg5a

lgnc6:	lda optimf
	and 8
	jp z,lgnc7
	ld a,0e7h	;rst 4: ld (hl),e inc hl ld (hl),d
	call genb
	jp lg5a

lgnc7:	ld de,maca1
	call mcrog
	jp lg5a

;
; Assign to absolute lvalue constant location:
;

palvc:	lhld svv1
	shld sr0
	lhld svv2
	shld sr1
	lda sval2	;rvalue a constant?
	and 1
	jp z,palvcc
	lda val		;yes.
	or a
	jp nz,palv3	;need value result?
	call tsclv	;no.
	jp nz,palv2	;8-bit object?
	ld a,3eh	;yes.
	call genb
	lda svv2
	call genb
	ld de,macacb
	call mcrog
	jp lgdone

palv2:	ld de,macacc	;16-bit object.
palv2a:	call mcrog
	xor a
	sta sval1	;result in HL (if needed)
	jp lgdone

palv3:	call tsclv	;need value result.
	jp nz,palv2
	ld a,1eh
	call genb
	lda svv2
	call genb
palv4:	ld a,7bh
	call genb
	ld de,macacb
	call mcrog
	jp lg5a

palvcc:	call tsclv	;rvalue is in a register.
	jp nz,plvc2	;simple char lvalue?
	lda sval2	;yes.
	and 0c0h
	jp nz,palv4	;in HL?
	ld a,7dh	;yes.
	call genb
	ld de,macacb
	jp palv2a

plvc2:	lda sval2	;16-bit value. in HL?
	and 0c0h
	call nz,gexdehl	;go "ex de,hl" if not, to get value into HL
	call tschr2	;simple char rvalue?
	jp nz,plvc3	;if not, do 16-bit assignment normally

	ld a,26h	;else clear H before assigning
	call genb
	xor a
	call genb

plvc3:	ld de,mac09	;go perform assignment
	jp palv2a
	
;
; Assign to a relative lvalue (external or local) location:
;

prlvc:	lda sval2
	and 1
	jp z,prlv2	;constant rvalue?
prlv1:	call flshh1	;yes. get value in HL
	jp lg3

prlv2:	lda sval1	;no; rvalue in a reg. local lvalue?
	and 8
	jp nz,prlv3
	call pn2ind	;yes. get value in DE
	call flshh1
	jp lgncon

prlv3:	lda sval2	;must be external.
	and 0c0h
	ld a,0e5h	;push rvalue.
	jp z,prlv4
	ld a,0d5h
prlv4:	call genb
	call flshh1	;generate lvalue in HL
	ld a,0d1h	;get back rvalue in DE
	call genb
	ld a,40h	;result in DE
	sta sval2
	jp lgncon	;go perform assignment.

glvcv:	push hl
	lhld svv1
	shld sr0
	pop hl
	ld de,mac40
	call mcrog
	lda sval1
	and 0feh	;no longer a simple lvalue constant
	or 10h		;now a "has been" !
	sta sval1
	ret

;
; Gen code to multiply HL by value passed here in HL:
;

gnmulh:	shld sr0	;save the value
	ld a,h
	or a		;is it very big?
	jp nz,mulhbg	;if so, go do brutal ld de,val- call mult- etc.
	ld a,l		;yes.
	or a
	jp nz,gnmh2
	ld de,mac04	;trivial case: ld hl,0
	call mcrog
	ret

gnmh2:	ld b,6		;find out if we have an easy power of two.
	push af	;push value
gnmh2a:	pop af		;pop value
	rra		;rotate right along with carry
	push af	;and immediately save to preserve carry bit
	or a		;did we just rotate the only 1 bit into the carry?
	jp z,gnmh3	;if so, we've got a power of 2 and can do "add hl,hl"'s
	dec b		;else keep rotating
	jp nz,gnmh2a
	pop af		;clean up stack...

mulhbg:	ld de,mac0a	;no simple power of two. use brute force.
	call mcrog
	ret

gnmh3:	pop af
	ld a,7		;ok, we can use add hl,hl's. find out how many
	sub b		;are needed.
	ld b,a		;save 1+n in B.
gnmh4:	dec b
	ret z
	ld a,29h	;and spit 'em out till done.
	call genb
	jp gnmh4


;
; process e1 ? e2 : e3 
; (upon entry, HL -> "?")
;
; New for v1.45 (fixing a bug...)
; Take special care in the case of mixed character and non-character
; values for e2 and e3, so 16 bit values don't get their high order
; bytes chopped off.
;

qexpr:	inc hl		;get HL -> e2
	call gncjf	;gen cond'l jump-on-false to e3

	call ltabtd	;define $ as true branch of pre-? expr
			;		(fixes bug found by D. Greenlaw)
	pop af
	push af
	call rpshp
	call expr1
	call ppshp
	call flshh1
	call igsht
	cp colon	;followed by colon?
	jp z,qxpr2
	call ltabpp
qxpr1:	ld de,stg14	;if not, bad news.
	call perr
	pop de
	ret

qxpr2:	inc hl		;colon found OK.
	call tschr	;set Z if e2 is a character value

	pop bc		;get item on top of stack
	push af	;save result of tschr test for later
	push bc		;put top item back on the stack

	jp nz,qxpr2a	;if e2 wasn't a char, don't bother clearing H
	ld de,mac61
	call mcrog	;clear H if e2 is a char expression	

qxpr2a:	pop af
	call gfjp	;generate forward jump to after e3.
	push af
	call ltabfd	;define false ltab branch
	call ltabpp	;and pop off ltab entry
	call rpshp
	pop af	

;	call 	expr1	;evaluate e3

	push af	;like the call above, except comma operator
	call expr2	;recognition is not allowed due to precedence
	pop af		;rules. This fixes a Dan Grayson bug.

	call ppshp
	call flshh1	;get result in HL

	pop bc		;get top item off stack (label code for plvdl)
	pop af		;get back Z flag, set iff e2 was a char value
	push bc		;put label code back onto stack
	jp z,qxpr3	;if e2 was a char, we don't care if e3 is a char
			;otherwise we might have to promote e3, so let's check:
	call tschr	;was e3 a char value?
	jp nz,qxpr3	;if not, we don't have to worry about e2 being demoted
	ld de,mac61	;else promote e3 to an int so that e2 won't be demoted
	call mcrog	;	since e2 was a 16-bit value and e3 is a char.
	ld a,1		;and make the overall result an int
	sta typ1
qxpr3:	call plvdl	;and pop and define after-e3 label
	ret

	;IF LASM
	;link cc2d
	;ENDIF
