;******** вспом п/п PAGE 4 ***** 256bt

;----ВЫБОР ГЕРОЕВ--------
outBOX	
        if 1==0
        CALL _TST#8
        endif
	LD A,(begBOX)
	OR A
	RET Z
	LD HL,(MX)
	LD A,L
	CP 190
	JR C,oB1
	LD L,190
oB1	LD DE,(BOXX)
	XOR A
	PUSH HL
	SBC HL,DE
	POP HL
	RET Z
	CALL STD
	PUSH DE
	LD E,L
	CALL vLINE
	POP DE
	PUSH DE
	LD D,H
	CALL hLINE
	POP DE
	CALL vLINE
	CALL hLINE
	LD HL,LMask
	RRC (HL)
	RET

hLINE	;гориз уч DE->L;
	LD A,(LMask)
	LD (LMask_),A
	LD A,L
	CP E
	RET Z
	PUSH HL
	PUSH DE
	JR NC,hL1
	LD L,E
	LD E,A
hL1	PUSH HL
	PUSH DE
	LD A,E
	AND #F8
	LD E,A
	LD A,L
	AND #F8
	SUB E
	CP #8
	JR C,hLA
	JR NZ,hLC
	LD B,0
	JR hLB
hLC	RRCA
	RRCA
	RRCA
	LD B,A
	DEC B
hLB	POP DE
	PUSH DE
	CALL PCOORD
	POP DE
	LD A,E
	AND 7
	LD DE,MLtab1
	ADD A,E
	LD E,A
	LD A,(DE)
	CALL pMASK ;A-маска;HL-коорд
	LD A,B
	OR A
	JR Z,hLC1
hLC0	LD A,#FF
	CALL pMASK
	DJNZ hLC0
hLC1	POP DE
	LD A,E
	AND 7
	LD DE,MLtab2
	ADD A,E
	LD E,A
	LD A,(DE)
	JR hLA1
hLA	POP DE
	PUSH DE
	CALL PCOORD
	POP DE
	LD A,E
	AND 7
	LD DE,MLtab1
	ADD A,E
	LD E,A
	LD A,(DE)
	LD C,A
	POP DE
	LD A,E
	AND 7
	LD DE,MLtab2
	ADD A,E
	LD E,A
	LD A,(DE)
	AND C
hLA1	CALL pMASK
	POP DE
	POP HL
	RET

pMASK	;выв байта LMask по маске А в (HL)
	LD C,A
	OR (HL)
	LD (HL),A
	LD A,(LMask_)
	AND C
	XOR (HL)
	LD (HL),A
	INC L
	RET

pvMASK	LD A,C
	OR (HL)
	LD (HL),A
	LD A,(LMask_)
	RLCA
	LD (LMask_),A
	AND C
	XOR (HL)
	LD (HL),A
	INC H
	LD A,H
	AND 7
	RET NZ
	LD A,L
	ADD A,32
	LD L,A
	RET C
	LD A,H
	SUB 8
	LD H,A
	RET

vLINE	;верт.линияDE->H
	LD A,(LMask)
	LD (LMask_),A
	LD A,D
	CP H
	RET Z
	PUSH HL
	PUSH DE
	JR C,vG1
	LD D,H
	LD H,A
vG1	PUSH DE
	LD A,H
	SUB D
	LD B,A
	POP DE
	PUSH DE
	CALL PCOORD
	POP DE
	LD A,E
	AND 7
	LD DE,MLtabV
	ADD A,E
	LD E,A
	LD A,(DE)
	LD C,A
vG2	CALL pvMASK
	DJNZ vG2
	POP DE
	POP HL
	RET




