
;--------работа со зданиями-------

;поиск зданий и запoлн данных
iniBLT	LD HL,MINE
	PUSH HL
	LD (HL),0
	LD DE,MINE+1
	LD BC,64+511
	LDIR
	EXX
	LD DE,8
	LD HL,datMIN
	EXX
	LD HL,HBUILD
	LD DE,KBUILD
	LD A,(MASTER)
	OR A
	JR Z,iTs
	EX DE,HL
iTs	PUSH HL
	PUSH DE
	POP IY
	POP IX
	POP HL
	LD DE,MAP
	LD C,0
iT0	LD B,0
iT1	LD A,(DE)
	CP 78
	JP C,iT2
	JR NZ,iT3
	LD (HL),B ;шахта
	INC L
	LD (HL),C
	INC L
	LD (HL),255 ;здоровье
	INC L
	LD (HL),bHmine
	INC L
	EXX
	LD A,(HL)
	INC L
	EXX
	;деньги
	LD (HL),A
	INC L
	EXX
	LD A,(HL)
	INC L
	EXX
	LD (HL),A
	INC L
	LD (HL),127 ;здоровье/2
	INC L
	INC L
	JR iT2
iT3	CP 86
	JR C,iT2
	CP 94
	JR NC,iT4
	SUB 86
iT30	LD (IX),B ;зд.наших
	LD (IX+1),C
	LD (IX+2),A
	PUSH HL
	LD HL,bHEALT
	CALL BA
	POP HL
	LD (IX+3),A
	CALL bHE75p
	LD (IX+6),A
	LD (IX+4),255
	EXX
	ADD IX,DE
	EXX
	JR iT2
iT4	CP 100
	JR C,iT2
	CP 108
	JR NC,iT5
	SUB 90
iT40	LD (IY),B ;зд.врагов
	LD (IY+1),C
	LD (IY+2),A
	PUSH HL
	LD HL,bHEALT
	CALL BA
	POP HL
	LD (IY+3),A
	CALL bHE75p
	LD (IY+6),A
	LD (IY+4),255
	EXX
	ADD IY,DE
	EXX
	JR iT2
iT5	CP 110
	JR C,iT2
	JR NZ,iT6
	LD A,8 ;хата л
	JR iT30
iT6	CP 112
	JR NZ,iT2
	LD A,18 ;хата к
	JR iT40
iT2	INC DE
	INC B
	LD A,B
	CP 64
	JP C,iT1
	INC C
	LD A,C
	CP 64
	JP C,iT0
	RET

setBLT	LD IX,MINE ;расст здан в мап2
	LD BC,#4838
	LD DE,8
sBL0	LD A,(IX)
	OR A
	JR Z,sBL1
	LD L,A
	LD H,(IX+1)
	CALL GMAP2
	LD (HL),C
sBL1	INC C
	ADD IX,DE
	DJNZ sBL0
	RET

vieBLT	;начальн осмотр вокр зданий
	LD IX,HBUILD
	LD B,32
vbb0	PUSH BC
	LD A,(IX)
	OR A
	LD A,1
	CALL NZ,onseeB
vbb1	LD BC,8
	ADD IX,BC
	POP BC
	DJNZ vbb0
	RET

placeB ;разместить на карте здание A/IX
	LD C,A
	CALL HL_IX0
	CALL GMAP2
	LD A,C
	ADD A,#38
	LD (HL),A ;# в MAP2
	PUSH HL
	LD B,2
	LD DE,-64
	LD A,(IX+2)
	CP 8
	JR Z,pBB2
	CP 18
	JR Z,pBB2
	INC L  ;3x3
	LD (HL),B ;вокруг - непрох
	DEC L
	DEC L
	LD (HL),B
	ADD HL,DE
	LD (HL),B
	INC L
	LD (HL),B
	INC L
	LD (HL),B
	LD DE,126
	ADD HL,DE
	LD (HL),B
	INC L
	LD (HL),B
	INC L
	LD (HL),B
	POP HL
	RES 4,H
	LD A,(IX+4)
	CP 253
	JR Z,pBB3f1
	CP 254
	LD A,(IX+2)
	JR Z,pBB3f2
	CP 10
	JR C,pBB31
	ADD A,4
pBB31	ADD A,86
	JR pBB30
pBB3f2	CP 10
	JR C,pBB32
	ADD A,4
pBB32	ADD A,79
	JR pBB30
pBB3f1	LD A,79
pBB30	LD (HL),A
	INC L
	LD (HL),124
	DEC L
	DEC L
	LD (HL),120
	LD DE,-64
	ADD HL,DE
	LD (HL),121
	INC L
	LD (HL),122
	INC L
	LD (HL),123
	LD DE,126
	ADD HL,DE
	LD (HL),127
	INC L
	LD (HL),126
	INC L
	LD (HL),125
	RET
	;
pBB2	DEC L ;2x2
	LD (HL),B
	ADD HL,DE
	LD (HL),B
	INC L
	LD (HL),B
	POP HL
	LD A,(IX+4)
	CP 253
	JR Z,pBB2f1
	CP 254
	LD A,(IX+2)
	JR Z,pBB2f2
	CP 8
	LD A,110
	JR Z,pBB20
	LD A,112
	JR pBB20
pBB2f2	CP 8
	LD A,109
	JR Z,pBB20
	LD A,111
	JR pBB20
pBB2f1	LD A,108
pBB20	RES 4,H
	LD (HL),A
	DEC L
	LD (HL),120
	ADD HL,DE
	LD (HL),121
	INC L
	LD (HL),122
	RET

bHE75p	;получить 75% от A
	PUSH HL
	LD L,A
	SRL L
	SRL L
	SUB L
	POP HL
	RET

BLTNEW	;новое здание (Вх: HL-coord,C-type,A=0/1-наш/не наш)
	EXX
	LD DE,8
	LD HL,HBUILD
	LD BC,#2008
	OR A
	JR Z,bNW0
	LD HL,KBUILD
	LD C,40
bNW0	LD A,(HL)
	OR A
	JR Z,bNW1
	ADD HL,DE
	INC C
	DJNZ bNW0
	RET ;нет места
bNW1	PUSH HL
	POP IX
	EXX
	CALL IX0_HL
	LD (IX+2),C
	LD A,C
	LD HL,bHEALT
	CALL BA
	LD (IX+3),A
	CALL bHE75p
	LD (IX+6),A
	LD A,C
	LD HL,bcTIME
	CALL BA
	LD (IX+5),A
	LD (IX+4),253
	LD (IX+7),255
	EXX
	LD A,C
	JP placeB

