;-----------Вывод спрайтов героев

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

AT_HER	DEFB #C0,#C6,#CA,#CE,#D2
	DEFB #D8,#DE,#E4,#F1
	DEFB #C4,#CA,#D0,#D6,#DC,#DC

AT_WAR	DEFB #C4,#C4,#C4,#00,#D6
	DEFB #DC,#E2,#ED,#FA
	DEFB #C8,#CE,#D4,#DA,#00,#00


AT_TY_	DEFB 0,0,0,0,0, 0,0,1,1
AT_TYP	DEFB 0,0,0,0,0, 0,0,1,1
	DEFB 0,0,0,0,0,0, 2,2,2


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
	XOR A
_XPUT	EX AF,AF ;Z-герой, NZ-(A=1:рамка/A>1:снаряд)
	LD L,(IY+2) ;получение Xh Yh SHIFTh
	LD H,(IY+3)
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
	LD H,(IY+1)
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
;	--------------------
	EX AF,AF
	JR Z,WY_0
	;для рамки
	DEC A
	JP NZ,WYbull;->обр снарядов
	CALL MEM1
	LD A,(IX+4)
	LD HL,AT_TY_
	CALL BA
	DEC A
	JR Z,WYr33
	LD BC,#1002
	LD DE,fr2x2h
	JR WYr
WYr33	LD BC,#1803
	LD DE,fr3x3h
WYr	JP HeF1
WY_0	LD A,(IX+0)
	OR A
	LD A,(IX+4)
	JR NZ,WY2
	;для трупа
	CP 17
	JR C,WYTr
	CALL MEM6 ;труп катап
	LD DE,WMISC3
	LD BC,#1803
	JP HeF1
WYTr	ADD A,A
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD DE,WMISC2
	ADD HL,DE
	EX DE,HL
	CALL MEM1
	LD BC,#1002
	JP HeF1
	;
WY2	;для героя
	LD E,A
	SUB 9
	JR NC,WY1
        if 1==0
	LD A,4 ;люди
        else
        call MEM_humans
        endif
	JR WY0
WY1	LD E,A
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
	LD A,E
	LD HL,AT_TYP
	CALL BA
	CP 1
	LD D,(IX+2)
	LD A,(IX+3)
	JR Z,H3x3
	JP NC,H3x2
H2x2	CP #80
	JR C,H221
	CP #A0
	LD A,0
	JR C,H221
	LD A,D
	LD BC,AT_WAR
	JR H222
H221	LD BC,AT_HER
	AND 1
	ADD A,D
	ADD A,D
H222	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	LD A,E
	EX DE,HL
	LD L,C
	LD H,B
	LD BC,#1002
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
	JR C,H331
	CP #A0
	LD A,0
	JR C,H331
	LD BC,#ED00
	LD A,D
	JR H332
H331	LD BC,#E400
	AND 1
	ADD A,D
	ADD A,D
	LD D,A
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
	ADD HL,HL
	ADD HL,BC
	LD BC,#1803
	LD A,E
	CP 7
	JR Z,H333
	LD DE,#D80
	ADD HL,DE
H333	EX DE,HL
;	--------------------
HeF1	;корректировка ширины,длины и др. по границам окна
	LD (Wh),BC
	LD HL,(Xh)
	LD A,H
	SUB B
	LD (Yh),A
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
eF4	LD A,(Yh)
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
eF2	;собств вывод
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
	LD IY,XY
vS0	LD A,(IX+0)
	OR A
	JR Z,vS6
	LD L,(IY+0)
	LD H,(IY+1)
	LD DE,(_X0pos)
	ADD HL,DE
	LD A,H
	OR A
	JR NZ,vS3
	LD A,L
	CP 192
	JR NC,vS1
	JR vS4
vS6	LD A,(IX+1)
	OR A
	JR Z,vS1
	LD L,0
	JR vS4_
vS3	INC A
	JR NZ,vS1
	LD A,L
	CP 192+40
	JR C,vS1
vS4	LD L,(IY+2)
	LD H,(IY+3)
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
	ADD IX,DE
	LD E,4
	ADD IY,DE
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
	POP IY
	DEC L
	LD D,(HL)
	DEC L
	LD E,(HL)
	PUSH DE
	POP IX
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
