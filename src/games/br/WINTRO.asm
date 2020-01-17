;---Развевающийся Флаг

bFLAG	DI
	LD A,1
	OUT (#FE),A
	CALL MEM7
	LD DE,SCR
	LD HL,CROW+2
	CALL DELPZ
	CALL SW7
	LD A,3
	CALL MEM
	LD HL,PIKE+2
	LD DE,DSCR
	CALL DELPZ
	CALL MEM0
	CALL MUS
	CALL COLOR
	LD BC,824
	;Развевающийся Флаг
fSS1	CALL PRESS
	PUSH BC
	EI
	HALT
	DI
	CALL MUS+6
	POP BC
	DEC BC
	LD A,C
	OR B
	JR NZ,fSS1
	;
	CALL SW5
fSS2	CALL PRESS
	CALL fLDIR
	XOR A
	OUT (#FE),A
	CALL MEM0
	CALL MUS+6
	JR fSS2

fFRAME	DEFB 0 ; (#кадра - 1..9)
fFDELY	DEFB 0 ;задержка
fLDIR	LD HL,fFDELY
	INC (HL)
	LD A,(HL)
	CP 3
	LD A,(fFRAME)
	JR C,fMM1
	LD (HL),0
	DEC HL
	INC (HL)
	LD A,(HL)
	CP 9
	JR C,fMM1
	XOR A
	LD (HL),A
fMM1	CP 5
	JR C,fMM2
	SUB 5
	PUSH AF
	LD A,4
	JR fMM3
fMM2	PUSH AF
	LD A,3
fMM3	CALL MEM
	POP AF
	LD HL,#C000
	OR A
	JR Z,fMM4
	LD DE,2560
fMM5	ADD HL,DE
	DEC A
	JR NZ,fMM5
fMM4	;
	LD DE,#4049
	EXX
	LD B,127
	LD A,(fFRAME)
	DEC A
	AND %11110
	CP 6
	LD A,#68
	JR NZ,fMM22
	LD A,#78
fMM22	EI
	HALT
	DI
	LD (#5800+124),A
fEM0	EXX
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI;
	LD A,E
	SUB 20
	LD E,A
	INC D
	LD A,D
	AND 7
	JP NZ,fEM1
	LD A,E
	ADD A,32
	LD E,A
	JR C,fEM1
	LD A,D
	SUB 8
	LD D,A
fEM1	EXX
	DJNZ fEM0
	RET

PRESS	;нажатие клавиши 1-2-3
	PUSH BC
	LD BC,#F7FE
	IN A,(C)
	POP BC
	CPL
	AND 7
	OR A
	RET Z
	LD E,1
	RRA
	JR C,PRE1
	INC E
	RRA
	JR C,PRE1
	INC E
PRE1	LD A,E
	PUSH AF
	CALL MUS+9
	POP AF
	CP 2
	JP C,bFLICK
	;JP Z,bGAME
	CALL OFFS
	JP bINSTR


COLOR	;раскр флага
	CALL STD
	LD HL,0
	LD BC,#1820
	LD E,#78
	CALL ATRBAR
	LD BC,#404
	LD E,#68
	CALL ATRBAR
	LD L,28
	CALL ATRBAR
	LD H,20
	CALL ATRBAR
	LD L,0
	CALL ATRBAR
	LD HL,8
	LD BC,#1801
	LD E,#30
	CALL ATRBAR
	LD BC,#202
	LD E,#70
	CALL ATRBAR
	LD HL,#1609
	LD C,15
	LD E,#50
	CALL ATRBAR
	LD BC,#605
	LD HL,#900
	LD E,#38
	CALL ATRBAR
	LD HL,#1202
	LD BC,#41D
	LD E,#78
	JP ATRBAR

;-----W_GrLib--for intro---------------
PUTsHL	DEFW 0
SCRADR	DEFB SCR/256
ATRADR	DEFB #D8
FONT	DEFW FFONT

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
	PUSHs
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
	POPs
	RET

PRINT	;печать символа А в поз DE(yx)
	PUSHs
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
	POPs
	INC E
	RET

;-------------------------
;---МУЛЬТФИЛЬМ------------
MUSj45	EQU 43700

bFLICK	DI
	LD A,0;6
	OUT (#FE),A
	LD A,R
	LD (RNB),A
	CALL SW70
	LD HL,WIN+2
	LD DE,#4000
	CALL DELPZ
	CALL STD
	LD HL,0
	;ОКРАС
	LD BC,#1820
	LD E,#30
	CALL ATRBAR
	LD L,2
	LD BC,#41C
	LD E,#70
	CALL ATRBAR
	LD HL,#501
	LD BC,#120E
	LD E,#68
	CALL ATRBAR
	INC C
	LD L,#10
	LD E,#71
	CALL ATRBAR
	LD DE,TITRES
	LD HL,WFTXT+2
	CALL DELPZ
	CALL MEM7
	LD DE,MUSj45
	LD HL,J45LPZ+2
	CALL DELPZ
	CALL MUSj45
	CALL SW5
	CALL MEM0
	;
fREP	LD A,-3
	LD (fBLOCK),A
	LD HL,TITRES-416
	LD (TITadr),HL
	CALL LOAD_M
	CALL PL0
	CALL LOAD_M
	CALL PL1
	CALL LOAD_M
	CALL PL2
	CALL LOAD_M
	CALL PL3
	CALL LOAD_M
	CALL PL4
	CALL LOAD_M
	CALL PL5
	JR fREP

fCOUNT	DEFB 0 ;счётчик кадровх16

pF	LD HL,fCOUNT
	LD (HL),A
pF0	PUSH HL
	CALL FRWRD
	POP HL
	LD A,(#5800)
	CP #30
	JR NZ,pF0
	DEC (HL)
	JR NZ,pF0
	RET


pFtt	DEFB 0,3,0,6,6,0,3,0, 0,0,0,6,0,3,0,0
	DEFB 6,0,0,0,3,3,0,3, 0,3,0,6,0,0,6,0

pFtcnt	DEFB 0

pFrr	LD HL,fCOUNT ;для doom
	LD (HL),A
pFr0	PUSH HL
	LD A,(pFtcnt)
	INC A
	AND #1F
	LD (pFtcnt),A
	LD HL,pFtt
	CALL BA
	LD (P_ANI),A
	CALL FRWRD
	POP HL
	LD A,(#5800)
	CP #30
	JR NZ,pFr0
	DEC (HL)
	JR NZ,pFr0
	RET

fLAST4	DEFB 0 ;(огранич.4х кадров)
pF4	LD HL,fCOUNT
	LD (HL),A
	LD A,C
	LD (fLAST4),A
pF40	PUSH HL
	CALL FRWRD4
	POP HL
	LD A,(#5800)
	CP #30
	JR NZ,pF40
	DEC (HL)
	JR NZ,pF40
	RET

pFB	LD HL,fCOUNT
	LD (HL),A
pFB0	PUSH HL
	CALL FRWRD
	CALL BCKWRD
	POP HL
	LD A,(#5800)
	CP #30
	JR NZ,pFB0
	DEC (HL)
	JR NZ,pFB0
	RET

pBF	LD HL,fCOUNT
	LD (HL),A
pBF0	PUSH HL
	CALL BCKWRD
	CALL FRWRD
	POP HL
	LD A,(#5800)
	CP #30
	JR NZ,pBF0
	DEC (HL)
	JR NZ,pBF0
	RET

PL0	XOR A ;&&copper feet
	CALL fSET
	LD A,12
	CALL pFB
	LD A,1 ;&&monitors
	CALL fSET
	 LD HL,450
	 LD (TITtim),HL
	LD A,21
	CALL pF
	LD A,2 ;&&river
	CALL fSET
	LD A,35
	CALL pF
	JP offVID

PL1	XOR A
	CALL fSET
	LD A,43
	CALL pF
	LD A,1 ;
	CALL fSET
	LD A,42
	CALL pF
	LD A,2 ;&&
	CALL fSET
	LD A,26
	CALL pFB
	JP offVID

PL2	XOR A ;&&
	CALL fSET
	LD A,20
	CALL pBF
	LD A,1 ;&&
	CALL fSET
	LD A,34
	CALL pF
	LD A,2 ;&&
	CALL fSET
	LD A,17
	CALL pFB
	CALL MUSj45
	JP offVID

tDEL	;время задержки
	DEFB 4,3,3, 3,3,2
	DEFB 3,4,3, 3,3,4
	DEFB 3,3,2, 4

PL3	XOR A ;&&
	CALL fSET
	LD A,26
	CALL pF
	LD A,1 ;&&
	CALL fSET
	LD A,28
	CALL pF
	LD A,2 ;&&
	CALL fSET
	LD A,25
	CALL pF
	JP offVID

PL4	XOR A ;&&
	CALL fSET
	LD A,32
	CALL pF
	LD A,1 ;&&катап
	CALL fSET
	 LD A,84
	 LD C,4
	 CALL pF4
	 LD A,1
	 LD C,8
	 CALL pF4
	 LD A,1
	 LD C,12
	 CALL pF4
	 LD A,44
	 LD C,16
	 CALL pF4
	LD A,2 ;&&
	CALL fSET
	LD A,84
	CALL pF
	CALL MUSj45
	JP offVID

PL5	XOR A ;&&
	CALL fSET
	LD A,23
	CALL pF
	CALL fStt
	LD A,14
	CALL pFrr
	LD A,3
	LD (DL_ANI),A
	LD A,16
	CALL pFrr
	CALL fStt
	LD A,2
	LD (DL_ANI),A
	LD A,18
	CALL pFrr
	LD A,1
	LD (DL_ANI),A
	LD A,32
	CALL pFrr
	CALL MUSj45
	JP offVID


fSET	;уст нач парм аним A (0-2) из тек блока
	LD E,A
	ADD A,A
	ADD A,E
	LD (P_ANI),A
	LD HL,(fBLOCK)
	LD A,E
	ADD A,L
	LD E,A
	LD HL,fCOLOR
	CALL BA
	LD (C_ANI),A
	LD A,E
	LD HL,tDEL
	CALL BA
	LD (DL_ANI),A
	;
	XOR A
	LD (FRAME),A
	INC A
	LD (FDELAY),A
	CALL fINTRP
	LD DE,(C_ANI)
	CALL fS_
	;инит титров
fStt	LD HL,(TITadr)
	LD DE,416
	ADD HL,DE
	LD (TITadr),HL
	XOR A
	LD (TITad_),A
	LD HL,800
	LD (TITtim),HL
	RET

TITadr	DEFW TITRES ;текст титров
TITad_	DEFB 0 ;+0,+208
TITtim	DEFW 10 ;время показа

fS_	LD BC,#120E
	LD HL,#501
	JP ATRBAR

offVID	;очистк межд блоками
	;;CALL MUSj45+9
	LD E,0
	JP fS_


;*************************
P_ANI	DEFB 0 ;нач страница аним (0,3,6)
DL_ANI	DEFB 4 ;задержка анимации
C_ANI	DEFB #38 ;цвет
;*************************

FRAME	DEFB 0 ;(#кадра - 0..15)
FDELAY	DEFB 0 ;задержка

fBLOCK	DEFB 0 ;блок анимации (0,3,6,9,12,15)

FRWRD4	LD B,4 ; 4 кадрa вперёд
frw4	PUSH BC
	LD A,(fLAST4)
	SUB B
	LD (FRAME),A
	CALL LDIRER
	POP BC
	DJNZ frw4
	RET

FRWRD	LD B,16 ; 16 кадров вперёд
frw0	PUSH BC
	LD A,16
	SUB B
	LD (FRAME),A
	CALL LDIRER
	POP BC
	DJNZ frw0
	RET

BCKWRD	LD B,16 ; 16 кадров вперёд
bkw0	PUSH BC
	LD A,B
	DEC A
	LD (FRAME),A
	CALL LDIRER
	POP BC
	DJNZ bkw0
	RET

LDIRER	;один кадр
	CALL fINTRP
	LD HL,FDELAY
	DEC (HL)
	JR NZ,LDIRER
	LD A,(DL_ANI)
	LD (HL),A
	;
	LD A,(FRAME) ;выв кадра A(0-15)
	CP 8
	LD E,A
	JR C,LMM2
	SUB 8
	LD E,A
	LD C,1
	JR LMM3
LMM2	LD C,0
LMM3	LD A,(P_ANI)
	ADD A,C
	CALL MEM
	LD A,E
	LD HL,#C000
	OR A
	JR Z,LMM4
	LD DE,2016
LMM5	ADD HL,DE
	DEC A
	JR NZ,LMM5
LMM4	;
	LD DE,#40A1
	EXX
	LD B,144
LEM0	EXX
	PUSH DE
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	POP DE
	INC D
	LD A,D
	AND 7
	JP NZ,LEM1
	LD A,E
	ADD A,32
	LD E,A
	JR C,LEM1
	LD A,D
	SUB 8
	LD D,A
LEM1	EXX
	DJNZ LEM0
	RET

fINTRP	;обработка im1
	EI
	HALT
	DI
	CALL MUSj45+6
	CALL fTITR
	JP fPRESS

Tpos	DEFB 0
fTITR	;выв текущ символа титров
	LD B,6
fQ0	LD HL,Tpos
	LD A,7;(?)
	ADD A,(HL)
	CP 208
	JR C,fQ1
	SUB 208
fQ1	LD (HL),A
	LD C,A
	AND #F
	ADD A,6
	LD D,A
	LD A,C
	RRCA
	RRCA
	RRCA
	RRCA
	AND #F
	ADD A,17
	LD E,A
	LD A,C
	LD HL,(TITadr)
	CALL BA
	LD A,(TITad_)
	CALL BA
	CALL PRINT
	DJNZ fQ0
	LD HL,(TITtim)
	DEC HL
	LD (TITtim),HL
	LD A,L
	OR H
	RET NZ
	LD A,208
	LD (TITad_),A
	RET


fPRESS	;обр нажатий
	;ss+N-next,ss+M-newerending loop,E-ret
	LD BC,#7FFE
	IN A,(C)
	RRA
	RRA
	JR C,fPP1
	RRA
	JR C,fPPnx
fPPR	LD A,(fRlock)
	OR A
	RET NZ
	LD A,(#5800) ;%00110000/%00010000
	XOR %00100000
	LD L,A
	LD H,A
	LD (#5800),HL
	LD (#5820),HL
	LD (fRlock),A
	RET
fPPnx	RRA
	RET C
	LD A,1 ;next flik
	LD (fCOUNT),A
	RET
fPP1	LD B,#FB
	IN E,(C)
	XOR A
	LD (fRlock),A
	BIT 2,E
	RET NZ
	CALL MUSj45+9
	JP START
fRlock	DEFB 0

fCOLOR	;цвета фликов
	DEFB #78,#7A,#60, #69,#38,#68
	DEFB #71,#78,#70, #68,#79,#30
	DEFB #70,#72,#78, #68

WIN	;окно для флика
        incbin "intro/WINFLICK.LPZ"
RNA	DEFW 14
RNB	DEFB 22

RND	PUSH	HL
	LD	HL,(RNA)
	INC	HL
	LD	A,H
	AND	#1F
	LD	H,A
	LD	A,(RNB)
	RRCA
	XOR	(HL)
	ADD	A,L
	LD	(RNA),HL
	LD	(RNB),A
	POP	HL
	RET


LOAD_M	;загр блок мультиков: A
	LD HL,fBLOCK
	INC (HL)
	INC (HL)
	INC (HL)
	LD A,(HL)
	ADD A,A
	ADD A,16
	LD C,-1
	CALL LOA1_M
	CALL LOA1_M
	CALL LOA1_M
	LD B,8
DPZ1	PUSH BC
	LD A,B
	DEC A
	CP 2
	JR Z,DPZ0
	CP 5
	JR Z,DPZ0
	CALL MEM
	LD HL,#C000
	CALL DELPZF
DPZ0	POP BC
	DJNZ DPZ1
	RET

FFONT
        incbin "data/WFONT.FNT"

LOA1_M	INC C
	CALL LOA2_M
LOA2_M	PUSH BC
	PUSH AF
	LD A,C
	CALL MEM
	POP AF
	PUSH AF
	CALL LOADF
	POP AF
	POP BC
	INC C
	INC A
	RET

TITRES  NOP