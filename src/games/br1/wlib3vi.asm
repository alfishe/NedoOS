;---манипуляции с видимостью---------------------

onsee2	CALL HL_IX0 ;видим на ходу (2)
ONSEEm	LD D,0 ;магич зрение (2)
	JR jS2
onsee	;видим при останове (2..5)
	LD A,(IX+4)
	LD HL,sRANGE
	CALL BA
onseeB	CALL HL_IX0
	LD D,0
	CP 1
	JP NC,jS3
jS2	LD A,H
	SUB 2
	LD H,A
	JR C,jjS2
	CP 60
	JR NC,jjS2
	LD A,L
	SUB 2
	JR C,jjS2
	CP 60
	JR NC,jjS2
	DEC L
jj02	CALL GMAP
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	LD E,61
	ADD HL,DE
jj01	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	DEC E
	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
jj0	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	LD E,61
	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	RET
jjS2	;
	LD A,L
	SUB 2
	LD L,A
	CP H
	RET Z
	LD A,H
	CP 255
	JR C,jjS21
	INC H
	CALL GMAP
	LD E,61
	JR jj01
jjS21	INC L
	CP 60
	JR C,jj02
	CALL GMAP
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	LD E,61
	ADD HL,DE
	DEC E
	CALL jQ5
	JP jQ5

jS3	JP NZ,jS4_5
	LD A,H
	SUB 3
	LD H,A
	JR C,jjS3
	CP 58
	JR NC,jjS3
	LD A,L
	SUB 3
	JR C,jjS3
	CP 58
	JR NC,jjS3
	DEC L
	CALL GMAP
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	LD E,61
	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	DEC E
	DEC E
	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	DEC E
	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	ADD HL,DE
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC E
	JP jj0
jjS3	DEC L
	LD B,3
	CALL jLINE
	DEC L
	LD B,5
	CALL jLINE
	DEC L
	LD B,7
	CALL jLINE
	CALL jLINE
	CALL jLINE
	INC L
	LD B,5
	CALL jLINE
	INC L
	LD B,3
	JP jLINE


jS4_5	CP 2
	JP NZ,jS5
jS4	LD A,H
	SUB 4
	LD H,A
	JR C,jjS4
	CP 56
	JR NC,jjS4
	LD A,L
	SUB 4
	JR C,jjS4
	CP 56
	JR NC,jjS4
	DEC L
	DEC L
	CALL GMAP
	LD E,59
	CALL jQ5
	LD E,57
	CALL jQ7
	DEC E
	CALL jQ9
	CALL jQ9
	CALL jQ9
	CALL jQ9
	INC E
	CALL jQ9
	INC E
	INC E
	CALL jQ7
	INC E
	INC E
	JP jQ5
jjS4	DEC L
	DEC L
	LD B,5
	CALL jLINE
	DEC L
	LD B,7
	CALL jLINE
	DEC L
	LD BC,#905
jjS40	CALL jLINE
	DEC C
	JR NZ,jjS40
	INC L
	LD B,7
	CALL jLINE
	INC L
	LD B,5
	JP jLINE


jS5	LD A,H
	SUB 5
	LD H,A
	JR C,jjS5
	CP 54
	JR NC,jjS5
	LD A,L
	SUB 5
	JR C,jjS5
	CP 54
	JR NC,jjS5
	DEC L
	DEC L
	DEC L
	CALL GMAP
	LD E,57
	CALL jQ7
	DEC E
	DEC E
	CALL jQ9
	DEC E
	CALL jQ11
	CALL jQ11
	CALL jQ11
	CALL jQ11
	CALL jQ11
	CALL jQ11
	INC E
	CALL jQ11
	INC E
	INC E
	CALL jQ9
	INC E
	INC E
	JP jQ7
jjS5	DEC L
	DEC L
	DEC L
	LD B,7
	CALL jLINE
	DEC L
	LD B,9
	CALL jLINE
	DEC L
	LD BC,#B07
jjS50	CALL jLINE
	DEC C
	JR NZ,jjS50
	INC L
	LD B,9
	CALL jLINE
	INC L
	LD B,7
	JR jLINE

jQ11	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
jQ9	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
jQ7	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
jQ5	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	INC HL
	RES 7,(HL)
	ADD HL,DE
	RET


jLINE	;HL-коорд,B-ширина
	LD A,H
	CP 63
	JR NC,jLr
	PUSH HL
	PUSH BC
	LD A,L
	OR A
	LD A,B
	JP P,jL1
	ADD A,L
	LD B,A
	LD L,0
	JR jL2
jL1	ADD A,L
	SUB 63
	JR C,jL2
	LD C,A
	LD A,B
	SUB C
	LD B,A
jL2	CALL GMAP
jL3	RES 7,(HL)
	INC L
	DJNZ jL3
	POP BC
	POP HL
jLr	INC H
	RET
