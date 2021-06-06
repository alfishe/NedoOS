        macro ADDRr16
;a=r/m byte
        ld c,a
        and 7
        add a,a
        ld l,a
        ld h,_AX/256
        ld a,c
        endm
        macro GETr16
        ld c,(hl)
        inc l
        ld b,(hl)
        endm

;000=[bx]+[si]+disp
;001=[bx]+[di]+disp
;010=[bp]+[si]+disp
;011=[bp]+[di]+disp
;100=[si]+disp
;101=[di]+disp
;110=[bp]+disp ;за исключением случая mod=00 и rm=110, когда EA равен старшему и младшему байтам смещения
;111=[bx]+disp
        macro ADDRm16
        call ADDRm16_pp
        endm
;a=r/m byte
ADDRm16_pp
        bit 0,a
        ld hl,(_SI)
        jr z,$+5
        ld hl,(_DI)
        bit 2,a
        jr z,9f
;1xx
        bit 1,a
        jr z,8f
        bit 0,a
        ld hl,(_BX)
        jr nz,8f
        ld hl,(_BP)
       cp 64
       jr nc,8f
;[bp+nodisp] = [disp]
       ld c,a
       getHL
        ;jp 4f
        ld a,c
        ret
9 ;0xx
        bit 1,a
        ld bc,(_BX) ;00?=[bx]+[?i]+disp
        jr z,$+6
        ld bc,(_BP) ;00?=[bp]+[?i]+disp
        add hl,bc
8
;MD=00: cmd [...] ;no disp
       cp 64
       ret c ;jr c,7f ;no disp
       ld c,a
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
;get dispL
	get
	next
        add a,l
        ld l,a
        jr nc,$+3
        inc h
       bit 7,c
       jr z,4f
;get dispH
	get
        add a,h
        ld h,a
	next
4
       ld a,c
;7
        ret

        macro GETm16
        getmemDS_bc
        endm
        macro GETm16_hl
        getmemDS_hl
        endm
        macro GETm8
        getmemDS ;a
        endm
        macro GETm8_c
        getmemDS_c
        endm

        macro _PUTr16Loop_
;hl is kept since ADDRr16
        ld a,l
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jp z,encodeSPLoop ;TODO ret z
       _Loop_
        endm

encodeSPLoop
encodeSPLoopC
        ld h,b
        ld l,c
        encodeSP
       _Loop_

        macro _PUTr16LoopC
;hl is kept since ADDRr16
        ld a,l
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jp z,encodeSPLoopC ;TODO ret z
       _LoopC
        endm

        macro _PUTm16LoopC
        putmemDS_bc
       _LoopC
        endm

        macro _PUTm8LoopC
        putmemDS ;a
       _LoopC
        endm

        macro _PUTm8_cLoopC
        putmemDS_c
       _LoopC
        endm

MOVrm8i8
	get
	next
;a=MD000R/M: mov r/m,i8
;MD=00: mov [...],i8
;MD=01: mov [...+disp8],i8
;MD=10: mov [...+disp16],i8
;MD=11: mov r/m,i8 ;проще всего, но не имеет смысла (есть короткий код)
        cp 0b11000000
        jp c,MOVrmmemi8
        ld h,_AX/256
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        get
        next
        ld (hl),a
       _Loop_
MOVrmmemi8
       ADDRm16
        get
        next
       _PUTm8LoopC

MOVrm16i16
	get
	next
;a=MD000R/M: mov r/m,i16
;MD=00: mov [...],i16
;MD=01: mov [...+disp8],i16
;MD=10: mov [...+disp16],i16
;MD=11: mov r/m,i16 ;проще всего, но не имеет смысла (есть короткий код)
        cp 0b11000000
        jp c,MOVrmmemi16
        and 7
        add a,a
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;rm addr
        getBC
       _PUTr16Loop_
MOVrmmemi16
       ADDRm16
        getBC
       _PUTm16LoopC

MOVrmr8
	get
	next
;a=MDregR/M
;MD=00: mov [...],r8
;MD=01: mov [...+disp8],r8
;MD=10: mov [...+disp16],r8
;MD=11: mov r/m,r8 ;проще всего
        cp 0b11000000
        jp c,MOVrmmemr8
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;r8 addr
        ld c,(hl)
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        ld (hl),c
       _Loop_
MOVrmmemr8
       ADDRm16
       or 0b11000000
        ld c,a
        ld b,_AX/256
        ld a,(bc)
        ld c,a ;r8 addr
        ld a,(bc)
       _PUTm8LoopC

MOVrmr16
	get
	next
;a=MDregR/M
;MD=00: mov [...],r16
;MD=01: mov [...+disp8],r16
;MD=10: mov [...+disp16],r16
;MD=11: mov r/m,r16 ;проще всего
        cp 0b11000000
        jr c,MOVrmmemr16
       push af
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop af
       and 7
       add a,a
        ld l,a
       _PUTr16Loop_
MOVrmmemr16
       ADDRm16
       push hl
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop hl       
       _PUTm16LoopC

MOVr8rm
	get
	next
;a=MDregR/M
;MD=00: mov r8,[...]
;MD=01: mov r8,[...+disp8]
;MD=10: mov r8,[...+disp16]
;MD=11: mov r8,r/m ;проще всего
        cp 0b11000000
        jp c,MOVr8rmmem
        ld l,a
       res 6,l
        ld h,_AX/256
        ld l,(hl) ;rm addr
        ld c,(hl)
       ld l,a
        ld l,(hl) ;r8 addr
        ld (hl),c
       _Loop_
MOVr8rmmem
       ADDRm16
       push af
       GETm8_c
       pop af
       or 0b11000000
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;r8 addr
        ld (hl),c
       _LoopC

MOVr16rm
	get
	next
;a=MDregR/M
;MD=00: mov r16,[...]
;MD=01: mov r16,[...+disp8]
;MD=10: mov r16,[...+disp16]
;MD=11: mov r16,r/m ;проще всего
        cp 0b11000000
        jr c,MOVr16rmmem
       push af
       and 7
       add a,a
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop af
        rra
        rra
        and 7*2 ;r16*2
        ld l,a
       _PUTr16Loop_
MOVr16rmmem
       ADDRm16
       push af
       GETm16
       pop af
        rra
        rra
        and 7*2 ;r16*2
        ld l,a
        ld h,_AX/256
       _PUTr16LoopC

MOVsregrm16
	get
	next
;a=MDregR/M
;MD=00: mov [...],r16
;MD=01: mov [...+disp8],r16
;MD=10: mov [...+disp16],r16
;MD=11: mov r/m,r16 ;проще всего
        cp 0b11000000
        jr c,MOVsregrmmem
       push af
       and 7
       add a,a
        ld l,a
        ld c,(hl)
        inc l
        ld b,(hl)
        jr MOVsregrmq
MOVsregrmmem
       push af
       ADDRm16
       GETm16
MOVsregrmq
       pop af
        rra
        rra
        and 7*2
        add a,_ES&0xff
        ld l,a
        ld h,_ES/256
        ld (hl),c
        inc l
        ld (hl),b
;TODO count?S
	xor a
	sla c
        rl b
	rla
	sla c
        rl b
	rla
	sla c
        rl b
	rla
	sla c
        rl b
	rla
        set 5,l
        ld (hl),b
        dec l
        ld (hl),c
        set 3,l
	ld (hl),a
       _LoopC

MOVrm16sreg
	get
	next
;a=MDregR/M
;MD=00: mov [...],r16
;MD=01: mov [...+disp8],r16
;MD=10: mov [...+disp16],r16
;MD=11: mov r/m,r16 ;проще всего
        cp 0b11000000
        jr c,MOVrmmemsreg
       push af
        rra
        rra
        and 7*2
        add a,_ES&0xff
        ld l,a
        ld h,_ES/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop af
       and 7
       add a,a
        ld l,a
       _PUTr16Loop_
MOVrmmemsreg
       ADDRm16
       push hl
        rra
        rra
        and 7*2
        add a,_ES&0xff
        ld l,a
        ld h,_ES/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop hl       
       _PUTm16LoopC

       macro OPrmmemi8_POST
        ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC
       endm
       macro LOGICOPrmmemi8_POST
        ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC
       endm
GRP1rmi8
	get
	next
;a=MD000R/M: add r/m,i8
;a=MD001R/M: or r/m,i8
;a=MD010R/M: adc r/m,i8
;a=MD011R/M: sbb r/m,i8
;a=MD100R/M: and r/m,i8
;a=MD101R/M: sub r/m,i8
;a=MD110R/M: xor r/m,i8
;a=MD111R/M: cmp r/m,i8
;MD=00: cmd [...],i8
;MD=01: cmd [...+disp8],i8
;MD=10: cmd [...+disp16],i8
;MD=11: cmd r/m,i8 ;проще всего
        cp 0b11000000
        jr c,GRP1rmmemi8
       ld l,a
       res 6,l
       ld h,_AX/256
       ld l,(hl) ;rm addr
       and 0b00111000
	jp z,ADDrmi8
	cp 0b00001000
	jp z,ORrmi8
	cp 0b00010000
	jp z,ADCrmi8
	cp 0b00011000
	jp z,SBBrmi8
	cp 0b00100000
	jp z,ANDrmi8
	cp 0b00101000
	jp z,SUBrmi8
	cp 0b00110000
	jp z,XORrmi8
;CMPrmi8
        get
        next
        ld c,a
        ld a,(hl)
        sub c
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC
GRP1rmmemi8
       ADDRm16
       and 0b00111000
	jp z,ADDrmmemi8
	cp 0b00001000
	jp z,ORrmmemi8
	cp 0b00010000
	jp z,ADCrmmemi8
	cp 0b00011000
	jp z,SBBrmmemi8
	cp 0b00100000
	jp z,ANDrmmemi8
	cp 0b00101000
	jp z,SUBrmmemi8
	cp 0b00110000
	jp z,XORrmmemi8
;CMPrmmemi8
        GETm8_c
        get
        next
        ld b,a
        ld a,c
        sub b
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC

ADDrmi8
        or a
        ex af,af' ;'
ADCrmi8
        ex af,af' ;'
        get
        next
        adc a,(hl)
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC
SUBrmi8
        or a
        ex af,af' ;'
SBBrmi8
        ex af,af' ;'
        get
        next
        ld c,a
        ld a,(hl)
        sbc a,c
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC
XORrmi8
        get
        next
        xor (hl)
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
ORrmi8
        get
        next
        xor (hl)
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
ANDrmi8
        get
        next
        xor (hl)
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC

ADDrmmemi8
        or a
        ex af,af' ;'
ADCrmmemi8
       push hl
        GETm8_c
        ex af,af' ;'
        get
        next
        adc a,c
        OPrmmemi8_POST
SUBrmmemi8
        or a
        ex af,af' ;'
SBBrmmemi8
       push hl
        GETm8_c
        ex af,af' ;'
        get
        next
        ld b,a
        ld a,c
        sbc a,b
        OPrmmemi8_POST
XORrmmemi8
       push hl
        GETm8_c
        get
        next
        xor c
        LOGICOPrmmemi8_POST
ORrmmemi8
       push hl
        GETm8_c
        get
        next
        or c
        LOGICOPrmmemi8_POST
ANDrmmemi8
       push hl
        GETm8_c
        get
        next
        and c
        LOGICOPrmmemi8_POST

GRP1rmi16
	get
	next
;a=MD000R/M: add r/m,i16
;a=MD001R/M: or r/m,i16
;a=MD010R/M: adc r/m,i16
;a=MD011R/M: sbb r/m,i16
;a=MD100R/M: and r/m,i16
;a=MD101R/M: sub r/m,i16
;a=MD110R/M: xor r/m,i16
;a=MD111R/M: cmp r/m,i16
;MD=00: cmd [...],i16
;MD=01: cmd [...+disp8],i16
;MD=10: cmd [...+disp16],i16
;MD=11: cmd r/m,i16 ;проще всего
        cp 0b11000000
        jr c,GRP1rmmemi16
       ADDRr16
       and 0b00111000
	jp z,ADDr16i16
	cp 0b00001000
	jp z,ORr16i16
	cp 0b00010000
	jp z,ADCr16i16
	cp 0b00011000
	jp z,SBBr16i16
	cp 0b00100000
	jp z,ANDr16i16
	cp 0b00101000
	jp z,SUBr16i16
	cp 0b00110000
	jp z,XORr16i16
;CMPr16i16
        GETr16
	ld h,b
	ld l,c
	getBC
	or a
	sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       _Loop_
GRP1rmmemi16
       ADDRm16
       and 0b00111000
	jp z,ADDrmmemi16
	cp 0b00001000
	jp z,ORrmmemi16
	cp 0b00010000
	jp z,ADCrmmemi16
	cp 0b00011000
	jp z,SBBrmmemi16
	cp 0b00100000
	jp z,ANDrmmemi16
	cp 0b00101000
	jp z,SUBrmmemi16
	cp 0b00110000
	jp z,XORrmmemi16
CMPrmmemi16
        GETm16
        ld h,b
        ld l,c
        getBC
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC

       macro OPr16i16_PRE
       push hl
        GETr16
        ld h,b
        ld l,c
        getBC
       endm
       macro OPr16i16_POST
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
       endm
       macro LOGICOPr16i16_POST
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
       endm
ADDr16i16
        or a
        ex af,af' ;'
ADCr16i16
        OPr16i16_PRE
        ex af,af' ;'
        adc hl,bc
        OPr16i16_POST
SUBr16i16
        or a
        ex af,af' ;'
SBBr16i16
        OPr16i16_PRE
        ex af,af' ;'
        sbc hl,bc
        OPr16i16_POST
XORr16i16
        OPr16i16_PRE
        ld a,l
        xor c
        ld l,a
        ld a,h
        xor b
        ld h,a
        LOGICOPr16i16_POST
ORr16i16
        OPr16i16_PRE
        ld a,l
        or c
        ld l,a
        ld a,h
        or b
        ld h,a
        LOGICOPr16i16_POST
ANDr16i16
        OPr16i16_PRE
        ld a,l
        and c
        ld l,a
        ld a,h
        and b
        ld h,a
        LOGICOPr16i16_POST

       macro OPrmmemi16_PRE
       push hl
        GETm16
        ld h,b
        ld l,c
        getBC
       endm
       macro OPrmmemi16_POST
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTm16LoopC
       endm
       macro LOGICOPrmmemi16_POST
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
        ld b,h
        ld c,l
       pop hl
       _PUTm16LoopC
       endm
ADDrmmemi16
        or a
        ex af,af' ;'
ADCrmmemi16
        OPrmmemi16_PRE
        ex af,af' ;'
        adc hl,bc
        OPrmmemi16_POST
SUBrmmemi16
        or a
        ex af,af' ;'
SBBrmmemi16
        OPrmmemi16_PRE
        ex af,af' ;'
        sbc hl,bc
        OPrmmemi16_POST
XORrmmemi16
        OPrmmemi16_PRE
        ld a,l
        xor c
        ld l,a
        ld a,h
        xor b
        ld h,a
        LOGICOPrmmemi16_POST
ORrmmemi16
        OPrmmemi16_PRE
        ld a,l
        or c
        ld l,a
        ld a,h
        or b
        ld h,a
        LOGICOPrmmemi16_POST
ANDrmmemi16
        OPrmmemi16_PRE
        ld a,l
        and c
        ld l,a
        ld a,h
        and b
        ld h,a
        LOGICOPrmmemi16_POST

       macro OPrmr8_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd [...],r8
;MD=01: cmd [...+disp8],r8
;MD=10: cmd [...+disp16],r8
;MD=11: cmd r/m,r8 ;проще всего
        cp 0b11000000
        jp c,6f;OPrmmemr8
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;r8 addr
        ld c,(hl)
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
       endm
       macro OPrmr8_POST
6;OPrmmemr8
       ADDRm16
       or 0b11000000
       push de
       push hl
       ld e,a
       GETm8
       ld c,a
        ld l,e
        ld h,_AX/256
        ld l,(hl) ;r8 addr
       endm
ADDrmr8
        or a
        ex af,af' ;'
ADCrmr8
        OPrmr8_PRE
        ex af,af' ;'
        ld a,(hl)
        adc a,c ;op
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        ex af,af' ;'
        ld a,c
        adc a,(hl) ;op
       ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       pop de
       _PUTm8_cLoopC
SUBrmr8
        or a
        ex af,af' ;'
SBBrmr8
        OPrmr8_PRE
        ex af,af' ;'
        ld a,(hl)
        sbc a,c ;op
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        ex af,af' ;'
        ld a,c
        sbc a,(hl) ;op
       ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       pop de
       _PUTm8_cLoopC
CMPrmr8
        OPrmr8_PRE
        ld a,(hl)
        sub c ;op
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
6;OPrmmemr8
       ADDRm16
       or 0b11000000
       push de
       ld e,a
       GETm8
        ld l,e
       pop de
        ld h,_AX/256
        ld l,(hl) ;r8 addr
        sub (hl) ;op
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC
XORrmr8
        OPrmr8_PRE
        xor (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        xor (hl) ;op
       ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       pop de
       _PUTm8_cLoopC
ORrmr8
        OPrmr8_PRE
        or (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        or (hl) ;op
       ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       pop de
       _PUTm8_cLoopC
ANDrmr8
        OPrmr8_PRE
        and (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        and (hl) ;op
       ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       pop de
       _PUTm8_cLoopC

       macro OPrmr16_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd r16,[...]
;MD=01: cmd r16,[...+disp8]
;MD=10: cmd r16,[...+disp16]
;MD=11: cmd r16,r/m ;проще всего
        cp 0b11000000
        jp c,6f;OPrmmemr16
       push af
        rra
        rra
        and 7*2 ;r16
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop af
        and 7 ;rm
        add a,a
        ld l,a
       ;push hl
        ;ld a,(hl)
        ;inc l
        ;ld h,(hl)
        ;ld l,a
        ;or a
        ;adc hl,bc ;op
       endm
       macro OPrmr16_POST
6;OPrmmemr16
       ADDRm16
       push hl
        ld h,_AX/256
        rra
        rra
        and 7*2 ;r16
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop hl
       ;push hl
       ;GETm16_hl
        ;or a
        ;adc hl,bc ;op
       endm
ADDrmr16
        or a
        ex af,af' ;'
ADCrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        adc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
       push hl
       GETm16_hl
        ex af,af' ;'
        adc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
      _PUTm16LoopC
SUBrmr16
        or a
        ex af,af' ;'
SBBrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        sbc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
       push hl
       GETm16_hl
        ex af,af' ;'
        adc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
      _PUTm16LoopC
CMPrmr16
        OPrmr16_PRE
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        sbc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
        OPrmr16_POST
       GETm16_hl
        or a
        sbc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
XORrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        xor c
        ld c,a
        inc l
        ld a,(hl)
        xor b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
       push hl
       GETm16_hl
        ld a,l
        xor c
        ld c,a
        ld a,h
        xor b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       pop hl
      _PUTm16LoopC
ORrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        or c
        ld c,a
        inc l
        ld a,(hl)
        or b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
       push hl
       GETm16_hl
        ld a,l
        or c
        ld c,a
        ld a,h
        or b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       pop hl
      _PUTm16LoopC
ANDrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        and c
        ld c,a
        inc l
        ld a,(hl)
        and b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
       push hl
       GETm16_hl
        ld a,l
        and c
        ld c,a
        ld a,h
        and b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       pop hl
      _PUTm16LoopC

       macro OPr8rm_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd r8,[...]
;MD=01: cmd r8,[...+disp8]
;MD=10: cmd r8,[...+disp16]
;MD=11: cmd r8,r/m ;проще всего
        cp 0b11000000
        jp c,6f;ADDr8rmmem
        ld l,a
       res 6,l
        ld h,_AX/256
        ld l,(hl) ;rm addr
        ld c,(hl)
5;ADDr8rmok
        ld l,a
        ld l,(hl) ;r8 addr
        ;ld a,(hl)
        ;add a,c ;op
       endm
       macro OPr8rm_POST
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC
6;ADDr8rmmem
       ADDRm16
       push af
       GETm8_c
       pop af
       or 0b11000000
        ld h,_AX/256
       jp 5b;ADDr8rmok
       endm
       macro LOGICOPr8rm_POST
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
6;ADDr8rmmem
       ADDRm16
       push af
       GETm8_c
       pop bc
       or 0b11000000
        ld h,_AX/256
       jp 5b;ADDr8rmok
       endm
ADDr8rm
        or a
        ex af,af' ;'
ADCr8rm
        OPr8rm_PRE
        ex af,af' ;'
        ld a,(hl)
        adc a,c ;op
        ld (hl),a
        OPr8rm_POST
SUBr8rm
        or a
        ex af,af' ;'
SBBr8rm
        OPr8rm_PRE
        ex af,af' ;'
        ld a,(hl)
        sbc a,c ;op
        ld (hl),a
        OPr8rm_POST
CMPr8rm
        OPr8rm_PRE
        ld a,(hl)
        sub c ;op
        OPr8rm_POST
XORr8rm
        OPr8rm_PRE
        ld a,(hl)
        xor c ;op
        ld (hl),a
        LOGICOPr8rm_POST
ORr8rm
        OPr8rm_PRE
        ld a,(hl)
        or c ;op
        ld (hl),a
        LOGICOPr8rm_POST
ANDr8rm
        OPr8rm_PRE
        ld a,(hl)
        and c ;op
        ld (hl),a
        LOGICOPr8rm_POST

       macro OPr16rm_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd r16,[...]
;MD=01: cmd r16,[...+disp8]
;MD=10: cmd r16,[...+disp16]
;MD=11: cmd r16,r/m ;проще всего
        cp 0b11000000
        jp c,6f;OPr16rmmem
       push af
        and 7 ;rm
        add a,a
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
5;OPr16rmok
       pop af
        rra
        rra
        and 7*2 ;r16
        ld l,a
       ;push hl
        ;ld a,(hl)
        ;inc l
        ;ld h,(hl)
        ;ld l,a
        ;or a
        ;adc hl,bc ;op
       endm
       macro OPr16rm_POST
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16LoopC
6;OPr16rmmem
       ADDRm16
       push af
       GETm16
        ld h,_AX/256
       jp 5b;OPr16rmok
       endm
       macro LOGICOPr16rm_POST
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _PUTr16LoopC
6;OPr16rmmem
       ADDRm16
       push af
       GETm16
        ld h,_AX/256
       jp 5b;OPr16rmok
       endm
ADDr16rm
        or a
        ex af,af' ;'
ADCr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        adc hl,bc ;op
        OPr16rm_POST
SUBr16rm
        or a
        ex af,af' ;'
SBBr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        sbc hl,bc ;op
        OPr16rm_POST
CMPr16rm
        OPr16rm_PRE
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        sbc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
       _PUTr16LoopC
6;OPr16rmmem
       ADDRm16
       push af
       GETm16
        ld h,_AX/256
       jp 5b;OPr16rmok
XORr16rm
        OPr16rm_PRE
        ld a,(hl)
        xor c
        ld c,a
        inc l
        ld a,(hl)
        xor b
        ld b,a
        dec l
        LOGICOPr16rm_POST
ORr16rm
        OPr16rm_PRE
        ld a,(hl)
        or c
        ld c,a
        inc l
        ld a,(hl)
        or b
        ld b,a
        dec l
        LOGICOPr16rm_POST
ANDr16rm
        OPr16rm_PRE
        ld a,(hl)
        and c
        ld c,a
        inc l
        ld a,(hl)
        and b
        ld b,a
        dec l
        LOGICOPr16rm_POST

GRP2rm81
;a=MD000R/M: rol r/m
;a=MD001R/M: ror r/m
;a=MD010R/M: rcl r/m
;a=MD011R/M: rcr r/m
;a=MD100R/M: shl r/m
;a=MD101R/M: shr r/m
;a=MD110R/M: ??? r/m
;a=MD111R/M: sar r/m
        cp 0b11000000
        jr c,GRP2rmmem81
       ld l,a
       res 6,l
       ld h,_AX/256
       ld l,(hl) ;rm addr
       and 0b00111000
	jp z,ROLr8
	cp 0b00001000
	jp z,RORr8
	cp 0b00010000
	jp z,RCLr8
	cp 0b00011000
	jp z,RCRr8
	cp 0b00100000
	jp z,SHLr8
	cp 0b00101000
	jp z,SHRr8
	cp 0b00111000
	jp z,SARr8
	jp $;PANIC
GRP2rmmem81
       ADDRm16
       push hl
       and 0b00111000
	jp z,ROLm8
	cp 0b00001000
	jp z,RORm8
	cp 0b00010000
	jp z,RCLm8
	cp 0b00011000
	jp z,RCRm8
	cp 0b00100000
	jp z,SHLm8
	cp 0b00101000
	jp z,SHRm8
	cp 0b00111000
	jp z,SARm8
	jp $;PANIC

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLr8
        ex af,af' ;' ;remember ZF
        ld a,(hl)
        rlca
        ld (hl),a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
       _Loop_
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORr8
        ex af,af' ;' ;remember ZF
        ld a,(hl)
        rrca
        ld (hl),a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _Loop_
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLr8
        ex af,af' ;' ;remember ZF,CF
        ld a,(hl)
        rla
        ld (hl),a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
       _Loop_
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRr8
        ex af,af' ;' ;remember ZF,CF
        ld a,(hl)
        rra
        ld (hl),a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _Loop_
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLr8
        sla (hl)
        ld a,(hl)
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRr8
        srl (hl)
        ld a,(hl)
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _Loop_
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARr8
        sra (hl)
        ld a,(hl)
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _Loop_

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLm8
        GETm8_c
        ex af,af' ;' ;remember ZF
        ld a,c
        rlca
        ld c,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
       pop hl
       _PUTm8_cLoopC
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORm8
        GETm8_c
        ex af,af' ;' ;remember ZF
        ld a,c
        rrca
        ld c,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       pop hl
       _PUTm8_cLoopC
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLm8
        GETm8_c
        ex af,af' ;' ;remember ZF,CF
        ld a,c
        rla
        ld c,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
       pop hl
       _PUTm8_cLoopC
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRm8
        GETm8_c
        ex af,af' ;' ;remember ZF,CF
        ld a,c
        rra
        ld c,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       pop hl
       _PUTm8_cLoopC
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLm8
        GETm8_c
        sla c
        ld a,c
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRm8
        GETm8_c
        srl c
        ld a,c
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       pop hl
       _PUTm8_cLoopC
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARm8
        GETm8_c
        sra c
        ld a,c
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       pop hl
       _PUTm8_cLoopC

GRP2rm161
;a=MD000R/M: rol r/m
;a=MD001R/M: ror r/m
;a=MD010R/M: rcl r/m
;a=MD011R/M: rcr r/m
;a=MD100R/M: shl r/m
;a=MD101R/M: shr r/m
;a=MD110R/M: ??? r/m
;a=MD111R/M: sar r/m
        cp 0b11000000
        jr c,GRP2rmmem161
       ADDRr16
       and 0b00111000
	jp z,ROLr16
	cp 0b00001000
	jp z,RORr16
	cp 0b00010000
	jp z,RCLr16
	cp 0b00011000
	jp z,RCRr16
	cp 0b00100000
	jp z,SHLr16
	cp 0b00101000
	jp z,SHRr16
	cp 0b00111000
	jp z,SARr16
	jp $;PANIC
GRP2rmmem161
       ADDRm16
       push hl
       and 0b00111000
       if 1
	jp z,ROLm16
	cp 0b00001000
	jp z,RORm16
	cp 0b00010000
	jp z,RCLm16
	cp 0b00011000
	jp z,RCRm16
	cp 0b00100000
	jp z,SHLm16
	cp 0b00101000
	jp z,SHRm16
	cp 0b00111000
	jp z,SARm16
       endif
	jp $;PANIC

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLr16
        ex af,af' ;' ;remember ZF        
        inc hl ;keep ZF
        ld a,(hl)
        ld b,a
        rla
        dec hl ;keep ZF
        ld a,(hl)
        rla
        ld c,a
        ld a,b
        rla
        ld b,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
       _PUTr16Loop_
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORr16
        ex af,af' ;' ;remember ZF        
        inc hl ;keep ZF
        ld a,(hl)
        ld b,a
        rra
        dec hl ;keep ZF
        ld a,(hl)
        rra
        ld c,a
        ld a,b
        rra ;use CF from C
        ld b,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _PUTr16Loop_
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLr16
        ex af,af' ;' ;remember ZF,CF
        ld a,(hl)
        rla
        ld c,a
        inc hl ;keep ZF
        ld a,(hl)
        rla
        ld b,a
        dec hl ;keep ZF
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
       _PUTr16Loop_
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRr16
        ex af,af' ;' ;remember ZF,CF
        inc hl ;keep ZF
        ld a,(hl)
        rra
        ld b,a
        dec hl ;keep ZF
        ld a,(hl)
        rra
        ld c,a
        ld a,b
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _PUTr16Loop_
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLr16
        ld a,(hl)
        add a,a
        ld c,a
        inc l
        ld a,(hl)
        exx
        ld e,a ;overflow data
        exx
        rla
        ld b,a
        ld a,c
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
       ld a,(hl)
       rla ;CF
       dec hl ;keep ZF
	ex af,af' ;'
	ld a,b
	xor c
	exx
	ld d,a ;parity data
	exx
       _PUTr16Loop_
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRr16
        inc l
        ld b,(hl)
        srl b
        dec l
        ld c,(hl)
        rra
        ld c,a
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
       ld a,(hl)
       rra ;CF
	ex af,af' ;'
        ld a,b
        exx
        ld e,a ;overflow data
        exx
	xor c
	exx
	ld d,a ;parity data
	exx
       _PUTr16Loop_
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARr16
        inc l
        ld b,(hl)
        sra b
        dec l
        ld c,(hl)
        rra
        ld c,a
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and 1
       or b ;CF=0 ;ZF=(bc==0)
       ld a,(hl)
       rra ;CF
	ex af,af' ;'
        ld a,b
        exx
        ld e,a ;overflow data
        exx
	xor c
	exx
	ld d,a ;parity data
	exx
       _PUTr16Loop_

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLm16
       GETm16
        ld a,b
        exx
	ld e,a ;overflow data
        exx
       ld a,b
       rla
        rl c
        rl b
       rl l ;l0=new CF
       ex af,af' ;'
       ld a,l
       rra ;new CF, keep other flags
       ex af,af' ;'
       pop hl
       _PUTm16LoopC
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORm16
       GETm16
       ld a,c
       rra
        rr b
        rr c
       rl l ;l0=new CF
       ex af,af' ;'
       ld a,l
       rra ;new CF, keep other flags
       ex af,af' ;'
        ld a,b
        exx
	ld e,a ;overflow data
        exx
       pop hl
       _PUTm16LoopC
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLm16
       GETm16
        ld a,b
        exx
	ld e,a ;overflow data
        exx
       ex af,af' ;'
       rla
       ld l,a ;l0=old CF, keep other flags
       ex af,af' ;'
       rr l ;restore CF
        rl c
        rl b
       rl l ;l0=new CF
       ex af,af' ;'
       ld a,l
       rra ;new CF, keep other flags
       ex af,af' ;'
       pop hl
       _PUTm16LoopC
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRm16
       GETm16
       ex af,af' ;'
       rla
       ld l,a ;l0=old CF, keep other flags
       ex af,af' ;'
       rr l ;restore CF
        rr b
        rr c
       rl l ;l0=new CF
       ex af,af' ;'
       ld a,l
       rra ;new CF, keep other flags
       ex af,af' ;'
        ld a,b
        exx
	ld e,a ;overflow data
        exx
       pop hl
       _PUTm16LoopC
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLm16 ;TODO через hl?
       GETm16
        ld a,b
        exx
        ld e,a ;overflow data
        exx
       ld l,b
        sla c
        rl b
        ld a,c
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
       ld a,l;b
       rla ;CF
	ex af,af' ;'
	ld a,b
	xor c
	exx
	ld d,a ;parity data
	exx
       pop hl
       _PUTm16LoopC
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRm16
       GETm16
       ld l,c
        srl b
        rr c
        ld a,c
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
       ld a,l;c
       rra ;CF
	ex af,af' ;'
        ld a,b
        exx
        ld e,a ;overflow data
        exx
	xor c
	exx
	ld d,a ;parity data
	exx
       pop hl
       _PUTm16LoopC
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARm16
       GETm16
       ld l,c
        sra b
        rr c
        ld a,c
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
       ld a,l;c
       rra ;CF
	ex af,af' ;'
        ld a,b
        exx
        ld e,a ;overflow data
        exx
	xor c
	exx
	ld d,a ;parity data
	exx
       pop hl
       _PUTm16LoopC

GRP316
;mul,div,test,not,neg
	get
	next
;a=MD000R/M: test r/m,i16 (не верится по формату)
;a=MD001R/M: ?
;a=MD010R/M: not r/m
;a=MD011R/M: neg r/m
;a=MD100R/M: mul ax,r/m
;a=MD101R/M: imul ax,r/m
;a=MD110R/M: div ax,r/m
;a=MD111R/M: idiv ax,r/m
;MD=00: cmd [...]
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
;MD=11: cmd r/m ;проще всего
        cp 0b11000000
        jr c,GRP316mem
       ADDRr16
       and 0b00111000
	jr z,TESTr16i16
	cp 0b00010000
	jp z,NOTr16
	cp 0b00011000
	jp z,NEGr16
	cp 0b00100000
	jp z,MULr16
	cp 0b00101000
	jp z,IMULr16
	cp 0b00110000
	jp z,DIVr16
	cp 0b00111000
	jp z,IDIVr16
	jr $;PANIC
GRP316mem
       ADDRm16
       and 0b00111000
	jr z,TESTm16i16
	cp 0b00010000
	jp z,NOTm16
	cp 0b00011000
	jp z,NEGm16
	cp 0b00100000
	jp z,MULm16
	cp 0b00101000
	jp z,IMULm16
	cp 0b00110000
	jp z,DIVm16
	cp 0b00111000
	jp z,IDIVm16       
	jr $;PANIC

TESTm16i16
        GETm16
        jr TESTrmi16bc
TESTr16i16
        GETr16
TESTrmi16bc
        get
        and c
        ld c,a
        get
        and b
        ld b,a
;The OF and CF flags are set to 0. The SF, ZF, and PF flags are set according to the result (see the "Operation" section above). The state of the AF flag is undefined. 
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _LoopC

TESTrmr8
        cp 0b11000000
        jr c,TESTrmmemr8
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;r8 addr
        ld c,(hl)
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        ld a,(hl)
        and c ;op
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
TESTrmmemr8
       ADDRm16
       or 0b11000000
       ex af,af' ;'
       GETm8
       ld c,a
       ex af,af' ;'
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;r8 addr
       ld a,c
        and (hl) ;op
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC

TESTrmr16
        cp 0b11000000
        jr c,TESTrmmemr16
       push af
        rra
        rra
        and 7*2 ;r16
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop af
        and 7 ;rm
        add a,a
        ld l,a
        ld a,(hl)
        and c
        ld c,a
        inc l
        ld a,(hl)
        and b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _Loop_
TESTrmmemr16
       push af
       ADDRm16
       GETm16
       pop af
        and 7 ;rm
        add a,a
        ld l,a
        ld a,(hl)
        and c
        ld c,a
        inc l
        ld a,(hl)
        and b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _LoopC

GRP416
;FF MOD01fRM disp16 = CALLrm+... /f - межсегментный/, так же можно PUSHrm+..., INCrm+... ;FF 25 = jmp word [di]
;TODO узнать все коды!
	get
	next
	cp 0b00100101
	jp z,JMPWORDmDI
	jp $;PANIC
