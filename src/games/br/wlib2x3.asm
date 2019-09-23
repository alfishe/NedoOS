;выв спрайтов 3х2 с зеркальным отображением
A2_HER	DEFW #E000,#F4B0,#FA50 ;для 3х2
A2_WAR	DEFW #E3C0,#F870,#FE10
H3x2	EX AF,AF
	LD A,D
	CP 5
	JR C,iH320
	LD A,8
	SUB D
	LD D,A
iH320	EX AF,AF ;C/NC - не инв/инв
	CP #80
	JR C,H321
	CP #A0
	LD A,0
	JR C,H321
	LD A,D
	LD BC,A2_WAR-30
	JR H322
H321	LD BC,A2_HER-30
	AND 1
	ADD A,D
	ADD A,D
	LD D,A
H322	ADD A,A
	ADD A,D
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD A,E
	EX DE,HL
	LD L,C
	LD H,B
	LD BC,#1802
	CALL WT
	ADD HL,DE
	EX DE,HL
	EX AF,AF
	JR C,H320r
INV3x2	EX DE,HL ;инвертирование
	PUSH BC
	LD DE,48+invBUF
	LD BC,48
	PUSH BC
	LDIR
	POP BC
	LD DE,invBUF
	PUSH DE
	LDIR
	CALL MEM6 ;доступ к табл. инвертирования
	POP HL
	PUSH HL
	LD B,16
	LD D,#C3 ;адр таб инв/0
inVLOO	;цикл инвертирования
	LD E,(HL)
	LD A,(DE)
	LD (HL),A
	INC HL	 ;1
	LD E,(HL)
	LD A,(DE)
	LD (HL),A
	INC HL	 ;2
	LD E,(HL)
	LD A,(DE)
	LD (HL),A
	INC HL	 ;3
	LD E,(HL)
	LD A,(DE)
	LD (HL),A
	INC HL	 ;4
	LD E,(HL)
	LD A,(DE)
	LD (HL),A
	INC HL	 ;5
	LD E,(HL)
	LD A,(DE)
	LD (HL),A
	INC HL	 ;6
	DJNZ inVLOO
	POP DE
	POP BC
H320r	JP HeF1
