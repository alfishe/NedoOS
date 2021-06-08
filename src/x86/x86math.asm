;cbw ;Expand AL to AX
CBWer
	ld a,(_AL);l ;al
	rla
	sbc a,a
	ld (_AH),a;h,a ;ah
       _Loop_

;cwd ;Expand AX to DX:AX
CWDer
	ld a,(_AH);h ;ah
	rla
	sbc a,a
	ld h,a
	ld l,a
	ld (_DX),hl
       _Loop_

ADDali8
	get
	next
        ld hl,_AL
        add a,(hl)
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
SUBali8
	get
	next
	ld c,a
        ld hl,_AL
        ld a,(hl)
	sub c
	ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
ADCali8
        ex af,af' ;'
	get
	next
        ld hl,_AL
        adc a,(hl)
        ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
SBBali8
        ex af,af' ;'
	get
	next
	ld c,a
        ld hl,_AL
        ld a,(hl)
	sbc a,c
	ld (hl),a
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_
CMPali8
	get
	next
	ld c,a
        ld a,(_AL)
	sub c
        KEEPCFPARITYOVERFLOW_FROMA
       _Loop_

ADDaxi16
	getBC
        ld hl,(_AX)
	or a
	adc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
        ld (_AX),hl
       _Loop_
SUBaxi16
	getBC
        ld hl,(_AX)
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
        ld (_AX),hl
       _Loop_
ADCaxi16
	getBC
        ld hl,(_AX)
	ex af,af' ;'
	adc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
        ld (_AX),hl
       _Loop_
SBBaxi16
	getBC
        ld hl,(_AX)
	ex af,af' ;'
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
        ld (_AX),hl
       _Loop_
CMPaxi16
	getBC
        ld hl,(_AX)
        or a
        sbc hl,bc
        KEEPCFPARITYOVERFLOW_FROMHL
       _Loop_

;mul cx ;ax*cx -> dxax (set OF,CF if result >=65536)
MULrmmem16
       pop af ;skip
        GETm16
        jr MULbc
MULr16;cx
        GETr16
MULbc
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
IMULrmmem16
       pop af ;skip
        GETm16
        jr IMULbc
IMULr16;cx
        GETr16
IMULbc
       push de
	ld de,(_AX);ex de,hl ;de=ax
        call IMUL_bc_de_to_hlde
	ld (_DX),hl ;HSW
        ld (_AX),de ;LSW
       pop de
       _Loop_

IMUL_bc_de_to_hlde
	call MUL16SIGNED ;HLDE=DE*BC
	ld a,d
	rla ;LSW sign
	jr c,IMULCX_NEG
	ld a,h
	or l
	add a,255 ;set CF if LSW sign != HSW (result >=32768 or < -32768)
	jp IMULCX_NEGQ
IMULCX_NEG
	ld a,h
	and l
	sub 255 ;set CF if LSW sign != HSW (result >=32768 or < -32768)
IMULCX_NEGQ
	sbc a,a ;keep CF
	srl a ;keep CF
        exx
	ld e,a ;overflow (d7 != d6) if CF
	exx
	ex af,af' ;'
        ret

;HLDE=DE*BC
MUL16SIGNED
	bit 7,d
	jr nz,MUL16SIGNED_NEGDE
	bit 7,b
	jp z,MUL16
MUL16SIGNED_NEGBC
	xor a
	sub c
	ld c,a
	sbc a,b
	sub c
	ld b,a
	jp MUL16NEGHLDE
MUL16SIGNED_NEGDE
	xor a
	sub e
	ld e,a
	sbc a,d
	sub e
	ld d,a
	bit 7,b
	jr nz,MUL16SIGNED_NEGDE_NEGBC
MUL16NEGHLDE
	call MUL16
	xor a
	sub e
	ld e,a
	ld a,0
	sbc a,d
	ld d,a
	ld a,0
	sbc a,l
	ld l,a
	ld a,0
	sbc a,h
	ld h,a
	ret
MUL16SIGNED_NEGDE_NEGBC
	xor a
	sub c
	ld c,a
	sbc a,b
	sub c
	ld b,a
;HLDE=DE*BC
MUL16
        ld hl,0
	dup 16
        rr d
        rr e
        jr nc,$+3
        add hl,bc
        rr h
        rr l
	edup
        rr d
        rr e
	ret

;div cx ;dxax/cx -> ax частное, dx остаток
DIVrmmem16
       pop af ;skip
        GETm16
        jr DIVbc
DIVr16;cx
        GETr16
DIVbc
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
IDIVrmmem16
       pop af ;skip
        GETm16
        jr IDIVbc
IDIVr16;cx
        GETr16
IDIVbc
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

;BC = HLBC/DE, HL = HLBC%DE
DIV32SIGNED
	bit 7,h
	jr nz,DIV32SIGNED_NEGHLBC
	bit 7,d
	;jr nz,DIV32SIGNED_NEGDE
        jp z,DIV32
DIV32SIGNED_NEGDE
	xor a
	sub e
	ld e,a
	sbc a,d
	sub e
	ld d,a
	call DIV32
	xor a
	sub c
	ld c,a
	sbc a,b
	sub c
	ld b,a ;neg result
	ret
DIV32SIGNED_NEGHLBC
	xor a
	sub c
	ld c,a
	ld a,0
	sbc a,b
	ld b,a
	ld a,0
	sbc a,l
	ld l,a
	ld a,0
	sbc a,h
	ld h,a
	bit 7,d
	jr nz,DIV32SIGNED_NEGHLBC_NEGDE
	call DIV32
	xor a
	sub c
	ld c,a
	sbc a,b
	sub c
	ld b,a ;neg result
	xor a
	sub l
	ld l,a
	sbc a,h
	sub l
	ld h,a ;знак остатка равен знаку делимого
	ret	
DIV32SIGNED_NEGHLBC_NEGDE
	xor a
	sub e
	ld e,a
	sbc a,d
	sub e
	ld d,a
	call DIV32
	xor a
	sub l
	ld l,a
	sbc a,h
	sub l
	ld h,a ;знак остатка равен знаку делимого
	ret

;BC = HLBC/DE, HL = HLBC%DE
DIV32
	ld a,b
	call DIV32_8
	push af
	ld a,c
	call DIV32_8
	pop bc
	ld c,a
	ret
;A = HLA/DE, HL = HLA%DE
DIV32_8
	ld b,8
DIV321
	add a,a
	adc hl,hl
	jr c,DIV322
	sbc hl,de
	jr nc,DIV323
	add hl,de
	djnz DIV321
	ret
DIV322
	ccf
	sbc hl,de
DIV323
	inc a
	djnz DIV321
	ret
