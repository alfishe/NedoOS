        macro ADDRr16
;a=r/m byte
        and 7
        add a,a
        ld l,a
        ld h,_AX/256
        endm
        macro GETr16
        ;ld a,c
        ;and 7
        ;add a,a
       ;cp l
       ;jr nz,$
        ;ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
        endm

        macro _PUTr16Loop_
;hl is kept since ADDRr16
        ld a,l
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jr z,3f
       _Loop_
3
        ld h,b
        ld l,c
        encodeSP
       _Loop_
        endm

        macro _PUTr16LoopC
;hl is kept since ADDRr16
        ld a,l
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jr z,3f
       _LoopC
3
        ld h,b
        ld l,c
        encodeSP
       _LoopC
        endm

        macro _PUTm16LoopC
        PUTm16
       _LoopC
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
;a=r/m byte
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
        jp 4f
9 ;0xx
        bit 1,a
        ld bc,(_BX) ;00?=[bx]+[?i]+disp
        jr z,$+6
        ld bc,(_BP) ;00?=[bp]+[?i]+disp
        add hl,bc
8
;MD=00: cmd [...] ;no disp
       cp 64
       jr c,7f ;no disp
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
7
        endm
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
        macro PUTm16
        putmemDS_bc
        endm
        macro PUTm8
        putmemDS ;a
        endm
        macro PUTm8_c
        putmemDS_c
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
        jp c,MOVrm8i8mem
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
        ld h,_AX/256
        and 7
       add a,16
        ld l,a
        ld l,(hl)
        get
        next
        ld (hl),a
       _Loop_
MOVrm8i8mem
       ADDRm16
        get
        next
       PUTm8
       _LoopC

GRP416
;FF MOD01fRM disp16 = CALLrm+... /f - межсегментный/, так же можно PUSHrm+..., INCrm+... ;FF 25 = jmp word [di]
	get
	next
	cp 0b00100101
	jp z,JMPWORDmDI
	jp $;PANIC

GRP1rmi8
;aluop
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
;MD=01: cmd [...+disp8],i8 ;TODO
;MD=10: cmd [...+disp16],i8 ;TODO
;MD=11: cmd r/m,i8 ;проще всего
	cp 0b00111100
	jp z,CMPrmmemi8
	;jp z,CMPmSIBYTE
	jp $;PANIC

CMPrmmemi8
        ADDRm16
       push hl
        GETm8_c
        get
        next
        sub c
        ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
        ;PUTm8_c
       _LoopC

GRP1rmi16
;aluop
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
;MD=01: cmd [...+disp8],i8 ;TODO
;MD=10: cmd [...+disp16],i8 ;TODO
;MD=11: cmd r/m,i8 ;проще всего
        cp 0b11000000
        jr c,GRP1mem
       ld c,a
       ADDRr16
       ld a,c
       and 0b11111000
	cp 0b11111000
	jp z,CMPrmi16
	;jp z,CMPr16i16;CMPspi16
	jp $;PANIC
GRP1mem
       ADDRm16
       and 0b00111000
	cp 0b00111000
	jp z,CMPrmmemi16
	jp $;PANIC

CMPr16i16
        GETr16
	ld h,b
	ld l,c
	getBC
	or a
	sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       _Loop_

CMPrmi16
       push hl
        GETr16
        ld h,b
        ld l,c
        getBC
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
        ;ld b,h
        ;ld c,l
       pop hl
        ;PUTr16
       _LoopC
CMPrmmemi16
        ADDRm16
       push hl
        GETm16
        ld h,b
        ld l,c
        getBC
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
        ;ld b,h
        ;ld c,l
       pop hl
        ;PUTm16
       _LoopC

GRP316
;mul,div,test,not,neg
	get
	next
;a=MD000R/M: test r/m,i16??? (не верится по формату) ;TODO
;a=MD001R/M: ?
;a=MD010R/M: not r/m?
;a=MD011R/M: neg r/m?
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
       ld c,a
       ADDRr16
       ld a,c
       and 0b11111000
	cp 0b11010000
	jp z,NOTr16
	cp 0b11011000
	jp z,NEGr16
	cp 0b11100000
	jp z,MULr16
	cp 0b11101000
	jp z,IMULr16
	cp 0b11110000
	jp z,DIVr16
	cp 0b11111000
	jp z,IDIVr16
	jp $;PANIC
GRP316mem
       ADDRm16
       and 0b00111000
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
	jp $;PANIC

MOVrmr8
	get
	next
;a=MDregR/M
;MD=00: mov [...],r8
;MD=01: mov [...+disp8],r8
;MD=10: mov [...+disp16],r8
;MD=11: mov r/m,r8 ;проще всего
        cp 0b11000000
        jp c,MOVrmr8mem
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ld b,a
        rra
        rra
        rra
        and 7
       add a,16
        ld l,a
        ld h,_AX/256
        ld l,(hl)
        ld c,(hl)
       ld a,b
        and 7
       add a,16
        ld l,a
        ld l,(hl)
        ld (hl),c
       _Loop_
MOVrmr8mem
       ADDRm16
       push hl
        rra
        rra
        rra       
        and 7
       add a,16
        ld l,a
        ld h,_AX/256 ;TODO bc, no push
        ld l,(hl)
        ld a,(hl)
       pop hl
       PUTm8
       _LoopC

MOVrmr16
	get
	next
;a=MDregR/M
;MD=00: mov [...],r16
;MD=01: mov [...+disp8],r16
;MD=10: mov [...+disp16],r16
;MD=11: mov r/m,r16 ;проще всего
        cp 0b11000000
        jr c,MOVrmr16mem
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
MOVrmr16mem
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
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ld b,a
        and 7
       add a,16
        ld l,a
        ld h,_AX/256
        ld l,(hl)
        ld c,(hl)
       ld a,b
        rra
        rra
        rra
        and 7
       add a,16
        ld l,a
        ld l,(hl)
        ld (hl),c
       _Loop_
MOVr8rmmem
       ADDRm16
       push af
       GETm8_c
       pop af
        rra
        rra
        rra       
        and 7
       add a,16
        ld l,a
        ld h,_AX/256
        ld l,(hl)
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

MOVrm16sreg
	jp $;PANIC

ADCrmr8
ADCrmr16
ADCali8
ADCaxi16
SBBrmr8
SBBrmr16
SBBali8
SBBaxi16
	jp $;PANIC

CMPrmr8
XORrmr8
ORrmr8
ANDrmr8
SUBrmr8
ADDrmr8
	get
	next
;a=MDregR/M
;MD=00: cmd [...],r8
;MD=01: cmd [...+disp8],r8
;MD=10: cmd [...+disp16],r8
;MD=11: cmd r/m,r8 ;проще всего
        cp 0b11000000
        jp c,ADDrmr8mem
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ld b,a
        rra
        rra
        rra
        and 7 ;r8
       add a,16
        ld l,a
        ld h,_AX/256
        ld l,(hl)
        ld c,(hl)
       ld a,b
        and 7 ;rm
       add a,16
        ld l,a
        ld l,(hl)
        ld a,c
        add a,(hl) ;op
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
ADDrmr8mem
       ADDRm16
       ex af,af' ;'
       push hl
       GETm8
       ex af,af' ;' ;a = rmbyte
        rra
        rra
        rra       
        and 7 ;r8
       add a,16
        ld l,a
        ld h,_AX/256
        ld l,(hl)
       ex af,af' ;' ;a = [mem]
        add a,(hl) ;op
       ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       PUTm8_c
       _LoopC

XORrmr16
	get
	next
;a=MDregR/M
;MD=00: cmd [...],r16 ;TODO
;MD=01: cmd [...+disp8],r16 ;TODO
;MD=10: cmd [...+disp16],r16 ;TODO
;MD=11: cmd r/m,r16 ;проще всего
	cp %11000000
	jp z,XORaxax
	cp %11001001
	jp z,XORcxcx
	cp %11010010
	jp z,XORdxdx
	cp %11011011
	jp z,XORbxbx
	jp $;PANIC

ORrmr16
	get
	next
;a=MDregR/M
;MD=00: cmd [...],r16 ;TODO
;MD=01: cmd [...+disp8],r16 ;TODO
;MD=10: cmd [...+disp16],r16 ;TODO
;MD=11: cmd r/m,r16 ;проще всего
	cp %11000000
	jp z,ORaxax
	cp %11001001
	jp z,ORcxcx
	cp %11010010
	jp z,ORdxdx
	cp %11011011
	jp z,ORbxbx
	jp $;PANIC

       macro OPrmr16_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd r16,[...]
;MD=01: cmd r16,[...+disp8]
;MD=10: cmd r16,[...+disp16]
;MD=11: cmd r16,r/m ;проще всего
        cp 0b11000000
        jp c,6f;ADDrmr16mem
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
        ;ld a,(hl)
        ;inc l
        ;ld h,(hl)
        ;ld l,a
        ;or a
        ;adc hl,bc ;op
       endm
       macro OPrmr16_POST
        KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
6;ADDrmr16mem
       ADDRm16
       push hl
        ld h,_AX/256
       push af
        rra
        rra
        and 7*2 ;r16
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop hl
       push hl
       GETm16_hl
        ;or a
        ;adc hl,bc ;op
       endm
       macro OPrmr16_POST2
       ld b,h
       ld c,l
       pop hl
       PUTm16
       endm
CMPrmr16
ANDrmr16
SUBrmr16
ADDrmr16
	get
	next
;a=MDregR/M
;MD=00: cmd [...],r16 ;TODO
;MD=01: cmd [...+disp8],r16 ;TODO
;MD=10: cmd [...+disp16],r16 ;TODO
;MD=11: cmd r/m,r16 ;проще всего
	cp %11001111
	jp z,ADDdicx
	cp %11000011
	jp z,ADDbxax
	cp %11001000
	jp z,ADDaxcx
	jp $;PANIC

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
;000... -> 000 ;al
;001... -> 010 ;cl
;010... -> 100 ;dl
;011... -> 110 ;bl
;100... -> 001 ;ah
;101... -> 011 ;ch
;110... -> 101 ;dh
;111... -> 111 ;bh
       ld b,a
        and 7 ;rm
       add a,16
        ld l,a
        ld h,_AX/256
        ld l,(hl)
        ld c,(hl)
       ld a,b
5;ADDr8rmok
        rra
        rra
        rra
        and 7 ;r8
       add a,16
        ld l,a
        ld l,(hl)
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
       pop af
        ld h,_AX/256
       jp 5b;ADDr8rmok
       endm
ADDr8rm
        OPr8rm_PRE
        ld a,(hl)
        add a,c ;op
        ld (hl),a
        OPr8rm_POST
SUBr8rm
        OPr8rm_PRE
        ld a,(hl)
        sub c ;op
        ld (hl),a
        OPr8rm_POST
ADCr8rm
        OPr8rm_PRE
        ex af,af' ;'
        ld a,(hl)
        adc a,c ;op
        ld (hl),a
        OPr8rm_POST
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
        jp c,6f;ADDr16rmmem
       push af
        and 7 ;rm
        add a,a
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
5;ADDr16rmok
       pop af
        rra
        rra
        and 7*2 ;r16
        ld l,a
        ;ld a,(hl)
        ;inc l
        ;ld h,(hl)
        ;ld l,a
        ;or a
        ;adc hl,bc ;op
       endm
       macro OPr16rm_POST
        KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
6;ADDr16rmmem
       ADDRm16
       push af
       GETm16
        ld h,_AX/256
       jp 5b;ADDr16rmok
       endm
       macro LOGICOPr16rm_POST
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _LoopC
6;ADDr16rmmem
       ADDRm16
       push af
       GETm16
        ld h,_AX/256
       jp 5b;ADDr16rmok
       endm
ADDr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        adc hl,bc ;op
       pop bc
        ld a,l
        ld (bc),a
        inc bc ;keep ZF
        ld a,h
        ld (bc),a
        OPr16rm_POST
SUBr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        sbc hl,bc ;op
       pop bc
        ld a,l
        ld (bc),a
        inc bc ;keep ZF
        ld a,h
        ld (bc),a
        OPr16rm_POST
ADCr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        adc hl,bc ;op
       pop bc
        ld a,l
        ld (bc),a
        inc bc ;keep ZF
        ld a,h
        ld (bc),a
        OPr16rm_POST
SBBr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        sbc hl,bc ;op
       pop bc
        ld a,l
        ld (bc),a
        inc bc ;keep ZF
        ld a,h
        ld (bc),a
        OPr16rm_POST
CMPr16rm
        OPr16rm_PRE
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        sbc hl,bc ;op
        OPr16rm_POST
XORr16rm
        OPr16rm_PRE
        ld a,(hl)
        xor c
        ld (hl),a
        ld c,a
        inc l
        ld a,(hl)
        xor b
        ld (hl),a
        ld b,a
        LOGICOPr16rm_POST
ORr16rm
        OPr16rm_PRE
        ld a,(hl)
        or c
        ld (hl),a
        ld c,a
        inc l
        ld a,(hl)
        or b
        ld (hl),a
        ld b,a
        LOGICOPr16rm_POST
ANDr16rm
        OPr16rm_PRE
        ld a,(hl)
        and c
        ld (hl),a
        ld c,a
        inc l
        ld a,(hl)
        and b
        ld (hl),a
        ld b,a
        LOGICOPr16rm_POST
