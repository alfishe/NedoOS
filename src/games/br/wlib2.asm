;-----------Вывод спрайтов героев
        if EGA==0
t7tab	DEFB 23,#20 ;[**]
	DEFB 11,#21
	DEFB 12,#60
	DEFB 13,#40  ;		 LD HL,#4060
	DEFB 24,#F8    ;	   JR NZ,tst70
	DEFB 25,#21
	DEFB 18,#23	 ;	     INC HL
	DEFB 19,#0D	 ;	     DEC C
	DEFB 29,#C9	;	RET
	DEFB 20,#20
	DEFB 21,#FB    ;	   JR NZ,tst70
	DEFB 26,#FE
	DEFB 15,#00
	DEFB 16,#35  ;		 LD BC,#3500
	DEFB 17,#AE	 ;   tst70   XOR (HL)
	DEFB 28,#BE	 ;	     CP (HL)
	DEFB 22,#05	 ;	     DEC B
	DEFB 27,#FF  ;		 LD HL,#FFFE
	DEFB 14,#01
	DEFB 0

;старшие байты адресов (к ним прибавляется (направление*2 + шаг)*64)
AT_HER	DEFB #C0,#C6,#CA,#CE,#D2
	DEFB #D8,#DE,#E4,#F1
	DEFB #C4,#CA,#D0,#D6,#DC,#DC

;старшие байты адресов фазы удара (к ним прибавляется (направление)*64)
AT_WAR	DEFB #C4,#C4,#C4,#00,#D6
	DEFB #DC,#E2,#ED,#FA
	DEFB #C8,#CE,#D4,#DA,#00,#00
        endif

        if EGA
theropg
;pg,shift in pg
        db 8,0 ;0=крестьянин
        db 8,24 ;1=крестьянин с дровами?
        db 8,24+16 ;2=крестьянин с мешком?
        db 9,0 ;3=лучник
        db 9,16 ;4=мечник
        db 10,0 ;5=священник
        db 10,24 ;6=волшебник
        db 11,0 ;7=катапульта
        db 12,0 ;8=всадник

        db 13,0 ;9=пеон
        db 13,24 ;10=пеон с дровами?
        db 13,24+16 ;11=пеон с мешком?
        db 14,0 ;12=лангольер
        db 14,16 ;13=кунг
        db 15,0 ;14=некромант
        db 15,24 ;15=варлок
        db 16,0 ;16=катапульта на гусеницах
        db 17,0 ;17=грюнвер

        db 18,0 ;18=паук
        db 18,24 ;19=скелет
        db 19,0 ;20=скорпион
        db 19,24 ;21=звезда
        db 20,0 ;22=князь
        db 20,16 ;23=гризольда
        db 21,0 ;24=костолом
        db 22,0 ;25=демон
        db 23,0 ;26=стеногрыз
        
;tbodypg ;все 16 рисунков в pg 24
;pg,shift in pg

;0..3=человек (меньше=дохлее)
;4..7=кунг (меньше=дохлее)
;8..10=шарик (меньше=дохлее)
;11=звезда
;12=мокрое место
;13=паук
;14=скорпион
;15=скелет
;(>=17 используется для трупа катапульты)
        
        endif

;для рамки
;в зависимости от полного ID
;0: 16x16, 1: 24x24, 2: 24x16
AT_TY_	DEFB 0,0,0,0,0, 0,0,1,1
;далее продолжение в AT_TYP
;для героя
;в зависимости от ID (для кунгов вычитается 9)
;0: 16x16, 1: 24x24, 2: 24x16
AT_TYP	DEFB 0,0,0,0,0, 0,0,1,1
	DEFB 0,0,0,0,0,0, 2,2,2
;0=крестьянин
;1=крестьянин с дровами?
;2=крестьянин с мешком?
;3=лучник
;4=мечник
;5=священник
;6=волшебник
;7=катапульта
;8=всадник

;9=пеон
;10=пеон с дровами?
;11=пеон с мешком?
;12=лангольер
;13=кунг
;14=некромант
;15=варлок
;16=катапульта на гусеницах
;17=грюнвер

;18=паук
;19=скелет
;20=скорпион
;21=звезда
;22=князь
;23=гризольда
;24=костолом
;25=демон
;26=стеногрыз

;виды трупов:
;0..3=человек (меньше=дохлее)
;4..7=кунг (меньше=дохлее)
;8..10=шарик (меньше=дохлее)
;11=звезда
;12=мокрое место
;13=паук
;14=скорпион
;15=скелет
;(>=17 используется для трупа катапульты)

XY0pos	LD A,(X0) ;выч смещ _X0pos в пикс
	CALL _xy0
	LD (_X0pos),HL
	LD A,(Y0)
	CALL _xy0
	LD (_Y0pos),HL
	RET
_xy0	LD L,A
	LD H,0
	LD D,H
	LD E,H
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	EX DE,HL
	XOR A
	SBC HL,DE
	RET

        if EGA==0
;*M+
        macro HENs lbl
	POP DE
	DJNZ $+5
	JP SET_SP
	INC H
	LD A,H
	AND 7
	JP NZ,lbl
	LD A,L
	ADD A,32
	LD L,A
	JR C,lbl
	LD A,H
	SUB 8
	LD H,A
	JR lbl
	ENDM

HE_N	DEFW HE0,HE1,HE2,HE3,HE4,HE5,HE6,HE7
HE_L	DEFW SET_SP,HE1L,HE2L,HE3L,HE4L,HE5L,HE6L,HE7L

;HE0L	EQU SET_SP

HE0	LD A,(HL)
	OR E
	XOR D
	LD (HL),A
	HENs HE0

HE1	LD A,E
	RRCA
	LD C,A
	AND #7F
	OR (HL)
	LD (HL),A
	LD A,C
	AND #80
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	LD C,A
	AND #80
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #7F
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE1


HE2	LD A,E
	RRCA
	RRCA
	LD C,A
	AND #3F
	OR (HL)
	LD (HL),A
	LD A,C
	AND #C0
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	RRCA
	LD C,A
	AND #C0
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #3F
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE2

HE3	LD A,E
	RRCA
	RRCA
	RRCA
	LD C,A
	AND #1F
	OR (HL)
	LD (HL),A
	LD A,C
	AND #E0
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	RRCA
	RRCA
	LD C,A
	AND #E0
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #1F
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE3

HE4	LD A,E
	RRCA
	RRCA
	RRCA
	RRCA
	LD C,A
	AND #F
	OR (HL)
	LD (HL),A
	LD A,C
	AND #F0
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	RRCA
	RRCA
	RRCA
	LD C,A
	AND #F0
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #F
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE4

HE5	LD A,E
	RLCA
	RLCA
	RLCA
	LD C,A
	AND #7
	OR (HL)
	LD (HL),A
	LD A,C
	AND #F8
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RLCA
	RLCA
	RLCA
	LD C,A
	AND #F8
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #7
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE5

HE6	LD A,E
	RLCA
	RLCA
	LD C,A
	AND #3
	OR (HL)
	LD (HL),A
	LD A,C
	AND #FC
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RLCA
	RLCA
	LD C,A
	AND #FC
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #3
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE6

HE7	LD A,E
	RLCA
	LD C,A
	AND #1
	OR (HL)
	LD (HL),A
	LD A,C
	AND #FE
	INC L
	OR (HL)
	LD (HL),A
	LD A,D
	RLCA
	LD C,A
	AND #FE
	XOR (HL)
	LD (HL),A
	LD A,C
	AND #1
	DEC L
	XOR (HL)
	LD (HL),A
	HENs HE7

HE1L	LD A,E
	RRCA
	AND #80
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	AND #80
	XOR (HL)
	LD (HL),A
	HENs HE1L

HE2L	LD A,E
	RRCA
	RRCA
	AND #C0
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	RRCA
	AND #C0
	XOR (HL)
	LD (HL),A
	HENs HE2L

HE3L	LD A,E
	RRCA
	RRCA
	RRCA
	AND #E0
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	RRCA
	RRCA
	AND #E0
	XOR (HL)
	LD (HL),A
	HENs HE3L

HE4L	LD A,E
	RRCA
	RRCA
	RRCA
	RRCA
	AND #F0
	OR (HL)
	LD (HL),A
	LD A,D
	RRCA
	RRCA
	RRCA
	RRCA
	AND #F0
	XOR (HL)
	LD (HL),A
	HENs HE4L

HE5L	LD A,E
	RLCA
	RLCA
	RLCA
	AND #F8
	OR (HL)
	LD (HL),A
	LD A,D
	RLCA
	RLCA
	RLCA
	AND #F8
	XOR (HL)
	LD (HL),A
	HENs HE5L

HE6L	LD A,E
	RLCA
	RLCA
	AND #FC
	OR (HL)
	LD (HL),A
	LD A,D
	RLCA
	RLCA
	AND #FC
	XOR (HL)
	LD (HL),A
	HENs HE6L

HE7L	LD A,E
	RLCA
	AND #FE
	OR (HL)
	LD (HL),A
	LD A,D
	RLCA
	AND #FE
	XOR (HL)
	LD (HL),A
	HENs HE7L
        
        endif ;~EGA

BCOORD	LD	A,D ;de(0-191,0-31) -- hl
	RRCA
	RRCA
	RRCA
	AND	%00011000
	LD	H,A
	LD	A,D
	AND	%00000111
	ADD	A,H
	ADD	A,DSCR/256
	LD	H,A
	LD	A,D
	RLA
	RLA
	AND	%11100000
	OR	E
	LD	L,A
	RET

XPUT	;формированиe вывода для героя IX
;IY=блок координат героя
	XOR A
_XPUT	EX AF,AF ;Z-герой, NZ-(A=1:рамка/A>1:снаряд)
	LD L,(IY+2) ;получение Xh Yh SHIFTh
	LD H,(IY+3) ;Ypos
	LD DE,(_Y0pos)
	ADD HL,DE
	LD A,H
	OR A
	RET NZ
	LD A,L
	CP 192+32;24
	RET NC
	LD (Yh),A
	LD L,(IY+0)
	LD H,(IY+1) ;Xpos
	LD DE,(_X0pos)
	ADD HL,DE
	LD A,H
	OR A
	JR NZ,UT3
	LD A,L
	CP 192
	RET NC
	LD L,A
	SRL L
	JR UT2
UT3	INC A
	RET NZ
	LD A,L
	CP 192+32;40
	RET C
	LD L,A
	SRA L
UT2	AND 7
	LD (SHIFTh),A
	SRA L
	SRA L
	LD A,L
	JP M,UT21
	CP 24
	RET NC
	JR UT22
UT21	CP -8
	RET C
UT22	LD (Xh),A
	;получть Wh,Hh,IMGh, выбрать страницу
        
        if EGA

	EX AF,AF
	JR Z,WY_0 ;героя, а не рамка/снаряд
	;для рамки
	DEC A
	JP NZ,WYbull;->обр снарядов ;заполняет данные и переходит на HeF1
	CALL MEM1
	LD A,(IX+4) ;ID (0..26)
	LD HL,AT_TY_
	CALL BA ;hl+=a: A=(HL)
	DEC A
	JR Z,WYr33
	;LD BC,#1002 ;HhWh
	;LD DE,fr2x2h
	ld iy,fr2x2h;testspr+4
        ;ld bc,0x1002 ;HhWh
	JR WYr
WYr33	;LD BC,#1803 ;HhWh
	;LD DE,fr3x3h
	ld iy,fr3x3h;testspr+4
        ;ld bc,0x1803 ;HhWh
WYr	JP HeF1
WY_0	
        LD A,(IX+0) ;x героя (0=труп)
	OR A
	LD A,(IX+4) ;ID (0..26)
	JR NZ,WY2
	;для трупа a=вид трупа
         add a,24
        add a,a
        ld (WYbody_where),a
         ld a,23;24
        call _128
WYbody_where=$+2 ;LSB
        ld iy,(0xc000)
	JP HeF1
	;
WY2	;для героя
        ;ld a,24;8

        ld hl,theropg ;pg, shift in pg
        add a,a
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld a,(hl)
        call _128
        inc hl

	LD D,(IX+2) ;направление (0..7)
	LD A,(IX+3) ;фаза (=0 - целиком в квадрате) ;или (%1ibttttt, где i-удар b-назад ttttt-задержка) ;или (%10000xxx, где ххх-ожидание свободного прохода)
	CP #80
	JR C,H221 ;не бьёт
	CP #A0
	LD A,0
	JR C,H221 ;не фаза удара
	LD A,D ;направление (0..7)
        add a,16
	JR H222
H221	
	AND 1 ;шаг0 или шаг1
	ADD A,D
	ADD A,D ;a=направление*2 + шаг
H222
        add a,(hl) ;ahift in pg
        add a,a
        ld (H222_where),a

	;ld iy,testspr+4
         ;jr $
H222_where=$+2 ;LSB
        ld iy,(0xc000)
        ;ld bc,0x1002 ;HhWh

        else
;	--------------------
	EX AF,AF
	JR Z,WY_0 ;героя, а не рамка/снаряд
	;для рамки
	DEC A
      if EGA==0
	JP NZ,WYbull;->обр снарядов
      endif
	CALL MEM1
	LD A,(IX+4) ;ID (0..26)
	LD HL,AT_TY_
	CALL BA ;hl+=a: A=(HL)
	DEC A
	JR Z,WYr33
	LD BC,#1002 ;HhWh
	LD DE,fr2x2h
	JR WYr
WYr33	LD BC,#1803 ;HhWh
	LD DE,fr3x3h
WYr	JP HeF1
WY_0	LD A,(IX+0) ;x героя (0=труп)
	OR A
	LD A,(IX+4) ;ID (0..26)
	JR NZ,WY2
	;для трупа a=вид трупа
	CP 17
	JR C,WYTr
	CALL MEM6 ;труп катап
	LD DE,WMISC3 ;gfxdata трупа катапульты
	LD BC,#1803 ;HhWh
	JP HeF1
WYTr	ADD A,A
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL ;вид трупа*64
	LD DE,WMISC2
	ADD HL,DE
	EX DE,HL ;gfxdata
	CALL MEM1
	LD BC,#1002 ;HhWh
	JP HeF1
	;
WY2	;для героя
	LD E,A ;ID (0..26)
	SUB 9
	JR NC,WY1
        if 1==0
	LD A,4 ;люди
        else
        call MEM_humans
        endif
	JR WY0
WY1	LD E,A ;ID - 9 (0..17)
	CP 9
	JR C,WY04
	CP 16
        if 1==0
	LD A,6 ;креат 18-24
	JR C,WY0
	XOR A	;креат 25-26
	JR WY0
        else
        jr c,WY_MEM_char0
        call MEM_char1 ;креат 25-26
	JR WY0
WY_MEM_char0
        call MEM_char0 ;креат 18-24
	JR WY0
        endif
WY04	
        if 1==0
        LD A,3	;кунги
        else
        call MEM_kungs
        endif
WY0	
        if 1==0
        CALL MEM ;page
        endif
	LD A,E ;ID (0..26)
	LD HL,AT_TYP
	CALL BA ;hl+=a: A=(HL)
	CP 1
	LD D,(IX+2) ;направление (0..7)
	LD A,(IX+3) ;фаза (=0 - целиком в квадрате) ;или (%1ibttttt, где i-удар b-назад ttttt-задержка) ;или (%10000xxx, где ххх-ожидание свободного прохода)
	JR Z,H3x3
	JP NC,H3x2
H2x2	CP #80
	JR C,H221 ;не бьёт
	CP #A0
	LD A,0
	JR C,H221 ;не фаза удара
	LD A,D ;направление (0..7)
	LD BC,AT_WAR
	JR H222
H221	LD BC,AT_HER
	AND 1 ;шаг0 или шаг1
	ADD A,D
	ADD A,D ;a=направление*2 + шаг
H222	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL ;*64
	LD A,E ;ID
	EX DE,HL
	LD L,C
	LD H,B
	LD BC,#1002 ;HhWw
H225	CALL BA
	LD H,A
	LD L,0
	ADD HL,DE
	EX DE,HL
	JR HeF1
	;
	;H3x2 - в WLIB2x3
	;
H3x3	CP #80
	JR C,H331 ;не бьёт
	CP #A0
	LD A,0
	JR C,H331 ;не фаза удара
	LD BC,#ED00 ;gfxdata
	LD A,D ;направление
	JR H332
H331	LD BC,#E400 ;gfxdata
	AND 1 ;шаг0 или шаг1
	ADD A,D
	ADD A,D
	LD D,A ;направление*2 + шаг
H332	ADD A,A
	ADD A,D
	LD D,A
	ADD A,A
	ADD A,D
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL ;*144
	ADD HL,BC ;+gfxdata
	LD BC,#1803 ;HhWh
	LD A,E ;ID
	CP 7
	JR Z,H333 ;катапульта на колёсах
	LD DE,#D80
	ADD HL,DE ;катапульта на гусеницах
H333	EX DE,HL
        endif ;~EGA
;	--------------------
HeF1	;корректировка ширины,длины и др. по границам окна
        if EGA
        ld c,(iy-4) ;Wh
        srl c
        srl c
        ld b,(iy-3) ;Hh
        endif

;YhXh (Xh в знакоместах)
;SHIFTh = 0..7 (xlow)
;bc=HhWh (Wh в знакоместах)
;de=gfxdata
	LD (Wh),BC
	LD HL,(Xh)
	LD A,H
	SUB B
	LD (Yh),A
        
        if EGA==0
        
	LD A,L
	CP 24
	JR NC,eF3
	SUB 24
	NEG
	CP C
	JR NC,eF4
	LD C,A
	JR eF4
eF3	INC A
	LD L,A
	ADD A,C
	 RET M
	 RET Z
	LD C,A
	LD A,-1
	LD (Xh),A
	LD A,L
	NEG
	LD L,A
	JR Z,eF4
	XOR A
eF5	ADD A,B
	ADD A,B
	DEC L
	JR NZ,eF5
	ADD A,E
	LD E,A
	JR NC,eF4
	INC D
eF4	
        LD A,(Yh)
	CP 192
	JR NC,eF1
	SUB 192
	NEG
	CP B
	JR NC,eF2
	LD B,A
	JR eF2
eF1	LD L,A
	ADD A,B
	 RET M
	 RET Z
	LD B,A
	XOR A
	LD (Yh),A
	LD A,L
	NEG
	ADD A,A
	ADD A,E
	LD E,A
	JR NC,eF2
	INC D
eF2	
        endif

;собств вывод
;YhXh (Xh в знакоместах)
;HhWh (Wh в знакоместах)
;SHIFTh = 0..7 (xlow)
;de=gfxdata
        if EGA
      ;ld iy,testspr+4
        jp prsprega
        else

	PUSH DE
	LD HL,HE_N
	LD DE,(Xh)
	BIT 7,E
	JR Z,HRU8
	LD HL,HE_L
	LD E,0
HRU8	EX AF,AF
	LD A,(SHIFTh)
	CALL WT
	LD (JP_SUB+1),HL
	CALL BCOORD
	POP DE
HRU0	PUSH HL
	PUSH DE
	PUSH BC
	LD (IMGh),HL
	CALL HRUp
	POP BC
	POP DE
	POP HL
	DEC C
	JR Z,HRU5
	EX AF,AF
	JR NZ,HRUm
	INC L
	JR HRUm1
HRUm	LD A,(SHIFTh)
	PUSH HL
	LD HL,HE_N
	CALL WT
	LD (JP_SUB+1),HL
	POP HL
HRUm1	XOR A
	EX AF,AF
	LD A,(Hh)
	ADD A,A
	ADD A,E
	LD E,A
	JR NC,HRU0
	INC D
	JR HRU0

HRU5	RET

HRUp	EX DE,HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD (SET_SP+1),SP
	LD SP,HL
	LD HL,(IMGh)
	JP JP_SUB
        endif ;~EGA

vBUF	EQU #7E00;BUF512
	;256 - eсть в строке?(ptr+1/0); 256-1_2:IX,3_4:IY,5й:next+1/null
vSORT	;видео сортировка
	LD HL,vBUF
	LD DE,vBUF+1
	LD BC,192+24
	LD (HL),0
	LDIR
	;
	EXX
	LD HL,vBUF+1+256
	EXX
	LD IX,HUMAN
	LD B,102
	LD IY,XY ;зачем отдельный массив? в каждом проходе прибавляем 4
vS0	LD A,(IX+0) ;x героя (0=труп)
	OR A
	JR Z,vS6 ;???
	LD L,(IY+0)
	LD H,(IY+1) ;Xpos
	LD DE,(_X0pos)
	ADD HL,DE
	LD A,H
	OR A
	JR NZ,vS3
	LD A,L
	CP 192
	JR NC,vS1
	JR vS4
vS6	LD A,(IX+1) ;y героя (0=пусто)
	OR A
	JR Z,vS1 ;нет героя
	LD L,0
	JR vS4_
vS3	INC A
	JR NZ,vS1
	LD A,L
	CP 192+40
	JR C,vS1
vS4	LD L,(IY+2)
	LD H,(IY+3) ;Ypos
	LD DE,(_Y0pos)
	ADD HL,DE
	LD A,H
	OR A
	JR NZ,vS1
	LD A,L
	CP 192+24
	JR NC,vS1
vS4_	LD H,vBUF/256
	LD A,(HL)
	OR A
	JR Z,vS5
	LD H,vBUF/256+1
vSM6	LD L,A
	LD A,(HL)
	OR A
	JR NZ,vSM6
vS5	EXX
	PUSH IX
	POP DE
	LD (HL),E
	INC L
	LD (HL),D
	INC L
	PUSH IY
	POP DE
	LD (HL),E
	INC L
	LD (HL),D
	INC L
	LD A,L
	LD (HL),0
	INC L
	EXX
	LD (HL),A
	RET Z ;более 51 героя в экране
vS1	LD DE,16
	ADD IX,DE ;следующий герой
	LD E,4
	ADD IY,DE ;следующий блок координат
	DJNZ vS0
	RET

vXPUT	;отсорт вывод
	CALL outSEL
	LD HL,vBUF
vX0	LD A,(HL)
	OR A
	JR Z,vX1
	PUSH HL
	LD H,vBUF/256+1
vX2	LD L,A
	PUSH HL
	DEC L
	LD D,(HL)
	DEC L
	LD E,(HL)
	PUSH DE
	POP IY ;адрес в блоке координат
	DEC L
	LD D,(HL)
	DEC L
	LD E,(HL)
	PUSH DE
	POP IX ;адрес героя
	CALL XPUT
	POP HL
	LD A,(HL)
	OR A
	JR NZ,vX2
	POP HL
vX1	INC L
	LD A,L
	CP 192+24
	JR C,vX0
	RET

vrYLF	LD A,#D8 ;ограничители
	LD HL,#1000
	JR vrYs
vrYRT	LD A,#FF
	LD HL,#C098
vrYs	LD DE,#D800
	JR vr_
vrXUP	LD DE,#2800
	JR vrXs
vrXDW	LD DE,#D8B0
vrXs	LD A,#D8
	LD HL,#C000
vr_	CALL vrSET
	CALL XY0pos
	;сортировка по окну
	LD HL,vBUF
	LD DE,vBUF+1
	LD BC,256
	LD (HL),0
	LDIR
	;
	EXX
	LD HL,vBUF+256
	EXX
	LD IX,HUMAN
	LD B,102
	LD IY,XY
vrS0	LD A,(IX)
	OR A
	JR Z,vrS6
	LD L,(IY+0)
	LD H,(IY+1)
	LD DE,(_X0pos)
	ADD HL,DE
	LD A,H
	OR A
	JR NZ,vrS3
	LD A,L
vrH	CP 0	;<-H
	JR NC,vrS1
vrL	CP 0	;<-L
	JR C,vrS1
	JR vrS4
vrS6	LD A,(IX+1)
	OR A
	JR Z,vrS1
	LD L,0
	JR vrS4_
vrS3	INC A
	JR NZ,vrS1
	LD A,L
vrA	CP 0	;<-A
	JR C,vrS1
vrS4	LD L,(IY+2)
	LD H,(IY+3)
	LD DE,(_Y0pos)
	ADD HL,DE
	LD A,H
	OR A
	JR NZ,vrS1
	LD A,L
vrD	CP 0	;<-D
	JR NC,vrS1
vrE	CP 0	;<-E
	JR C,vrS1
vrS4_	LD H,vBUF/256
	LD A,(HL)
	OR A
	JR Z,vrS5
	LD H,vBUF/256+1
vrSM6	LD L,A
	LD A,(HL)
	OR A
	JR NZ,vrSM6
vrS5	EXX
	PUSH IX
	POP DE
	LD (HL),E
	INC L
	LD (HL),D
	INC L
	PUSH IY
	POP DE
	LD (HL),E
	INC L
	LD (HL),D
	INC L
	LD A,L
	LD (HL),0
	INC L
	EXX
	LD (HL),A
	RET Z ;более 51 героя в экране
vrS1	LD DE,16
	ADD IX,DE
	LD E,4
	ADD IY,DE
	DJNZ vrS0
vrS51	XOR A
	LD L,A
	LD H,A
	LD D,A
	LD E,A
vrSET	LD (vrA+1),A
	LD A,L
	LD (vrL+1),A
	LD A,H
	LD (vrH+1),A
	LD A,E
	LD (vrE+1),A
	LD A,D
	LD (vrD+1),A
	RET

outSEL	;выв выбр об'ектов и рамки цели
	CALL STD
	LD HL,sel_ti
	LD A,(HL)
	OR A
	JR Z,uS3
	DEC (HL)
	LD A,(TIC)
	RRCA
	JR C,uS3
	DEC HL
	LD A,(HL)
	BIT 7,A
	JR NZ,uS5
	;рамка героя-цели
	CALL N_IXIY
	LD A,(IX+0)
	OR A
	JR Z,uS3
	LD A,1 ;nz,A=1
	CALL _XPUT
	JR uS3
uS5	;рамка здания-цели
	AND #7F
	CALL uS6
uS3	LD A,(SEL_T) ;объекты
	OR A
	RET Z
	LD HL,SEL_N
	CP 7
	JR C,uS4
	JR NZ,uS1
	LD A,1
uS4	LD B,A
uS0	PUSH BC
	PUSH HL
	LD A,(HL)
	CALL N_IXIY
	XOR A
	INC A ;nz,A=1
	CALL _XPUT
	POP HL
	INC HL
	POP BC
	DJNZ uS0
	RET
uS1	;выд.здания
	LD A,(HL)
uS6	CALL B_IX
	LD A,(IX+0)
	OR A
	JP NZ,_BPUT
	RET

B_IX	;получить IX здания по номеру А
	PUSH HL
	PUSH DE
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	LD DE,MINE
	ADD HL,DE
	PUSH HL
	POP IX
	POP DE
	POP HL
	RET

N_IXIY	;получить IX,IY героя по номеру А
	PUSH AF
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	LD A,L
	ADD A,XY&255
	LD L,A
	LD A,XY/256
	ADC A,H
	LD H,A
	PUSH HL
	POP IY
	POP AF
N_IX	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD A,HUMAN/256
	ADD A,H
	LD H,A
	PUSH HL
	POP IX
	RET


_BPUT	;выв рамки выбора зд
	CALL HL_IX0
	LD A,(IX+2)
	CP 8
	JR Z,_Bsmal
	CP 18
	JR Z,_Bsmal
	DEC L
	INC H;/8
	PUSH HL
	LD DE,#40C0
	CALL bJ0v
	LD DE,#8000
	CALL C,bJ1h_
	POP HL
	INC L;/7
	PUSH HL
	LD D,#00
	CALL bJ0h_
	POP HL
	INC L;/6
	PUSH HL
	LD DE,#0203
	CALL bJ1v
	LD DE,#0001
	DEC L
	CALL C,bJ1h_
	POP HL
	DEC H;/5
	PUSH HL
	LD DE,#0203
	CALL bJ1v
	POP HL
	DEC H;/4
	PUSH HL
	CALL bJ1v
	LD DE,#0001
	DEC L
	CALL C,bJ1h
	POP HL
	DEC L;/3
	PUSH HL
	LD DE,#0000
	CALL bJ0h
	POP HL
	DEC L;/2
	PUSH HL
	LD DE,#40C0
	CALL bJ0v
	LD DE,#8000
	CALL C,bJ1h
	POP HL
	INC H;/1
	LD DE,#40C0
	JP bJ0v
_Bsmal	DEC L;\4
	PUSH HL
	LD DE,#40C0
	CALL bJ0v
	LD DE,#8000
	CALL C,bJ1h_
	POP HL
	INC L;\3
	PUSH HL
	LD DE,#0203
	CALL bJ1v
	LD DE,#0001
	DEC L
	CALL C,bJ1h_
	POP HL
	DEC H;\2
	PUSH HL
	LD DE,#0203
	CALL bJ1v
	LD DE,#0001
	DEC L
	CALL C,bJ1h
	POP HL
	DEC L;\1
	LD DE,#40C0
	CALL bJ0v
	LD DE,#8000
	JP C,bJ1h
	RET

bJ0h_	;снизу
	CALL bJadr
	RET NC
bJ1h_	LD A,L
	ADD A,32
	LD L,A
	LD A,H
	ADD A,6
	LD H,A
	CALL bJ100
	LD D,E
	DEC H
	INC L
bJ100	XOR A
	XOR D
	LD (HL),A
	INC H
	LD (HL),#FF
	SCF
	RET

bJ0h	CALL bJadr;выв гориз
	RET NC
bJ1h	CALL bJ200
	LD D,E
	DEC H
	INC L
bJ200	LD (HL),#FF
	INC H
	XOR A
	XOR D
	LD (HL),A
	SCF
	RET

bJ1v	CALL bJadr
	RET NC
	INC L
	JR bJ002
bJ0v	;выв верт лин для здан (HL-adr в map;DE-изобр/маска)
	CALL bJadr
	RET NC
bJ002	PUSH HL
	CALL bJ000
	LD A,H
	SUB 8
	LD H,A
	LD A,L
	ADD A,32
	LD L,A
	CALL bJ000
	POP HL
	SCF
	RET
bJ000	LD B,2
bJ001	LD A,(HL)	;
	OR E
	XOR D
	LD (HL),A
	INC H
	LD A,(HL)	;
	OR E
	XOR D
	LD (HL),A
	INC H
	LD A,(HL)	;
	OR E
	XOR D
	LD (HL),A
	INC H
	LD A,(HL)	;
	OR E
	XOR D
	LD (HL),A
	INC H
	DJNZ bJ001
	RET

bJadr	LD BC,(X0) ;выч адр (NC/C-out/ok)
	LD A,L
	SUB C
	CP 12
	RET NC
	LD L,A
	LD A,H
	SUB B
	CP 12
	RET NC
	LD H,A
	ADD HL,HL
	PUSH DE
	EX DE,HL
	CALL SCOORD
	POP DE
	XOR A
	CCF
	RET

        if 1==0
_TST#7	 LD HL,dummy+0 ;isTST7[**]
	LD A,(HL) ;mem7!
	OR A
	RET NZ
	PUSH HL
	LD HL,(t7pos)
	CALL GMAP
	LD A,(HL)
	POP HL
	CP #7F
	RET NC
	SET 7,(HL)
	CALL t7dt ;7
	RET Z
	LD HL,BULL+72
	LD B,72
t7er	SET 7,(HL)
	INC HL
	DJNZ t7er
	RET
	;
t7dt	LD HL,BUF512
	PUSH HL
	LD DE,t7tab
t7d0	LD A,(DE)
	INC DE
	OR A
	JR Z,t7de
	POP HL
	SUB 11
	PUSH HL
	CALL BA
	LD A,(DE)
	INC DE
	LD (HL),A
	JR t7d0
t7de	XOR A
	RET

        endif
