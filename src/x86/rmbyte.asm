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
;bc=data
        ld a,l
        _PUTr16Loop_AisL
        endm
        macro _PUTr16Loop_AisL
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jp z,encodeSPLoop ;TODO ret z
       _Loop_
        endm

        macro _PUTr16LoopC
;hl is kept since ADDRr16
;bc=data
        ld a,l
        _PUTr16LoopC_AisL
        endm
        macro _PUTr16LoopC_AisL
        ld (hl),c
        inc l
        ld (hl),b
        cp _SP&0xff
        jp z,encodeSPLoopC ;TODO ret z
       _LoopC
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
       _LoopC

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
	  ;ld b,tpgs/256
	  ;ld a,(bc)
	  ;SETPGC000
	ld a,(hl)
        inc l
        call z,inch_nextsubsegment_pglx
	ld b,(hl)
        ld c,a
        endm

        macro ADDRm16_GETm8b_keepaf ;for MOVr8rmmem, OPr8rmmem, TESTrmmemr8, CMPrmmemr8 (в CMPrmmemi8 GET_PUTm8 и pop af) ;TODO kill
        push af
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
	;ld b,tpgs/256
	;ld a,(bc)
	;SETPGC000
        pop af
        ld b,(hl)
        endm

        macro ADDRm16_GETm8c_for_PUTm8 ;for OPrmmemi8/r8, ROLm8... ;keep lx=pg!!!
        push af
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
	;ld b,tpgs/256
	;ld a,(bc)
	;SETPGC000
        pop af
        ld c,(hl)
        endm

        macro ADDRm16_for_PUTm8a_nokeepaf ;for MOVrmmemi8, MOVrmmemr8
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
	;ld b,tpgs/256
	;ld a,(bc)
	;SETPGC000
        endm

        macro ADDRm16_GETm16 ;for MOVr16rmmem, MOVsregrmmem, CMPrmr16, OPr16rmmem, TESTrmmemr16
        push af
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
            ;ld lx,c ;можно убрать, если особый вариант nextsubsegment
         GETm16
        pop af
        endm

        macro ADDRm16_GETm16_keeplx ;for 32bit read
        push af
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
         GETm16
        pop af
        endm

        macro ADDRm16_GETm16_keeplx_nokeepaf ;for 32bit read
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
         GETm16
        endm

        macro ADDRm16_for_PUTm16_nokeepaf ;for MOVrmmemi16
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
        endm

        macro ADDRm16_for_PUTm16 ;for MOVrmmemr16/sreg
         push af
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
         pop af
        endm
;TODO fix! уже прочитано 2 байта из (hl)!

        macro ADDRm16_GETm16_for_PUTm16 ;for OPrmmemi16/r16, ROLm16..., TESTrmmemi16, MULrmmem16...
       push af
        call ADDRGETm16_pp
        ;ADDRSEGMENT_chl_bHSB
        ; ld lx,c
        push hl
        GETm16
        pop hl
       pop af
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

        macro _PUTm8aLoopC_oldpglx
;hl=addr
;a=data
;lx=page (%01..5432)
	ld (hl),a
        ld c,lx
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
        push bc
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADDRm16_pp_ssbp_plusi ;ss:bp+?i+
        ld bc,(_BP)
        add hl,bc
       cp 64
       ret c
ADDRm16_pp_ssbp ;ss:bp+ ;не бывает nodisp, отсеяно выше
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
       rla
	get ;dispL
	next
       jr nc,ADDRm16_pp_ds_8bit
        add a,l
        ld l,a
        jr nc,$+3
        inc h
	get ;dispH
	next
        add a,h
        ld h,a
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
;out (only for LEA): hl=addr
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
        ld bc,(_BX) ;00?=[bx]+[?i]+disp
        add hl,bc
ADDRm16_pp_ds ;ds:??+
;MD=00: cmd [...] ;no disp
       cp 64
       ret c
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
       rla
	get ;dispL
	next
       jr nc,ADDRm16_pp_ds_8bit
        add a,l
        ld l,a
        jr nc,$+3
        inc h
	get ;dispH
	next
        add a,h
        ld h,a
        ret
ADDRm16_pp_ds_8bit
       or a
       jp p,$+4
       dec h
        add a,l
        ld l,a
        ret nc
        inc h
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ADDRGETm16_pp_ssbp_plusi ;ss:bp+?i+
       push bc
        ld bc,(_BP)
        add hl,bc
       pop bc
       cp 64
       jr c,ADDRGETm16_pp_ss_nodisp
ADDRGETm16_pp_ssbp ;ss:bp+ ;не бывает nodisp, отсеяно выше
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
       rla
	get ;dispL
	next
       jr nc,ADDRGETm16_pp_ssbp_8bit
        add a,l
        ld l,a
        jr nc,$+3
        inc h
       ;bit 7,c
       ;jr z,ADDRGETm16_pp_ss_nodisp
	get ;dispH
	next
        add a,h
        ld h,a
ADDRGETm16_pp_ss_nodisp
        bit 0,b
        jr nz,ADDRGETm16_pp_segprefix
	ld bc,(ss_LSW)
	ld a,(ss_HSB)
        ADDRSEGMENT_chl_bHSB
         ld lx,c
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ret
ADDRGETm16_pp_ssbp_8bit
       or a
       jp p,$+4
       dec h
        add a,l
        ld l,a
        jr nc,ADDRGETm16_pp_ss_nodisp
        inc h
        jp ADDRGETm16_pp_ss_nodisp

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
;out: hl=zxaddr, lx=page on (%01..5432) [b=?s_HSB]
ADDRGETm16_pp
        bit 2,a
        jr z,ADDRGETm16_pp_sum ;ds:b?+?i+
;1xx
        bit 1,a
        jr z,ADDRGETm16_pp_i ;ds:?i+
;11x
        bit 0,a
        ld hl,(_BX)
        jr nz,ADDRGETm16_pp_ds ;ds:??+
        ld hl,(_BP)
       cp 64
       jr nc,ADDRGETm16_pp_ssbp ;ss:bp+
;[bp+nodisp] = [disp]
       getHL
        bit 0,b
        jr z,ADDRGETm16_pp_seg_ds
ADDRGETm16_pp_segprefix
        push hl
        ld h,es_LSW/256
        ld l,b
        ld b,(hl)
        dec l
        ld c,(hl)
        res 4,l
        ld a,(hl)
        pop hl ;abc=?s*16
        ADDRSEGMENT_chl_bHSB
         ld lx,c
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ret
ADDRGETm16_pp_i ;10x
        bit 0,a
        ld hl,(_SI)
        jr z,ADDRGETm16_pp_ds
        ld hl,(_DI)
        jp ADDRGETm16_pp_ds
ADDRGETm16_pp_sum ;0xx
        bit 0,a
        ld hl,(_SI)
        jr z,$+5
        ld hl,(_DI)
        bit 1,a
        jp nz,ADDRGETm16_pp_ssbp_plusi;01?=[bp]+[?i]+disp
       push bc
        ld bc,(_BX) ;00?=[bx]+[?i]+disp
        add hl,bc
       pop bc
ADDRGETm16_pp_ds ;ds:??+
;MD=00: cmd [...] ;no disp
       cp 64
       jr c,ADDRGETm16_pp_ds_nodisp
;MD=01: cmd [...+disp8]
;MD=10: cmd [...+disp16]
       rla
	get ;dispL
	next
       jr nc,ADDRGETm16_pp_ds_8bit
        add a,l
        ld l,a
        jr nc,$+3
        inc h
	get ;dispH
	next
        add a,h
        ld h,a
ADDRGETm16_pp_ds_nodisp
;вызывается из MOVaxmem
;out: hl=zxaddr, c=page (%01..5432), [b=?s_HSB]
        bit 0,b
        jr nz,ADDRGETm16_pp_segprefix
ADDRGETm16_pp_seg_ds
	ld bc,(ds_LSW)
	ld a,(ds_HSB)
        ADDRSEGMENT_chl_bHSB
         ld lx,c
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ret
ADDRGETm16_pp_ds_8bit
       or a
       jp p,$+4
       dec h
        add a,l
        ld l,a
        jr nc,ADDRGETm16_pp_ds_nodisp
        inc h
        jp ADDRGETm16_pp_ds_nodisp

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
       ;dec a
       ;cp b ;b=?s_HSB
       ;jr nz,$+3
       ;dec c ;если читать слово из [?s:ffff], то второй байт читается из [?s:0000], но на 386 не так
	ld b,tpgs/256
	ld a,(bc)
	SETPGC000
        ld h,0xc0
       pop af
        ret
