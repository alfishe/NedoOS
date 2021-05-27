XORaxax
	exx
	;ex af,af'
	xor a ;CF=0
	ld h,a
	ld l,a
	ld d,a ;parity data ;the SF, ZF, and PF flags are set according to the result. The state of the AF flag is undefined. 
        ld e,a;0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

	macro XORSELFRP rp
	;ex af,af'
	xor a
	ld h,a
	ld l,a ;CF=0
        ld (rp),hl
        exx
	ld d,a ;parity data
        ld e,0 ;OF=0
        exx
	ex af,af' ;'
       _Loop_
	endm
XORcxcx
	XORSELFRP _CX
XORdxdx
	XORSELFRP _DX
XORbxbx
	XORSELFRP _BX

ORaxax
ANDaxax
	exx
	;ex af,af'
	ld a,h
	or l ;CF=0
	ld d,a ;parity data
        ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

	macro ORSELFRP rp
	;ex af,af'
        ld hl,(rp)
	ld a,h
	or l ;CF=0
	ex af,af' ;'
        exx
	ld a,h
	xor l
	ld d,a ;parity data
        ld e,0 ;OF=0
        exx
       _Loop_
	endm
ORcxcx
ANDcxcx
	ORSELFRP _CX
ORdxdx
ANDdxdx
	ORSELFRP _DX
ORbxbx
ANDbxbx
	ORSELFRP _BX

;and al,n
ANDali8
	get
	next
        exx
        and l ;al ;CF=0
        ld l,a
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

ORali8
	get
	next
        exx
        or l ;al ;CF=0
        ld h,a
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

XORali8
	get
	next
        exx
        xor l ;al ;CF=0
        ld h,a
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

ANDaxi16
	get
	next
        exx
        and l ;al ;CF=0
        ld l,a
        exx
	get
	next
        exx
        and h ;ah ;CF=0
        ld h,a
        xor l
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

ORaxi16
	get
	next
        exx
        or l ;al ;CF=0
        ld l,a
        exx
	get
	next
        exx
        or h ;ah ;CF=0
        ld h,a
        xor l
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_

XORaxi16
	get
	next
        exx
        xor l ;al ;CF=0
        ld l,a
        exx
	get
	next
        exx
        xor h ;ah ;CF=0
        ld h,a
        xor l
	ld d,a ;parity data
	ld e,0 ;OF=0
	ex af,af' ;'
	exx
       _Loop_
