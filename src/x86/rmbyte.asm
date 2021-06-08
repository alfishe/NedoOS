;TODO все ветвления на 8 веток делать по rla (5 rla + 3 jr дешевле, чем 1 and + 7 cp + 7 jr)

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

        macro GETr16_hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        endm

        macro PUTr16
;hl is kept since ADDRr16
        ld a,l
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        call z,encodeSP_pp
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

encodeSP_pp
        ld h,b
        ld l,c
        encodeSP
        ret

encodeSPLoop
encodeSPLoopC
        ld h,b
        ld l,c
        encodeSP
       _Loop_

        macro ADDRSEGMENT_chl_bHSB
;hl=addr
;abc=?s*16
       push af
        ADDSEGMENT_hl_abc_to_ahl
       pop bc
	ld c,a
	ld a,h
	or 0xc0
	ld h,a
;c=page (%01..5432), b=?s_HSB
        endm

        macro ADDRm16_for_GETm8 ;for MOVr8rmmem, OPr8rmmem, TESTrmmemr8, CMPrmmemr8 (в CMPrmmemi8 GET_PUTm8 и pop af, TODO TESTrmmemi8)
         push af
        call ADDRm16_pp
         pop af
        endm ;GET делать сразу! по bc,hl
        
        macro ADDRm16_for_PUTm8 ;for MOVrmmemr8
         push af
        call ADDRm16_pp
         pop af
       push bc ;c=page (%01..5432), b=?s_HSB ;TODO сэкономить 4 такта через push hl и особую версию PUTm8
        endm
        
        macro ADDRm16_for_PUTm8_nokeepcmd ;for MOVrmmemi8
        call ADDRm16_pp
       push bc ;c=page (%01..5432), b=?s_HSB
        endm
        
        macro ADDRm16_for_GET_PUTm8 ;for OPrmmemi8/r8, ROLm8...
         push af
        call ADDRm16_pp
         pop af
       push bc ;c=page (%01..5432), b=?s_HSB
        endm ;GET делать сразу! по bc,hl
        
        macro ADDRm16_for_GETm16 ;for MOVr16rmmem, MOVsregrmmem, CMPrmr16, OPr16rmmem, TESTrmmemr16
        call ADDRm16_pp
        endm ;GET делать сразу! по bc,hl
        
        macro ADDRm16_for_PUTm16_nokeepcmd ;for MOVrmmemi16
        call ADDRm16_pp
       push bc ;c=page (%01..5432), b=?s_HSB
        endm
        
        macro ADDRm16_for_PUTm16 ;for MOVrmmemr16/sreg
         push af
        call ADDRm16_pp
         pop af
       push bc ;c=page (%01..5432), b=?s_HSB
        endm
        
        macro ADDRm16_for_GET_PUTm16 ;for OPrmmemi16/r16, ROLm16..., TESTrmmemi16, MULrmmem16...
         push af
        call ADDRm16_pp
         pop af
       push bc ;c=page (%01..5432), b=?s_HSB
        endm ;GET делать сразу! по bc,hl

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
        ADDRSEGMENT_chl_bHSB
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
        set 3,l
        ld a,(hl)
        pop hl ;abc=?s*16
        ADDRSEGMENT_chl_bHSB
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
;out: hl=zxaddr, c=page (%01..5432), b=?s_HSB
        bit 0,b
        jr nz,ADDRm16_pp_segprefix
addrseg_ds
	ld bc,(ds_LSW)
	ld a,(ds_HSB)
        ADDRSEGMENT_chl_bHSB
        ret

inch_nextsubsegment
;c=page (%01..5432), b=?s_HSB ;keep updated for GETm32
;keep a
;hl=0xXX00 ;keep updated
        inc h
        ret nz
       push af
        ld a,c ;c=page (%01..5432)
        add a,64
        adc a,0
        ld c,a
       dec a
       cp b ;b=?s_HSB
       jr nz,$+3
       dec c ;если читать слово из [?s:ffff], то второй байт читается из [?s:0000]
       push bc
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld h,0xc0
       pop bc
       pop af
        ret

        macro GETm8
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
	ld a,(hl)
        endm
        macro GETm8_c
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
	ld c,(hl)
        endm

        macro GETm16
       push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld b,(hl)
        ld c,a
        endm
        macro GETm16_hl
       push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld h,(hl)
        ld l,a
        endm
        macro GETm16_de
       push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld d,(hl)
        ld e,a
        endm

        macro GETm32_l_h_c_b
       push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
_base_LSB_GETm32_l_h_c_b=$
        ld ($+_shift_LSB_GETm32_l_h_c_b),a
        inc l
        call z,inch_nextsubsegment
	ld a,(hl)
_base_HSB_GETm32_l_h_c_b=$
        ld ($+_shift_HSB_GETm32_l_h_c_b),a
        inc l
        call z,inch_nextsubsegment
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld b,(hl)
        ld c,a
_shift_LSB_GETm32_l_h_c_b=$+1-_base_LSB_GETm32_l_h_c_b
_shift_HSB_GETm32_l_h_c_b=$+2-_base_HSB_GETm32_l_h_c_b
        ld hl,0
        endm

        macro GETm32_e_d_c_b
       push bc ;c=page (%01..5432), b=?s_HSB
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
       pop bc ;c=page (%01..5432), b=?s_HSB
	ld a,(hl)
_base_LSB_GETm32_e_d_c_b=$
        ld ($+_shift_LSB_GETm32_e_d_c_b),a
        inc l
        call z,inch_nextsubsegment
	ld a,(hl)
_base_HSB_GETm32_e_d_c_b=$
        ld ($+_shift_HSB_GETm32_e_d_c_b),a
        inc l
        call z,inch_nextsubsegment
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment
	ld b,(hl)
        ld c,a
_shift_LSB_GETm32_e_d_c_b=$+1-_base_LSB_GETm32_e_d_c_b
_shift_HSB_GETm32_e_d_c_b=$+2-_base_HSB_GETm32_e_d_c_b
        ld de,0
        endm

        macro _PUTm8LoopC
;hl=addr
;a=data
;(sp)=(l=page (%01..5432), h=?s_HSB)
       pop bc ;c=page (%01..5432), b=?s_HSB
       push bc
	ld b,tpgs/256
       push af
	ld a,(bc)
	SETPGC000
       pop af
	ld (hl),a
       pop bc
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC
        endm

        macro _PUTm8_cLoopC
;hl=addr
;c=data
;(sp)=(l=page (%01..5432), h=?s_HSB)
        ld a,c
       pop bc ;c=page (%01..5432), b=?s_HSB
       push bc
	ld b,tpgs/256
       push af
	ld a,(bc)
	SETPGC000
       pop af
	ld (hl),a
       pop bc
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC
        endm

        macro _PUTm16LoopC
;hl=addr
;bc=data
;(sp)=(l=page (%01..5432), h=?s_HSB)
       ex (sp),hl ;l=page (%01..5432), h=?s_HSB
	ld h,tpgs/256
	ld a,(hl)
       ex (sp),hl ;hl=addr
       push bc ;bc=data
	SETPGC000
       pop bc ;bc=data
	ld (hl),c
        ld a,b
       pop bc ;c=page (%01..5432), b=?s_HSB
       _PUTscreen_logpgc_zxaddrhl_datamhl_keepabchlpg
        inc l
        call z,inch_nextsubsegment
	ld (hl),a
       _PUTscreen_logpgc_zxaddrhl_datamhl
       _LoopC
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
        ld h,_AX/256
       sub 64
        ld l,a
        ld l,(hl) ;rm addr
        get
        next
        ld (hl),a
       _Loop_
MOVrmmemi8
       ADDRm16_for_PUTm8_nokeepcmd
        get
        next
       _PUTm8LoopC

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
        and 7
        add a,a
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;rm addr
        getBC
       _PUTr16Loop_
MOVrmmemi16
       ADDRm16_for_PUTm16_nokeepcmd
        getBC
       _PUTm16LoopC

        ALIGNrm
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
       ADDRm16_for_PUTm8
        ld b,_AX/256
        or 0b11000000
        ld c,a ;через ld (),a:ld bc:set 7,c:set 6,c та же скорость
        ld a,(bc)
        ld c,a ;r8 addr
        ld a,(bc)
       _PUTm8LoopC

        ALIGNrm
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
       ADDRm16_for_PUTm16
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

        ALIGNrm
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
       ADDRm16_for_GETm8
       push af
       GETm8_c
       pop af
       or 0b11000000
        ld l,a
        ld h,_AX/256
        ld l,(hl) ;r8 addr
        ld (hl),c
       _LoopC

        ALIGNrm
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
       push af
       ADDRm16_for_GETm16
       GETm16
       pop af
        rra
        rra
        and 7*2 ;r16*2
        ld l,a
        ld h,_AX/256
       _PUTr16LoopC

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
       push af
       and 7
       add a,a
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
        jr MOVsregrmq
MOVsregrmmem
       push af
       ADDRm16_for_GETm16
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
        set 3,l
	ld (hl),a
       _LoopC

        ALIGNrm
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
       ADDRm16_for_PUTm16
       push hl
        rra
        rra
        and 7*2
        add a,_ES&0xff ;единственное отличие от MOVrmmemr16
        ld l,a
        ld h,_ES/256
        ld c,(hl)
        inc l
        ld b,(hl)
       pop hl       
       _PUTm16LoopC

       display "movs size=",$-beginmovs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginalus

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
       ADDRm16_for_GET_PUTm8
       push af
        GETm8_c
       pop af
       push hl
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
        ;GETm8_c
       pop af ;skip
        get
        next
        ld b,a
        ld a,c
        sub b
        KEEPCFPARITYOVERFLOW_FROMA
       pop bc ;skip
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
        or (hl)
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC
ANDrmi8
        get
        next
        and (hl)
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _LoopC

ADDrmmemi8
        or a
        ex af,af' ;'
ADCrmmemi8
       ;push hl
       ; GETm8_c
        ex af,af' ;'
        get
        next
        adc a,c
        OPrmmemi8_POST
SUBrmmemi8
        or a
        ex af,af' ;'
SBBrmmemi8
       ;push hl
       ; GETm8_c
        ex af,af' ;'
        get
        next
        ld b,a
        ld a,c
        sbc a,b
        OPrmmemi8_POST
XORrmmemi8
       ;push hl
       ; GETm8_c
        get
        next
        xor c
        LOGICOPrmmemi8_POST
ORrmmemi8
       ;push hl
       ; GETm8_c
        get
        next
        or c
        LOGICOPrmmemi8_POST
ANDrmmemi8
       ;push hl
       ; GETm8_c
        get
        next
        and c
        LOGICOPrmmemi8_POST

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
        GETr16_hl
	getBC
	or a
	sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       _Loop_
GRP1rmmemi16
       ADDRm16_for_GET_PUTm16
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
        GETm16_hl
        getBC
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       pop bc ;skip
       _LoopC

       macro OPr16i16_PRE
       push hl
        GETr16_hl
        getBC
       endm
       macro OPr16i8_PRE
       push hl
        GETr16_hl
        get
        next
        ld c,a
        rla
        sbc a,a
        ld b,a
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
        GETm16_hl
        getBC
       endm
       macro OPrmmem16i8_PRE
       push hl
        GETm16_hl
        get
        next
        ld c,a
        rla
        sbc a,a
        ld b,a
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

        ALIGNrm
GRP1rm16i8 ;операнд расширяется со знаком
	get
	next
;a=MD000R/M: add r/m,i8
;a=MD010R/M: adc r/m,i8
;a=MD011R/M: sbb r/m,i8
;a=MD101R/M: sub r/m,i8
;a=MD111R/M: cmp r/m,i8
;MD=00: cmd [...],i8
;MD=01: cmd [...+disp8],i8
;MD=10: cmd [...+disp16],i8
;MD=11: cmd r/m,i8 ;проще всего
        cp 0b11000000
        jr c,GRP1rmmem16i8
       ADDRr16
       and 0b00111000
	jp z,ADDr16i8
	;cp 0b00001000
	;jp z,ORr16i8
	cp 0b00010000
	jp z,ADCr16i8
	cp 0b00011000
	jp z,SBBr16i8
	;cp 0b00100000
	;jp z,ANDr16i8
	cp 0b00101000
	jp z,SUBr16i8
        ;cp 0b00110000
	;jp z,XORr16i8
;CMPr16i8
        GETr16_hl
        get
        next
        ld c,a
        rla
        sbc a,a
        ld b,a
	or a
	sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       _Loop_
GRP1rmmem16i8
       ADDRm16_for_GET_PUTm16
       and 0b00111000
	jp z,ADDrmmem16i8
	;cp 0b00001000
	;jp z,ORrmmem16i8
	cp 0b00010000
	jp z,ADCrmmem16i8
	cp 0b00011000
	jp z,SBBrmmem16i8
	;cp 0b00100000
	;jp z,ANDrmmem16i8
	cp 0b00101000
	jp z,SUBrmmem16i8
	;cp 0b00110000
	;jp z,XORrmmem16i8
;CMPrmmem16i8
        GETm16_hl
        get
        next
        ld c,a
        rla
        sbc a,a
        ld b,a
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       pop bc ;skip
       _LoopC

ADDr16i8
        or a
        ex af,af' ;'
ADCr16i8
        OPr16i8_PRE
        ex af,af' ;'
        adc hl,bc
        OPr16i16_POST
SUBr16i8
        or a
        ex af,af' ;'
SBBr16i8
        OPr16i8_PRE
        ex af,af' ;'
        sbc hl,bc
        OPr16i16_POST
ADDrmmem16i8
        or a
        ex af,af' ;'
ADCrmmem16i8
        OPrmmem16i8_PRE
        ex af,af' ;'
        adc hl,bc
        OPrmmemi16_POST
SUBrmmem16i8
        or a
        ex af,af' ;'
SBBrmmem16i8
        OPrmmem16i8_PRE
        ex af,af' ;'
        sbc hl,bc
        OPrmmemi16_POST

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
        ;op (hl),c
       endm
       macro OPrmr8_POST
6;OPrmmemr8
       ADDRm16_for_GET_PUTm8
       or 0b11000000
_base_OPrmmemr8=$
       ld ($+_shift_OPrmmemr8),a
       ;push de
       push hl
       ;ld e,a
       GETm8
       ;ld c,a
       ; ld l,e
       ; ld h,_AX/256
_shift_OPrmmemr8=$+1-_base_OPrmmemr8
       ld hl,_AX
        ld l,(hl) ;r8 addr
        ;op a,(hl)
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
        adc a,c ;op
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        ld c,a
        ex af,af' ;'
        ld a,c
        adc a,(hl) ;op
       ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC

        ALIGNrm
SUBrmr8
        or a
        ex af,af' ;'
        ALIGNrm
SBBrmr8
        OPrmr8_PRE
        ex af,af' ;'
        ld a,(hl)
        sbc a,c ;op
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        ld c,a
        ex af,af' ;'
        ld a,c
        sbc a,(hl) ;op
       ld c,a
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC

        ALIGNrm
CMPrmr8
        OPrmr8_PRE
        ld a,(hl)
        sub c ;op
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
6;CMPrmmemr8
       ADDRm16_for_GETm8
       or 0b11000000
       ld (_CMPrmmemr8_r8addraddr),a
       GETm8
_CMPrmmemr8_r8addraddr=$+1
        ld hl,_AX
        ld l,(hl) ;r8 addr
        sub (hl) ;op
        KEEPCFPARITYOVERFLOW_FROMA
       _LoopC

        ALIGNrm
XORrmr8
        OPrmr8_PRE
        ld a,c
        xor (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        xor (hl) ;op
       ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC

        ALIGNrm
ORrmr8
        OPrmr8_PRE
        ld a,c
        or (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        or (hl) ;op
       ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC

        ALIGNrm
ANDrmr8
        OPrmr8_PRE
        ld a,c
        and (hl) ;op
        ld (hl),a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       _Loop_
        OPrmr8_POST
        and (hl) ;op
       ld c,a
        KEEPLOGICCFPARITYOVERFLOW_FROMA
       pop hl
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
       ADDRm16_for_GET_PUTm16
      push hl
       push af
       GETm16_hl
       pop af
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
        ;or a
        ;adc hl,bc ;op
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
        adc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
        ex af,af' ;'
        adc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
      pop hl
      _PUTm16LoopC

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
        sbc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
       pop hl
       _PUTr16Loop_
        OPrmr16_POST
        ex af,af' ;'
        adc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
        ld b,h
        ld c,l
      pop hl
      _PUTm16LoopC

        ALIGNrm
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
       push af
       ADDRm16_for_GETm16
       GETm16_hl
       pop af
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
        or a
        sbc hl,bc ;op
        KEEPCFPARITYOVERFLOW_FROMHL
       _LoopC

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
        ld a,l
        xor c
        ld c,a
        ld a,h
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
        ld a,l
        or c
        ld c,a
        ld a,h
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
       ADDRm16_for_GETm8
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
       ADDRm16_for_GETm8
       push af
       GETm8_c
       pop af
       or 0b11000000
        ld h,_AX/256
       jp 5b;ADDr8rmok
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
        adc a,c ;op
        ld (hl),a
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
        sbc a,c ;op
        ld (hl),a
        OPr8rm_POST

        ALIGNrm
CMPr8rm
        OPr8rm_PRE
        ld a,(hl)
        sub c ;op
        OPr8rm_POST

        ALIGNrm
XORr8rm
        OPr8rm_PRE
        ld a,(hl)
        xor c ;op
        ld (hl),a
        LOGICOPr8rm_POST

        ALIGNrm
ORr8rm
        OPr8rm_PRE
        ld a,(hl)
        or c ;op
        ld (hl),a
        LOGICOPr8rm_POST

        ALIGNrm
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
       push af
       ADDRm16_for_GETm16
       GETm16
        ld h,_AX/256
       jp 5b;OPr16rmok ;там pop af
       endm
       macro LOGICOPr16rm_POST
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _PUTr16LoopC
6;OPr16rmmem
       push af
       ADDRm16_for_GETm16
       GETm16
        ld h,_AX/256
       jp 5b;OPr16rmok ;там pop af
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
        adc hl,bc ;op
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
        sbc hl,bc ;op
        OPr16rm_POST

        ALIGNrm
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
6;CMPr16rmmem
       push af
       ADDRm16_for_GETm16
       GETm16
        ld h,_AX/256
       jp 5b;OPr16rmok ;там pop af

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
        LOGICOPr16rm_POST

       display "alus size=",$-beginalus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginrolls

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
	jr $;PANIC
GRP2rmmem81
       ADDRm16_for_GET_PUTm8
       push af
        GETm8_c
       pop af
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
	jr $;PANIC

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
        ;GETm8_c
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
        ;GETm8_c
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
        ;GETm8_c
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
        ;GETm8_c
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
        ;GETm8_c
        sla c
        ld a,c
        KEEPCFPARITYOVERFLOW_FROMA
       pop hl
       _PUTm8_cLoopC
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRm8
        ;GETm8_c
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
        ;GETm8_c
        sra c
        ld a,c
        exx
	ld d,a ;parity data
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       pop hl
       _PUTm8_cLoopC

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
	jr $;PANIC
GRP2rmmem161
       ADDRm16_for_GET_PUTm16
       push hl
       and 0b00111000
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
	jr $;PANIC

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
       ld a,(hl) ;oldb
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
       ;ld a,b
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
SHLm16
       GETm16_hl
        ld a,h
        exx
        ld e,a ;overflow data
        exx
        or a
        adc hl,hl ;CF,ZF,SF
	ex af,af' ;'
	ld a,h
	xor l
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
;a=MD110R/M: ???
;a=MD111R/M: sar r/m,i8
        cp 0b11000000
        jr c,GRP2rmmem16i8
       ADDRr16
       and 0b00111000
	jp z,ROLr16i8
	cp 0b00001000
	jp z,RORr16i8
	cp 0b00010000
	jp z,RCLr16i8
	cp 0b00011000
	jp z,RCRr16i8
	cp 0b00100000
	jp z,SHLr16i8
	cp 0b00101000
	jp z,SHRr16i8
	cp 0b00111000
	jp z,SARr16i8
	jr $;PANIC
GRP2rmmem16i8
       ADDRm16_for_GET_PUTm16
       push hl
       and 0b00111000
	jp z,ROLm16i8
	cp 0b00001000
	jp z,RORm16i8
	cp 0b00010000
	jp z,RCLm16i8
	cp 0b00011000
	jp z,RCRm16i8
	cp 0b00100000
	jp z,SHLm16i8
	cp 0b00101000
	jp z,SHRm16i8
	cp 0b00111000
	jp z,SARm16i8
	jr $;PANIC

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call ROLhli8_to_bc
       pop hl
       _PUTr16Loop_
ROLhli8_to_bc
        get
        next
        ld b,a
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
       ld b,h
       ld c,l
        ret
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call RORhli8_to_bc
       pop hl
       _PUTr16Loop_
RORhli8_to_bc
        get
        next
        ld b,a
        ex af,af' ;' ;remember ZF        
        ld a,h
_RORr16i8loop
        rra
        ld a,l
        rra
        ld l,a
        ld a,h
        rra ;use CF from L
        ld h,a
       djnz _RORr16i8loop
        exx
	ld e,a ;overflow data
        exx
	ex af,af' ;'
       ld b,h
       ld c,l
        ret
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call RCLhli8_to_bc
       pop hl
       _PUTr16Loop_
RCLhli8_to_bc
        get
        next
        ld b,a
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
       ld b,h
       ld c,l
        ret
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call RCRhli8_to_bc
       pop hl
       _PUTr16Loop_
RCRhli8_to_bc
        get
        next
        ld b,a
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
       ld b,h
       ld c,l
        ret
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call SHLhli8_to_bc
       pop hl
       _PUTr16Loop_
SHLhli8_to_bc
        get
        next
        ld b,a
_SHLr16i8loop
        or a
        adc hl,hl ;CF,ZF,SF
        djnz _SHLr16i8loop
        exx
	rra
	ld e,a ;overflow data
	rla ;restore CF
        exx
	ex af,af' ;'
	ld a,h
	xor l
	exx
	ld d,a ;parity data
	exx
       ld b,h
       ld c,l
        ret
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call SHRhli8_to_bc
       pop hl
       _PUTr16Loop_
SHRhli8_to_bc
        get
        next
        ld b,a
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
	ex af,af' ;'
        ld a,h
        exx
        ld e,a ;overflow data
        exx
	xor l
	exx
	ld d,a ;parity data
	exx
       ld b,h
       ld c,l
        ret
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARr16i8
       push hl
        ld a,(hl)
        inc l
        ld h,(hl)
        ld l,a
        call SARhli8_to_bc
       pop hl
       _PUTr16Loop_
SARhli8_to_bc
        get
        next
        ld b,a
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
	ex af,af' ;'
        ld a,h
        exx
        ld e,a ;overflow data
        exx
	xor l
	exx
	ld d,a ;parity data
	exx
       ld b,h
       ld c,l
        ret

;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
ROLm16i8
       GETm16_hl
       call ROLhli8_to_bc
      pop hl
       _PUTm16LoopC
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RORm16i8
       GETm16_hl
       call RORhli8_to_bc
      pop hl
       _PUTm16LoopC
;For left rotates, the OF flag is set to the exclusive OR of the CF bit (after the rotate) and the most-significant bit of the result.
RCLm16i8
       GETm16_hl
       call RCLhli8_to_bc
      pop hl
       _PUTm16LoopC
;For right rotates, the OF flag is set to the exclusive OR of the two most-significant bits of the result.
RCRm16i8
       GETm16_hl
       call RCRhli8_to_bc
      pop hl
       _PUTm16LoopC
;For left shifts, the OF flag is set to 0 if the most significant bit of the result is the same as the CF flag (that is, the top two bits of the original operand were the same); otherwise, it is set to 1.
SHLm16i8
       GETm16_hl
       call SHLhli8_to_bc
      pop hl
       _PUTm16LoopC
;For the SHR instruction, the OF flag is set to the most-significant bit of the original operand. (result7 xor result6)
SHRm16i8
       GETm16_hl
       call SHRhli8_to_bc
      pop hl
       _PUTm16LoopC
;For the SAR instruction, the OF flag is cleared for all 1-bit shifts. (result7 xor result6)
SARm16i8
       GETm16_hl
       call SARhli8_to_bc
      pop hl
       _PUTm16LoopC

       display "rolls size=",$-beginrolls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
beginmuls

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
TESTrmmemi16
        GETm16
       pop af ;skip
        jr _TESTrmi16bc
TESTr16i16
        GETr16
_TESTrmi16bc
        get
        and c
        ld c,a
        get
        and b
        ld b,a
;The OF and CF flags are set to 0. The SF, ZF, and PF flags are set according to the result (see the "Operation" section above). The state of the AF flag is undefined. 
        KEEPLOGICCFPARITYOVERFLOW_FROMBC_AisB
       _LoopC
GRP316mem
       ADDRm16_for_GET_PUTm16
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
	sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
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
        GETm16
        NEGBCWITHFLAGS
       pop hl
       _PUTm16LoopC

NOTr16
       push hl
        GETr16 ;TODO optimize
        ld a,b
        cpl
        ld b,a
        ld a,c
        cpl
        ld c,a ;no flags
       pop hl
       _PUTr16Loop_

NOTrmmem16
       push hl
        GETm16 ;TODO optimize
        ld a,b
        cpl
        ld b,a
        ld a,c
        cpl
        ld c,a ;no flags        
       pop hl
       _PUTm16LoopC

        ALIGNrm
TESTrmr8
        get
        next
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
       ADDRm16_for_GETm8
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

        ALIGNrm
TESTrmr16
        get
        next
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
       ADDRm16_for_GETm16
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

        ALIGNrm
GRP48
;a=MD000R/M: inc r/m8
;a=MD001R/M: dec r/m8
	get
	next
       cp 0b11000000
       jr c,GRP48mem
	jr $;PANIC
GRP48mem
	jr $;PANIC

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
       jr c,GRP416mem
       ADDRr16
       and 0b00111000
      if 0
	jr z,INCr16
	cp 0b00001000
	jp z,DECr16
	cp 0b00010000
	jp z,CALLr16
	;cp 0b00011000
	;jp z,CALLFm1616
	cp 0b00100000
	jp z,JMPr16
	;cp 0b00101000
	;jp z,JMPFm1616
	cp 0b00110000
	jp z,PUSHrmmem16
      endif
	jr $;PANIC
GRP416mem
       push af
       ADDRm16_for_GETm16
       pop af
       and 0b00111000
	jr z,INCrmmem16
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
       push bc ;for PUTm16
       push hl
        GETm16
	incbcwithflags
       pop hl
       _PUTm16LoopC
DECrmmem16
       push bc ;for PUTm16
       push hl
        GETm16
	decbcwithflags
       pop hl
       _PUTm16LoopC
CALLrmmem16
        GETm16_hl
        ex de,hl ;new IP(PC)
        ld b,h
        ld c,l ;=old IP(PC)
        putmemspBC
       _LoopC_JP
CALLFm1616mem ;высчитывается эффективный адрес, и с этого адреса берутся 4 байта (ip:cs)
        GETm32_l_h_c_b ;hl=new IP, bc=new CS
;push cs; push ip (адрес после команды)
       push hl
       push bc
        ld bc,(_CS) ;old CS
        putmemspBC
       pop bc
       ld (_CS),bc ;new CS
       countCS
        LD b,d
        ld c,e ;=old IP(PC)
       pop de ;new IP(PC)
        putmemspBC
       _LoopC_JP
JMPrmmem16
        GETm16_de
       _LoopC_JP
JMPFm1616mem ;высчитывается эффективный адрес, и с этого адреса берутся 4 байта (ip:cs)
        GETm32_e_d_c_b ;hl=new IP, bc=new CS
       ld (_CS),bc ;new CS
       countCS
       _LoopJP
PUSHrmmem16
        GETm16
        putmemspBC
       _LoopC

        ALIGNrm
IMULr16rmi8
        get
        next
;a=MDregR/M
;MD=00: imul r16,[...],i8
;MD=01: imul r16,[...+disp8],i8
;MD=10: imul r16,[...+disp16],i8
;MD=11: imul r16,r/m,i8 ;проще всего
        cp 0b11000000
        jp c,IMULr16rmmemi8
       push af
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
       pop af
       push hl ;r16addr
        and 7
        add a,a
        ld l,a
        GETr16 ;bc=r/m
        get
        next
       push de
        ld e,a
        rla
        sbc a,a
        ld d,a
        call IMUL_bc_de_to_hlde
        ld b,d
        ld c,e
       pop de
       pop hl
       _PUTr16Loop_
IMULr16rmmemi8
       ADDRm16_for_GETm16
       push af
       GETm16 ;bc=rmmem
       pop af
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
       push hl ;r16addr
        get
        next
       push de
        ld e,a
        rla
        sbc a,a
        ld d,a
        call IMUL_bc_de_to_hlde
        ld b,d
        ld c,e
       pop de
       pop hl
       _PUTr16LoopC

        ALIGNrm
IMULr16rmi16
        get
        next
;a=MDregR/M
;MD=00: imul r16,[...],i16
;MD=01: imul r16,[...+disp8],i16
;MD=10: imul r16,[...+disp16],i16
;MD=11: imul r16,r/m,i16 ;проще всего
        cp 0b11000000
        jp c,IMULr16rmmemi16
       push af
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
       pop af
       push hl ;r16addr
        and 7
        add a,a
        ld l,a
        GETr16 ;bc=r/m
        getHL
       push de
        ex de,hl
        call IMUL_bc_de_to_hlde
        ld b,d
        ld c,e
       pop de
       pop hl
       _PUTr16Loop_
IMULr16rmmemi16
       ADDRm16_for_GETm16
       push af
       GETm16 ;bc=rmmem
       pop af
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
       push hl ;r16addr
        getHL
       push de
        ex de,hl
        call IMUL_bc_de_to_hlde
        ld b,d
        ld c,e
       pop de
       pop hl
       _PUTr16LoopC

        ALIGNrm
XCHGr16rm
        get
        next
;a=MDregR/M
;MD=00: xchg r16,[...]
;MD=01: xchg r16,[...+disp8]
;MD=10: xchg r16,[...+disp16]
;MD=11: xchg r16,r/m ;проще всего
        cp 0b11000000
        jp c,XCHGr16rmmem
       push af
        and 7
        add a,a
        ld l,a
        ld h,_AX/256
       pop af
       ld (_XCHGr16rm_rmaddr),hl
        GETr16 ;bc=r/m
       push bc ;rm
        rra
        rra
        and 7*2
        ld l,a
       push hl ;r16addr
        GETr16 ;bc=r16
_XCHGr16rm_rmaddr=$+1
        ld hl,0
        PUTr16 ;rm (old r16)
       pop hl ;r16addr
       pop bc ;r16 (old rm)
       _PUTr16Loop_
XCHGr16rmmem
       ADDRm16_for_GET_PUTm16
       push af
       GETm16
       pop af
        rra
        rra
        and 7*2
        ld l,a
        ld h,_AX/256
       ld (_XCHGr16rmmem_oldrm),bc ;TODO обмен на месте, но с проверкой на _SP
        GETr16 ;bc=r16
       push bc
_XCHGr16rmmem_oldrm=$+1
        ld bc,0
        dec l
        PUTr16 ;r16 (old rm)
       pop bc ;rm (old r16)
       _PUTm16LoopC

       display "muls size=",$-beginmuls
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
