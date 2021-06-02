MOVrm8i8
	get
	next
;a=MD000R/M: mov r/m,i8
;MD=00: mov [...],i8
;MD=01: mov [...+disp8],i8 ;TODO
;MD=10: mov [...+disp16],i8 ;TODO
;MD=11: mov r/m,i8 ;проще всего, но не имеет смысла (есть короткий код)
	cp %00000101
	jp z,MOVmDIBYTE
	jp $;PANIC

GRP416
;FF MOD01fRM disp16 = CALLrm+... /f - межсегментный/, так же можно PUSHrm+..., INCrm+... ;FF 25 = jmp word [di]
	get
	next
	cp %00100101
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
	cp %00111100
	jp z,CMPmSIBYTE
	jp $;PANIC

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
       ld c,a
       and %11111000
	cp %11111000;100
	jp z,CMPr16i16;CMPspi16
	jp $;PANIC

GRP316
;mul,div,test,not,neg
	get
	next
;a=MD000R/M: test r/m,i16? ;TODO
;a=MD001R/M: ?
;a=MD010R/M: not r/m? ;TODO
;a=MD011R/M: neg r/m?
;a=MD100R/M: mul ax,r/m
;a=MD101R/M: imul ax,r/m
;a=MD110R/M: div ax,r/m
;a=MD111R/M: idiv ax,r/m
;MD=00: cmd [...],r16 ;TODO
;MD=01: cmd [...+disp8],r16 ;TODO
;MD=10: cmd [...+disp16],r16 ;TODO
;MD=11: cmd r/m,r16 ;проще всего
       ld c,a
       and %11111000
	cp %11011000
	jp z,NEGr16;ax
	cp %11100000;1
	jp z,MULr16;cx
	cp %11101000;1
	jp z,IMULr16;cx
	cp %11110000;1
	jp z,DIVr16;cx
	cp %11111000;1
	jp z,IDIVr16;cx
	jp $;PANIC

getr16
        ;exx
        ;ld (_AX),hl
        ;exx
        ld a,c
        and 7
       ;cp 4
       ;jr z,getr16sp
        add a,a
        ld l,a
        ld h,_AX/256
        ld c,(hl)
        inc l
        ld b,(hl)
        ret
getr16sp
        decodeSP
        ret

putr16
;hl is kept since getr16
;TODO sp!!!
        ld (hl),b
        dec l
        ld (hl),c
        ret ;nz
;ax!
        ;exx
        ;ld hl,(_AX)
        ;exx
        ;ret

MOVrmr8
	get
	next
;a=MDregR/M
;MD=00: mov [...],r8 ;TODO
;MD=01: mov [...+disp8],r8 ;TODO
;MD=10: mov [...+disp16],r8 ;TODO
;MD=11: mov r/m,r8 ;проще всего
	jp $;PANIC
MOVrmr16
	get
	next
;a=MDregR/M
;MD=00: mov [...],r16 ;TODO
;MD=01: mov [...+disp8],r16 ;TODO
;MD=10: mov [...+disp16],r16 ;TODO
;MD=11: mov r/m,r16 ;проще всего
	jp $;PANIC
MOVr8rm
	get
	next
;a=MDregR/M
;MD=00: mov r8,[...] ;TODO
;MD=01: mov r8,[...+disp8] ;TODO
;MD=10: mov r8,[...+disp16] ;TODO
;MD=11: mov r8,r/m ;проще всего
	cp %00000101
	jp z,MOVALmDI
	jp $;PANIC
MOVr16rm
	get
	next
;a=MDregR/M
;MD=00: mov r16,[...] ;TODO
;MD=01: mov r16,[...+disp8] ;TODO
;MD=10: mov r16,[...+disp16] ;TODO
;MD=11: mov r16,r/m ;проще всего
	cp %00000111
	jp z,MOVAXmBX
	jp $;PANIC
MOVrm16sreg
	jp $;PANIC

ADCrmr8
ADCrmr16
ADCr8rm
ADCr16rm
ADCali8
ADCaxi16
SBBrmr8
SBBrmr16
SBBr8rm
SBBr16rm
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
;MD=00: cmd [...],r8 ;TODO
;MD=01: cmd [...+disp8],r8 ;TODO
;MD=10: cmd [...+disp16],r8 ;TODO
;MD=11: cmd r/m,r8 ;проще всего
	cp %11000000
	jp z,ADDalal
	;cp %11100100
	;jp z,ADDahah
	jp $;PANIC

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

CMPr8rm
XORr8rm
ORr8rm
ANDr8rm
SUBr8rm
ADDr8rm
	get
	next
;a=MDregR/M
;MD=00: cmd r8,[...] ;TODO
;MD=01: cmd r8,[...+disp8] ;TODO
;MD=10: cmd r8,[...+disp16] ;TODO
;MD=11: cmd r8,r/m ;проще всего
	cp %11000000
	jp z,ADDalal
	;cp %11100100
	;jp z,ADDahah
	jp $;PANIC

CMPr16rm
XORr16rm
ORr16rm
ANDr16rm
SUBr16rm
ADDr16rm
	get
	next
;a=MDregR/M
;MD=00: cmd r16,[...] ;TODO
;MD=01: cmd r16,[...+disp8] ;TODO
;MD=10: cmd r16,[...+disp16] ;TODO
;MD=11: cmd r16,r/m ;проще всего
	cp %11111001
	jp z,ADDdicx
	cp %11011000
	jp z,ADDbxax
	jp $;PANIC

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

;cmp byte [si],n
CMPmSIBYTE
	get
	next
	ld (CMPmSIBYTE_n),a
	ld hl,(_SI)
	ex af,af'
	getmemDS
CMPmSIBYTE_n=$+1
	cp 0
	ex af,af'
       _LoopC

;add di,cx
ADDdicx
	ld hl,(_DI)
	ld bc,(_CX)
	ex af,af'
	or a
	adc hl,bc ;TODO overflow
	ex af,af'
	ld (_DI),hl
       _Loop_

;add bx,ax
ADDbxax
        ld bc,(_AX)
	ld hl,(_BX)
	ex af,af'
	or a
	adc hl,bc ;TODO overflow
	ex af,af'
	ld (_BX),hl
       _Loop_

;add ax,cx
ADDaxcx
        ld hl,(_AX)
	ld bc,(_CX)
	or a
	adc hl,bc ;TODO overflow
	ex af,af' ;'
        ld (_AX),hl
       _Loop_

;neg ax
;The CF flag set to 0 if the source operand is 0; otherwise it is set to 1. The OF, SF, ZF, AF, and PF flags are set according to the result
NEGr16
        call getr16
        push bc
	exx
        pop bc
        
	xor a
	ld h,a
	ld l,a
	sbc hl,bc
        
        push hl
        
	ld a,h
	rra
	ld e,a ;overflow data
	rla ;restore CF
	ex af,af' ;'
        ld a,h
        xor l
	ld d,a ;parity data
	exx
        pop bc
        call putr16
       _Loop_

;add ax,nn
ADDaxi16
	getBC
        ld hl,(_AX)
	or a
	adc hl,bc
	ld a,h
	rra
	exx
	ld e,a ;overflow data
	exx
	rla ;restore CF
	ex af,af' ;'
        ld a,h
        xor l
	exx
	ld d,a ;parity data
	exx
        ld (_AX),hl
       _Loop_

;add al,al
ADDalal
        ld hl,_AL
        ld a,(hl);l
        add a,a
        ld (hl),a
        exx
	KEEPPARITYOVERFLOW
        exx
	ex af,af' ;'
       _Loop_

;add al,n
ADDali8
	get
	next
        ld hl,_AL
        add a,(hl)
        ld (hl),a
        exx
	KEEPPARITYOVERFLOW
	exx
	ex af,af' ;'
       _Loop_

;add al,n
SUBali8
	get
	next
	ld c,a
        ld hl,_AL
        ld a,(hl)
	sub c
	ld (hl),a
        exx
	KEEPPARITYOVERFLOW
	exx
	ex af,af' ;'
       _Loop_

;cmp al,n
CMPali8
	get
	next
	ld c,a
        ld a,(_AL)
	cmpc
	ex af,af' ;'
       _Loop_

SUBaxi16
	getBC
        ld hl,(_AX)
        or a
        sbc hl,bc
        ld a,h
        rra
        exx
	ld e,a ;overflow data
        exx
        rla ;restore CF
	ex af,af' ;'
        ld a,h
        xor l
        exx
	ld d,a ;parity data
	exx
        ld (_AX),hl
       _Loop_

CMPaxi16
	getBC
        ld hl,(_AX)
        or a
        sbc hl,bc
        ld a,h
        rra
        exx
	ld e,a ;overflow data
        exx
        rla ;restore CF
	ex af,af' ;'
        ld a,h
        xor l
        exx
	ld d,a ;parity data
	exx
       _Loop_

       if 0
	macro CMPRP rp
	getBC
	ld hl,(rp)
	ld d,h
	ld e,l
	or a
	sbc hl,bc
	ex de,hl ;keep hl=ax
	exx
	KEEPPARITYOVERFLOW
	exx
	ex af,af' ;'
       _Loop_
	endm
CMPcxi16
	CMPRP _CX
CMPdxi16
	CMPRP _DX
CMPbxi16
	CMPRP _BX
       endif
CMPr16i16
       ;decodeSP ;->bc
       call getr16
	ld h,b
	ld l,c
	getBC
	or a
	sbc hl,bc
	exx
	KEEPPARITYOVERFLOW
	exx
	ex af,af' ;'
       _Loop_

;mul cx ;ax*cx -> dxax (set OF,CF if result >=65536)
MULr16;cx
       call getr16
       push de
	ld de,(_AX);ex de,hl ;de=ax
	;ld bc,(_CX)
	call MUL16 ;HLDE=DE*BC
	ld (_DX),hl
	;ex de,hl ;hl=ax
        ld (_AX),de
	ld a,h
	or l ;0?
	add a,255 ;set CF if result >=65536
	sbc a,a ;keep CF
	srl a ;keep CF
        exx
	ld e,a ;overflow (d7 != d6) if CF
	ex af,af' ;'
	exx
       pop de
       _Loop_

;imul cx ;ax*cx -> dxax signed (set OF,CF if result >=32768 or < -32768)
IMULr16;cx
       call getr16
       push de
	ld de,(_AX);ex de,hl ;de=ax
	;ld bc,(_CX)
	call MUL16SIGNED ;HLDE=DE*BC
	ld (_DX),hl
	;ex de,hl ;hl=ax
        ld (_AX),de
	ld a,d
	rla ;ax sign
	jr c,IMULCX_NEG
	ld a,h
	or l
	add a,255 ;set CF if ax sign != dx (result >=32768 or < -32768)
	jp IMULCX_NEGQ
IMULCX_NEG
	ld a,h
	and l
	sub 255 ;set CF if ax sign != dx (result >=32768 or < -32768)
IMULCX_NEGQ
	sbc a,a ;keep CF
	srl a ;keep CF
        exx
	ld e,a ;overflow (d7 != d6) if CF
	ex af,af' ;'
	exx
       pop de
       _Loop_

;HLDE=DE*BC
MUL16SIGNED
	bit 7,d
	jr nz,MUL16SIGNED_NEGDE
	bit 7,b
	;jr nz,MUL16SIGNED_NEGBC
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
	;jp MUL16
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
DIVr16;cx
       call getr16
       push de
        ld d,b
        ld e,c
	ld bc,(_AX)
	ld hl,(_DX)
	;ld de,(_CX)
	call DIV32 ;BC = HLBC/DE, HL = HLBC%DE
	ld (_DX),hl
        ld (_AX),bc
       pop de
       _Loop_

;idiv cx ;dxax/cx -> ax частное, dx остаток signed (знак остатка равен знаку делимого)
IDIVr16;cx
       call getr16
       push de
        ld d,b
        ld e,c
	ld bc,(_AX)
	ld hl,(_DX)
	;ld de,(_CX)
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
	jr c, DIV322
	sbc hl,de
	jr nc, DIV323
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
