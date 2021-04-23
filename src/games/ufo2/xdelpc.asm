;Декомпрессор
;HL-откуда DE-куда
DLPCB	DEFS 4
DELPC	PUSH DE
	LD DE,DLPCB
	LD BC,4
	LDIR
	POP DE
xpD0	LD A,(HL)
	BIT 7,A
	JR NZ,xpD1
	PUSH AF
	AND 1
	LD B,A
	LD A,(HL)
	AND #E
	RRCA
	ADD A,3
	LD C,A
xpD0X	INC HL
	LD A,E
	SUB (HL)
	INC HL
	PUSH HL
	LD L,A
	LD A,D
	SBC A,B
	LD H,A
	LD B,0
	LDIR
D00     POP HL
	POP AF
	RLCA
	RLCA
	RLCA
	RLCA
	AND #F
	JR Z,xpD0
	JR xpDRR
xpD1    INC HL
	BIT 6,A
	JR NZ,xpD2
	AND #3F
	JR Z,xpDEND
xpDRR	LD C,A
xpDLO	RRC (HL)
	LDI
	JP PE,xpDLO
	JR xpD0
xpD2	AND #3F
	ADD A,4
	LD C,A
	LD A,(HL)
	PUSH AF
	AND #F
	LD B,A
	JR xpD0X
xpDEND	LD HL,DLPCB
	LD C,4
	LDIR
	RET
