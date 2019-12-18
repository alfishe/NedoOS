;------------Работа с картой (c #C000)
;align!!!
MPsign	;номера спрайтов для обычн уровней
	DEFB 60
	DEFS 6,18
	DEFS 10,24
	DEFS 13,18
	DEFB 84,36,84,84,36,84,84,36,84
	DEFS 3,96
	DEFS 3,30
	DEFS 3,96
	DEFS 3,18
	DEFB 18
	DEFS 9,42
	DEFS 3,48
	DEFS 14,54
	DEFB 18
	DEFB 78
	DEFS 14,66
	DEFS 14,72
	DEFB 78
	DEFS 2,66
	DEFS 2,72
	DEFS 5,42
	DEFS 2,42 ;?
	DEFB 84,90,96,102,108,114,120,126

;полезные данные в битах 7..5, но потом прокручиваются вправо и в следующий байт (MP_R2)
MP_IMG	DEFW #E0,#80,#80 ;00 люди
	DEFW #E0,#80,#A0 ;06 кунги
	DEFW #E0,#C0,#A0 ;12 пленник
	DEFW #E0,#E0,#E0 ;18 пусто
	DEFW #E0,#A0,#E0 ;24 дорожки
	DEFW #40,#40,#40 ;30 мост гор
	DEFW #00,#E0,#00 ;36 мост вер
water	DEFW #E0,#A0,#40 ;42 вода
	DEFW #C0,#80,#00 ;48 лес
	DEFW #A0,#40,#A0 ;54 забор
	DEFW #00,#40,#00 ;60 рамка
	DEFW #80,#40,#40 ;66 здания люди
	DEFW #40,#20,#40 ;72 здания кунги
	DEFW #00,#60,#00 ;78 строительство
	DEFW #A0,#A0,#A0 ;84 |
	DEFW #E0,#80,#A0 ;90 |~
	DEFW #E0,#00,#E0 ;96  ~
	DEFW #E0,#00,#C0 ;102 ~|
	DEFW #C0,#C0,#C0 ;108  |
	DEFW #C0,#C0,#00 ;114 _|
	DEFW #E0,#E0,#00 ;120 _
	DEFW #A0,#A0,#80 ;126|_
MP_LEN	EQU $-MP_IMG

mnt	EQU 72 ;горы
MPsig2	;номера спрайтов для подземелий
	DEFS 1,60
	DEFS 3,18
	DEFS 2,48
	DEFS 1,18
	DEFS 2,#0
	DEFS 33,24
	DEFS 10,#0
	DEFS 2,30
	DEFS 2,#0
	DEFS 1,42
	DEFS 2,mnt
	DEFS 2,54
	DEFS 1,30
	DEFS 1,#0
	DEFS 1,24
	DEFS 15,#0
	DEFS 9,54
	DEFS 1,60 ;внутр гор
	DEFS 14,mnt
	DEFS 10,60
	DEFS 1,42
	DEFS 2,mnt
	DEFS 2,54


MPswap	;сменить нумерацию спрайтов для подземелий
	LD A,(LEV_T)
	OR A
	RET Z
	LD HL,MPsign
	LD DE,MPsig2
	LD B,118
MPsw0	LD A,(DE)
	LD C,(HL)
	LD (HL),A
	LD A,C
	LD (DE),A
	INC L
	INC E
	DJNZ MPsw0
	RET

MP_ANI	LD A,(isANI)
	OR A
	RET Z
	LD DE,water
	LD HL,water+2
	LD A,(DE)
	LDI
	LDI
	LDI
	INC DE
	LD (DE),A
	LD HL,MP_IMG+10
	CALL MP_an
	LD HL,MP_IMG+14
	CALL MP_an
	INC HL
	INC HL
MP_an	LD A,(HL)
	XOR #60
	LD (HL),A
	RET
        
        if EGA==0

MP_R1	PUSH HL
	LD HL,MP_IMG
	LD B,MP_LEN/2
mp01	SRL (HL)
	INC HL
	INC HL
	DJNZ mp01
	POP HL
	RET

MP_R2	PUSH HL
	LD HL,MP_IMG
	LD B,MP_LEN/2
mp02	SRL (HL)
	INC HL
	RR (HL)
	INC HL
	DJNZ mp02
	POP HL
	RET
        
        endif

MP_OU1	;HL -адр экр
;вывод столбца карты, если сдвинутое значение умещается в байт
	LD C,64
mp03	CALL MP_SPA ;->de адр спр
	JR Z,mp041
        if EGA
        push bc
        call setpgsscr40008000
        pop bc
        endif
	LD B,3
mp05
        if EGA
        push bc
        push de
        push hl
        ld a,(de)
        ld e,a
        xor a
        rl e
        jr nc,$+4
        or 0x47 ;L
        rl e
        jr nc,$+4
        or 0xb8 ;R
	XOR (HL)
	LD (HL),A	
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,MP_OU1column_noxor ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
MP_OU1column_noxor       
        rl e
        jr nc,$+2+4
         ld a,0x47 ;L
	 XOR (HL)
	 LD (HL),A
        pop hl
        pop de
        pop bc
        inc de
        inc de
                
        else ;~EGA
        
	LD A,(DE)
	XOR (HL)
	LD (HL),A
	INC DE
	INC DE
        endif
        
        if EGA
        ld a,l
        add a,40
        ld l,a
        jr nc,$+3
        inc h
        else
	INC H
	LD A,H
	AND 7
	JR NZ,mp04
	LD A,L
	ADD A,32
	LD L,A
	JR C,mp04
	LD A,H
	SUB 8
	LD H,A
mp04
        endif
	DJNZ mp05
        if EGA
        push bc
        call setpgsmain40008000
        pop bc
        endif
mp041	DEC C
	JR NZ,mp03
	RET

MP_OU2	;HL -адр экр
;вывод столбца карты
	LD C,64
mp43	CALL MP_SPA ;->de адр спр
	JR Z,mp441
        if EGA
        push bc
        call setpgsscr40008000
        pop bc
        endif
	LD B,3
mp45
        if EGA
        push bc
        push de
        push hl
        ld a,(de)
        add a,a
        ld e,a
        jr nc,$+2+4
         ld a,0xb8 ;R
	 XOR (HL)
	 LD (HL),A	
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,MP_OU2column_noxor ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
MP_OU2column_noxor       
        xor a
        rl e
        jr nc,$+4
        or 0x47 ;L
        rl e
        jr nc,$+4
        or 0xb8 ;R
	XOR (HL)
	LD (HL),A
        pop hl
        pop de
        pop bc
        inc de
        inc de
        
        else ;~EGA
        
	LD A,(DE)
	XOR (HL)
	LD (HL),A
	INC DE
        if EGA
        inc hl
        else
	INC L
        endif
	LD A,(DE)
	XOR (HL)
	LD (HL),A
        if EGA
        dec hl
        else
	DEC L
        endif
	INC DE
        
        endif
        
        if EGA
        ld a,l
        add a,40
        ld l,a
        jr nc,$+3
        inc h
        else
	INC H
	LD A,H
	AND 7
	JR NZ,mp44
	LD A,L
	ADD A,32
	LD L,A
	JR C,mp44
	LD A,H
	SUB 8
	LD H,A
mp44
        endif
	DJNZ mp45
        if EGA
        push bc
        call setpgsmain40008000
        pop bc
        endif
mp441	DEC C
	JR NZ,mp43
	RET

        if EGA
MP_OU32_64
	LD (MP_sub+1),bc
	LD B,32
MP_OUT0
	push bc
	PUSH HL
	PUSH DE
	CALL MP_SET
MP_sub	CALL MP_OU1
	POP DE
	POP HL
        ld bc,0x4000
        ld lx,3
MP_OUT0_3
        ld a,0x9f;0xa0
        cp h
        adc hl,bc
        jp pe,MP_OUT0_noxor ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
MP_OUT0_noxor
        dec lx
        jr nz,MP_OUT0_3
        pop bc
        inc e
        inc e
	DJNZ MP_OUT0
	RET
        
        else ;~EGA

MP_OU8	PUSH HL
	PUSH DE
	LD B,8
mp11	PUSH BC
	PUSH HL
	PUSH DE
	CALL MP_SET
MP_sub	CALL MP_OU1
	POP DE
	POP HL
	POP BC
        if EGA
        inc hl
        inc hl
        inc hl
        else
	INC L
	INC L
	INC L
        endif
	LD A,E
	ADD A,8
	LD E,A
	DJNZ mp11
	POP DE
	POP HL
	RET
        
        endif

MP_OUT
	CALL MPswap
	CALL MP_OFF ;очистка
	CALL MP_ANI
        
        if EGA
;00 01 11 22|23 33 44 45|55 66 67 77|
        ;jr $
	LD bc,MP_OU1
        ld hl,scrbase;0x4000
	LD DE,MAP
	CALL MP_OU32_64
	LD bc,MP_OU2
        ld hl,scrbase+0x4000;0x8000
	LD DE,MAP+1
	CALL MP_OU32_64
	JP MPswap
        
        else ;~EGA
        
	LD HL,DSCR
	LD DE,MAP
	LD B,6
mp19	PUSH BC
	CALL MP_OU8
        if EGA
        inc hl
        else
	INC L
        endif
	INC E
	INC E
	INC E
	POP BC
	PUSH BC
	LD A,B
	CP 1
	PUSH AF
	CALL NZ,MP_R1
	POP AF
	CALL Z,MP_R2
	POP BC
	LD A,B
	CP 4
	JR Z,mp17
	CP 1
	JR NZ,mp18
mp17
        if EGA
        dec hl
        dec hl
        dec hl
        else
	DEC L
	DEC L
	DEC L
        endif
	LD A,E
	SUB 8
	LD E,A
mp18	DJNZ mp19
	LD BC,MP_OU2
	LD (MP_sub+1),BC
	CALL MP_OU8
	CALL MP_R2
        if EGA
        inc hl
        else
	INC L
        endif
	INC E
	INC E
	INC E
	CALL MP_OU8
	CALL MP_R2
	LD HL,MP_OU1
	LD (MP_sub+1),HL
;MP_Re
	LD HL,MP_IMG+1
	LD DE,MP_IMG
	LD BC,MP_LEN-1
	LDIR
	XOR A
	LD (DE),A
	JP MPswap
        
        endif


MP_SET	;уст.на карту (DE-адрес)
	PUSH DE
	EXX
	POP HL
	LD BC,64
	EXX
	RET


MP_SPA	EXX	;Z-невид; NZ-видим ;->DE adr
	LD A,(HL)
	RLCA
	JR C,mpsN
	SET 4,H ;MAP->MAP2
	LD A,(HL)
	RES 4,H
	CP #80
	JR NC,mpHE
	LD A,(HL)
	ADD HL,BC
	EXX
	LD D,#C0
	LD E,A
	LD A,(DE)
	ADD A,#80
	LD E,A
	RET
mpHE	;герои
	ADD HL,BC
	CP #B0
	JR NC,mpH1
	EXX
	LD DE,MP_IMG
	RET
mpH1	CP #E0
	JR NC,mpH2
	EXX
	LD DE,MP_IMG+6
	RET
mpH2	EXX
	LD DE,MP_IMG+12
	AND A
	RET
mpsN	ADD HL,BC ;невидим поле
	EXX
        if EGA
        ld a,l
        add a,40*3
        ld l,a
        jr nc,$+3
        inc h
        else
	LD A,H
	ADD A,3
	LD H,A
	AND 7
	CP 3
	JR NC,mps4
	LD A,L
	ADD A,32
	LD L,A
	JR C,mps4
	LD A,H
	SUB 8
	LD H,A
mps4
        endif
	XOR A
	RET

        display $,"<=0xc300"
