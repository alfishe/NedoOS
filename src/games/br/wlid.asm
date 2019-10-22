;XECUTE MOUSE
;TAKE COORDINATES FROM CURPOS==MX

MOUSE	LD	HL,(COORD)
	LD	BC,#FBDF
	LD	DE,(OLDCO)
	IN	A,(C)
	LD	(OLDCO),A
	SUB	E
	JR	Z,NM_X
	JP	P,MX_PL
	ADD	A,L
	JR	C,ZER_X
	XOR	A
ZER_X	LD	L,A
	JR	NM_X
MX_PL	ADD	A,L
	JR	C,BEX_Z
	CP	248	;MAXIMUM X
	JR	C,BEX_B
BEX_Z	LD	A,248	;MAXIMUM X
BEX_B	LD	L,A
NM_X	LD	B,#FF
	IN	A,(C)
	LD	(OLDCO+1),A
	SUB	D
	JR	Z,NM_Y
	NEG
	JP	P,MY_PL
	ADD	A,H
	JR	C,ZER_Y
	XOR	A
ZER_Y	LD	H,A
	JR	NM_Y
MY_PL	ADD	A,H
	JR	C,BEY_Z
	CP	#BE	;MAXIMUM Y
	JR	C,BEY_B
BEY_Z	LD	A,#BE	;MAXIMUM Y
BEY_B	LD	H,A
NM_Y	LD	A,H
	CP	#FF
	JR	C,BIGY
	LD	H,#FF
BIGY	CP	#00	;MINIMUM Y
	JR	NC,SMALY
	LD	H,#00	;MINIMUM Y
SMALY	LD	A,L
	CP	#FF
	JR	C,DIRY
	LD	L,#FF
DIRY	CP	#00	;MINIMUM X
	JR	NC,DIMENS
	LD	L,#00	;MINIMUM X
DIMENS	LD	(COORD),HL
	LD BC,#FADF
	LD HL,CONTRB
	IN A,(C)
	CPL
	AND 7
	RLCA
	RLCA
	RLCA
	RLCA
	OR (HL)
	LD (HL),A
	RET

;========================Мeнeджер памяти========
        if 1==1
MEM_kungs
MEM_snd	LD A,3 ;страница с эффектами
	JR MEM 
        endif
MEM_humans
MEM4	LD A,4
	JR MEM
MEM_char1 ;креат 25-26
MEM0	XOR A
	JR MEM
MEM1	LD A,1
	JR MEM
MEM_char0 ;креат 18-24
MEM6	LD A,6
	JR MEM
MEM7	LD	A,7
MEM	
        if 1==1
        ;OR	%11000
         jp _128
        else
        OR	%11000
_128	LD	BC,#7FFD
	LD	(R128),A
	OUT	(C),A
	RET
        endif

;--------scr сlr/mov
OFFD	LD	DE,DSCR+#1AFE
	JR	offx

;TODO убрать в EGA
OFFS	CALL	MEM7
	LD	DE,SCR+#1AFE
offx	PUSH DE
	POP HL
	INC HL
	LD	BC,768
	LD	(HL),0
	LDDR
	LD	BC,6143
	LD	(HL),255
	LDDR
	RET

COPY	 ;копир.экр
        if EGA
        ret
        else
	LD	BC,6144
CY_	LD	HL,DSCR
	LD	DE,SCR
	LDIR
	RET

COPYAT	LD	BC,6912
	JR CY_
        endif

;поиск по таблицам

WT	RLCA
	ADD	A,L
	LD	L,A
	JR	NC,WT_
	INC	H
WT_	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET


BT	PUSH	HL
	ADD	A,L
	LD	L,A
	JR	NC,BT_
	INC	H
BT_	LD	A,(HL)
	POP	HL
	RET


DA	ADD A,A
WA	ADD A,A
BA	ADD A,L
	LD L,A
	LD A,(HL)
	RET NC
	INC H
	LD A,(HL)
	RET

;-----W_GrLib-------------------------------
;PUTsHL DEFW 0
;SCRADR DEFB SCR/256
;ATRADR DEFB #D8
;FONT	DEFW WFONT

PCOORD	LD	A,D ;de(0-191,0-255) -- hl
	RRCA
	RRCA
	RRCA
	LD	L,A
	AND	%00011000
	LD	H,A
	LD	A,D
	AND	%00000111
	ADD	A,H
	LD	H,A
	LD	A,(SCRADR)
	ADD	A,H
	LD	H,A
	LD	A,L
	LD	L,E
	RRA
	RR	L
	RRA
	RR	L
	RRA
	RR	L
	RET


SCOORD	LD	A,(SCRADR) ;de(0-23,0-31)--hl
	ADD	A,D
	AND	%11111000
	LD	H,A
	LD	A,D
	RRCA
	RRCA
	RRCA
	AND	%11100000
	OR	E
	LD	L,A
	RET

STD	LD	A,DSCR/256 ;выбор тенев.экрана
	JR	SELSCR
STS	LD	A,SCR/256 ;выб.осн.экр
SELSCR	LD	(SCRADR),A ;A-screen address
	ADD	A,#18
	LD	(ATRADR),A; A-attr address
	RET

ACOORD	LD A,L ;коорд атр HL->HL
	RLA
	RLA
	RLA
	SRL H
	RRA
	SRL H
	RRA
	SRL H
	RRA
	LD L,A
	LD A,(ATRADR)
	ADD A,H
	LD H,A
	RET

ATRBAR	;HL - adr in scr; BC-size(yx) ;E-COLOR
        if EGA
;TODO
        ret
        else
	CALL ACOORD
ATRBA0	LD D,L
	LD A,C
ATRBA1	LD (HL),E
	INC L
	DEC A
	JR NZ,ATRBA1
	LD A,D
	ADD A,32
	LD L,A
	JR NC,ATRBA2
	INC H
ATRBA2	DJNZ ATRBA0
	RET
        endif

        if EGA
PUTSYM=primgega
        else
PUTSYM	;HL - adr in scr; DE-adr spr; BC-size(yx)
	PUSH DE
	EX DE,HL
	CALL SCOORD
	LD (PUTsHL),HL
	POP HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD (SET_SP+1),SP
	LD SP,HL
	LD HL,(PUTsHL)
	LD A,B
YS2	LD (PUTsHL),HL
	EX AF,AF
YS0	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD A,L
	ADD A,32
	LD L,A
	JR C,YS1
	LD A,H
	SUB 8
	LD H,A
YS1	DJNZ YS0
	LD HL,(PUTsHL)
	INC L
	EX AF,AF
	LD B,A
	DEC C
	JR NZ,YS2
YSR	JP SET_SP
        endif

;;MATHEMATICAL LIBRARY	MATH-ZX
;MULB2	PUSH	HL	 ;HL*E--DE  (C)
;	JR	MULENT
;MULB	PUSH	HL	 ;L*E--DE
;	LD	H,0
;MULENT LD	A,E
;	LD	E,0
;	LD	D,E
;	JR	MMULB2
;MMULB1 ADD	HL,HL
;	JR	C,ENDMUL
;MMULB2 OR	A
;	JR	Z,ENDMUL
;	RRA
;	JR	NC,MMULB1
;	EX	DE,HL
;	ADD	HL,DE
;	EX	DE,HL
;	JR	MMULB1
;ENDMUL POP	HL
;	RET
;MUL	PUSH	HL ;HL*DE--DE
;	XOR	A
;	OR	D
;	JR	Z,MULENT
;	EX	DE,HL
;	XOR	A
;	OR	D
;	JR	Z,MULENT
;	SCF
;	POP	HL
;	RET
DIVB	LD	D,0 ;E/L--E (MOD in D)
DIVB2	PUSH	HL ;DE/L--E
	PUSH	BC
	LD	B,8
	EX	DE,HL
	LD	D,E
	LD	E,0
DIV1B	OR	A
	RR	D
	RR	E
	SBC	HL,DE
	JR	NC,MDIVB
	ADD	HL,DE
MDIVB	RLA
	DJNZ	DIV1B
	CPL
	LD	D,L
	LD	E,A
	POP	BC
	POP	HL
	RET

;-------------------------------КОНЕЦ W_Gr.Lib

PRINTS	;печать строки HL(конец 127)
	LD A,(HL)
	CP #7F
	RET Z
	CALL PRINT
	INC HL
	JR PRINTS

PRINT	;печать символа А в поз DE(yx)
	PUSHs
        if EGA
        call prchar
        else
	LD C,A
	CALL SCOORD
	EX DE,HL
	LD A,C
	ADD A,A
	LD BC,(FONT)
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,BC
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	LD (DE),A
	INC HL
	INC D
        endif
	POPs
	INC E
	RET

        if 1==0
t5inc	LD HL,tst5B ;[**]
	LD B,tst5E-tst5B
t5inc0	INC (HL)
	INC HL
	DJNZ t5inc0
	RET
        endif

;--------РАБОТА С КУРСОРОМ---

MMOV	;обр.управл
	CALL CONTR
	LD BC,#BFFE ;'Enter' || 'x'
	IN A,(C)
	RRA
	JR NC,eMOV
	LD B,#FE
	IN A,(C)
	BIT 2,A
	JR Z,eMOV
	XOR A
	LD (BENTER),A
_422	LD A,(CONTRB)
	LD D,A
	AND #20 ;'Caps' || R.butt?
	LD E,A
	LD BC,#FEFE
	IN A,(C)
	AND 1
	OR E
	LD (BCAP),A
	LD	C,D
	LD	DE,(ENDX)  ;move
	LD	B,D
	LD	HL,(MX)
	LD	(MXOLD),HL
	RR	C
	JR	NC,_1
	LD	A,L
	ADD	A,B
	JR	C,_11A
	CP	E
	JR	C,_11B
_11A	LD	A,E
_11B	LD	L,A
	LD	D,0
_1	RR	C
	JR	NC,_2
	LD	A,L
	SUB	B
	JR	NC,_21
	XOR	A
_21	LD	L,A
	LD	D,0
_2	RR	C
	JR	NC,_3
	LD	A,H
	ADD	A,B
	CP	189
	JR	C,_31
	LD	A,189
_31	LD	H,A
	LD	D,0
_3	RR	C
	JR	NC,_4
	LD	A,H
	SUB	B
	JR	NC,_41
	XOR	A
_41	LD	H,A
	LD	D,0
_4	LD	(MX),HL
	LD	A,D
	OR	A
	LD	A,step_B ;нач шаг
	JR	NZ,_42
	LD	A,(MtSTEP)
	LD	DE,(M_STEP)
	ADD	A,1
	CP	E
	JR	C,_42
	LD	A,E
_42	LD	(MtSTEP),A
	RET
eMOV	LD A,1
	LD (BENTER),A
	LD A,(isMAP)
	OR A
	LD A,0
	JR Z,_42
	CALL MEM7
	CALL MAPwin
	CALL MX3PX
	CALL movWIN
	CALL MAPwin
	JP _422

B_OFF	LD HL,B_ONOF
	LD A,(HL)
	OR A
	RET Z
	LD (HL),0
	LD HL,(BATR)
	LD DE,B_ABUF
	LD A,(DE)
	INC DE
	LD (HL),A
	LD HL,(BADR)
	LD B,8
B_o1	LD A,(DE)
	LD (HL),A
	INC DE
	INC H
	DJNZ B_o1
	RET

B_IMGM	DEFB #55,#81,#19,#BD,#3D,#99,#01,#FF

;курсор скролла? TODO!!!
BL_ONN	EXX
	LD A,(BY)
	CP B
	JR NZ,_BL
	PUSH BC
	LD HL,(BX) ;модиф B_ONN
	LD (BXOLD),HL
	PUSH HL
	CALL STS
	CALL ACOORD
	LD (UATR),HL
	LD A,(HL)
	LD (U_ABUF),A
	LD A,(COLRsc)
	LD (HL),A
	POP DE
	CALL SCOORD
	LD (UADR),HL
	LD DE,U_BUF
	LD BC,B_IMGM
	LD A,8
B_n4	PUSH AF
	LD A,(HL)
	LD (DE),A
	LD A,(BC)
	LD (HL),A
	INC H
	INC BC
	INC DE
	POP AF
	DEC A
	JR NZ,B_n4
	POP BC
_BL	EXX
	RET

B_U2B	LD HL,BY
	LD DE,UBY
	LD BC,14
	LDIR
	LD A,1
	LD (B_ONOF),A
	RET

B_SET0	EXX
	LD B,-1
	EXX
	RET

B_SETI	EXX
	LD B,26
	EXX
	CALL B_NXTI
B_NXTI	EXX
	DEC B
	LD A,(UBY)
	SUB -2
	JR b_n_

B_SETN	EXX
	LD B,-3
	EXX
	CALL B_NXTN
B_NXTN	EXX
	INC B
	LD A,(UBY)
	SUB 2
b_n_	SUB B
	JR NZ,_BL
	PUSH BC
	CALL B_OFF
	POP BC
	EXX
	RET

B_NXT0	EXX
	INC B
	LD A,(UBY)
	JR b_n_

        if 1==0
t5dec	LD HL,tst5B ;[**]
	LD B,tst5E-tst5B
t5dec0	DEC (HL)
	INC HL
	DJNZ t5dec0
	RET
        endif

BMOV	LD HL,(MX) ;преобр MX->BX->PX
	   INC L
	   INC L ;коррекц
	SRL L
	SRL L
	SRL L
	SRL H
	SRL H
	SRL H
	LD (BX),HL
	LD A,(isMAP)
	OR A
	JR NZ,mB1
	SRL L
	SRL H
	LD DE,(X0)
	ADD HL,DE
	LD (PX),HL
	RET
mB1	CALL MX3PX
	LD (PX),BC
	RET

        if 1==0
tst5B	DEFB 1+#AF	;0:0076 TST#5	XOR A [**]
	DEFB 1+#21,1+#00,1+#C0	;0:0077     LD HL,#C000
	DEFB 1+#01,1+#00,1+#34	;0:0078     LD BC,#3400
	DEFB 1+#96	;0:0079 tst50	SUB (HL)
	DEFB 1+#07	;0:0080 	RLCA
	DEFB 1+#23	;0:0081 	INC HL
	DEFB 1+#0D	;0:0082 	DEC C
	DEFB 1+#20,1+#FA	;0:0083 	  JR NZ,tst50
	DEFB 1+#05	;0:0084 	DEC B
	DEFB 1+#20,1+#F7	;0:0085 	  JR NZ,tst50
	DEFB 1+#21,1+#AF,1+#F4	;0:0086     LD HL,#F4AF
	DEFB 1+#BE	;0:0087 	CP (HL)
tst5E	RET
        endif

MX3PX	LD HL,(MX) ;MX/3->PX
	   INC L
	   INC L
	LD E,L
	LD L,3
	CALL DIVB
	LD A,E
	CP 64
	JR C,mB2
	LD A,63
mB2	LD C,A
	LD E,H
	CALL DIVB
	LD B,E
	RET

        if 1==0
	PUSH HL
_TST#5	LD A,(isTST5) ;[**]
	OR A
	RET Z
	CALL t5dec
	CALL tst5B
	PUSH AF
	CALL t5inc
	XOR A
	LD (isTST5),A
	POP AF
	RET Z
	POP HL
        CALL OFFD
        endif
