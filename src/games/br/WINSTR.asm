;******** "ЧЁРНЫЙ ВОРОН" - МОДУЛЬ ИНСТРУКЦИИ ********
;пока не работает - TODO
;лежит в 4000+
FONT42
        incbin "data/wnf1.fnt"
        incbin "data/wnf2.fnt"

WTR	EI
	HALT
	HALT
	DI
	RET

WT	RLCA
	ADD	A,L
	LD	L,A
	JR	NC,JA_
	INC	H
JA_	LD	A,(HL)
	INC HL
	LD H,(HL)
	LD L,A
	RET

PIC_T	DEFW PICbeg,PIC1,PIC2
DLPPIC	;A-N экр
	PUSH AF
	LD DE,#4000
	LD HL,PIC_T
	CALL WT
	INC HL
	INC HL
	CALL DELPZ
	POP AF
	CALL ATRIB
	CALL SW5
	CALL MEM7
	CALL COPY
SW70	CALL SW7
	JP MEM0

ATR_T	DEFB #69,#28,#39
ATRIB	PUSH AF
	LD HL,ATR_T
	CALL BA
	LD HL,#5800
	LD (HL),A
	LD DE,#5801
	LD BC,#2FF
	LDIR
	POP AF
	OR A
	RET NZ
	LD HL,#58A0 ;для текста
	LD DE,#58A1
	LD BC,#23F
	LD (HL),#44
	LDIR
	JP TEXT

KEYS	;0-none ;1..5 - <1>..<5> ;6-<A> ;7-<Q> ;8-<E>;9-<O>;10-<P>
	LD BC,#F7FE
	IN A,(C)
	CPL
	AND %11111
	JR Z,K768
	LD C,1
	RRA
	JR C,K1_5
	INC C
	RRA
	JR C,K1_5
	INC C
	RRA
	JR C,K1_5
	INC C
	RRA
	JR C,K1_5
	INC C
K1_5	LD A,C
	OR A
	RET
K768	LD B,#FD
	IN A,(C)
	RRA
	JR C,K78
	LD A,6
	OR A
	RET
K78	LD B,#FB
	IN A,(C)
	RRA
	JR C,K8
	LD A,7
	OR A
	RET
K8	RRA
	RRA
	JR C,Kop
	LD A,8
	OR A
	RET
Kop	LD B,#DF
	IN A,(C)
	RRA
	JR C,K10
	LD A,9
	OR A
	RET
K10	RRA
	JR C,Knon
	LD A,10
	OR A
	RET
Knon	XOR A
	RET

WAIT	CALL KEYS
	JR NZ,WAIT
	LD BC,#88
WA2	DEC BC
	LD A,C
	OR B
	JR NZ,WA2
	RET

;===========================

bINSTR	
        CALL SW70
XI00	XOR A
	OUT (#FE),A
	CALL DLPPIC
XI0	CALL TEXT
XI1	CALL COPY18
XI2	CALL KEYS
	JR Z,XI2
	CP 6
	JR NC,XI3
	CP 3
	JR NC,XI2
	CALL DLPPIC
	CALL WAIT
	CALL WTR
	CALL OFFS
	JR XI00
XI3	CP 7
	JR Z,XI4
	JR C,XI5
	CP 9
	JR Z,XI8
	JR NC,XI9
	;CALL MEM7
	;CALL OFFS
	;CALL OFFD
	;CALL MEM0
	;JP bFLAG
        jp press_quit

XI4	CALL PgUp
	JR XI0
XI5	CALL PgDwn
	JR XI0
XI9	CALL LnUp
	LD HL,(TXT1)
	LD DE,Instr
	XOR A
	SBC HL,DE
	JR Z,XI0
	CALL _UP18
	CALL TEXT1
	JR XI1

XI8	CALL LnDwn
	CALL _DW18
	LD B,22-5
	LD HL,(TXT1)
XD2	LD A,(HL)
	INC HL
	CP 127
	JR Z,XI1
	CP 126
	JR NZ,XD2
	DJNZ XD2
	LD DE,(TXT1)
	PUSH DE
	LD (TXT1),HL
	CALL TEXTe
	POP HL
	LD (TXT1),HL
	JP XI1

LnUp	LD B,2
	JR _Up
PgUp	LD B,24-5
_Up	LD HL,(TXT1)
	LD DE,Instr
PU1	LD A,L
	CP E
	JR NZ,PU0
	LD A,H
	CP D
	JR NZ,PU0
	LD (TXT1),DE
	RET
PU0	DEC HL
	LD A,(HL)
	CP 126
	JR NZ,PU1
	DJNZ PU1
	INC HL
	LD (TXT1),HL
	RET

LnDwn	LD B,1
	JR _Dwn
PgDwn	LD B,23-5
_Dwn	LD HL,(TXT1)
PD1	LD A,(HL)
	INC HL
	CP 127
	RET Z
	CP 126
	JR NZ,PD1
	DJNZ PD1
	LD (TXT1),HL
	RET

WORDHL	LD	(TXT),HL
WORD	LD	HL,(TXT)
	LD	A,(HL)
	INC	HL
	LD	(TXT),HL
	CP	#80
	JR	NC,Compr
	CP	#7E
	RET	NC
	CALL	LETTER
	JR	WORD
Compr	AND	#7F
	LD HL,INCMPR
	CALL WT
	PUSH HL
	LD A,L
	CALL LETTER
	POP HL
	LD A,H
	CALL LETTER
	JR WORD

LETTER	OR A
	JR Z,W2
	LD	L,A
	LD	H,0
;	LD	A,(SY)
;	CP	24
;	JR	NC,W2
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,FONT42
	ADD	HL,BC
	PUSH	HL
	LD A,(SY)
	LD HL,YT
	CALL WT
	EX DE,HL
	LD A,(SX)
	LD C,A
	LD HL,XDT
	CALL BA
	LD L,A
	LD H,0
	ADD HL,DE
	POP	DE
	LD B,8
	LD A,C
	AND 3
	JP Z,L00
	CP 2
	JP Z,L04
	JP C,L06
	JP L02
W2	LD	A,(SX)
	INC	A
	CP	42
	JR	C,W3
	XOR	A
W3	LD	(SX),A
	RET

YT	DEFW #4000,#4020,#4040,#4060,#4080,#40A0,#40C0,#40E0
	DEFW #4800,#4820,#4840,#4860,#4880,#48A0,#48C0,#48E0
	DEFW #5000,#5020,#5040,#5060,#5080,#50A0,#50C0,#50E0

L00	LD A,(DE)
	LD (HL),A
	INC H
	INC DE
	DJNZ L00
	JP W2

L02	LD A,(DE)
	RRCA
	RRCA
	LD C,A
	AND %111111
	OR (HL)
	LD (HL),A
	INC L
	LD A,C
	AND %11000000
	OR (HL)
	LD (HL),A
	DEC L
	INC H
	INC DE
	DJNZ L02
	JP W2

L04	LD A,(DE)
	RRCA
	RRCA
	RRCA
	RRCA
	LD C,A
	AND %1111
	OR (HL)
	LD (HL),A
	INC L
	LD A,C
	AND %11110000
	OR (HL)
	LD (HL),A
	DEC L
	INC H
	INC DE
	DJNZ L04
	JP W2

L06	LD A,(DE)
	RLCA
	RLCA
	LD C,A
	AND %11
	OR (HL)
	LD (HL),A
	INC L
	LD A,C
	AND %11111100
	OR (HL)
	LD (HL),A
	DEC L
	INC H
	INC DE
	DJNZ L06
	JP W2

TEXT1	LD HL,#500
	LD A,6
	JR _TEXT

TEXTe	LD HL,#1600
	LD A,23
	JR _TEXT

TEXT	CALL _OFF18
	LD HL,#500
	LD A,23
_TEXT	LD (TXE+1),A
	LD	(SX),HL  ;выв.текста
	LD HL,(TXT1)
	LD (TXT),HL
TT	CALL	WORD
	RET NZ
	LD	HL,(SX)
	LD	L,0
	INC	H
	LD	(SX),HL
	LD A,H
TXE	CP 23
	JR C,TT
	RET

TXT1	DEFW Instr
SX	DEFB 2
SY	DEFB 1
TXT	DEFW 1

XDT	DEFB 0,0,1,2,3,3,4,5,6,6,7,8,9,9,10,11,12,12
	DEFB 13,14,15,15,16,17,18,18,19,20,21,21,22,23
	DEFB 24,24,25,26,27,27,28,29,30,30,30,30
INCMPR
        incbin "data/winstrcm.dat"

COPY	CALL MEM7
	LD HL,#4000
	LD DE,SCR
	LD BC,#1B00
	LDIR
	JP MEM0

COPY18	;копир 18 строк
	CALL MEM7
	LD HL,#40A0
	LD DE,#C0A0
	LD B,3
	CALL cpy_18
	LD B,8
	LD HL,#4800
	LD DE,#C800
	CALL cpy_18
	LD B,7
	LD HL,#5000
	LD DE,#D000
	CALL cpy_18
	JP MEM0

cpy_18	PUSHs
	LD A,8
cpy1	PUSH HL
	PUSH DE
	LDI
	LDI
	LDI
	LDI;0
	LDI
	LDI
	LDI
	LDI;1
	LDI
	LDI
	LDI
	LDI;2
	LDI
	LDI
	LDI
	LDI;3
	LDI
	LDI
	LDI
	LDI;4
	LDI
	LDI
	LDI
	LDI;5
	LDI
	LDI
	LDI
	LDI;6
	LDI
	LDI
	LDI
	LDI;7
	POP DE
	POP HL
	INC H
	INC D
	DEC A
	JR NZ,cpy1
	POPs
	LD A,E
	ADD A,32
	LD E,A
	LD L,A
	DJNZ cpy_18
	RET

_OFF18	;очист 18 строк
	LD E,0
	LD HL,#40A0
	LD C,3
	CALL off_18
	LD C,8
	LD HL,#4800
	CALL off_18
	LD C,7
	LD HL,#5000
	CALL off_18
	JP MEM0

off_18	PUSH HL
	LD B,8
off1	PUSH HL
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E ;
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	INC L
	LD (HL),E
	POP HL
	INC H
	DEC A
	DJNZ off1
	POP HL
	LD A,L
	ADD A,32
	LD L,A
	DEC C
	JR NZ,off_18
	RET

_DW18	LD DE,#40A0
	LD HL,#40C0
	LD B,18
_U00	CALL MOVlin
	LD A,E
	ADD A,32
	LD E,A
	JR NC,_U01
	LD A,D
	ADD A,8
	LD D,A
_U01	LD A,L
	ADD A,32
	LD L,A
	JR NC,_U02
	LD A,H
	ADD A,8
	LD H,A
_U02	DJNZ _U00
	LD E,0
	LD C,1
	LD HL,#50C0
	JP off_18

_UP18	LD DE,#50C0
	LD HL,#50A0
	LD B,18
_D00	CALL MOVlin
	LD A,E
	SUB 32
	LD E,A
	JR NC,_D01
	LD A,D
	SUB 8
	LD D,A
_D01	LD A,L
	SUB 32
	LD L,A
	JR NC,_D02
	LD A,H
	SUB 8
	LD H,A
_D02	DJNZ _D00
	LD E,0
	LD C,1
	LD HL,#40A0
	JP off_18


MOVlin	PUSHs
	LD A,8
_MVLL	PUSH HL
	PUSH DE
	LDI
	LDI
	LDI
	LDI;0
	LDI
	LDI
	LDI
	LDI;1
	LDI
	LDI
	LDI
	LDI;2
	LDI
	LDI
	LDI
	LDI;3
	LDI
	LDI
	LDI
	LDI;4
	LDI
	LDI
	LDI
	LDI;5
	LDI
	LDI
	LDI
	LDI;6
	LDI
	LDI
	LDI
	LDI;7
	POP DE
	POP HL
	INC D
	INC H
	DEC A
	JR NZ,_MVLL
	POPs
	RET


PICbeg
        incbin "data/winstr0.lpz"
PIC1
        incbin "data/winstr1.lpz"
PIC2
        incbin "data/winstr2.lpz"


Instr
        incbin "data/winstr.dat" ;текст зашифрован, оригинала нет, есть конвертор из оригинала на C, но не наоборот

