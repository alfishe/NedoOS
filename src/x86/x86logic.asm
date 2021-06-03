       if 1
XORaxax
	xor a ;CF=0
	ld h,a
	ld l,a
        ld (_AX),hl
        exx
	ld d,a ;parity data ;the SF, ZF, and PF flags are set according to the result. The state of the AF flag is undefined. 
        ld e,a;0 ;OF=0
	exx
	ex af,af' ;'
       _Loop_

	macro XORSELFRP rp
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
        ld hl,(_AX)
        KEEPLOGICCFPARITYOVERFLOW_FROMHL
       _Loop_

	macro ORSELFRP rp
        ld hl,(rp)
        KEEPLOGICCFPARITYOVERFLOW_FROMHL
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
       endif

;and al,n
ANDali8
	get
	next
        ld hl,_AL
        and (hl) ;al ;CF=0
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_

ORali8
	get
	next
        ld hl,_AL
        or (hl) ;al ;CF=0
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_

XORali8
	get
	next
        ld hl,_AL
        xor (hl) ;al ;CF=0
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_

ANDaxi16
	get
	next
        ld hl,(_AX)
        and l ;al ;CF=0
        ld l,a
	get
	next
        and h ;ah ;CF=0
        ld h,a
        ld (_AX),hl
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
       _Loop_

ORaxi16
	get
	next
        ld hl,(_AX)
        or l ;al ;CF=0
        ld l,a
	get
	next
        or h ;ah ;CF=0
        ld h,a
        ld (_AX),hl
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
       _Loop_

XORaxi16
	get
	next
        ld hl,(_AX)
        xor l ;al ;CF=0
        ld l,a
	get
	next
        xor h ;ah ;CF=0
        ld h,a
        ld (_AX),hl
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
       _Loop_
