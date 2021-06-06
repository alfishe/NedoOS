TESTali8
	get
	next
        ld hl,_AL
        and (hl) ;al ;CF=0
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_

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

TESTaxi16
	get
	next
        ld hl,(_AX)
        and l ;al ;CF=0
        ld l,a
	get
	next
        and h ;ah ;CF=0
        ld h,a
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
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
