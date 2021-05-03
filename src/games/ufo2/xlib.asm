;**** HЛО-2. Дьяволы бездны ****
;8F80-xCONV(128)
;9000-теневой экран(6k)
;A800-теневые атрибуты(768)  (128-буф1)
;AB00-MAN+ALIEN(1024)
;AF80-vSIZE(128)
;AF00-xATR(128)
;B000-истребитель(2k) (0,1,2-15)
;B800-НЛО(6k) (16-63)
;D000-ландшафт(4k) (64-95)
;E000-1й этаж(4k)
;F000-2й этаж(4k)

;CПРАЙТЫ: 0-fill 2й этаж;1-fill 1й этаж
;2-15-истребитель(2-vSIZE<4)
;96-127-стоит герой(0-31)

SCR	EQU	#C000
ATR	EQU	#D800
DSCR	EQU	#9000
DATR	EQU	#A800
MAN	EQU     #AB00
ALIEN   EQU	MAN+320
TMP	EQU	DSCR
xATR	EQU     #AF00
vSIZE	EQU	#AF80
xCONV	EQU	#8F80

;****************************************** работа с 3D спрайтами

SH	DEFB	0; Shift 0/8
TX	DEFB	0
TY	DEFB	1
TTX	DEFB	#CD
TTY	DEFB	0
NSH	DEFW	0
UDHL	DEFW	6
XMAX	DEFB 63;макс.коорд
YMAX	DEFB 63
;*L+
B_DAT	;-----данные боя-------------
OLDFLR	DEFB 0
X0	DEFB   63
Y0	DEFB   63
RNB	DEFB 5
RNA	DEFW 1970
NX_RNB	DEFB 0
NX_RNA	DEFW 505
FIRTYP	DEFB 0 ;тип Стрельбы (1-прицельная)
HER_N	DEFB 0 ;NO. текущ героя
HER_AD	DEFW 0 ;адр. его данных
G_TIME	DEFB 0 ;время использ текущ оружия
G_TYPE	DEFB #FF;текущ оружие
SETLEN	EQU 38
SET_N	DEFB 0 ;к-во записей
SETDIM	DEFS 5*SETLEN,#FF ;двери/гранаты (X,Y,Flr,Tmp,Door)/(x,y,Flr,0,0)
B_LEN	EQU   $-B_DAT ;--------------

HER_BA	LD HL,(HER_AD) ;взять поле А
	JP BA

RRT	LD	DE,DSCR+1024 ;скролл вправо
	LD	HL,DSCR+1024+1
	LD	BC,4095
	LDIR
	LD	A,(SH)
	XOR	8
	LD	(SH),A
	JR	NZ,RR8
	LD	HL,X0
	INC	(HL)
	INC	HL
	DEC	(HL)
RR8	LD A,(FLR)
	OR A
	JR NZ,RLN
	INC A
	CALL FLOOR
	CALL RLN
	XOR A
	CALL FLOOR
RLN	LD	DE,(X0)
	LD	A,14
	ADD	A,E
	LD	E,A
	LD	A,-14
	ADD	A,D
	LD	D,A
	LD	A,(SH)
	OR	A
	JR	Z,RL0
	LD	HL,DSCR+29+128
	JR	LL1
RL0	DEC	E
	LD	HL,DSCR+29
	JR	LL1

LRT	LD	DE,DSCR+6143-1024 ;Скролл влево
	LD	HL,DSCR+6142-1024
	LD	BC,4095
	LDDR
	LD	A,(SH)
	XOR	8
	LD	(SH),A
	JR	Z,LR8
	LD	HL,X0
	DEC	(HL)
	INC	HL
	INC	(HL)
LR8	LD A,(FLR)
	OR A
	JR NZ,LLN
	INC A
	CALL FLOOR
	CALL LLN
	XOR A
	CALL FLOOR
LLN	LD	A,(SH)
	LD	DE,(X0)
	OR	A
	JR	NZ,LL0
	LD	HL,DSCR+128+2
	JR	LL1
LL0	LD	HL,DSCR+2
	DEC	D
LL1	LD	(TX),DE
	LD	B,20
LL2	CALL	ASP
	JR 	Z,LL_2
	CALL	LSP
LL_2	LD	DE,128
	ADD	HL,DE
	LD	A,(TY)
	INC	A
	LD	(TY),A
	CALL	ASP
	JR 	Z,LL_3
	CALL	RSP
LL_3	LD	DE,128
	ADD	HL,DE
	LD	A,(TX)
	INC	A
	LD	(TX),A
	DJNZ	LL2
	RET

DRT	LD	DE,DSCR+1024 ;скролл вниз
	LD	HL,DSCR+256+1024
	LD	BC,4096-256
	LDIR
	LD	HL,X0
	INC	(HL)
	INC	HL
	INC	(HL)
	LD A,(FLR)
	OR A
	JR NZ,DLN
	INC A
	CALL FLOOR
	CALL DLN
	XOR A
	CALL FLOOR
DLN	LD	HL,X0
	LD	A,#F
	ADD	A,(HL)
	LD	(TTX),A
	INC	HL
	LD	A,#F
	ADD	A,(HL)
	LD	(TTY),A
	LD	HL,DSCR+4096+768+1
	JR	UL_

URT	LD	DE,DSCR+6143-1024 ;скролл вверх
	LD	HL,DSCR+6143-256-1024
	LD	BC,4096-256
	LDDR
	LD	HL,X0
	DEC	(HL)
	INC	HL
	DEC	(HL)
	LD A,(FLR)
	OR A
	JR NZ,ULN
	INC A
	CALL FLOOR
	CALL ULN
	XOR A
	CALL FLOOR
ULN	LD	HL,(X0)
	LD	(TTX),HL
	LD	HL,DSCR+1024+1
UL_	LD	A,(SH)
	OR	A
	JR	NZ,UL10
	INC	HL
UL10	LD	(UDHL),HL
	LD	HL,96
	LD	(NSH),HL
	LD	C,4
UL0	LD	HL,(UDHL)
	LD	DE,(TTX)
	LD	(TX),DE
	CALL	UDL2
	LD	HL,(UDHL)
	DEC	HL
	LD	DE,(TTX)
	INC	D
	LD	(TX),DE
	CALL	UDL
	LD	HL,(NSH)
	LD	DE,32
	OR	A
	SBC	HL,DE
	LD	(NSH),HL
	LD	HL,(TTX)
	INC	H
	INC	L
	LD	(TTX),HL
	DEC	C
	JR	NZ,UL0
	LD	HL,-16
	LD	(NSH),HL
	LD	HL,(UDHL)
	LD	DE,128
	ADD	HL,DE
	LD	DE,(TTX)
	LD	(TX),DE
	CALL	UDL2
	RET

UDL	LD	B,15
UD0	CALL	ASP
	JR 	Z,U_D0
	CALL	NSP
U_D0	LD	DE,(TX)
	DEC	D
	INC	E
	LD	(TX),DE
	INC	HL
	INC	HL
	DJNZ	UD0
	RET

UDL2	LD	B,15
UD2	CALL	ASP
	JR 	Z,U_D2
	CALL	NSP2
U_D2	LD	DE,(TX)
	DEC	D
	INC	E
	LD	(TX),DE
	INC	HL
	INC	HL
	DJNZ	UD2
	RET

PSP	;задать N спр
	EX AF,AF
	CALL GSP
	CP 2
	RET C
	EXX
	EX AF,AF
	LD (HL),A
	EXX
	RET

ATSP	;получить атрибуты из xATR
	CALL GSP
	AND #7F
ATSP_	EXX
	LD E,A
	LD D,xATR/256
	LD A,(DE)
	EXX
	RET

ATSPM	;взять атрибуты с учётом героев
	CALL GSP
	AND #7F
	CP #60
	JR C,ATSP_
	SUB #60
	EXX
	RLCA
	RLCA
	RLCA
	LD D,0
	SLA A
	RL D
	SLA A
	RL D
	ADD A,7
	LD E,A
	LD A,D
	ADD A,MAN/256
	LD D,A
	LD A,(DE)
	AND #7F
	JR ATSP_+1

GS_4x4	LD	A,63
	CP	H
	DEFB #38,#14 ;JR C,G00
	CP	L
	DEFB #38,#11 ;JR C,G00
	LD	A,L
	RLCA
	RLCA
	SRL	H
	RRA
	SRL 	H
	RRA
	LD	L,A

GS_8x2	LD	A,31
	CP	H
	DEFB #38,#14 ;JR C,G00
	LD 	A,127
	CP	L
	DEFB #38,#0F ;JR C,G00
	RLC 	L
	SRL	H
	RR	L
	NOP
	NOP

SET4x4  LD HL,#3F3F ;уст.поле 64х64
	LD DE,GS_4x4
	JR SETxxx
SET8x2  LD HL,#1F7F ;уст.поле 128х32
	LD DE,GS_8x2
SETxxx	LD (XMAX),HL
	EX DE,HL
	LD DE,GSPdim
	LD BC,18
	LDIR
	RET

GSP     EXX	;получить N спр
	LD	HL,(TX)
GSPdim	LD	A,63
	CP	H
	JR	C,G00
	CP	L
	JR	C,G00
	LD	A,L
	RLCA
	RLCA
	SRL	H
	RRA
	SRL 	H
	RRA
	LD	L,A
GS1	LD	A,#F0 ;map #F000/#E000
	OR	H
	LD	H,A
	LD	A,(HL)
	EXX
	RET
G00	LD	A,1 ;Вне поля
	EXX
	RET

;AinvX-	#AA(XOR D)-норм.,#0(NOP)-только маска
;возвр: Z-0й спрайт DE-адр А-номер
ASP	CALL GSP
	LD D,A
	RLCA
	LD A,(Ainv1)
	JR C,A2P
	OR A
	JR NZ,A22P
	LD A,#AA
	JR A21P
A2P	OR A
	JR Z,A22P
	XOR A
A21P	LD (Ainv1),A
	LD (Ainv2),A
	LD (Ainv3),A
	LD (Ainv4),A
A22P    LD A,D
A22P_	LD E,0
	AND #7F
	PUSH AF
	CP #60
	JR NC,A4P
	SRL A
	RR E
	ADD A,#B0;sprites
	LD D,A
	POP AF
	RET
A4P     POP AF
	SUB #60
	PUSHs;$
	PUSH IX
	CALL GET_IX
	CALL HERLIV
	JR NZ,A7PLIV
	LD A,(IX+4)
	CALL M96
	LD DE,xDIE
	JR A6P
A7PLIV	LD A,(IX+6)	;visi
	OR A		;
	LD A,(IX+7)	;
	JR Z,A9P	;
	POP IX
	POPs;$
	JR A22P_
A9P     CALL NORM_V
	LD A,(IX+3)
	CALL M96
	ADD HL,HL
	LD A,(IX+4)
	RLCA
	LD D,A
	RLCA
	ADD A,D
	ADD A,H
	LD H,A
	LD DE,xHERO
A6P	ADD HL,DE
	PUSH HL
	LD A,(IX+7)
	AND #7F
	LD L,0
	SRL A
	RR L
	ADD A,#B0
	LD H,A
	LD DE,DATR
	LD BC,128
	LDIR
	POP HL
	LD DE,DATR+16
	Ms 4
	LD B,48
A5P	LD A,(DE)
	OR (HL)
	LD (DE),A
	INC DE
	LD A,(DE)
	CPL
	OR (HL)
	CPL
	INC HL
	OR (HL)
	LD (DE),A
	INC DE
	INC HL
	DJNZ A5P
	CALL PT128
	POP IX
	POPs;$
	LD DE,DATR
	LD A,#60
	OR A
	RET;NZ

M96	LD L,A
	RLCA
	ADD A,L	;x3
	RLCA	;x6
	RLCA	;x12
	LD	L,A
	LD	H,0
	ADD	HL,HL ;x24
	ADD	HL,HL ;x48
	ADD	HL,HL ;x96
	RET

MSizeP	pushs;$
	CALL ASP
	JR Z,MSiRET
       ;jr $
	PUSH HL
	LD B,vSIZE/256
	OR #80 ;(vSIZE mod 256)
	LD C,A
	LD A,(BC)
	LD H,0
	ADD A,A
	ADD A,A
	ADD A,A
	LD L,A
	RRCA
	ADD A,E
	LD E,A
	ADD HL,HL
	ADD HL,HL
	LD A,(BC)
	POP BC
	ADD HL,BC
	CPL
	ADD A,33
	LD B,A
	JP MS2

BSP	pushs;$
	JP	MS2

NSP	pushs;$
	LD	BC,(NSH)
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	LD	B,8
	JP	MS2

NSP2	pushs;$
	EX	DE,HL
	LD	BC,(NSH)
	ADD	HL,BC
	LD	BC,16
	ADD	HL,BC
	EX	DE,HL
	LD	B,4
	LD	A,(NSH)
	CP	96
	JR	Z,MS2
	CP	-16
	JR	Z,MS2
	LD	B,8
	JP	MS2

MSP	pushs;$
	LD	B,32
MS2	LD	(MSPSP+1),SP
	EX	DE,HL
	LD	SP,HL
	EX	DE,HL
MS20    POP	DE
	LD	A,(HL)
	OR	E
Ainv1	XOR	D
	LD	(HL),A
	INC	HL
	POP	DE
	LD	A,(HL)
	OR	E
Ainv2	XOR	D
	LD	(HL),A
	LD	DE,31
	ADD	HL,DE
	DJNZ	MS20
MSPSP	LD	SP,#4020
MSiRET	pops;$
	RET

LSP	pushs;$
	LD	B,32
LS2     LD	(LSPSP+1),SP
	EX	DE,HL
	LD	SP,HL
	EX	DE,HL
LS20	POP	DE
	LD	A,(HL)
	OR	E
Ainv3	XOR	D
	LD	(HL),A
	POP	DE
	LD	DE,32
	ADD	HL,DE
	DJNZ	LS20
LSPSP	LD	SP,#4020
	pops;$
	RET

RSP	pushs;$
	LD	B,32
RS2     LD	(RSPSP+1),SP
	EX	DE,HL
	LD	SP,HL
	EX	DE,HL
RS20	POP	DE
	POP	DE
	LD	A,(HL)
	OR	E
Ainv4	XOR	D
	LD	(HL),A
	LD	DE,32
	ADD	HL,DE
	DJNZ	RS20
RSPSP	LD	SP,#4020
	pops;$
	RET

RSPB	pushs;$
	JR	RS2

LSPB	pushs;$
	JR	LS2

ALLSPF	LD A,(FLR) ;вывод обоих этажей
	OR A
	JR NZ,ALLSP
	INC A
	CALL FLOOR
	CALL ALLSP
	XOR A
	CALL FLOOR
ALLSP	LD	HL,DSCR+128+2
	LD	A,(SH)
	OR	A
	JR	Z,AP1
	DEC	HL
AP1	LD	DE,(X0)
	LD	(TX),DE
	LD	C,20
AP2	LD	B,15
	PUSH	DE
AP3	CALL	MSizeP
	LD	DE,(TX)
	INC	E
	DEC	D
	LD	(TX),DE
	INC	HL
	INC	HL
	DJNZ	AP3
	LD	DE,128-30-1
	ADD	HL,DE
	POP	DE
	INC	D
	LD	(TX),DE
	PUSH	DE
	LD	B,15
AP4	CALL	MSizeP
	LD	DE,(TX)
	INC	E
	DEC	D
	LD	(TX),DE
	INC	HL
	INC	HL
	DJNZ	AP4
	LD	DE,128-30+1
	ADD	HL,DE
	POP	DE
	INC	E
	LD	(TX),DE
	DEC	C
	JR	NZ,AP2
	RET

DSC3	LD	B,8
	PUSH	DE
DS3	PUSH	DE
	PUSH	BC
	INC DE
	LDI
	LDI
	LDI
	LDI;4
	LDI
	LDI
	LDI
	LDI;8
	LDI
	LDI
	LDI
	LDI;12
	LDI
	LDI
	LDI
	LDI;16
	LDI
	LDI
	LDI
	LDI;20
	LDI
	LDI
	LDI
	LDI;24
	LDI
	LDI
	LDI
	LDI;28
	LD	DE,4
	ADD	HL,DE
	POP	BC
	POP	DE
	INC	D
	DJNZ	DS3
	POP	DE
	LD	A,32
	ADD	A,E
	LD	E,A
	DEC	C
	JR	NZ,DSC3
	RET

OUTDSC	CALL	MEM7
	LD	DE,SCR+32
	LD	HL,DSCR+1024+2
	LD	C,7
	CALL	DSC3
	LD	DE,SCR+2048
	LD	C,8
	CALL	DSC3
	LD	DE,SCR+4096
	LD C,1
	CALL	DSC3
	JP  PT128

FLR	EQU	G00+1 	;этаж 1-1й 0-2й
FLOOR	OR A ;сменить этаж на А(0-2Й;1-1Й)
	LD A,(FLR)
	JR NZ,FLO2
	OR A
	RET Z
	XOR A ;2й
	LD (FLR),A
	PUSH BC
	LD C,3
	LD A,#E0
FLO_  	LD (GS1+1),A
	LD A,(X0)
	ADD A,C
	LD (X0),A
	LD A,(Y0)
	ADD A,C
	LD (Y0),A
	POP BC
	RET
FLO2	OR A
	RET NZ
	INC A
	LD (FLR),A
	PUSH BC
	LD C,-3
	LD A,#F0
	JR FLO_

LCOUNT	LD DE,vSIZE ;подсчёт высоты
	LD HL,#B000
	LD B,96
LCX	PUSH BC
	PUSH HL
	LD BC,#1F00
LCX0	LD A,(HL)
	OR A
	JR NZ,LCX2
	INC HL
	INC HL
	LD A,(HL)
	OR A
	JR NZ,LCX2
	INC HL
	INC HL
	INC C
	DJNZ LCX0
LCX2	LD A,C
	LD (DE),A
	INC DE
	POP HL
	LD BC,128
	ADD HL,BC
	POP BC
	DJNZ LCX
	XOR A
	LD (DE),A
	RET

