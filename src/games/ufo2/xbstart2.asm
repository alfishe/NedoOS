;*Z80
	ORG	23845
ORGX
*D+

INIT	EQU 0;пересылка main блока НЛО2
DSCR	EQU #4000
SCR	EQU #C000
	DEFM " * UFO-2 Disk 2 *"
	DEFM " Wrote by Slava MEDNONOGOV *"
	DEFM " (c) 1996, COPPER FEET *"
	DEFM " (812) 143-3303 * "
;Декомпрессор
;HL-откуда DE-куда
COLOR	DEFB #42
DLPCB	DEFS 4,1
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
xpDLO	LD A,(HL) ;неразрушающий
	RRCA
	LD (DE),A
	INC DE
	INC HL
	DEC C
	JP NZ,xpDLO
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

WAIT	LD BC,#BFFE
	IN A,(C)
	RRA
	JR NC,DISK1
	LD B,33
WTR0	EI
	HALT
	DI
	DJNZ WTR0
	LD A,(COLOR)	
	XOR #4
	LD (COLOR),A
	LD HL,#5800
	LD DE,#5801
	LD (HL),A
	LD BC,777
	LDIR
	JR WAIT
DISK1	LD HL,0
	PUSH HL
	JP #3D2F

	DEFS	256+ORGX-$

	DEFW	S,S,S,S,S,S,S,S,S,S,S,S,S,S

WARN
*B ..\data\xdisk2.lpc
	ENT $
S
START   ;начало warning
	DI
	IM 1
	LD SP,#8000
	LD HL,#5B01
	LD DE,#5B00
	LD BC,7000
	XOR A
	OUT (254),A
	LD (HL),A
	LDDR
	LD HL,WARN+2
	LD DE,#4800
	CALL DELPC
	JP WAIT