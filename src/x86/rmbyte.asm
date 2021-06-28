;TODO все ветвления на 8 веток делать по rla:rla:rla:jr nc/c:add a,a:jp p/m:jr nc/c

       macro ADDRr8 ;r/m register
;a=r/m byte (kept)
       ld l,a
       res 6,l
       ld h,_AX/256
       ld l,(hl) ;rm addr
       endm
        macro ADDRr16_keepa ;r/m register
;a=r/m byte
        ld h,a
        and 7
        add a,a
        ld l,a
        ld a,h
        ld h,_AX/256
        endm
        macro ADDRr16_nokeepa ;r/m register
;a=r/m byte
        and 7
        add a,a
        ld l,a
        ld h,_AX/256
        endm

        macro GETr16
        ld c,(hl)
        inc l
        ld b,(hl)
        endm
        macro GETr16_de
        ld e,(hl)
        inc l
        ld d,(hl)
        endm
        macro GETr16_hl
        ld b,(hl)
        inc l
        ld h,(hl)
        ld l,b
        endm

       macro SWAPr16
        ld a,(hl)
        ld (hl),c
        ld c,a
        inc l
        ld a,(hl)
        ld (hl),b
        ld b,a
        ld a,l
        cp 1+(_SP&0xff)
        call z,encodeSP_pp
       endm

        macro _PUTr8Loop_
;hl is kept since ADDRr8
        ld (hl),a
       _Loop_
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

        macro _PUTr16hlLoop_
;(sp)=ADDRr16
;hl=data
        pop bc
        ld a,l
        ld (bc),a
        inc c
        ld a,h
        ld (bc),a
        ld a,c
        cp 1+(_SP&0xff)
        jp z,encodeSPhlLoop ;TODO ret z
       _Loop_
        endm

        macro _PUTr16LoopC
;hl is kept since ADDRr16
;bc=data
        ld a,l
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jp z,encodeSPLoopC ;TODO ret z
       _LoopC
        endm

encodeSP_pp
        ld hl,(_SP)
        encodeSP
        ret

encodeSPLoop
encodeSPLoopC
        ld h,b
        ld l,c
encodeSPhlLoop
        encodeSP
       _Loop_

        macro ADDRSEGMENT_chl_bHSB
;hl=addr
;abc=?s*16
        ADDSEGMENT_hl_abc_to_ahl
	ld c,a
	ld a,h
	or 0xc0
	ld h,a
;c=page (%01..5432)
        endm

        macro GETm16
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld b,(hl)
        ld c,a
        endm

        macro ADDRm16_GETm8b_keepaf ;for MOVr8rmmem, OPr8rmmem, TESTrmmemr8, CMPrmmemr8 (в CMPrmmemi8 GET_PUTm8 и pop af, TODO TESTrmmemi8)
        push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
        pgforGETm8
        ld b,(hl)
        pop af
        endm

        macro ADDRm16_GETm8b_for_PUTm8 ;for OPrmmemi8/r8, ROLm8... ;keep lx=pg!!! ;TODO kill, use getm8c
        push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c ;push bc
        pgforGETm8
         ld c,lx ;pop bc
        ld b,(hl)
        pop af
        endm

        macro ADDRm16_GETm8c_for_PUTm8 ;for OPrmmemi8/r8, ROLm8... ;keep lx=pg!!!
        push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c ;push bc
        pgforGETm8
        ld c,(hl)
        pop af
        endm

        macro ADDRm16_for_PUTm8_nokeepaf ;for MOVrmmemi8, MOVrmmemr8
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ;ld lx,c
        endm

        macro ADDRm16_GETm16 ;for MOVr16rmmem, MOVsregrmmem, CMPrmr16, OPr16rmmem, TESTrmmemr16
        push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ;ld lx,c
         GETm16
        pop af
        endm

        macro ADDRm16_GETm16_keeplx ;for 32bit read
        push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c
         GETm16
        pop af
        endm

        macro ADDRm16_GETm16_keeplx_nokeepaf ;for 32bit read
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c
         GETm16
        endm

        macro ADDRm16_for_PUTm16_nokeepaf ;for MOVrmmemi16
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c
        endm

        macro ADDRm16_for_PUTm16 ;for MOVrmmemr16/sreg
         push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c
         pop af
        endm
;TODO fix! уже прочитано 2 байта из (hl)!

        macro ADDRm16_GETm16_for_PUTm16 ;for OPrmmemi16/r16, ROLm16..., TESTrmmemi16, MULrmmem16...
       push af
        call ADDRm16_pp
        ADDRSEGMENT_chl_bHSB
         ld lx,c
        push hl
        GETm16
        pop hl
       pop af
        endm

ADDRm16_pp_ssbp_plusi ;ss:bp+?i+
       push bc
        ld bc,(_BP)
        add hl,bc
       pop bc
ADDRm16_pp_ssbp ;ss:bp+ ;не бывает nodisp, отсеяно выше
       ld c,a
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
	get ;dispL
	next
        add a,l
        ld l,a
        jr nc,$+3
        inc h
       bit 7,c
       jr z,ADDRm16_pp_ss_nodisp
	get ;dispH
	next
        add a,h
        ld h,a
ADDRm16_pp_ss_nodisp
        bit 0,b
        jr nz,ADDRm16_pp_segprefix
	ld bc,(ss_LSW)
	ld a,(ss_HSB)
        ;ADDRSEGMENT_chl_bHSB
        ret

;000=[bx]+[si]+disp
;001=[bx]+[di]+disp
;010=[bp]+[si]+disp
;011=[bp]+[di]+disp
;100=[si]+disp
;101=[di]+disp
;110=[bp]+disp ;за исключением случая mod=00 и rm=110, когда EA равен старшему и младшему байтам смещения
;111=[bx]+disp
;a=r/m byte
;b=?s_LSW+1 (если нечётный, а иначе сегмент по умолчанию)
;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
ADDRm16_pp
        bit 2,a
        jr z,ADDRm16_pp_sum ;ds:b?+?i+
;1xx
        bit 1,a
        jr z,ADDRm16_pp_i ;ds:?i+
;11x
        bit 0,a
        ld hl,(_BX)
        jr nz,ADDRm16_pp_ds ;ds:??+
        ld hl,(_BP)
       cp 64
       jr nc,ADDRm16_pp_ssbp ;ss:bp+
;[bp+nodisp] = [disp]
       getHL
        bit 0,b
        jr z,addrseg_ds
ADDRm16_pp_segprefix
        push hl
        ld h,es_LSW/256
        ld l,b
        ld b,(hl)
        dec l
        ld c,(hl)
        ;set 3,l
        res 4,l
        ld a,(hl)
        pop hl ;abc=?s*16
        ;ADDRSEGMENT_chl_bHSB
        ret
ADDRm16_pp_i ;10x
        bit 0,a
        ld hl,(_SI)
        jr z,ADDRm16_pp_ds
        ld hl,(_DI)
        jp ADDRm16_pp_ds
ADDRm16_pp_sum ;0xx
        bit 0,a
        ld hl,(_SI)
        jr z,$+5
        ld hl,(_DI)
        bit 1,a
        jp nz,ADDRm16_pp_ssbp_plusi;01?=[bp]+[?i]+disp
       push bc
        ld bc,(_BX) ;00?=[bx]+[?i]+disp
        add hl,bc
       pop bc
ADDRm16_pp_ds ;ds:??+
;MD=00: cmd [...] ;no disp
       cp 64
       jr c,ADDRm16_pp_ds_nodisp
       ld c,a
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
	get ;dispL
	next
        add a,l
        ld l,a
        jr nc,$+3
        inc h
       bit 7,c
       jr z,ADDRm16_pp_ds_nodisp
	get ;dispH
	next
        add a,h
        ld h,a
ADDRm16_pp_ds_nodisp
;вызывается из MOVaxmem
;out: данные для вычисления hl=zxaddr, c=page (%01..5432), b=?s_HSB
        bit 0,b
        jr nz,ADDRm16_pp_segprefix
addrseg_ds
	ld bc,(ds_LSW)
	ld a,(ds_HSB)
        ;ADDRSEGMENT_chl_bHSB
        ret

inch_nextsubsegment_pglx
;lx=page (%01..5432) ;keep updated for GET..PUT back
;keep a
;hl=0xXX00 ;keep updated
        inc h
        ret nz
       push af
        ld a,lx
        add a,64
        adc a,0
        ld lx,a
        ld c,a ;c=page (%01..5432)
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld h,0xc0
       pop af
        ret

inch_nextsubsegment
;c=page (%01..5432)[, b=?s_HSB] ;keep updated for GET..PUT back
;keep a
;hl=0xXX00 ;keep updated
        inc h
        ret nz
       push af
        ld a,c ;c=page (%01..5432)
        add a,64
        adc a,0
        ld c,a
       ;dec a
       ;cp b ;b=?s_HSB
       ;jr nz,$+3
       ;dec c ;если читать слово из [?s:ffff], то второй байт читается из [?s:0000], но на 386 не так
       push bc
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld h,0xc0
       pop bc
       pop af
        ret

        macro pgforGETm8
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        endm

        macro skip2b_GETm16
       ld c,lx
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        inc l
        call z,inch_nextsubsegment_pglx
        inc l
        call z,inch_nextsubsegment_pglx
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment_pglx
	ld b,(hl)
        ld c,a
        endm

        macro _PUTm8bLoopC
;hl=addr
;b=data
;c=page (%01..5432)
       push bc
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc
	ld (hl),b
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC
        endm

        macro _PUTm8bLoopC_oldpgc
;hl=addr
;b=data
;c=page (%01..5432)
	ld (hl),b
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC
        endm

        macro _PUTm8cLoopC_oldpglx
;hl=addr
;c=data
;lx=page (%01..5432)
	ld (hl),c
        ld c,lx
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC
        endm

        macro _PUTm16LoopC_oldpglx
;hl=addr
;bc=data
;lx=pg
	ld (hl),c ;TODO записать в память второй байт заранее (а сложная ветка только при hl=0xffff)
        push bc;ld a,b
         ld c,lx
       _PUTscreen_logpgc_zxaddrhl_datamhl_keephlpg ;TODO по умолчанию без keeppg и сразу 2 байта
        inc l
        call z,inch_nextsubsegment_pglx
        pop af
	ld (hl),a
         ld c,lx
       _PUTscreen_logpgc_zxaddrhl_datamhl ;TODO убрать там повторный ld c,lx:ld b,.../256
       _LoopC
        endm

        macro _PUTm16LoopC
;hl=addr
;bc=data
;lx=pg
       push bc ;bc=data
         ld c,lx
         ld b,tpgs/256
         ld a,(bc)
	SETPGC000
       pop bc ;bc=data
       _PUTm16LoopC_oldpglx
        endm

        macro _PUTm16hlLoopC ;(instead of ld b,h:ld c,l:pop hl:_PUTm16LoopC)
;(sp)=addr
;hl=data
;lx=pg
       ex (sp),hl ;hl=addr, (sp)=data
         ld c,lx
         ld b,tpgs/256
         ld a,(bc)
	SETPGC000
       pop bc ;bc=data
       _PUTm16LoopC_oldpglx
        endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginmovs

        ALIGNrm
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
       sub 64
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;rm addr
        get
        next
        ld (hl),a
       _Loop_
MOVrmmemi8
       ADDRm16_for_PUTm8_nokeepaf
        get
        next
        ld b,a
       _PUTm8bLoopC

        ALIGNrm
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
        ADDRr16_nokeepa ;rm addr
        getBC
       _PUTr16Loop_
MOVrmmemi16
       ADDRm16_for_PUTm16_nokeepaf
        getBC
       _PUTm16LoopC

        ALIGNrm
MOVrmr8
	get
	next
;a=MDregR/M
;MD=00: mov [...],reg8
;MD=01: mov [...+disp8],reg8
;MD=10: mov [...+disp16],reg8
;MD=11: mov r/m,reg8 ;проще всего
        cp 0b11000000
        jp c,MOVrmmemr8
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld c,(hl)
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        ld (hl),c
       _Loop_
MOVrmmemr8
       push af
       ADDRm16_for_PUTm8_nokeepaf
       pop af
       push hl
        or 0b11000000
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld b,(hl)
       pop hl
       _PUTm8bLoopC

        ALIGNrm
MOVrmr16
	get
	next
;a=MDregR/M
;MD=00: mov [...],reg16
;MD=01: mov [...+disp8],reg16
;MD=10: mov [...+disp16],reg16
;MD=11: mov r/m,reg16 ;проще всего
        cp 0b11000000
        jr c,MOVrmmemr16
       ld h,a
        rra
        rra
        and 7*2
        ld l,a
       ld a,h
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl) ;reg16
       and 7
       add a,a
        ld l,a ;rm addr
       _PUTr16Loop_
MOVrmmemr16
       ADDRm16_for_PUTm16
       push hl
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl) ;reg16
       pop hl
       _PUTm16LoopC

        ALIGNrm
MOVr8rm
	get
	next
;a=MDregR/M
;MD=00: mov reg8,[...]
;MD=01: mov reg8,[...+disp8]
;MD=10: mov reg8,[...+disp16]
;MD=11: mov reg8,r/m ;проще всего
        cp 0b11000000
        jp c,MOVr8rmmem
        ADDRr8 ;rm addr
        ld c,(hl)
       ld l,a
        ld l,(hl) ;reg8 addr
        ld (hl),c
       _Loop_
MOVr8rmmem
       ADDRm16_GETm8b_keepaf
       or 0b11000000
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld (hl),b
       _LoopC

        ALIGNrm
MOVr16rm
	get
	next
;a=MDregR/M
;MD=00: mov reg16,[...]
;MD=01: mov reg16,[...+disp8]
;MD=10: mov reg16,[...+disp16]
;MD=11: mov reg16,r/m ;проще всего
        cp 0b11000000
        jr c,MOVr16rmmem
        ADDRr16_keepa
        ld c,(hl)
        inc l
        ld b,(hl) ;rm
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
       _PUTr16Loop_
MOVr16rmmem
       ADDRm16_GETm16 ;bc=rmmem
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
        ld h,_AX/256
       _PUTr16LoopC ;TODO без ld a,l

        ALIGNrm
MOVsregrm16
	get
	next
;a=MDregR/M
;MD=00: mov sreg,[...]
;MD=01: mov sreg,[...+disp8]
;MD=10: mov sreg,[...+disp16]
;MD=11: mov sreg,r/m ;проще всего
        cp 0b11000000
        jr c,MOVsregrmmem
        ADDRr16_keepa
        ld c,(hl)
        inc l
        ld b,(hl) ;rm
        jr MOVsregrmq
MOVsregrmmem
       ADDRm16_GETm16 ;bc=rmmem
        ld h,_AX/256
MOVsregrmq
        rra
        rra
        and 7*2
        add a,_ES&0xff
        ld l,a
        ld (hl),c
        inc l
        ld (hl),b
;count?S
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
        set 5,l ;0x11 -> 0x31
        ld (hl),b
        dec l
        ld (hl),c
        ;set 3,l
        res 4,l
	ld (hl),a
       _LoopC

        ALIGNrm
MOVrm16sreg
	get
	next
;a=MDregR/M
;MD=00: mov [...],sreg16
;MD=01: mov [...+disp8],sreg16
;MD=10: mov [...+disp16],sreg16
;MD=11: mov r/m,sreg16 ;проще всего
        cp 0b11000000
        jr c,MOVrmmemsreg
       ld h,a
        rra
        rra
        and 7*2
        add a,_ES&0xff
        ld l,a ;sreg16 addr
       ld a,h
        ld h,_ES/256
        ld c,(hl)
        inc l
        ld b,(hl)
       and 7
       add a,a
        ld l,a ;rm addr
       _PUTr16Loop_
MOVrmmemsreg
       ADDRm16_for_PUTm16
       push hl
        rra
        rra
        and 7*2
        add a,_ES&0xff ;единственное отличие от MOVrmmemr16
        ld l,a ;sreg16 addr
        ld h,_ES/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop hl
       _PUTm16LoopC

       display "movs size=",$-beginmovs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginalus

        ALIGNrm
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
        cp 0b11000000
        jr c,GRP1rmmemi8
       ADDRr8
       rla
       rla
       rla
       jr c,GRP1rmi8_1xx
       add a,a
       jp p,GRP1rmi8_ADD_ADC
       jr c,SBBrmi8
        get
        or (hl)
        jr GRP1rmi8logicstoreq
SBBrmi8
        ex af,af' ;' ;old CF for sbb
        get
SUBrmi8
        ld c,a
        ld a,(hl)
        sbc a,c
        jr GRP1rmi8storeq
GRP1rmi8_ADD_ADC
       jr nc,ADDrmi8 ;CF=0 for add
        ex af,af' ;' ;old CF for adc
ADDrmi8
        get
        adc a,(hl)
GRP1rmi8storeq
        ld (hl),a
GRP1rmi8q
        KEEPHFCFPARITYOVERFLOW_FROMA
        next ;doesn't keep SF
       _LoopC      
GRP1rmi8_1xx
       add a,a
        get
       jp p,GRP1rmi8_AND_XOR       
       jr nc,SUBrmi8 ;CF=0 for sub
;CMPrmi8
        ld c,a
        ld a,(hl)
        sub c
        jr GRP1rmi8q        
GRP1rmi8_AND_XOR
        jr c,XORrmi8
        and (hl)
GRP1rmi8logicstoreq
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
        next ;doesn't keep SF
       _LoopC
XORrmi8
        xor (hl)
        jr GRP1rmi8logicstoreq
GRP1rmmemi8
       ADDRm16_GETm8c_for_PUTm8
       rla
       rla
       rla
       jr c,GRP1rmmemi8_1xx
       add a,a
       jp p,GRP1rmmemi8_ADD_ADC
       jr c,SBBrmmemi8
        get
        or c
        jr GRP1rmmemi8logicstoreq
SBBrmmemi8
        ex af,af' ;' ;old CF for sbb
        get
SUBrmmemi8
        ld b,a
        ld a,c ;rmmem
        sbc a,b
        jr GRP1rmmemi8storeq
GRP1rmmemi8_ADD_ADC
       jr nc,ADDrmmemi8 ;CF=0 for add
        ex af,af' ;' ;old CF for adc
ADDrmmemi8
        get
        adc a,c
GRP1rmmemi8storeq
        ld c,a
        KEEPHFCFPARITYOVERFLOW_FROMA
        next ;doesn't keep SF
       _PUTm8cLoopC_oldpglx
GRP1rmmemi8_1xx
       add a,a
        get
       jp p,GRP1rmmemi8_AND_XOR       
       jr nc,SUBrmmemi8 ;CF=0 for sub
;CMPrmmemi8
        ld b,a
        ld a,c
        sub b
        KEEPHFCFPARITYOVERFLOW_FROMA
        next ;doesn't keep SF
       _LoopC
GRP1rmmemi8_AND_XOR
        jr c,XORrmmemi8
        and c
GRP1rmmemi8logicstoreq
        ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
        next ;doesn't keep SF
       _PUTm8cLoopC_oldpglx
XORrmmemi8
        xor c
        jr GRP1rmmemi8logicstoreq

GRP1rmi16_ADD_ADC
       jr nc,ADDr16i16 ;CF=0 for add
        ex af,af' ;' ;old CF for adc
ADDr16i16
        get
        next
        ld c,a
        get
        ld b,a
ADCr16bc
        ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
GRP1rmi16q
        next
       _PUTr16hlLoop_
        ALIGNrm
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
        cp 0b11000000
        jp c,GRP1rmmemi16
       ADDRr16_keepa
       push hl
        GETr16_hl
       rla
       rla
       rla
       jr c,GRP1rmi16_1xx
       add a,a
       jp p,GRP1rmi16_ADD_ADC
       jr c,SBBr16i16
;ORr16i16
        get
        next
        or l
        ld l,a
        get
        or h
        jr GRP1rmi16logicq        
SBBr16i16
        ex af,af' ;' ;old CF for sbb
        get
SUBr16i16
        next
        ld c,a
        get
        ld b,a
SBCr16bc
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        jr GRP1rmi16q
GRP1rmi16_1xx
       add a,a
        get
       jp p,GRP1rmi16_AND_XOR
       jr nc,SUBr16i16 ;CF=0 for sub
CMPr16i16
        next
        ld c,a
        get
CMPr16hlac
        ld b,a
	or a
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
       pop hl ;skip
        next
       _Loop_
GRP1rmi16_AND_XOR
        next
        jr c,XORr16i16
;ANDr16i16
        and l
        ld l,a
        get
        and h
GRP1rmi16logicq
        ld h,a
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
        next
       _PUTr16hlLoop_
XORr16i16
        xor l
        ld l,a
        get
        xor h
        jr GRP1rmi16logicq
GRP1rmmemi16_ADD_ADC
       jr nc,ADDrmmemi16 ;CF=0 for add
        ex af,af' ;' ;old CF for adc
ADDrmmemi16
        get
        next
        ld c,a
        get
        ld b,a
ADCrmmem16bc
        ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
GRP1rmmemi16q
        next
       _PUTm16hlLoopC
GRP1rmmemi16
        ADDRm16_GETm16_for_PUTm16
       push hl
        ld h,b
        ld l,c
       rla
       rla
       rla
       jr c,GRP1rmmemi16_1xx
       add a,a
       jp p,GRP1rmmemi16_ADD_ADC
       jr c,SBBrmmemi16
;ORrmmemi16
        get
        next
        or l
        ld l,a
        get
        or h
        jr GRP1rmmemi16logicq
SBBrmmemi16
        ex af,af' ;' ;old CF for sbb
        get
SUBrmmemi16
        next
        ld c,a
        get
        ld b,a
SBBrmmem16bc
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        jp GRP1rmmemi16q        
GRP1rmmemi16_1xx
       add a,a
        get
       jp p,GRP1rmmemi16_AND_XOR
       jr nc,SUBrmmemi16
        jp CMPr16i16
GRP1rmmemi16_AND_XOR
        next
       jr c,XORrmmemi16
;ANDrmmemi16
        and l
        ld l,a
        get
        and h
GRP1rmmemi16logicq
        ld h,a
        KEEPLOGICCFPARITYOVERFLOW_FROMHL_AisH
        next
       _PUTm16hlLoopC
XORrmmemi16
        xor l
        ld l,a
        get
        xor h
        jr GRP1rmmemi16logicq

        ALIGNrm
GRP1rm16i8 ;операнд расширяется со знаком (проверено)
	get
	next
;a=MD000R/M: add r/m,i8
;a=MD010R/M: adc r/m,i8
;a=MD011R/M: sbb r/m,i8
;a=MD101R/M: sub r/m,i8
;a=MD111R/M: cmp r/m,i8
        cp 0b11000000
        jr c,GRP1rmmem16i8
       ADDRr16_keepa
       push hl
        GETr16_hl
       rla
       rla
       rla
       jr c,GRP1rm16i8_1xx
       add a,a
       jp p,GRP1rm16i8_ADD_ADC
       jr nc,$ ;no OR
       ;jr c,SBBr16i8
        ex af,af' ;'
SUBr16i8
        ex af,af' ;'
SBBr16i8
        get
        ld c,a
        rla
        sbc a,a
        ld b,a
        ex af,af' ;'
        jp SBCr16bc ;там next
GRP1rm16i8_ADD_ADC
       jr c,ADCr16i8
;ADDr16i8
        ex af,af' ;'
ADCr16i8
        get
        ld c,a
        rla
        sbc a,a
        ld b,a
        ex af,af' ;'
        jp ADCr16bc ;там next
GRP1rm16i8_1xx
       add a,a
       ;jp p,$ ;no AND,XOR??? used in para512!
       jp p,GRP1rm16i8_AND_XOR
       jr nc,SUBr16i8
CMPr16i8
        get
        ld c,a
        rla
        sbc a,a
        jp CMPr16hlac ;там next
GRP1rm16i8_AND_XOR
       jr c,XORr16i8
        get
        ld c,a
        and l
        ld l,a
        ld a,c
        rla
        sbc a,a
        and h
        jp GRP1rmi16logicq ;al=result ;там next
XORr16i8
        get
        ld c,a
        xor l
        ld l,a
        ld a,c
        rla
        sbc a,a
        xor h
        jp GRP1rmi16logicq ;al=result ;там next

GRP1rmmem16i8
        ADDRm16_GETm16_for_PUTm16
       push hl
        ld h,b
        ld l,c
       rla
       rla
       rla
       jr c,GRP1rmmem16i8_1xx
       add a,a
       jp p,GRP1rmmem16i8_ADD_ADC
       ;jr c,SBBrmmem16i8
       jr nc,$ ;no OR
        ex af,af' ;'
SUBrmmem16i8
        ex af,af' ;'
SBBrmmem16i8
        get
        ld c,a
        rla
        sbc a,a
        ld b,a
        ex af,af' ;'
        jp SBBrmmem16bc ;там next
GRP1rmmem16i8_ADD_ADC
       jr c,ADCrmmem16i8
;ADDrmmem16i8
        ex af,af' ;'
ADCrmmem16i8
        get
        ld c,a
        rla
        sbc a,a
        ld b,a
        ex af,af' ;'
        jp ADCrmmem16bc ;там next
GRP1rmmem16i8_1xx
       add a,a
       jp p,$ ;no AND,XOR
       jr nc,SUBrmmem16i8
        jr CMPr16i8

;--------------- alu single calls
       macro OPrmr8_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd [...],reg8
;MD=01: cmd [...+disp8],reg8
;MD=10: cmd [...+disp16],reg8
;MD=11: cmd r/m,reg8 ;проще всего
        cp 0b11000000
        jp c,6f;OPrmmemr8
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld b,(hl)
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        ;op (hl),b
       endm
       macro OPrmr8_POST
6;OPrmmemr8
       ADDRm16_GETm8b_for_PUTm8
        or 0b11000000
        ;ld l,a
        ;ld h,_AX/256
        ;ld l,(hl) ;reg8 addr
        ;op b,(hl)
       endm

        ALIGNrm
ADDrmr8
        or a
        ex af,af' ;'
        ALIGNrm
ADCrmr8
        OPrmr8_PRE
        ex af,af' ;'
        ld a,(hl)
        adc a,b ;op
        ld (hl),a
        KEEPHFCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
       push hl
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ex af,af' ;'
        ld a,b
        adc a,(hl) ;op
        ld b,a
        KEEPHFCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8bLoopC

        ALIGNrm
SUBrmr8
        or a
        ex af,af' ;'
        ALIGNrm
SBBrmr8
        OPrmr8_PRE
        ex af,af' ;'
        ld a,(hl)
        sbc a,b ;op
        ld (hl),a
        KEEPHFCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
       push hl
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ex af,af' ;'
        ld a,b
        sbc a,(hl) ;op
        ld b,a
        KEEPHFCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8bLoopC

        ALIGNrm
CMPrmr8
        OPrmr8_PRE
        ld a,(hl)
        sub b ;op
        KEEPHFCFPARITYOVERFLOW_FROMA
       _Loop_
6;CMPrmmemr8
       ADDRm16_GETm8b_keepaf
       or 0b11000000
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
       ld a,b
        sub (hl) ;op
        KEEPHFCFPARITYOVERFLOW_FROMA
       _LoopC

        ALIGNrm
XORrmr8
        OPrmr8_PRE
        ld a,b
        xor (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
       push hl
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld a,b
        xor (hl) ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8bLoopC

        ALIGNrm
ORrmr8
        OPrmr8_PRE
        ld a,b
        or (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
       push hl
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld a,b
        or (hl) ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8bLoopC

        ALIGNrm
ANDrmr8
        OPrmr8_PRE
        ld a,b
        and (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
       push hl
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld a,b
        and (hl) ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8bLoopC

       macro OPrmr16_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd reg16,[...]
;MD=01: cmd reg16,[...+disp8]
;MD=10: cmd reg16,[...+disp16]
;MD=11: cmd reg16,r/m ;проще всего
        cp 0b11000000
        jp c,6f;OPrmmemr16
       ld h,a
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
       ld a,h
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl) ;reg16
        and 7
        add a,a
        ld l,a ;rm addr
       ;push hl
        ;ld hl,(hl)
        ;or a
        ;adc hl,bc ;op
       endm
       macro OPrmr16_POST
6;OPrmmemr16
        ADDRm16_GETm16_for_PUTm16
      push hl
        ld h,_AX/256
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
        ;ld hl,(hl)
        ;or a
        ;adc hl,bc ;op
       endm
       macro SUBrmr16_POST
6;SUBrmmemr16
        ADDRm16_GETm16_for_PUTm16
      push hl
        ld h,_AX/256
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
       push bc
        ld c,(hl)
        inc l
        ld b,(hl) ;reg16
       pop hl
        ex af,af' ;'
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
      _PUTm16hlLoopC
       endm
       macro CMPrmr16_POST
6;CMPrmmemr16
       ADDRm16_GETm16 ;bc=rmmem
        ld h,_AX/256
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
       push bc
        ld c,(hl)
        inc l
        ld b,(hl) ;reg16
       pop hl ;rmmem
        or a
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
       endm

        ALIGNrm
ADDrmr16
        or a
        ex af,af' ;'
        ALIGNrm
ADCrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
      _PUTm16hlLoopC

        ALIGNrm
SUBrmr16
        or a
        ex af,af' ;'
        ALIGNrm
SBBrmr16
        OPrmr16_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
        SUBrmr16_POST

        ALIGNrm
CMPrmr16
        OPrmr16_PRE
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
        CMPrmr16_POST

        ALIGNrm
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
        ld a,(hl)
        xor c
        ld c,a
        inc l
        ld a,(hl)
        xor b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
      pop hl
      _PUTm16LoopC

        ALIGNrm
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
        ld a,(hl)
        or c
        ld c,a
        inc l
        ld a,(hl)
        or b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
      pop hl
      _PUTm16LoopC

        ALIGNrm
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
        ld a,(hl)
        and c
        ld c,a
        inc l
        ld a,(hl)
        and b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
      pop hl
      _PUTm16LoopC

       macro OPr8rm_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd reg8,[...]
;MD=01: cmd reg8,[...+disp8]
;MD=10: cmd reg8,[...+disp16]
;MD=11: cmd reg8,r/m ;проще всего
        cp 0b11000000
        jp c,6f;ADDr8rmmem
        ADDRr8 ;rm addr
        ld b,(hl)
5;OPr8rmok
        ld l,a
        ld l,(hl) ;reg8 addr
        ;op (hl),b
       endm
       macro OPr8rm_POST
6;OPr8rmmem
       ADDRm16_GETm8b_keepaf
       or 0b11000000
        ld h,_AX/256
       jp 5b;OPr8rmok
       endm

        ALIGNrm
ADDr8rm
        or a
        ex af,af' ;'
        ALIGNrm
ADCr8rm
        OPr8rm_PRE
        ex af,af' ;'
        ld a,(hl)
        adc a,b ;op
        ld (hl),a
        KEEPHFCFPARITYOVERFLOW_FROMA
       _LoopC
        OPr8rm_POST

        ALIGNrm
SUBr8rm
        or a
        ex af,af' ;'
        ALIGNrm
SBBr8rm
        OPr8rm_PRE
        ex af,af' ;'
        ld a,(hl)
        sbc a,b ;op
        ld (hl),a
        KEEPHFCFPARITYOVERFLOW_FROMA
       _LoopC
        OPr8rm_POST

        ALIGNrm
CMPr8rm
        OPr8rm_PRE
        ld a,(hl)
        sub b ;op
        KEEPHFCFPARITYOVERFLOW_FROMA
       _LoopC
        OPr8rm_POST

        ALIGNrm
XORr8rm
        OPr8rm_PRE
        ld a,(hl)
        xor b ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
        OPr8rm_POST

        ALIGNrm
ORr8rm
        OPr8rm_PRE
        ld a,(hl)
        or b ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
        OPr8rm_POST

        ALIGNrm
ANDr8rm
        OPr8rm_PRE
        ld a,(hl)
        and b ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
        OPr8rm_POST

       macro OPr16rm_PRE
	get
	next
;a=MDregR/M
;MD=00: cmd reg16,[...]
;MD=01: cmd reg16,[...+disp8]
;MD=10: cmd reg16,[...+disp16]
;MD=11: cmd reg16,r/m ;проще всего
        cp 0b11000000
        jp c,6f;OPr16rmmem
        ADDRr16_keepa ;rm addr
        ld c,(hl)
        inc l
        ld b,(hl) ;rm
5;OPr16rmok
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
       ;push hl
        ;ld hl,(hl)
        ;op hl,bc
       endm
       macro OPr16rm_POST
6;OPr16rmmem
       ADDRm16_GETm16 ;bc=rmmem
        ld h,_AX/256
       jp 5b;OPr16rmok
       endm
       macro CMPr16rmPOST
6;CMPr16rmmem
       ADDRm16_GETm16 ;bc=rmmem
        ld h,_AX/256
       jp 5b;OPr16rmok
       endm
       macro LOGICOPr16rm_POST
6;OPr16rmmem
       ADDRm16_GETm16 ;bc=rmmem
        ld h,_AX/256
       jp 5b;OPr16rmok
       endm

        ALIGNrm
ADDr16rm
        or a
        ex af,af' ;'
        ALIGNrm
ADCr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        ADCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16LoopC
        OPr16rm_POST

        ALIGNrm
SUBr16rm
        or a
        ex af,af' ;'
        ALIGNrm
SBBr16rm
        OPr16rm_PRE
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        ex af,af' ;'
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16LoopC
        OPr16rm_POST

        ALIGNrm
CMPr16rm
        OPr16rm_PRE
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        or a
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC
       CMPr16rmPOST

        ALIGNrm
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
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _PUTr16LoopC
        LOGICOPr16rm_POST

        ALIGNrm
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
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _PUTr16LoopC
        LOGICOPr16rm_POST

        ALIGNrm
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
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _PUTr16LoopC
        LOGICOPr16rm_POST

       display "alus size=",$-beginalus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginrolls

        ALIGNrm
GRP2rm8i8
        get
        next
;a=MD000R/M: rol r/m
;a=MD001R/M: ror r/m
;a=MD010R/M: rcl r/m
;a=MD011R/M: rcr r/m
;a=MD100R/M: shl r/m
;a=MD101R/M: shr r/m
;a=MD110R/M: ??? r/m
;a=MD111R/M: sar r/m
        cp 0b11000000
        jr c,GRP2rmmem8i8
       ADDRr8 ;rm addr
       push af ;TODO optimize
        get
        next
        ld b,a ;TODO mask
       pop af
       ld c,(hl)
       rla
       rla
       rla
       jr c,GRP2rm8i8_1xx
       add a,a
       jp p,GRP2rm8i8_ROL_RCL ;0x0
       jr c,RCRr8i8
        call RORci8
        ld (hl),c
       _Loop_
RCRr8i8
        call RCRci8
        ld (hl),c
       _Loop_        
GRP2rm8i8_ROL_RCL
       jr c,RCLr8i8
        call ROLci8
        ld (hl),c
       _Loop_
RCLr8i8
        call RCLci8
        ld (hl),c
       _Loop_
GRP2rm8i8_1xx
       add a,a
       jp p,SHLr8i8
       jr c,SARr8i8
        call SHRci8
        ld (hl),c
       _Loop_
SARr8i8
        call SARci8
GRP2r8i8q
        ld (hl),c
       _Loop_
SHLr8i8
        call SHRci8
        ld (hl),c
       _Loop_
GRP2rmmem8i8
       ADDRm16_GETm8c_for_PUTm8 ;делает ld lx,c
       push af ;TODO optimize
        get
        next
        ld b,a ;TODO mask
       pop af
       rla
       rla
       rla
       jr c,GRP2rmmem8i8_1xx
       add a,a
       jp p,GRP2rmmem8i8_ROL_RCL ;0x0
       jr c,RCRm8i8
        call RORci8
        jr GRP2rmmem8i8q
RCRm8i8
        call RCRci8
        jr GRP2rmmem8i8q
GRP2rmmem8i8_ROL_RCL
       jr c,RCLm8i8
        call ROLci8
        jr GRP2rmmem8i8q
RCLm8i8
        call RCLci8
        jr GRP2rmmem8i8q
GRP2rmmem8i8_1xx
       add a,a
       jp p,SHLm8i8
       jr c,SARm8i8
        call SHRci8
GRP2rmmem8i8q
       _PUTm8cLoopC_oldpglx
SARm8i8
        call SARci8
        jr GRP2rmmem8i8q
SHLm8i8
        call SHLci8
        jr GRP2rmmem8i8q

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLci8
ROL_c_b
        ex af,af' ;' ;remember ZF
        ld a,c
ROLci8loop
        rlca
        djnz ROLci8loop
        ld c,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
        ret
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORci8
ROR_c_b
        ex af,af' ;' ;remember ZF
        ld a,c
RORci8loop
        rrca
        djnz RORci8loop
        ld c,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
        ret
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLci8
RCL_c_b
        ex af,af' ;' ;remember ZF,CF
        ld a,c
RCLci8loop
        rla
        djnz RCLci8loop
        ld c,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
        ret
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRci8
RCR_c_b
        ex af,af' ;' ;remember ZF,CF
        ld a,c
RCRci8loop
        rra
        djnz RCRci8loop
        ld c,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
        ret
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLci8
SHL_c_b
        ld a,c
SHLr8i8loop
        add a,a
        djnz SHLr8i8loop
        ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
        ret
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRci8
SHR_c_b
SHRr8i8loop
        srl c
        djnz SHRr8i8loop
        ld a,c
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
        ret
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARci8
SAR_c_b
SARr8i8loop
        sra c
        djnz SARr8i8loop
        ld a,c
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
        ret

        ALIGNrm
GRP2rm81
        get
        next
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
       ADDRr8 ;rm addr
       rla
       rla
       rla
       jr c,GRP2rm81_1xx
       add a,a
       jp p,GRP2rm81_ROL_RCL ;0x0
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
       jr c,RCRr8
;RORr8
        ex af,af' ;' ;remember ZF
        ld a,(hl)
        rrca
        ld (hl),a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _Loop_
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
GRP2rm81_ROL_RCL
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
       jr c,RCLr8
;ROLr8
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
	ex af,af' ;'
       _Loop_
GRP2rm81_1xx
       add a,a
       jp p,SHLr8
       jr c,SARr8
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
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
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLr8
        ld a,(hl)
        add a,a
        jp keephlflagsfroma_loop
        ;ld (hl),a
        ;KEEPCFPARITYOVERFLOW_FROMA
       ;_Loop_
GRP2rmmem81
       ADDRm16_GETm8b_for_PUTm8
       rla
       rla
       rla
       jr c,GRP2rmmem81_1xx
       add a,a
       jp p,GRP2rmmem81_ROL_RCL ;0x0
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
       jr c,RCRm8
;RORm8
        ex af,af' ;' ;remember ZF
        ld a,b
        rrca
       ld b,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _PUTm8bLoopC_oldpgc
RCRm8
        ex af,af' ;' ;remember ZF,CF
        ld a,b
        rra
       ld b,a
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _PUTm8bLoopC_oldpgc
GRP2rmmem81_ROL_RCL
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
       jr c,RCLm8
;ROLm8
        ex af,af' ;' ;remember ZF
        ld a,b
        rlca
       ld b,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
       _PUTm8bLoopC_oldpgc
RCLm8
        ex af,af' ;' ;remember ZF,CF
        ld a,b
        rla
       ld b,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
       _PUTm8bLoopC_oldpgc
GRP2rmmem81_1xx
       add a,a
       jp p,SHLm8
       jr c,SARm8
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
        srl b
        ld a,b
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _PUTm8bLoopC_oldpgc
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARm8
        sra b
        ld a,b
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       _PUTm8bLoopC_oldpgc
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLm8
        ld a,b
        add a,a
        ld b,a
        KEEPCFPARITYOVERFLOW_FROMA
       _PUTm8bLoopC_oldpgc

        ALIGNrm
GRP2rm161
        get
        next
;a=MD000R/M: rol r/m
;a=MD001R/M: ror r/m
;a=MD010R/M: rcl r/m
;a=MD011R/M: rcr r/m
;a=MD100R/M: shl r/m
;a=MD101R/M: shr r/m
;a=MD110R/M: ??? r/m <-- shl
;a=MD111R/M: sar r/m
        cp 0b11000000
        jp c,GRP2rmmem161
       ADDRr16_keepa
       rla
       rla
       rla
       jr c,GRP2rm161_1xx
       add a,a
       jp p,GRP2rm161_ROL_RCL ;0x0
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
       jr c,RCRr16
;RORr16
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
        jr _ROLr16q
RCRr16
        ex af,af' ;' ;remember ZF,CF
        inc hl ;keep ZF
        ld a,(hl)
        rra
        ld b,a
        exx
	ld e,a ;overflow data
        exx
        dec hl ;keep ZF
        ld a,(hl)
        rra
        ld c,a
        jr _ROLr16q
GRP2rm161_ROL_RCL
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
       jr c,RCLr16
;ROLr16
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
        jr RCLr16_go
RCLr16
        ex af,af' ;' ;remember ZF,CF
        ld a,(hl)
        rla
        ld c,a
        inc hl ;keep ZF
        ld a,(hl)
        dec hl ;keep ZF
RCLr16_go
        rla
        ld b,a
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
        jr _ROLr16q
GRP2rm161_1xx
       add a,a
       jp p,SHLr16
        inc l
        ld b,(hl)
       jr c,SARr16
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
;SHRr16
        srl b
        jr SARr16_go
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARr16
        sra b
SARr16_go
        dec l
        ld a,(hl)
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
        ld a,b
        exx
        ld e,a ;overflow data
        exx
_ROLr16pfq
	ld a,c
	exx
	ld d,a ;parity data
	exx
_ROLr16q
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
       ld a,(hl) ;oldb
       rla ;CF
       dec hl ;keep ZF
        jr _ROLr16pfq

GRP2rmmem161
        ADDRm16_GETm16_for_PUTm16
       push hl
       rla
       rla
       rla
       jr c,GRP2rmmem161_1xx
       add a,a
       jp p,GRP2rmmem161_ROL_RCL ;0x0
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
       jr c,RCRm16
;RORm16
       ld a,c
       rra
       jr RCRm16_go
RCRm16
       ex af,af' ;'
       rla
       ld l,a ;l0=old CF, keep other flags
       ex af,af' ;'
       rr l ;restore CF
RCRm16_go
        rr b
        rr c
       rl l ;l0=new CF
       ex af,af' ;'
_ROLm16cfofq
       ld a,l
       rra ;new CF, keep other flags
        ld a,b
        exx
	ld e,a ;overflow data
        exx
_ROLm16q
       ex af,af' ;'
      pop hl
       _PUTm16LoopC
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
GRP2rmmem161_ROL_RCL
       jr c,RCLm16
;ROLm16
        ld a,b
        exx
	ld e,a ;overflow data
        exx
       rla
       jr RCLm16_go
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLm16
        ld a,b
        exx
	ld e,a ;overflow data
        exx
       ex af,af' ;'
       rla
       ld l,a ;l0=old CF, keep other flags
       ex af,af' ;'
       rr l ;restore CF
RCLm16_go
        rl c
        rl b
       rl l ;l0=new CF
       ex af,af' ;'
       ld a,l
       rra ;new CF, keep other flags
       jr _ROLm16q
GRP2rmmem161_1xx
       add a,a
       jp p,SHLm16
       ld l,c ;for generating CF
       jr c,SARm16
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
;SHRm16
        srl b
        jr SARm16_go
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARm16
        sra b
SARm16_go
        rr c
        ld a,c
;чтобы правильно сформировать ZF,SF по b,c:
;если c!=0, то set 0,b
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or b ;CF=0 ;ZF=(bc==0)
	ld a,c
	exx
	ld d,a ;parity data
	exx
        jr _ROLm16cfofq
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLm16
        ld a,h
        exx
        ld e,a ;overflow data
        exx
        or a
        adc hl,hl ;CF,ZF,SF
	ld a,l
	exx
	ld d,a ;parity data
	exx
        ex af,af' ;'
GRP2rmmem16i8q
       _PUTm16hlLoopC

GRP2r16i8q
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_ ;TODO optimize

        ALIGNrm
GRP2rm16cl
        get
        next
;a=MD000R/M: rol r/m,cl
;a=MD001R/M: ror r/m,cl
;a=MD010R/M: rcl r/m,cl
;a=MD011R/M: rcr r/m,cl
;a=MD100R/M: shl r/m,cl
;a=MD101R/M: shr r/m,cl
;a=MD110R/M: ???
;a=MD111R/M: sar r/m,cl
        cp 0b11000000
        jp c,GRP2rmmem16cl
       ADDRr16_keepa
       push hl
        ld (_GRP2rm16cl_hl),hl
       ld hl,GRP2r16i8q
       push hl
_GRP2rm16cl_hl=$+1
        ld hl,(0) ;ok
        jr GRP2rm16cl_go
GRP2rmmem16cl
        ADDRm16_GETm16_for_PUTm16
       push hl
       ld hl,GRP2rmmem16i8q
       push hl
        ld h,b
        ld l,c
GRP2rm16cl_go
        ld c,a ;op
        ld a,(_CL)
       if SHIFTCOUNTMASK
       and 0x1f
       else
       or a
       endif
        jr nz,GRP2rm16cl_no0
       pop hl ;skip
       pop hl ;skip
       _LoopC
GRP2rm16cl_no0
        ld b,a
        ld a,c
       rla
       rla
       rla
       jr c,GRP2rm16cl_1xx
       add a,a
       jr c,GRP2rm16cl_01x
       jp m,RORhl_b_to_hl
        jp ROLhl_b_to_hl
GRP2rm16cl_01x
       jp m,RCRhl_b_to_hl
        jp RCLhl_b_to_hl
GRP2rm16cl_1xx
       add a,a
       jp p,SHLhl_b_to_hl
       jp c,SARhl_b_to_hl
       jp SHRhl_b_to_hl

        ALIGNrm
GRP2rm8cl
        get
        next
;a=MD000R/M: rol r/m,cl
;a=MD001R/M: ror r/m,cl
;a=MD010R/M: rcl r/m,cl
;a=MD011R/M: rcr r/m,cl
;a=MD100R/M: shl r/m,cl
;a=MD101R/M: shr r/m,cl
;a=MD110R/M: ???
;a=MD111R/M: sar r/m,cl
        cp 0b11000000
        jr c,GRP2rmmem8cl
       ADDRr8
        ld c,(hl)
       push hl
       ld hl,GRP2r8i8q
        jr GRP2rmmem8cl_go
GRP2rmmem8cl
        ADDRm16_GETm8c_for_PUTm8
       push hl
       ld hl,GRP2rmmem8i8q
GRP2rmmem8cl_go       
       push af
        ld a,(_CL)
       if SHIFTCOUNTMASK
       and 31
       else
       or a
       endif
        jr nz,GRP2rmmem8cl_no0
       pop af ;skip
       pop hl ;skip
       _LoopC
GRP2rmmem8cl_no0
        ld b,a
       pop af
       ex (sp),hl ;keep return addr, hl=putaddr
       rla
       rla
       rla
       jr c,GRP2m8cl_1xx
       add a,a
       jr c,GRP2m8cl_01x
       jp m,ROR_c_b
        jp ROL_c_b
GRP2m8cl_01x
       jp m,RCR_c_b
        jp RCL_c_b
GRP2m8cl_1xx
       add a,a
       jp p,SHL_c_b
       jp c,SAR_c_b
        jp SHR_c_b

        ALIGNrm
GRP2rm16i8
        get
        next
;a=MD000R/M: rol r/m,i8
;a=MD001R/M: ror r/m,i8
;a=MD010R/M: rcl r/m,i8
;a=MD011R/M: rcr r/m,i8
;a=MD100R/M: shl r/m,i8
;a=MD101R/M: shr r/m,i8
;a=MD110R/M: ??? <------- shl
;a=MD111R/M: sar r/m,i8
        cp 0b11000000
        jr c,GRP2rmmem16i8
       ADDRr16_keepa
       push hl
        ld c,(hl)
        inc l
        ld b,(hl)
      ld hl,GRP2r16i8q
      jr GRP2rm16i8_go
GRP2rmmem16i8
        ADDRm16_GETm16_for_PUTm16
       push hl
      ld hl,GRP2rmmem16i8q
GRP2rm16i8_go
      push hl
        ld h,b
        ld l,c
       rla
       rla
       rla
       jp c,GRP2rmmem16i8_1xx
       add a,a
       jr c,GRP2rmmem16i8_01x
       jp m,RORhli8_to_hl ;TODO once
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLhli8_to_hl
        get
        next
        ld b,a
ROLhl_b_to_hl
        ex af,af' ;' ;remember ZF
        ld a,h
_ROLr16i8loop
        rla
        ld a,l
        rla
        ld l,a
        ld a,h
        rla
        ld h,a
       djnz _ROLr16i8loop
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
        ret
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORhli8_to_hl
        get
        next
        ld b,a
RORhl_b_to_hl
        ex af,af' ;' ;remember ZF
        ld a,l
_RORr16i8loop
        rra
        ld a,h
        rra
        ld h,a
        ld a,l
        rra
        ld l,a
       djnz _RORr16i8loop
        ld a,h
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
        ret

GRP2rmmem16i8_01x
       jp m,RCRhli8_to_hl
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLhli8_to_hl
        get
        next
        ld b,a
RCLhl_b_to_hl
        ex af,af' ;' ;remember ZF,CF
_RCLr16i8loop
        ld a,l
        rla
        ld l,a
        ld a,h
        rla
        ld h,a
       djnz _RCLr16i8loop
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
        ret
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRhli8_to_hl
        get
        next
        ld b,a
RCRhl_b_to_hl
        ex af,af' ;' ;remember ZF,CF
_RCRr16i8loop
        ld a,h
        rra
        ld h,a
        ld a,l
        rra
        ld l,a
       djnz _RCRr16i8loop
        ld a,h
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
        ret

;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLhli8_to_hl
        get
        next
        ld b,a
SHLhl_b_to_hl
_SHLr16i8loop
        or a
        adc hl,hl ;CF,ZF,SF
        djnz _SHLr16i8loop
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ld a,l
	exx
	ld d,a ;parity data
	exx
	ex af,af' ;'
        ret

GRP2rmmem16i8_1xx
      add a,a
      jp p,SHLhli8_to_hl
       jr c,SARhli8_to_hl
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRhli8_to_hl
        get
        next
        ld b,a
SHRhl_b_to_hl
_SHRr16i8loop
        srl h
        rr l
        djnz _SHRr16i8loop
     rra
     ld b,a ;keep CF
        ld a,l
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or h ;CF=0 ;ZF=(bc==0)
     ld a,b
     rla ;CF
        ld a,h
        exx
        ld e,a ;overflow data
        exx
	ld a,l
	exx
	ld d,a ;parity data
	exx
	ex af,af' ;'
        ret
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARhli8_to_hl
        get
        next
        ld b,a
SARhl_b_to_hl
_SARr16i8loop
        sra h
        rr l
        djnz _SARr16i8loop
     rra
     ld b,a ;keep CF
        ld a,l
;чтобы правильно сформировать ZF,SF по h,l:
;если l!=0, то set h!=0
       add a,0xff
       sbc a,a ;CF=(c!=0)
       and d;1 ;any number 1..0x7f
       or h ;CF=0 ;ZF=(bc==0)
     ld a,b
     rla ;CF
        ld a,h
        exx
        ld e,a ;overflow data
        exx
	ld a,l
	exx
	ld d,a ;parity data
	exx
	ex af,af' ;'
        ret

       display "rolls size=",$-beginrolls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginmuls

        ALIGNrm
GRP38
	get
	next
;a=MD000R/M: test r/m8,i8 (не верится по формату)
;a=MD001R/M: ?
;a=MD010R/M: not r/m8
;a=MD011R/M: neg r/m8
;a=MD100R/M: mul ax,r/m8
;a=MD101R/M: imul ax,r/m8
;a=MD110R/M: div ax,r/m8
;a=MD111R/M: idiv ax,r/m8
        cp 0b11000000
        jr c,GRP38mem
       ADDRr8
       and 0b00111000
	jr z,TESTr8i8
	cp 0b00010000
	jr z,NOTr8
	cp 0b00011000
	jr z,NEGr8
	cp 0b00100000
	jp z,MULr8 ;for fbird "mul ah"
	;cp 0b00101000
	;jp z,IMULr8
	cp 0b00110000
	jp z,DIVr8 ;for invaders "div cl"
	;cp 0b00111000
	;jp z,IDIVr8
	jr $;PANIC
MULr8
;mul ah: ax=al*ah
        ld c,(hl) ;reg
MULrmmem8
       push de
        ld b,0
	ld de,(_AX)
        ld d,b;0
	call MUL16 ;HLDE=DE*BC
       ;ld (_DX),hl ;надо ли?
        ld (_AX),de
       pop de
       _Loop_
DIVr8
;DIV AL,r/m8
;Беззнаковое деление AX на r/m8, частное помещается в AL, остаток от деления - в AH
        ld c,(hl) ;reg
DIVrmmem8
       push de
        ld e,c ;reg
        ld d,0
	ld bc,(_AX)
        ld hl,0
	call DIV32 ;BC = HLBC/DE, HL = HLBC%DE
        ld h,l ;остаток
        ld l,c ;частное
        ld (_AX),hl
       pop de
       _Loop_


TESTr8i8
        ld c,(hl)
TESTrmmemi8
        get
        next
        and c
;The OF and CF flags are set to 0. The SF, ZF, and PF flags are set according to the result (see the "Operation" section above). The state of the AF flag is undefined.
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
NOTr8 ;no flags
        ld a,(hl)
        cpl
        ld (hl),a
       _Loop_
NEGr8
        xor a
        sub (hl)
        ld (hl),a
        KEEPHFCFPARITYOVERFLOW_FROMA
       _Loop_
GRP38mem
       ADDRm16_GETm8c_for_PUTm8
       and 0b00111000
	jr z,TESTrmmemi8
	cp 0b00010000
	jr z,NOTrmmem8
	cp 0b00011000
	jr z,NEGrmmem8
	cp 0b00100000
	jp z,MULrmmem8
	;cp 0b00101000
	;jp z,IMULrmmem8
	cp 0b00110000
	jp z,DIVrmmem8
	;cp 0b00111000
	;jp z,IDIVrmmem8
	jr $;PANIC
NOTrmmem8 ;no flags
        ld a,c
        cpl
        ld c,a
       _PUTm8cLoopC_oldpglx
NEGrmmem8
        xor a
        sub c
        ld c,a
        KEEPHFCFPARITYOVERFLOW_FROMA
       _PUTm8cLoopC_oldpglx

        ALIGNrm
GRP316
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
        cp 0b11000000
        jr c,GRP316mem
       ADDRr16_keepa
;TODO rla
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
TESTr16i16
        GETr16
TESTrmmemi16
        get
        and c
        ld c,a
        get
        and b
        ld b,a
;The OF and CF flags are set to 0. The SF, ZF, and PF flags are set according to the result. The state of the AF flag is undefined.
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _LoopC
GRP316mem
        ADDRm16_GETm16
;TODO rla
       and 0b00111000
	jr z,TESTrmmemi16
	cp 0b00010000
	jp z,NOTrmmem16
	cp 0b00011000
	jp z,NEGrmmem16
	cp 0b00100000
	jp z,MULrmmem16
	cp 0b00101000
	jp z,IMULrmmem16
	cp 0b00110000
	jp z,DIVrmmem16
	cp 0b00111000
	jp z,IDIVrmmem16
	jr $;PANIC

;The CF flag set to 0 if the source operand is 0; otherwise it is set to 1. The OF, SF, ZF, AF, and PF flags are set according to the result
        macro NEGBCWITHFLAGS
	xor a
	ld h,a
	ld l,a
        SBCHLBC_KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
        endm
NEGr16
       push hl
        GETr16
        NEGBCWITHFLAGS
       pop hl
       _PUTr16Loop_

NEGrmmem16
       push hl
        NEGBCWITHFLAGS
       pop hl
       _PUTm16LoopC

NOTr16
        ld a,(hl)
        cpl
        ld c,a
        inc l
        ld a,(hl)
        cpl
        dec l
        ld b,a ;no flags
       _PUTr16Loop_

NOTrmmem16
        ld a,c
        cpl
        ld c,a
        ld a,b
        cpl
        ld b,a ;no flags
       _PUTm16LoopC

;mul cx ;ax*cx -> dxax (set OF,CF if result >=65536)
MULr16
        GETr16
MULrmmem16
       push de
	ld de,(_AX);ex de,hl ;de=ax
	call MUL16 ;HLDE=DE*BC
	ld (_DX),hl
        ld (_AX),de
	ld a,h
	or l ;0?
	add a,255 ;set CF if result >=65536
	sbc a,a ;keep CF
	srl a ;keep CF
        exx
	ld e,a ;overflow (d7 != d6) if CF
	exx
	ex af,af' ;'
       pop de
       _Loop_

;imul cx ;ax*cx -> dxax signed (set OF,CF if result >=32768 or < -32768)
IMULr16
        GETr16
IMULrmmem16
       push de
	ld de,(_AX);ex de,hl ;de=ax
        call IMUL_bc_de_to_hlde
	ld (_DX),hl ;HSW
        ld (_AX),de ;LSW
       pop de
       _Loop_

;div cx ;dxax/cx -> ax частное, dx остаток
DIVr16
        GETr16
DIVrmmem16
       push de
        ld d,b
        ld e,c
	ld bc,(_AX)
	ld hl,(_DX)
	call DIV32 ;BC = HLBC/DE, HL = HLBC%DE
	ld (_DX),hl
        ld (_AX),bc
       pop de
       _Loop_

;idiv cx ;dxax/cx -> ax частное, dx остаток signed (знак остатка равен знаку делимого)
IDIVr16
        GETr16
IDIVrmmem16
       push de
        ld d,b
        ld e,c
	ld bc,(_AX)
	ld hl,(_DX)
	call DIV32SIGNED ;BC = HLBC/DE, HL = HLBC%DE
	ld (_DX),hl
        ld (_AX),bc
       pop de
       _Loop_

        ALIGNrm
TESTrmr8
        get
        next
        cp 0b11000000
        jr c,TESTrmmemr8
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
        ld c,(hl)
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        ld a,(hl)
        and c ;op
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
TESTrmmemr8
       ADDRm16_GETm8b_keepaf
       or 0b11000000
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;reg8 addr
       ld a,b
        and (hl) ;op
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC

        ALIGNrm
TESTrmr16
        get
        next
        cp 0b11000000
        jr c,TESTrmmemr16
       ld h,a
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
       ld a,h
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl) ;reg16
        and 7
        add a,a
        ld l,a ;rm addr
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
       ADDRm16_GETm16 ;bc=rmmem
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
        ld h,_AX/256
        ld a,(hl)
        and c
        ld c,a
        inc l
        ld a,(hl)
        and b ;op
        ld b,a
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _LoopC

        ALIGNrm
GRP48
;a=MD000R/M: inc r/m8
;a=MD001R/M: dec r/m8
	get
	next
       cp 0b11000000
       jr c,GRP48mem
       ADDRr8
       and 0b00111000
	jr z,INCr8
	cp 0b00001000
	jp z,DECr8
	jr $;PANIC
GRP48mem
       ADDRm16_GETm8b_for_PUTm8
       and 0b00111000
	jr z,INCrmmem8
	cp 0b00001000
	jp z,DECrmmem8
	jr $;PANIC

INCr8
        ex af,af' ;' ;remember CY (keep)
        ld a,(hl)
        inc a
        ld (hl),a
	KEEPHFCFPARITYOVERFLOW_FROMA
       _Loop_
DECr8
        ex af,af' ;' ;remember CY (keep)
        ld a,(hl)
        dec a
        ld (hl),a
	KEEPHFCFPARITYOVERFLOW_FROMA
       _Loop_

INCrmmem8
        ex af,af' ;' ;remember CY (keep)
	inc b
        ld a,b
	KEEPHFCFPARITYOVERFLOW_FROMA
       _PUTm8bLoopC_oldpgc
DECrmmem8
        ex af,af' ;' ;remember CY (keep)
	dec b
        ld a,b
	KEEPHFCFPARITYOVERFLOW_FROMA
       _PUTm8bLoopC_oldpgc

        ALIGNrm
GRP416
;a=MD000R/M: inc r/m16
;a=MD001R/M: dec r/m16
;a=MD010R/M: call r/m16
;a=MD011R/M: callf m16:16 ;первым идет WORD для IP, потом для CS ;push cs; push ip
;a=MD100R/M: jmp r/m16
;a=MD101R/M: jmpf m16:16 ;первым идет WORD для IP, потом для CS ;push cs; push ip
;a=MD110R/M: push r/m16
;a=MD111R/M: ?
	get
	next
       cp 0b11000000
       jp c,GRP416mem
       ADDRr16_keepa
       and 0b00111000
	jr z,INCr16
	cp 0b00001000
	jr z,DECr16
	cp 0b00010000
	jr z,CALLr16
	;cp 0b00011000
	;jp z,CALLFm1616
	cp 0b00100000
	;jr z,JMPr16
	;cp 0b00101000
	;jp z,JMPFm1616
	;cp 0b00110000
	;jp z,PUSHr16
	jr nz,$;PANIC
JMPr16
        GETr16_de
        jp JMPr16q
INCr16
       push hl
        GETr16
	incbcwithflags
_pophl_PUTr16Loop_
       pop hl
       _PUTr16Loop_
DECr16
       push hl
        GETr16
	decbcwithflags
        jr _pophl_PUTr16Loop_
       ;pop hl
       ;_PUTr16Loop_
CALLr16
        GETr16_hl
        ex de,hl ;new IP(PC)
        ld b,h
        ld c,l ;=old IP(PC)
        putmemspBC
JMPr16q
       _LoopJP

GRP416mem
        ADDRm16_GETm16_for_PUTm16
       and 0b00111000
	jp z,INCrmmem16
	cp 0b00001000
	jp z,DECrmmem16
	cp 0b00010000
	jp z,CALLrmmem16
	cp 0b00011000
	jp z,CALLFm1616mem ;высчитывается эффективный адрес, и с этого адреса берутся 4 байта (ip:cs)
	cp 0b00100000
	jp z,JMPrmmem16
	cp 0b00101000
	jp z,JMPFm1616mem ;высчитывается эффективный адрес, и с этого адреса берутся 4 байта (ip:cs)
	cp 0b00110000
	jp z,PUSHrmmem16
	jr $;PANIC

INCrmmem16
       push hl
	incbcwithflags
_pophl_PUTm16LoopC
       pop hl
       _PUTm16LoopC
DECrmmem16
       push hl
	decbcwithflags
       jr _pophl_PUTm16LoopC
CALLrmmem16
        ld h,b
        ld l,c
_CALLrmmem16q
        ex de,hl ;new IP(PC)
        ld b,h
        ld c,l ;=old IP(PC)
        putmemspBC
       _LoopC_JP
CALLFm1616mem ;высчитывается эффективный адрес, и с этого адреса берутся 4 байта (ip:cs)
;уже прочитано 2 байта bc из (hl), но hl не сдвинут
       push bc ;new IP(PC)
        skip2b_GETm16 ;bc=new CS
       push bc
;push cs; push ip (адрес после команды)
        ld bc,(_CS) ;old CS
        putmemspBC
       pop bc
       ld (_CS),bc ;new CS
       countCS
       pop hl ;new IP(PC)
        jr _CALLrmmem16q
JMPrmmem16
        ld d,b
        ld e,c
       _LoopC_JP
JMPFm1616mem ;высчитывается эффективный адрес, и с этого адреса берутся 4 байта (ip:cs)
;уже прочитано 2 байта bc из (hl), но hl не сдвинут
       push de ;new IP(PC)
        skip2b_GETm16 ;bc=new CS
       ld (_CS),bc ;new CS
       countCS
       pop de ;new IP(PC)
       _LoopJP
PUSHrmmem16
        putmemspBC
       _LoopC

        ALIGNrm
IMULr16rmi8
        get
        next
;a=MDregR/M
;MD=00: imul reg16,[...],i8
;MD=01: imul reg16,[...+disp8],i8
;MD=10: imul reg16,[...+disp16],i8
;MD=11: imul reg16,r/m,i8 ;проще всего
       push af
        cp 0b11000000
        jp c,IMULr16rmmemi8
        ADDRr16_nokeepa
        GETr16 ;bc=r/m
        jr _IMULr16rmmem_geti8
IMULr16rmmemi8
       ADDRm16_GETm16 ;bc=rmmem
_IMULr16rmmem_geti8
        get
        next
       push de
        ld e,a
        rla
        sbc a,a
        ld d,a
        jr _IMULr16rmmem_go

        ALIGNrm
IMULr16rmi16
        get
        next
;a=MDregR/M
;MD=00: imul r16,[...],i16
;MD=01: imul r16,[...+disp8],i16
;MD=10: imul r16,[...+disp16],i16
;MD=11: imul r16,r/m,i16 ;проще всего
       push af
        cp 0b11000000
        jp c,IMULr16rmmemi16
        ADDRr16_nokeepa
        GETr16 ;bc=r/m
        jr _IMULr16rmmem_geti16
IMULr16rmmemi16
       ADDRm16_GETm16 ;bc=rmmem
_IMULr16rmmem_geti16
        getHL
       push de
        ex de,hl
_IMULr16rmmem_go
        call IMUL_bc_de_to_hlde
        ld b,d
        ld c,e
       pop de
       pop af
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
        ld h,_AX/256
       _PUTr16LoopC ;TODO без ld a,l

        ALIGNrm
XCHGr16rm
        get
        next
;a=MDregR/M
;MD=00: xchg reg16,[...]
;MD=01: xchg reg16,[...+disp8]
;MD=10: xchg reg16,[...+disp16]
;MD=11: xchg reg16,r/m ;проще всего
        cp 0b11000000
        jp c,XCHGr16rmmem
        ADDRr16_keepa ;rm addr
      push hl
        GETr16 ;bc=r/m
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
        ld h,_AX/256
        SWAPr16
        jp _pophl_PUTr16Loop_
XCHGr16rmmem
        ADDRm16_GETm16_for_PUTm16
      push hl
        rra
        rra
        and 7*2
        ld l,a ;reg16 addr
        ld h,_AX/256
        SWAPr16
        jp _pophl_PUTm16LoopC

       display "muls size=",$-beginmuls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
