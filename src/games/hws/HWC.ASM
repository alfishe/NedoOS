;
	ORG	#8000
;
       DB       #41,#42
;
       DW       L_8010
;
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00
;
L_8010	CALL	L_80D3
	CALL	L_819B
	JP	L_826B
;
L_8019	LD	HL,(#E390)
L_801C	DEC	HL
	LD	A,L
	OR	H
	JR	NZ,L_801C
	LD	A,(#E000)
	DEC	A
	LD	(#E000),A
	JR	NZ,L_8064
	LD	A,#10
	LD	(#E000),A
	LD	A,(#E012)
	LD	B,A
	LD	A,(#E013)
	LD	C,A
	LD	A,(#E014)
	CALL	L_870A
	CALL	L_84EA
	CALL	L_85A9
	CALL	L_8D38
	CALL	L_86B7
	CALL	L_86D3
	CALL	L_8C06
	CALL	L_8E9D
	LD	A,#00
	CALL	L_8B78
	LD	A,#01
	CALL	L_8B78
	LD	A,#02
	CALL	L_8B78
	CALL	L_8F4A
L_8064	LD	A,(#E001)
	DEC	A
	LD	(#E001),A
	JR	NZ,L_8088
	LD	A,#16
	LD	(#E001),A
	LD	A,(#E016)
	LD	B,A
	LD	A,(#E017)
	LD	C,A
	LD	A,(#E018)
	CALL	L_870A
	LD	A,#00
	CALL	L_88C5
	CALL	L_8D38
L_8088	LD	A,(#E002)
	DEC	A
	LD	(#E002),A
	JR	NZ,L_80AC
	LD	A,#18
	LD	(#E002),A
	LD	A,(#E020)
	LD	B,A
	LD	A,(#E021)
	LD	C,A
	LD	A,(#E022)
	CALL	L_870A
	LD	A,#01
	CALL	L_88C5
	CALL	L_8D38
L_80AC	LD	A,(#E003)
	DEC	A
	LD	(#E003),A
	JR	NZ,L_80D0
	LD	A,#14
	LD	(#E003),A
	LD	A,(#E030)
	LD	B,A
	LD	A,(#E031)
	LD	C,A
	LD	A,(#E032)
	CALL	L_870A
	LD	A,#02
	CALL	L_88C5
	CALL	L_8D38
L_80D0	JP	L_8019
;
L_80D3	LD	C,#80
	LD	HL,L_80E8
L_80D8	LD	A,(HL)
	LD	B,A
	PUSH	BC
	CALL	#0047
	POP	BC
	INC	C
	INC	HL
	LD	A,#88
	CP	C
	JR	Z,L_80F0
	JR	L_80D8
;
L_80E8	LD	(BC),A
	JP	PO,#FF0E
	INC	BC
	HALT
	INC	BC
	DB	#00
L_80F0	LD	HL,L_9703
	LD	DE,#0000
	LD	BC,#0800
	CALL	#005C
	LD	HL,L_9703
	LD	DE,#0800
	LD	BC,#0800
	CALL	#005C
	LD	HL,L_9703
	LD	DE,#1000
	LD	BC,#0800
	CALL	#005C
	LD	HL,L_9CD3
	LD	DE,#2000
	LD	BC,#02D0
	CALL	#005C
	LD	HL,L_9CD3
	LD	DE,#2800
	LD	BC,#02D0
	CALL	#005C
	LD	HL,L_9CD3
	LD	DE,#3000
	LD	BC,#02D0
	CALL	#005C
	LD	HL,#22D0
	CALL	L_8171
	LD	HL,#2AD0
	CALL	L_8171
	LD	HL,#32D0
	CALL	L_8171
	LD	HL,L_9FA3
	LD	DE,#2410
	LD	BC,#03E8
	CALL	#005C
	LD	HL,L_9FA3
	LD	DE,#2C10
	LD	BC,#03E8
	CALL	#005C
	LD	HL,L_9FA3
	LD	DE,#3410
	LD	BC,#03E8
	CALL	#005C
	JP	L_8180
;
L_8171	LD	BC,#0140
L_8174	LD	A,#E1
	CALL	#004D
	INC	HL
	DEC	BC
	LD	A,B
	OR	C
	JR	NZ,L_8174
	RET
;
L_8180	LD	HL,L_A163
	LD	DE,#1800
	LD	BC,#0240
	CALL	#005C
	LD	HL,#3800
	LD	BC,#0300
	LD	A,#82
	CALL	#0056
	CALL	L_903C
	RET
;
L_819B	LD	B,#FF
	LD	HL,#3B00
L_81A0	LD	A,#D1
	CALL	#004D
	INC	HL
	DJNZ	L_81A0
	LD	HL,L_960E
	LD	DE,L_967F
	LD	BC,L_96AE
	CALL	L_9013
	LD	DE,L_822B
	LD	HL,#38C8
	LD	B,#08
	CALL	L_8207
	LD	HL,#390C
	LD	B,#04
	CALL	L_8207
	LD	HL,#39A7
	LD	B,#13
	CALL	L_8214
	LD	HL,#3A29
	LD	B,#0E
	CALL	L_8214
	LD	HL,#3A6F
	LD	B,#02
	CALL	L_8214
	LD	HL,#3AAB
	LD	B,#09
	CALL	L_8214
	LD	HL,#3AEC
	LD	B,#08
	CALL	L_8214
L_81EF	LD	A,#00
	CALL	#00D8
	CP	#00
	JP	NZ,L_8203
	LD	A,#01
	CALL	#00D8
	CP	#00
	JP	Z,L_81EF
L_8203	CALL	L_902D
	RET
;
L_8207	LD	A,(DE)
	INC	DE
	CALL	#004D
	CALL	L_8220
	INC	HL
	INC	HL
	DJNZ	L_8207
	RET
;
L_8214	LD	A,(DE)
	INC	DE
	CALL	#004D
	CALL	L_8220
	INC	HL
	DJNZ	L_8214
	RET
;
L_8220	EXX
	LD	HL,#2000
L_8224	DEC	HL
	LD	A,L
	OR	H
	JR	NZ,L_8224
	EXX
	RET
;
L_822B       DB       #6B,#6C,#6A,#6B,#82,#79,#64,#7B       ;kljk.yd{
       DB       #75,#76,#64,#74,#79,#64,#7B,#82       ;uvdtyd{.
       DB       #6F,#6C,#70,#6C,#76,#82,#73,#74       ;olplv.st
       DB       #68,#75,#68,#71,#76,#75,#82,#5B       ;huhqvu.[
       DB       #63,#62,#5D,#82,#66,#72,#73,#7B       ;cb].frs{
       DB       #74,#6C,#6A,#6B,#76,#65,#7B,#7B       ;tljkve{{
       DB       #7F,#6C,#76,#64,#6E,#77,#74,#64       ;.lvdnwtd
       DB       #74,#7F,#76,#72,#6E,#77,#67,#64       ;t.vrnwgd
;
L_826B	LD	HL,#E000
	LD	DE,#1000
L_8271	LD	A,#00
	LD	(HL),A
	INC	HL
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,L_8271
	LD	HL,#0000
	LD	(#E202),HL
	LD	(#E200),HL
	LD	HL,#03E8
	LD	(#E20D),HL
	LD	HL,#3800
	LD	BC,#0300
	LD	A,#7D
	CALL	#0056
	LD	HL,#3818
	LD	B,#18
	LD	DE,L_82CE
L_829D	PUSH	BC
	LD	B,#08
L_82A0	LD	A,(DE)
	CALL	#004D
	INC	DE
	INC	HL
	DJNZ	L_82A0
	LD	BC,#0018
	ADD	HL,BC
	POP	BC
	DJNZ	L_829D
	LD	A,#40
	LD	HL,#3B42
	CALL	#004D
	LD	A,#06
	INC	HL
	CALL	#004D
	LD	A,#44
	LD	HL,#3B52
	CALL	#004D
	LD	A,#0F
	INC	HL
	CALL	#004D
	JP	L_838E
;
L_82CE       DB       #82,#82,#82,#82,#82,#82,#82,#82
       DB       #6B,#6C,#7E,#75,#66,#72,#74,#68
       DB       #82,#82,#82,#82,#82,#82,#82,#5A
       DB       #82,#82,#82,#82,#82,#82,#82,#82
       DB       #82,#82,#82,#75,#66,#72,#74,#68
       DB       #82,#82,#82,#82,#82,#82,#82,#5A
       DB       #82,#82,#82,#82,#82,#82,#82,#82
       DB       #83,#87,#87,#87,#87,#87,#87,#84
       DB       #8A,#82,#82,#82,#82,#82,#82,#88
       DB       #86,#89,#89,#89,#89,#89,#89,#85
       DB       #82,#82,#69,#77,#68,#6F,#82,#82
       DB       #82,#82,#82,#82,#82,#82,#82,#82
       DB       #83,#87,#87,#87,#87,#87,#87,#84
       DB       #8A,#17,#17,#17,#17,#17,#17,#88
       DB       #8A,#17,#17,#17,#17,#17,#17,#88
       DB       #8A,#17,#17,#17,#17,#17,#17,#88
       DB       #8A,#17,#17,#17,#17,#17,#17,#88
       DB       #8A,#17,#17,#17,#17,#17,#17,#88
       DB       #86,#89,#89,#89,#89,#89,#89,#85
       DB       #82,#82,#70,#64,#73,#82,#82,#82
       DB       #82,#82,#82,#82,#82,#82,#82,#82
       DB       #82,#66,#64,#74,#82,#5A,#82,#82
       DB       #82,#82,#82,#82,#82,#82,#82,#82
       DB       #82,#82,#82,#82,#82,#82,#82,#82
;
L_838E	LD	HL,#0190
	LD	(#E390),HL
	LD	HL,#0000
	LD	(#E200),HL
	LD	HL,#0003
	LD	(#E211),HL
	LD	A,#00
	LD	(#E220),A
	LD	(#E221),A
L_83A8	LD	A,(#E220)
	SLA	A
	LD	HL,L_83C6
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	HL,L_A3A3
	ADD	HL,DE
	LD	DE,#E090
	LD	BC,#003C
	LDIR
	JP	L_83D0
;
L_83C6       DB       #00,#00,#3B,#00,#76,#00,#B1,#00
       DB       #EC,#00
;
L_83D0	LD	HL,#03E8
	LD	(#E20D),HL
	LD	A,#00
	LD	(#E057),A
	LD	HL,L_84CD
	LD	A,(HL)
	INC	HL
	LD	(#E016),A
	LD	A,(HL)
	INC	HL
	LD	(#E017),A
	LD	A,(HL)
	INC	HL
	LD	(#E019),A
	LD	A,(HL)
	INC	HL
	LD	(#E01A),A
	LD	A,(HL)
	INC	HL
	LD	(#E020),A
	LD	A,(HL)
	INC	HL
	LD	(#E021),A
	LD	A,(HL)
	INC	HL
	LD	(#E023),A
	LD	A,(HL)
	INC	HL
	LD	(#E024),A
	LD	A,(HL)
	INC	HL
	LD	(#E030),A
	LD	A,(HL)
	INC	HL
	LD	(#E031),A
	LD	A,(HL)
	INC	HL
	LD	(#E033),A
	LD	A,(HL)
	INC	HL
	LD	(#E034),A
	LD	A,(HL)
	INC	HL
	LD	(#E010),A
	LD	A,(HL)
	INC	HL
	LD	(#E011),A
	LD	A,(HL)
	INC	HL
	LD	(#E012),A
	LD	A,(HL)
	INC	HL
	LD	(#E013),A
	LD	A,(HL)
	INC	HL
	LD	(#E015),A
	LD	A,(HL)
	INC	HL
	LD	(#E014),A
	LD	A,(HL)
	INC	HL
	LD	(#E050),A
	LD	(#E053),A
	LD	(#E051),A
	LD	(#E052),A
	LD	HL,#FFFF
L_8449	DEC	HL
	LD	A,L
	OR	H
	JP	NZ,L_8449
	LD	HL,(#E211)
	LD	A,L
	DEC	A
	ADD	A,#5A
	LD	HL,#3ABE
	CALL	#004D
	LD	HL,(#E221)
	LD	B,L
	INC	B
	LD	HL,#3ADF
	LD	DE,#0020
L_8467	LD	A,#2F
	CALL	#004D
	LD	A,#30
	ADD	HL,DE
	CALL	#004D
	SBC	HL,DE
	DEC	HL
	DJNZ	L_8467
	LD	HL,#3800
	LD	DE,#0008
	LD	B,#18
L_847F	PUSH	BC
	LD	B,#18
L_8482	LD	A,#82
	CALL	#004D
	INC	HL
	DJNZ	L_8482
	ADD	HL,DE
	POP	BC
	DJNZ	L_847F
	LD	DE,#38C8
	LD	HL,L_84E0
	LD	BC,#0005
	CALL	#005C
	LD	DE,#3929
	LD	HL,L_84E5
	LD	BC,#0005
	CALL	#005C
	LD	A,(#E221)
	INC	A
	ADD	A,#5A
	LD	HL,#38CE
	CALL	#004D
	LD	HL,#0000
L_84B5	DEC	HL
	LD	B,#05
L_84B8	DJNZ	L_84B8
	LD	A,L
	OR	H
	JR	NZ,L_84B5
	LD	HL,L_9564
	LD	DE,L_95CF
	LD	BC,L_95F2
	CALL	L_9013
	JP	L_8064
;
L_84CD       DB       #01,#03,#01,#00,#2F,#03,#01,#00
       DB       #5D,#03,#01,#00,#23,#31,#2F,#3D
       DB       #06,#00,#00
L_84E0       DB       #74,#72,#77,#71,#67
L_84E5       DB       #75,#76,#64,#74,#76
;
L_84EA	LD	A,(#E014)
	LD	B,A
	LD	A,(#E015)
	CP	#06
	JR	Z,L_8503
	LD	A,(#E057)
	DEC	A
	LD	(#E057),A
	RET	NZ
	LD	A,#06
	LD	(#E015),A
	RET
;
L_8503	LD	A,#00
	CALL	#00D5
	CP	#00
	JR	NZ,L_8511
	LD	A,#01
	CALL	#00D5
L_8511	LD	(#E056),A
	CP	#01
	JP	Z,L_852B
	CP	#03
	JP	Z,L_8532
	CP	#05
	JP	Z,L_8539
	CP	#07
	JP	Z,L_8540
	JP	L_854D
;
L_852B	LD	A,(#E050)
	LD	B,#00
	JR	L_8545
;
L_8532	LD	A,(#E053)
	LD	B,#01
	JR	L_8545
;
L_8539	LD	A,(#E051)
	LD	B,#02
	JR	L_8545
;
L_8540	LD	A,(#E052)
	LD	B,#03
L_8545	CP	#00
	JR	Z,L_8555
	CP	#01
	JR	Z,L_8555
L_854D	LD	A,(#E014)
	CP	#FF
	JR	NZ,L_8556
	RET
;
L_8555	LD	A,B
L_8556	CP	#00
	JR	Z,L_8574
	CP	#01
	JR	Z,L_856E
	CP	#02
	JR	Z,L_8568
	LD	B,A
	LD	A,(#E052)
	JR	L_8578
;
L_8568	LD	B,A
	LD	A,(#E051)
	JR	L_8578
;
L_856E	LD	B,A
	LD	A,(#E053)
	JR	L_8578
;
L_8574	LD	B,A
	LD	A,(#E050)
L_8578	CP	#00
	JR	Z,L_8583
	CP	#01
	JR	Z,L_858F
	JP	L_859B
;
L_8583	LD	A,(#E014)
	CP	B
	CALL	NZ,L_85A1
	LD	A,B
	LD	(#E014),A
	RET
;
L_858F	LD	A,#00
	LD	(#E015),A
	LD	A,#05
	LD	(#E057),A
	JR	L_8583
;
L_859B	LD	A,#FF
	LD	(#E014),A
	RET
;
L_85A1	EXX
	PUSH	AF
	CALL	#003D
	POP	AF
	EXX
	RET
;
L_85A9	LD	A,(#E012)
	CP	#08
	JR	NZ,L_85D9
	LD	A,(#E013)
	CP	#19
	JR	NZ,L_85D9
L_85B7	LD	DE,#000A
	LD	HL,(#E20D)
	LD	A,H
	CP	#05
	JP	NC,L_85F2
	ADD	HL,DE
	LD	(#E20D),HL
	LD	DE,L_96FB
	LD	(#E320),DE
	LD	DE,#E320
	LD	A,#02
	CALL	L_9071
	JP	L_85F2
;
L_85D9	LD	A,(#E012)
	CP	#56
	JR	NZ,L_85EA
	LD	A,(#E013)
	CP	#19
	JR	NZ,L_85EA
	JP	L_85B7
;
L_85EA	LD	HL,(#E20D)
	DEC	HL
	DEC	HL
	LD	(#E20D),HL
L_85F2	LD	A,(#E014)
	CP	#00
	JR	Z,L_8606
	CP	#01
	JR	Z,L_860C
	CP	#02
	JR	Z,L_8612
	CP	#03
	JR	Z,L_8618
	RET
;
L_8606	LD	HL,#E013
	DEC	(HL)
	JR	L_861C
;
L_860C	LD	HL,#E012
	INC	(HL)
	JR	L_861C
;
L_8612	LD	HL,#E013
	INC	(HL)
	JR	L_861C
;
L_8618	LD	HL,#E012
	DEC	(HL)
L_861C	LD	A,(#E012)
	SUB	#0C
	LD	(#E010),A
	LD	A,(#E013)
	SUB	#0C
	LD	(#E011),A
	LD	A,(#E012)
	CP	#0C
	JR	NC,L_863B
	LD	A,#00
	LD	(#E010),A
	JP	L_8644
;
L_863B	CP	#54
	JR	C,L_8644
	LD	A,#48
	LD	(#E010),A
L_8644	LD	A,(#E013)
	CP	#0C
	JR	NC,L_8653
	LD	A,#00
	LD	(#E011),A
	JP	L_865C
;
L_8653	CP	#3C
	JR	C,L_865C
	LD	A,#30
	LD	(#E011),A
L_865C	LD	HL,(#E200)
	INC	HL
	LD	(#E200),HL
	LD	DE,(#E202)
	CALL	#0020
	JP	C,L_8670
	LD	(#E202),HL
L_8670	LD	A,(#E014)
	SLA	A
	SLA	A
	LD	HL,#3B00
	INC	HL
	INC	HL
	CALL	#004D
	LD	DE,#0003
	LD	A,(#E015)
	LD	HL,#3B00
	ADD	HL,DE
	CALL	#004D
	LD	A,(#E010)
	LD	B,A
	LD	A,(#E011)
	LD	C,A
	LD	A,(#E012)
	SUB	B
	SLA	A
	SLA	A
	SLA	A
	LD	B,A
	LD	A,(#E013)
	SUB	C
	SLA	A
	SLA	A
	SLA	A
	LD	C,A
	LD	HL,#3B00
	LD	A,C
	CALL	#004D
	INC	HL
	LD	A,B
	CALL	#004D
	RET
;
L_86B7	LD	A,(#E012)
	SRL	A
	ADD	A,#C8
	LD	HL,#3B40
	INC	HL
	CALL	#004D
	LD	A,(#E013)
	SRL	A
	ADD	A,#68
	LD	HL,#3B40
	CALL	#004D
	RET
;
L_86D3	LD	HL,L_A4CA
	LD	DE,#0060
	AND	A
	SBC	HL,DE
	LD	A,(#E011)
	LD	B,A
	INC	B
L_86E1	ADD	HL,DE
	DJNZ	L_86E1
	LD	A,(#E010)
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	LD	DE,#3800
	LD	A,#18
L_86F0	LD	BC,#0018
	PUSH	DE
	PUSH	HL
	PUSH	AF
	CALL	#005C
	POP	AF
	POP	HL
	POP	DE
	LD	BC,#0060
	ADD	HL,BC
	LD	BC,#0020
	EX	DE,HL
	ADD	HL,BC
	EX	DE,HL
	DEC	A
	JR	NZ,L_86F0
	RET
;
L_870A	PUSH	AF
	LD	HL,L_A4CA
	LD	DE,#0060
	AND	A
	SBC	HL,DE
	INC	C
L_8715	ADD	HL,DE
	DEC	C
	JR	NZ,L_8715
	LD	C,B
	LD	A,#00
	LD	B,A
	ADD	HL,BC
	PUSH	HL
	POP	HL
	POP	AF
	PUSH	HL
	PUSH	AF
	AND	A
	LD	DE,#0060
	SBC	HL,DE
	LD	A,(HL)
	INC	HL
	LD	B,(HL)
	CP	#28
	JR	Z,L_8786
	CP	#2A
	JR	Z,L_878D
	CP	#16
	JR	Z,L_875B
	CP	#17
	JR	Z,L_875B
	CP	#18
	JR	Z,L_875B
	CP	#1C
	JR	Z,L_875B
	CP	#1F
	JR	Z,L_875B
	CP	#1D
	JR	Z,L_875B
	CP	#19
	JR	Z,L_875B
	CP	#20
	JR	Z,L_875B
L_8754	LD	A,#FF
	LD	(#E050),A
	JR	L_8792
;
L_875B	LD	A,B
	CP	#16
	JR	Z,L_877F
	CP	#17
	JR	Z,L_877F
	CP	#18
	JR	Z,L_877F
	CP	#1C
	JR	Z,L_877F
	CP	#1F
	JR	Z,L_877F
	CP	#1D
	JR	Z,L_877F
	CP	#19
	JR	Z,L_877F
	CP	#20
	JR	Z,L_877F
	JP	L_8754
;
L_877F	LD	A,#00
	LD	(#E050),A
	JR	L_8792
;
L_8786	LD	A,#01
	LD	(#E050),A
	JR	L_8792
;
L_878D	LD	A,#02
	LD	(#E050),A
L_8792	POP	AF
	POP	HL
	PUSH	HL
	PUSH	AF
	LD	DE,#00C0
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	B,(HL)
	CP	#2A
	JR	Z,L_87EF
	CP	#28
	JR	Z,L_87F6
	CP	#16
	JR	Z,L_87C8
	CP	#17
	JR	Z,L_87C8
	CP	#18
	JR	Z,L_87C8
	CP	#1C
	JR	Z,L_87C8
	CP	#1F
	JR	Z,L_87C8
	CP	#19
	JR	Z,L_87C8
	CP	#1D
	JR	Z,L_87C8
L_87C1	LD	A,#FF
	LD	(#E051),A
	JR	L_87FB
;
L_87C8	LD	A,B
	CP	#16
	JR	Z,L_87E8
	CP	#17
	JR	Z,L_87E8
	CP	#18
	JR	Z,L_87E8
	CP	#1C
	JR	Z,L_87E8
	CP	#1F
	JR	Z,L_87E8
	CP	#19
	JR	Z,L_87E8
	CP	#1D
	JR	Z,L_87E8
	JP	L_87C1
;
L_87E8	LD	A,#00
	LD	(#E051),A
	JR	L_87FB
;
L_87EF	LD	A,#01
	LD	(#E051),A
	JR	L_87FB
;
L_87F6	LD	A,#02
	LD	(#E051),A
L_87FB	POP	AF
	POP	HL
	PUSH	HL
	PUSH	AF
	DEC	HL
	LD	A,(HL)
	LD	DE,#0060
	ADD	HL,DE
	LD	B,(HL)
	CP	#2B
	JR	Z,L_8860
	CP	#29
	JR	Z,L_8867
	CP	#19
	JR	Z,L_8835
	CP	#1A
	JR	Z,L_8835
	CP	#17
	JR	Z,L_8835
	CP	#1B
	JR	Z,L_8835
	CP	#23
	JR	Z,L_8835
	CP	#1D
	JR	Z,L_8835
	CP	#16
	JR	Z,L_8835
	CP	#00
	JR	Z,L_8835
L_882E	LD	A,#FF
	LD	(#E052),A
	JR	L_886C
;
L_8835	LD	A,B
	CP	#19
	JR	Z,L_8859
	CP	#1A
	JR	Z,L_8859
	CP	#17
	JR	Z,L_8859
	CP	#1B
	JR	Z,L_8859
	CP	#23
	JR	Z,L_8859
	CP	#1D
	JR	Z,L_8859
	CP	#16
	JR	Z,L_8859
	CP	#00
	JR	Z,L_8859
	JP	L_882E
;
L_8859	LD	A,#00
	LD	(#E052),A
	JR	L_886C
;
L_8860	LD	A,#01
	LD	(#E052),A
	JR	L_886C
;
L_8867	LD	A,#02
	LD	(#E052),A
L_886C	POP	AF
	POP	HL
	INC	HL
	INC	HL
	LD	A,(HL)
	LD	DE,#0060
	ADD	HL,DE
	LD	B,(HL)
	CP	#29
	JR	Z,L_88B8
	CP	#2B
	JR	Z,L_88BF
	CP	#1A
	JR	Z,L_8899
	CP	#19
	JR	Z,L_8899
	CP	#17
	JR	Z,L_8899
	CP	#1B
	JR	Z,L_8899
	CP	#23
	JR	Z,L_8899
L_8892	LD	A,#FF
	LD	(#E053),A
	JR	L_88C4
;
L_8899	LD	A,B
	CP	#1A
	JR	Z,L_88B1
	CP	#19
	JR	Z,L_88B1
	CP	#17
	JR	Z,L_88B1
	CP	#1B
	JR	Z,L_88B1
	CP	#23
	JR	Z,L_88B1
	JP	L_8892
;
L_88B1	LD	A,#00
	LD	(#E053),A
	JR	L_88C4
;
L_88B8	LD	A,#01
	LD	(#E053),A
	JR	L_88C4
;
L_88BF	LD	A,#02
	LD	(#E053),A
L_88C4	RET
;
L_88C5	CP	#00
	JP	Z,L_88D5
	CP	#01
	JP	Z,L_88DB
	CP	#02
	JP	Z,L_88E1
	RET
;
L_88D5	LD	IX,#E016
	JR	L_88E5
;
L_88DB	LD	IX,#E020
	JR	L_88E5
;
L_88E1	LD	IX,#E030
L_88E5	LD	A,(IX+#04)
	CP	#00
	JR	Z,L_8916
	DEC	A
	LD	(IX+#04),A
	JR	NZ,L_88F7
	LD	A,#11
	LD	(IX+#03),A
L_88F7	LD	A,(IX+#02)
	CP	#00
	JR	Z,L_8912
	CP	#01
	JR	Z,L_890E
	CP	#02
	JR	Z,L_890A
	DEC	(IX+#00)
	RET
;
L_890A	INC	(IX+#01)
	RET
;
L_890E	INC	(IX+#00)
	RET
;
L_8912	DEC	(IX+#01)
	RET
;
L_8916	LD	A,(IX+#02)
	CP	#00
	JP	Z,L_89EB
	CP	#01
	JP	Z,L_89AA
	CP	#02
	JP	Z,L_8969
	LD	A,#FF
	LD	(#E053),A
	LD	A,(#E052)
	CP	#FF
	JP	Z,L_8A2D
	CP	#02
	JP	Z,L_8A2D
	LD	A,(#E050)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E051)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E052)
	CP	#00
	JR	Z,L_8965
L_895B	LD	A,#00
	LD	(IX+#03),A
	LD	A,#04
	LD	(IX+#04),A
L_8965	DEC	(IX+#00)
	RET
;
L_8969	LD	A,#FF
	LD	(#E050),A
	LD	A,(#E051)
	CP	#FF
	JP	Z,L_8A2D
	CP	#02
	JP	Z,L_8A2D
	LD	A,(#E052)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E053)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E051)
	CP	#00
	JR	Z,L_89A6
L_899C	LD	A,#00
	LD	(IX+#03),A
	LD	A,#04
	LD	(IX+#04),A
L_89A6	INC	(IX+#01)
	RET
;
L_89AA	LD	A,#FF
	LD	(#E052),A
	LD	A,(#E053)
	CP	#FF
	JP	Z,L_8A2D
	CP	#02
	JP	Z,L_8A2D
	LD	A,(#E050)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E051)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E053)
	CP	#00
	JR	Z,L_89E7
L_89DD	LD	A,#00
	LD	(IX+#03),A
	LD	A,#04
	LD	(IX+#04),A
L_89E7	INC	(IX+#00)
	RET
;
L_89EB	LD	A,#FF
	LD	(#E051),A
	LD	A,(#E050)
	CP	#FF
	JP	Z,L_8A2D
	CP	#02
	JP	Z,L_8A2D
	LD	A,(#E053)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E052)
	CP	#00
	JP	Z,L_8A2D
	CP	#01
	JP	Z,L_8A2D
	LD	A,(#E050)
	CP	#00
	JP	Z,L_8A29
L_8A1F	LD	A,#00
	LD	(IX+#03),A
	LD	A,#04
	LD	(IX+#04),A
L_8A29	DEC	(IX+#01)
	RET
;
L_8A2D	LD	A,(#E012)
	LD	B,A
	LD	A,(#E013)
	LD	C,A
	LD	A,(IX+#00)
	CP	B
	JP	C,L_8A48
	LD	A,(IX+#01)
	CP	C
	JP	C,L_8A54
	LD	A,#04
	JP	L_8A5B
;
L_8A48	LD	A,(IX+#01)
	CP	C
	JP	C,L_8A59
	LD	A,#01
	JP	L_8A5B
;
L_8A54	LD	A,#03
	JP	L_8A5B
;
L_8A59	LD	A,#02
L_8A5B	CP	#01
	JP	Z,L_8AB5
	CP	#02
	JP	Z,L_8A9A
	CP	#03
	JP	Z,L_8A81
	LD	A,(IX+#00)
	SUB	B
	LD	D,A
	LD	A,(IX+#01)
	SUB	C
	SUB	D
	JP	C,L_8A7C
	LD	A,#00
	JP	L_8ACB
;
L_8A7C	LD	A,#03
	JP	L_8ACB
;
L_8A81	LD	A,(IX+#00)
	SUB	B
	LD	D,A
	LD	A,(IX+#01)
	LD	E,A
	LD	A,C
	SUB	E
	SUB	D
	JP	C,L_8A95
	LD	A,#02
	JP	L_8ACB
;
L_8A95	LD	A,#03
	JP	L_8ACB
;
L_8A9A	LD	A,(IX+#00)
	LD	D,A
	LD	A,B
	SUB	D
	LD	D,A
	LD	A,(IX+#01)
	LD	E,A
	LD	A,C
	SUB	E
	SUB	D
	JP	C,L_8AB0
	LD	A,#02
	JP	L_8ACB
;
L_8AB0	LD	A,#01
	JP	L_8ACB
;
L_8AB5	LD	A,(IX+#00)
	LD	D,A
	LD	A,B
	SUB	D
	LD	D,A
	LD	A,(IX+#01)
	SUB	C
	SUB	D
	JP	C,L_8AC9
	LD	A,#00
	JP	L_8ACB
;
L_8AC9	LD	A,#01
L_8ACB	CP	#00
	JP	Z,L_8B3A
	CP	#01
	JP	Z,L_8B1B
	CP	#02
	JP	Z,L_8AFC
	JP	L_8ADD
;
L_8ADD	LD	A,(#E052)
	CP	#FF
	JP	Z,L_8AFC
	CP	#02
	JP	Z,L_8AFC
	CP	#01
	JP	Z,L_8AF4
	LD	A,#03
	JP	L_8B59
;
L_8AF4	LD	A,#03
	LD	(IX+#02),A
	JP	L_895B
;
L_8AFC	LD	A,(#E051)
	CP	#FF
	JP	Z,L_8B1B
	CP	#02
	JP	Z,L_8B1B
	CP	#01
	JP	Z,L_8B13
	LD	A,#02
	JP	L_8B59
;
L_8B13	LD	A,#02
	LD	(IX+#02),A
	JP	L_899C
;
L_8B1B	LD	A,(#E053)
	CP	#FF
	JP	Z,L_8B3A
	CP	#02
	JP	Z,L_8B3A
	CP	#01
	JP	Z,L_8B32
	LD	A,#01
	JP	L_8B59
;
L_8B32	LD	A,#01
	LD	(IX+#02),A
	JP	L_89DD
;
L_8B3A	LD	A,(#E050)
	CP	#FF
	JP	Z,L_8ADD
	CP	#02
	JP	Z,L_8ADD
	CP	#01
	JP	Z,L_8B51
	LD	A,#00
	JP	L_8B59
;
L_8B51	LD	A,#00
	LD	(IX+#02),A
	JP	L_8A1F
;
L_8B59	LD	(IX+#02),A
	CP	#00
	JR	Z,L_8B74
	CP	#01
	JR	Z,L_8B70
	CP	#02
	JR	Z,L_8B6C
	DEC	(IX+#00)
	RET
;
L_8B6C	INC	(IX+#01)
	RET
;
L_8B70	INC	(IX+#00)
	RET
;
L_8B74	DEC	(IX+#01)
	RET
;
L_8B78	CP	#00
	JR	Z,L_8B96
	CP	#01
	JR	Z,L_8B8B
	LD	IX,#E030
	LD	HL,#3B30
	LD	D,#30
	JR	L_8B9F
;
L_8B8B	LD	IX,#E020
	LD	HL,#3B20
	LD	D,#20
	JR	L_8B9F
;
L_8B96	LD	IX,#E016
	LD	HL,#3B10
	LD	D,#10
L_8B9F	LD	A,(IX+#00)
	LD	B,A
	LD	A,(IX+#01)
	LD	C,A
	LD	A,(#E010)
	CP	B
	JP	NC,L_8C00
	LD	A,(#E011)
	CP	C
	JP	NC,L_8C00
	LD	A,(#E010)
	ADD	A,#16
	CP	B
	JP	C,L_8C00
	LD	A,(#E011)
	ADD	A,#16
	CP	C
	JP	C,L_8C00
	LD	A,(#E010)
	LD	B,A
	LD	A,(#E011)
	LD	C,A
	LD	A,(IX+#00)
	SUB	B
	SLA	A
	SLA	A
	SLA	A
	INC	HL
	CALL	#004D
	LD	A,(IX+#01)
	SUB	C
	SLA	A
	SLA	A
	SLA	A
	DEC	HL
	CALL	#004D
	LD	A,(IX+#02)
	SLA	A
	SLA	A
	ADD	A,D
	INC	HL
	INC	HL
	CALL	#004D
	LD	A,(IX+#03)
	INC	HL
	CALL	#004D
	RET
;
L_8C00	LD	A,#D1
	CALL	#004D
	RET
;
L_8C06	LD	IX,#E090
	LD	B,#0C
L_8C0C	PUSH	BC
	LD	A,(IX+#00)
	CP	#00
	JP	Z,L_8CD1
	LD	A,(#E010)
	LD	D,A
	LD	A,(IX+#01)
	CP	D
	JP	C,L_8CD1
	LD	A,(#E011)
	LD	E,A
	LD	A,(IX+#02)
	CP	E
	JP	C,L_8CD1
	LD	A,(#E010)
	ADD	A,#17
	LD	D,A
	LD	A,(IX+#01)
	CP	D
	JP	NC,L_8CD1
	LD	A,(#E011)
	ADD	A,#17
	LD	E,A
	LD	A,(IX+#02)
	CP	E
	JP	NC,L_8CD1
	LD	A,(IX+#01)
	LD	D,A
	LD	A,(IX+#02)
	LD	E,A
	LD	A,(#E012)
	CP	D
	JP	NZ,L_8C8D
	LD	A,(#E013)
	CP	E
	JP	NZ,L_8C8D
	LD	A,#00
	LD	(IX+#00),A
	LD	A,(IX+#03)
	CP	#01
	JP	Z,L_8C71
	CP	#00
	JP	Z,L_8C71
	POP	BC
	JP	L_8DD1
;
L_8C71	LD	HL,(#E200)
	LD	BC,#0064
	ADD	HL,BC
	LD	(#E200),HL
	LD	DE,L_96DE
	LD	(#E320),DE
	LD	A,#02
	LD	DE,#E320
	CALL	L_9071
	JP	L_8CD1
;
L_8C8D	LD	A,(#E010)
	LD	D,A
	LD	A,(IX+#01)
	SUB	D
	LD	C,A
	LD	A,(#E011)
	LD	D,A
	LD	A,(IX+#02)
	SUB	D
	LD	B,A
	LD	HL,#3800
	LD	DE,#0020
	AND	A
	SBC	HL,DE
	INC	B
L_8CA9	ADD	HL,DE
	DJNZ	L_8CA9
	ADD	HL,BC
	LD	A,(IX+#03)
	SLA	A
	SLA	A
	ADD	A,#46
	PUSH	AF
	CALL	#004D
	POP	AF
	INC	A
	ADD	HL,DE
	PUSH	AF
	CALL	#004D
	POP	AF
	INC	A
	AND	A
	SBC	HL,DE
	INC	HL
	PUSH	AF
	CALL	#004D
	POP	AF
	INC	A
	ADD	HL,DE
	CALL	#004D
L_8CD1	LD	DE,#0004
	ADD	IX,DE
	POP	BC
	DEC	B
	JP	NZ,L_8C0C
	RET
;
L_8CDC	POP	HL
	LD	DE,#0030
	LD	HL,(#E390)
	LD	A,H
	CP	#00
	JR	Z,L_8CEE
	AND	A
	SBC	HL,DE
	LD	(#E390),HL
L_8CEE	CALL	L_902D
	LD	A,(#E220)
	CP	#04
	JP	NZ,L_8CFB
	LD	A,#FF
L_8CFB	INC	A
	LD	(#E220),A
	LD	A,(#E221)
	INC	A
	LD	(#E221),A
L_8D06	LD	HL,(#E20D)
	DEC	HL
	LD	A,L
	OR	H
	JP	Z,L_8D35
	LD	(#E20D),HL
	LD	DE,L_96FB
	LD	(#E320),DE
	LD	DE,#E320
	LD	A,#02
	CALL	L_9071
	CALL	L_8F4A
	LD	HL,(#E200)
	INC	HL
	LD	(#E200),HL
	LD	B,#FF
L_8D2D	DJNZ	L_8D2D
	CALL	L_8F4A
	JP	L_8D06
;
L_8D35	JP	L_83A8
;
L_8D38	LD	A,(#E012)
	LD	B,A
	LD	A,(#E013)
	LD	C,A
	LD	A,(#E016)
	CP	B
	JP	NZ,L_8D6C
	LD	A,(#E017)
	CP	C
	JP	NZ,L_8D6C
	LD	A,(#E019)
	CP	#00
	JP	NZ,L_8D61
	LD	A,(#E015)
	CP	#00
	JP	NZ,L_8D6C
	JP	L_8DD1
;
L_8D61	LD	A,(#E015)
	CP	#00
	JP	Z,L_8D6C
	JP	L_8DD1
;
L_8D6C	LD	A,(#E020)
	CP	B
	JP	NZ,L_8D98
	LD	A,(#E021)
	CP	C
	JP	NZ,L_8D98
	LD	A,(#E023)
	CP	#00
	JP	NZ,L_8D8D
	LD	A,(#E015)
	CP	#00
	JP	NZ,L_8D98
	JP	L_8DD1
;
L_8D8D	LD	A,(#E015)
	CP	#00
	JP	Z,L_8D98
	JP	L_8DD1
;
L_8D98	LD	A,(#E030)
	CP	B
	JP	NZ,L_8DC4
	LD	A,(#E031)
	CP	C
	JP	NZ,L_8DC4
	LD	A,(#E033)
	CP	#00
	JP	NZ,L_8DB9
	LD	A,(#E015)
	CP	#00
	JP	NZ,L_8DC4
	JP	L_8DD1
;
L_8DB9	LD	A,(#E015)
	CP	#00
	JP	Z,L_8DC4
	JP	L_8DD1
;
L_8DC4	LD	HL,(#E20D)
	LD	DE,#0007
	CALL	#0020
	JP	C,L_8DD1
	RET
;
L_8DD1	POP	HL
	CALL	L_902D
	LD	DE,L_96E9
	LD	(#E320),DE
	LD	DE,#E320
	LD	A,#02
	CALL	L_9071
	LD	A,(#E010)
	LD	D,A
	LD	A,(#E011)
	LD	E,A
	LD	A,(#E012)
	SUB	D
	SUB	#01
	LD	C,A
	LD	A,(#E013)
	SUB	E
	SUB	#01
	LD	B,A
	LD	HL,#3800
	LD	DE,#0020
	AND	A
	SBC	HL,DE
	INC	B
L_8E04	ADD	HL,DE
	DJNZ	L_8E04
	ADD	HL,BC
	LD	DE,L_8E38
	LD	B,#04
L_8E0D	PUSH	BC
	LD	B,#04
L_8E10	LD	A,(DE)
	INC	DE
	CALL	#004D
	INC	HL
	DJNZ	L_8E10
	PUSH	DE
	LD	DE,#001C
	ADD	HL,DE
	POP	DE
	POP	BC
	DJNZ	L_8E0D
	LD	HL,(#E211)
	DEC	HL
	LD	(#E211),HL
	LD	A,H
	OR	L
	JP	Z,L_8E48
	LD	HL,#FFFF
L_8E30	DEC	HL
	LD	A,L
	OR	H
	JR	NZ,L_8E30
	JP	L_83D0
;
L_8E38       DB       #96,#97,#98,#99,#9A,#9D,#9C,#9D
       DB       #9E,#9F,#A0,#A1,#A2,#A3,#A4,#A5
;
L_8E48	LD	HL,L_8E57
	LD	DE,#3928
	LD	BC,#0009
	CALL	#005C
	JP	L_8E60
;
L_8E57       DB       #6A,#64,#70,#68,#7D,#72,#78,#68
       DB       #74
;
L_8E60	LD	HL,#0000
L_8E63	DEC	HL
	LD	B,#05
L_8E66	DJNZ	L_8E66
	LD	A,L
	OR	H
	JR	NZ,L_8E63
L_8E6C	LD	A,#00
	CALL	#00D8
	CP	#00
	JP	NZ,L_8E80
	LD	A,#01
	CALL	#00D8
	CP	#00
	JP	Z,L_8E6C
L_8E80	LD	HL,#3AD8
	LD	B,#08
L_8E85	LD	A,#82
	CALL	#004D
	INC	HL
	DJNZ	L_8E85
	LD	HL,#3AF8
	LD	B,#08
L_8E92	LD	A,#82
	CALL	#004D
	INC	HL
	DJNZ	L_8E92
	JP	L_838E
;
L_8E9D	LD	HL,#E090
	LD	DE,#0030
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	SLA	A
	LD	E,A
	LD	D,#00
	ADD	HL,DE
	LD	A,(HL)
	INC	HL
	LD	B,A
	LD	A,(HL)
	LD	C,A
	LD	A,B
	SRL	A
	ADD	A,#C8
	LD	HL,#3B51
	CALL	#004D
	LD	A,C
	SRL	A
	ADD	A,#68
	LD	HL,#3B50
	CALL	#004D
	LD	A,(#E010)
	LD	D,A
	LD	A,(#E011)
	LD	E,A
	LD	A,B
	CP	D
	RET	C
	LD	A,C
	CP	E
	RET	C
	LD	A,D
	ADD	A,#17
	LD	D,A
	LD	A,E
	ADD	A,#17
	LD	E,A
	LD	A,B
	CP	D
	RET	NC
	LD	A,C
	CP	E
	RET	NC
	PUSH	BC
	LD	A,(#E010)
	LD	D,A
	LD	A,(#E011)
	LD	E,A
	LD	A,B
	SUB	D
	LD	D,A
	LD	A,C
	SUB	E
	LD	E,A
	LD	B,E
	LD	C,D
	LD	HL,#3800
	LD	DE,#0020
	AND	A
	SBC	HL,DE
	INC	B
L_8EFE	ADD	HL,DE
	DJNZ	L_8EFE
	ADD	HL,BC
	LD	A,#52
	CALL	#004D
	LD	DE,#0020
	ADD	HL,DE
	LD	A,#53
	CALL	#004D
	LD	A,#54
	SBC	HL,DE
	INC	HL
	CALL	#004D
	LD	A,#55
	ADD	HL,DE
	CALL	#004D
	POP	BC
	LD	A,(#E012)
	CP	B
	RET	NZ
	LD	A,(#E013)
	CP	C
	RET	NZ
	LD	DE,L_96DE
	LD	(#E320),DE
	LD	DE,#E320
	LD	A,#02
	CALL	L_9071
	LD	HL,#E090
	LD	DE,#0030
	ADD	HL,DE
	LD	A,(HL)
	INC	A
	CP	#05
	JR	Z,L_8F47
	LD	(HL),A
	RET
;
L_8F47	JP	L_8CDC
;
L_8F4A	LD	HL,(#E202)
	LD	(#E202),HL
	LD	(#E20B),HL
	LD	HL,#385A
	LD	(#E209),HL
	CALL	L_8FBF
	LD	HL,(#E200)
	LD	(#E200),HL
	LD	(#E20B),HL
	LD	HL,#38BA
	LD	(#E209),HL
	CALL	L_8FBF
	LD	HL,#3919
	LD	B,#06
L_8F73	LD	A,#8D
	CALL	#004D
	INC	HL
	DJNZ	L_8F73
	LD	HL,(#E20D)
	OR	A
	RR	H
	RR	L
	OR	A
	RR	H
	RR	L
	OR	A
	RR	H
	RR	L
	OR	A
	RR	H
	RR	L
	OR	A
	RR	H
	RR	L
	XOR	A
	RR	L
	RRA
	RR	L
	RRA
	RR	L
	RRA
	RRA
	RRA
	RRA
	RRA
	RRA
	LD	C,A
	LD	A,L
	LD	B,L
	LD	HL,#391E
	CP	#00
	JR	Z,L_8FB8
L_8FB0	LD	A,#8C
	CALL	#004D
	DEC	HL
	DJNZ	L_8FB0
L_8FB8	LD	A,C
	ADD	A,#8D
	CALL	#004D
	RET
;
L_8FBF	PUSH	BC
	PUSH	HL
	LD	BC,#E204
	LD	HL,(#E20B)
	CALL	L_8FCD
	JP	L_8FF9
;
L_8FCD	LD	DE,#2710
	CALL	L_8FEC
	LD	DE,#03E8
	CALL	L_8FEC
	LD	DE,#0064
	CALL	L_8FEC
	LD	DE,#000A
	CALL	L_8FEC
	LD	DE,#0001
	CALL	L_8FEC
	RET
;
L_8FEC	XOR	A
	AND	A
L_8FEE	INC	A
	SBC	HL,DE
	JP	NC,L_8FEE
	ADD	HL,DE
	DEC	A
	LD	(BC),A
	INC	BC
	RET
;
L_8FF9	LD	DE,#E204
	LD	HL,(#E209)
	LD	B,#05
L_9001	LD	A,(DE)
	LD	C,#5A
	ADD	A,C
	PUSH	HL
	PUSH	BC
	CALL	#004D
	POP	BC
	POP	HL
	INC	HL
	INC	DE
	DJNZ	L_9001
	POP	HL
	POP	BC
	RET
;
L_9013	LD	(#E300),HL
	LD	(#E320),DE
	LD	(#E340),BC
	LD	HL,#E300
	LD	DE,#E320
	LD	BC,#E340
	LD	A,#07
	CALL	L_9071
	RET
;
L_902D	LD	HL,#E300
	LD	DE,#E320
	LD	BC,#E340
	LD	A,#07
	CALL	L_90FF
	RET
;
L_903C	DI
	CALL	#0090
	DI
	XOR	A
	LD	(#E408),A
	LD	A,#07
	CALL	#0096
	AND	#C0
	OR	#38
	LD	E,A
	LD	A,#07
	CALL	#0093
	LD	E,#00
	LD	A,#08
	CALL	#0093
	INC	A
	CALL	#0093
	INC	A
	CALL	#0093
	LD	HL,#FD9F
	LD	DE,L_9266
	LD	(HL),#C3
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	EI
	RET
;
L_9071	DI
	PUSH	IX
	PUSH	BC
	PUSH	DE
	PUSH	HL
	LD	C,A
	LD	A,(#E408)
	OR	C
	AND	#0F
	EX	AF,AF'
	XOR	A
	LD	(#E408),A
	LD	A,C
	BIT	3,A
	JP	NZ,L_90B3
	AND	#07
	RLA
	RLA
	RLA
L_908E	LD	E,A
	LD	A,#07
	CALL	#0096
	OR	E
	LD	E,A
	LD	A,#07
	CALL	#0093
	LD	B,#04
	LD	IY,#E400
L_90A1	POP	HL
	RR	C
	CALL	C,L_90B7
	INC	IY
	INC	IY
	DJNZ	L_90A1
	EX	AF,AF'
	LD	(#E408),A
	EI
	RET
;
L_90B3	LD	A,#38
	JR	L_908E
;
L_90B7	LD	(IY+#00),L
	LD	(IY+#01),H
	LD	A,#04
	SUB	B
	LD	D,A
	CP	#03
	JP	Z,L_90D9
	SLA	A
	LD	E,#00
	CALL	#0093
	INC	A
	CALL	#0093
	LD	A,D
	ADD	A,#08
	LD	E,#08
	CALL	#0093
L_90D9	PUSH	HL
	POP	IX
	LD	DE,#0008
	ADD	HL,DE
	LD	(IX+#02),L
	LD	(IX+#03),H
	LD	(IX+#04),#01
	LD	(IX+#05),#00
	LD	(IX+#07),#3C
	LD	(IX+#08),#00
	LD	A,C
	BIT	3,A
	RET	NZ
	LD	(IX+#06),#01
	RET
;
L_90FF	DI
	AND	#0F
	LD	D,A
	CPL
	LD	HL,#E408
	AND	(HL)
	LD	(HL),A
	LD	A,D
	BIT	3,A
	JR	NZ,L_9125
	LD	A,#08
	LD	E,#00
	RR	D
	CALL	C,#0093
	INC	A
	RR	D
	CALL	C,#0093
	INC	A
	RR	D
	CALL	C,#0093
	EI
	RET
;
L_9125	LD	A,#07
	CALL	#0096
	OR	#38
	LD	E,A
	LD	A,#07
	CALL	#0093
	EI
	RET
;
       DB       #F3,#E6,#0F,#DD,#E5,#C5,#D5,#E5       ;sf.]eEUe
       DB       #4F,#3A,#08,#E4,#B1,#08,#AF,#32       ;O:.d1./2
       DB       #08,#E4,#06,#04,#FD,#21,#00,#E4       ;.d..}!.d
       DB       #E1,#CB,#19,#DC,#5E,#91,#FD,#23       ;aK.\^.}#
       DB       #FD,#23,#10,#F4,#08,#32,#08,#E4       ;}#.t.2.d
       DB       #FB,#C9,#FD,#75,#00,#FD,#74,#01       ;{I}u.}t.
       DB       #3E,#04,#90,#57,#E5,#DD,#E1,#DD       ;>..We]a]
       DB       #6E,#02,#DD,#66,#03,#5E,#3E,#0D       ;n.]f.^>.
       DB       #CD,#93,#00,#2B,#3D,#5E,#CD,#93       ;M..+=^M.
       DB       #00,#2B,#3D,#5E,#CD,#93,#00,#2B       ;.+=^M..+
       DB       #7A,#FE,#03,#20,#42,#C6,#08,#5E       ;z~. BF.^
       DB       #CD,#93,#00,#2B,#7A,#D5,#B7,#17       ;M..+zU7.
       DB       #17,#17,#2F,#57,#2F,#A6,#5F,#3E       ;../W/&_>
       DB       #07,#CD,#96,#00,#A2,#B3,#5F,#3E       ;.M.."3_>
       DB       #07,#CD,#93,#00,#D1,#2B,#3D,#5E       ;.M..Q+=^
       DB       #CD,#93,#00,#7A,#FE,#03,#20,#1D       ;M..z~. .
       DB       #2B,#7A,#CB,#27,#3C,#5E,#CD,#93       ;+zK'<^M.
       DB       #00,#2B,#3D,#5E,#CD,#93,#00,#2B       ;.+=^M..+
       DB       #DD,#75,#02,#DD,#74,#03,#C9,#2B       ;]u.]t.I+
       DB       #D5,#3E,#38,#18,#C5,#2B,#2B,#18       ;U>8.E++.
       DB       #EE,#F3,#E6,#0F,#4F,#2F,#47,#3A       ;nsf.O/G:
       DB       #08,#E4,#A0,#08,#AF,#32,#08,#E4       ;.d ./2.d
       DB       #01,#08,#00,#DD,#2A,#00,#E4,#CB       ;...]*.dK
       DB       #1A,#DC,#11,#92,#01,#09,#02,#DD       ;.\.....]
       DB       #2A,#02,#E4,#CB,#1A,#DC,#11,#92       ;*.dK.\..
       DB       #01,#0A,#04,#DD,#2A,#04,#E4,#CB       ;...]*.dK
       DB       #1A,#DC,#11,#92,#01,#06,#00,#DD       ;.\.....]
       DB       #2A,#06,#E4,#FB,#C9,#DD,#6E,#02       ;*.d{I]n.
       DB       #DD,#66,#03,#23,#78,#CD,#96,#00       ;]f.#xM..
       DB       #77,#23,#78,#3C,#CD,#96,#00,#77       ;w#x<M..w
       DB       #23,#3E,#06,#CD,#96,#00,#77,#23       ;#>.M..w#
       DB       #3E,#07,#CD,#96,#00,#77,#F6,#38       ;>.M..wv8
       DB       #5F,#3E,#07,#CD,#93,#00,#23,#79       ;_>.M..#y
       DB       #CD,#96,#00,#77,#1E,#00,#79,#CD       ;M..w..yM
       DB       #93,#00,#23,#3E,#0B,#CD,#96,#00       ;..#>.M..
       DB       #77,#23,#3E,#0C,#CD,#96,#00,#77       ;w#>.M..w
       DB       #23,#3E,#0D,#CD,#96,#00,#77,#DD       ;#>.M..w]
       DB       #75,#02,#DD,#74,#03,#C9,#3A,#08       ;u.]t.I:.
       DB       #E4,#C9       ;dI
;
L_9266	DI
	PUSH	AF
	LD	BC,#0008
	LD	D,#01
	LD	IX,(#E400)
	CALL	L_929B
	LD	BC,#0209
	LD	D,#02
	LD	IX,(#E402)
	CALL	L_929B
	LD	BC,#040A
	LD	D,#04
	LD	IX,(#E404)
	CALL	L_929B
	LD	BC,#0006
	LD	D,#08
	LD	IX,(#E406)
	CALL	L_929B
	POP	AF
	EI
	RET
;
L_929B	LD	A,(#E408)
	AND	D
	RET	Z
	DEC	(IX+#04)
	RET	NZ
	INC	(IX+#04)
L_92A7	LD	L,(IX+#00)
	LD	H,(IX+#01)
	PUSH	HL
	POP	IY
	LD	A,(IY+#00)
	CP	#60
	JP	C,L_933A
	CP	#C0
	JP	C,L_936E
	CP	#D0
	JP	C,L_93AE
	CP	#E0
	JP	C,L_93E4
	JP	Z,L_9388
	CP	#E2
	JP	C,L_939B
	JP	Z,L_93B8
	CP	#E4
	JP	C,L_93C3
	JP	Z,L_93CE
	CP	#E6
	JP	C,L_93F8
	JP	Z,L_940D
	CP	#E8
	JP	C,L_9422
	JP	Z,L_942F
	CP	#EA
	JP	C,L_944C
	JP	Z,L_9462
	CP	#EC
	JP	C,L_946D
	JP	Z,L_9493
	CP	#EE
	JP	C,L_94BC
	JP	Z,L_94E0
	CP	#F0
	JP	C,L_9318
	JP	L_94F8
;
L_930A	INC	IY
L_930C	PUSH	IY
	POP	HL
	LD	(IX+#00),L
	LD	(IX+#01),H
	JP	L_92A7
;
L_9318	LD	A,C
	LD	E,#00
	CALL	#0093
	LD	A,D
	BIT	3,A
	JR	NZ,L_932A
L_9323	CPL
	LD	HL,#E408
	AND	(HL)
	LD	(HL),A
	RET
;
L_932A	LD	A,#07
	CALL	#0096
	OR	#38
	LD	E,A
	LD	A,#07
	CALL	#0093
	LD	A,D
	JR	L_9323
;
L_933A	ADD	A,(IX+#05)
	CALL	L_94FB
	LD	E,L
	LD	A,B
	CALL	#0093
	LD	E,H
	INC	A
	CALL	#0093
L_934A	LD	A,(IX+#07)
L_934D	LD	E,(IX+#06)
	LD	H,A
L_9351	DEC	E
	JR	Z,L_9357
	ADD	A,H
	JR	L_9351
;
L_9357	LD	(IX+#04),A
	LD	E,(IX+#08)
	LD	A,#0D
	CALL	#0093
	INC	IY
	PUSH	IY
	POP	HL
	LD	(IX+#00),L
	LD	(IX+#01),H
	RET
;
L_936E	SUB	#60
	ADD	A,(IX+#05)
	CALL	L_94FB
	LD	E,L
	LD	A,B
	CALL	#0093
	LD	E,H
	INC	A
	CALL	#0093
L_9380	INC	IY
	LD	A,(IY+#00)
	JP	L_934D
;
L_9388	LD	A,D
	BIT	3,A
	JP	NZ,L_934A
	LD	E,#00
	LD	A,B
	CALL	#0093
	INC	A
	CALL	#0093
	JP	L_934A
;
L_939B	LD	A,D
	BIT	3,A
	JP	NZ,L_9380
	LD	E,#00
	LD	A,B
	CALL	#0093
	INC	A
	CALL	#0093
	JP	L_9380
;
L_93AE	SUB	#C0
	LD	E,A
	LD	A,C
	CALL	#0093
	JP	L_930A
;
L_93B8	INC	IY
	LD	A,(IY+#00)
	LD	(IX+#07),A
	JP	L_930A
;
L_93C3	INC	IY
	LD	A,(IY+#00)
	LD	(IX+#05),A
	JP	L_930A
;
L_93CE	INC	IY
	LD	E,(IY+#00)
	LD	A,#0B
	CALL	#0093
	INC	IY
	LD	E,(IY+#00)
	INC	A
	CALL	#0093
	JP	L_930A
;
L_93E4	SUB	#D0
	LD	(IX+#08),A
	LD	E,A
	LD	A,#0D
	CALL	#0093
	LD	E,#10
	LD	A,C
	CALL	#0093
	JP	L_930A
;
L_93F8	INC	IY
	LD	A,B
	LD	E,(IY+#00)
	CALL	#0093
	INC	A
	INC	IY
	LD	E,(IY+#00)
	CALL	#0093
	JP	L_934A
;
L_940D	INC	IY
	LD	A,B
	LD	E,(IY+#00)
	CALL	#0093
	INC	A
	INC	IY
	LD	E,(IY+#00)
	CALL	#0093
	JP	L_9380
;
L_9422	INC	IY
	LD	E,(IY+#00)
	LD	A,#06
	CALL	#0093
	JP	L_930A
;
L_942F	LD	A,D
	BIT	3,A
	JR	NZ,L_9448
	CPL
	RLCA
	RLCA
	RLCA
L_9438	LD	E,A
	LD	A,#07
	CALL	#0096
	AND	E
L_943F	LD	E,A
	LD	A,#07
	CALL	#0093
	JP	L_930A
;
L_9448	LD	A,#C7
	JR	L_9438
;
L_944C	LD	A,D
	BIT	3,A
	JR	NZ,L_945E
	RLCA
	RLCA
	RLCA
L_9454	LD	E,A
	LD	A,#07
	CALL	#0096
	OR	E
	JP	L_943F
;
L_945E	LD	A,#38
	JR	L_9454
;
L_9462	INC	IY
	LD	A,(IY+#00)
	LD	(IX+#06),A
	JP	L_930A
;
L_946D	PUSH	DE
	INC	IY
	LD	A,(IY+#00)
	OR	A
	JP	NZ,L_9478
	DEC	A
L_9478	LD	L,(IX+#02)
	LD	H,(IX+#03)
	INC	IY
	PUSH	IY
	POP	DE
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	(HL),A
	LD	(IX+#02),L
	LD	(IX+#03),H
	POP	DE
	JP	L_930C
;
L_9493	LD	L,(IX+#02)
	LD	H,(IX+#03)
	LD	A,(HL)
	OR	A
	JP	Z,L_94B0
	CP	#FF
	JP	Z,L_94A4
	DEC	A
L_94A4	LD	(HL),A
	DEC	HL
	LD	A,(HL)
	DEC	HL
	LD	L,(HL)
	LD	H,A
	PUSH	HL
	POP	IY
	JP	L_930C
;
L_94B0	DEC	HL
	DEC	HL
	DEC	HL
	LD	(IX+#02),L
	LD	(IX+#03),H
	JP	L_930A
;
L_94BC	PUSH	DE
	LD	L,(IX+#02)
	LD	H,(IX+#03)
	PUSH	IY
	POP	DE
	INC	DE
	INC	DE
	INC	DE
	INC	HL
	LD	(HL),E
	INC	HL
	LD	(HL),D
	LD	(IX+#02),L
	LD	(IX+#03),H
	LD	L,(IY+#01)
	LD	H,(IY+#02)
	PUSH	HL
	POP	IY
	POP	DE
	JP	L_930C
;
L_94E0	PUSH	DE
	LD	L,(IX+#02)
	LD	H,(IX+#03)
	LD	D,(HL)
	DEC	HL
	LD	E,(HL)
	DEC	HL
	LD	(IX+#02),L
	LD	(IX+#03),H
	PUSH	DE
	POP	IY
	POP	DE
	JP	L_930C
;
L_94F8	JP	L_930A
;
L_94FB	PUSH	BC
	LD	BC,#000C
L_94FF	CP	C
	JP	C,L_9507
	SUB	C
	INC	B
	JR	L_94FF
;
L_9507	LD	HL,L_954C
	SLA	A
	ADD	A,L
	LD	L,A
	LD	A,#00
	ADC	A,H
	LD	H,A
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	LD	A,B
	LD	C,#00
L_9519	OR	A
	JR	Z,L_9525
	RR	H
	RR	L
	RR	C
	DEC	A
	JR	L_9519
;
L_9525	BIT	7,C
	JR	Z,L_952A
	INC	HL
L_952A	POP	BC
	RET
;
       DB       #08,#3E,#07,#CD,#96,#00,#B2,#5F       ;.>.M..2_
       DB       #3E,#07,#CD,#93,#00,#08,#08,#7A       ;>.M....z
       DB       #2F,#5F,#3E,#07,#CD,#96,#00,#A3       ;/_>.M..#
       DB       #5F,#3E,#07,#CD,#93,#00,#08,#C9       ;_>.M...I
;
L_954C       DB       #5D,#0D,#9C,#0C,#E7,#0B,#3C,#0B
       DB       #9B,#0A,#02,#0A,#73,#09,#EB,#08
       DB       #6B,#08,#F2,#07,#80,#07,#14,#07
L_9564       DB       #EA,#07,#CE,#EB,#00,#EB,#03,#E2
       DB       #01,#30,#E1,#01,#30,#E1,#01,#34
       DB       #E1,#01,#34,#E1,#01,#35,#E1,#01
       DB       #35,#E1,#01,#36,#E1,#01,#37,#E1
       DB       #01,#EC,#EB,#01,#E2,#02,#2B,#E2
       DB       #01,#2B,#E1,#01,#E2,#02,#2B,#E2
       DB       #01,#2B,#2D,#E2,#01,#2F,#32,#E2
       DB       #02,#34,#32,#34,#E2,#02,#32,#E2
       DB       #01,#32,#E1,#01,#E2,#04,#32,#E2
       DB       #01,#34,#32,#E2,#02,#34,#37,#34
       DB       #EC,#E2,#02,#2B,#E2,#01,#2B,#E1
       DB       #01,#E2,#02,#2B,#E2,#01,#2B,#2D
       DB       #E2,#01,#2F,#32,#E2,#02,#34,#32
       DB       #34,#EC,#EF
L_95CF       DB       #EA,#07,#CE,#EB,#00,#EB,#03,#E2
       DB       #02,#13,#E2,#01,#13,#E1,#01,#E2
       DB       #04,#13,#E2,#01,#0B,#E1,#01,#0B
       DB       #E1,#01,#0C,#E1,#01,#0E,#E1,#01
       DB       #EC,#EC,#EF
L_95F2       DB       #EA,#07,#CE,#EB,#00,#EB,#03,#E2
       DB       #02,#2B,#E2,#01,#2B,#E1,#01,#E2
       DB       #04,#2B,#E2,#04,#29,#E2,#02,#28
       DB       #26,#EC,#EC,#EF
L_960E       DB       #EA,#06,#CE,#EB,#00,#E2,#01,#18
       DB       #E1,#01,#18,#E1,#01,#1A,#E1,#01
       DB       #1A,#E1,#01,#1C,#E1,#01,#1C,#E1
       DB       #01,#1D,#E1,#01,#E2,#02,#18,#E2
       DB       #01,#18,#E1,#01,#E2,#01,#18,#E1
       DB       #01,#1A,#E1,#01,#1A,#E1,#01,#1C
       DB       #E1,#01,#1C,#E1,#01,#1D,#E1,#01
       DB       #E2,#02,#13,#E2,#02,#13,#E2,#01
       DB       #13,#E1,#01,#15,#E1,#01,#15,#E1
       DB       #01,#17,#E1,#01,#17,#E1,#01,#18
       DB       #E1,#01,#E2,#02,#13,#E2,#02,#13
       DB       #E2,#01,#13,#E1,#01,#15,#E1,#01
       DB       #15,#E1,#01,#17,#E1,#01,#17,#E1
       DB       #01,#18,#E1,#01,#E2,#02,#18,#EC
       DB       #EF
L_967F       DB       #EA,#06,#CE,#EB,#00,#E2,#02,#30
       DB       #34,#37,#3C,#30,#34,#37,#3C,#E2
       DB       #02,#30,#34,#37,#3C,#30,#34,#37
       DB       #3C,#E2,#02,#2F,#32,#37,#32,#2F
       DB       #32,#37,#3B,#E2,#02,#2F,#32,#37
       DB       #32,#2F,#32,#37,#3B,#EC,#EF
L_96AE       DB       #EA,#06,#D0,#E4,#88,#13,#EB,#00
       DB       #E2,#02,#24,#26,#28,#29,#2B,#29
       DB       #28,#26,#E2,#04,#28,#29,#2B,#E2
       DB       #02,#2B,#1F,#E2,#02,#1F,#21,#23
       DB       #24,#26,#24,#23,#21,#E2,#04,#23
       DB       #24,#26,#E2,#02,#26,#24,#EC,#EF
L_96DE       DB       #EA,#03,#CF,#E2,#01,#48,#3C,#48
       DB       #43,#48,#EF
L_96E9       DB       #EA,#03,#CF,#E2,#01,#27,#2C,#31
       DB       #36,#3B,#40,#45,#4A,#4F,#54,#59
       DB       #5E,#EF
L_96FB       DB       #EA,#03,#CF,#E2,#02,#45,#4A,#EF
L_9703       DB       #FF,#7F,#FF,#7F,#FF,#7F,#FF,#7F
       DB       #EA,#C0,#D5,#C0,#DA,#C0,#D5,#C0
       DB       #FF,#FF,#55,#00,#AA,#00,#55,#00
       DB       #FF,#FF,#FD,#F0,#EA,#C0,#D5,#C0
       DB       #FF,#FF,#7F,#1F,#AF,#01,#55,#00
       DB       #FF,#FF,#FE,#F8,#EA,#C0,#D5,#C0
       DB       #CA,#C0,#D5,#C0,#EA,#E0,#FD,#FE
       DB       #AA,#00,#55,#00,#AA,#00,#55,#00
       DB       #0F,#17,#0F,#17,#0F,#17,#0F,#17
       DB       #17,#0F,#17,#0F,#17,#0F,#17,#0F
       DB       #00,#00,#00,#55,#AA,#FF,#FF,#FF
       DB       #C0,#80,#00,#AA,#55,#FF,#FF,#FF
       DB       #00,#00,#00,#AA,#55,#FF,#FF,#FF
       DB       #D7,#8F,#17,#0F,#17,#0F,#17,#0F
       DB       #0F,#17,#2F,#57,#AF,#FE,#FC,#F8
       DB       #17,#0B,#15,#6A,#75,#7F,#3F,#1F
       DB       #07,#03,#01,#A0,#51,#AB,#D7,#EF
       DB       #E0,#C0,#80,#05,#0A,#15,#0B,#17
       DB       #FF,#FF,#F7,#EF,#D7,#8F,#17,#0F
       DB       #FF,#FF,#FF,#F7,#CF,#97,#0F,#17
       DB       #FC,#F8,#F0,#FA,#F5,#FF,#FF,#FF
       DB       #FC,#F8,#F0,#F5,#FA,#FF,#FF,#FF
       DB       #C0,#C0,#C0,#C0,#C0,#C0,#C0,#C0
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #C0,#C0,#C0,#C0,#C0,#C0,#C0,#80
       DB       #FF,#FF,#00,#00,#00,#00,#00,#00
       DB       #FF,#FE,#00,#00,#00,#00,#00,#00
       DB       #0F,#07,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#80,#C0,#C0,#C0
       DB       #FF,#FF,#F8,#F0,#E0,#C0,#C0,#C0
       DB       #FF,#FE,#55,#00,#AA,#00,#55,#00
       DB       #EA,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #AA,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #FF,#FF,#00,#01,#00,#01,#00,#01
       DB       #00,#01,#00,#01,#00,#01,#00,#01
       DB       #FF,#FF,#FF,#7F,#FF,#7F,#FF,#7F
       DB       #0F,#17,#2F,#57,#AF,#FE,#FC,#F8
       DB       #17,#0B,#15,#6A,#F5,#7F,#3F,#1F
       DB       #07,#03,#01,#A0,#51,#AB,#D7,#EF
       DB       #E0,#C0,#80,#05,#0A,#15,#0B,#17
       DB       #00,#00,#00,#55,#AA,#FF,#FF,#FF
       DB       #0F,#17,#0F,#17,#0F,#17,#0F,#17
       DB       #00,#00,#00,#AA,#55,#FF,#FF,#FF
       DB       #17,#0F,#17,#0F,#17,#0F,#17,#0F
       DB       #EA,#C0,#D5,#C0,#EA,#C0,#D5,#80
       DB       #AF,#07,#55,#00,#AA,#00,#55,#00
       DB       #AA,#00,#55,#00,#AA,#C0,#D5,#C0
       DB       #00,#80,#C0,#F0,#F8,#FE,#FC,#F0
       DB       #C0,#80,#80,#80,#80,#80,#80,#80
       DB       #7F,#3F,#1F,#0F,#07,#03,#01,#00
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #FF,#FE,#FC,#F8,#F0,#E0,#C0,#80
       DB       #FF,#82,#C2,#E2,#F2,#F2,#F2,#F2
       DB       #2A,#80,#D5,#E0,#EA,#E0,#F5,#E0
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #F2,#F2,#F2,#F2,#F2,#F2,#F2,#F2
       DB       #EA,#E0,#F5,#E0,#EA,#E0,#F5,#E0
       DB       #FE,#FC,#F8,#F0,#E0,#C0,#80,#00
       DB       #FF,#7F,#3F,#1F,#0F,#07,#03,#01
       DB       #3E,#0E,#11,#13,#10,#09,#06,#00
       DB       #7C,#18,#24,#04,#18,#12,#0C,#00
       DB       #FF,#FF,#BF,#BF,#B8,#B8,#80,#FF
       DB       #FF,#07,#07,#07,#00,#00,#20,#B0
       DB       #03,#03,#03,#FF,#00,#00,#00,#00
       DB       #FF,#FF,#E0,#E0,#1F,#00,#00,#00
       DB       #F2,#F2,#F2,#F2,#02,#02,#02,#02
       DB       #7F,#3F,#5F,#00,#AA,#00,#55,#00
       DB       #B8,#B9,#BA,#BA,#B8,#B9,#FF,#3F
       DB       #FF,#00,#1F,#1F,#1F,#0F,#FF,#C3
       DB       #07,#18,#23,#24,#33,#38,#3F,#38
       DB       #38,#39,#38,#38,#39,#19,#0F,#03
       DB       #E0,#18,#C4,#24,#CC,#14,#F4,#1C
       DB       #14,#F4,#34,#34,#FC,#F8,#F0,#C0
       DB       #0E,#13,#50,#0F,#21,#87,#1D,#30
       DB       #25,#65,#60,#7D,#45,#60,#3D,#1F
       DB       #98,#6C,#DC,#31,#C4,#E0,#B8,#0D
       DB       #A4,#BE,#02,#B2,#B2,#06,#BC,#F8
       DB       #E0,#CF,#9F,#9F,#BF,#BB,#B3,#B3
       DB       #B2,#BE,#BF,#8F,#8B,#8A,#C5,#C0
       DB       #07,#F3,#F9,#F9,#FD,#DD,#CD,#CD
       DB       #4D,#7D,#FD,#F0,#D1,#51,#A3,#03
       DB       #00,#40,#78,#3F,#3F,#1F,#1F,#0F
       DB       #0F,#07,#04,#02,#02,#01,#01,#00
       DB       #00,#3C,#F8,#F8,#FC,#FC,#FC,#FE
       DB       #FE,#F8,#60,#00,#00,#00,#00,#80
       DB       #E0,#00,#00,#88,#C8,#D0,#E0,#C0
       DB       #02,#02,#02,#02,#02,#03,#01,#00
       DB       #E0,#C0,#80,#D5,#AA,#FF,#FF,#FF
       DB       #AA,#07,#58,#20,#20,#40,#42,#41
       DB       #00,#3E,#41,#41,#00,#41,#41,#3E
       DB       #00,#08,#08,#08,#00,#08,#08,#08
       DB       #00,#3E,#01,#01,#3E,#40,#40,#3E
       DB       #00,#3E,#01,#01,#3E,#01,#01,#3E
       DB       #00,#41,#41,#41,#3E,#01,#01,#01
       DB       #00,#3E,#40,#40,#3E,#01,#01,#3E
       DB       #00,#3E,#40,#40,#3E,#41,#41,#3E
       DB       #00,#3E,#01,#01,#00,#01,#01,#01
       DB       #00,#3E,#41,#41,#3E,#41,#41,#3E
       DB       #00,#3E,#41,#41,#3E,#01,#01,#3E
       DB       #00,#3E,#41,#41,#41,#7F,#41,#41
       DB       #00,#7E,#41,#41,#7E,#41,#41,#7E
       DB       #00,#3E,#41,#40,#40,#40,#41,#3E
       DB       #00,#7E,#41,#41,#41,#41,#41,#7E
       DB       #00,#7F,#40,#40,#7F,#40,#40,#7F
       DB       #00,#7F,#40,#40,#7E,#40,#40,#40
       DB       #00,#3E,#41,#40,#40,#4F,#41,#3E
       DB       #00,#41,#41,#41,#7F,#41,#41,#41
       DB       #00,#1C,#08,#08,#08,#08,#08,#1C
       DB       #00,#01,#01,#01,#01,#41,#41,#3E
       DB       #00,#41,#46,#58,#60,#58,#46,#41
       DB       #00,#40,#40,#40,#40,#40,#40,#7F
       DB       #00,#63,#63,#55,#49,#41,#41,#41
       DB       #00,#61,#51,#51,#49,#45,#45,#43
       DB       #00,#3E,#41,#41,#41,#41,#41,#3E
       DB       #00,#7E,#41,#41,#7E,#40,#40,#40
       DB       #00,#7E,#41,#41,#7E,#41,#41,#41
       DB       #00,#3E,#41,#40,#3E,#01,#41,#3E
       DB       #00,#7F,#08,#08,#08,#08,#08,#08
       DB       #00,#41,#41,#41,#41,#41,#41,#3E
       DB       #00,#41,#41,#22,#22,#14,#14,#08
       DB       #00,#41,#41,#49,#49,#49,#49,#36
       DB       #00,#41,#22,#14,#08,#14,#22,#41
       DB       #00,#41,#22,#14,#08,#08,#08,#08
       DB       #00,#7F,#02,#04,#08,#10,#20,#7F
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#7E,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#18,#18
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #FF,#80,#C0,#E0,#F0,#F8,#FC,#FE
       DB       #FF,#01,#03,#07,#0F,#1F,#3F,#7F
       DB       #7F,#3F,#1F,#0F,#07,#03,#01,#FF
       DB       #FE,#FC,#F8,#F0,#E0,#C0,#80,#FF
       DB       #FF,#00,#00,#00,#00,#00,#00,#FF
       DB       #7F,#7F,#7F,#7F,#7F,#7F,#7F,#7F
       DB       #FF,#00,#00,#00,#00,#00,#00,#FF
       DB       #FE,#FE,#FE,#FE,#FE,#FE,#FE,#FE
       DB       #AA,#80,#65,#10,#32,#04,#26,#54
       DB       #FF,#FF,#FF,#FF,#FF,#FF,#FF,#FF
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #01,#01,#01,#01,#01,#01,#01,#01
       DB       #03,#03,#03,#03,#03,#03,#03,#03
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #0F,#0F,#0F,#0F,#0F,#0F,#0F,#0F
       DB       #1F,#1F,#1F,#1F,#1F,#1F,#1F,#1F
       DB       #3F,#3F,#3F,#3F,#3F,#3F,#3F,#3F
       DB       #7F,#7F,#7F,#7F,#7F,#7F,#7F,#7F
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #42,#38,#1E,#8F,#2C,#94,#04,#FE
       DB       #89,#4C,#1C,#96,#F2,#2B,#91,#01
       DB       #20,#48,#99,#3C,#2C,#66,#C7,#03
       DB       #90,#22,#04,#3D,#7C,#E9,#8A,#50
       DB       #7C,#38,#9E,#47,#1E,#7C,#F0,#1E
       DB       #AA,#04,#71,#3F,#1A,#9A,#48,#8E
       DB       #55,#E2,#E5,#EA,#D4,#2F,#5F,#06
       DB       #14,#21,#7C,#3E,#43,#26,#38,#F1
       DB       #8C,#3C,#72,#B8,#46,#1C,#71,#FA
       DB       #18,#B1,#76,#7E,#0F,#43,#13,#A9
       DB       #3C,#0D,#5C,#7E,#7F,#C0,#92,#29
       DB       #62,#78,#BD,#0E,#7F,#C0,#69,#74
       DB       #0C,#C9,#1B,#96,#3C,#B2,#44,#11
       DB       #50,#CA,#66,#7A,#F3,#EB,#83,#2A
       DB       #A0,#2B,#73,#39,#AF,#87,#13,#41
       DB       #30,#59,#18,#CD,#76,#1E,#43,#11
       DB       #C0,#21,#6A,#1D,#A7,#07,#52,#00
       DB       #A6,#4F,#AE,#1F,#7E,#FE,#FE,#50
       DB       #AA,#03,#46,#19,#01,#10,#60,#20
       DB       #B6,#59,#00,#80,#81,#03,#00,#80
       DB       #AA,#E0,#15,#28,#48,#50,#38,#0E
       DB       #01,#20,#64,#42,#C4,#0C,#60,#13
       DB       #88,#19,#40,#C0,#02,#D2,#5F,#75
       DB       #8C,#80,#0F,#B8,#EF,#94,#74,#C8
       DB       #9C,#09,#4C,#03,#A9,#00,#55,#00
       DB       #8D,#3B,#CA,#35,#FF,#FF,#1F,#03
       DB       #1F,#50,#7F,#C1,#FE,#FC,#F1,#E0
       DB       #C0,#C7,#07,#07,#00,#FF,#7F,#3F
       DB       #03,#00,#0C,#0C,#00,#FE,#FC,#F8
       DB       #E0,#40,#20,#7C,#3E,#9F,#D5,#E0
       DB       #1F,#0F,#07,#03,#01,#00,#01,#03
       DB       #F0,#E0,#C0,#80,#00,#80,#C0,#E0
       DB       #EA,#E0,#F5,#E0,#F5,#E0,#EA,#E0
       DB       #07,#0F,#1F,#3F,#7F,#FF,#7F,#3F
       DB       #F0,#F8,#FC,#FE,#FF,#FF,#FF,#FF
       DB       #F5,#E0,#EA,#E0,#F5,#E0,#EA,#E0
L_9CD3       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#41,#41,#41
       DB       #4F,#4F,#4F,#4F,#4F,#4E,#4E,#4E
       DB       #EF,#EF,#EF,#4F,#4F,#4F,#4F,#4F
       DB       #EF,#EF,#EF,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #EE,#EE,#EE,#EE,#EE,#EE,#EE,#EE
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #4F,#4F,#4F,#4F,#4F,#43,#43,#43
       DB       #4F,#4F,#4F,#4F,#4F,#43,#43,#43
       DB       #3F,#3F,#3F,#4F,#4F,#4F,#4F,#4F
       DB       #3F,#3F,#3F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #01,#A0,#80,#80,#80,#80,#80,#80
       DB       #80,#A0,#A0,#A0,#A0,#A0,#A0,#A0
       DB       #F7,#F7,#F7,#F7,#F7,#F7,#F7,#F7
       DB       #F0,#F0,#F0,#F0,#F0,#F0,#F0,#F0
       DB       #F5,#F5,#F5,#F5,#F5,#F5,#F5,#F5
       DB       #10,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #70,#70,#70,#70,#70,#70,#70,#70
       DB       #50,#50,#50,#50,#50,#50,#50,#50
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #74,#74,#74,#74,#74,#74,#74,#74
       DB       #54,#54,#54,#54,#54,#54,#54,#54
       DB       #B4,#14,#14,#14,#14,#14,#14,#14
       DB       #B4,#14,#14,#14,#14,#14,#14,#14
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #10,#18,#1F,#18,#0E,#0E,#1E,#1E
       DB       #1C,#13,#13,#10,#0E,#0E,#0E,#0E
       DB       #10,#10,#1B,#1A,#B0,#0E,#0E,#0E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#40,#4F
       DB       #F0,#0E,#9E,#8E,#6E,#1E,#10,#10
       DB       #7E,#7E,#7E,#7E,#7E,#7E,#7E,#7E
       DB       #7E,#7E,#7E,#7E,#7E,#7E,#7E,#7E
       DB       #7E,#7E,#7E,#7E,#7E,#7E,#7E,#7E
       DB       #7E,#7E,#7E,#7E,#7E,#7E,#7E,#7E
       DB       #6E,#6E,#6E,#6E,#6E,#6E,#6E,#6E
       DB       #6E,#6E,#6E,#6E,#6E,#6E,#6E,#6E
       DB       #6E,#6E,#6E,#6E,#6E,#6E,#6E,#6E
       DB       #6E,#6E,#6E,#6E,#6E,#6E,#6E,#6E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #FE,#FE,#FE,#FE,#FE,#FE,#FE,#FE
       DB       #FE,#FE,#FE,#FE,#FE,#FE,#FE,#FE
       DB       #FE,#FE,#FE,#FE,#FE,#FE,#FE,#FE
       DB       #FE,#FE,#FE,#FE,#FE,#FE,#FE,#FE
       DB       #0E,#0E,#0E,#1E,#1E,#1E,#1E,#1E
       DB       #1E,#1E,#1E,#1E,#1E,#1E,#1E,#1E
       DB       #4F,#4F,#4F,#4F,#4F,#4F,#4F,#4F
       DB       #C3,#F3,#F3,#F3,#F3,#F3,#F3,#23
L_9FA3       DB       #10,#10,#10,#10,#10,#10,#10,#10
       DB       #F0,#54,#54,#54,#54,#54,#54,#54
       DB       #F0,#54,#54,#54,#54,#54,#54,#51
       DB       #51,#57,#57,#57,#57,#57,#57,#10
       DB       #51,#57,#57,#57,#57,#57,#57,#10
       DB       #F0,#04,#04,#04,#04,#04,#04,#10
       DB       #51,#51,#51,#51,#51,#51,#51,#51
       DB       #E0,#07,#07,#07,#07,#07,#07,#10
       DB       #51,#51,#51,#51,#51,#51,#51,#51
       DB       #C3,#F3,#C3,#C3,#C3,#C3,#C3,#13
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #B1,#B1,#B1,#B1,#B1,#B1,#B1,#B1
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #8F,#8F,#8F,#8F,#8F,#8F,#8F,#8F
       DB       #C3,#C3,#C3,#C3,#C3,#13,#C3,#03
       DB       #C3,#13,#C3,#13,#1C,#C3,#13,#C3
       DB       #C3,#F3,#F3,#F3,#83,#C3,#C3,#C3
       DB       #F3,#C3,#C3,#83,#83,#83,#83,#83
       DB       #C3,#F3,#C3,#C3,#C3,#C3,#C1,#C3
       DB       #83,#C3,#C3,#C3,#C3,#83,#C3,#C3
       DB       #8F,#83,#8F,#83,#83,#C3,#C3,#1C
       DB       #13,#83,#13,#C1,#18,#C1,#31,#31
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #1C,#13,#C3,#31,#10,#10,#13,#13
       DB       #13,#C1,#18,#C1,#13,#13,#1C,#13
       DB       #83,#83,#BC,#BC,#0C,#F8,#F8,#F8
       DB       #F3,#C3,#C3,#C3,#C3,#F6,#F6,#F6
       DB       #F3,#13,#13,#13,#13,#13,#C3,#13
       DB       #F8,#F8,#F8,#F8,#F8,#98,#98,#98
       DB       #F6,#F6,#F6,#F6,#F6,#96,#96,#96
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
       DB       #98,#98,#98,#98,#98,#C3,#C3,#C3
       DB       #96,#96,#96,#96,#96,#C3,#C3,#C3
       DB       #C3,#C3,#C3,#C3,#C3,#C3,#C3,#C3
L_A163       DB       #07,#1F,#37,#3F,#3F,#18,#1C,#0F
       DB       #0B,#1B,#1B,#3F,#3C,#3F,#1F,#07
       DB       #E0,#F8,#EC,#FC,#FC,#18,#38,#F0
       DB       #D0,#D8,#D8,#FC,#3C,#FC,#F8,#E0
       DB       #00,#00,#38,#7E,#7F,#78,#EF,#EF
       DB       #EF,#EF,#78,#7F,#7E,#38,#00,#00
       DB       #00,#00,#1C,#7E,#FA,#DF,#9F,#9F
       DB       #9F,#9F,#DF,#FA,#7E,#1C,#00,#00
       DB       #07,#1F,#3F,#3C,#3F,#1B,#1B,#0B
       DB       #0F,#1C,#18,#3F,#3F,#37,#1F,#07
       DB       #E0,#F8,#FC,#3C,#FC,#D8,#D8,#D0
       DB       #F0,#38,#18,#FC,#FC,#EC,#F8,#E0
       DB       #00,#00,#38,#7E,#5F,#FB,#F9,#F9
       DB       #F9,#F9,#FB,#5F,#7E,#38,#00,#00
       DB       #00,#00,#1C,#7E,#FE,#1F,#F7,#F7
       DB       #F7,#F7,#1F,#FE,#7E,#1C,#00,#00
       DB       #FF,#7F,#08,#FF,#27,#17,#CF,#7F
       DB       #E7,#6C,#EE,#66,#FF,#67,#CF,#0F
       DB       #FF,#FE,#10,#FF,#E4,#E8,#F3,#FE
       DB       #67,#76,#37,#E6,#FF,#E6,#F3,#F0
       DB       #55,#7F,#3F,#10,#D6,#FF,#FD,#F1
       DB       #F8,#FB,#FF,#D6,#10,#3F,#7F,#55
       DB       #49,#CB,#9B,#AB,#CF,#FB,#FB,#FB
       DB       #FB,#FB,#FB,#CF,#AB,#9B,#CB,#49
       DB       #0F,#CF,#67,#FF,#67,#EC,#6E,#E6
       DB       #7F,#CF,#17,#27,#FF,#08,#7F,#FF
       DB       #F0,#F3,#F6,#FF,#66,#77,#36,#E7
       DB       #FE,#F3,#E8,#E4,#FF,#10,#EE,#FF
       DB       #92,#D3,#D9,#D5,#F3,#DF,#DF,#DF
       DB       #DF,#DF,#DF,#F3,#D5,#D9,#D3,#92
       DB       #AA,#FE,#FC,#08,#6B,#FF,#DF,#1F
       DB       #8F,#BF,#FF,#6B,#08,#FC,#FE,#AA
       DB       #12,#52,#92,#9E,#CC,#FF,#FF,#FE
       DB       #0D,#44,#A6,#6E,#BF,#6F,#A3,#41
       DB       #48,#4A,#49,#79,#33,#FF,#FF,#7F
       DB       #30,#A2,#65,#76,#FD,#F6,#C5,#82
       DB       #54,#AA,#7C,#10,#39,#3F,#7C,#F1
       DB       #F2,#7C,#3F,#31,#10,#7C,#AA,#54
       DB       #FC,#F2,#E0,#EF,#F8,#F8,#EF,#60
       DB       #60,#EF,#F8,#F8,#EF,#E0,#F2,#FC
       DB       #41,#A3,#6F,#BF,#6E,#A6,#45,#0C
       DB       #FE,#FF,#FF,#CC,#9E,#92,#52,#12
       DB       #82,#C5,#F6,#FD,#76,#65,#22,#B0
       DB       #7F,#FF,#FF,#33,#79,#49,#4A,#48
       DB       #3F,#4F,#07,#F7,#1F,#1F,#F7,#06
       DB       #06,#F7,#1F,#1F,#F7,#07,#4F,#3F
       DB       #2A,#55,#3E,#08,#9C,#FC,#3E,#4F
       DB       #8F,#3E,#FC,#9C,#08,#3E,#55,#2A
       DB       #4A,#EB,#EF,#FF,#EF,#4E,#0C,#1C
       DB       #1F,#7F,#7F,#EF,#FF,#E7,#E2,#42
       DB       #52,#D7,#F7,#FF,#F7,#72,#30,#38
       DB       #F0,#FE,#FE,#F7,#FF,#E7,#47,#42
       DB       #78,#FE,#7E,#17,#1F,#3F,#FF,#3F
       DB       #3F,#FF,#3F,#1F,#17,#7E,#FE,#78
       DB       #1E,#3F,#1E,#88,#FF,#FC,#3F,#1E
       DB       #1E,#3F,#FC,#FF,#88,#1E,#3F,#1E
       DB       #42,#E2,#E7,#FF,#EF,#7F,#7F,#1F
       DB       #1C,#0C,#4E,#EF,#FF,#EF,#EB,#4A
       DB       #42,#47,#E7,#FF,#F7,#FE,#FE,#F8
       DB       #38,#30,#72,#F7,#FF,#F7,#D7,#52
       DB       #78,#FC,#78,#11,#FF,#3F,#FC,#78
       DB       #78,#FC,#3F,#FF,#11,#78,#FC,#78
       DB       #1E,#7F,#7E,#E8,#F8,#FC,#FF,#FC
       DB       #FC,#FF,#FC,#F8,#E8,#7E,#7F,#1E
       DB       #E0,#E0,#E0,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #E0,#E0,#E0,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
       DB       #00,#00,#00,#00,#00,#00,#00,#00
L_A3A3       DB       #FF,#08,#34,#01,#FF,#17,#21,#01
       DB       #FF,#2F,#09,#01,#FF,#4F,#37,#01
       DB       #FF,#56,#29,#01,#FF,#37,#31,#01
       DB       #FF,#0F,#29,#00,#FF,#08,#45,#00
       DB       #FF,#47,#21,#00,#FF,#55,#09,#00
       DB       #FF,#3F,#29,#02,#FF,#2F,#45,#02
       DB       #00,#37,#21,#0F,#19,#5D,#37,#1F
       DB       #29,#22,#45,#FF,#0F,#29,#02,#FF
       DB       #4F,#29,#02,#FF,#2F,#21,#01,#FF
       DB       #5D,#29,#01,#FF,#56,#21,#01,#FF
       DB       #5D,#19,#01,#FF,#56,#21,#01,#FF
       DB       #37,#11,#00,#FF,#3F,#21,#00,#FF
       DB       #2F,#37,#00,#FF,#47,#31,#00,#FF
       DB       #16,#21,#00,#00,#0F,#09,#5D,#45
       DB       #1F,#19,#4F,#3F,#0F,#19,#FF,#22
       DB       #45,#02,#FF,#37,#21,#02,#FF,#17
       DB       #21,#01,#FF,#2F,#37,#01,#FF,#08
       DB       #45,#01,#FF,#4F,#37,#01,#FF,#55
       DB       #09,#01,#FF,#5D,#19,#01,#FF,#2F
       DB       #21,#00,#FF,#37,#11,#00,#FF,#4F
       DB       #29,#00,#FF,#5D,#29,#00,#00,#08
       DB       #45,#2F,#45,#37,#31,#0F,#09,#5D
       DB       #45,#FF,#2F,#21,#02,#FF,#1F,#29
       DB       #02,#FF,#0F,#09,#01,#FF,#2F,#09
       DB       #01,#FF,#2F,#37,#01,#FF,#3F,#29
       DB       #01,#FF,#4F,#29,#01,#FF,#0F,#29
       DB       #00,#FF,#2F,#45,#00,#FF,#37,#31
       DB       #00,#FF,#3F,#21,#00,#FF,#5D,#37
       DB       #00,#00,#5D,#09,#1F,#19,#4F,#37
       DB       #17,#21,#37,#21,#FF,#37,#21,#02
       DB       #FF,#17,#21,#02,#FF,#08,#34,#01
       DB       #FF,#1F,#29,#01,#FF,#22,#45,#01
       DB       #FF,#2E,#09,#01,#FF,#4F,#3F,#01
       DB       #FF,#0F,#09,#00,#FF,#1F,#19,#00
       DB       #FF,#2F,#29,#00,#FF,#37,#31,#00
       DB       #FF,#5D,#29,#00,#00,#2F,#09,#2F
       DB       #45,#55,#09,#0F,#29,#47,#21
L_A4CA       DB       #11,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#10
       DB       #08,#1D,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#0D
       DB       #08,#16,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#09
       DB       #08,#16,#17,#11,#0A,#0A,#0A,#0A
       DB       #0A,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0C,#10,#1C,#17,#11
       DB       #0A,#0A,#0C,#0C,#10,#1C,#17,#09
       DB       #08,#16,#17,#08,#03,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#0D,#16,#17,#08
       DB       #03,#02,#02,#02,#0D,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#08,#01,#07,#09,#16,#17,#08
       DB       #01,#59,#8B,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#08,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#A7,#A6,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#A7,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#08,#16,#17,#09
       DB       #01,#A6,#A7,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#08,#16,#17,#09
       DB       #01,#07,#07,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#0F,#0B,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#08,#01,#07,#07,#07,#27,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0A,#0E,#18,#17,#0F
       DB       #0B,#0C,#0A,#0A,#0E,#18,#17,#09
       DB       #08,#16,#17,#1B,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#08,#01,#07,#07,#07,#08,#1D
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#1A,#17,#17,#1B
       DB       #19,#19,#19,#19,#1A,#17,#17,#09
       DB       #08,#16,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#16
       DB       #17,#08,#00,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#09
       DB       #08,#16,#17,#11,#0A,#0A,#0A,#0A
       DB       #0A,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#09,#16
       DB       #17,#08,#15,#0A,#0A,#0A,#0A,#0C
       DB       #0C,#0C,#0C,#0C,#10,#1C,#17,#09
       DB       #08,#16,#17,#08,#03,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#05,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#09,#16
       DB       #17,#08,#05,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#0D,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#A8,#A9,#AA,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#B1
       DB       #B2,#B3,#07,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#A8,#A9,#AA,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#AB,#AC,#AD,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#B4
       DB       #B5,#B6,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#AB,#AC,#AD,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#AE,#AF,#B0,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#B7
       DB       #B8,#B9,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#AE,#AF,#B0,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#27,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#26,#2E,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#1D
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#0D,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#16
       DB       #17,#08,#00,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#07,#31,#32
       DB       #32,#33,#34,#35,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#09,#16
       DB       #17,#08,#15,#0A,#0A,#0A,#0A,#0A
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#31,#32,#32,#33
       DB       #34,#35,#07,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#08,#01,#07,#36,#31
       DB       #33,#37,#38,#39,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#09,#16
       DB       #17,#08,#05,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#36,#31,#33,#37
       DB       #38,#39,#07,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#36,#3A
       DB       #3B,#37,#38,#39,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#36,#3A,#3B,#37
       DB       #38,#39,#07,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#3A,#3C
       DB       #3D,#3B,#38,#39,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#3A,#3C,#3D,#3B
       DB       #38,#39,#07,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#3E,#3F
       DB       #40,#41,#42,#39,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#59,#8B,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#3E,#3F,#40,#41
       DB       #42,#39,#07,#07,#08,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#43,#44
       DB       #45,#56,#57,#58,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0A,#0E,#18
       DB       #17,#08,#01,#A6,#A7,#07,#27,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#26,#2E,#A6,#A7,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#43,#44,#45,#56
       DB       #57,#58,#0A,#0A,#0E,#18,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #1D,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#08,#01,#59,#8B,#07,#08,#1D
       DB       #19,#19,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#19,#19
       DB       #19,#0D,#01,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#1D,#19
       DB       #19,#19,#19,#19,#1A,#17,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#08,#16
       DB       #17,#09,#00,#17,#17,#17,#17,#17
       DB       #17,#08,#01,#A6,#A7,#07,#08,#16
       DB       #17,#17,#17,#17,#17,#17,#08,#16
       DB       #17,#09,#00,#17,#17,#17,#17,#17
       DB       #17,#09,#01,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#11,#0A,#0A,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#08,#16
       DB       #17,#09,#15,#0A,#0C,#0C,#10,#1C
       DB       #17,#08,#01,#59,#8B,#07,#08,#16
       DB       #17,#11,#0A,#0A,#0C,#0C,#08,#16
       DB       #17,#09,#15,#0A,#0C,#0C,#10,#1C
       DB       #17,#09,#01,#59,#8B,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #11,#0A,#0A,#0C,#10,#1C,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#08,#03,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#08,#16
       DB       #17,#09,#05,#02,#02,#02,#0D,#16
       DB       #17,#08,#01,#A6,#A7,#07,#08,#16
       DB       #17,#08,#03,#02,#02,#02,#08,#16
       DB       #17,#09,#05,#02,#02,#02,#0D,#16
       DB       #17,#09,#01,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #08,#03,#02,#02,#0D,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#08,#01,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#59,#8B,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #08,#01,#07,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#08,#01,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #08,#01,#07,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#08,#01,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#08,#16,#17
       DB       #08,#01,#07,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#0F,#0B,#0C,#0A,#0A
       DB       #2A,#0A,#0A,#0A,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0A,#0A,#2A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0E,#18,#17
       DB       #08,#01,#07,#07,#09,#16,#17,#09
       DB       #08,#16,#17,#1B,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#1A,#17,#17
       DB       #08,#01,#07,#07,#09,#16,#17,#09
       DB       #09,#16,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#08,#16
       DB       #17,#09,#00,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#16
       DB       #17,#09,#00,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#08,#16
       DB       #17,#09,#00,#17,#17,#17,#17,#17
       DB       #09,#01,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#11,#0A,#0C,#0C,#0C
       DB       #28,#0C,#0C,#0C,#0C,#0C,#08,#16
       DB       #17,#09,#15,#0A,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#0C,#28
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#09,#16
       DB       #17,#09,#15,#0A,#0A,#0A,#0A,#0A
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#08,#16
       DB       #17,#09,#15,#0A,#0C,#10,#1C,#17
       DB       #09,#01,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#08,#03,#02,#04,#12
       DB       #1F,#20,#13,#05,#02,#02,#08,#16
       DB       #17,#09,#05,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#04,#12,#1F
       DB       #20,#13,#05,#02,#02,#02,#09,#16
       DB       #17,#09,#05,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#08,#16
       DB       #17,#09,#05,#02,#02,#0D,#16,#17
       DB       #09,#01,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#08,#01,#59,#8B,#09
       DB       #16,#17,#08,#01,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#B1,#B2,#B3,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#09,#16,#17
       DB       #09,#01,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#08,#01,#A6,#A7,#09
       DB       #16,#17,#09,#01,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#A6,#A7,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#B4,#B5,#B6,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #09,#01,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#08,#01,#59,#8B,#09
       DB       #16,#17,#09,#01,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#59,#8B,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#B7,#B8,#B9,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#08,#16,#17
       DB       #09,#01,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#08,#01,#A6,#A7,#09
       DB       #16,#17,#0F,#0B,#0C,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0A,#0E,#18
       DB       #17,#08,#01,#A6,#A7,#07,#09,#16
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#2A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#08,#16
       DB       #17,#09,#14,#0C,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0A,#0E,#18,#17
       DB       #0F,#0B,#0C,#0A,#0E,#18,#17,#08
       DB       #09,#16,#17,#08,#01,#59,#8B,#09
       DB       #16,#17,#1B,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#08,#01,#59,#8B,#07,#09,#16
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#1A,#17,#17
       DB       #1B,#19,#19,#19,#1A,#17,#17,#08
       DB       #09,#16,#17,#09,#01,#A6,#A7,#08
       DB       #16,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#16
       DB       #17,#09,#00,#17,#17,#17,#17,#17
       DB       #17,#09,#01,#A6,#A7,#07,#09,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#08,#16
       DB       #17,#08,#00,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#08
       DB       #09,#16,#17,#09,#01,#59,#8B,#08
       DB       #16,#17,#11,#0A,#0A,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#09,#16
       DB       #17,#09,#15,#0A,#0C,#0C,#10,#1C
       DB       #17,#09,#01,#59,#8B,#07,#25,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0C,#0C,#28
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#08,#16
       DB       #17,#08,#15,#0A,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0C
       DB       #0C,#0C,#0C,#0C,#10,#1C,#17,#08
       DB       #09,#16,#17,#09,#01,#A6,#A7,#08
       DB       #16,#17,#08,#03,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#09,#16
       DB       #17,#09,#05,#02,#02,#02,#0D,#16
       DB       #17,#09,#01,#A6,#A7,#07,#2D,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#04,#12,#1F
       DB       #20,#13,#05,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#08,#16
       DB       #17,#08,#05,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#0D,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#59,#8B,#08
       DB       #16,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#59,#8B,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#A6,#A7,#08
       DB       #16,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#A6,#A7,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#59,#8B,#08
       DB       #16,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#06,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#A6,#A7,#08
       DB       #16,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#08,#16
       DB       #17,#09,#14,#0C,#0C,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#08,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#59,#8B,#08
       DB       #16,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#29,#16
       DB       #17,#2B,#23,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#A6,#A7,#08
       DB       #16,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#08,#16
       DB       #17,#08,#00,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#08,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#0F,#0B,#0C,#0A,#0E
       DB       #18,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#25,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#08,#16
       DB       #17,#08,#15,#0A,#0A,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#24,#2C,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#59,#8B,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#1B,#19,#19,#19,#1A
       DB       #17,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#2D,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#08,#16
       DB       #17,#08,#05,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#1E,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#A6,#A7,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#11,#0A,#0A,#0C,#10
       DB       #1C,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#0F,#0B,#0C,#0A,#0A,#0A,#2A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0A
       DB       #0A,#0A,#0A,#0A,#0E,#18,#17,#08
       DB       #09,#16,#17,#08,#03,#02,#02,#0D
       DB       #16,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#09,#01,#A8,#A9,#AA,#09,#16
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#08,#01,#07,#07,#07,#09,#16
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#1A,#17,#17,#08
       DB       #09,#16,#17,#08,#01,#07,#07,#09
       DB       #16,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#09,#01,#AB,#AC,#AD,#09,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#09,#01,#07,#07,#07,#09,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#08
       DB       #09,#16,#17,#08,#01,#07,#07,#09
       DB       #16,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#09,#01,#AE,#AF,#B0,#25,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#09,#01,#07,#07,#07,#25,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#28
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#10,#1C
       DB       #17,#11,#0A,#0A,#0A,#0A,#0A,#0C
       DB       #0C,#0C,#0C,#0C,#10,#1C,#17,#08
       DB       #09,#16,#17,#08,#01,#07,#07,#09
       DB       #16,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#2D,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#09,#01,#07,#07,#07,#2D,#02
       DB       #02,#02,#02,#02,#02,#04,#12,#1F
       DB       #20,#13,#05,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#0D,#16
       DB       #17,#08,#03,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#0D,#16,#17,#08
       DB       #09,#16,#17,#08,#01,#07,#07,#09
       DB       #16,#17,#08,#01,#59,#8B,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#B1,#B2
       DB       #B3,#07,#07,#07,#07,#07,#08,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #59,#8B,#59,#8B,#59,#8B,#09,#16
       DB       #17,#08,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#A8,#A9,#AA,#09,#16
       DB       #17,#08,#01,#07,#07,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#08,#01,#07,#07,#09
       DB       #16,#17,#08,#01,#A6,#A7,#09,#16
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#26,#2E,#B4,#B5
       DB       #B6,#27,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#0F,#0B,#0C,#0C,#0C,#26,#2E
       DB       #A6,#A7,#A6,#A7,#A6,#A7,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#AB,#AC,#AD,#08,#16
       DB       #17,#08,#01,#07,#07,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#59,#8B,#09,#16
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#0D,#01,#B7,#B8
       DB       #B9,#08,#1D,#19,#19,#19,#1A,#17
       DB       #17,#1B,#19,#19,#19,#19,#0D,#01
       DB       #59,#8B,#59,#8B,#59,#8B,#09,#16
       DB       #17,#09,#01,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#AE,#AF,#B0,#08,#16
       DB       #17,#08,#01,#07,#07,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#A6,#A7,#09,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#09,#01,#07,#07
       DB       #07,#08,#16,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#01
       DB       #A6,#A7,#A6,#A7,#A6,#A7,#09,#16
       DB       #17,#0F,#0B,#0C,#0C,#0C,#0C,#0C
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0E,#18
       DB       #17,#08,#01,#07,#07,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#09,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#59,#8B,#25,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#10,#1C,#17,#09,#01,#07,#07
       DB       #07,#08,#16,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#01
       DB       #59,#8B,#59,#8B,#59,#8B,#09,#16
       DB       #17,#1B,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#1A,#17
       DB       #17,#08,#01,#07,#07,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#A6,#A7,#2D,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#0D,#16,#17,#09,#01,#07,#07
       DB       #07,#08,#16,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#01
       DB       #A6,#A7,#A6,#A7,#A6,#A7,#09,#16
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#08,#01,#07,#07,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#59,#8B,#59,#8B
       DB       #59,#8B,#59,#8B,#59,#8B,#59,#8B
       DB       #59,#8B,#59,#8B,#59,#8B,#59,#8B
       DB       #07,#09,#16,#17,#09,#01,#07,#07
       DB       #07,#08,#16,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#01
       DB       #59,#8B,#59,#8B,#59,#8B,#25,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#24,#2C,#07,#07,#59,#8B,#59
       DB       #8B,#59,#8B,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#A6,#A7,#A6,#A7
       DB       #A6,#A7,#A6,#A7,#A6,#A7,#A6,#A7
       DB       #A6,#A7,#A6,#A7,#A6,#A7,#A6,#A7
       DB       #07,#08,#16,#17,#09,#01,#07,#07
       DB       #07,#08,#16,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#01
       DB       #A6,#A7,#A6,#A7,#A6,#A7,#2D,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#02,#02,#02,#02,#02,#02,#02
       DB       #02,#1E,#07,#07,#07,#A6,#A7,#A6
       DB       #A7,#A6,#A7,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#09,#01,#07,#07,#08
       DB       #16,#17,#09,#01,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#08,#16,#17,#09,#01,#07,#07
       DB       #07,#08,#16,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#09,#01
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#07,#07,#07,#07
       DB       #07,#07,#07,#07,#08,#16,#17,#08
       DB       #09,#16,#17,#0F,#0B,#0C,#0A,#0E
       DB       #18,#17,#0F,#0B,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0E,#16,#17,#0F,#0B,#0C,#0A
       DB       #0A,#0E,#18,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#0F,#0B
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0E,#18,#17,#08
       DB       #09,#16,#17,#1B,#19,#19,#19,#1A
       DB       #17,#17,#1B,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#1A,#17,#17,#1B,#19,#19,#19
       DB       #19,#1A,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#1B,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#19,#19,#19,#19
       DB       #19,#19,#19,#19,#1A,#17,#17,#08
       DB       #09,#16,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#17
       DB       #17,#17,#17,#17,#17,#17,#17,#08
       DB       #0F,#0B,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0C,#0C,#0C,#0C,#0C,#0C,#0C,#0C
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0A
       DB       #0A,#0A,#0A,#0A,#0A,#0A,#0A,#0E
       DB       #00,#FF,#00,#FF,#00,#FF,#FF,#00
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00
       DB       #FF,#00,#FF,#00,#FF,#00,#00,#FF
       DB       #00,#FF,#00,#FF,#00,#FF,#00,#FF
       DB       #00,#FF,#00,#FF,#00,#FF,#FF,#00
       DB       #FF,#00,#FF,#00,#FF,#00,#FF,#00
       DB       #FF,#00,#FF,#00,#FF,#00
;#C000
;
