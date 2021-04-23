;*L+
;*** IO FOR UFO2: A-N(1..) HL-START DE-LENTGTH / CY=0 - ERROR
SIDE	DEFB	0

POS	LD A,(SIDE)
	OR A
	LD	A,#3C
	JR	Z,DW_SID
	RES	4,A
DW_SID	LD	C,#FF
	CALL	RG_DOS
	LD	A,D
	LD	C,#7F
	CALL	RG_DOS
	LD	A,#18
	LD	C,#1F
	CALL	RG_DOS
	CALL	COM_EX
	DI
	RET

RD_SCT	LD	BC,RD_SCT
	PUSH	BC
	LD	BC,#17F
	LD	IX,#2090
	JR	DOS

RG_DOS	LD	IX,#2A53
	JR	DOS

COM_EX	LD	IX,#3EF5
DOS	PUSH	IX
	JP	#3D2F

ERR_RW	SCF
	RET

READ1	CALL	D_READ
	RET	NC
	LD	A,(SIDE)
	XOR #FF
	LD	(SIDE),A
	LD A,12
	JR NZ,RTR1
	NEG
RTR1	ADD A,D
	LD D,A
	CALL	TR000
	JR	READ1

TR000	CALL TR0
TR0	CALL TR00
TR00	DI
	LD	IX,#2F5F
	CALL	DOS
	LD	IX,#2F65
	JP	DOS

READ	;A-No., HL - adr
	LD D,0
	CP 73
	JR C,REA0
	INC D
REA0	LD (X0),HL
	LD HL,X_LEN-2
	CALL WA
	PUSH AF
	PUSH HL
	LD E,A
	LD L,5
	CALL DIVB2
	LD A,D
	LD D,E
	INC D
	INC D
	INC D
	INC D
	ADD A,#F4
	LD E,A
	LD B,1
	LD HL,(X0)
	PUSH HL
	XOR A
	LD (SIDE),A
	CALL READ1
	LD (FREE16),DE
	POP DE
	POP HL
	INC HL
	PUSH HL
	LD L,(HL)
	LD H,0
	ADD HL,HL
	ADD HL,HL
	PUSH HL
	ADD HL,DE
	LD BC,1024
	PUSH BC
	LDIR
	POP HL
	POP BC
	OR A
	SBC HL,BC
	LD BC,(X0)
	ADD HL,BC
	POP DE
	INC DE
	LD A,(DE)
	POP BC
	SUB B
	RET Z
	LD B,A
	LD DE,(FREE16)
	JP READ1

D_WRITE DI
LOPWR	CALL	POS
LOPWR1	PUSH	HL
	PUSH	BC
	LD	C,#5F
	LD	A,E
	CALL	RG_DOS
	CALL	WR_SC
	POP	BC
	POP	HL
	INC	E
	INC	H
	DJNZ	LOPWR
	RET

WR_SC	LD	A,#A0
	LD	IX,#2FC3
	CALL	DOS
	LD	IX,#3FCA
	LD	C,#7F
	JP	DOS

D_READ	DI ;E-sec,D-trk,B-sec.num,HL-mem.adr
	CALL	POS
	LD	A,(#5CD6)
	EX	AF,AF'
NXT_S	DEFB	#DD
	LD	L,#3 ;retry.num
NXT_SC	PUSH	HL
	PUSH	BC
NXC_C1	PUSH	IX
	LD	C,#5F
	LD	A,E
	CALL	RG_DOS
	CALL	RD_SCT
	DI
	LD	HL,#5CD6
	EX	AF,AF'
	CP	(HL)
	POP	IX
	JR	Z,GOOD
	LD	(HL),A
	DEFB	#DD
	DEC	L
	POP	BC
	POP	HL
	JP	Z,ERR_RW
	EX	AF,AF'
	JR	NXT_SC
GOOD	POP	BC
	POP	HL
	EX	AF,AF'
GOOD1	INC	E
	LD	A,E
	CP	#F9
	JR	C,OLD_TR
	LD	E,#F4
	INC	D
	CALL	POS
OLD_TR	INC	H
	INC	H
	INC	H
	INC	H
	DJNZ	NXT_S
	XOR	A
	RET

;----------------------------------------------------------
S_T100	DEFW #101 ;сектор 1..16; трек 1 or 3

BUF100 ;--------- таблица защиты ---- EQU ATR+768 ---------
 DEFB #43,#7E,#90,#70,#45,#C1,#22,#E0,#F5,#3B,#ED,#F0,#4C,#C4,#E2,#2D
 DEFB #46,#0C,#61,#72,#88,#78,#14,#0C,#7F,#54,#6D,#93,#FD,#C1,#6E,#AB
 DEFB #6E,#14,#F0,#C5,#0E,#13,#11,#7B,#4B,#B9,#E3,#3D,#06,#92,#C4,#3C
 DEFB #58,#C8,#B7,#C5,#73,#A8,#69,#19,#3B,#87,#80,#89,#9B,#07,#32,#E4

 DEFB #98,#09,#1D,#0A,#88,#09,#49,#38,#98,#07,#31,#1E,#88,#07,#50,#3F
 DEFB #B8,#05,#3D,#26,#98,#05,#4D,#3A,#88,#05,#5A,#49,#88,#03,#49,#38
 DEFB #A0,#B5,#CE,#AC,#BC,#84,#0E,#49,#62,#76,#81,#97,#6D,#25,#30,#49
 DEFB #60,#B8,#88,#2A,#25,#F7,#24,#17,#52,#25,#9D,#6B,#B1,#8F,#35,#20

 DEFB #39,#AD,#73,#C6,#11,#44,#88,#58,#12,#3D,#38,#4D,#C5,#4D,#5E,#88
 DEFB #58,#FE,#D9,#27,#CB,#06,#E0,#A2,#9D,#AC,#70,#5A,#55,#69,#AB,#AF
 DEFB #A3,#CF,#4D,#93,#51,#7C,#8D,#BE,#86,#48,#83,#61,#D9,#F4,#05,#39
 DEFB #07,#C7,#12,#F6,#4A,#6D,#BC,#88,#8C,#60,#C0,#80,#CB,#77,#58,#E3

 DEFB #CB,#0A,#50,#82,#5E,#A6,#EC,#E7,#F0,#8B,#E3,#18,#AB,#9E,#DC,#24
 DEFB #CE,#09,#02,#35,#30,#E7,#F0,#8B,#E3,#57,#8A,#94,#BB,#9C,#27,#8F
 DEFB #C4,#9B,#BC,#48,#26,#51,#26,#2F,#B9,#F5,#DB,#FC,#88,#E6,#D9,#F3
 DEFB #6F,#70,#0B,#63,#64,#00,#6E,#6F,#F8,#B6,#8E,#3C,#17,#24,#18,#E8,#11


LD100	;загр 100 бт блока в ТАВ100
	LD HL,(TAB100+98)
	LD BC,#ACCE
	XOR A
	SBC HL,BC
	RET Z ;уже загружено
	XOR A
	LD (SIDE),A
L101	LD HL,BUF100
	LD B,1
	LD DE,(S_T100)
	CALL D_READ
	JR C,L100er
	LD HL,(BUF100+98)
	LD BC,#ACCE ;последние два байта
	XOR A
	SBC HL,BC
	JR Z,L100ok
L100er	LD HL,(S_T100)
	INC L
	LD A,L
	CP 16
	JR C,L102
	LD L,1
	LD A,H
	XOR %10
	LD H,A
L102	LD (S_T100),HL
	CALL TR000
	JP L101
L100ok	LD DE,TAB100
	LD HL,BUF100
	LD BC,100
	LDIR
	SCF
	RET

PROTEC	;A- N нач данных
	LD	HL,TAB100+64
	CALL DD
	LD	A,1
	LD	(SIDE),A
	LD A,(HL)
	INC HL
	LD D,(HL)
	SRL D
	INC HL
	PUSH HL
	RRCA
	RRCA
	RRCA
	LD E,A
	LD	HL,INTR
	LD	B,1
	PUSH	DE
	CALL	D_WRITE
	POP	DE
	LD	HL,BUF100
	LD	B,1
	CALL	D_READ
U102	LD	B,255
	LD	DE,INTR
	LD	HL,BUF100
U100	LD	A,(DE)
	CP	(HL)
	JR	NZ,U101
	INC	HL
	INC	HL
	INC	DE
	INC	DE
	DJNZ	U100
	PUSH	HL
	CALL	READ ;сектор целый
	CALL	PT128
U101	POP	HL
	LD	A,B
	CP	252
	RET	NC ;сектор не найден /retry
	ADD	A,8
	SUB	(HL)
	CP	20
	JR	NC,U102 ;царапина не на месте
	POP	HL
	RET	C ;норм выход

P_BLK	DEFB 0 ;номер блока для проверки 0,1,4,5
RETRY	DEFB 9 ;к-во попыток

;*L+
TR_SEC	; ПРВЕРКА ЗАЩИТЫ - номера tr sec для PROTEC
	CALL MEM7
	CALL L100ok ;-------------------LD100---|
	CALL CHECK3
	RET ;---------без проверки защиты--|
	CALL CLR_P
	CALL RND
	AND %101
	LD (P_BLK),A
TR_RTR	CALL PROTEC
	CALL TR000
	CALL CLR_P
	LD A,(P_BLK)
	XOR %10
	LD (P_BLK),A
	LD HL,RETRY
	DEC (HL)
	JR NZ,TR_RTR
	Ms 1	;превышено число попыток
	LD DE,SCR
	LDIR
	CALL LDASM2
	CALL MLOOP
	db "эТО ОНo"

X_LEN
;*F xdisk2 ; sec_No(1), sec_Shift(1)
        include "xdisk2.asm"
;3,246, 15,13  LEN=278580

CLR_P	LD HL,BUF100
	LD BC,511
	PUSH HL
	POP DE
	INC DE
	LD (HL),#FE
	LDIR
	RET
