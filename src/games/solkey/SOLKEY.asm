;
	;ORG	#9300
;
GO
L_9300	DI
	LD	SP,#0000
	XOR	A
	OUT	(#FE),A
	LD	(L_A390),A
	XOR	A
	LD	(L_C256),A
	LD	(L_CF6F),A
	LD	HL,L_C21F
	LD	DE,L_C220
	LD	(HL),#30
	LD	BC,#0005
	LDIR
	LD	A,#06
	LD	(L_C255),A
	CALL	L_C2D9
	CALL	MakeScreenYTable
	CALL	Menu
L_932C	
        CALL	L_C257
	CALL	L_CB6A
	CALL	L_D3BF
	CALL	L_9B30
	CALL	L_C1A3
	CALL	L_ACBA
	CALL	L_B2AB
	CALL	L_AD74
	CALL	L_AF97
	CALL	L_A3AC
	CALL	L_B425
	CALL	L_B5D2
	CALL	L_B78A
	CALL	L_BABE
	CALL	L_C9E8
	CALL	L_D1B5
	CALL	L_CD02
	CALL	L_AFA9
	CALL	L_AD86
	CALL	L_CFA2
	CALL	L_CDF8
	CALL	L_D0DE
	CALL	L_B22E
	XOR	A
	LD	(L_A8C2),A
	LD	(L_C899),A
	LD	(L_C72B),A
	LD	(L_D7BE),A
	LD	A,(L_A390)
	CP	#03
	JR	Z,L_9392
	CP	#0B
	JR	Z,L_9392
	CP	#10
	JR	Z,L_9392
	LD	HL,#2710
	JR	L_93A1
;
L_9392	LD	DE,#2010
	CALL	L_CF70
	LD	DE,#20E0
	CALL	L_CF70
	LD	HL,#4E20
L_93A1	LD	(L_C295),HL
	LD	(L_C297),HL
L_93A7	XOR	A
	LD	(L_95D2),A
	LD	HL,L_9478
	INC	(HL)
	CALL	L_9738
	LD	HL,L_95F6
	LD	(L_95F4),HL
	LD	(HL),#FF
	CALL	ReadControls
	CALL	L_A9BA
	LD	HL,L_AB57
	LD	(L_AB55),HL
	LD	(HL),#FF
	LD	HL,L_BFF1
	LD	(L_BFEF),HL
	LD	(HL),#FF
	CALL	L_C33C
	CALL	L_AB46
	CALL	L_A3BE
	CALL	L_CB9F
	CALL	L_AD94
	CALL	L_AFB7
	CALL	L_AB0E
	CALL	L_CE4F
	CALL	L_C299
	CALL	L_C2E7
	CALL	L_CBE8
	CALL	L_CF0A
	CALL	L_D03F
	CALL	L_D7C6
	CALL	L_A7B9
	CALL	L_C67A
	CALL	L_C72D
	CALL	L_C89B
	CALL	L_ACCC
	CALL	L_B32B
	CALL	L_AEE7
	CALL	L_B271
	CALL	L_B111
	CALL	L_B4D8
	CALL	L_B676
	CALL	L_B8AB
	CALL	L_BBDF
	CALL	L_CEE0
	CALL	L_CA68
	CALL	L_CFC0
	CALL	L_D120
	CALL	L_D259
	CALL	L_D3EF
	CALL	L_C0A6
	CALL	L_B306
	CALL	L_B437
	CALL	L_B79C
	CALL	L_BAD0
	CALL	L_AEC2
	CALL	L_B0EB
	CALL	L_B651
	CALL	L_CA43
	CALL	L_D234
	CALL	L_9697
	CALL	L_9490
	CALL	L_94AF
	CALL	L_94A5
	LD	A,(L_9478)
	AND	#01
	JP	NZ,L_93A7
	LD	DE,L_FFF6
	LD	HL,(L_C295)
	ADD	HL,DE
	LD	(L_C295),HL
	CALL	L_C257
	CALL	L_C1CE
	JP	L_93A7
;
L_9478       DB       #F1
;
       DB       #CD,#9F,#F6,#21,#90,#A3,#B7,#C8       ;M.v!.#7H
       DB       #FE,#39,#28,#07,#FE,#30,#C0,#34       ;~9(.~0@4
       DB       #C3,#2C,#93,#35,#C3,#2C,#93       ;C,.5C,.
;
L_9490	LD	A,(L_95D2)
	LD	B,A
	LD	A,#0A
	SUB	B
	RET	C
	RET	Z
	LD	B,A
L_949A	PUSH	BC
	LD	BC,#01F4
	CALL	PauseBC
	POP	BC
	DJNZ	L_949A
	RET
;
L_94A5	LD	A,#FB
	IN	A,(#FE)
	AND	#1F ;qwert
	JP	Z,L_9300
	RET
;
L_94AF	LD	A,#FE
	IN	A,(#FE)
	AND	#01
	RET	NZ
	LD	A,#7F
	IN	A,(#FE)
	AND	#02
	RET	NZ
	LD	BC,#01F4
	CALL	PauseBC
	CALL	WaitNoKey
L_94C6	CALL	L_F69F
	OR	A
	JR	Z,L_94C6
	RET
;
L_94CD	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,L_DE22
	ADD	HL,BC
	LD	(L_95E3),SP
	LD	SP,HL
	LD	A,E
	AND	#07
	ADD	A,A
	LD	L,A
	LD	H,#00
	LD	BC,L_95D3
	ADD	HL,BC
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	IX,#0000
	ADD	IX,BC
	LD	L,D
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	D,#73
L_9502       EQU       $-1
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	E,A
	ADD	HL,DE
	LD	(L_9566),HL
	LD	B,#10
L_9510	POP	DE
	SCF
	LD	C,#FF
	JP	(IX)
;
L_9516	RL	D
	RL	E
	RL	C
L_951C	RL	D
	RL	E
	RL	C
L_9522	RL	D
	RL	E
	RL	C
L_9528	RL	D
	RL	E
	RL	C
	LD	A,C
	AND	(HL)
	LD	(HL),A
	INC	HL
	LD	A,E
	AND	(HL)
	LD	(HL),A
	INC	HL
	LD	A,D
	AND	(HL)
	LD	(HL),A
	LD	DE,#001E
	ADD	HL,DE
	DJNZ	L_9510
	JP	L_9565
;
L_9542	RR	E
	RR	D
	RR	C
L_9548	RR	E
	RR	D
	RR	C
L_954E	RR	E
	RR	D
	RR	C
L_9554	LD	A,E
	AND	(HL)
	LD	(HL),A
	INC	HL
	LD	A,D
	AND	(HL)
	LD	(HL),A
	INC	HL
	LD	A,C
	AND	(HL)
	LD	(HL),A
	LD	DE,#001E
	ADD	HL,DE
	DJNZ	L_9510
L_9565	LD	HL,#830F
L_9566       EQU       $-2
	LD	DE,#005E
	ADD	IX,DE
	LD	B,#10
L_956F	POP	DE
	LD	C,#00
	JP	(IX)
;
	SLA	D
	RL	E
	RL	C
	SLA	D
	RL	E
	RL	C
	SLA	D
	RL	E
	RL	C
	SLA	D
	RL	E
	RL	C
	LD	A,C
	OR	(HL)
	LD	(HL),A
	INC	HL
	LD	A,E
	OR	(HL)
	LD	(HL),A
	INC	HL
	LD	A,D
	OR	(HL)
	LD	(HL),A
	LD	DE,#001E
	ADD	HL,DE
	DJNZ	L_956F
	JP	L_95C3
;
	SRL	E
	RR	D
	RR	C
	SRL	E
	RR	D
	RR	C
	SRL	E
	RR	D
	RR	C
	LD	A,E
	OR	(HL)
	LD	(HL),A
	INC	HL
	LD	A,D
	OR	(HL)
	LD	(HL),A
	INC	HL
	LD	A,C
	OR	(HL)
	LD	(HL),A
	LD	DE,#001E
	ADD	HL,DE
	DJNZ	L_956F
L_95C3	LD	SP,(L_95E3)
	LD	HL,L_95D2
	INC	(HL)
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_95D2       DB       #05
;
L_95D3       DW       L_9554
       DW       L_954E
       DW       L_9548
       DW       L_9542
       DW       L_9516
       DW       L_951C
       DW       L_9522
       DW       L_9528
L_95E3       DW       L_FFEE
;
L_95E5	PUSH	HL
	LD	HL,(L_95F4)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),#FF
	LD	(L_95F4),HL
	POP	HL
	RET
;
L_95F4       DW       L_9612
;
L_95F6       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#48,#90,#48,#90
       DB       #38,#70,#B8,#70,#68,#20,#6B,#20
       DB       #80,#80,#7F,#80
L_9612       DB       #FF,#40,#54,#40,#BE,#B0,#C0,#B0
       DB       #FF,#40,#FF,#30,#FF,#78,#FF,#30
       DB       #FF,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00
;
L_9697	LD	HL,L_95F6
L_969A	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	PUSH	HL
	CALL	L_96A9
	POP	HL
	JR	L_969A
;
L_96A9	LD	A,D
	CP	#08
	JP	C,L_96F0
	LD	L,D
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	B,#73
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	C,A
	ADD	HL,BC
	PUSH	HL
	CALL	CountScreenAddr_bytable_DEyx
	EX	DE,HL
	POP	HL
	LD	BC,L_FFFF
	LD	A,#10
L_96CC	EX	AF,AF' ;'
	LDI
	LDI
	LDI
	DEC	DE
	DEC	DE
	DEC	DE
	INC	D
	LD	A,D
	AND	#07
	JR	NZ,L_96E6
	LD	A,E
	ADD	A,#20
	LD	E,A
	JR	C,L_96E6
	LD	A,D
	SUB	#08
	LD	D,A
L_96E6	LD	BC,#001D
	ADD	HL,BC
	EX	AF,AF' ;'
	DEC	A
	JP	NZ,L_96CC
	RET
;
L_96F0	LD	A,D
	CPL
	AND	#07
	INC	A
	ADD	A,D
	LD	D,A
	LD	L,D
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	B,#73
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	C,A
	ADD	HL,BC
	PUSH	HL
	CALL	CountScreenAddr_bytable_DEyx
	EX	DE,HL
	POP	HL
	LD	BC,L_FFFF
	LD	A,#10
L_9714	EX	AF,AF' ;'
	LDI
	LDI
	LDI
	DEC	DE
	DEC	DE
	DEC	DE
	INC	D
	LD	A,D
	AND	#07
	JR	NZ,L_972E
	LD	A,E
	ADD	A,#20
	LD	E,A
	JR	C,L_972E
	LD	A,D
	SUB	#08
	LD	D,A
L_972E	LD	BC,#001D
	ADD	HL,BC
	EX	AF,AF' ;'
	DEC	A
	JP	NZ,L_9714
	RET
;
L_9738	LD	HL,L_95F6
L_973B	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	PUSH	HL
	CALL	L_974A
	POP	HL
	JR	L_973B
;
L_974A	LD	L,D
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	D,#5B
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	E,A
	ADD	HL,DE
	PUSH	HL
	LD	DE,#1800
	ADD	HL,DE
	EX	DE,HL
	POP	HL
	LD	BC,L_FFFF
	LD	A,#10
L_9768	LDI
	LDI
	LDI
	LD	BC,#001D
	ADD	HL,BC
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	DEC	A
	JP	NZ,L_9768
	RET
;
DrawSprite
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	CountScrAddr_DEyx
	LD	BC,#9000
	ADD	HL,BC
	LD	(HL),A
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,L_DDC2
	ADD	HL,BC
	LD	(L_95E3),SP
	LD	SP,HL
	LD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	D,#5B
	ADD	HL,DE
	LD	A,#10
	LD	BC,#001F
L_97AB	POP	DE
	LD	(HL),E
	INC	HL
	LD	(HL),D
	ADD	HL,BC
	DEC	A
	JP	NZ,L_97AB
	LD	SP,(L_95E3)
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_97BD	LD	HL,#5B00
	LD	DE,#7300
	LD	BC,#1800
	LDIR
	RET
;
       DB       #21,#00,#73,#11,#00,#5B,#01,#00       ;!.s..[..
       DB       #18,#ED,#B0,#C9       ;.m0I
;
L_97D5	LD	HL,#7300
	LD	DE,#4000
	LD	B,#C0
L_97DD	PUSH	BC
	PUSH	DE
	LD	BC,#0020
	LDIR
	POP	DE
	POP	BC
	EX	DE,HL
	CALL	DownHL
	EX	DE,HL
	DJNZ	L_97DD
	RET
;
L_97EE	PUSH	DE
	PUSH	AF
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	E,A
	LD	A,D
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	D,A
	CALL	CountScrAddr_DEyx
	LD	DE,#8D00
	ADD	HL,DE
	POP	AF
	POP	DE
	RET
;
CountScrAddr_DEyx
	PUSH	AF
	LD	A,D
	SRA	A
	SRA	A
	SRA	A
	LD	H,A
	LD	A,D
	AND	#07
	RRCA
	RRCA
	RRCA
	ADD	A,E
	LD	L,A
	POP	AF
	RET
;
L_981B	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CALL	CountScrAddr_DEyx
	LD	DE,#5800
	ADD	HL,DE
	LD	DE,#001F
	LD	(HL),C
	INC	L
	LD	(HL),C
	ADD	HL,DE
	LD	(HL),C
	INC	L
	LD	(HL),C
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_9835	PUSH	BC
	PUSH	HL
	LD	HL,tkeys
	LD	D,#FE
L_983C	LD	A,D
	IN	A,(#FE)
	LD	E,#01
	LD	B,#05
L_9843	RRCA
	JR	NC,L_984F
	INC	HL
	SLA	E
	DJNZ	L_9843
	RLC	D
	JR	C,L_983C
L_984F	LD	A,(HL)
	POP	HL
	POP	BC
	RET
;
tkeys
       DB       #01
       DM       "ZXCVASDFGQWERT1234509876POIUY"
       DB       #0D
       DM       "LKJH "
       DB       #02
       DM       "MNB"
       DB       #00
;
WaitNoKey
	XOR	A
	IN	A,(#FE)
	CPL
	AND	#1F
	JR	NZ,WaitNoKey
	RET
;
       DB       #3E,#F7,#DB,#FE,#E6,#1F,#FE,#1B       ;>w[~f.~.
       DB       #C0,#01,#F4,#01,#CD,#1A,#99,#CD       ;@.t.M..M
       DB       #7C,#98,#C3,#00,#00       ;|.C..
;
L_989A	PUSH	HL
	PUSH	DE
	PUSH	BC
	LD	HL,(L_98B5)
	LD	DE,#0007
	ADD	HL,DE
	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,HL
	LD	C,L
	LD	B,H
	ADD	HL,HL
	ADD	HL,BC
	ADD	HL,DE
	LD	(L_98B5),HL
	XOR	H
	POP	BC
	POP	DE
	POP	HL
	RET
;
L_98B5       DW       L_AB61
;
Cls
	LD	C,#00
Cls_attrC
	LD	HL,#5AFF
	LD	DE,#5AFE
	LD	(HL),C
	LD	BC,#0300
	LDDR
	LD	(HL),#00
	LD	BC,#17FF
	LDDR
	RET
;
MakeScreenYTable
	LD	IX,screenYtable;#8B00
	LD	IY,screenYtable+256;#8C00
	LD	HL,#4000
	LD	B,#C0
L_98DA	LD	(IX+#00),H
	LD	(IY+#00),L
	CALL	DownHL
	INC	IX
	INC	IY
	DJNZ	L_98DA
	RET
;
CountScreenAddr_bytable_DEyx
	PUSH	AF
	LD	L,D
	LD	H,screenYtable/256;#8B
	LD	A,(HL)
	INC	H
	LD	L,(HL)
	LD	H,A
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	ADD	A,L
	LD	L,A
	POP	AF
	RET
;
DownHL	INC	H
	LD	A,H
	AND	#07
	RET	NZ
	LD	A,L
	ADD	A,#20
	LD	L,A
	RET	C
	LD	A,H
	SUB	#08
	LD	H,A
	RET
;
       DB       #7C,#25,#E6,#07,#C0,#7D,#D6,#20       ;|%f.@}V 
       DB       #6F,#D8,#7C,#C6,#08,#67,#C9       ;oX|F.gI
;
PauseBC
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	HL,#0000
	LD	DE,#0000
	LDIR
	POP	HL
	POP	DE
	POP	BC
	RET
;
PrintString_HL
	LD	A,(HL)
	INC	HL
	CP	#61
	JP	NC,L_9937
	CALL	PrintChar
printstring_printcharaddr=$-2
	INC	E
	JP	PrintString_HL
;
L_9937	CP	#90
	JP	NC,L_9947
	SUB	#78
	ADD	A,D
	LD	D,A
	LD	A,(HL)
	ADD	A,E
	LD	E,A
	INC	HL
	JP	PrintString_HL
;
L_9947	CP	#CF
	JP	NC,L_9954
	INC	D
	SUB	#AF
	ADD	A,E
	LD	E,A
	JP	PrintString_HL
;
L_9954	CP	#DF
	JP	NC,L_996D
	SUB	#CF
	CP	#08
	JP	C,L_9964
	SUB	#08
	OR	#40
L_9964	LD	B,A
	LD	A,C
	AND	#38
	OR	B
	LD	C,A
	JP	PrintString_HL
;
L_996D	CP	#DF
	JP	NZ,L_9979
	LD	D,(HL)
	INC	HL
	LD	E,(HL)
	INC	HL
	JP	PrintString_HL
;
L_9979	CP	#E0
	JP	NZ,L_9983
	LD	C,(HL)
	INC	HL
	JP	PrintString_HL
;
L_9983	CP	#E1
	JP	NZ,L_998F
	LD	B,(HL)
	INC	HL
L_998A	PUSH	HL
	PUSH	BC
	JP	PrintString_HL
;
L_998F	CP	#E2
	JP	NZ,L_999F
	POP	BC
	DJNZ	L_999B
	POP	AF
	JP	PrintString_HL
;
L_999B	POP	HL
	JP	L_998A
;
L_999F	CP	#E3
	JP	NZ,L_99B5
	LD	A,(HL)
	INC	HL
	PUSH	HL
	LD	H,(HL)
	LD	L,A
	PUSH	BC
	PUSH	DE
	CALL	PrintString_HL
	POP	DE
	POP	BC
	POP	HL
	INC	HL
	JP	PrintString_HL
;
L_99B5	CP	#E4
	JP	NZ,L_99C7
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
L_99BD	CALL	PrintChar
L_99BE       EQU       $-2
	INC	E
	DJNZ	L_99BD
	INC	HL
	JP	PrintString_HL
;
L_99C7	CP	#E5
	JP	NZ,L_99D9
	LD	B,(HL)
	INC	HL
	LD	A,(HL)
L_99CF	CALL	PrintChar
L_99D0       EQU       $-2
	INC	D
	DJNZ	L_99CF
	INC	HL
	JP	PrintString_HL
;
L_99D9	CP	#E6
	JR	NZ,L_99EA
	LD	A,(HL)
	LD	(L_9A57),A
	INC	HL
	LD	A,(HL)
	LD	(L_9A58),A
	INC	HL
	JP	PrintString_HL
;
L_99EA	CP	#E7
	JR	NZ,L_9A07
	PUSH	HL
	LD	HL,(L_9A57)
	PUSH	HL
	LD	HL,L_D712
	LD	(L_9A57),HL
	LD	A,#20
	CALL	PrintChar
L_99FC       EQU       $-2
	INC	E
	POP	HL
	LD	(L_9A57),HL
	POP	HL
	JP	PrintString_HL
;
L_9A07	CP	#E8
	JR	NZ,L_9A13
	LD	A,(HL)
	LD	(L_9AA6),A
	INC	HL
	JP	PrintString_HL
;
L_9A13	CP	#E9
	JR	NZ,L_9A1A
	JP	PrintString_HL
;
L_9A1A	CP	#EA
	JR	NZ,L_9A21
	JP	PrintString_HL
;
L_9A21	CP	#EB
	RET	NZ
	PUSH	BC
	PUSH	HL
	LD	L,(HL)
	LD	H,#00
	ADD	HL,HL
	LD	BC,L_9A44
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	(printstring_printcharaddr),HL
	LD	(L_99BE),HL
	LD	(L_99D0),HL
	LD	(L_99FC),HL
	POP	HL
	POP	BC
	INC	HL
	JP	PrintString_HL
;
L_9A44       DW       PrintChar
       DW       DrawSprite
       DW       L_9A82
       DW       L_9ABA
;
PrintChar
	PUSH	AF
	PUSH	DE
	PUSH	HL
	PUSH	BC
	ADD	A,A
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,L_DCDA
L_9A57       EQU       $-2
L_9A58       EQU       $-1
	ADD	HL,BC
	LD	A,D
	AND	#F8
	OR	#40
	LD	B,A
	LD	A,D
	LD	D,B
	AND	#07
	RRCA
	RRCA
	RRCA
	ADD	A,E
	LD	E,A
	LD	B,#08
L_9A6B	LD	A,(HL)
	LD	(DE),A
	INC	D
	INC	HL
	DJNZ	L_9A6B
	DEC	D
	LD	A,D
	RRCA
	RRCA
	RRCA
	AND	#03
	OR	#58
	LD	H,A
	LD	L,E
	POP	BC
	LD	(HL),C
	POP	HL
	POP	DE
	POP	AF
	RET
;
L_9A82	PUSH	HL
	PUSH	DE
	PUSH	AF
	LD	A,#5B
	LD	(L_9502),A
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A
	LD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	D,A
	POP	AF
	CALL	L_94CD
	POP	DE
	PUSH	AF
	PUSH	DE
	CALL	L_981B
	CALL	CountScrAddr_DEyx
	LD	DE,#8D00
	ADD	HL,DE
	LD	A,#01
L_9AA6       EQU       $-1
	LD	(HL),A
	INC	HL
	LD	(HL),A
	LD	DE,#001F
	ADD	HL,DE
	LD	(HL),A
	INC	HL
	LD	(HL),A
	LD	A,#73
	LD	(L_9502),A
	POP	DE
	POP	AF
	POP	HL
	RET
;
L_9ABA	PUSH	AF
	PUSH	HL
	PUSH	BC
	PUSH	DE
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	BC,(L_9A57)
	ADD	HL,BC
	PUSH	HL
	LD	H,D
	LD	L,#00
	LD	D,#5B
	ADD	HL,DE
	POP	DE
	LD	BC,#0020
	LD	A,#08
L_9AD6	EX	AF,AF'
	LD	A,(DE)
	LD	(HL),A
	INC	DE
	ADD	HL,BC
	EX	AF,AF'
	DEC	A
	JP	NZ,L_9AD6
	POP	DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(L_9AA6)
	LD	(HL),A
	LD	BC,L_CB00
	ADD	HL,BC
	POP	BC
	LD	(HL),C
	POP	HL
	POP	AF
	RET
;
       DB       #F5,#E5,#C5,#D5,#ED,#73,#2E,#9B       ;ueEUms..
       DB       #6F,#26,#00,#29,#29,#29,#ED,#4B       ;o&.)))mK
       DB       #57,#9A,#09,#F9,#62,#2E,#00,#16       ;W..yb...
       DB       #73,#19,#01,#20,#00,#D1,#73,#09       ;s.. .Qs.
       DB       #72,#09,#D1,#73,#09,#72,#09,#D1       ;r.Qs.r.Q
       DB       #73,#09,#72,#09,#D1,#73,#09,#72       ;s.r.Qs.r
       DB       #ED,#7B,#2E,#9B,#D1,#C1,#E1,#F1       ;m{..QAaq
       DB       #C9,#00,#00       ;I..
;
L_9B30	LD	A,(L_A390)
	CP	#04
	JR	Z,L_9B3B
	XOR	A
	LD	(L_C3AB),A
L_9B3B	CALL	L_A391
	LD	A,(L_A390)
	ADD	A,A
	LD	L,A
	LD	H,#00
	LD	BC,L_9C03
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(L_A8C6),DE
	XOR	A
	LD	(L_9AA6),A
	LD	A,(L_A390)
	LD	BC,L_9C53
	CALL	GetHLFrom2APlusBC
	LD	DE,#0000
	LD	BC,#0000
	CALL	PrintString_HL
	CALL	L_C34E
	OR	A
	JR	NZ,L_9B81
	CALL	CountXYtoxy_DE
	LD	A,#2F
	CALL	L_9A82
	CALL	L_C33C
	CALL	CountXYtoxy_DE
	LD	A,#1D
	CALL	L_9A82
	JR	L_9B8C
;
L_9B81	CALL	L_C33C
	CALL	CountXYtoxy_DE
	LD	A,#01
	CALL	L_9A82
L_9B8C	CALL	L_CB7C
	CALL	L_D3D1
	LD	C,#47
	CALL	Cls_attrC
	CALL	L_9BB2
	LD	HL,L_9C2D
	CALL	PrintString_HL
	CALL	L_97BD
	JP	L_97D5
;
GetHLFrom2APlusBC
	PUSH	AF
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	ADD	HL,BC
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	POP	AF
	RET
;
L_9BB2	LD	A,#1C
	LD	(L_9BFC),A
	LD	(L_9BFD),A
	LD	A,#02
	LD	(L_9AA6),A
	LD	A,(L_A390)
	LD	BC,L_9FE6
	CALL	GetHLFrom2APlusBC
	LD	C,#45
L_9BCA	LD	A,(HL)
	CP	#FF
	RET	Z
	CP	#FE
	JR	NZ,L_9BE1
	LD	A,(L_9AA6)
	XOR	#03
	LD	(L_9AA6),A
	LD	A,C
	XOR	#03
	LD	C,A
	INC	HL
	JR	L_9BF1
;
L_9BE1	CP	#FD
	JR	NZ,L_9BF1
	LD	A,(L_9BFC)
	XOR	#08
	LD	(L_9BFC),A
	LD	(L_9BFD),A
	INC	HL
L_9BF1	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	A,#00
L_9BF9	CALL	L_9A82
L_9BFC	INC	E
L_9BFD	INC	E
	DJNZ	L_9BF9
	JP	L_9BCA
;
L_9C03       DB       #48,#90,#18,#80,#38,#30,#28,#80
       DB       #E8,#60,#18,#50,#68,#B0,#78,#B0
       DB       #28,#B0,#48,#B0,#58,#B0,#28,#80
       DB       #78,#90,#58,#B0,#78,#B0,#D8,#B0
       DB       #28,#80,#00,#00,#00,#00,#00,#00
       DB       #18,#20
L_9C2D       DB       #EB,#03,#E6,#EA,#D9,#E8,#01,#DF
       DB       #00,#00,#E0,#44,#E1,#06,#00,#AE
       DB       #01,#AE,#02,#AE,#03,#AE,#E2,#DF
       DB       #00,#1F,#E1,#06,#00,#AE,#01,#AE
       DB       #02,#AE,#03,#AE,#E2,#FF
;
L_9C53       DW       L_9C7D
       DW       L_9CA2
       DW       L_9CD1
       DW       L_9CFC
       DW       L_9D2B
       DW       L_9D5A
       DW       L_9D89
       DW       L_9DC1
       DW       L_9DF9
       DW       L_9E32
       DW       L_9E67
       DW       L_9E93
       DW       L_9EC2
       DW       L_9EFA
       DW       L_9F26
       DW       L_9F55
       DW       L_9F89
       DW       L_9FB8
       DW       L_9FB9
       DW       L_9FBA
       DW       L_9FBB
;
L_9C7D       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#FF
L_9CA2       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#02
       DB       #03,#1C,#DF,#02,#07,#1C,#FF
L_9CD1       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#02
       DB       #0B,#1C,#FF
L_9CFC       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#14
       DB       #05,#1C,#DF,#14,#19,#1C,#FF
L_9D2B       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#04
       DB       #07,#1C,#DF,#04,#17,#1C,#FF
L_9D5A       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#02
       DB       #07,#1C,#DF,#02,#19,#1C,#FF
L_9D89       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#DF,#12,#03,#E1
       DB       #07,#02,#78,#03,#E2,#EB,#02,#DF
       DB       #02,#05,#1C,#DF,#02,#19,#1C,#FF
L_9DC1       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#DF,#12,#03,#E1
       DB       #07,#02,#78,#03,#E2,#EB,#02,#DF
       DB       #00,#09,#1C,#DF,#00,#17,#1C,#FF
L_9DF9       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#DF,#12,#03,#E1
       DB       #07,#02,#78,#03,#E2,#EB,#02,#DF
       DB       #02,#0D,#1C,#DF,#02,#11,#1C,#FF
       DB       #FF
L_9E32       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#DF,#12,#03,#E1
       DB       #07,#02,#78,#03,#E2,#EB,#02,#DF
       DB       #00,#0B,#1C,#FF,#FF
L_9E67       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#10
       DB       #05,#1C,#FF,#FF
L_9E93       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#14
       DB       #05,#1C,#DF,#14,#19,#1C,#FF
L_9EC2       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#DF,#12,#03,#E1
       DB       #07,#02,#78,#03,#E2,#EB,#02,#DF
       DB       #02,#05,#1C,#DF,#02,#19,#1C,#FF
L_9EFA       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#00
       DB       #01,#1C,#FF,#FF
L_9F26       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#02
       DB       #0D,#1C,#DF,#02,#11,#1C,#FF
L_9F55       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#DF,#10,#03,#E1
       DB       #07,#02,#78,#03,#E2,#EB,#02,#DF
       DB       #12,#01,#1C,#FF
L_9F89       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#14
       DB       #05,#1C,#DF,#14,#19,#1C,#FF
L_9FB8       DB       #FF
L_9FB9       DB       #FF
L_9FBA       DB       #FF
L_9FBB       DB       #DF,#00,#01,#EB,#01,#E1,#06,#E1
       DB       #07,#00,#78,#01,#01,#78,#01,#E2
       DB       #00,#78,#01,#7A,#E2,#E1,#07,#01
       DB       #78,#01,#00,#78,#01,#E2,#01,#78
       DB       #01,#7A,#E2,#E2,#EB,#02,#DF,#02
       DB       #1B,#1C,#FF
;
L_9FE6       DW       L_A010
       DW       L_A05A
       DW       L_A080
       DW       L_A0DD
       DW       L_A115
       DW       L_A135
       DW       L_A140
       DW       L_A178
       DW       L_A1D2
       DW       L_A1E9
       DW       L_A23C
       DW       L_A26E
       DW       L_A2A6
       DW       L_A2EF
       DW       L_A311
       DW       L_A346
       DW       L_A347
       DW       L_A37F
       DW       L_A380
       DW       L_A381
       DW       L_A382
;
L_A010       DB       #0D,#06,#03,#0B,#08,#01,#13,#08
       DB       #01,#0D,#0A,#03,#0D,#0C,#03,#09
       DB       #10,#01,#07,#12,#01,#09,#14,#01
       DB       #0B,#12,#05,#15,#10,#01,#17,#12
       DB       #01,#15,#14,#01,#FE,#0B,#06,#01
       DB       #13,#06,#01,#0B,#0A,#01,#13,#0A
       DB       #01,#07,#10,#01,#0B,#10,#01,#07
       DB       #14,#01,#0B,#14,#01,#13,#10,#01
       DB       #17,#10,#01,#13,#14,#01,#17,#14
       DB       #01,#FF
L_A05A       DB       #19,#06,#02,#15,#08,#02,#11,#0A
       DB       #02,#0B,#0E,#03,#07,#10,#07,#03
       DB       #12,#02,#FE,#03,#06,#02,#07,#08
       DB       #02,#0B,#0A,#02,#11,#0E,#02,#15
       DB       #10,#02,#19,#12,#02,#FF
L_A080       DB       #0D,#02,#03,#0F,#04,#01,#17,#04
       DB       #01,#1B,#08,#01,#17,#0C,#02,#1D
       DB       #0C,#01,#1B,#0E,#01,#03,#0C,#04
       DB       #03,#0E,#02,#03,#12,#01,#0B,#12
       DB       #05,#0D,#14,#01,#11,#14,#01,#FE
       DB       #0D,#00,#03,#0D,#04,#01,#11,#04
       DB       #01,#0D,#06,#03,#03,#08,#0C,#03
       DB       #0A,#04,#15,#0A,#03,#15,#0C,#01
       DB       #07,#0E,#02,#15,#0E,#03,#0B,#10
       DB       #05,#0B,#14,#01,#13,#14,#01,#03
       DB       #16,#09,#FD,#01,#00,#0C,#1D,#00
       DB       #06,#1D,#0E,#05,#FF
L_A0DD       DB       #0B,#00,#01,#0F,#00,#01,#13,#00
       DB       #01,#0B,#04,#01,#13,#04,#01,#01
       DB       #02,#03,#05,#04,#01,#01,#06,#03
       DB       #19,#02,#03,#19,#04,#01,#19,#06
       DB       #03,#03,#0C,#01,#1B,#0C,#01,#07
       DB       #12,#04,#11,#12,#04,#FE,#05,#12
       DB       #01,#0F,#12,#01,#19,#12,#01,#FF
L_A115       DB       #09,#12,#01,#15,#12,#01,#FE,#01
       DB       #06,#02,#1B,#06,#02,#17,#0E,#04
       DB       #01,#0E,#04,#0B,#0A,#01,#13,#0A
       DB       #01,#0F,#06,#01,#0F,#0E,#01,#FF
L_A135       DB       #FE,#03,#08,#01,#03,#0C,#01,#0B
       DB       #12,#05,#FF
L_A140       DB       #1D,#02,#01,#19,#04,#02,#17,#06
       DB       #01,#13,#0A,#01,#0F,#0E,#01,#15
       DB       #02,#01,#11,#06,#01,#0D,#0A,#01
       DB       #09,#0E,#01,#01,#12,#03,#03,#14
       DB       #01,#01,#16,#02,#FE,#05,#08,#02
       DB       #17,#04,#01,#13,#08,#02,#0F,#0C
       DB       #02,#0B,#10,#02,#07,#14,#02,#FF
L_A178       DB       #05,#04,#05,#05,#10,#05,#11,#04
       DB       #05,#11,#10,#05,#09,#08,#01,#07
       DB       #0A,#01,#0B,#0A,#01,#09,#0C,#01
       DB       #15,#08,#01,#13,#0A,#01,#17,#0A
       DB       #01,#15,#0C,#01,#FD,#03,#06,#05
       DB       #1B,#06,#05,#0F,#06,#05,#FE,#03
       DB       #04,#01,#0F,#04,#01,#1B,#04,#01
       DB       #03,#10,#01,#0F,#10,#01,#1B,#10
       DB       #01,#07,#08,#01,#0B,#08,#01,#07
       DB       #0C,#01,#0B,#0C,#01,#13,#08,#01
       DB       #17,#08,#01,#13,#0C,#01,#17,#0C
       DB       #01,#FF
L_A1D2       DB       #FE,#0D,#08,#01,#11,#08,#01,#0D
       DB       #0C,#01,#11,#0C,#01,#0D,#10,#01
       DB       #11,#10,#01,#0F,#16,#01,#FF
L_A1E9       DB       #0D,#04,#02,#0B,#08,#04,#15,#08
       DB       #01,#1D,#08,#01,#09,#0C,#02,#07
       DB       #10,#04,#15,#10,#01,#19,#10,#01
       DB       #05,#14,#01,#FE,#03,#04,#01,#07
       DB       #04,#01,#0B,#04,#01,#11,#04,#01
       DB       #0D,#08,#01,#13,#08,#01,#17,#08
       DB       #01,#1B,#08,#01,#03,#0C,#01,#07
       DB       #0C,#01,#0D,#0C,#01,#05,#10,#01
       DB       #0F,#10,#01,#13,#10,#01,#17,#10
       DB       #01,#1B,#10,#01,#03,#14,#01,#07
       DB       #14,#01,#FF
L_A23C       DB       #05,#0A,#03,#07,#14,#01,#15,#12
       DB       #01,#FE,#05,#08,#05,#0D,#0A,#01
       DB       #0F,#0C,#02,#13,#0E,#01,#15,#10
       DB       #01,#05,#0C,#03,#0B,#0E,#01,#0D
       DB       #10,#02,#0F,#12,#02,#11,#14,#03
       DB       #15,#16,#01,#01,#10,#02,#07,#10
       DB       #01,#FF
L_A26E       DB       #0B,#00,#01,#0F,#00,#01,#13,#00
       DB       #01,#0B,#04,#01,#13,#04,#01,#01
       DB       #02,#03,#05,#04,#01,#01,#06,#03
       DB       #19,#02,#03,#19,#04,#01,#19,#06
       DB       #03,#03,#0C,#01,#1B,#0C,#01,#07
       DB       #12,#04,#11,#12,#04,#FE,#05,#12
       DB       #01,#0F,#12,#01,#19,#12,#01,#FF
L_A2A6       DB       #FD,#0B,#00,#03,#13,#00,#03,#FD
       DB       #0D,#06,#03,#07,#0C,#02,#0D,#0E
       DB       #01,#11,#0E,#01,#15,#0C,#02,#07
       DB       #12,#02,#0D,#14,#01,#11,#14,#01
       DB       #15,#12,#02,#FE,#0B,#06,#01,#13
       DB       #06,#01,#05,#0C,#01,#0B,#0C,#01
       DB       #0F,#0E,#01,#13,#0C,#01,#19,#0C
       DB       #01,#05,#12,#01,#0B,#12,#01,#0F
       DB       #14,#01,#13,#12,#01,#19,#12,#01
       DB       #FF
L_A2EF       DB       #FE,#01,#04,#04,#05,#08,#06,#01
       DB       #0C,#04,#07,#10,#06,#01,#14,#04
       DB       #FD,#0D,#06,#09,#FE,#09,#08,#01
       DB       #0D,#0A,#01,#03,#0C,#01,#09,#10
       DB       #01,#FF
L_A311       DB       #03,#0E,#02,#FD,#01,#10,#04,#05
       DB       #10,#04,#03,#14,#01,#FD,#19,#0E
       DB       #02,#FD,#19,#10,#04,#1D,#10,#04
       DB       #1B,#14,#01,#FE,#0B,#06,#02,#09
       DB       #0A,#02,#07,#0E,#05,#01,#0E,#01
       DB       #13,#06,#02,#15,#0A,#02,#17,#0E
       DB       #05,#1D,#0E,#01,#FF
L_A346       DB       #FF
L_A347       DB       #0B,#00,#01,#0F,#00,#01,#13,#00
       DB       #01,#0B,#04,#01,#13,#04,#01,#01
       DB       #02,#03,#05,#04,#01,#01,#06,#03
       DB       #19,#02,#03,#19,#04,#01,#19,#06
       DB       #03,#03,#0C,#01,#1B,#0C,#01,#07
       DB       #12,#04,#11,#12,#04,#FE,#05,#12
       DB       #01,#0F,#12,#01,#19,#12,#01,#FF
L_A37F       DB       #FF
L_A380       DB       #FF
L_A381       DB       #FF
L_A382       DB       #FE,#01,#06,#0B,#09,#0A,#0B,#01
       DB       #0E,#0B,#09,#12,#0B,#FF
;
L_A390       DB       #00
;
L_A391	LD	HL,#5B00
	LD	(HL),#00
	LD	DE,#5B01
	LD	BC,#2FFF
	LDIR
	LD	HL,#8D00
	LD	DE,#8D01
	LD	BC,#05FF
	LD	(HL),#00
	LDIR
	RET
;
L_A3AC	LD	A,(L_A390)
	LD	BC,L_A3E4
	CALL	GetHLFrom2APlusBC
	LD	DE,L_A3CF
	LD	BC,#0014
	LDIR
	RET
;
L_A3BE	LD	HL,L_A3CF
L_A3C1	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	CALL	L_AB46
	JP	L_A3C1
;
L_A3CF       DB       #FF,#18,#10,#38,#10,#FF,#58,#10
       DB       #FF,#28,#A0,#C8,#A0,#FF,#38,#20
       DB       #B8,#20,#FF,#38,#FF
;
L_A3E4       DW       L_A40E
       DW       L_A40F
       DW       L_A414
       DW       L_A417
       DW       L_A41C
       DW       L_A421
       DW       L_A426
       DW       L_A42B
       DW       L_A430
       DW       L_A435
       DW       L_A438
       DW       L_A43B
       DW       L_A440
       DW       L_A445
       DW       L_A448
       DW       L_A44D
       DW       L_A450
       DW       L_A455
       DW       L_A456
       DW       L_A457
       DW       L_A458
;
L_A40E       DB       #FF
L_A40F       DB       #18,#10,#38,#10,#FF
L_A414       DB       #58,#10,#FF
L_A417       DB       #28,#A0,#C8,#A0,#FF
L_A41C       DB       #38,#20,#B8,#20,#FF
L_A421       DB       #38,#10,#C8,#10,#FF
L_A426       DB       #28,#10,#C8,#10,#FF
L_A42B       DB       #48,#00,#B8,#00,#FF
L_A430       DB       #68,#10,#88,#10,#FF
L_A435       DB       #58,#00,#FF
L_A438       DB       #28,#80,#FF
L_A43B       DB       #28,#A0,#C8,#A0,#FF
L_A440       DB       #C8,#10,#28,#10,#FF
L_A445       DB       #08,#00,#FF
L_A448       DB       #68,#10,#88,#10,#FF
L_A44D       DB       #08,#90,#FF
L_A450       DB       #28,#A0,#C8,#A0,#FF
L_A455       DB       #FF
L_A456       DB       #FF
L_A457       DB       #FF
L_A458       DB       #D8,#10,#FF
L_A45B       DB       #78,#10,#D8,#80,#98,#60,#C8,#80
       DB       #18,#60,#D8,#50,#08,#A0,#A8,#50
       DB       #D8,#B0,#18,#40,#D8,#A0,#C8,#80
       DB       #78,#10,#08,#B0,#18,#B0,#D8,#10
       DB       #C8,#80,#00,#00,#00,#00,#00,#00
       DB       #D8,#B0
L_A485       DB       #A8,#90,#00,#D8,#20,#00,#A8,#80
       DB       #00,#78,#80,#00,#78,#50,#00,#78
       DB       #50,#00,#E8,#30,#00,#48,#50,#00
       DB       #78,#60,#00,#C8,#40,#00,#68,#70
       DB       #00,#78,#80,#00,#78,#60,#00,#28
       DB       #10,#00,#D8,#B0,#00,#C8,#B0,#00
       DB       #78,#80,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#38,#20,#00,#FF
;
L_A4C5       DW       L_A4EF
       DW       L_A510
       DW       L_A519
       DW       L_A526
       DW       L_A52B
       DW       L_A544
       DW       L_A555
       DW       L_A566
       DW       L_A5A3
       DW       L_A5C4
       DW       L_A5DD
       DW       L_A5EA
       DW       L_A5F3
       DW       L_A608
       DW       L_A625
       DW       L_A64A
       DW       L_A677
       DW       L_A678
       DW       L_A679
       DW       L_A67A
       DW       L_A67B
;
L_A4EF       DB       #68,#40,#48,#01,#78,#40,#4C,#01
       DB       #88,#40,#48,#01,#68,#50,#40,#02
       DB       #78,#50,#41,#02,#88,#50,#40,#02
       DB       #28,#50,#47,#01,#C8,#50,#47,#01
       DB       #FF
L_A510       DB       #88,#50,#48,#02,#78,#20,#4C,#01
       DB       #FF
L_A519       DB       #B8,#60,#44,#02,#18,#90,#48,#02
       DB       #C8,#10,#4C,#01,#FF
L_A526       DB       #B8,#20,#46,#02,#FF
L_A52B       DB       #88,#A0,#44,#01,#68,#A0,#4C,#01
       DB       #78,#40,#41,#01,#78,#60,#44,#01
       DB       #68,#50,#47,#01,#88,#50,#47,#01
       DB       #FF
L_A544       DB       #78,#10,#4C,#01,#68,#80,#40,#01
       DB       #88,#80,#40,#01,#28,#50,#60,#02
       DB       #FF
L_A555       DB       #18,#A0,#4C,#02,#D8,#B0,#48,#01
       DB       #B8,#60,#44,#01,#C8,#60,#44,#01
       DB       #FF
L_A566       DB       #78,#10,#4C,#01,#38,#30,#3F,#01
       DB       #58,#30,#3F,#01,#28,#40,#3F,#01
       DB       #68,#40,#3F,#01,#28,#60,#3F,#01
       DB       #68,#60,#47,#01,#98,#30,#3F,#01
       DB       #B8,#30,#3F,#01,#88,#40,#3F,#01
       DB       #C8,#40,#44,#01,#88,#60,#47,#01
       DB       #C8,#60,#44,#01,#08,#B0,#4A,#02
       DB       #78,#50,#43,#02,#FF
L_A5A3       DB       #78,#40,#4C,#01,#68,#50,#43,#01
       DB       #78,#50,#43,#02,#88,#50,#43,#01
       DB       #68,#70,#43,#01,#78,#70,#43,#02
       DB       #88,#70,#43,#01,#78,#80,#48,#01
       DB       #FF
L_A5C4       DB       #98,#B0,#47,#01,#B8,#B0,#47,#01
       DB       #D8,#B0,#47,#01,#A8,#B0,#4A,#02
       DB       #C8,#B0,#60,#02,#18,#10,#4C,#01
       DB       #FF
L_A5DD       DB       #58,#20,#46,#01,#A8,#90,#44,#02
       DB       #18,#A0,#5F,#01,#FF
L_A5EA       DB       #98,#20,#46,#02,#68,#90,#60,#02
       DB       #FF
L_A5F3       DB       #28,#30,#44,#01,#C8,#30,#44,#01
       DB       #88,#70,#48,#02,#68,#70,#4C,#02
       DB       #78,#50,#5E,#01,#FF
L_A608       DB       #48,#20,#5E,#01,#78,#50,#47,#01
       DB       #88,#50,#47,#01,#78,#60,#47,#01
       DB       #88,#60,#47,#01,#78,#70,#47,#01
       DB       #88,#70,#47,#01,#FF
L_A625       DB       #18,#20,#47,#01,#18,#30,#42,#01
       DB       #D8,#20,#47,#01,#D8,#30,#42,#01
       DB       #18,#80,#44,#01,#18,#90,#44,#01
       DB       #48,#B0,#48,#01,#A8,#B0,#48,#01
       DB       #78,#10,#4A,#01,#FF
L_A64A       DB       #38,#70,#47,#01,#78,#70,#47,#01
       DB       #38,#80,#47,#01,#48,#80,#47,#01
       DB       #68,#80,#47,#01,#78,#80,#47,#01
       DB       #38,#90,#47,#01,#58,#90,#47,#01
       DB       #78,#90,#47,#01,#38,#A0,#47,#01
       DB       #78,#A0,#47,#01,#FF
L_A677       DB       #FF
L_A678       DB       #FF
L_A679       DB       #FF
L_A67A       DB       #FF
L_A67B       DB       #C8,#30,#47,#01,#D8,#30,#42,#01
       DB       #18,#50,#42,#01,#28,#50,#47,#01
       DB       #C8,#70,#47,#01,#D8,#70,#42,#01
       DB       #18,#90,#42,#01,#28,#90,#47,#01
       DB       #78,#A0,#4C,#01,#28,#00,#46,#02
       DB       #38,#00,#46,#02,#48,#00,#46,#02
       DB       #08,#B0,#48,#02,#28,#B0,#5E,#02
       DB       #18,#20,#5E,#01,#FF
L_A6B8       DB       #68,#40,#48,#01,#78,#40,#4C,#01
       DB       #88,#40,#48,#01,#68,#50,#40,#02
       DB       #78,#50,#41,#02,#88,#50,#40,#02
       DB       #28,#50,#47,#01,#C8,#50,#47,#01
       DB       #FF,#88,#50,#48,#02,#78,#20,#4C
       DB       #01,#FF,#B8,#60,#44,#02,#18,#90
       DB       #48,#02,#C8,#10,#4C,#01,#FF,#B8
       DB       #20,#46,#02,#FF,#88,#A0,#44,#01
       DB       #68,#A0,#4C,#01,#78,#40,#41,#01
       DB       #78,#60,#44,#01,#68,#50,#47,#01
       DB       #FF
;
ReadOPQAM
	LD	D,#01
	LD	HL,curcontrols-1;L_A7B2
	LD	C,#FE
L_A710	INC	HL
	LD	B,#DF
	IN	A,(C)
	AND	#02 ;'O'
	JR	NZ,L_A71A
	LD	(HL),D
L_A71A	INC	HL
	LD	B,#DF
	IN	A,(C)
	AND	#01 ;'P'
	JR	NZ,L_A724
	LD	(HL),D
L_A724	INC	HL
	LD	B,#FB
	IN	A,(C)
	AND	#01 ;'Q'
	JR	NZ,L_A72E
	LD	(HL),D
L_A72E	INC	HL
	LD	B,#FD
	IN	A,(C)
	AND	#01 ;'A'
	JR	NZ,L_A738
	LD	(HL),D
L_A738	INC	HL
	LD	B,#7F
	IN	A,(C)
	AND	#04 ;'M'
	RET	NZ
	LD	(HL),D
	RET
;
ReadSinclairJoy
	LD	BC,0xEFFE
	IN	A,(C)
	CPL
	AND	#1F
	LD	D,A
	CALL	L_A78E
	LD	(curfire),A
	CALL	L_A78E
	LD	(curup),A
	CALL	L_A78E
	LD	(curdown),A
	CALL	L_A78E
	LD	(curright),A
	CALL	L_A78E
	LD	(curleft),A
	RET
;
ReadKempstonJoy
	LD	BC,#001F
	IN	D,(C)
	CALL	L_A78E
	LD	(curright),A
	CALL	L_A78E
	LD	(curleft),A
	CALL	L_A78E
	LD	(curdown),A
	CALL	L_A78E
	LD	(curup),A
	CALL	L_A78E
	LD	(curfire),A
	RET
;
L_A78E	XOR	A
	SRL	D
	RLA
	RET
;
ReadControls
	CALL	ClearControls
	LD	A,(L_A7B8)
	OR	A
	JP	Z,ReadOPQAM
	CP	#01
	JP	Z,ReadSinclairJoy
	JP	ReadKempstonJoy
;
ClearControls
	LD	HL,curcontrols
	LD	DE,curcontrols+1;curright
	LD	(HL),#00
	LD	BC,#0004
	LDIR
	RET
;
curcontrols
curleft
       DB       #00
curright       DB       #00
curup       DB       #00
curdown       DB       #00
curfire       DB       #00
L_A7B8       DB       #00
;
L_A7B9	LD	DE,(L_A8C6)
	CALL	L_95E5
	LD	A,(L_A8C3)
	OR	A
	JR	Z,L_A7D1
	DEC	A
	LD	(L_A8C3),A
	LD	A,(L_A8C4)
	LD	B,A
	JP	L_A87F
;
L_A7D1	LD	HL,L_A8C2
	LD	A,(HL)
	OR	A
	JR	Z,L_A7F9
	CP	#0C
	JR	NC,L_A7E1
	CALL	L_A964
	JR	NZ,L_A7F5
L_A7E1	LD	A,(HL)
	DEC	(HL)
	LD	L,A
	LD	H,#00
	LD	BC,L_A8B3
	ADD	HL,BC
	LD	A,(HL)
	ADD	A,D
	LD	D,A
	LD	B,#38
	XOR	A
	LD	(curdown),A
	JR	L_A849
;
L_A7F5	XOR	A
	LD	(L_A8C2),A
L_A7F9	CALL	L_A964
	JR	NZ,L_A80E
	LD	A,D
	CP	#B0
	JR	Z,L_A80E
	ADD	A,#04
	LD	D,A
	LD	B,#38
	XOR	A
	LD	(curdown),A
	JR	L_A849
;
L_A80E	LD	A,(curdown)
	OR	A
	JP	NZ,L_A849
	LD	A,D
	OR	A
	JR	Z,L_A849
	LD	A,(curup)
	OR	A
	JR	Z,L_A846
	LD	A,(L_A8C5)
	OR	A
	JR	NZ,L_A849
	CALL	L_A98F
	JR	Z,L_A841
	CALL	L_AA8A
	LD	A,#01
	LD	(L_A8C5),A
	LD	A,#05
	LD	(L_A8C3),A
	LD	B,#46
	CALL	L_D0B7
	LD	B,#37
	JP	L_A87F
;
L_A841	LD	A,#0E
	LD	(L_A8C2),A
L_A846	LD	(L_A8C5),A
L_A849	LD	B,#36
	LD	HL,(curcontrols)
	LD	A,L
	XOR	H
	JR	Z,L_A87F
	BIT	0,L
	JR	NZ,L_A863
	XOR	A
	LD	(L_A8C8),A
	CALL	L_A927
	JR	NZ,L_A87F
	INC	E
	INC	E
	JR	L_A86F
;
L_A863	LD	A,#03
	LD	(L_A8C8),A
	CALL	L_A947
	JR	NZ,L_A87F
	DEC	E
	DEC	E
L_A86F	LD	A,(L_A8B3)
	CP	#05
	JR	NZ,L_A878
	LD	A,#FF
L_A878	INC	A
	LD	(L_A8B3),A
	ADD	A,#30
	LD	B,A
L_A87F	LD	A,(curdown)
	OR	A
	JR	Z,L_A887
	LD	B,#39
L_A887	LD	A,(L_A8C8)
	OR	A
	JR	NZ,L_A896
	LD	A,(L_A924)
	OR	A
	CALL	NZ,MirrorSprite
	JR	L_A89D
;
L_A896	LD	A,(L_A924)
	OR	A
	CALL	Z,MirrorSprite
L_A89D	CALL	L_A964
	JR	NZ,L_A8A4
	LD	B,#38
L_A8A4	LD	A,B
	LD	(L_A8C4),A
	LD	C,A
	LD	(L_A8C6),DE
	CALL	L_95E5
	JP	L_94CD
;
L_A8B3       DB       #04,#04,#04,#02,#02,#02,#02,#00
       DB       #00,#FE,#FE,#FE,#FE,#FC,#FC
L_A8C2       DB       #00
L_A8C3       DB       #00
L_A8C4       DB       #36
L_A8C5       DB       #00
;
L_A8C6       DW       #9048
L_A8C7       EQU       $-1
;
L_A8C8       DB       #00
;
MirrorSprite
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	BC,#0160
	LD	(L_A925),SP
	LD	HL,L_EA22
	LD	SP,HL
L_A8D8	POP	DE
	SRL	D
	RLA
	SRL	D
	RLA
	SRL	D
	RLA
	SRL	D
	RLA
	SRL	D
	RLA
	SRL	D
	RLA
	SRL	D
	RLA
	SRL	D
	RLA
	LD	(HL),A
	INC	HL
	SRL	E
	RLA
	SRL	E
	RLA
	SRL	E
	RLA
	SRL	E
	RLA
	SRL	E
	RLA
	SRL	E
	RLA
	SRL	E
	RLA
	SRL	E
	RLA
	LD	(HL),A
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,L_A8D8
	LD	A,(L_A924)
	XOR	#01
	LD	(L_A924),A
	LD	SP,(L_A925)
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_A924       DB       #00
L_A925       DB       #EE,#FF
;
L_A927	PUSH	BC
	PUSH	DE
	PUSH	HL
	DEC	E
	DEC	E
	DEC	E
	DEC	E
	CALL	L_97EE
	INC	L
	INC	L
	LD	BC,#0020
	LD	A,(HL)
	ADD	HL,BC
	OR	(HL)
	LD	E,A
	LD	A,D
	AND	#07
	LD	A,E
	JR	Z,L_A942
	ADD	HL,BC
	OR	(HL)
L_A942	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_A947	PUSH	BC
	PUSH	DE
	PUSH	HL
	INC	E
	INC	E
	INC	E
	CALL	L_97EE
	LD	BC,#0020
	LD	A,(HL)
	ADD	HL,BC
	OR	(HL)
	LD	E,A
	LD	A,D
	AND	#07
	LD	A,E
	JR	Z,L_A95F
	ADD	HL,BC
	OR	(HL)
L_A95F	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_A964	PUSH	BC
	PUSH	DE
	PUSH	HL
	INC	E
	INC	E
	INC	E
	INC	E
	LD	A,D
	CP	#B0
	LD	A,#01
	JR	NC,L_A98A
	LD	A,D
	AND	#0F
	LD	A,#00
	JR	NZ,L_A98A
	CALL	L_97EE
	LD	BC,#0040
	ADD	HL,BC
	LD	A,(HL)
	LD	D,A
	LD	A,E
	AND	#07
	LD	A,D
	JR	Z,L_A98A
	INC	L
	OR	(HL)
L_A98A	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_A98F	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,D
	OR	A
	LD	A,#01
	JP	Z,L_A9B5
	INC	E
	INC	E
	INC	E
	INC	E
	LD	A,D
	AND	#0F
	LD	A,#00
	JR	NZ,L_A9B5
	CALL	L_97EE
	LD	BC,L_FFE0
	ADD	HL,BC
	LD	A,(HL)
	LD	D,A
	LD	A,E
	AND	#07
	LD	A,D
	JR	Z,L_A9B5
	INC	L
	OR	(HL)
L_A9B5	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_A9BA	LD	A,(L_A8C3)
	OR	A
	RET	NZ
	LD	A,(curfire)
	OR	A
	JR	NZ,L_A9C9
	LD	(L_AA89),A
	RET
;
L_A9C9	LD	A,(L_AA89)
	OR	A
	RET	NZ
	INC	A
	LD	(L_AA89),A
	LD	A,#05
	LD	(L_A8C3),A
	LD	B,#46
	CALL	L_D0B7
	LD	DE,(L_A8C6)
	LD	A,(L_A8C8)
	OR	A
	JR	NZ,L_A9EC
	LD	A,E
	ADD	A,#12
	LD	E,A
	JR	L_A9F0
;
L_A9EC	LD	A,E
	SUB	#14
	LD	E,A
L_A9F0	CALL	CountXYtoxy_DE
	SET	0,E
	RES	0,D
	LD	A,(curdown)
	OR	A
	JR	Z,L_AA0E
	PUSH	DE
	LD	DE,(L_A8C6)
	LD	A,D
	CP	#B0
	JR	Z,L_AA0A
	CALL	L_A964
L_AA0A	POP	DE
	RET	Z
	INC	D
	INC	D
L_AA0E	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	OR	A
	JR	Z,L_AA4F
	CP	#01
	RET	Z
L_AA1C	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	XOR	A
	LD	(L_9AA6),A
	CALL	L_9A82
	CALL	CountScrAddr_DEyx
	LD	BC,#9000
	ADD	HL,BC
	LD	A,(HL)
	CALL	DrawSprite
	LD	C,#47
	CALL	L_981B
	CALL	CountxytoXY_DE
	CALL	L_95E5
	CALL	L_AAE5
	PUSH	DE
	CALL	L_974A
	POP	DE
	LD	B,D
	LD	C,E
	CALL	L_CBB5
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_AA4F	PUSH	DE
	CALL	CountxytoXY_DE
	PUSH	DE
	CALL	L_AC0C
	POP	DE
	OR	A
	CALL	NZ,L_CD19
	CALL	NZ,L_C363
	POP	DE
	RET	NZ
	LD	A,#02
	LD	(L_9AA6),A
	LD	A,#00
	LD	C,#45
	CALL	L_9A82
	CALL	CountxytoXY_DE
	LD	A,#00
	CALL	L_95E5
	CALL	L_94CD
	CALL	L_AAE5
	LD	HL,#5801
	LD	DE,#5802
	LD	BC,#001D
	LD	(HL),#47
	LDIR
	RET
;
L_AA89       DB       #00
;
L_AA8A	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	DE,(L_A8C6)
	CALL	CountXYtoxy_DE
	DEC	D
	DEC	D
	SET	0,E
	RES	0,D
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	NZ,L_AABD
	LD	A,#03
	LD	(L_9AA6),A
	LD	C,#45
	CALL	L_9A82
	CALL	CountxytoXY_DE
	LD	A,#03
	CALL	L_94CD
	CALL	L_95E5
	XOR	A
L_AABD	CP	#03
	CALL	Z,L_AA1C
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
CountXYtoxy_DE
	PUSH	AF
	LD	A,D
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	D,A
	LD	A,E
	AND	#F8
	RRCA
	RRCA
	RRCA
	LD	E,A
	POP	AF
	RET
;
CountxytoXY_DE
	PUSH	AF
	LD	A,D
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	D,A
	LD	A,E
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	E,A
	POP	AF
	RET
;
L_AAE5	LD	HL,L_AAFB
L_AAE8	LD	A,(HL)
	CP	#FF
	RET	Z
	INC	HL
	INC	HL
	LD	A,(HL)
	OR	A
	INC	HL
	JR	NZ,L_AAE8
	DEC	HL
	LD	(HL),#07
	DEC	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	RET
;
L_AAFB       DB       #68,#B0,#00,#3B,#B0,#00,#38,#B0
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#FF
;
L_AB0E	LD	HL,L_AAFB
L_AB11	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	Z,L_AB11
	PUSH	HL
	DEC	HL
	DEC	(HL)
	JR	Z,L_AB35
	LD	L,A
	LD	H,#00
	LD	BC,L_AB3E
	ADD	HL,BC
	LD	A,(HL)
	CALL	L_94CD
	CALL	L_95E5
	POP	HL
	JP	L_AB11
;
L_AB35	CALL	L_95E5
	CALL	L_974A
	POP	HL
	JP	L_AB11
L_AB3E       EQU       $-1
;
       DB       #00,#08,#08,#08,#09,#09,#09       ;.......
;
L_AB46	PUSH	HL
	LD	HL,(L_AB55)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),#FF
	LD	(L_AB55),HL
	POP	HL
	RET
;
L_AB55       DW       L_AB6D
;
L_AB57       DB       #78,#10,#68,#40,#78,#40,#88,#40
       DB       #28,#50
L_AB61       DB       #C8,#50,#A8,#90,#38,#70,#B8,#70
       DB       #6B,#20,#7F,#80
L_AB6D       DB       #FF,#78,#FF,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#FF
;
L_ABF8	LD	A,D
	SUB	B
	SUB	#11
	CP	#E3
	LD	A,#00
	RET	C
	LD	A,E
	SUB	C
	SUB	#11
	CP	#E3
	LD	A,#00
	RET	C
	INC	A
	RET
;
L_AC0C	PUSH	BC
	PUSH	HL
	INC	D
	INC	D
	INC	E
	INC	E
	LD	HL,L_AB57
L_AC15	LD	A,(HL)
	CP	#FF
	LD	A,#00
	JR	Z,L_AC27
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	CALL	L_ABF8
	OR	A
	JP	Z,L_AC15
L_AC27	POP	HL
	POP	BC
	RET
;
L_AC2A	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,E
	ADD	A,#10
	LD	E,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_AC49
	CALL	L_AA1C
	LD	A,#01
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_AC49	XOR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_AC4E	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,E
	SUB	#09
	LD	E,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_AC6D
	CALL	L_AA1C
	LD	A,#01
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_AC6D	XOR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_AC72	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,D
	SUB	#10
	LD	D,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_AC91
	CALL	L_AA1C
	LD	A,#01
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_AC91	XOR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_AC96	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,D
	ADD	A,#10
	LD	D,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_ACB5
	CALL	L_AA1C
	LD	A,#01
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_ACB5	XOR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_ACBA	LD	BC,L_AD20
	LD	A,(L_A390)
	CALL	GetHLFrom2APlusBC
	LD	DE,L_AD01
	LD	BC,#001E
	LDIR
	RET
;
L_ACCC	LD	HL,L_AD01
L_ACCF	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	CALL	L_A964
	JR	NZ,L_ACE8
	CALL	L_95E5
	LD	A,D
	CP	#B0
	JR	Z,L_ACE8
	INC	D
	INC	D
	INC	D
	INC	D
	LD	(HL),D
L_ACE8	INC	HL
	INC	HL
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	LD	A,(L_9478)
	AND	#01
	ADD	A,#06
	CALL	L_94CD
	JP	L_ACCF
;
       DB       #06
;
L_AD01       DB       #38,#70,#00,#B8,#70,#00,#FF,#FF
       DB       #FF,#FF,#FF,#FF,#A8,#00,#00,#88
       DB       #20,#00,#68,#40,#00,#48,#60,#00
       DB       #28,#80,#00,#FF,#FF,#FF,#FF
;
L_AD20       DW       L_AD4A
       DW       L_AD51
       DW       L_AD52
       DW       L_AD53
       DW       L_AD54
       DW       L_AD55
       DW       L_AD56
       DW       L_AD66
       DW       L_AD67
       DW       L_AD68
       DW       L_AD69
       DW       L_AD6A
       DW       L_AD6B
       DW       L_AD6C
       DW       L_AD6D
       DW       L_AD6E
       DW       L_AD6F
       DW       L_AD70
       DW       L_AD71
       DW       L_AD72
       DW       L_AD73
;
L_AD4A       DB       #38,#70,#00,#B8,#70,#00,#FF
L_AD51       DB       #FF
L_AD52       DB       #FF
L_AD53       DB       #FF
L_AD54       DB       #FF
L_AD55       DB       #FF
L_AD56       DB       #A8,#00,#00,#88,#20,#00,#68,#40
       DB       #00,#48,#60,#00,#28,#80,#00,#FF
L_AD66       DB       #FF
L_AD67       DB       #FF
L_AD68       DB       #FF
L_AD69       DB       #FF
L_AD6A       DB       #FF
L_AD6B       DB       #FF
L_AD6C       DB       #FF
L_AD6D       DB       #FF
L_AD6E       DB       #FF
L_AD6F       DB       #FF
L_AD70       DB       #FF
L_AD71       DB       #FF
L_AD72       DB       #FF
L_AD73       DB       #FF
;
L_AD74	LD	BC,L_AE18
	LD	A,(L_A390)
	CALL	GetHLFrom2APlusBC
	LD	DE,L_ADFB
	LD	BC,#001C
	LDIR
	RET
;
L_AD86	LD	HL,L_AE8F
	LD	DE,L_AE90
	LD	BC,#0031
	LD	(HL),#00
	LDIR
	RET
;
L_AD94	LD	IX,L_ADFB
L_AD98	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	A,(IX+#05)
	OR	A
	JR	Z,L_ADAE
	DEC	(IX+#05)
	LD	BC,#0007
	ADD	IX,BC
	JR	L_AD98
;
L_ADAE	LD	A,(IX+#04)
	LD	(IX+#05),A
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	LD	A,(IX+#02)
	XOR	(IX+#03)
	LD	(IX+#03),A
	CALL	L_ADCD
	LD	BC,#0007
	ADD	IX,BC
	JR	L_AD98
;
L_ADCD	LD	BC,#0005
	LD	IY,L_AE8F
L_ADD4	LD	A,(IY+#00)
	CP	#FF
	RET	Z
	LD	A,(IY+#02)
	OR	A
	JR	NZ,L_ADF7
	LD	(IY+#00),E
	LD	(IY+#01),D
	LD	A,(IX+#03)
	LD	(IY+#02),A
	LD	(IY+#03),#00
	LD	A,(IX+#06)
	LD	(IY+#04),A
	RET
;
L_ADF7	ADD	IY,BC
	JR	L_ADD4
;
L_ADFB       DB       #FF,#38,#10,#00,#03,#64,#1E,#50
       DB       #FF,#FF,#FF,#38,#20,#00,#FD,#78
       DB       #78,#50,#B8,#20,#00,#03,#78,#78
       DB       #50,#FF,#38,#10,#FF
;
L_AE18       DW       L_AE42
       DW       L_AE43
       DW       L_AE4B
       DW       L_AE4C
       DW       L_AE4D
       DW       L_AE5C
       DW       L_AE6B
       DW       L_AE73
       DW       L_AE74
       DW       L_AE75
       DW       L_AE76
       DW       L_AE77
       DW       L_AE78
       DW       L_AE87
       DW       L_AE88
       DW       L_AE89
       DW       L_AE8A
       DW       L_AE8B
       DW       L_AE8C
       DW       L_AE8D
       DW       L_AE8E
;
L_AE42       DB       #FF
L_AE43       DB       #38,#10,#00,#03,#64,#1E,#50,#FF
L_AE4B       DB       #FF
L_AE4C       DB       #FF
L_AE4D       DB       #38,#20,#00,#FD,#78,#78,#50,#B8
       DB       #20,#00,#03,#78,#78,#50,#FF
L_AE5C       DB       #38,#10,#00,#03,#78,#78,#50,#C8
       DB       #10,#00,#FD,#78,#78,#50,#FF
L_AE6B       DB       #C8,#10,#00,#FD,#78,#5A,#8C,#FF
L_AE73       DB       #FF
L_AE74       DB       #FF
L_AE75       DB       #FF
L_AE76       DB       #FF
L_AE77       DB       #FF
L_AE78       DB       #28,#10,#FE,#FD,#28,#0A,#3C,#C8
       DB       #10,#FE,#03,#28,#0A,#3C,#FF
L_AE87       DB       #FF
L_AE88       DB       #FF
L_AE89       DB       #FF
L_AE8A       DB       #FF
L_AE8B       DB       #FF
L_AE8C       DB       #FF
L_AE8D       DB       #FF
L_AE8E       DB       #FF
L_AE8F       DB       #00
L_AE90       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#FF
;
L_AEC2	LD	IX,L_AE8F
L_AEC6	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_AEE0
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_AEE0
	LD	(IX+#02),#00
L_AEE0	LD	BC,#0005
	ADD	IX,BC
	JR	L_AEC6
;
L_AEE7	LD	IX,L_AE8F
L_AEEB	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	D,(IX+#01)
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_AF03
	LD	BC,#0005
	ADD	IX,BC
	JP	L_AEEB
;
L_AF03	CALL	L_95E5
	CALL	L_A964
	OR	A
	JR	NZ,L_AF1B
	LD	A,D
	CP	#B0
	JR	Z,L_AF1B
	ADD	A,#04
	LD	D,A
	LD	(IX+#01),A
	XOR	A
	JP	L_AF60
;
L_AF1B	LD	A,(IX+#02)
	CP	#FD
	JR	Z,L_AF3C
	LD	C,A
	CALL	L_A927
	LD	A,C
	JR	Z,L_AF52
	NEG
	LD	(IX+#02),A
	CALL	L_AC2A
	OR	A
	JP	Z,L_AF52
	LD	(IX+#03),#05
	JP	L_AF52
;
L_AF3C	LD	C,A
	CALL	L_A947
	LD	A,C
	JR	Z,L_AF52
	NEG
	LD	(IX+#02),A
	CALL	L_AC4E
	OR	A
	JR	Z,L_AF52
	LD	(IX+#03),#05
L_AF52	LD	A,(IX+#03)
	OR	A
	JR	Z,L_AF5D
	DEC	(IX+#03)
	JR	L_AF65
;
L_AF5D	LD	A,(IX+#02)
L_AF60	ADD	A,E
	LD	E,A
	LD	(IX+#00),E
L_AF65	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	LD	A,(L_9478)
	RRCA
	AND	#07
	ADD	A,#0C
	CALL	L_94CD
	LD	A,(L_9478)
	AND	#01
	JR	Z,L_AF8F
	DEC	(IX+#04)
	JR	NZ,L_AF8F
	LD	(IX+#02),#00
	CALL	L_AAE5
	CALL	L_974A
L_AF8F	LD	BC,#0005
	ADD	IX,BC
	JP	L_AEEB
;
L_AF97	LD	BC,L_B04C
	LD	A,(L_A390)
	CALL	GetHLFrom2APlusBC
	LD	DE,L_B02F
	LD	BC,#001C
	LDIR
	RET
;
L_AFA9	LD	HL,L_B0AE
	LD	DE,L_B0AF
	LD	BC,#003B
	LD	(HL),#00
	LDIR
	RET
;
L_AFB7	LD	A,(L_B110)
	CP	#02
	JR	NZ,L_AFC0
	LD	A,#FF
L_AFC0	INC	A
	LD	(L_B110),A
	LD	IX,L_B02F
L_AFC8	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	A,(IX+#05)
	OR	A
	JR	Z,L_AFDE
	DEC	(IX+#05)
	LD	BC,#0007
	ADD	IX,BC
	JR	L_AFC8
;
L_AFDE	LD	A,(IX+#04)
	LD	(IX+#05),A
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	LD	A,(IX+#02)
	XOR	(IX+#03)
	LD	(IX+#03),A
	CALL	L_AFFD
	LD	BC,#0007
	ADD	IX,BC
	JR	L_AFC8
;
L_AFFD	LD	BC,#0006
	LD	IY,L_B0AE
L_B004	LD	A,(IY+#00)
	CP	#FF
	RET	Z
	LD	A,(IY+#02)
	OR	A
	JR	NZ,L_B02B
	LD	A,(IX+#06)
	LD	(IY+#04),A
	LD	(IY+#00),E
	LD	(IY+#01),D
	LD	A,(IX+#03)
	LD	(IY+#02),A
	LD	(IY+#03),#00
	LD	(IY+#05),#01
	RET
;
L_B02B	ADD	IY,BC
	JR	L_B004
;
L_B02F       DB       #FF,#18,#10,#FC,#FE,#64,#14,#41
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #58,#00,#00,#FE,#3C,#1E,#50,#FF
       DB       #FF,#FF,#FF,#08,#FF
;
L_B04C       DW       L_B076
       DW       L_B077
       DW       L_B07F
       DW       L_B080
       DW       L_B081
       DW       L_B082
       DW       L_B083
       DW       L_B084
       DW       L_B085
       DW       L_B086
       DW       L_B08E
       DW       L_B08F
       DW       L_B090
       DW       L_B091
       DW       L_B099
       DW       L_B0A8
       DW       L_B0A9
       DW       L_B0AA
       DW       L_B0AB
       DW       L_B0AC
       DW       L_B0AD
;
L_B076       DB       #FF
L_B077       DB       #18,#10,#FC,#FE,#64,#14,#41,#FF
L_B07F       DB       #FF
L_B080       DB       #FF
L_B081       DB       #FF
L_B082       DB       #FF
L_B083       DB       #FF
L_B084       DB       #FF
L_B085       DB       #FF
L_B086       DB       #58,#00,#00,#FE,#3C,#1E,#50,#FF
L_B08E       DB       #FF
L_B08F       DB       #FF
L_B090       DB       #FF
L_B091       DB       #08,#00,#00,#02,#32,#0A,#32,#FF
L_B099       DB       #64,#10,#00,#02,#4B,#28,#19,#8C
       DB       #10,#00,#FE,#4B,#28,#19,#FF
L_B0A8       DB       #FF
L_B0A9       DB       #FF
L_B0AA       DB       #FF
L_B0AB       DB       #FF
L_B0AC       DB       #FF
L_B0AD       DB       #FF
L_B0AE       DB       #00
L_B0AF       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#FF
;
L_B0EB	LD	IX,L_B0AE
L_B0EF	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_B109
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_B109
	LD	(IX+#02),#00
L_B109	LD	BC,#0006
	ADD	IX,BC
	JR	L_B0EF
;
L_B110       DB       #00
;
L_B111	LD	IX,L_B0AE
L_B115	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	D,(IX+#01)
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_B12D
	LD	BC,#0006
	ADD	IX,BC
	JP	L_B115
;
L_B12D	CALL	L_95E5
	CALL	L_A964
	OR	A
	JR	NZ,L_B15D
	LD	A,D
	CP	#B0
	JR	Z,L_B15D
	ADD	A,#04
	LD	D,A
	LD	(IX+#01),A
	LD	(IX+#03),#03
	LD	A,#01
	LD	(IX+#05),A
	LD	B,#17
	LD	A,(IX+#02)
	CP	#FE
	LD	A,#00
	JP	Z,L_B203
	LD	B,#14
	LD	A,#00
	JP	L_B203
;
L_B15D	LD	A,(IX+#05)
	OR	A
	JR	Z,L_B173
	LD	A,(L_A8C6)
	CP	E
	JR	NC,L_B16F
	LD	(IX+#02),#FE
	JR	L_B173
;
L_B16F	LD	(IX+#02),#02
L_B173	LD	(IX+#05),#00
	LD	A,(IX+#02)
	CP	#FE
	JR	Z,L_B1AA
	LD	C,A
	LD	B,#14
	CALL	L_A927
	LD	A,C
	JR	Z,L_B1D3
	NEG
	LD	(IX+#02),A
	CALL	L_AC2A
	OR	A
	JR	Z,L_B1D3
	PUSH	DE
	LD	A,E
	ADD	A,#10
	LD	E,A
	CALL	L_B23C
	LD	(IX+#03),#0A
	LD	A,(IX+#02)
	NEG
	LD	(IX+#02),A
	POP	DE
	JP	L_B1D3
;
L_B1AA	LD	C,A
	LD	B,#17
	CALL	L_A947
	LD	A,C
	JR	Z,L_B1D3
	NEG
	LD	(IX+#02),A
	CALL	L_AC4E
	OR	A
	JR	Z,L_B1D3
	PUSH	DE
	LD	A,E
	SUB	#10
	LD	E,A
	CALL	L_B23C
	LD	A,(IX+#02)
	NEG
	LD	(IX+#02),A
	POP	DE
	LD	(IX+#03),#0A
L_B1D3	LD	A,(IX+#03)
	OR	A
	JR	Z,L_B1ED
	DEC	(IX+#03)
	LD	B,#17
	LD	A,(IX+#02)
	CP	#FE
	LD	A,#00
	JR	Z,L_B203
	LD	B,#14
	LD	A,#00
	JR	L_B203
;
L_B1ED	LD	A,(IX+#02)
	ADD	A,E
	LD	E,A
	LD	(IX+#00),E
	LD	A,(IX+#02)
	CP	#FE
	LD	B,#17
	JR	Z,L_B200
	LD	B,#14
L_B200	LD	A,(L_B110)
L_B203	ADD	A,B
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	LD	A,(L_9478)
	AND	#03
	JR	NZ,L_B226
	DEC	(IX+#04)
	JR	NZ,L_B226
	LD	(IX+#02),#00
	CALL	L_AAE5
	CALL	L_974A
L_B226	LD	BC,#0006
	ADD	IX,BC
	JP	L_B115
;
L_B22E	LD	HL,L_B252
	LD	DE,L_B253
	LD	BC,#001D
	LD	(HL),#00
	LDIR
	RET
;
L_B23C	LD	HL,L_B252
L_B23F	LD	A,(HL)
	CP	#FF
	RET	Z
	INC	HL
	INC	HL
	LD	A,(HL)
	INC	HL
	OR	A
	JR	NZ,L_B23F
	DEC	HL
	LD	(HL),#0A
	DEC	HL
	LD	(HL),D
	DEC	HL
	LD	(HL),E
	RET
;
L_B252       DB       #00
L_B253       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#FF
;
L_B271	LD	HL,L_B252
L_B274	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	OR	A
	INC	HL
	JR	Z,L_B274
	DEC	HL
	DEC	(HL)
	INC	HL
	JR	Z,L_B29F
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	LD	A,(L_B2AA)
	XOR	#01
	LD	(L_B2AA),A
	ADD	A,#1A
	CALL	L_94CD
	JP	L_B274
;
L_B29F	PUSH	HL
	CALL	L_95E5
	CALL	L_974A
	POP	HL
	JP	L_B274
;
L_B2AA       DB       #01
;
L_B2AB	LD	BC,L_B2BD
	LD	A,(L_A390)
	CALL	GetHLFrom2APlusBC
	LD	DE,L_B2E7
	LD	BC,#001E
	LDIR
	RET
;
L_B2BD       DW       L_B3F0
       DW       L_B3F5
       DW       L_B3F6
       DW       L_B3F7
       DW       L_B3F8
       DW       L_B3F9
       DW       L_B402
       DW       L_B403
       DW       L_B404
       DW       L_B415
       DW       L_B416
       DW       L_B417
       DW       L_B418
       DW       L_B419
       DW       L_B41E
       DW       L_B41F
       DW       L_B420
       DW       L_B421
       DW       L_B422
       DW       L_B423
       DW       L_B424
;
L_B2E7       DB       #6B,#20,#03,#00,#FF,#FF,#FF,#FF
       DB       #FF,#78,#40,#FD,#00,#78,#60,#FD
       DB       #00,#FF,#FF,#FF,#58,#50,#03,#00
       DB       #58,#70,#03,#00,#98,#50,#FF
;
L_B306	LD	IX,L_B2E7
L_B30A	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_B324
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_B324
	LD	(IX+#02),#00
L_B324	LD	BC,#0004
	ADD	IX,BC
	JR	L_B30A
;
L_B32B	LD	IX,L_B2E7
L_B32F	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	D,(IX+#01)
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_B347
	LD	BC,#0004
	ADD	IX,BC
	JP	L_B32F
;
L_B347	CALL	L_95E5
	LD	A,(IX+#03)
	OR	A
	JP	NZ,L_B3DF
	LD	A,(IX+#02)
	CP	#FD
	JR	Z,L_B38E
	LD	C,A
	LD	B,#0A
	CALL	L_A927
	LD	A,C
	JR	Z,L_B3C1
	NEG
	LD	(IX+#02),A
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,E
	ADD	A,#10
	LD	E,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_B387
	LD	(IX+#03),#05
	CALL	L_AA1C
	JP	L_B3DB
;
L_B387	POP	HL
	POP	DE
	POP	BC
	POP	AF
	JP	L_B3C1
;
L_B38E	LD	C,A
	LD	B,#0B
	CALL	L_A947
	LD	A,C
	JR	Z,L_B3C1
	NEG
	LD	(IX+#02),A
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,E
	SUB	#09
	LD	E,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_B3BD
	LD	(IX+#03),#05
	CALL	L_AA1C
	JP	L_B3DB
;
L_B3BD	POP	HL
	POP	DE
	POP	BC
	POP	AF
L_B3C1	ADD	A,E
	LD	E,A
	LD	(IX+#00),E
L_B3C6	LD	A,B
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	CALL	L_94CD
	LD	BC,#0004
	ADD	IX,BC
	JP	L_B32F
;
L_B3DB	POP	HL
	POP	DE
	POP	BC
	POP	AF
L_B3DF	DEC	(IX+#03)
	LD	A,(IX+#02)
	CP	#FD
	LD	B,#0A
	JP	Z,L_B3C6
	INC	B
	JP	L_B3C6
;
L_B3F0       DB       #08,#20,#03,#00,#FF
L_B3F5       DB       #FF
L_B3F6       DB       #FF
L_B3F7       DB       #FF
L_B3F8       DB       #FF
L_B3F9       DB       #78,#40,#FD,#00,#78,#60,#FD,#00
       DB       #FF
L_B402       DB       #FF
L_B403       DB       #FF
L_B404       DB       #58,#50,#03,#00,#58,#70,#03,#00
       DB       #98,#50,#FD,#00,#98,#70,#FD,#00
       DB       #FF
L_B415       DB       #FF
L_B416       DB       #FF
L_B417       DB       #FF
L_B418       DB       #FF
L_B419       DB       #78,#10,#FD,#00,#FF
L_B41E       DB       #FF
L_B41F       DB       #FF
L_B420       DB       #FF
L_B421       DB       #FF
L_B422       DB       #FF
L_B423       DB       #FF
L_B424       DB       #FF
;
L_B425	LD	A,(L_A390)
	LD	BC,L_B45C
	CALL	GetHLFrom2APlusBC
	LD	DE,L_B4BE
	LD	BC,#0019
	LDIR
	RET
;
L_B437	LD	IX,L_B4BE
L_B43B	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_B455
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_B455
	LD	(IX+#02),#00
L_B455	LD	BC,#0005
	ADD	IX,BC
	JR	L_B43B
;
L_B45C       DW       L_B486
       DW       L_B48C
       DW       L_B48D
       DW       L_B493
       DW       L_B494
       DW       L_B495
       DW       L_B4A0
       DW       L_B4A1
       DW       L_B4A2
       DW       L_B4A3
       DW       L_B4A4
       DW       L_B4A5
       DW       L_B4A6
       DW       L_B4A7
       DW       L_B4A8
       DW       L_B4B3
       DW       L_B4B4
       DW       L_B4B5
       DW       L_B4B6
       DW       L_B4B7
       DW       L_B4B8
;
L_B486       DB       #78,#80,#01,#00,#00,#FF
L_B48C       DB       #FF
L_B48D       DB       #38,#A0,#FF,#00,#00,#FF
L_B493       DB       #FF
L_B494       DB       #FF
L_B495       DB       #18,#B0,#01,#00,#00,#E0,#B0,#FF
       DB       #00,#00,#FF
L_B4A0       DB       #FF
L_B4A1       DB       #FF
L_B4A2       DB       #FF
L_B4A3       DB       #FF
L_B4A4       DB       #FF
L_B4A5       DB       #FF
L_B4A6       DB       #FF
L_B4A7       DB       #FF
L_B4A8       DB       #08,#60,#01,#00,#00,#E8,#60,#FF
       DB       #00,#00,#FF
L_B4B3       DB       #FF
L_B4B4       DB       #FF
L_B4B5       DB       #FF
L_B4B6       DB       #FF
L_B4B7       DB       #FF
L_B4B8       DB       #78,#B0,#FF,#00,#00,#FF
L_B4BE       DB       #7F,#80,#FF,#00,#00,#FF,#FF,#38
       DB       #A0,#FF,#00,#00,#FF,#FF,#FF,#18
       DB       #B0,#01,#00,#00,#E0,#B0,#FF,#00
       DB       #00,#FF
;
L_B4D8	LD	IX,L_B4BE
L_B4DC	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_B4F1
L_B4E9	LD	BC,#0005
	ADD	IX,BC
	JP	L_B4DC
;
L_B4F1	LD	D,(IX+#01)
	CALL	L_95E5
	CALL	L_A964
	JR	NZ,L_B536
	LD	A,(IX+#03)
	CP	#04
	JR	C,L_B50A
	INC	D
	INC	D
	INC	D
	INC	D
	LD	(IX+#01),D
L_B50A	LD	A,#23
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	INC	(IX+#03)
	LD	A,(IX+#03)
	CP	#08
	JP	NZ,L_B4E9
	CALL	L_AAE5
	CALL	L_974A
	XOR	A
	LD	(IX+#02),A
	LD	(IX+#03),A
	LD	(IX+#04),A
	JP	L_B4E9
;
L_B536	LD	A,(IX+#02)
	CP	#FF
	JR	Z,L_B562
	PUSH	DE
	LD	A,E
	ADD	A,#08
	LD	E,A
	CALL	L_A964
	POP	DE
	JR	Z,L_B54D
	CALL	L_A927
	JR	Z,L_B584
L_B54D	LD	(IX+#02),#FF
	CALL	L_AC2A
	OR	A
	JR	Z,L_B584
	LD	(IX+#04),#0A
	LD	(IX+#02),#01
	JP	L_B584
;
L_B562	PUSH	DE
	LD	A,E
	SUB	#09
	LD	E,A
	CALL	L_A964
	POP	DE
	JR	Z,L_B572
	CALL	L_A947
	JR	Z,L_B584
L_B572	LD	(IX+#02),#01
	CALL	L_AC4E
	OR	A
	JR	Z,L_B584
	LD	(IX+#02),#FF
	LD	(IX+#04),#0A
L_B584	LD	A,(IX+#04)
	OR	A
	JR	Z,L_B5A8
	DEC	(IX+#04)
	LD	A,(IX+#02)
	CP	#FF
	LD	A,#28
	JP	Z,L_B599
	LD	A,#22
L_B599	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	JP	L_B4E9
;
L_B5A8	LD	A,(IX+#02)
	ADD	A,E
	LD	E,A
	LD	(IX+#00),E
	LD	A,(IX+#02)
	LD	B,#24
	CP	#FF
	JR	Z,L_B5BB
	LD	B,#1E
L_B5BB	LD	A,(L_9478)
	RRCA
	RRCA
	AND	#03
	ADD	A,B
	CALL	L_94CD
	CALL	L_AB46
	CALL	L_95E5
	CALL	L_BFE0
	JP	L_B4E9
;
L_B5D2	LD	A,(L_A390)
	LD	BC,L_B5E4
	CALL	GetHLFrom2APlusBC
	LD	DE,L_B637
	LD	BC,#0019
	LDIR
	RET
;
L_B5E4       DW       L_B60E
       DW       L_B60F
       DW       L_B610
       DW       L_B61B
       DW       L_B61C
       DW       L_B627
       DW       L_B628
       DW       L_B629
       DW       L_B62A
       DW       L_B62B
       DW       L_B62C
       DW       L_B62D
       DW       L_B62E
       DW       L_B62F
       DW       L_B630
       DW       L_B631
       DW       L_B632
       DW       L_B633
       DW       L_B634
       DW       L_B635
       DW       L_B636
;
L_B60E       DB       #FF
L_B60F       DB       #FF
L_B610       DB       #78,#70,#01,#00,#00,#78,#70,#FF
       DB       #00,#00,#FF
L_B61B       DB       #FF
L_B61C       DB       #08,#20,#01,#00,#00,#E8,#20,#FF
       DB       #00,#00,#FF
L_B627       DB       #FF
L_B628       DB       #FF
L_B629       DB       #FF
L_B62A       DB       #FF
L_B62B       DB       #FF
L_B62C       DB       #FF
L_B62D       DB       #FF
L_B62E       DB       #FF
L_B62F       DB       #FF
L_B630       DB       #FF
L_B631       DB       #FF
L_B632       DB       #FF
L_B633       DB       #FF
L_B634       DB       #FF
L_B635       DB       #FF
L_B636       DB       #FF
L_B637       DB       #FF,#FF,#78,#70,#01,#00,#00,#78
       DB       #70,#FF,#00,#00,#FF,#FF,#08,#20
       DB       #01,#00,#00,#E8,#20,#FF,#00,#00
       DB       #FF,#FF
;
L_B651	LD	IX,L_B637
L_B655	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_B66F
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_B66F
	LD	(IX+#02),#00
L_B66F	LD	BC,#0005
	ADD	IX,BC
	JR	L_B655
;
L_B676	LD	IX,L_B637
L_B67A	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_B68F
L_B687	LD	BC,#0005
	ADD	IX,BC
	JP	L_B67A
;
L_B68F	LD	D,(IX+#01)
	CALL	L_95E5
	CALL	L_A964
	JR	NZ,L_B6DD
	LD	A,(IX+#03)
	CP	#04
	JR	C,L_B6A8
	INC	D
	INC	D
	INC	D
	INC	D
	LD	(IX+#01),D
L_B6A8	LD	A,(IX+#02)
	CP	#01
	LD	A,#29
	JR	Z,L_B6B3
	LD	A,#2B
L_B6B3	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	INC	(IX+#03)
	LD	A,(IX+#03)
	CP	#08
	JP	NZ,L_B687
	CALL	L_AAE5
	CALL	L_974A
	XOR	A
	LD	(IX+#02),A
	LD	(IX+#03),A
	LD	(IX+#04),A
	JP	L_B687
;
L_B6DD	LD	A,(IX+#02)
	CP	#FF
	JR	Z,L_B712
	PUSH	DE
	LD	A,E
	ADD	A,#08
	LD	E,A
	CALL	L_A964
	POP	DE
	JR	Z,L_B6F4
	CALL	L_A927
	JR	Z,L_B73D
L_B6F4	LD	(IX+#02),#FF
	CALL	L_AC2A
	OR	A
	JR	Z,L_B73D
	PUSH	DE
	LD	A,E
	ADD	A,#10
	LD	E,A
	CALL	L_B23C
	POP	DE
	LD	(IX+#04),#0A
	LD	(IX+#02),#01
	JP	L_B73D
;
L_B712	PUSH	DE
	LD	A,E
	SUB	#09
	LD	E,A
	CALL	L_A964
	POP	DE
	JR	Z,L_B722
	CALL	L_A947
	JR	Z,L_B73D
L_B722	LD	(IX+#02),#01
	CALL	L_AC4E
	OR	A
	JR	Z,L_B73D
	PUSH	DE
	LD	A,E
	SUB	#10
	LD	E,A
	CALL	L_B23C
	POP	DE
	LD	(IX+#02),#FF
	LD	(IX+#04),#0A
L_B73D	LD	A,(IX+#04)
	OR	A
	JR	Z,L_B761
	DEC	(IX+#04)
	LD	A,(IX+#02)
	CP	#FF
	LD	A,#2B
	JP	Z,L_B752
	LD	A,#29
L_B752	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	JP	L_B687
;
L_B761	LD	A,(IX+#02)
	ADD	A,E
	LD	E,A
	LD	(IX+#00),E
	LD	A,(IX+#02)
	LD	B,#2B
	CP	#FF
	JR	Z,L_B774
	LD	B,#29
L_B774	LD	A,(L_9478)
	RRCA
	AND	#01
	ADD	A,B
	CALL	L_94CD
	CALL	L_AB46
	CALL	L_95E5
	CALL	L_BFE0
	JP	L_B687
;
L_B78A	LD	A,(L_A390)
	LD	BC,L_B7C1
	CALL	GetHLFrom2APlusBC
	LD	DE,L_B7EB
	LD	BC,#0063
	LDIR
	RET
;
L_B79C	LD	IX,L_B7EB
L_B7A0	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_B7BA
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_B7BA
	LD	(IX+#02),#00
L_B7BA	LD	BC,#0005
	ADD	IX,BC
	JR	L_B7A0
;
L_B7C1       DW       L_B850
       DW       L_B851
       DW       L_B852
       DW       L_B85D
       DW       L_B85E
       DW       L_B85F
       DW       L_B860
       DW       L_B861
       DW       L_B885
       DW       L_B886
       DW       L_B887
       DW       L_B897
       DW       L_B898
       DW       L_B899
       DW       L_B89A
       DW       L_B8A5
       DW       L_B8A6
       DW       L_B8A7
       DW       L_B8A8
       DW       L_B8A9
       DW       L_B8AA
;
L_B7EB       DB       #FF,#FF,#B8,#14,#01,#02,#00,#78
       DB       #A4,#01,#02,#00,#FF,#FF,#FF,#FF
       DB       #FF,#58,#2C,#03,#02,#00,#58,#34
       DB       #01,#02,#00,#B8,#2C,#03,#02,#00
       DB       #B8,#34,#01,#02,#00,#58,#8C,#03
       DB       #02,#00,#B8,#8C,#03,#02,#00,#78
       DB       #14,#01,#02,#00,#FF,#FF,#FF,#88
       DB       #84,#01,#04,#00,#98,#90,#01,#04
       DB       #00,#08,#80,#01,#04,#00,#FF,#FF
       DB       #FF,#FF,#D8,#94,#01,#04,#00,#D8
       DB       #7C,#03,#04,#00,#FF,#FF,#FF,#FF
       DB       #FF,#FF,#FF,#DD,#21,#EB,#B7,#DD
       DB       #7E,#00,#FE,#00,#FF
L_B850       DB       #FF
L_B851       DB       #FF
L_B852       DB       #B8,#14,#01,#02,#00,#78,#A4,#01
       DB       #02,#00,#FF
L_B85D       DB       #FF
L_B85E       DB       #FF
L_B85F       DB       #FF
L_B860       DB       #FF
L_B861       DB       #58,#2C,#03,#02,#00,#58,#34,#01
       DB       #02,#00,#B8,#2C,#03,#02,#00,#B8
       DB       #34,#01,#02,#00,#58,#8C,#03,#02
       DB       #00,#B8,#8C,#03,#02,#00,#78,#14
       DB       #01,#02,#00,#FF
L_B885       DB       #FF
L_B886       DB       #FF
L_B887       DB       #88,#84,#01,#04,#00,#98,#90,#01
       DB       #04,#00,#08,#80,#01,#04,#00,#FF
L_B897       DB       #FF
L_B898       DB       #FF
L_B899       DB       #FF
L_B89A       DB       #D8,#94,#01,#04,#00,#D8,#7C,#03
       DB       #04,#00,#FF
L_B8A5       DB       #FF
L_B8A6       DB       #FF
L_B8A7       DB       #FF
L_B8A8       DB       #FF
L_B8A9       DB       #FF
L_B8AA       DB       #FF
;
L_B8AB	LD	IX,L_B7EB
L_B8AF	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_B8C3
L_B8BB	LD	BC,#0005
	ADD	IX,BC
	JP	L_B8AF
;
L_B8C3	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	A,(IX+#04)
	OR	A
	JP	NZ,L_B9AC
	LD	A,(IX+#02)
	CP	#01
	JR	Z,L_B8F9
	CP	#02
	JR	Z,L_B910
	CP	#03
	JR	Z,L_B927
	CALL	L_BA90
	JR	Z,L_B8EC
	LD	A,#03
	JP	L_B93E
;
L_B8EC	CALL	L_BA42
	LD	A,#00
	JP	NZ,L_B93E
	LD	A,#01
	JP	L_B93E
;
L_B8F9	CALL	L_BA42
	JR	Z,L_B903
	LD	A,#04
	JP	L_B93E
;
L_B903	CALL	L_BA61
	LD	A,#00
	JP	NZ,L_B93E
	LD	A,#02
	JP	L_B93E
;
L_B910	CALL	L_BA61
	JR	Z,L_B91A
	LD	A,#01
	JP	L_B93E
;
L_B91A	CALL	L_BA20
	LD	A,#00
	JP	NZ,L_B93E
	LD	A,#03
	JP	L_B93E
;
L_B927	CALL	L_BA20
	JR	Z,L_B931
	LD	A,#02
	JP	L_B93E
;
L_B931	CALL	L_BA90
	LD	A,#00
	JP	NZ,L_B93E
	LD	A,#04
	JP	L_B93E
;
L_B93E	LD	H,A
	LD	L,(IX+#02)
	LD	B,(IX+#03)
	OR	A
	JR	Z,L_B94B
	LD	(IX+#02),A
L_B94B	LD	A,(IX+#02)
	CP	#01
	JR	NZ,L_B959
	LD	A,B
	NEG
	ADD	A,E
	LD	E,A
	JR	L_B970
;
L_B959	CP	#02
	JR	NZ,L_B962
	LD	A,B
	ADD	A,D
	LD	D,A
	JR	L_B970
;
L_B962	CP	#03
	JR	NZ,L_B96B
	LD	A,B
	ADD	A,E
	LD	E,A
	JR	L_B970
;
L_B96B	LD	A,B
	NEG
	ADD	A,D
	LD	D,A
L_B970	LD	A,(IX+#04)
	OR	A
	JR	NZ,L_B98E
	LD	A,H
	OR	A
	JR	Z,L_B98E
	CALL	L_BA06
	JR	NZ,L_B98E
	LD	(IX+#04),#01
	LD	(IX+#02),L
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	JR	L_B9AC
;
L_B98E	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	A,(L_9478)
	RRCA
	RRCA
	AND	#01
	ADD	A,#2D
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	JP	L_B8BB
;
L_B9AC	LD	A,(IX+#02)
	CP	#01
	JP	Z,L_B9D0
	CP	#02
	JP	Z,L_B9E2
	CP	#03
	JP	Z,L_B9F4
	CALL	L_BA90
	LD	B,A
	CALL	L_BA42
	OR	B
	JP	Z,L_B93E
	LD	(IX+#04),#00
	JP	L_B8C3
;
L_B9D0	CALL	L_BA42
	LD	B,A
	CALL	L_BA61
	OR	B
	JP	Z,L_B93E
	LD	(IX+#04),#00
	JP	L_B8C3
;
L_B9E2	CALL	L_BA61
	LD	B,A
	CALL	L_BA20
	OR	B
	JP	Z,L_B93E
	LD	(IX+#04),#00
	JP	L_B8C3
;
L_B9F4	CALL	L_BA20
	LD	B,A
	CALL	L_BA90
	OR	B
	JP	Z,L_B93E
	LD	(IX+#04),#00
	JP	L_B8C3
;
L_BA06	PUSH	BC
	PUSH	HL
	CALL	L_BA42
	LD	H,A
	CALL	L_BA20
	LD	L,A
	CALL	L_BA90
	LD	B,A
	CALL	L_BA61
	LD	C,A
	XOR	A
	OR	H
	OR	L
	OR	B
	OR	C
	POP	HL
	POP	BC
	RET
;
L_BA20	PUSH	BC
	PUSH	DE
	PUSH	HL
	DEC	E
	DEC	E
	DEC	E
	DEC	E
	INC	D
	INC	D
	INC	D
	INC	D
	CALL	L_97EE
	INC	L
	INC	L
	LD	BC,#0020
	LD	A,(HL)
	LD	E,A
	LD	A,D
	AND	#07
	LD	A,E
	JR	Z,L_BA3D
	ADD	HL,BC
	OR	(HL)
L_BA3D	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_BA42	PUSH	BC
	PUSH	DE
	PUSH	HL
	INC	E
	INC	E
	INC	E
	INC	D
	INC	D
	INC	D
	INC	D
	CALL	L_97EE
	LD	BC,#0020
	LD	A,(HL)
	LD	E,A
	LD	A,D
	AND	#07
	LD	A,E
	JR	Z,L_BA5C
	ADD	HL,BC
	OR	(HL)
L_BA5C	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_BA61	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,D
	CP	#B0
	LD	A,#01
	JR	NC,L_BA8B
	INC	E
	INC	E
	INC	E
	INC	E
	DEC	D
	DEC	D
	DEC	D
	DEC	D
	LD	A,D
	AND	#0F
	LD	A,#00
	JR	NZ,L_BA8B
	CALL	L_97EE
	LD	BC,#0040
	ADD	HL,BC
	LD	A,(HL)
	LD	D,A
	LD	A,E
	AND	#07
	LD	A,D
	JR	Z,L_BA8B
	INC	L
	OR	(HL)
L_BA8B	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_BA90	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,D
	OR	A
	LD	A,#01
	JR	Z,L_BAB9
	INC	E
	INC	E
	INC	E
	INC	E
	INC	D
	INC	D
	INC	D
	INC	D
	LD	A,D
	AND	#0F
	LD	A,#00
	JR	NZ,L_BAB9
	CALL	L_97EE
	LD	BC,L_FFE0
	ADD	HL,BC
	LD	A,(HL)
	LD	D,A
	LD	A,E
	AND	#07
	LD	A,D
	JR	Z,L_BAB9
	INC	L
	OR	(HL)
L_BAB9	OR	A
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_BABE	LD	A,(L_A390)
	LD	BC,L_BAF5
	CALL	GetHLFrom2APlusBC
	LD	DE,L_BB1F
	LD	BC,#0063
	LDIR
	RET
;
L_BAD0	LD	IX,L_BB1F
L_BAD4	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_BAEE
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_BAEE
	LD	(IX+#02),#00
L_BAEE	LD	BC,#0005
	ADD	IX,BC
	JR	L_BAD4
;
L_BAF5       DW       L_BB84
       DW       L_BB85
       DW       L_BB86
       DW       L_BB8C
       DW       L_BB8D
       DW       L_BBAC
       DW       L_BBAD
       DW       L_BBAE
       DW       L_BBC3
       DW       L_BBC4
       DW       L_BBC5
       DW       L_BBCB
       DW       L_BBCC
       DW       L_BBCD
       DW       L_BBCE
       DW       L_BBD9
       DW       L_BBDA
       DW       L_BBDB
       DW       L_BBDC
       DW       L_BBDD
       DW       L_BBDE
;
L_BB1F       DB       #FF,#FF,#B8,#2C,#01,#02,#00,#FF
       DB       #FF,#78,#24,#03,#02,#00,#58,#44
       DB       #03,#02,#00,#78,#64,#03,#02,#00
       DB       #98,#44,#03,#02,#00,#48,#84,#03
       DB       #02,#00,#A8,#84,#03,#02,#00,#FF
       DB       #FF,#FF,#58,#74,#03,#02,#00,#58
       DB       #6C,#01,#02,#00,#B8,#74,#03,#02
       DB       #00,#B8,#6C,#01,#02,#00,#FF,#FF
       DB       #FF,#38,#94,#03,#02,#00,#FF,#FF
       DB       #FF,#FF,#D8,#94,#03,#04,#00,#D8
       DB       #7C,#01,#04,#00,#FF,#FF,#FF,#FF
       DB       #FF,#FF,#FF,#DD,#21,#1F,#BB,#DD
       DB       #7E,#00,#FE,#00,#FF
L_BB84       DB       #FF
L_BB85       DB       #FF
L_BB86       DB       #B8,#2C,#01,#02,#00,#FF
L_BB8C       DB       #FF
L_BB8D       DB       #78,#24,#03,#02,#00,#58,#44,#03
       DB       #02,#00,#78,#64,#03,#02,#00,#98
       DB       #44,#03,#02,#00,#48,#84,#03,#02
       DB       #00,#A8,#84,#03,#02,#00,#FF
L_BBAC       DB       #FF
L_BBAD       DB       #FF
L_BBAE       DB       #58,#74,#03,#02,#00,#58,#6C,#01
       DB       #02,#00,#B8,#74,#03,#02,#00,#B8
       DB       #6C,#01,#02,#00,#FF
L_BBC3       DB       #FF
L_BBC4       DB       #FF
L_BBC5       DB       #38,#94,#03,#02,#00,#FF
L_BBCB       DB       #FF
L_BBCC       DB       #FF
L_BBCD       DB       #FF
L_BBCE       DB       #D8,#94,#03,#04,#00,#D8,#7C,#01
       DB       #04,#00,#FF
L_BBD9       DB       #FF
L_BBDA       DB       #FF
L_BBDB       DB       #FF
L_BBDC       DB       #FF
L_BBDD       DB       #FF
L_BBDE       DB       #FF
;
L_BBDF	LD	IX,L_BB1F
L_BBE3	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_BBF7
L_BBEF	LD	BC,#0005
	ADD	IX,BC
	JP	L_BBE3
;
L_BBF7	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	A,(IX+#04)
	OR	A
	JP	NZ,L_BCE0
	LD	A,(IX+#02)
	CP	#01
	JR	Z,L_BC2D
	CP	#02
	JR	Z,L_BC44
	CP	#03
	JR	Z,L_BC5B
	CALL	L_BA90
	JR	Z,L_BC20
	LD	A,#01
	JP	L_BC72
;
L_BC20	CALL	L_BA20
	LD	A,#00
	JP	NZ,L_BC72
	LD	A,#03
	JP	L_BC72
;
L_BC2D	CALL	L_BA42
	JR	Z,L_BC37
	LD	A,#02
	JP	L_BC72
;
L_BC37	CALL	L_BA90
	LD	A,#00
	JP	NZ,L_BC72
	LD	A,#04
	JP	L_BC72
;
L_BC44	CALL	L_BA61
	JR	Z,L_BC4E
	LD	A,#03
	JP	L_BC72
;
L_BC4E	CALL	L_BA42
	LD	A,#00
	JP	NZ,L_BC72
	LD	A,#01
	JP	L_BC72
;
L_BC5B	CALL	L_BA20
	JR	Z,L_BC65
	LD	A,#04
	JP	L_BC72
;
L_BC65	CALL	L_BA61
	LD	A,#00
	JP	NZ,L_BC72
	LD	A,#02
	JP	L_BC72
;
L_BC72	LD	H,A
	LD	L,(IX+#02)
	LD	B,(IX+#03)
	OR	A
	JR	Z,L_BC7F
	LD	(IX+#02),A
L_BC7F	LD	A,(IX+#02)
	CP	#01
	JR	NZ,L_BC8D
	LD	A,B
	NEG
	ADD	A,E
	LD	E,A
	JR	L_BCA4
;
L_BC8D	CP	#02
	JR	NZ,L_BC96
	LD	A,B
	ADD	A,D
	LD	D,A
	JR	L_BCA4
;
L_BC96	CP	#03
	JR	NZ,L_BC9F
	LD	A,B
	ADD	A,E
	LD	E,A
	JR	L_BCA4
;
L_BC9F	LD	A,B
	NEG
	ADD	A,D
	LD	D,A
L_BCA4	LD	A,(IX+#04)
	OR	A
	JR	NZ,L_BCC2
	LD	A,H
	OR	A
	JR	Z,L_BCC2
	CALL	L_BA06
	JR	NZ,L_BCC2
	LD	(IX+#04),#01
	LD	(IX+#02),L
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	JR	L_BCE0
;
L_BCC2	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	A,(L_9478)
	RRCA
	RRCA
	AND	#01
	ADD	A,#2D
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	JP	L_BBEF
;
L_BCE0	LD	A,(IX+#02)
	CP	#01
	JP	Z,L_BD04
	CP	#02
	JP	Z,L_BD16
	CP	#03
	JP	Z,L_BD28
	CALL	L_BA90
	LD	B,A
	CALL	L_BA20
	OR	B
	JP	Z,L_BC72
	LD	(IX+#04),#00
	JP	L_BBF7
;
L_BD04	CALL	L_BA42
	LD	B,A
	CALL	L_BA90
	OR	B
	JP	Z,L_BC72
	LD	(IX+#04),#00
	JP	L_BBF7
;
L_BD16	CALL	L_BA61
	LD	B,A
	CALL	L_BA42
	OR	B
	JP	Z,L_BC72
	LD	(IX+#04),#00
	JP	L_BBF7
;
L_BD28	CALL	L_BA20
	LD	B,A
	CALL	L_BA61
	OR	B
	JP	Z,L_BC72
	LD	(IX+#04),#00
	JP	L_BBF7
;
L_BD3A	LD	IY,L_BD52
	LD	(L_BF39),HL
	JP	(IY)
;
L_BD43	LD	IY,L_BD4A
	LD	(L_BF39),HL
L_BD4A	XOR	A
	IN	A,(#FE)
	AND	#1F
	CP	#1F
	RET	NZ
L_BD52	LD	HL,(L_BF39)
	LD	A,(HL)
	OR	A
	RET	Z
	INC	HL
	LD	(L_BF38),A
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	INC	HL
	LD	(L_BF39),HL
	LD	A,C
	OR	B
	JP	NZ,L_BD70
	LD	A,(L_BF38)
	CALL	L_BF4E
	JP	(IY)
;
L_BD70	LD	H,#00
	LD	L,C
	LD	DE,L_BFAC
	ADD	HL,DE
	LD	D,(HL)
	LD	H,#00
	LD	L,B
	LD	BC,L_BFAC
	ADD	HL,BC
	LD	E,(HL)
	LD	A,(L_BF38)
	CALL	L_BF87
	JP	(IY)
;
L_BD88       DB       #0F,#1C,#28,#0F,#1C,#2C,#0F,#1C
       DB       #2F,#0F,#1B,#27,#0F,#1B,#2B,#0F
       DB       #1B,#2E,#0F,#1A,#26,#0F,#1A,#2A
       DB       #0F,#1A,#2D,#0F,#19,#25,#0F,#19
       DB       #29,#0F,#19,#2C,#0F,#18,#24,#0F
       DB       #18,#28,#0F,#18,#2B,#0F,#17,#23
       DB       #0F,#17,#27,#0F,#17,#2A,#2D,#1C
       DB       #28,#00,#00
L_BDC3       DB       #12,#07,#13,#12,#08,#14,#12,#09
       DB       #15,#12,#0A,#16,#12,#0B,#17,#12
       DB       #0C,#18,#12,#0D,#19,#12,#0E,#1A
       DB       #12,#0F,#1B,#12,#10,#1C,#12,#11
       DB       #1D,#12,#12,#1E,#12,#13,#1F,#12
       DB       #14,#20,#12,#15,#21,#12,#17,#23
       DB       #24,#18,#24,#24,#18,#24
L_BDF9       DB       #24,#13,#26,#12,#13,#24,#12,#13
       DB       #26,#24,#18,#28,#12,#1C,#24,#12
       DB       #1C,#21,#24,#1F,#1F,#24,#1C,#1F
       DB       #24,#18,#24,#24,#18,#24,#24,#13
       DB       #26,#12,#13,#24,#12,#13,#26,#24
       DB       #18,#28,#12,#1F,#28,#12,#21,#28
       DB       #12,#23,#28,#12,#24,#28,#24,#26
       DB       #28,#24,#18,#24,#24,#18,#24,#24
       DB       #13,#26,#12,#13,#24,#12,#13,#26
       DB       #24,#18,#28,#12,#1C,#24,#12,#1C
       DB       #21,#24,#1F,#1F,#24,#1C,#1F,#24
       DB       #18,#24,#24,#18,#24,#24,#13,#26
       DB       #12,#13,#24,#12,#13,#26,#12,#18
       DB       #24,#12,#1C,#24,#12,#18,#24,#12
       DB       #1C,#24,#12,#1F,#24,#12,#1C,#24
       DB       #12,#1F,#24,#12,#24,#24,#24,#18
       DB       #2B,#24,#1C,#2B,#12,#18,#28,#12
       DB       #18,#26,#12,#1C,#24,#12,#1C,#24
       DB       #24,#18,#2B,#24,#1C,#2B,#12,#18
       DB       #28,#12,#18,#26,#12,#1C,#24,#12
       DB       #1C,#24,#24,#18,#2B,#24,#1C,#2B
       DB       #12,#18,#28,#12,#18,#26,#12,#1C
       DB       #24,#12,#1C,#24,#24,#18,#26,#12
       DB       #1C,#24,#12,#1C,#26,#24,#18,#28
       DB       #24,#1C,#24,#12,#13,#1F,#12,#17
       DB       #1F,#12,#1A,#1F,#12,#1F,#1F,#24
       DB       #18,#24,#24,#18,#24,#24,#13,#26
       DB       #12,#13,#24,#12,#13,#26,#24,#18
       DB       #28,#12,#1C,#24,#12,#1C,#21,#24
       DB       #1F,#1F,#24,#1C,#1F,#24,#18,#24
       DB       #24,#18,#24,#24,#13,#26,#12,#13
       DB       #24,#12,#13,#26,#24,#1C,#24,#24
       DB       #1A,#23,#24,#18,#21,#24,#1A,#23
L_BF01       DB       #24,#0C,#18,#12,#0C,#18,#12,#0C
       DB       #1A,#12,#10,#1C,#12,#10,#1F,#24
       DB       #13,#21,#24,#18,#24,#24,#1A,#23
       DB       #48,#1C,#24,#00,#00
L_BF1E       DB       #12,#07,#13,#12,#08,#14,#12,#09
       DB       #15,#12,#0A,#16,#12,#0B,#17,#12
       DB       #0C,#18,#12,#0D,#19,#12,#0E,#1A
       DB       #00,#00
;
L_BF38       DB       #24
;
L_BF39       DW       L_BDF9
;
L_BF3B	AND	#FF
	EX	AF,AF'
	INC	D
	JP	NZ,L_BF69
L_BF42	DB	#00
	DB	#00
	DB	#00
	XOR	C
	LD	D,L
	DJNZ	L_BF58
	DEC	H
	JP	NZ,L_BF5A
	RET
;
L_BF4E	LD	H,A
	LD	XL,E
	LD	L,D
	LD	C,#10
	XOR	A
	EX	AF,AF'
	XOR	A
	LD	B,A
L_BF58	OR	A
	AND	A
L_BF5A	EX	AF,AF'
	INC	E
	DB	#00
	DB	#00
	DB	#00
	JR	NZ,L_BF3B
	XOR	C
	LD	E,XL
	EX	AF,AF'
	INC	D
	JP	Z,L_BF42
L_BF69	DB	#00
	DB	#00
	DB	#00
	OR	A
	AND	A
	DJNZ	L_BF58
	DEC	H
	JP	NZ,L_BF5A
	RET
;
L_BF75	AND	#FF
	EX	AF,AF'
	INC	D
	JP	NZ,L_BFA1
L_BF7C	OUT	(#FE),A
	XOR	C
	LD	D,L
	DJNZ	L_BF91
	DEC	H
	JP	NZ,L_BF93
	RET
;
L_BF87	LD	H,A
	LD	XL,E
	LD	L,D
	LD	C,#10
	XOR	A
	EX	AF,AF'
	XOR	A
	LD	B,A
L_BF91	OR	A
	AND	A
L_BF93	EX	AF,AF'
	INC	E
	OUT	(#FE),A
	JR	NZ,L_BF75
	XOR	C
	LD	E,XL
	EX	AF,AF'
	INC	D
	JP	Z,L_BF7C
L_BFA1	OUT	(#FE),A
	OR	A
	AND	A
	DJNZ	L_BF91
	DEC	H
	JP	NZ,L_BF93
	RET
;
L_BFAC       DB       #01,#1D,#29,#34,#40,#4C,#54,#5F
       DB       #69,#70,#78,#80,#87,#8E,#94,#9A
       DB       #A0,#A5,#AA,#AF,#B4,#B8,#BC,#C0
       DB       #C3,#C7,#CA,#CD,#D0,#D3,#D5,#D8
       DB       #DA,#DC,#DE,#E0,#E2,#E4,#E5,#E7
       DB       #E8,#E9,#EB,#EC,#ED,#EE,#EF,#F0
       DB       #F1,#F2,#F3,#F4
;
L_BFE0	PUSH	HL
	LD	HL,(L_BFEF)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),#FF
	LD	(L_BFEF),HL
	POP	HL
	RET
;
L_BFEF       DW       L_BFF9
;
L_BFF1       DB       #38
;
       DB       #70,#B8,#70,#6B,#20,#7F,#80       ;p8pk ..
;
L_BFF9       DB       #FF,#B0,#FF,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #FF
;
L_C092	LD	A,E
	SUB	C
	SUB	#02
	CP	#EE
	LD	A,#00
	RET	C
	LD	A,D
	SUB	B
	SUB	#02
	CP	#EE
	LD	A,#00
	RET	C
	INC	A
	RET
;
L_C0A6	LD	HL,(L_C295)
	LD	A,L
	OR	H
	JP	Z,L_C0EE
	LD	DE,(L_A8C6)
	CALL	L_C0CC
	OR	A
	RET	Z
	LD	HL,L_BD88
	CALL	L_BD3A
L_C0BD	LD	A,(L_C255)
L_C0C0	DEC	A
	LD	(L_C255),A
	OR	A
	JP	Z,L_C13A
	POP	BC
	JP	L_932C
;
L_C0CC	PUSH	BC
	PUSH	HL
	LD	HL,L_BFF1
L_C0D1	LD	A,(HL)
	CP	#FF
	LD	A,#00
	JR	Z,L_C0EB
	LD	C,(HL)
	INC	HL
	LD	B,(HL)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	INC	HL
	CALL	L_C092
	OR	A
	JP	Z,L_C0D1
L_C0EB	POP	HL
	POP	BC
	RET
;
L_C0EE	LD	HL,L_BD88
	CALL	L_BD3A
	CALL	Cls
	LD	HL,L_C11B
	CALL	PrintString_HL
	LD	BC,#0000
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	JP	L_C0BD
;
L_C11B       DB       #DF,#00,#08,#EB,#00,#E3,#EC,#C5
       DB       #E6,#12,#D7,#EB,#00,#DF,#0B,#0A
       DB       #E0,#46,#4F,#55,#54,#20,#4F,#46
       DB       #20,#54,#49,#4D,#45,#21,#FF
;
L_C13A	CALL	Cls
	LD	HL,L_C164
	CALL	PrintString_HL
	LD	BC,#0000
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	PauseBC
	CALL	L_D5CA
	JP	L_9300
;
L_C164       DB       #EB,#00,#DF,#00,#08,#E3,#EC,#C5
       DB       #DF,#0A,#0B,#E6,#12,#D7,#E0,#46
       DB       #DF,#0B,#0B,#47,#41,#4D,#45,#20
       DB       #4F,#56,#45,#52,#FF
L_C181       DB       #EB,#00,#E6,#0A,#DA,#DF,#00,#01
       DB       #E0,#47,#00,#01,#02,#78,#06,#0E
       DB       #03,#04,#05,#78,#05,#0E,#06,#07
       DB       #08,#09,#0A,#78,#01,#0E,#0B,#0C
       DB       #0D,#FF
;
L_C1A3	LD	HL,L_C181
	CALL	PrintString_HL
	CALL	L_C1B5
	CALL	L_C1CE
	CALL	L_C1E1
	JP	L_C1EE
;
L_C1B5	LD	C,#47
	LD	HL,L_D712
	LD	(L_9A57),HL
	LD	HL,L_C21F
	LD	DE,#0004
	LD	B,#06
L_C1C5	LD	A,(HL)
	CALL	PrintChar
	INC	E
	INC	HL
	DJNZ	L_C1C5
	RET
;
L_C1CE	LD	C,#47
	LD	HL,L_C28F
	LD	DE,#000E
	LD	B,#05
L_C1D8	LD	A,(HL)
	CALL	PrintChar
	INC	E
	INC	HL
	DJNZ	L_C1D8
	RET
;
L_C1E1	LD	C,#47
	LD	A,(L_C256)
	ADD	A,#30
	LD	DE,#0019
	JP	PrintChar
;
L_C1EE	LD	C,#47
	LD	A,(L_C255)
	ADD	A,#30
	LD	E,#1E
	JP	PrintChar
;
L_C1FA	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,#00
	LD	HL,L_C224
	LD	B,#06
L_C205	LD	A,(DE)
	ADD	A,(HL)
	SUB	#30
	ADD	A,C
	CP	#3A
	LD	C,#01
	JR	C,L_C214
	SUB	#0A
	JR	L_C215
;
L_C214	DEC	C
L_C215	LD	(HL),A
	DEC	HL
	DEC	DE
	DJNZ	L_C205
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_C21F       DM       "0"
L_C220       DM       "0000"
L_C224       DM       "000010"
L_C22A       DM       "000020"
L_C230       DM       "000050"
L_C236       DM       "000100"
L_C23C       DM       "000200"
L_C242       DM       "0"
       DM       "005000"
       DM       "010000"
       DM       "020000"
;
L_C255       DB       #06
L_C256       DB       #00
;
L_C257	LD	HL,(L_C295)
	LD	IX,L_C28F
	LD	IY,L_C284
L_C262	LD	A,#30
	LD	E,(IY+#00)
	LD	D,(IY+#01)
L_C26A	OR	A
	SBC	HL,DE
	JR	C,L_C272
	INC	A
	JR	L_C26A
;
L_C272	ADD	HL,DE
	LD	(IX+#00),A
	INC	IX
	INC	IY
	INC	IY
	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	JR	L_C262
;
L_C284       DB       #10,#27,#E8,#03,#64,#00,#0A,#00
       DB       #01,#00,#30
L_C28F       DB       #30,#39,#38,#34
L_C293       DB       #30,#FF
;
L_C295       DW       #2670
L_C297       DW       #2710
;
L_C299	CALL	L_C34E
	OR	A
	RET	NZ
	CALL	L_AB46
	LD	BC,(L_A8C6)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	CALL	L_C092
	OR	A
	RET	Z
	LD	(HL),A
	LD	HL,L_BF1E
	PUSH	DE
	CALL	L_BD3A
	POP	DE
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#9000
	ADD	HL,BC
	LD	A,(HL)
	CALL	DrawSprite
	CALL	CountxytoXY_DE
	CALL	L_AAE5
	PUSH	DE
	CALL	L_C33C
	LD	B,D
	LD	C,E
	POP	DE
	JP	L_D725
;
L_C2D9	LD	HL,L_A485
L_C2DC	LD	A,(HL)
	CP	#FF
	RET	Z
	INC	HL
	INC	HL
	LD	(HL),#00
	INC	HL
	JR	L_C2DC
;
L_C2E7	CALL	L_C34E
	OR	A
	RET	Z
	CALL	L_C33C
	LD	BC,(L_A8C6)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	CALL	L_C092
	OR	A
	RET	Z
	POP	BC
	LD	A,(L_A390)
	CP	#14
	JR	NZ,L_C30F
	LD	A,#04
	LD	(L_A390),A
	JR	L_C31A
;
L_C30F	LD	A,(L_C3AB)
	OR	A
	JR	Z,L_C31A
	LD	A,#13
	LD	(L_A390),A
L_C31A	LD	A,(L_A390)
	CP	#10
	JR	NZ,L_C326
	CALL	L_C2D9
	LD	A,#FF
L_C326	INC	A
	LD	(L_A390),A
	LD	HL,L_BF01
	CALL	L_BD3A
	LD	DE,L_C293
	CALL	L_C1FA
	CALL	L_C1B5
	JP	L_932C
;
L_C33C	PUSH	BC
	PUSH	HL
	LD	BC,L_A45B
	LD	HL,(L_A390)
	LD	H,#00
	ADD	HL,HL
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	POP	HL
	POP	BC
	RET
;
L_C34E	PUSH	BC
	LD	HL,(L_A390)
L_C350       EQU       $-2
	LD	H,#00
	LD	B,H
	LD	C,L
	ADD	HL,HL
	ADD	HL,BC
	LD	BC,L_A485
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	POP	BC
	RET
;
L_C363	PUSH	AF
	PUSH	BC
	PUSH	HL
	PUSH	DE
	LD	A,(L_A390)
	CP	#04
	JR	NZ,L_C3A6
	CALL	L_C34E
	LD	H,D
	LD	L,E
	OR	A
	JR	NZ,L_C3A6
	POP	DE
	PUSH	DE
	AND	A
	SBC	HL,DE
	JR	NZ,L_C3A6
	CALL	L_AAE5
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#9000
	ADD	HL,BC
	LD	A,(HL)
	CALL	DrawSprite
	XOR	A
	LD	(L_9AA6),A
	LD	A,(L_C3AB)
	XOR	#01
	LD	(L_C3AB),A
	LD	B,#2F
	JR	Z,L_C3A0
	LD	B,#61
L_C3A0	LD	A,B
	LD	C,#47
	CALL	L_9A82
L_C3A6	POP	DE
	POP	HL
	POP	BC
	POP	AF
	RET
;
L_C3AB       DB       #00
;
Menu	CALL	Cls
	LD	HL,tmenu
	CALL	PrintString_HL
	CALL	L_C49F
	CALL	WaitNoKey
	LD	HL,L_BDC3
	CALL	L_BD43
	LD	BC,#00C8
L_C3C4	PUSH	BC
	CALL	L_F69F
	CP	#31
	JR	C,L_C3F0
	CP	#36
	JR	NC,L_C3F0
	CP	#31
	JP	Z,L_932C
	CP	#32
	JP	Z,L_C4B9
	SUB	#33
	LD	E,A
	LD	A,(L_A7B8)
	CP	E
	JR	Z,L_C3F0
	LD	A,E
	LD	(L_A7B8),A
	LD	HL,tmenu
	CALL	PrintString_HL
	CALL	L_C49F
L_C3F0	POP	BC
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,L_C3C4
	CALL	L_D480
	JP	Menu
;
tmenu       DB       #EB,#00,#DF,#00,#08,#E3,#EC,#C5
       DB       #E6,#12,#D7,#DF,#09,#02,#E0,#44
;
       DM       "CONVERSION BY PROBE SOFTWARE"
;
       DB       #DF,#0C,#09,#DA
;
       DM       "1"
;
       DB       #DC
;
       DM       " START GAME"
;
       DB       #79,#F4,#DA
;
       DM       "2"
;
       DB       #DC
;
       DM       " DEFINE KEYS"
;
       DB       #79,#F3,#DA
;
       DM       "3"
;
       DB       #DC
;
       DM       " KEYBOARD"
;
       DB       #79,#F6,#DA
;
       DM       "4"
;
       DB       #DC
;
       DM       " INTERFACE 2"
;
       DB       #79,#F3,#DA
;
       DM       "5"
;
       DB       #DC
;
       DM       " KEMPSTON"
;
       DB       #DF,#17,#02,#DD
;
       DM       "SOLOMON'S KEY (C) 1987 TECMO"
;
       DB       #DF,#12,#0A,#E3,#4D,#C6,#FF
;
L_C49F	LD	A,(L_A7B8)
	ADD	A,#0E
	LD	D,A
	LD	E,#0B
	CALL	CountScrAddr_DEyx
	LD	DE,#5800
	ADD	HL,DE
	LD	(HL),#47
	LD	E,L
	LD	D,H
	INC	E
	LD	BC,#000D
	LDIR
	RET
;
L_C4B9	CALL	Cls
	XOR	A
	LD	(L_A7B8),A
	LD	HL,tselectkeys
	CALL	PrintString_HL
	LD	IX,L_A710
	LD	IY,topqam
	LD	DE,#090F
	LD	B,#05
L_C4D3	PUSH	BC
	LD	A,#3F
	LD	C,#44
	CALL	PrintChar
	PUSH	DE
	CALL	WaitNoKey
L_C4DF	CALL	L_F69F
	OR	A
	JR	Z,L_C4DF
	LD	(IX+#02),D
	LD	(IX+#06),E
	LD	DE,#000A
	ADD	IX,DE
	LD	(IY+#00),A
	INC	IY
	POP	DE
	LD	HL,L_C54B
	CP	#20
	JR	NZ,L_C500
	LD	HL,tspace
L_C500	CP	#0D
	JR	NZ,L_C507
	LD	HL,tenter
L_C507	CP	#01
	JR	NZ,L_C50E
	LD	HL,tcapsshift
L_C50E	CP	#02
	JR	NZ,L_C515
	LD	HL,tsymbolshift
L_C515	LD	(L_C54B),A
	LD	C,#43
	CALL	PrintString_HL
	POP	BC
	DJNZ	L_C4D3
	LD	BC,L_C350
	CALL	PauseBC
	CALL	PauseBC
	LD	HL,topqam
	LD	DE,teborp
	LD	B,#05
L_C531	LD	A,(DE)
	CP	(HL)
	JP	NZ,Menu
	INC	HL
	INC	DE
	DJNZ	L_C531
	LD	A,(L_C0C0)
	XOR	#3D
	LD	(L_C0C0),A
	LD	HL,L_BF01
	CALL	Z,L_BD3A
	JP	Menu
;
L_C54B       DB       #4D,#7A,#FF,#FF
;
tspace       DM       "SPACE"
;
       DB       #7A,#FB,#FF
;
tenter       DM       "ENTER"
;
       DB       #7A,#FB,#FF
;
tcapsshift       DM       "CAPS SHIFT"
;
       DB       #7A,#F6,#FF
;
tsymbolshift       DM       "SYMBOL SHIFT"
;
       DB       #7A,#F4,#FF
;
topqam       DM       "OPQAM"
teborp       DM       "EBORP"
;
tselectkeys       DB       #EB,#00,#E0,#46,#DF,#06,#07,#E6
       DB       #12,#D7
;
       DM       "SELECT KEY FOR...."
;
       DB       #DE,#7B,#EE
;
       DM       "LEFT"
;
       DB       #7A,#FC
;
       DM       "RIGHT"
;
       DB       #7A,#FB
;
       DM       "JUMP"
;
       DB       #7A,#FC
;
       DM       "DUCK"
;
       DB       #7A,#FC
;
       DM       "BLOCKS"
;
       DB       #70,#02,#E5,#09,#20,#DF,#17,#02
       DB       #DE
;
       DM       "SOLOMON'S KEY (C) 1987 TECMO"
;
       DB       #E6,#12,#D7,#FF,#E6,#82,#DA,#E0       ;f.W.f.Z`
       DB       #43,#00,#01,#02,#03,#04,#05,#06       ;C.......
       DB       #07,#A7,#08,#09,#0A,#0B,#0C,#0D       ;.'......
       DB       #0E,#0F,#A7,#10,#11,#12,#13,#14       ;..'.....
       DB       #15,#16,#17,#76,#00,#18,#19,#1A       ;...v....
       DB       #1B,#1C,#1D,#1E,#1F,#A7,#20,#21       ;.....' !
       DB       #22,#23,#24,#25,#26,#27,#A7,#28       ;"#$%&''(
       DB       #29,#2A,#2B,#2C,#2D,#2E,#2F,#79       ;)*+,-./y
       DB       #F0,#30,#31,#32,#79,#01,#DB,#E6       ;p012y.[f
       DB       #1A,#DC,#00,#01,#02,#03,#04,#05       ;.\......
       DB       #06,#07,#A7,#08,#09,#0A,#0B,#0C       ;..'.....
       DB       #0D,#0E,#0F,#A7,#10,#11,#12,#13       ;...'....
       DB       #14,#15,#16,#17,#FF,#E6,#DA,#DC       ;.....fZ\
       DB       #E0,#07,#17,#E4,#05,#15,#12,#15       ;`..d....
       DB       #15,#13,#14,#A4,#18,#00,#01,#02       ;...$....
       DB       #03,#04,#05,#06,#07,#10,#1A,#A4       ;.......$
       DB       #18,#08,#09,#0A,#0B,#0C,#0D,#0E       ;........
       DB       #0F,#11,#1A,#A4,#19,#E4,#09,#1C       ;...$.d..
       DB       #1B,#FF       ;..
;
L_C67A	LD	A,(L_C72B)
	LD	B,A
	LD	A,(L_C899)
	OR	B
	RET	NZ
	LD	A,#FE
	IN	A,(#FE)
	AND	#10
	RET	NZ
	LD	A,(L_C256)
	OR	A
	RET	Z
	DEC	A
	LD	(L_C256),A
	CALL	L_C1E1
	LD	A,(L_A8C8)
	OR	A
	JR	Z,L_C6B2
	LD	DE,(L_A8C6)
	LD	A,E
	AND	#F8
	LD	E,A
	LD	A,D
	CP	#B0
	JP	Z,L_C87A
	AND	#F8
	ADD	A,#04
	LD	D,A
	JP	L_C87A
;
L_C6B2	LD	DE,(L_A8C6)
	LD	A,E
	AND	#F8
	LD	E,A
	LD	A,D
	CP	#B0
	JP	Z,L_C70C
	AND	#F8
	ADD	A,#04
	LD	D,A
	JP	L_C70C
;
L_C6C8	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,(L_C72B)
	LD	B,A
	LD	A,(L_C899)
	OR	B
	JR	Z,L_C706
	LD	BC,(L_C70A)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	CALL	L_C092
	OR	A
	JR	Z,L_C706
	PUSH	AF
	LD	A,(L_C72B)
	OR	A
	LD	A,#01
	JR	Z,L_C6FC
	LD	(L_C72B),A
	CALL	L_CE85
	CALL	L_CE19
	POP	AF
	JR	L_C706
;
L_C6FC	LD	(L_C899),A
	CALL	L_CE85
	CALL	L_CE19
	POP	AF
L_C706	POP	HL
	POP	DE
	POP	BC
	RET
;
L_C70A       DW       #88E4
;
L_C70C	LD	IX,L_C726
	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	(IX+#02),#03
	LD	(IX+#05),#32
	CALL	L_BA06
	CPL
	LD	(IX+#04),A
	RET
;
L_C726       DB       #B8,#2C,#01,#04,#00
;
L_C72B       DB       #00
       DB       #FF
;
L_C72D	LD	IX,L_C726
	LD	A,(IX+#05)
	OR	A
	RET	Z
L_C736	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	A,(IX+#04)
	OR	A
	JP	NZ,L_C820
	LD	A,(IX+#02)
	CP	#01
	JR	Z,L_C76C
	CP	#02
	JR	Z,L_C783
	CP	#03
	JR	Z,L_C79A
	CALL	L_BA90
	JR	Z,L_C75F
	LD	A,#01
	JP	L_C7B1
;
L_C75F	CALL	L_BA20
	LD	A,#00
	JP	NZ,L_C7B1
	LD	A,#03
	JP	L_C7B1
;
L_C76C	CALL	L_BA42
	JR	Z,L_C776
	LD	A,#02
	JP	L_C7B1
;
L_C776	CALL	L_BA90
	LD	A,#00
	JP	NZ,L_C7B1
	LD	A,#04
	JP	L_C7B1
;
L_C783	CALL	L_BA61
	JR	Z,L_C78D
	LD	A,#03
	JP	L_C7B1
;
L_C78D	CALL	L_BA42
	LD	A,#00
	JP	NZ,L_C7B1
	LD	A,#01
	JP	L_C7B1
;
L_C79A	CALL	L_BA20
	JR	Z,L_C7A4
	LD	A,#04
	JP	L_C7B1
;
L_C7A4	CALL	L_BA61
	LD	A,#00
	JP	NZ,L_C7B1
	LD	A,#02
	JP	L_C7B1
;
L_C7B1	LD	H,A
	LD	L,(IX+#02)
	LD	B,(IX+#03)
	OR	A
	JR	Z,L_C7BE
	LD	(IX+#02),A
L_C7BE	LD	A,(IX+#02)
	CP	#01
	JR	NZ,L_C7CC
	LD	A,B
	NEG
	ADD	A,E
	LD	E,A
	JR	L_C7E3
;
L_C7CC	CP	#02
	JR	NZ,L_C7D5
	LD	A,B
	ADD	A,D
	LD	D,A
	JR	L_C7E3
;
L_C7D5	CP	#03
	JR	NZ,L_C7DE
	LD	A,B
	ADD	A,E
	LD	E,A
	JR	L_C7E3
;
L_C7DE	LD	A,B
	NEG
	ADD	A,D
	LD	D,A
L_C7E3	LD	A,(IX+#04)
	OR	A
	JR	NZ,L_C801
	LD	A,H
	OR	A
	JR	Z,L_C801
	CALL	L_BA06
	JR	NZ,L_C801
	LD	(IX+#04),#01
	LD	(IX+#02),L
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	JR	L_C820
;
L_C801	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	A,(IX+#02)
	ADD	A,#51
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	LD	(L_C70A),DE
	DEC	(IX+#05)
	JP	Z,L_974A
	RET
;
L_C820	LD	A,(IX+#02)
	CP	#01
	JP	Z,L_C844
	CP	#02
	JP	Z,L_C856
	CP	#03
	JP	Z,L_C868
	CALL	L_BA90
	LD	B,A
	CALL	L_BA20
	OR	B
	JP	Z,L_C7B1
	LD	(IX+#04),#00
	JP	L_C736
;
L_C844	CALL	L_BA42
	LD	B,A
	CALL	L_BA90
	OR	B
	JP	Z,L_C7B1
	LD	(IX+#04),#00
	JP	L_C736
;
L_C856	CALL	L_BA61
	LD	B,A
	CALL	L_BA42
	OR	B
	JP	Z,L_C7B1
	LD	(IX+#04),#00
	JP	L_C736
;
L_C868	CALL	L_BA20
	LD	B,A
	CALL	L_BA61
	OR	B
	JP	Z,L_C7B1
	LD	(IX+#04),#00
	JP	L_C736
;
L_C87A	LD	IX,L_C894
	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	(IX+#02),#01
	LD	(IX+#05),#32
	CALL	L_BA06
	CPL
	LD	(IX+#04),A
	RET
;
L_C894       DB       #E4,#88,#04,#04,#00
;
L_C899       DB       #00
       DB       #FF
;
L_C89B	LD	IX,L_C894
	LD	A,(IX+#05)
	OR	A
	RET	Z
L_C8A4	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	A,(IX+#04)
	OR	A
	JP	NZ,L_C98E
	LD	A,(IX+#02)
	CP	#01
	JR	Z,L_C8DA
	CP	#02
	JR	Z,L_C8F1
	CP	#03
	JR	Z,L_C908
	CALL	L_BA90
	JR	Z,L_C8CD
	LD	A,#03
	JP	L_C91F
;
L_C8CD	CALL	L_BA42
	LD	A,#00
	JP	NZ,L_C91F
	LD	A,#01
	JP	L_C91F
;
L_C8DA	CALL	L_BA42
	JR	Z,L_C8E4
	LD	A,#04
	JP	L_C91F
;
L_C8E4	CALL	L_BA61
	LD	A,#00
	JP	NZ,L_C91F
	LD	A,#02
	JP	L_C91F
;
L_C8F1	CALL	L_BA61
	JR	Z,L_C8FB
	LD	A,#01
	JP	L_C91F
;
L_C8FB	CALL	L_BA20
	LD	A,#00
	JP	NZ,L_C91F
	LD	A,#03
	JP	L_C91F
;
L_C908	CALL	L_BA20
	JR	Z,L_C912
	LD	A,#02
	JP	L_C91F
;
L_C912	CALL	L_BA90
	LD	A,#00
	JP	NZ,L_C91F
	LD	A,#04
	JP	L_C91F
;
L_C91F	LD	H,A
	LD	L,(IX+#02)
	LD	B,(IX+#03)
	OR	A
	JR	Z,L_C92C
	LD	(IX+#02),A
L_C92C	LD	A,(IX+#02)
	CP	#01
	JR	NZ,L_C93A
	LD	A,B
	NEG
	ADD	A,E
	LD	E,A
	JR	L_C951
;
L_C93A	CP	#02
	JR	NZ,L_C943
	LD	A,B
	ADD	A,D
	LD	D,A
	JR	L_C951
;
L_C943	CP	#03
	JR	NZ,L_C94C
	LD	A,B
	ADD	A,E
	LD	E,A
	JR	L_C951
;
L_C94C	LD	A,B
	NEG
	ADD	A,D
	LD	D,A
L_C951	LD	A,(IX+#04)
	OR	A
	JR	NZ,L_C96F
	LD	A,H
	OR	A
	JR	Z,L_C96F
	CALL	L_BA06
	JR	NZ,L_C96F
	LD	(IX+#04),#01
	LD	(IX+#02),L
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	JR	L_C98E
;
L_C96F	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	A,(IX+#02)
	ADD	A,#51
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	LD	(L_C70A),DE
	DEC	(IX+#05)
	JP	Z,L_974A
	RET
;
L_C98E	LD	A,(IX+#02)
	CP	#01
	JP	Z,L_C9B2
	CP	#02
	JP	Z,L_C9C4
	CP	#03
	JP	Z,L_C9D6
	CALL	L_BA90
	LD	B,A
	CALL	L_BA42
	OR	B
	JP	Z,L_C91F
	LD	(IX+#04),#00
	JP	L_C8A4
;
L_C9B2	CALL	L_BA42
	LD	B,A
	CALL	L_BA61
	OR	B
	JP	Z,L_C91F
	LD	(IX+#04),#00
	JP	L_C8A4
;
L_C9C4	CALL	L_BA61
	LD	B,A
	CALL	L_BA20
	OR	B
	JP	Z,L_C91F
	LD	(IX+#04),#00
	JP	L_C8A4
;
L_C9D6	CALL	L_BA20
	LD	B,A
	CALL	L_BA90
	OR	B
	JP	Z,L_C91F
	LD	(IX+#04),#00
	JP	L_C8A4
;
L_C9E8	LD	BC,L_C9FA
	LD	A,(L_A390)
	CALL	GetHLFrom2APlusBC
	LD	DE,L_CA24
	LD	BC,#001E
	LDIR
	RET
;
L_C9FA       DW       L_CB35
       DW       L_CB36
       DW       L_CB37
       DW       L_CB3C
       DW       L_CB3D
       DW       L_CB3E
       DW       L_CB3F
       DW       L_CB40
       DW       L_CB41
       DW       L_CB42
       DW       L_CB43
       DW       L_CB44
       DW       L_CB45
       DW       L_CB46
       DW       L_CB47
       DW       L_CB4C
       DW       L_CB4D
       DW       L_CB4E
       DW       L_CB4F
       DW       L_CB50
       DW       L_CB51
;
L_CA24       DB       #FF,#FF,#D8,#80,#FD,#00,#FF,#FF
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #FF,#FF,#78,#20,#FD,#00,#FF,#FF
       DB       #FF,#FF,#FF,#FF,#B0,#40,#FF
;
L_CA43	LD	IX,L_CA24
L_CA47	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_CA61
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_CA61
	LD	(IX+#02),#00
L_CA61	LD	BC,#0004
	ADD	IX,BC
	JR	L_CA47
;
L_CA68	LD	IX,L_CA24
L_CA6C	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	D,(IX+#01)
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_CA84
	LD	BC,#0004
	ADD	IX,BC
	JP	L_CA6C
;
L_CA84	CALL	L_95E5
	LD	A,(IX+#03)
	OR	A
	JP	NZ,L_CB24
	LD	A,(IX+#02)
	CP	#FD
	JR	Z,L_CACB
	LD	C,A
	LD	B,#3B
	CALL	L_A927
	LD	A,C
	JR	Z,L_CAFE
	NEG
	LD	(IX+#02),A
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,E
	ADD	A,#10
	LD	E,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_CAC4
	LD	(IX+#03),#05
	CALL	L_AA1C
	JP	L_CB20
;
L_CAC4	POP	HL
	POP	DE
	POP	BC
	POP	AF
	JP	L_CAFE
;
L_CACB	LD	C,A
	LD	B,#3D
	CALL	L_A947
	LD	A,C
	JR	Z,L_CAFE
	NEG
	LD	(IX+#02),A
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	A,E
	SUB	#09
	LD	E,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#8D00
	ADD	HL,BC
	LD	A,(HL)
	CP	#02
	JR	C,L_CAFA
	LD	(IX+#03),#05
	CALL	L_AA1C
	JP	L_CB20
;
L_CAFA	POP	HL
	POP	DE
	POP	BC
	POP	AF
L_CAFE	ADD	A,E
	LD	E,A
L_CB00	LD	(IX+#00),E
	LD	A,(L_9478)
	AND	#01
	JR	Z,L_CB0B
	INC	B
L_CB0B	LD	A,B
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	CALL	L_94CD
	LD	BC,#0004
	ADD	IX,BC
	JP	L_CA6C
;
L_CB20	POP	HL
	POP	DE
	POP	BC
	POP	AF
L_CB24	DEC	(IX+#03)
	LD	A,(IX+#02)
	CP	#FD
	LD	B,#3C
	JP	Z,L_CB0B
	INC	B
	JP	L_CB0B
;
L_CB35       DB       #FF
L_CB36       DB       #FF
L_CB37       DB       #D8,#80,#FD,#00,#FF
L_CB3C       DB       #FF
L_CB3D       DB       #FF
L_CB3E       DB       #FF
L_CB3F       DB       #FF
L_CB40       DB       #FF
L_CB41       DB       #FF
L_CB42       DB       #FF
L_CB43       DB       #FF
L_CB44       DB       #FF
L_CB45       DB       #FF
L_CB46       DB       #FF
L_CB47       DB       #78,#20,#FD,#00,#FF
L_CB4C       DB       #FF
L_CB4D       DB       #FF
L_CB4E       DB       #FF
L_CB4F       DB       #FF
L_CB50       DB       #FF
L_CB51       DB       #B0,#40,#03,#00,#D8,#40,#03,#00
       DB       #10,#60,#FD,#00,#38,#60,#FD,#00
       DB       #B0,#80,#03,#00,#D8,#80,#03,#00
       DB       #FF
;
L_CB6A	LD	A,(L_A390)
	LD	BC,L_A4C5
	CALL	GetHLFrom2APlusBC
	LD	DE,L_A6B8
	LD	BC,#0050
	LDIR
	RET
;
L_CB7C	XOR	A
	LD	(L_9AA6),A
	LD	HL,L_A6B8
L_CB83	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	CP	#01
	JR	NZ,L_CB83
	LD	A,C
	LD	C,#47
	CALL	CountXYtoxy_DE
	CALL	L_9A82
	JP	L_CB83
;
L_CB9F	LD	HL,L_A6B8
L_CBA2	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	INC	HL
	LD	A,(HL)
	INC	HL
	CP	#01
	CALL	Z,L_AB46
	JP	L_CBA2
;
L_CBB5	XOR	A
	LD	(L_9AA6),A
	LD	HL,L_A6B8
L_CBBC	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	E,A
	INC	HL
	LD	D,(HL)
	LD	A,E
	CP	C
	JR	NZ,L_CBE3
	LD	A,D
	CP	B
	JR	NZ,L_CBE3
	INC	HL
	LD	C,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	CP	#02
	JR	NZ,L_CBBC
	DEC	HL
	LD	(HL),#01
	LD	A,C
	CALL	L_94CD
	CALL	CountXYtoxy_DE
	LD	C,#47
	JP	L_9A82
;
L_CBE3	INC	HL
	INC	HL
	INC	HL
	JR	L_CBBC
;
L_CBE8	LD	HL,L_A6B8
L_CBEB	LD	A,(HL)
	CP	#FF
	RET	Z
	LD	C,A
	INC	HL
	LD	B,(HL)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	INC	HL
	LD	A,(HL)
	EX	AF,AF'
	INC	HL
	LD	A,(HL)
	INC	HL
	CP	#01
	JR	NZ,L_CBEB
	LD	DE,(L_A8C6)
	CALL	L_C092
	OR	A
	JR	Z,L_CBEB
	EX	AF,AF'
	PUSH	BC
	LD	C,#32
L_CC12	LD	B,#0A
	CALL	L_D0B7
	DEC	C
	JR	NZ,L_CC12
	POP	BC
	CALL	L_CC43
	CALL	L_CC81
	DEC	HL
	LD	(HL),#00
	LD	A,C
	SUB	#08
	LD	E,A
	LD	A,B
	SUB	#08
	LD	D,A
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#9000
	ADD	HL,BC
	LD	A,(HL)
	CALL	DrawSprite
	CALL	CountxytoXY_DE
	CALL	L_95E5
	JP	L_974A
;
L_CC43	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,A
	LD	HL,L_CC65
L_CC4B	LD	A,(HL)
	CP	#FF
	JR	Z,L_CC60
	CP	C
	INC	HL
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	JR	Z,L_CC5A
	JR	L_CC4B
;
L_CC5A	CALL	L_C1FA
	CALL	L_C1B5
L_CC60	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_CC65       DB       #3F,#2A,#C2,#40,#30,#C2,#41,#36
       DB       #C2,#42,#3C,#C2,#43,#42,#C2,#44
       DB       #48,#C2,#45,#4E,#C2,#46,#54,#C2
       DB       #47,#3C,#C2,#FF
;
L_CC81	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	CP	#48
	JR	NZ,L_CC9A
	LD	A,(L_C256)
	CP	#03
	JR	Z,L_CCFD
	INC	A
	LD	(L_C256),A
	CALL	L_C1E1
	JP	L_CCFD
;
L_CC9A	CP	#49
	JR	NZ,L_CCB1
	LD	HL,(L_C297)
	SRL	H
	RR	L
	LD	(L_C295),HL
	CALL	L_C257
	CALL	L_C1CE
	JP	L_CCFD
;
L_CCB1	CP	#4A
	JR	NZ,L_CCC4
	LD	HL,(L_C297)
	LD	(L_C295),HL
	CALL	L_C257
	CALL	L_C1CE
	JP	L_CCFD
;
L_CCC4	CP	#4C
	JR	NZ,L_CCD4
	CALL	L_C33C
	CALL	L_CF70
	CALL	L_AAE5
	JP	L_CCFD
;
L_CCD4	CP	#5E
	JR	NZ,L_CCE8
	LD	HL,(L_C295)
	ADD	HL,HL
	LD	(L_C295),HL
	CALL	L_C257
	CALL	L_C1CE
	JP	L_CCFD
;
L_CCE8	CP	#5F
	JR	NZ,L_CCFD
	LD	HL,(L_C295)
	LD	B,H
	LD	C,H
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,BC
	LD	(L_C295),HL
	CALL	L_C257
	CALL	L_C1CE
L_CCFD	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_CD02	LD	A,(L_A390)
	LD	BC,L_CDAB
	CALL	GetHLFrom2APlusBC
	LD	DE,L_CDA2
	LD	BC,#0008
	LDIR
	XOR	A
	LD	(L_CD18),A
	RET
;
L_CD18       DB       #00
;
L_CD19	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	XOR	A
	LD	(L_9AA6),A
	LD	BC,#0002
	LD	IX,L_CDA2
L_CD2A	LD	A,(IX+#00)
	CP	#FF
	JR	Z,L_CD9B
	LD	L,A
	LD	H,(IX+#01)
	AND	A
	SBC	HL,DE
	JR	Z,L_CD3E
	ADD	IX,BC
	JR	L_CD2A
;
L_CD3E	LD	L,(IX+#00)
	LD	H,(IX+#01)
	LD	IX,L_A6B8
	LD	BC,#0004
L_CD4B	LD	A,(IX+#00)
	CP	#FF
	JR	Z,L_CD9B
	LD	E,A
	LD	D,(IX+#01)
	AND	A
	PUSH	HL
	SBC	HL,DE
	POP	HL
	JR	Z,L_CD61
	ADD	IX,BC
	JR	L_CD4B
;
L_CD61	LD	A,(IX+#03)
	CP	#01
	JR	NZ,L_CD9B
	EX	DE,HL
	LD	HL,L_CD18
	LD	A,(HL)
	INC	(HL)
	AND	#07
	LD	L,A
	LD	H,#00
	LD	BC,L_CDF0
	ADD	HL,BC
	LD	A,(HL)
	LD	(IX+#02),A
	PUSH	AF
	CALL	CountXYtoxy_DE
	CALL	CountScrAddr_DEyx
	LD	BC,#9000
	ADD	HL,BC
	LD	A,(HL)
	CALL	DrawSprite
	POP	AF
	LD	C,#47
	CALL	L_9A82
	CALL	CountxytoXY_DE
	PUSH	DE
	CALL	L_974A
	POP	DE
	CALL	L_AAE5
L_CD9B	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_CDA2       DB       #FF,#FF,#FF,#FF,#FF,#28,#50,#FF
       DB       #FF
;
L_CDAB       DW       L_CDD5
       DW       L_CDD6
       DW       L_CDD7
       DW       L_CDD8
       DW       L_CDD9
       DW       L_CDDA
       DW       L_CDDD
       DW       L_CDDE
       DW       L_CDDF
       DW       L_CDE0
       DW       L_CDE3
       DW       L_CDE4
       DW       L_CDE7
       DW       L_CDE8
       DW       L_CDE9
       DW       L_CDEA
       DW       L_CDEB
       DW       L_CDEC
       DW       L_CDED
       DW       L_CDEE
       DW       L_CDEF
;
L_CDD5       DB       #FF
L_CDD6       DB       #FF
L_CDD7       DB       #FF
L_CDD8       DB       #FF
L_CDD9       DB       #FF
L_CDDA       DB       #28,#50,#FF
L_CDDD       DB       #FF
L_CDDE       DB       #FF
L_CDDF       DB       #FF
L_CDE0       DB       #C8,#B0,#FF
L_CDE3       DB       #FF
L_CDE4       DB       #68,#90,#FF
L_CDE7       DB       #FF
L_CDE8       DB       #FF
L_CDE9       DB       #FF
L_CDEA       DB       #FF
L_CDEB       DB       #FF
L_CDEC       DB       #FF
L_CDED       DB       #FF
L_CDEE       DB       #FF
L_CDEF       DB       #FF
L_CDF0       DB       #48,#5E,#4A,#46,#4C,#49,#5F,#44
;
L_CDF8	LD	HL,L_CE06
	LD	DE,L_CE07
	LD	(HL),#00
	LD	BC,#0011
	LDIR
	RET
;
L_CE06       DB       #00
;
L_CE07       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#FF
;
L_CE19	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	LD	A,D
	AND	#F8
	LD	D,A
	LD	BC,#0003
	LD	IX,L_CE06
L_CE2A	LD	A,(IX+#00)
	CP	#FF
	JR	Z,L_CE48
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_CE43
	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	(IX+#02),#01
	JR	L_CE48
;
L_CE43	ADD	IX,BC
	JP	L_CE2A
;
L_CE48	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_CE4F	LD	IX,L_CE06
L_CE53	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_CE7D
	CALL	L_A964
	JR	NZ,L_CE6F
	INC	D
	INC	D
	INC	D
	INC	D
L_CE6F	LD	(IX+#01),D
	CALL	L_95E5
	CALL	L_AB46
	LD	A,#4B
	CALL	L_94CD
L_CE7D	LD	BC,#0003
	ADD	IX,BC
	JP	L_CE53
;
L_CE85	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	LD	A,#1E
L_CE8D	LD	B,#19
	CALL	L_D0B7
	DEC	A
	JR	NZ,L_CE8D
	LD	BC,#0003
	LD	IX,L_CEC1
L_CE9C	LD	A,(IX+#00)
	CP	#FF
	JR	Z,L_CEBA
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_CEB5
	LD	(IX+#02),#14
	LD	(IX+#00),E
	LD	(IX+#01),D
	JR	L_CEBA
;
L_CEB5	ADD	IX,BC
	JP	L_CE9C
;
L_CEBA	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_CEC1       DB       #89,#B0,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#FF
;
L_CEE0	LD	IX,L_CEC1
L_CEE4	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_CF02
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	A,#4D
	CALL	L_94CD
	DEC	(IX+#02)
	CALL	Z,L_974A
L_CF02	LD	BC,#0003
	ADD	IX,BC
	JP	L_CEE4
;
L_CF0A	LD	IX,L_CE06
L_CF0E	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_CF57
	LD	D,(IX+#01)
	LD	BC,(L_A8C6)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	CALL	L_C092
	OR	A
	JR	Z,L_CF57
	LD	(IX+#02),#00
	CALL	L_974A
	CALL	L_989A
	AND	#07
	LD	L,A
	LD	H,#00
	ADD	HL,HL
	LD	BC,L_CF5F
	ADD	HL,BC
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	CALL	L_C1FA
	LD	A,#1E
L_CF4C	LD	B,#0A
	CALL	L_D0B7
	DEC	A
	JR	NZ,L_CF4C
	JP	L_C1B5
;
L_CF57	LD	BC,#0003
	ADD	IX,BC
	JP	L_CF0E
;
L_CF5F       DW       L_C22A
       DW       L_C22A
       DW       L_C230
       DW       L_C230
       DW       L_C236
       DW       L_C236
       DW       L_C23C
       DW       L_C242
;
L_CF6F       DB       #00
;
L_CF70	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	LD	BC,#0003
	LD	IX,L_CFB0
L_CF7D	LD	A,(IX+#00)
	CP	#FF
	JR	Z,L_CF9B
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_CF96
	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	(IX+#02),#01
	JR	L_CF9B
;
L_CF96	ADD	IX,BC
	JP	L_CF7D
;
L_CF9B	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_CFA2	LD	HL,L_CFB0
	LD	DE,L_CFB1
	LD	BC,#000E
	LD	(HL),#00
	LDIR
	RET
;
L_CFB0       DB       #00
L_CFB1       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#FF
;
L_CFC0	LD	IX,L_CFB0
L_CFC4	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_D037
	LD	D,(IX+#01)
	CALL	L_95E5
	CALL	L_989A
	CP	#C8
	JR	C,L_CFE6
	LD	A,(L_A8C6)
	CP	E
	JR	C,L_CFF6
	JR	L_CFED
;
L_CFE6	CALL	L_989A
	AND	#01
	JR	Z,L_CFF6
L_CFED	CALL	L_BA20
	JR	NZ,L_CFF6
	INC	E
	JP	L_CFFC
;
L_CFF6	CALL	L_BA42
	JR	NZ,L_CFFC
	DEC	E
L_CFFC	CALL	L_989A
	CP	#C8
	JR	C,L_D00B
	LD	A,(L_A8C7)
	CP	D
	JR	C,L_D01A
	JR	L_D012
;
L_D00B	CALL	L_989A
	AND	#01
	JR	Z,L_D01A
L_D012	CALL	L_BA61
	JR	NZ,L_D01A
	INC	D
	JR	L_D020
;
L_D01A	CALL	L_BA90
	JR	NZ,L_D020
	DEC	D
L_D020	LD	(IX+#00),E
	LD	(IX+#01),D
	CALL	L_95E5
	CALL	L_AB46
	LD	A,(L_9478)
	RRCA
	AND	#03
	ADD	A,#4E
	CALL	L_94CD
L_D037	LD	BC,#0003
	ADD	IX,BC
	JP	L_CFC4
;
L_D03F	LD	IX,L_CFB0
L_D043	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_D092
	LD	D,(IX+#01)
	LD	BC,(L_A8C6)
	LD	A,B
	ADD	A,#08
	LD	B,A
	LD	A,C
	ADD	A,#08
	LD	C,A
	CALL	L_C092
	OR	A
	JR	Z,L_D092
	LD	(IX+#02),#00
	CALL	L_95E5
	CALL	L_974A
	LD	DE,L_C242
	CALL	L_C1FA
	CALL	L_C1B5
	CALL	L_D09A
	LD	A,(L_CF6F)
	INC	A
	CP	#0A
	JR	NZ,L_D08E
	LD	A,(L_C255)
	INC	A
	LD	(L_C255),A
	CALL	L_C1EE
	XOR	A
L_D08E	LD	(L_CF6F),A
	RET
;
L_D092	LD	BC,#0003
	ADD	IX,BC
	JP	L_D043
;
L_D09A	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	XOR	A
	LD	DE,#1F30
L_D0A2	LD	H,#0A
L_D0A4	XOR	#10
	OUT	(#FE),A
	LD	B,E
L_D0A9	DJNZ	L_D0A9
	DEC	H
	JR	NZ,L_D0A4
	INC	E
	DEC	D
	JR	NZ,L_D0A2
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_D0B7	PUSH	AF
	PUSH	BC
	PUSH	DE
L_D0BA	LD	A,R
	AND	#F8
	OUT	(#FE),A
	LD	E,B
	INC	E
L_D0C2	DEC	E
	JR	NZ,L_D0C2
	XOR	A
	OUT	(#FE),A
	DJNZ	L_D0BA
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_D0CE       DB       #00
L_D0CF       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#FF
;
L_D0DE	LD	HL,L_D0CE
	LD	DE,L_D0CF
	LD	BC,#000E
	LD	(HL),#00
	LDIR
	RET
;
L_D0EC	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	PUSH	AF
	LD	BC,#0003
	LD	IX,L_D0CE
L_D0F9	LD	A,(IX+#00)
	CP	#FF
	JR	Z,L_D119
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_D114
	POP	AF
	PUSH	AF
	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	(IX+#02),A
	JP	L_D119
;
L_D114	ADD	IX,BC
	JP	L_D0F9
;
L_D119	POP	AF
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	RET
;
L_D120	LD	IX,L_D0CE
L_D124	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_D1AD
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_95E5
	CP	#01
	JR	Z,L_D157
	CP	#03
	JR	Z,L_D169
	CP	#04
	JR	Z,L_D17B
	CALL	L_A964
	JR	Z,L_D150
	CALL	L_AC96
	JP	L_D18D
;
L_D150	LD	A,D
	ADD	A,#04
	LD	D,A
	JP	L_D196
;
L_D157	CALL	L_A947
	JR	Z,L_D162
	CALL	L_AC4E
	JP	L_D18D
;
L_D162	LD	A,E
	SUB	#04
	LD	E,A
	JP	L_D196
;
L_D169	CALL	L_A927
	JR	Z,L_D174
	CALL	L_AC2A
	JP	L_D18D
;
L_D174	LD	A,E
	ADD	A,#04
	LD	E,A
	JP	L_D196
;
L_D17B	CALL	L_A98F
	JR	Z,L_D186
	CALL	L_AC72
	JP	L_D18D
;
L_D186	LD	A,D
	SUB	#04
	LD	D,A
	JP	L_D196
;
L_D18D	LD	(IX+#02),#00
	CALL	L_AAE5
	JR	L_D1AD
;
L_D196	LD	(IX+#00),E
	LD	(IX+#01),D
	LD	A,(IX+#02)
	ADD	A,#51
	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
L_D1AD	LD	BC,#0003
	ADD	IX,BC
	JP	L_D124
;
L_D1B5	LD	A,(L_A390)
	LD	BC,L_D1C7
	CALL	GetHLFrom2APlusBC
	LD	DE,L_D21A
	LD	BC,#0019
	LDIR
	RET
;
L_D1C7       DW       L_D1F1
       DW       L_D1F2
       DW       L_D1F3
       DW       L_D1F9
       DW       L_D1FA
       DW       L_D1FB
       DW       L_D201
       DW       L_D207
       DW       L_D20D
       DW       L_D20E
       DW       L_D20F
       DW       L_D210
       DW       L_D211
       DW       L_D212
       DW       L_D213
       DW       L_D214
       DW       L_D215
       DW       L_D216
       DW       L_D217
       DW       L_D218
       DW       L_D219
;
L_D1F1       DB       #FF
L_D1F2       DB       #FF
L_D1F3       DB       #18,#80,#01,#00,#00,#FF
L_D1F9       DB       #FF
L_D1FA       DB       #FF
L_D1FB       DB       #78,#80,#01,#00,#00,#FF
L_D201       DB       #28,#30,#01,#00,#00,#FF
L_D207       DB       #18,#10,#01,#00,#00,#FF
L_D20D       DB       #FF
L_D20E       DB       #FF
L_D20F       DB       #FF
L_D210       DB       #FF
L_D211       DB       #FF
L_D212       DB       #FF
L_D213       DB       #FF
L_D214       DB       #FF
L_D215       DB       #FF
L_D216       DB       #FF
L_D217       DB       #FF
L_D218       DB       #FF
L_D219       DB       #FF
L_D21A       DB       #FF,#FF,#18,#80,#01,#00,#00,#FF
       DB       #FF,#FF,#78,#80,#01,#00,#00,#FF
       DB       #28,#30,#01,#00,#00,#FF,#18,#10
       DB       #01,#FF
;
L_D234	LD	IX,L_D21A
L_D238	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_D252
	LD	D,(IX+#01)
	CALL	L_C6C8
	OR	A
	JR	Z,L_D252
	LD	(IX+#02),#00
L_D252	LD	BC,#0005
	ADD	IX,BC
	JR	L_D238
;
L_D259	LD	IX,L_D21A
L_D25D	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	NZ,L_D272
L_D26A	LD	BC,#0005
	ADD	IX,BC
	JP	L_D25D
;
L_D272	LD	D,(IX+#01)
	CALL	L_95E5
	CALL	L_A964
	JR	NZ,L_D2C0
	LD	A,(IX+#03)
	CP	#04
	JR	C,L_D28B
	INC	D
	INC	D
	INC	D
	INC	D
	LD	(IX+#01),D
L_D28B	LD	A,(IX+#02)
	CP	#01
	LD	A,#56
	JR	Z,L_D296
	LD	A,#58
L_D296	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	INC	(IX+#03)
	LD	A,(IX+#03)
	CP	#08
	JP	NZ,L_D26A
	CALL	L_AAE5
	CALL	L_974A
	XOR	A
	LD	(IX+#02),A
	LD	(IX+#03),A
	LD	(IX+#04),A
	JP	L_D26A
;
L_D2C0	CALL	L_D370
	LD	A,(IX+#02)
	CP	#FF
	JR	Z,L_D2F8
	PUSH	DE
	LD	A,E
	ADD	A,#08
	LD	E,A
	CALL	L_A964
	POP	DE
	JR	Z,L_D2DA
	CALL	L_A927
	JR	Z,L_D323
L_D2DA	LD	(IX+#02),#FF
	CALL	L_AC2A
	OR	A
	JR	Z,L_D323
	PUSH	DE
	LD	A,E
	ADD	A,#10
	LD	E,A
	CALL	L_B23C
	POP	DE
	LD	(IX+#04),#0A
	LD	(IX+#02),#01
	JP	L_D323
;
L_D2F8	PUSH	DE
	LD	A,E
	SUB	#09
	LD	E,A
	CALL	L_A964
	POP	DE
	JR	Z,L_D308
	CALL	L_A947
	JR	Z,L_D323
L_D308	LD	(IX+#02),#01
	CALL	L_AC4E
	OR	A
	JR	Z,L_D323
	PUSH	DE
	LD	A,E
	SUB	#10
	LD	E,A
	CALL	L_B23C
	POP	DE
	LD	(IX+#02),#FF
	LD	(IX+#04),#0A
L_D323	LD	A,(IX+#04)
	OR	A
	JR	Z,L_D347
	DEC	(IX+#04)
	LD	A,(IX+#02)
	CP	#FF
	LD	A,#58
	JP	Z,L_D338
	LD	A,#56
L_D338	CALL	L_94CD
	CALL	L_95E5
	CALL	L_AB46
	CALL	L_BFE0
	JP	L_D26A
;
L_D347	LD	A,(IX+#02)
	ADD	A,E
	LD	E,A
	LD	(IX+#00),E
	LD	A,(IX+#02)
	LD	B,#58
	CP	#FF
	JR	Z,L_D35A
	LD	B,#56
L_D35A	LD	A,(L_9478)
	RRCA
	AND	#01
	ADD	A,B
	CALL	L_94CD
	CALL	L_AB46
	CALL	L_95E5
	CALL	L_BFE0
	JP	L_D26A
;
L_D370	LD	BC,(L_A8C6)
	LD	A,C
	CP	E
	JR	C,L_D382
	LD	A,(IX+#02)
	CP	#01
	RET	NZ
	LD	H,#03
	JR	L_D38A
;
L_D382	LD	A,(IX+#02)
	CP	#FF
	RET	NZ
	LD	H,#01
L_D38A	LD	A,D
	SUB	#11
	CP	B
	RET	NC
	ADD	A,#21
	CP	B
	RET	C
	LD	A,(L_9478)
	AND	#1F
	JR	NZ,L_D39E
	LD	A,H
	CALL	L_D0EC
L_D39E	LD	A,(IX+#02)
	LD	B,#58
	CP	#FF
	JR	Z,L_D3A9
	LD	B,#56
L_D3A9	LD	A,B
	CALL	L_94CD
	CALL	L_AB46
	CALL	L_95E5
	CALL	L_BFE0
	POP	BC
	LD	BC,#0005
	ADD	IX,BC
	JP	L_D25D
;
L_D3BF	LD	BC,L_D429
	LD	A,(L_A390)
	CALL	GetHLFrom2APlusBC
	LD	DE,L_D419
	LD	BC,#000F
	LDIR
	RET
;
L_D3D1	PUSH	HL
	LD	HL,L_D419
L_D3D5	LD	A,(HL)
	CP	#FF
	JR	Z,L_D3ED
	LD	E,A
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	A,(HL)
	INC	HL
	CALL	CountXYtoxy_DE
	ADD	A,#59
	LD	C,#47
	CALL	L_9A82
	JP	L_D3D5
;
L_D3ED	POP	HL
	RET
;
L_D3EF	LD	IX,L_D419
	LD	BC,#0003
L_D3F6	LD	A,(IX+#00)
	CP	#FF
	RET	Z
	LD	E,A
	LD	A,(IX+#02)
	OR	A
	JR	Z,L_D414
	LD	D,(IX+#01)
	CALL	L_AB46
	LD	A,(L_9478)
	AND	#3F
	LD	A,(IX+#02)
	CALL	Z,L_D0EC
L_D414	ADD	IX,BC
	JP	L_D3F6
;
L_D419       DB       #FF,#FF,#18,#20,#03,#FF,#FF,#FF
       DB       #FF,#FF,#FF,#FF,#FF,#18,#00,#FF
;
L_D429       DW       L_D453
       DW       L_D454
       DW       L_D455
       DW       L_D459
       DW       L_D45A
       DW       L_D45B
       DW       L_D45C
       DW       L_D45D
       DW       L_D45E
       DW       L_D45F
       DW       L_D460
       DW       L_D467
       DW       L_D468
       DW       L_D469
       DW       L_D46A
       DW       L_D46B
       DW       L_D47B
       DW       L_D47C
       DW       L_D47D
       DW       L_D47E
       DW       L_D47F
;
L_D453       DB       #FF
L_D454       DB       #FF
L_D455       DB       #18,#20,#03,#FF
L_D459       DB       #FF
L_D45A       DB       #FF
L_D45B       DB       #FF
L_D45C       DB       #FF
L_D45D       DB       #FF
L_D45E       DB       #FF
L_D45F       DB       #FF
L_D460       DB       #18,#00,#02,#28,#B0,#04,#FF
L_D467       DB       #FF
L_D468       DB       #FF
L_D469       DB       #FF
L_D46A       DB       #FF
L_D46B       DB       #08,#30,#03,#08,#40,#03,#08,#50
       DB       #03,#08,#60,#03,#08,#70,#03,#FF
L_D47B       DB       #FF
L_D47C       DB       #FF
L_D47D       DB       #FF
L_D47E       DB       #FF
L_D47F       DB       #FF
;
L_D480	CALL	Cls
	LD	HL,L_D4BD
	CALL	PrintString_HL
	LD	HL,L_D712
	LD	(L_9A57),HL
	LD	HL,L_D4C7
	LD	B,#0F
	LD	C,#46
	LD	DE,#0808
L_D499	PUSH	BC
	LD	B,#10
L_D49C	LD	A,(HL)
	CALL	PrintChar
	INC	HL
	INC	E
	DJNZ	L_D49C
	POP	BC
	INC	D
	LD	E,#08
	DJNZ	L_D499
	CALL	WaitNoKey
	LD	BC,#3A98
L_D4B0	PUSH	BC
	CALL	L_F69F
	OR	A
	POP	BC
	RET	NZ
	DEC	BC
	LD	A,B
	OR	C
	RET	Z
	JR	L_D4B0
;
L_D4BD       DB       #EB,#00,#DF,#00,#08,#E3,#EC,#C5
       DB       #FF,#00
;
L_D4C7       DM       "RAFFAELE  040000"
       DM       "SURYANI   030000"
       DM       "CHRIS     020000"
       DM       "FERGUS    010000"
       DM       "PROBE     009000"
       DM       "EQUINOX   008000"
       DM       "QUEEN     007000"
       DM       "NICK      006000"
       DM       "EEYUP!    005000"
       DM       "NATWEST   004000"
       DM       "THE..     003000"
       DM       "..HERO    002000"
       DM       "CUTEE     001000"
       DM       "TIKUS     001000"
       DM       "HANFRU    00100"
L_D5B6       DM       "0"
L_D5B7       DB       #FF       ;.
       DM       "ANFRU    00100"
L_D5C6       DM       "0"
       DB       #00,#00,#00       ;...
;
L_D5CA	LD	IX,L_D4C7
L_D5CE	BIT	7,(IX+#00)
	RET	NZ
	PUSH	IX
	LD	DE,#000A
	ADD	IX,DE
	LD	HL,L_C21F
	LD	B,#06
L_D5DF	LD	A,(IX+#00)
	CP	(HL)
	JP	Z,L_D69A
	JP	NC,L_D6A1
	POP	HL
	PUSH	HL
	LD	A,#FF
	LD	BC,#03E8
	CPIR
	LD	HL,#03E8
	AND	A
	SBC	HL,BC
	PUSH	HL
	POP	BC
	LD	DE,L_D5C6
	LD	HL,L_D5B6
	LDDR
	LD	A,#FF
	LD	(L_D5B7),A
	POP	HL
	PUSH	HL
	LD	DE,#000A
	ADD	HL,DE
	EX	DE,HL
	LD	HL,L_C21F
	LD	BC,#0006
	LDIR
	CALL	Cls
	LD	HL,L_D71D
	LD	DE,L_D71E
	LD	BC,#0007
	LD	(HL),#20
	LDIR
	LD	HL,L_D6AB
	CALL	PrintString_HL
	LD	DE,#0F0C
	LD	HL,L_D71D
L_D632	LD	C,#44
	LD	A,#3F
	CALL	PrintChar
L_D639	LD	BC,#03E8
	CALL	PauseBC
	CALL	WaitNoKey
	PUSH	DE
L_D643	CALL	L_F69F
	OR	A
	JR	Z,L_D643
	POP	DE
	CP	#0D
	JR	Z,L_D688
	CP	#01
	JR	Z,L_D659
	CP	#02
	JR	NZ,L_D679
	PUSH	DE
	JR	L_D643
;
L_D659	LD	A,E
	CP	#13
	JR	NZ,L_D667
	LD	A,(HL)
	CP	#20
	JR	Z,L_D667
	LD	(HL),#20
	JR	L_D632
;
L_D667	LD	A,E
	CP	#0C
	JR	Z,L_D632
	LD	A,#2D
	LD	C,#47
	CALL	PrintChar
	DEC	HL
	LD	(HL),#20
	DEC	E
	JR	L_D632
;
L_D679	LD	(HL),A
	LD	C,#46
	CALL	PrintChar
	LD	A,E
	CP	#13
	JR	Z,L_D639
	INC	HL
	INC	E
	JR	L_D632
;
L_D688	POP	DE
	LD	HL,L_D71D
	LD	BC,#0008
	LDIR
	CALL	WaitNoKey
	CALL	L_D480
	JP	L_9300
;
L_D69A	INC	HL
	INC	IX
	DEC	B
	JP	NZ,L_D5DF
L_D6A1	POP	IX
	LD	DE,#0010
	ADD	IX,DE
	JP	L_D5CE
;
L_D6AB       DB       #EB,#00,#DF,#00,#08,#E3,#EC,#C5
       DB       #DF,#08,#08,#E0,#46,#E6,#12,#D7
;
       DM       "CONGRATULATIONS!{"
;
       DB       #ED,#DB
;
       DM       "PLEASE ENTER YOUR NAME"
;
       DB       #DF,#0F,#0C,#DE,#2D,#2D,#2D,#2D
       DB       #2D,#2D,#2D,#2D,#7B,#F2,#DC
;
       DM       "PRESS CAPS TO DELETE"
;
       DB       #7A,#ED,#DD
;
       DM       "PRESS EN"
L_D712       DM       "TER TO END"
;
       DB       #FF
;
L_D71D       DM       "E"
L_D71E       DM       "RT     "
;
L_D725	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
	PUSH	IX
	LD	IX,L_D7BC
	LD	H,E
	LD	L,D
	LD	A,B
	LD	B,C
	LD	C,A
	LD	DE,#0101
	LD	A,B
	SUB	H
	JR	NC,L_D73F
	LD	D,#FF
	NEG
L_D73F	LD	B,A
	LD	A,C
	SUB	L
	JR	NC,L_D748
	LD	E,#FF
	NEG
L_D748	LD	C,A
	OR	B
	RET	Z
	LD	A,C
	CP	B
	LD	(IX+#00),H
	LD	(IX+#01),L
	LD	H,D
	LD	L,E
	LD	(IX+#04),H
	LD	(IX+#03),L
	LD	L,#00
	JR	C,L_D763
	LD	H,L
	LD	L,E
	LD	C,B
	LD	B,A
L_D763	LD	(IX+#06),H
	LD	(IX+#05),L
	LD	(IX+#02),B
	LD	A,B
	SRL	A
	LD	(IX+#07),A
	LD	(IX+#09),B
	LD	(IX+#08),C
	POP	IX
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
L_D77F	LD	B,(IX+#09)
	LD	C,(IX+#08)
	LD	L,(IX+#07)
	LD	A,L
	ADD	A,C
	JR	C,L_D78F
	CP	B
	JR	C,L_D79B
L_D78F	SUB	B
	LD	(IX+#07),A
	LD	D,(IX+#04)
	LD	E,(IX+#03)
	JR	L_D7A4
;
L_D79B	LD	(IX+#07),A
	LD	D,(IX+#06)
	LD	E,(IX+#05)
L_D7A4	LD	H,(IX+#00)
	LD	L,(IX+#01)
	LD	A,H
	ADD	A,D
	LD	H,A
	LD	A,L
	ADD	A,E
	LD	L,A
	LD	D,L
	LD	E,H
	DEC	(IX+#02)
	LD	(IX+#00),E
	LD	(IX+#01),D
	RET
;
L_D7BC       DB       #78,#10
;
L_D7BE       DB       #00
;
       DB       #FF,#FF,#FF,#00,#40,#30,#80       ;....@0.
;
L_D7C6	LD	IX,L_D7BC
	LD	A,(IX+#02)
	OR	A
	RET	Z
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_95E5
	LD	B,#08
L_D7DA	PUSH	BC
	LD	E,(IX+#00)
	LD	D,(IX+#01)
	CALL	L_D77F
	POP	BC
	JR	Z,L_D7F6
	DJNZ	L_D7DA
	LD	A,(L_9478)
	AND	#01
	ADD	A,#08
	CALL	L_94CD
	JP	L_95E5
;
L_D7F6	CALL	L_C33C
	LD	A,#01
	CALL	L_94CD
	CALL	L_AAE5
	CALL	L_95E5
	CALL	CountXYtoxy_DE
	XOR	A
	LD	(L_9AA6),A
	LD	A,#01
	LD	C,#47
	JP	L_9A82
;
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#1C,#1C,#1C,#1C,#00,#1C,#00       ;........
       DB       #00,#77,#77,#00,#00,#00,#00,#00       ;.ww.....
       DB       #00,#24,#7E,#24,#24,#7E,#24,#00       ;.$~$$~$.
       DB       #18,#18,#5A,#58,#18,#5A,#18,#18       ;..ZX.Z..
       DB       #00,#60,#4E,#1C,#38,#72,#06,#00       ;.`N.8r..
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#38,#38,#70,#00,#00,#00,#00       ;.88p....
       DB       #00,#1C,#38,#38,#38,#38,#1C,#00       ;..8888..
       DB       #00,#38,#1C,#1C,#1C,#1C,#38,#00       ;.8....8.
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#1C,#1C,#7F,#1C,#1C,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#38,#38,#70       ;.....88p
       DB       #00,#00,#00,#7E,#00,#00,#00,#00       ;...~....
       DB       #00,#00,#00,#00,#38,#38,#38,#00       ;....888.
       DB       #00,#00,#0E,#1C,#38,#70,#00,#00       ;....8p..
       DB       #00,#3C,#72,#76,#7A,#72,#3C,#00       ;.<rvzr<.
       DB       #00,#1C,#3C,#1C,#1C,#1C,#1C,#00       ;..<.....
       DB       #00,#3C,#5E,#1E,#7C,#70,#7E,#00       ;.<^.|p~.
       DB       #00,#7C,#1E,#3C,#1E,#1E,#7C,#00       ;.|.<..|.
       DB       #00,#70,#74,#74,#7E,#7E,#04,#00       ;.ptt~~..
       DB       #00,#7E,#70,#7C,#1E,#1E,#7C,#00       ;.~p|..|.
       DB       #00,#3C,#70,#7C,#72,#72,#3C,#00       ;.<p|rr<.
       DB       #00,#7E,#1E,#1E,#3C,#78,#70,#00       ;.~..<xp.
       DB       #00,#3C,#72,#7C,#32,#72,#3C,#00       ;.<r|2r<.
       DB       #00,#3C,#72,#72,#3E,#1E,#7C,#00       ;.<rr>.|.
       DB       #00,#38,#38,#00,#00,#38,#38,#00       ;.88..88.
       DB       #00,#00,#38,#38,#00,#38,#38,#70       ;..88.88p
       DB       #00,#0E,#1C,#38,#70,#38,#1C,#0E       ;...8p8..
       DB       #00,#00,#7E,#00,#00,#7E,#00,#00       ;..~..~..
       DB       #00,#70,#38,#1C,#0E,#1C,#38,#70       ;.p8...8p
       DB       #00,#7C,#EE,#0E,#3C,#70,#00,#70       ;.|n.<p.p
       DB       #00,#38,#44,#54,#54,#5C,#40,#3C       ;.8DTT\@<
       DB       #00,#3C,#72,#72,#7E,#72,#72,#00       ;.<rr~rr.
       DB       #00,#7C,#72,#7C,#72,#72,#7C,#00       ;.|r|rr|.
       DB       #00,#3C,#72,#70,#70,#72,#3C,#00       ;.<rppr<.
       DB       #00,#7C,#72,#72,#72,#72,#7E,#00       ;.|rrrr~.
       DB       #00,#7E,#70,#7C,#70,#70,#7E,#00       ;.~p|pp~.
       DB       #00,#7E,#70,#7C,#70,#70,#70,#00       ;.~p|ppp.
       DB       #00,#3C,#72,#70,#76,#72,#3C,#00       ;.<rpvr<.
       DB       #00,#72,#72,#7E,#72,#72,#72,#00       ;.rr~rrr.
       DB       #00,#7C,#38,#38,#38,#38,#7C,#00       ;.|8888|.
       DB       #00,#7C,#38,#38,#38,#38,#70,#00       ;.|8888p.
       DB       #00,#72,#74,#78,#78,#74,#72,#00       ;.rtxxtr.
       DB       #00,#70,#70,#70,#70,#70,#7E,#00       ;.ppppp~.
       DB       #00,#72,#7E,#72,#72,#72,#72,#00       ;.r~rrrr.
       DB       #00,#72,#7A,#76,#72,#72,#72,#00       ;.rzvrrr.
       DB       #00,#3C,#72,#72,#72,#72,#3C,#00       ;.<rrrr<.
       DB       #00,#7C,#72,#72,#7C,#70,#70,#00       ;.|rr|pp.
       DB       #00,#3C,#72,#72,#72,#74,#3A,#00       ;.<rrrt:.
       DB       #00,#7C,#72,#72,#7C,#74,#72,#00       ;.|rr|tr.
       DB       #00,#3C,#72,#78,#3C,#5E,#3C,#00       ;.<rx<^<.
       DB       #00,#7C,#38,#38,#38,#38,#38,#00       ;.|88888.
       DB       #00,#72,#72,#72,#72,#72,#3C,#00       ;.rrrrr<.
       DB       #00,#72,#72,#72,#72,#34,#18,#00       ;.rrrr4..
       DB       #00,#72,#72,#72,#72,#7E,#72,#00       ;.rrrr~r.
       DB       #00,#42,#66,#3C,#18,#3C,#66,#00       ;.Bf<.<f.
       DB       #00,#44,#28,#38,#38,#38,#38,#00       ;.D(8888.
       DB       #00,#7E,#1E,#3C,#78,#70,#7E,#00       ;.~.<xp~.
       DB       #FF,#80,#BD,#B4,#BD,#9C,#9D,#BC       ;..=4=..<
       DB       #9D,#BC,#BD,#B8,#B9,#BC,#BD,#B8       ;.<=89<=8
       DB       #BD,#BC,#BD,#9C,#9D,#BC,#BD,#BC       ;=<=..<=<
       DB       #B9,#BC,#BD,#8C,#BD,#80,#D5,#00       ;9<=.=.U.
       DB       #00,#33,#44,#24,#14,#54,#23,#00       ;.3D$.T#.
       DB       #00,#26,#55,#56,#55,#55,#25,#00       ;.&UVUU%.
       DB       #00,#70,#40,#60,#40,#40,#70,#00       ;.p@`@@p.
       DB       #00,#62,#55,#65,#55,#55,#62,#00       ;.bUeUUb.
       DB       #00,#55,#55,#75,#55,#55,#57,#00       ;.UUuUUW.
       DB       #00,#30,#40,#20,#10,#50,#20,#00       ;.0@ .P .
       DB       #00,#75,#45,#65,#45,#45,#45,#00       ;.uEeEEE.
       DB       #00,#9D,#51,#99,#51,#51,#5D,#00       ;..Q.QQ].
       DB       #00,#89,#55,#9D,#55,#55,#95,#00       ;..U.UU..
       DB       #00,#10,#11,#10,#10,#11,#DC,#00       ;......\.
       DB       #00,#C0,#00,#80,#40,#40,#80,#00       ;.@..@@..
       DB       #00,#45,#45,#45,#45,#45,#74,#00       ;.EEEEEt.
       DB       #00,#5C,#51,#58,#50,#51,#9C,#00       ;.\QXPQ..
       DB       #00,#C0,#00,#80,#40,#40,#80,#00       ;.@..@@..
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#01,#07,#0F,#1F,#1F,#3F       ;.......?
       DB       #00,#00,#FE,#FF,#FF,#FF,#87,#03       ;..~.....
       DB       #00,#00,#00,#80,#C0,#E0,#E0,#F0       ;....@``p
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #1F,#1F,#1F,#1F,#1F,#1F,#1F,#1F       ;........
       DB       #00,#E0,#C0,#C0,#C0,#C0,#C0,#C0       ;.`@@@@@@
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #3F,#3F,#3F,#1F,#1F,#07,#01,#F0       ;???....p
       DB       #03,#00,#80,#C0,#FC,#FF,#FF,#3F       ;...@|..?
       DB       #F0,#F0,#01,#03,#03,#87,#C7,#E7       ;pp....Gg
       DB       #3F,#FF,#FF,#FF,#FE,#FC,#FC,#FC       ;?...~|||
       DB       #9F,#EF,#F7,#F7,#3B,#3B,#3B,#3B       ;.oww;;;;
       DB       #80,#80,#80,#80,#80,#80,#80,#80       ;........
       DB       #07,#1F,#3F,#7F,#7F,#FF,#FF,#FF       ;..?.....
       DB       #F3,#FD,#FE,#FE,#C7,#87,#87,#87       ;s}~~G...
       DB       #FE,#FE,#FE,#FF,#7F,#7F,#3F,#1F       ;~~~...?.
       DB       #0F,#07,#07,#07,#8F,#FF,#FF,#FF       ;........
       DB       #E7,#F7,#F7,#F7,#F3,#E3,#E1,#C0       ;gwwwsca@
       DB       #F8,#F8,#F8,#F8,#FF,#FF,#FF,#7F       ;xxxx....
       DB       #7B,#7B,#7B,#F7,#F7,#EF,#DF,#1F       ;{{{wwo_.
       DB       #00,#00,#01,#03,#0F,#FF,#FF,#FF       ;........
       DB       #FF,#FF,#7F,#7F,#7F,#7F,#3F,#0F       ;......?.
       DB       #0F,#0F,#0F,#1E,#FE,#FD,#FB,#E3       ;....~}{c
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#0E,#0E,#0E,#1C,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #E0,#E0,#F1,#F1,#7B,#7B,#7F,#7F       ;``qq{{..
       DB       #F8,#F8,#F9,#FB,#FB,#F7,#F7,#F7       ;xxy{{www
       DB       #3F,#FF,#FF,#FF,#FE,#FC,#FC,#FC       ;?...~|||
       DB       #8F,#EF,#F7,#F7,#3B,#3B,#3B,#3B       ;.oww;;;;
       DB       #00,#80,#80,#C0,#E0,#E0,#F0,#F8       ;...@``px
       DB       #F1,#E7,#EF,#EF,#EF,#EF,#EF,#E7       ;qgooooog
       DB       #FC,#FF,#FF,#9F,#0F,#00,#C0,#F8       ;|.....@x
       DB       #00,#00,#00,#80,#80,#00,#00,#00       ;........
       DB       #7F,#7F,#6E,#EE,#C4,#C4,#80,#80       ;..nnDD..
       DB       #F7,#F7,#F7,#F7,#7B,#7B,#3D,#3C       ;wwww{{=<
       DB       #F8,#F8,#F8,#F8,#FF,#FF,#FF,#7F       ;xxxx....
       DB       #7B,#7B,#7B,#F7,#F7,#EF,#DF,#1F       ;{{{wwo_.
       DB       #F9,#FD,#BF,#1F,#0F,#07,#03,#01       ;y}?.....
       DB       #C3,#C0,#DE,#DE,#DF,#DF,#CF,#C3       ;C@^^__OC
       DB       #FC,#7E,#1E,#0F,#1F,#FF,#FE,#F8       ;|~....~x
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #07,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #FF,#FE,#00,#00,#00,#00,#00,#00       ;.~......
       DB       #80,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #07,#07,#07,#07,#0F,#0F,#0F,#0F       ;........
       DB       #F0,#F0,#F1,#E3,#E7,#EF,#FF,#FF       ;ppqcgo..
       DB       #7E,#FC,#F8,#F1,#E1,#C1,#81,#01       ;~|xqaA..
       DB       #FF,#FF,#FF,#FF,#FF,#FC,#FC,#FC       ;.....|||
       DB       #FE,#FE,#FD,#FD,#FD,#01,#00,#00       ;~~}}}...
       DB       #F8,#F8,#FC,#FC,#FE,#FF,#FF,#7F       ;xx||~...
       DB       #3F,#3F,#7F,#7F,#FF,#FE,#FC,#F8       ;??...~|x
       DB       #F0,#E0,#C0,#80,#00,#00,#00,#00       ;p`@.....
       DB       #0F,#0F,#0F,#0F,#1F,#1F,#1F,#1F       ;........
       DB       #FE,#FC,#F8,#F0,#E0,#C0,#E0,#F0       ;~|xp`@`p
       DB       #01,#03,#03,#03,#03,#03,#03,#07       ;........
       DB       #FC,#F8,#FF,#FF,#FF,#FF,#F8,#F0       ;|x....xp
       DB       #00,#00,#F8,#F0,#F0,#F0,#00,#00       ;..xppp..
       DB       #3F,#1F,#0F,#0F,#0F,#1F,#1F,#1F       ;?.......
       DB       #F0,#E0,#E0,#E0,#E0,#E0,#E0,#E0       ;p```````
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
       DB       #1F,#1F,#1F,#1F,#3F,#3F,#3F,#3F       ;....????
       DB       #F8,#FC,#FE,#BF,#9F,#0F,#07,#03       ;x|~?....
       DB       #07,#07,#07,#07,#87,#CF,#EF,#F7       ;.....Oow
       DB       #F0,#F0,#F0,#FF,#FF,#FF,#FF,#FF       ;ppp.....
       DB       #00,#00,#00,#F0,#F0,#F0,#E0,#E0       ;...ppp``
       DB       #3F,#3F,#3F,#7F,#7F,#7F,#FF,#FF       ;???.....
       DB       #E0,#E0,#E0,#E0,#E0,#E0,#E0,#E0       ;````````
       DB       #00,#00,#00,#00,#00,#00,#00,#00       ;........
;
L_DCDA       DB       #38,#20,#07,#0F,#0F,#1F,#1F,#1F
       DB       #7E,#1E,#8E,#CE,#C6,#E6,#E6,#E6
       DB       #70,#40,#0F,#1F,#3F,#3F,#7F,#7F
       DB       #FF,#3E,#1C,#9C,#F8,#F9,#F9,#F9
       DB       #87,#01,#78,#FC,#FC,#FE,#FE,#FE
       DB       #E7,#E4,#E0,#E1,#63,#63,#67,#67
       DB       #0F,#03,#F1,#F9,#F8,#FC,#FC,#FC
       DB       #FC,#F0,#E3,#E7,#CF,#CF,#C0,#C0
       DB       #0F,#0F,#07,#20,#38,#3F,#3F,#3F
       DB       #C6,#CE,#8E,#1E,#7E,#FE,#FE,#FE
       DB       #7F,#7F,#7F,#7F,#7F,#7F,#7F,#7F
       DB       #F9,#F9,#F9,#F8,#FC,#FC,#FE,#FF
       DB       #FE,#FE,#FE,#FC,#FC,#78,#01,#87
       DB       #67,#67,#63,#63,#E1,#E0,#E4,#E7
       DB       #FC,#FC,#FC,#F8,#F9,#F1,#03,#0F
       DB       #CF,#CF,#CF,#CF,#E7,#E3,#F0,#FC
       DB       #1F,#07,#E3,#F3,#F9,#F9,#01,#01
       DB       #FF,#FF,#F9,#F9,#F3,#E3,#07,#1F
       DB       #FF,#FF,#00,#FF,#E7,#E7,#E7,#E7
       DB       #FF,#FF,#00,#FF,#C4,#ED,#ED,#FF
       DB       #FE,#FC,#01,#FA,#99,#5A,#D9,#FA
       DB       #FF,#FF,#00,#FF,#FF,#FF,#FF,#FF
       DB       #FF,#FF,#FF,#FF,#FF,#00,#55,#AA
       DB       #7F,#BF,#C0,#DF,#DF,#DF,#DF,#DF
       DB       #DF,#DF,#DF,#DF,#DF,#DF,#DF,#DF
       DB       #DF,#DF,#DF,#DF,#DF,#C0,#95,#2A
       DB       #F9,#FA,#F9,#FA,#F9,#FA,#F9,#FA
       DB       #F9,#FA,#F9,#FA,#F9,#02,#55,#AA
       DB       #FF,#FF,#FF,#FF,#FF,#00,#55,#AA
L_DDC2       DB       #00,#00,#7F,#FF,#7F,#00,#78,#00
       DB       #70,#00,#60,#00,#60,#00,#60,#00
       DB       #40,#00,#40,#00,#40,#00,#40,#00
       DB       #40,#00,#40,#00,#40,#00,#00,#00
       DB       #00,#00,#FF,#FE,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#02,#00,#00
       DB       #00,#02,#00,#00,#00,#02,#00,#00
       DB       #00,#0A,#00,#00,#02,#AA,#00,#00
       DB       #00,#00,#5F,#FE,#58,#3E,#5B,#DE
       DB       #5B,#DE,#5B,#DE,#5B,#DE,#58,#3E
       DB       #5A,#FE,#5B,#6E,#5B,#A6,#5B,#C2
       DB       #5B,#E6,#5F,#EE,#5F,#FE,#00,#00
L_DE22       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #3F,#FE,#7F,#FC,#AA,#AA,#F7,#D4
       DB       #FB,#F2,#FF,#F4,#7F,#E2,#FF,#D4
       DB       #FF,#F2,#FF,#F4,#7F,#F2,#FF,#F4
       DB       #BF,#F2,#7B,#E4,#ED,#B0,#00,#00
       DB       #C0,#03,#80,#01,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #07,#E0,#18,#18,#27,#E4,#44,#22
       DB       #44,#22,#BF,#FD,#A1,#09,#A1,#09
       DB       #BF,#FD,#84,#21,#84,#21,#BF,#FD
       DB       #A1,#09,#A1,#09,#BF,#FD,#80,#01
       DB       #E0,#00,#E0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#80,#01,#80,#00,#00,#00
       DB       #00,#00,#00,#01,#00,#01,#04,#03
       DB       #00,#01,#00,#00,#08,#00,#F8,#00
       DB       #07,#F8,#0B,#FF,#0F,#00,#10,#EE
       DB       #03,#F8,#08,#00,#37,#FC,#2F,#FE
       DB       #5E,#00,#19,#F4,#61,#E8,#51,#E8
       DB       #30,#00,#E3,#F4,#03,#FA,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #3F,#FE,#7F,#FC,#AA,#AA,#F7,#D4
       DB       #EB,#F2,#FF,#F4,#3F,#F2,#9F,#34
       DB       #C8,#72,#E1,#B4,#79,#D2,#F4,#F4
       DB       #A6,#72,#6B,#24,#C5,#10,#00,#00
       DB       #C0,#0F,#00,#0F,#00,#03,#00,#03
       DB       #00,#03,#00,#07,#80,#01,#00,#01
       DB       #00,#00,#00,#00,#80,#00,#80,#00
       DB       #C0,#00,#80,#00,#00,#00,#00,#10
       DB       #07,#E0,#1F,#C0,#FF,#C0,#00,#F8
       DB       #77,#00,#1F,#C0,#00,#10,#3F,#EC
       DB       #7F,#74,#00,#76,#2F,#06,#17,#76
       DB       #17,#6E,#00,#0E,#2F,#C7,#5F,#C0
       DB       #00,#07,#00,#07,#00,#03,#00,#03
       DB       #00,#03,#80,#01,#00,#01,#00,#00
       DB       #00,#00,#80,#00,#80,#00,#C0,#20
       DB       #80,#00,#00,#00,#00,#10,#00,#1F
       DB       #1F,#E0,#FF,#D0,#00,#F0,#77,#08
       DB       #1F,#C0,#00,#10,#3F,#EC,#7F,#F4
       DB       #00,#7A,#2F,#98,#17,#86,#17,#8A
       DB       #00,#0C,#2F,#C7,#5F,#C0,#00,#00
       DB       #FE,#3F,#FE,#0F,#FE,#0F,#F8,#0F
       DB       #F8,#07,#E0,#07,#E0,#07,#E0,#01
       DB       #E0,#01,#C0,#01,#C0,#01,#C0,#01
       DB       #C0,#01,#C0,#01,#E0,#03,#F8,#03
       DB       #00,#80,#00,#80,#00,#A0,#00,#20
       DB       #02,#20,#02,#90,#0A,#90,#0A,#E0
       DB       #09,#C4,#0D,#D4,#15,#D4,#0F,#F0
       DB       #13,#F4,#0B,#E0,#01,#C8,#02,#40
       DB       #FF,#FF,#FE,#3F,#F8,#3F,#F8,#0F
       DB       #F0,#0F,#F0,#03,#F0,#03,#C0,#03
       DB       #C0,#01,#C0,#01,#C0,#01,#C0,#01
       DB       #E0,#01,#E0,#03,#E0,#03,#E0,#0F
       DB       #00,#00,#00,#00,#00,#80,#02,#80
       DB       #00,#A0,#04,#A0,#04,#A8,#01,#A8
       DB       #13,#48,#13,#D4,#17,#F0,#07,#E4
       DB       #0F,#F0,#03,#E8,#0B,#C0,#01,#20
       DB       #FC,#7F,#FC,#7F,#F8,#3F,#F8,#3F
       DB       #F0,#1F,#F0,#1F,#C0,#07,#00,#01
       DB       #00,#01,#00,#01,#C0,#07,#F0,#1F
       DB       #F0,#1F,#F8,#3F,#F8,#3F,#FC,#7F
       DB       #00,#00,#01,#00,#01,#00,#03,#80
       DB       #03,#80,#07,#C0,#07,#C0,#1F,#F0
       DB       #7F,#FC,#1F,#F0,#07,#C0,#07,#C0
       DB       #03,#80,#03,#80,#01,#00,#01,#00
       DB       #FF,#FF,#FF,#FF,#8F,#E3,#83,#83
       DB       #80,#03,#C0,#07,#C0,#07,#E0,#0F
       DB       #E0,#0F,#E0,#0F,#C0,#07,#C0,#07
       DB       #80,#03,#83,#83,#8F,#E3,#FF,#FF
       DB       #00,#00,#00,#00,#00,#00,#20,#08
       DB       #18,#30,#1E,#F0,#0F,#E0,#0F,#E0
       DB       #07,#C0,#0F,#E0,#0F,#E0,#1E,#F0
       DB       #18,#30,#20,#08,#00,#00,#00,#00
       DB       #F8,#00,#F8,#00,#F8,#00,#30,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#80,#00,#E0,#7F
       DB       #01,#FC,#03,#FE,#01,#F0,#02,#F5
       DB       #87,#75,#D7,#B0,#F7,#DF,#77,#E0
       DB       #FB,#F6,#FC,#FB,#7F,#3B,#7F,#BB
       DB       #7F,#BB,#3F,#76,#0F,#00,#0C,#00
       DB       #00,#1F,#00,#1F,#00,#1F,#00,#0C
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#01,#FE,#07
       DB       #3F,#80,#7F,#C0,#0F,#80,#AF,#40
       DB       #AE,#E1,#0D,#EB,#FB,#EF,#07,#EE
       DB       #6F,#DF,#DF,#3F,#DC,#FE,#DD,#FE
       DB       #DD,#FE,#6E,#FC,#00,#F0,#00,#30
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#01,#80,#01,#C0,#03,#E0,#07
       DB       #87,#E1,#5F,#FA,#2F,#F4,#57,#EA
       DB       #6B,#D2,#DB,#DB,#CB,#D3,#D3,#CB
       DB       #D9,#9B,#6D,#B6,#75,#AE,#38,#0C
       DB       #3B,#DC,#1A,#58,#0C,#30,#07,#E0
       DB       #C0,#00,#80,#00,#00,#01,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#00
       DB       #C0,#01,#E0,#01,#E0,#03,#F0,#03
       DB       #13,#F2,#0B,#E4,#35,#C8,#7A,#D4
       DB       #7A,#D6,#F8,#C6,#F3,#F3,#F5,#CB
       DB       #F6,#DB,#7B,#36,#3C,#CE,#1C,#0C
       DB       #0D,#EC,#0D,#28,#04,#18,#07,#F0
       DB       #80,#07,#00,#07,#00,#07,#00,#07
       DB       #00,#03,#00,#03,#00,#03,#00,#01
       DB       #00,#01,#80,#01,#80,#01,#C0,#01
       DB       #E0,#01,#F0,#01,#F8,#03,#FC,#03
       DB       #0F,#30,#3F,#40,#7F,#A0,#FF,#F0
       DB       #FF,#F0,#FF,#98,#7F,#A8,#7F,#D0
       DB       #3F,#E4,#3F,#FC,#1F,#FC,#0F,#C4
       DB       #07,#D4,#03,#D0,#01,#D8,#01,#F8
       DB       #C0,#00,#80,#00,#00,#01,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#00
       DB       #C0,#01,#E0,#01,#E0,#03,#F0,#03
       DB       #13,#D2,#0F,#F4,#3F,#E8,#7F,#F4
       DB       #7F,#FA,#FF,#FE,#FF,#FD,#FF,#FB
       DB       #FF,#FD,#7F,#FE,#3F,#FA,#1B,#EC
       DB       #0E,#B4,#0F,#F8,#07,#A8,#07,#50
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#01,#80,#01,#C0,#03,#E0,#07
       DB       #87,#E1,#5F,#DA,#3F,#F4,#7F,#FA
       DB       #7F,#FE,#FF,#FB,#FF,#FD,#FF,#FF
       DB       #FF,#FD,#7F,#FE,#7F,#FA,#2F,#EC
       DB       #3A,#B4,#1F,#E8,#0F,#50,#06,#A0
       DB       #00,#03,#00,#01,#80,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#01
       DB       #80,#03,#80,#07,#C0,#07,#C0,#0F
       DB       #4F,#C8,#2F,#B0,#1F,#EC,#3F,#F6
       DB       #7F,#FA,#7F,#FB,#FF,#FD,#FF,#FB
       DB       #FF,#FD,#7F,#FA,#7F,#F4,#37,#C8
       DB       #3D,#70,#1F,#D0,#1F,#60,#0E,#A0
       DB       #E0,#01,#E0,#00,#E0,#00,#E0,#00
       DB       #C0,#00,#C0,#00,#C0,#00,#80,#00
       DB       #80,#00,#80,#01,#80,#01,#80,#03
       DB       #80,#07,#80,#0F,#C0,#1F,#C0,#3F
       DB       #0C,#F0,#02,#EC,#05,#FA,#0F,#FD
       DB       #0F,#FB,#19,#FD,#15,#FA,#0B,#FA
       DB       #27,#FC,#3F,#F4,#3F,#E8,#23,#D0
       DB       #2B,#A0,#0B,#40,#1B,#80,#1E,#80
       DB       #00,#03,#00,#01,#80,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#01
       DB       #80,#03,#80,#07,#C0,#07,#C0,#0F
       DB       #4F,#C8,#27,#D0,#13,#AC,#2B,#5A
       DB       #6B,#5C,#63,#1F,#CF,#CD,#D3,#AF
       DB       #DB,#6D,#6C,#DA,#73,#34,#30,#38
       DB       #37,#B0,#14,#B0,#18,#20,#0F,#E0
       DB       #FC,#1F,#F8,#0F,#F0,#07,#80,#03
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#03,#00,#03,#00,#03,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#80,#03
       DB       #00,#C0,#01,#00,#03,#E0,#04,#30
       DB       #26,#D8,#63,#0F,#67,#FF,#CF,#80
       DB       #CF,#F0,#CC,#78,#E3,#88,#77,#C0
       DB       #77,#CC,#7B,#DC,#3D,#F8,#1C,#70
       DB       #FC,#1F,#F8,#0F,#F0,#07,#80,#03
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#03,#00,#03,#00,#03,#00,#03
       DB       #00,#1F,#00,#03,#00,#01,#80,#01
       DB       #00,#C0,#01,#00,#03,#E0,#04,#30
       DB       #26,#D8,#63,#0F,#67,#FF,#CF,#80
       DB       #CF,#F0,#CC,#78,#E3,#88,#77,#C0
       DB       #77,#C0,#7B,#80,#3D,#F8,#1C,#FC
       DB       #FC,#1F,#F8,#0F,#F0,#07,#C0,#03
       DB       #80,#00,#80,#00,#00,#00,#00,#00
       DB       #00,#03,#00,#03,#00,#03,#00,#03
       DB       #00,#1F,#80,#07,#80,#03,#80,#03
       DB       #00,#C0,#01,#00,#03,#E0,#04,#30
       DB       #16,#D8,#33,#0F,#37,#FF,#6F,#80
       DB       #6F,#F0,#6C,#78,#63,#88,#77,#C0
       DB       #37,#C0,#3B,#80,#3D,#F0,#1D,#F8
       DB       #F8,#3F,#F0,#1F,#E0,#0F,#C0,#01
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #C0,#00,#C0,#00,#C0,#00,#80,#00
       DB       #80,#00,#80,#00,#80,#00,#C0,#01
       DB       #03,#00,#00,#80,#07,#C0,#0C,#20
       DB       #1B,#64,#F0,#C6,#FF,#E6,#01,#F3
       DB       #0F,#F3,#1E,#33,#11,#C7,#03,#EE
       DB       #33,#EE,#3B,#DE,#1F,#BC,#0E,#38
       DB       #F8,#3F,#F0,#1F,#E0,#0F,#C0,#01
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #C0,#00,#C0,#00,#C0,#00,#C0,#00
       DB       #F8,#00,#C0,#00,#80,#00,#80,#01
       DB       #03,#00,#00,#80,#07,#C0,#0C,#20
       DB       #1B,#64,#F0,#C6,#FF,#E6,#01,#F3
       DB       #0F,#F3,#1E,#33,#11,#C7,#03,#EE
       DB       #03,#EE,#01,#DE,#1F,#BC,#3F,#38
       DB       #F8,#3F,#F0,#1F,#E0,#0F,#C0,#03
       DB       #00,#01,#00,#01,#00,#00,#00,#00
       DB       #C0,#00,#C0,#00,#C0,#00,#C0,#00
       DB       #F8,#00,#E0,#01,#C0,#01,#C0,#01
       DB       #03,#00,#00,#80,#07,#C0,#0C,#20
       DB       #1B,#68,#F0,#CC,#FF,#EC,#01,#F6
       DB       #0F,#F6,#1E,#36,#11,#C6,#03,#EE
       DB       #03,#EC,#01,#DC,#0F,#BC,#1F,#B8
       DB       #FE,#3F,#F0,#07,#F0,#07,#E0,#07
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#07,#E0,#07,#E0,#0F,#E0,#0F
       DB       #FC,#7F,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #00,#00,#00,#80,#04,#10,#00,#80
       DB       #0A,#50,#54,#0D,#B2,#9A,#28,#00
       DB       #05,#50,#00,#80,#08,#20,#01,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #FC,#0F,#E0,#0F,#C0,#07,#80,#07
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #E0,#07,#F0,#07,#F0,#07,#FE,#3F
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #00,#00,#01,#20,#08,#80,#15,#50
       DB       #28,#80,#82,#AA,#55,#05,#0A,#50
       DB       #00,#80,#04,#50,#00,#80,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #03,#C0,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#C0,#03,#C0,#03,#C0,#03
       DB       #30,#0C,#40,#02,#FF,#FF,#E0,#07
       DB       #C7,#03,#CE,#0B,#DC,#1B,#D8,#3B
       DB       #D0,#73,#C0,#E3,#D1,#CB,#71,#8E
       DB       #15,#28,#14,#28,#14,#28,#1F,#F8
       DB       #C0,#03,#80,#01,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #07,#E0,#18,#18,#23,#C4,#5B,#DA
       DB       #58,#1A,#BF,#FD,#8F,#8D,#EF,#05
       DB       #8F,#05,#BF,#05,#BF,#8D,#BF,#8D
       DB       #8F,#8D,#EF,#8D,#8F,#FD,#BF,#FD
       DB       #F0,#1F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #C0,#0F,#80,#0F,#80,#07,#80,#07
       DB       #80,#07,#80,#07,#80,#07,#80,#07
       DB       #80,#07,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #03,#80,#07,#40,#07,#20,#07,#E0
       DB       #03,#C0,#1C,#00,#38,#E0,#33,#70
       DB       #37,#70,#37,#70,#37,#B0,#37,#70
       DB       #00,#00,#07,#80,#07,#E0,#07,#E0
       DB       #F0,#1F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #C0,#0F,#80,#0F,#80,#07,#80,#07
       DB       #80,#07,#80,#07,#80,#07,#80,#07
       DB       #80,#07,#C0,#07,#C0,#07,#C0,#07
       DB       #03,#80,#07,#40,#07,#20,#07,#E0
       DB       #03,#C0,#1C,#00,#3E,#60,#3D,#B0
       DB       #3B,#B0,#3B,#90,#3B,#D0,#3B,#90
       DB       #00,#00,#1E,#40,#1F,#B0,#1F,#B0
       DB       #F0,#1F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #C0,#0F,#80,#0F,#80,#07,#80,#07
       DB       #80,#07,#80,#07,#80,#07,#80,#07
       DB       #80,#07,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #03,#80,#07,#40,#07,#20,#07,#E0
       DB       #03,#C0,#1C,#00,#38,#E0,#33,#70
       DB       #37,#70,#37,#70,#37,#B0,#37,#70
       DB       #00,#00,#07,#80,#07,#E0,#07,#E0
       DB       #F0,#1F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #C0,#0F,#80,#0F,#80,#07,#80,#07
       DB       #80,#07,#80,#07,#80,#07,#80,#07
       DB       #80,#07,#C0,#07,#C0,#07,#C0,#07
       DB       #03,#80,#07,#40,#07,#20,#07,#E0
       DB       #03,#C0,#1C,#00,#38,#E0,#37,#70
       DB       #2F,#70,#2E,#F0,#2F,#70,#2E,#F0
       DB       #00,#00,#1B,#C0,#1B,#F0,#1B,#F0
       DB       #F0,#1F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #C0,#0F,#80,#07,#80,#00,#80,#00
       DB       #80,#00,#80,#00,#80,#00,#80,#07
       DB       #80,#07,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #03,#80,#07,#40,#07,#20,#07,#E0
       DB       #03,#C0,#1C,#00,#3F,#90,#3F,#67
       DB       #3E,#FF,#3E,#FF,#3F,#00,#3F,#F0
       DB       #00,#00,#07,#80,#07,#E0,#07,#E0
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#C0,#03,#C0,#03,#C0,#00
       DB       #C0,#00,#C0,#00,#C0,#00,#C0,#7F
       DB       #33,#CC,#64,#26,#45,#A2,#A6,#65
       DB       #E2,#47,#CD,#B3,#DE,#7B,#5F,#FA
       DB       #1F,#F8,#1F,#F8,#1F,#C0,#1F,#B8
       DB       #00,#3E,#07,#3E,#1F,#00,#1F,#00
       DB       #F8,#0F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #F0,#03,#F0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#E0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #01,#C0,#02,#E0,#04,#E0,#07,#E0
       DB       #03,#C0,#00,#38,#07,#1C,#0E,#CC
       DB       #0E,#EC,#0E,#EC,#0D,#EC,#0E,#EC
       DB       #00,#00,#01,#E0,#07,#E0,#07,#E0
       DB       #F8,#0F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #F0,#03,#F0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#E0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#E0,#03,#E0,#03,#E0,#03
       DB       #01,#C0,#02,#E0,#04,#E0,#07,#E0
       DB       #03,#C0,#00,#38,#06,#7C,#0D,#BC
       DB       #0D,#DC,#09,#DC,#0B,#DC,#09,#DC
       DB       #00,#00,#02,#78,#0D,#F8,#0D,#F8
       DB       #F8,#0F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #F0,#03,#F0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#E0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #01,#C0,#02,#E0,#04,#E0,#07,#E0
       DB       #03,#C0,#00,#38,#07,#1C,#0E,#CC
       DB       #0E,#EC,#0E,#EC,#0D,#EC,#0E,#EC
       DB       #00,#00,#01,#E0,#07,#E0,#07,#E0
       DB       #F8,#0F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #F0,#03,#F0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#E0,#01,#E0,#01,#E0,#01
       DB       #E0,#01,#E0,#03,#E0,#03,#E0,#03
       DB       #01,#C0,#02,#E0,#04,#E0,#07,#E0
       DB       #03,#C0,#00,#38,#07,#1C,#0E,#EC
       DB       #0E,#F4,#0F,#74,#0E,#F4,#0F,#74
       DB       #00,#00,#03,#D8,#0F,#D8,#0F,#D8
       DB       #F8,#0F,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #F0,#03,#E0,#01,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#E0,#01
       DB       #E0,#01,#F0,#0F,#F0,#0F,#F0,#0F
       DB       #01,#C0,#02,#E0,#04,#E0,#07,#E0
       DB       #03,#C0,#00,#38,#09,#FC,#E6,#FC
       DB       #FF,#7C,#FF,#7C,#00,#FC,#0F,#FC
       DB       #00,#00,#01,#E0,#07,#E0,#07,#E0
       DB       #0F,#E0,#0F,#E0,#0F,#C0,#01,#80
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#01,#00,#03,#00,#03,#00,#03
       DB       #00,#03,#00,#01,#01,#80,#01,#80
       DB       #00,#07,#60,#08,#80,#08,#80,#1E
       DB       #9C,#39,#7E,#7D,#FF,#FF,#FF,#FC
       DB       #FB,#F8,#FD,#F8,#FD,#F8,#7D,#D8
       DB       #7B,#B8,#70,#38,#38,#1C,#7C,#3E
       DB       #FF,#E0,#87,#E0,#0F,#C0,#01,#80
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#01,#00,#03,#00,#03,#00,#03
       DB       #00,#07,#80,#07,#80,#03,#80,#03
       DB       #00,#0E,#00,#08,#60,#08,#80,#1E
       DB       #9C,#39,#7E,#7D,#FF,#FF,#FF,#FC
       DB       #FB,#F8,#FD,#F8,#7D,#F8,#7D,#B0
       DB       #3B,#70,#38,#60,#1C,#30,#3E,#F8
       DB       #07,#F0,#07,#F0,#03,#F0,#01,#80
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#00,#C0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#80,#00,#01,#80,#01,#80
       DB       #E0,#00,#10,#06,#88,#01,#78,#01
       DB       #9C,#39,#BE,#7E,#FF,#FF,#3F,#FF
       DB       #1F,#DF,#1F,#BF,#1F,#BF,#1B,#BE
       DB       #1D,#DE,#1C,#0E,#38,#1C,#7C,#3E
       DB       #07,#FF,#07,#F0,#03,#F0,#01,#80
       DB       #00,#00,#00,#00,#80,#00,#00,#00
       DB       #80,#00,#C0,#00,#E0,#00,#C0,#00
       DB       #E0,#00,#E0,#01,#C0,#01,#C0,#01
       DB       #70,#00,#10,#00,#10,#06,#78,#01
       DB       #9C,#39,#BE,#7E,#FF,#FF,#3F,#FF
       DB       #1F,#DF,#1F,#BF,#1F,#BE,#0D,#BE
       DB       #0E,#DC,#06,#1C,#0C,#38,#1F,#7C
       DB       #C4,#7F,#C4,#71,#80,#61,#80,#01
       DB       #80,#03,#C0,#07,#C0,#00,#00,#00
       DB       #00,#00,#00,#07,#C0,#03,#C0,#03
       DB       #84,#41,#84,#21,#8C,#31,#FE,#3F
       DB       #00,#00,#11,#00,#11,#04,#22,#08
       DB       #12,#70,#09,#80,#03,#C0,#1B,#CE
       DB       #63,#B0,#05,#80,#08,#60,#11,#18
       DB       #11,#08,#21,#04,#00,#80,#00,#00
       DB       #F8,#61,#88,#41,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#00,#00,#00
       DB       #80,#00,#C0,#01,#80,#01,#80,#01
       DB       #80,#01,#80,#07,#E1,#0F,#E3,#8F
       DB       #00,#00,#03,#0C,#21,#10,#50,#20
       DB       #09,#8C,#03,#D0,#47,#E0,#37,#E2
       DB       #07,#EC,#0B,#C0,#13,#80,#20,#2C
       DB       #24,#90,#04,#40,#08,#20,#00,#00
       DB       #F8,#7F,#C0,#7F,#80,#1F,#80,#1F
       DB       #80,#1F,#C0,#1F,#E0,#3F,#F0,#1F
       DB       #F8,#00,#FC,#00,#FE,#00,#FF,#00
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00
       DB       #00,#00,#03,#00,#17,#00,#3A,#C0
       DB       #1D,#C0,#0E,#80,#07,#00,#03,#80
       DB       #01,#C0,#00,#FE,#00,#42,#00,#5A
       DB       #00,#5A,#00,#42,#00,#7E,#00,#00
L_EA22       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#01,#00,#00,#08,#00
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #2E,#FE,#6E,#00,#60,#BC,#6E,#B8
       DB       #76,#B8,#70,#00,#E2,#FC,#02,#FE
       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#08,#03
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #36,#FE,#77,#00,#70,#F4,#77,#60
       DB       #73,#68,#70,#04,#E3,#F0,#03,#F8
       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#01,#00,#01,#00,#01
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #36,#FE,#77,#00,#70,#6C,#73,#98
       DB       #75,#40,#70,#18,#EF,#DC,#0F,#E0
       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#01,#00,#00,#00,#00
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #36,#FE,#77,#00,#70,#EC,#77,#58
       DB       #73,#18,#70,#80,#EF,#DC,#00,#3E
       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#07,#00,#07,#08,#07
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #2E,#FE,#6E,#00,#60,#F4,#6E,#E8
       DB       #76,#10,#71,#E0,#E3,#F0,#00,#00
       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#01,#00,#01,#08,#01
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #2E,#FE,#6E,#00,#60,#BC,#6E,#B8
       DB       #76,#00,#70,#F8,#E2,#FC,#03,#00
       DB       #F0,#03,#F0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#E0,#00,#80,#01,#80,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#01,#00,#00,#08,#00
       DB       #07,#E0,#03,#F8,#03,#FF,#1F,#00
       DB       #00,#EE,#03,#F8,#08,#00,#37,#FC
       DB       #2E,#FE,#6E,#00,#60,#F4,#6E,#E8
       DB       #76,#E8,#70,#00,#E3,#F4,#03,#FA
       DB       #E0,#00,#E0,#00,#C0,#00,#C0,#00
       DB       #C0,#00,#80,#01,#80,#00,#00,#00
       DB       #00,#00,#00,#01,#00,#01,#04,#03
       DB       #00,#01,#00,#00,#08,#00,#F8,#00
       DB       #07,#F8,#0B,#FF,#0F,#00,#10,#EE
       DB       #03,#F8,#08,#00,#37,#FC,#2F,#FE
       DB       #5E,#00,#19,#F4,#61,#E8,#51,#E8
       DB       #30,#00,#E3,#F4,#03,#FA,#00,#00
       DB       #F0,#00,#F0,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#00
       DB       #80,#00,#00,#00,#00,#01,#00,#01
       DB       #00,#03,#00,#00,#00,#00,#10,#00
       DB       #07,#E3,#03,#F8,#03,#FF,#DF,#00
       DB       #E0,#ED,#53,#FB,#3C,#02,#1F,#FC
       DB       #2F,#FE,#30,#00,#7B,#F4,#79,#E8
       DB       #75,#D8,#76,#00,#C7,#EE,#03,#F7
       DB       #FF,#FF,#FF,#FF,#F0,#0F,#F0,#03
       DB       #F0,#00,#C0,#00,#C0,#00,#C0,#00
       DB       #E0,#00,#80,#01,#80,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#07,#E0
       DB       #03,#F8,#03,#FF,#1F,#00,#00,#EE
       DB       #03,#F8,#08,#00,#37,#FC,#2E,#FE
       DB       #6E,#FE,#60,#00,#6E,#F4,#F6,#FA
       DB       #00,#38,#00,#08,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #C0,#01,#C0,#00,#C0,#00,#C1,#80
       DB       #AC,#01,#A6,#83,#29,#A3,#6D,#9A
       DB       #65,#A9,#ED,#B3,#ED,#BB,#ED,#BB
       DB       #F5,#BB,#F5,#A7,#93,#8E,#13,#B0
       DB       #17,#7C,#0A,#FC,#1C,#3E,#18,#02
       DB       #F0,#00,#F0,#00,#E0,#00,#E0,#00
       DB       #E0,#00,#80,#00,#80,#00,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#80,#03
       DB       #03,#F7,#07,#8A,#07,#B4,#0A,#D7
       DB       #06,#67,#0B,#3F,#25,#C0,#31,#7C
       DB       #BA,#88,#DE,#D4,#7E,#E8,#3E,#D4
       DB       #DD,#E8,#63,#D4,#3F,#A8,#1F,#50
       DB       #F0,#00,#F0,#00,#80,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#80,#03
       DB       #03,#F7,#07,#8A,#07,#B4,#36,#D7
       DB       #7A,#67,#FD,#3F,#FE,#C0,#DF,#7C
       DB       #BA,#88,#B5,#D4,#27,#E8,#0F,#D4
       DB       #CF,#E8,#7F,#D4,#3F,#A8,#1F,#50
       DB       #00,#0F,#00,#0F,#00,#07,#00,#07
       DB       #00,#07,#00,#01,#00,#01,#80,#00
       DB       #80,#00,#80,#00,#80,#00,#80,#00
       DB       #80,#00,#80,#00,#80,#00,#C0,#01
       DB       #EF,#C0,#51,#E0,#2D,#E0,#EB,#50
       DB       #E6,#60,#FC,#D0,#03,#A4,#3E,#8C
       DB       #11,#5D,#2B,#7B,#17,#7E,#2B,#7C
       DB       #17,#BB,#2B,#C6,#15,#FC,#0A,#F8
       DB       #00,#0F,#00,#0F,#00,#01,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#00
       DB       #80,#00,#80,#00,#80,#00,#80,#00
       DB       #80,#00,#80,#00,#80,#00,#C0,#01
       DB       #EF,#C0,#51,#E0,#2D,#E0,#EB,#6C
       DB       #E6,#5E,#FC,#BF,#03,#7F,#3E,#FB
       DB       #11,#5D,#2B,#AD,#17,#E4,#2B,#F0
       DB       #17,#F3,#2B,#FE,#15,#FC,#0A,#F8
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #C0,#03,#80,#01,#80,#01,#80,#01
       DB       #80,#01,#80,#01,#80,#01,#C0,#03
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#1F,#F8,#35,#7C,#2A,#F4
       DB       #17,#C4,#2E,#04,#1F,#F8,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #FC,#3F,#F8,#1F,#F0,#0F,#E0,#07
       DB       #C0,#03,#80,#01,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#80,#01,#C0,#03
       DB       #E0,#07,#F0,#0F,#F8,#1F,#FC,#3F
       DB       #00,#00,#01,#80,#03,#40,#07,#A0
       DB       #0F,#50,#1F,#A8,#3F,#54,#7F,#A2
       DB       #55,#02,#2A,#04,#15,#08,#0A,#10
       DB       #04,#20,#02,#40,#01,#80,#00,#00
       DB       #F8,#1F,#F0,#0F,#E0,#07,#E0,#07
       DB       #E0,#07,#E0,#07,#E0,#07,#E0,#07
       DB       #E0,#07,#E0,#07,#E0,#07,#E0,#07
       DB       #E0,#07,#E0,#07,#F0,#0F,#F8,#1F
       DB       #00,#00,#03,#C0,#07,#E0,#0E,#70
       DB       #0D,#B0,#0D,#30,#0C,#30,#0C,#20
       DB       #0D,#10,#0D,#20,#0D,#10,#0C,#20
       DB       #0E,#50,#06,#A0,#03,#40,#00,#00
       DB       #F0,#1F,#C0,#07,#80,#03,#80,#03
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #80,#03,#80,#03,#C0,#07,#F0,#1F
       DB       #00,#00,#07,#C0,#1F,#F0,#3F,#D8
       DB       #3F,#A8,#7F,#D4,#7F,#D4,#7E,#FC
       DB       #7E,#FC,#57,#FC,#57,#FC,#2B,#F8
       DB       #37,#F8,#1F,#F0,#07,#C0,#00,#00
       DB       #F0,#07,#C0,#01,#80,#00,#80,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#00,#80,#01,#C0,#01,#F0,#07
       DB       #00,#00,#07,#D0,#1F,#F4,#3F,#DA
       DB       #3F,#A8,#7F,#D5,#7F,#D4,#7E,#FD
       DB       #7E,#FC,#57,#FD,#57,#FC,#2B,#FA
       DB       #37,#F8,#1F,#F4,#07,#D0,#00,#00
       DB       #F0,#0F,#E0,#07,#C0,#03,#C0,#03
       DB       #C0,#03,#C0,#03,#C0,#03,#C0,#03
       DB       #C0,#03,#C0,#03,#C0,#03,#C0,#03
       DB       #C0,#03,#C0,#03,#E0,#07,#F0,#0F
       DB       #00,#00,#07,#E0,#0F,#F0,#1E,#68
       DB       #1D,#B0,#1A,#08,#1A,#10,#18,#08
       DB       #1A,#10,#1A,#08,#1A,#10,#1C,#28
       DB       #1E,#48,#0F,#90,#06,#A0,#00,#00
       DB       #F0,#1F,#C0,#07,#80,#03,#80,#03
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #80,#03,#80,#03,#C0,#07,#F0,#1F
       DB       #00,#00,#07,#C0,#1F,#F0,#3F,#F8
       DB       #3F,#F8,#7E,#FC,#7A,#BC,#7C,#7C
       DB       #7C,#7C,#7A,#BC,#7E,#FC,#3F,#F8
       DB       #3F,#F8,#1F,#F0,#07,#C0,#00,#00
       DB       #F0,#07,#C0,#01,#80,#00,#80,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#00,#80,#01,#C0,#01,#F0,#07
       DB       #00,#00,#07,#D0,#1F,#F4,#3F,#FA
       DB       #3F,#F8,#7E,#FD,#7A,#BC,#7C,#7D
       DB       #7C,#7C,#7A,#BD,#7E,#FC,#3F,#FA
       DB       #3F,#F8,#1F,#F4,#07,#D0,#00,#00
       DB       #FF,#FF,#FF,#FF,#F8,#1F,#F0,#0F
       DB       #E0,#07,#E0,#07,#C0,#03,#C0,#03
       DB       #80,#01,#80,#01,#80,#01,#80,#01
       DB       #80,#01,#E0,#07,#FF,#FF,#FF,#FF
;L_EFFE       EQU       $-4
       DB       #00,#00,#00,#00,#00,#00,#03,#C0
       DB       #04,#E0,#09,#F0,#0B,#F0,#1F,#F8
       DB       #0E,#70,#35,#AC,#39,#9C,#39,#9C
       DB       #0F,#F0,#00,#00,#00,#00,#00,#00
       DB       #E0,#07,#E0,#07,#F0,#0F,#F0,#0F
       DB       #E0,#07,#C0,#03,#C0,#03,#80,#01
       DB       #80,#01,#80,#01,#80,#01,#80,#01
       DB       #80,#01,#C0,#03,#C0,#03,#E0,#07
       DB       #0B,#F0,#05,#E0,#05,#E0,#05,#E0
       DB       #05,#E0,#0B,#F0,#1B,#F8,#17,#78
       DB       #3E,#BC,#3D,#7C,#3A,#BC,#3C,#5C
       DB       #1A,#28,#1C,#18,#0E,#30,#03,#C0
       DB       #80,#03,#80,#03,#C0,#07,#C0,#07
       DB       #C0,#07,#E0,#0F,#E0,#0F,#F0,#1F
       DB       #E0,#0F,#E0,#0F,#C0,#07,#C0,#07
       DB       #C0,#07,#80,#03,#80,#03,#80,#03
       DB       #3F,#F8,#16,#10,#16,#10,#16,#10
       DB       #0B,#20,#0B,#20,#04,#40,#03,#80
       DB       #04,#40,#08,#20,#08,#20,#11,#10
       DB       #13,#90,#17,#D0,#3F,#F8,#00,#00
       DB       #80,#03,#80,#03,#C0,#07,#C0,#07
       DB       #C0,#07,#E0,#0F,#E0,#0F,#F0,#1F
       DB       #E0,#0F,#E0,#0F,#C0,#07,#C0,#07
       DB       #C0,#07,#80,#03,#80,#03,#80,#03
       DB       #3F,#F8,#14,#10,#14,#10,#1B,#F0
       DB       #0D,#E0,#0D,#E0,#07,#C0,#03,#80
       DB       #04,#40,#09,#20,#0B,#A0,#17,#D0
       DB       #17,#D0,#1F,#F0,#3F,#F8,#00,#00
       DB       #00,#07,#00,#07,#00,#07,#80,#00
       DB       #C0,#00,#80,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#03,#00,#03,#00,#03
       DB       #00,#03,#00,#03,#00,#07,#00,#0F
       DB       #7F,#E0,#77,#D0,#2F,#A0,#1F,#C0
       DB       #04,#46,#11,#19,#3F,#ED,#79,#D2
       DB       #76,#E8,#FE,#D0,#FD,#E8,#FB,#D0
       DB       #FB,#A8,#7F,#D0,#7B,#A0,#1F,#40
       DB       #FF,#F0,#FF,#E0,#FC,#00,#E0,#00
       DB       #00,#01,#00,#03,#00,#03,#00,#03
       DB       #00,#03,#00,#03,#00,#07,#80,#07
       DB       #80,#07,#80,#0F,#80,#0F,#C0,#0F
       DB       #00,#03,#00,#07,#00,#0E,#01,#DC
       DB       #0E,#28,#BC,#70,#B9,#F8,#DF,#F0
       DB       #5F,#E8,#6F,#D0,#37,#E0,#19,#50
       DB       #2E,#A0,#37,#40,#1B,#A0,#00,#C0
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #01,#00,#00,#00,#21,#04,#01,#00
       DB       #05,#60,#0E,#70,#09,#90,#03,#DD
       DB       #BB,#C0,#05,#90,#0E,#30,#06,#A0
       DB       #00,#80,#20,#84,#00,#00,#00,#80
       DB       #80,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#00
       DB       #C0,#01,#F0,#07,#F0,#07,#F0,#07
       DB       #19,#CC,#32,#26,#75,#D7,#34,#96
       DB       #15,#D4,#45,#51,#50,#85,#1E,#3C
       DB       #25,#D2,#7B,#EF,#3B,#6E,#11,#C4
       DB       #03,#E0,#03,#E0,#07,#F0,#03,#E0
       DB       #C0,#01,#80,#00,#80,#00,#80,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#00,#80,#00,#80,#00,#C0,#01
       DB       #F8,#0F,#F0,#07,#F0,#07,#F0,#07
       DB       #09,#C8,#12,#24,#35,#D6,#14,#94
       DB       #05,#D0,#45,#51,#50,#85,#1E,#3C
       DB       #25,#D2,#3B,#EE,#1B,#6C,#01,#C0
       DB       #03,#E0,#03,#E0,#07,#F0,#03,#E0
       DB       #F8,#0F,#F0,#07,#F0,#07,#F0,#07
       DB       #10,#04,#00,#00,#00,#00,#00,#00
       DB       #C0,#01,#F0,#07,#F8,#0F,#F8,#0F
       DB       #F8,#0F,#F0,#07,#F0,#07,#F0,#07
       DB       #01,#C0,#02,#20,#05,#D0,#04,#90
       DB       #05,#D0,#45,#51,#50,#85,#1E,#3C
       DB       #05,#D0,#03,#E0,#03,#60,#01,#C0
       DB       #03,#E0,#03,#E0,#07,#F0,#03,#E0
       DB       #C0,#01,#80,#00,#80,#00,#80,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #80,#00,#80,#00,#80,#00,#C0,#01
       DB       #F8,#0F,#F0,#07,#F0,#07,#F0,#07
       DB       #09,#C8,#12,#24,#35,#D6,#14,#94
       DB       #05,#D0,#45,#51,#50,#85,#1E,#3C
       DB       #25,#D2,#3B,#EE,#1B,#6C,#01,#C0
       DB       #03,#E0,#03,#E0,#07,#F0,#03,#E0
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#80,#FF
       DB       #00,#1F,#00,#0F,#00,#01,#00,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#0F
       DB       #00,#1F,#81,#FF,#FF,#FF,#FF,#FF
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #3A,#00,#55,#40,#BE,#A0,#6D,#54
       DB       #FE,#A9,#DB,#54,#EE,#A0,#79,#40
       DB       #34,#00,#00,#00,#00,#00,#00,#00
       DB       #FE,#3F,#FC,#1F,#FC,#1F,#FC,#1F
       DB       #F8,#0F,#F0,#07,#F0,#07,#F0,#07
       DB       #E0,#07,#E0,#03,#E0,#03,#E0,#03
       DB       #E0,#03,#E0,#03,#E0,#03,#F0,#07
       DB       #00,#80,#00,#00,#01,#40,#00,#80
       DB       #01,#40,#02,#A0,#05,#50,#02,#A0
       DB       #05,#50,#0A,#E0,#07,#A8,#0B,#F0
       DB       #0E,#D8,#0B,#B8,#05,#F0,#02,#E0
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#01
       DB       #F8,#00,#F0,#00,#80,#00,#00,#00
       DB       #00,#00,#00,#00,#80,#00,#F0,#00
       DB       #F8,#00,#FF,#81,#FF,#FF,#FF,#FF
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#5C,#02,#AA,#05,#7D,#2A,#B6
       DB       #95,#7F,#2A,#DB,#05,#77,#02,#9E
       DB       #00,#2C,#00,#00,#00,#00,#00,#00
       DB       #E0,#0F,#C0,#07,#C0,#07,#C0,#07
       DB       #C0,#07,#C0,#07,#C0,#07,#E0,#07
       DB       #E0,#0F,#E0,#0F,#E0,#0F,#F0,#1F
       DB       #F8,#3F,#F8,#3F,#F8,#3F,#FC,#7F
       DB       #07,#40,#0F,#A0,#1D,#D0,#1B,#70
       DB       #0F,#D0,#15,#E0,#07,#50,#0A,#A0
       DB       #05,#40,#0A,#A0,#05,#40,#02,#80
       DB       #01,#00,#02,#80,#00,#00,#01,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#07
       DB       #00,#01,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#80,#00,#C0,#00
       DB       #DE,#1C,#EF,#BF,#F4,#51,#F6,#60
       DB       #F7,#EE,#73,#DF,#B8,#00,#B7,#C0
       DB       #85,#F0,#8A,#FC,#95,#3B,#AA,#8F
       DB       #55,#72,#2A,#F8,#15,#F3,#0B,#BF
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#07
       DB       #00,#01,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#80,#00,#C0,#00
       DB       #1E,#1C,#CF,#BF,#E4,#51,#F6,#60
       DB       #F7,#EE,#33,#DF,#B8,#00,#B7,#C0
       DB       #B5,#F0,#8A,#FC,#95,#3B,#AA,#0F
       DB       #54,#E2,#29,#F0,#13,#E2,#07,#7E
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#E0,#00
       DB       #80,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#03
       DB       #38,#7B,#FD,#F7,#8A,#2F,#06,#6F
       DB       #77,#EF,#FB,#CE,#00,#1D,#03,#ED
       DB       #0F,#A1,#3F,#51,#DC,#A9,#F1,#55
       DB       #4E,#AA,#1F,#54,#CF,#A8,#FD,#D0
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#E0,#00
       DB       #80,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#01,#00,#03
       DB       #38,#78,#FD,#F3,#8A,#27,#06,#6F
       DB       #77,#EF,#FB,#CC,#00,#1D,#03,#ED
       DB       #0F,#AD,#3F,#51,#DC,#A9,#F0,#55
       DB       #47,#2A,#0F,#94,#47,#C8,#7E,#E0
       DB       #FC,#00,#F8,#00,#F8,#00,#E0,#00
       DB       #80,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#80,#00,#F0,#00,#E0,#00
       DB       #E0,#00,#E0,#00,#E0,#00,#F8,#00
       DB       #00,#7E,#01,#FE,#03,#FE,#03,#06
       DB       #0E,#6E,#3E,#5E,#7B,#3E,#77,#FE
       DB       #2F,#EE,#07,#9E,#00,#3E,#00,#FE
       DB       #0F,#FE,#0F,#FE,#03,#FE,#00,#3E
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#01,#80,#07
       DB       #84,#07,#FC,#0F,#FC,#0F,#FE,#1F
       DB       #00,#00,#FF,#FF,#FF,#FF,#FF,#F7
       DB       #FE,#E7,#FD,#D7,#79,#B7,#7B,#86
       DB       #73,#CE,#73,#FC,#33,#B0,#31,#70
       DB       #00,#E0,#01,#E0,#00,#C0,#00,#00
       DB       #00,#3F,#00,#1F,#00,#1F,#00,#07
       DB       #00,#01,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#01,#00,#0F,#00,#07
       DB       #00,#07,#00,#07,#00,#07,#00,#1F
       DB       #7E,#00,#7F,#80,#7F,#C0,#60,#C0
       DB       #76,#70,#7A,#7C,#7C,#DE,#7F,#EE
       DB       #77,#F4,#79,#E0,#7C,#00,#7F,#00
       DB       #7F,#F0,#7F,#F0,#7F,#C0,#7C,#00
       DB       #FE,#1F,#FC,#0F,#FC,#0F,#84,#07
       DB       #80,#07,#00,#01,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#C0,#01,#E0,#00,#E0
       DB       #31,#70,#33,#B0,#73,#FC,#73,#CE
       DB       #7B,#86,#79,#B7,#FD,#D7,#FE,#E7
       DB       #FF,#F7,#FF,#FF,#FF,#FF,#00,#00
       DB       #E0,#07,#E0,#07,#F0,#0F,#E0,#07
       DB       #C0,#03,#80,#01,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#01
       DB       #80,#01,#C0,#03,#C0,#03,#E0,#07
       DB       #0F,#F0,#04,#20,#05,#20,#05,#20
       DB       #0A,#10,#14,#08,#28,#04,#40,#02
       DB       #5F,#FA,#5F,#FA,#2F,#F4,#2F,#F4
       DB       #17,#E8,#17,#E8,#08,#10,#0F,#F0
       DB       #E0,#07,#E0,#07,#F0,#0F,#E0,#07
       DB       #C0,#03,#80,#01,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#01
       DB       #80,#01,#C0,#03,#C0,#03,#E0,#07
       DB       #0F,#F0,#04,#20,#05,#A0,#05,#A0
       DB       #0A,#D0,#15,#E8,#2B,#F4,#57,#FA
       DB       #57,#FA,#5F,#FA,#2F,#F4,#2F,#F4
       DB       #17,#E8,#17,#E8,#08,#10,#0F,#F0
       DB       #F8,#1F,#F0,#0F,#E0,#07,#C0,#03
       DB       #80,#01,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#80,#01
       DB       #C0,#03,#E0,#07,#F0,#0F,#F8,#1F
       DB       #01,#80,#03,#C0,#06,#60,#0C,#30
       DB       #19,#98,#32,#4C,#60,#46,#C0,#83
       DB       #C1,#03,#61,#06,#30,#0C,#19,#18
       DB       #0C,#30,#06,#60,#03,#C0,#01,#80
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00
       DB       #FF,#00,#C2,#00,#C0,#00,#00,#00
       DB       #00,#1F,#00,#3F,#00,#7F,#80,#FF
       DB       #81,#FF,#83,#FF,#C7,#FF,#FF,#FF
       DB       #00,#00,#00,#7E,#00,#42,#00,#5A
       DB       #00,#5A,#00,#42,#18,#FE,#1D,#C0
       DB       #6B,#80,#77,#00,#2E,#00,#1C,#00
       DB       #38,#00,#10,#00,#00
;
L_F69F	PUSH	BC
	LD	B,#32
L_F6A2	PUSH	BC
	LD	B,#FF
L_F6A5	DB	#00
	DJNZ	L_F6A5
	POP	BC
	DJNZ	L_F6A2
	POP	BC
	CALL	L_9835
         push af
         call CheckQuit
         pop af
	RET
;
	;org #ffe0
L_FFE0=0xffe0
	;org #ffee
L_FFEE=0xffee
	;org #fff6
L_FFF6=0xfff6
	;org #ffff
L_FFFF=0xffff
