;Начальные установки и защита
DELRET  LD HL,START1
	LD DE,START1+1
	LD (HL),H
	LD BC,START2-START1-2
	LDIR
	RET
START1
	LD HL,start
	LD (JP_ST+1),HL
       if PROTECT
;------------защита проц боя
	;4 - пров свопперов
	LD DE,LQWE-MAN
	LD BC,+(B_LOOP-LQWE) *256 +8
	LD IX,MAN
	ADD IX,DE
prt4_	LD A,(IX+2)
	OR A
	JR Z,prt44_
	ADD A,C
	LD C,A
prt44_	INC IX
	DJNZ prt4_
	LD (CRC4),A
	;
       endif
	CALL SWPBAT
	CALL LDASM1
	CALL LDASM2
       if PROTECT
;------------защита проц меню/карты
	;2
	Ms 0
	LD HL,SCR
	PUSH HL
	LD BC,#2000
	ADD HL,BC
	POP DE
prt1	LD A,(DE)
	CP (HL)
	JR Z,prt1_
	DEC C
	ADD A,B
	ADD A,(HL)
	LD B,A
prt1_	INC HL
	INC DE
	LD A,H
	OR L
	JR NZ,prt1
	LD (CRC2),BC
	;3
	LD HL,#FF02
	LD (TX),HL
	XOR A
	CALL MEM
	XOR A
	LD C,A
	ADD A,#3D
	LD B,A
prt3_	LD DE,TY
	LD A,(DE)
	EXX
	LD HL,TX
	SUB (HL)
	LD (HL),A
	EXX
	LDD
	JP PE,prt3_
	LD A,(TX)
	LD (CRC3),A
	;
       endif
	CALL MEM7
	JP DELRET
START2	LD A,R
	JR STRT2
	DEFM "*** Hello, my dear! You find hidden entry in my subject! ***"
	DEFM " (812)1433303 *** UFO-2 by Vyacheslav Mednonogov (c)1996 ***"
STRT2	LD (RNB),A
	LD (NX_RNB),A
;------------созд игр данных
	Ms 3
	LD HL,DATA
	LD DE,NEWDAT
	LD B,6
JJ0	PUSH BC
	PUSH HL
JJ1	CALL RND
	CP 192
	JR NC,JJ1
	INC A
	LD (N_AQU),A
	CALL RND
	LD (RNBgen),A
	CALL RND
	LD (RNAgen+1),A
	AND #F
	INC A
	LD (TARoff),A
	LD BC,480
	LDIR
	POP HL
	POP BC
	DJNZ JJ0
	JP MEM7
