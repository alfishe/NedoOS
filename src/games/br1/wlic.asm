;------ПЕРЕМЕЩЕНИЯ
;---------п/п перемещения и поиска маршрута

DIR	;напр HL->DE
	LD A,L
	CP E
	LD A,H
	JR C,di1
	JR NZ,di2
	CP D
	LD A,0
	RET C
	LD A,4
;//	RET NZ
;//	LD A,#FF
	RET
di1	CP D
	LD A,1
	RET C
	LD A,3
	RET NZ
	DEC A
	RET
di2	CP D
	LD A,7
	RET C
	LD A,5
	RET NZ
	INC A
	RET

DIR_F	;напр HL->DE  с учётом наклона
	PUSH HL
	LD A,L
	SUB E
	JR C,df1
	JP NZ,df2
	POP HL
	LD A,H
	CP D
	LD A,0
	RET C
	LD A,4
;//	RET NZ
;//	LD A,#FF
	RET
df1	NEG
	LD L,A
	LD A,H
	SUB D
	LD H,2
	JR Z,df0
	JR C,df11
	CP L
	LD H,3
	JR Z,df0
	JR NC,df12
	ADD A,A ;--3|2
	CP L
	POP HL
	JR C,df14
	LD A,R
	RRA
	LD A,3
	RET C
	DEC A
	RET
df14	LD A,R
	AND %11
	LD A,3
	RET Z
	DEC A
	RET
df12	SLA L  ;--3|4
	CP L
	POP HL
	JR NC,df15
	LD A,R
	RRA
	LD A,3
	RET C
	INC A
	RET
df15	LD A,R
	AND %11
	LD A,3
	RET Z
	INC A
	RET
df11	NEG
	CP L
	LD H,1
	JR Z,df0
	JR NC,df32
	ADD A,A ;--1|2
	CP L
	POP HL
	JR C,df34
	LD A,R
	RRA
	LD A,1
	RET C
	INC A
	RET
df34	LD A,R
	AND %11
	LD A,1
	RET Z
	INC A
	RET
df32	SLA L  ;--1|0
	CP L
	POP HL
	JR NC,df35
	LD A,R
	RRA
	LD A,1
	RET C
	XOR A
	RET
df35	LD A,R
	AND %11
	LD A,1
	RET Z
	XOR A
	RET
df0	LD A,H
	POP HL
	RET
df2	LD L,A
	LD A,H
	SUB D
	LD H,6
	JR Z,df0
	JR C,df21
	CP L
	LD H,5
	JR Z,df0
	JR NC,df22
	ADD A,A ;--5|6
	CP L
	POP HL
	JR C,df24
	LD A,R
	RRA
	LD A,5
	RET C
	INC A
	RET
df24	LD A,R
	AND %11
	LD A,5
	RET Z
	INC A
	RET
df22	SLA L  ;--5|4
	CP L
	POP HL
	JR NC,df25
	LD A,R
	RRA
	LD A,5
	RET C
	DEC A
	RET
df25	LD A,R
	AND %11
	LD A,5
	RET Z
	DEC A
	RET
df21	NEG
	CP L
	LD H,7
	JR Z,df0
	JR NC,df42
	ADD A,A ;--7|6
	CP L
	POP HL
	JR C,df44
	LD A,R
	RRA
	LD A,7
	RET C
	DEC A
	RET
df44	LD A,R
	AND %11
	LD A,7
	RET Z
	DEC A
	RET
df42	SLA L  ;--7|0
	CP L
	POP HL
	JR NC,df45
	LD A,R
	RRA
	LD A,7
	RET C
	XOR A
	RET
df45	LD A,R
	AND %11
	LD A,7
	RET Z
	XOR A
	RET

DIST	;расст по ф-ле max(|X-Xt|,|Y-Yt|) Вх.XY-HL;Вых.A
	LD A,L
	SUB (IX+10)
	JR NC,dt1
	NEG
dt1	LD B,A
	LD A,H
	SUB (IX+11)
	JR NC,dt2
	NEG
dt2	CP B
	RET NC
	LD A,B
	RET

nxtTRY	LD (IX+8),#80 ;нет времени, попытайся потом
	RET

MAKE_R	;Выбор направления обхода Вх:hl-start
	LD A,(makTRY)
	OR A
	JR Z,nxtTRY
	DEC A
	LD (makTRY),A
	PUSH HL
	LD A,L ; вхHL-XY, выхHL-pos in map
	RLCA
	RLCA
	SRL H
	RRA
	SRL H
	RRA
	LD E,A
	LD A,H
	ADD A,MAP2/256
	LD D,A
	LD B,8 ;нач поз окружена?
MKstr	LD HL,inMAP ;выровн
	LD A,B
	DEC A
	ADD A,A
	ADD A,L
	LD L,A
	LD A,(HL)
	INC L
	LD H,(HL)
	LD L,A
	ADD HL,DE
	LD A,(HL)
	OR A  ;пров на прох
	JR Z,MKst0
	DJNZ MKstr
	LD B,8 ;есть ли рядом движущиеся?
MKany	LD HL,inMAP ;выровн
	LD A,B
	DEC A
	ADD A,A
	ADD A,L
	LD L,A
	LD A,(HL)
	INC L
	LD H,(HL)
	LD L,A
	ADD HL,DE
	LD A,(HL)
	CP #80	;пров движ обj рядом
	JR C,MKan1
	CALL GO_NXe
	JR NZ,MKst0
MKan1	DJNZ MKany
	POP HL
	JP G_stop ;поз окружена - стоп
MKst0	POP HL
	LD A,(DE)
	LD (ss_num),A
	LD (ss_pos),DE
	XOR A
	LD (DE),A
	LD (MINLEN),A
	CALL DIST
	LD (MINDIS),A
	PUSH HL
	PUSH DE
	EXX
	LD A,(IX+2)
	LD C,A
	BIT 0,A
	JR NZ,Mk1
	DEC C
	INC A
Mk1	DEC C
	INC A
	POP DE
	POP HL
	EXX
	LD C,A
	;HL-коорд DE-адр C-cdir/exx-против часовой
	LD A,1
	EX AF,AF ;A'-текущ. длина обхода
MkLOOP	;обх в 2 стороны
Mk_cw	BIT 0,C
	JR Z,Mk7
	DEC C
Mk7	DEC C
	PUSH HL
CWrep	LD HL,inMAP ; (выровн)
	LD A,C
	AND 7
	LD C,A
	ADD A,A
	ADD A,L
	LD L,A
	LD A,(HL)
	INC L
	LD H,(HL)
	LD L,A
	ADD HL,DE
	LD A,(HL)
	CP 1   ;пров на прох
	JR C,Mk4
	JP Z,CWstop
	 RLCA
	 JR NC,Mk4n
	 CALL Mk_her
	 JR C,Mk4
Mk4n	INC C
	JR CWrep
Mk4	EX (SP),HL
	LD DE,GO_Ntb
	LD A,C
	ADD A,A
	ADD A,E
	LD E,A
	LD A,(DE)
	ADD A,L
	LD L,A
	INC DE
	LD A,(DE)
	ADD A,H
	LD H,A
	POP DE
	EXX
	CP H
	EXX
	JR NZ,Mk5
	EXX
	LD A,L
	EXX
	CP L
	JR NZ,Mk5
	 LD A,(MINLEN) ;узкий проход?
	 OR A
	 JP NZ,MK_RET
Mk5	CALL DIST
	LD B,A
	LD A,(MINDIS)
	CP B
	JR C,Mk_ccw
	JR Z,Mk_ccw
	LD A,B
	LD (MINDIS),A
	EX AF,AF
	LD (MINLEN),A
	EX AF,AF
	XOR A
	LD (NROUND),A
Mk_ccw	EXX
	BIT 0,C
	JR Z,M1k7
	INC C
M1k7	INC C
	PUSH HL
CCWrep	LD HL,inMAP ;(выровн)
	LD A,C
	AND 7
	LD C,A
	ADD A,A
	ADD A,L
	LD L,A
	LD A,(HL)
	INC L
	LD H,(HL)
	LD L,A
	ADD HL,DE
	LD A,(HL)
	CP 1   ;пров на прох
	JR C,M1k4
	JP Z,CCWstp
	 RLCA
	 JR NC,M1k4n
	 CALL Mk_her
	 JR C,M1k4
M1k4n	DEC C
	JR CCWrep
M1k4	EX (SP),HL
	LD DE,GO_Ntb
	LD A,C
	ADD A,A
	ADD A,E
	LD E,A
	LD A,(DE)
	ADD A,L
	LD L,A
	INC DE
	LD A,(DE)
	ADD A,H
	LD H,A
	POP DE
	EXX
	CP H
	JR NZ,M1k5
	EXX
	LD A,L
	EXX
	CP L
	JR NZ,M1k5
	 LD A,(MINLEN) ;узкий проход?
	 OR A
	 JR NZ,MK_RET
M1k5	EXX
	CALL DIST
	LD B,A
	LD A,(MINDIS)
	CP B
	JR C,Mk_eol
	JR Z,Mk_eol
	LD A,B
	LD (MINDIS),A
	EX AF,AF
	LD (MINLEN),A
	EX AF,AF
	LD A,#80
	LD (NROUND),A
Mk_eol	EXX
	EX AF,AF
	INC A
	LD B,A
	EX AF,AF
	LD A,(MAXLEN)
	CP B
	JP NC,MkLOOP
MK_RET	LD HL,(ss_pos)
	LD A,(ss_num)
	LD (HL),A
	LD A,(MINLEN)
	OR A
	JP NZ,Mkr1
	 LD A,(IX+8) ;обхода нет или слишком далеко
	 OR A
	 JP NZ,G_stop
	 JP G_free ;если остановка при ложном обходе
Mkr1	CP 127
	JR C,Mkr2
	LD A,127
Mkr2	LD B,A
	 LD A,(IX+8)
	 OR A
	 JR NZ,Mkr2a
	 LD B,1
Mkr2a	 ;^если (IX+8)==0, уменьшить длину прохода до 1 (против ложного обхода)
	LD A,(NROUND)
	LD C,A
	OR B
	LD (IX+8),A
	LD A,C
	OR A
	LD A,(IX+2)
	JR NZ,Mkr3
	INC A
	BIT 0,A
	JR Z,Mkr4
	INC A
	JR Mkr4
Mkr3	DEC A
	BIT 0,A
	JR Z,Mkr4
	DEC A
Mkr4	AND 7
	LD (IX+2),A
	JP GO_MAN;!

MK_REp	POP HL
	JR MK_RET

CWstop	POP HL
	EXX
	EX AF,AF
	LD B,A
	LD A,(MAXLEN)
	ADD A,A
	SUB B
	LD (MAX_II),A
	LD A,B
	EX AF,AF
MkLOO3	BIT 0,C
	JR Z,M3k7
	INC C
M3k7	INC C
	PUSH HL
CCWre1	LD HL,inMAP ;выровн
	LD A,C
	AND 7
	LD C,A
	ADD A,A
	ADD A,L
	LD L,A
	LD A,(HL)
	INC L
	LD H,(HL)
	LD L,A
	ADD HL,DE
	LD A,(HL)
	CP 1   ;пров на прох
	JR C,M3k4
	JR Z,MK_REp
	 RLCA
	 JR NC,M3k4n
	 CALL Mk_her
	 JR C,M3k4
M3k4n	DEC C
	JR CCWre1
M3k4	EX (SP),HL
	LD DE,GO_Ntb
	LD A,C
	ADD A,A
	ADD A,E
	LD E,A
	LD A,(DE)
	ADD A,L
	LD L,A
	INC DE
	LD A,(DE)
	ADD A,H
	LD H,A
	POP DE
	CP (IX+1)
	JR NZ,M3kk
	LD A,L
	CP (IX+0)
	JP Z,MK_RET
M3kk	CALL DIST
	LD B,A
	LD A,(MINDIS)
	CP B
	JR C,Mk_eo3
	JR Z,Mk_eo3
	LD A,B
	LD (MINDIS),A
	EX AF,AF
	LD (MINLEN),A
	EX AF,AF
	LD A,#80
	LD (NROUND),A
Mk_eo3	EX AF,AF
	INC A
	LD B,A
	EX AF,AF
	LD A,(MAX_II)
	CP B
	JP NC,MkLOO3
	JP MK_RET
	;
CCWstp	POP HL
	EXX
	EX AF,AF
	LD B,A
	LD A,(MAXLEN)
	ADD A,A
	SUB B
	LD (MAX_II),A
	LD A,B
	EX AF,AF
MkLOO2	BIT 0,C
	JR Z,M2k7
	DEC C
M2k7	DEC C
	PUSH HL
CWrep2	LD HL,inMAP ;выровн
	LD A,C
	AND 7
	LD C,A
	ADD A,A
	ADD A,L
	LD L,A
	LD A,(HL)
	INC L
	LD H,(HL)
	LD L,A
	ADD HL,DE
	LD A,(HL)
	CP 1   ;пров на прох
	JR C,M2k4
	JP Z,MK_REp
	 RLCA
	 JR NC,M2k4n
	 CALL Mk_her
	 JR C,M2k4
M2k4n	INC C
	JR CWrep2
M2k4	EX (SP),HL
	LD DE,GO_Ntb
	LD A,C
	ADD A,A
	ADD A,E
	LD E,A
	LD A,(DE)
	ADD A,L
	LD L,A
	INC DE
	LD A,(DE)
	ADD A,H
	LD H,A
	POP DE
	CP (IX+1)
	JR NZ,M2kk
	LD A,L
	CP (IX+0)
	JP Z,MK_RET
M2kk	CALL DIST
	LD B,A
	LD A,(MINDIS)
	CP B
	JR C,Mk_eo2
	JR Z,Mk_eo2
	LD A,B
	LD (MINDIS),A
	EX AF,AF
	LD (MINLEN),A
	EX AF,AF
	XOR A
	LD (NROUND),A
Mk_eo2	EX AF,AF
	INC A
	LD B,A
	EX AF,AF
	LD A,(MAX_II)
	CP B
	JP NC,MkLOO2
	JP MK_RET

Mk_her	;препятствие - герой
	;(C: чужаки/движущиеся - прозрачны для трассировки)
	RRCA
	PUSH AF
	PUSH HL
	AND #7F ;/CALL N_IX
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD A,HUMAN/256
	ADD A,H
	LD H,A
	SET 3,L
	LD A,(HL) ;/LD A,(IX+8)
	POP HL
	OR A
	JR Z,Mk_h2 ;/00
	INC A
	JR Z,Mk_h2 ;/FF
	POP AF ;движущийся прозрачен
	SCF
	RET
Mk_h2	EX AF,AF
	CP 4 ;миним дальность-1 на которой враг не проходим
	JR C,Mk_h3
	EX AF,AF
	LD A,(SIDE_N)
	OR A
	JR NZ,Mk_h1
	POP AF
	SUB #B0
	CP #30
	RET  ;враг прозрачен
Mk_h1	POP AF
	SUB #80
	CP #30
	RET  ;наш прозрачен
Mk_h3	EX AF,AF ;противник близко (непрозрачен)
	POP AF
	XOR A
	RET


GO_MAN	;перемещение
	LD A,(IX+8)
	OR A
	RET Z
	CALL HL_IXt
	EX DE,HL
	CALL HL_IX0
	PUSH HL
	SBC HL,DE
	POP HL
	JP Z,G_stop ;пришли к цели - стоп
	CP #80
	JR C,GO_CW
	JR NZ,GO_CCW
	CALL DIR_F
	LD (IX+2),A
	CALL GO_NXT
	JR C,GO_go
	  BIT 7,A
	  JP Z,MAKE_R
	  CALL GO_NXe
	  JP Z,MAKE_R
	  LD (IX+8),0 ;против ложного обхода
	JP MAKE_R
	;
GO_go	JP go_IX3
GO_CW	DEC (IX+8)
	CALL Z,G_free
	LD C,1
	LD A,(IX+2)
	DEC A
	BIT 0,A
	JR NZ,GO_rep
	DEC A
	 LD B,A ;против закручивания
	 DEC A
	 AND 7
	 CALL GO_NXT
	 JR NC,GO_re2
	 LD A,(IX+8)
	 CP #80
	 JR Z,GO_re2
	 CP 2
	 JR C,GO_re2
	 LD (IX+8),#01
	JR GO_re2
GO_CCW	DEC (IX+8)
	LD C,-1
	LD A,(IX+2)
	INC A
	BIT 0,A
	JR NZ,GO_rep
	INC A
	 LD B,A ;против закручивания
	 INC A
	 AND 7
	 CALL GO_NXT
	 JR NC,GO_re2
	 LD A,(IX+8)
	 CP #82
	 JR C,GO_re2
	 LD (IX+8),#81
GO_re2	LD A,B
GO_rep	LD B,8
GO_re1	AND 7
	LD (IX+2),A
	CALL GO_NXT
	JR C,Gx3
	  BIT 7,A
	  JR Z,G_re5
	  CALL GO_NXe ;против заторов
	  JR Z,G_re5
	  LD A,B
	  CP 8
	  JR NC,G_re5a
	  LD A,R ;для b=6..1
	  AND #7
	  RET NZ
G_re5a	  LD (IX+8),#80 ;для b=7..8
G_re5	LD A,(IX+2)
	ADD A,C
	DJNZ GO_re1
	JR G_wait ;! временно заперт - ждать
Gx3	CALL HL_IXt
	EX DE,HL
	CALL DIR
	CP (IX+2)
	CALL Z,G_rnd
	EX DE,HL
	JP GO_go

G_rnd	LD A,R ;переходить на своб. траеторию?
	AND #7F
	CP 7  ;вер:X/128
	RET C ;антизацикливание
	;
G_free	LD (IX+8),#80 ;своб. перемещ
	RET

G_wait	;ждать прохода
	LD (IX+3),#80+6;величина ожидания
	JR G_free

G_stop	XOR A ;стоп
	LD (IX+8),A
	RET

GO_NXT	;Вх:HL-исх точка, А-напр
	;Вых: DE-след точка, NC/C - непрох/прох
	PUSH HL
	LD DE,GO_Ntb
	ADD A,A
	ADD A,E
	LD E,A
	LD A,(DE)
	ADD A,L
	LD L,A
	INC DE
	LD A,(DE)
	ADD A,H
	LD H,A
	LD D,H
	LD E,L
	LD A,L
	RLCA
	RLCA
	SRL H
	RRA
	SRL H
	RRA
	LD L,A
	LD A,H
	ADD A,MAP2/256
	LD H,A
	LD A,(HL) ;проработать!
	POP HL
	CP 1
	RET

GO_NXe	 ;против заторов
	 AND #7F
	 PUSH IX ;впереди герой
	 PUSH HL
	 CALL N_IX
	 LD A,(IX+8)
	 POP HL
	 POP IX
	 OR A
	 RET Z ;он стоит/00
	 INC A
	 RET;Z ;он стоит/FF  /NZ-двигается




;-----герои ходят и дерутся ----------------------------------
TimIMP	DEFB 1,1,1,-1,1,1,1,27,1 ;задержка удара (-1 - нет фазы)
	DEFB 1,1,1,-1,1,1,1,27,1
	DEFB 1,1,1,1,1,1, 2,2,3

TimDEL	DEFB 1,1,1,6,1,1,1, 31,2 ;задержка после удара
	DEFB 1,1,1,9,1,1,1, 31,2
	DEFB 1,1,1,1,1,1, 2,3,8

HvT1	DEFW 0,1, 1,1, 1,0, 1,-1
	DEFW 0,-1, -1,-1, -1,0, -1,1

HvA	; %1ibttttt
	JR NZ,HvAA
	LD (IX+3),0  ;конец удара
	RET
HvAA	LD L,A
	AND %11111
	JR Z,HvAim
	DEC (IX+3)  ;задержка
	RET
HvAim	BIT 6,L
	JR Z,HvAdel
	LD A,(IX+4)
	LD HL,TimIMP
	CALL BA
	CP 255
	JR C,HvAi1
	LD HL,TimDEL ;лучники
	LD A,(IX+4)
	CALL BA
	ADD A,%10000000
	LD (IX+3),A
	 LD A,3 	;FX-лук
	 JP SOUNDn	;
HvAi1	ADD A,%10100000  ;удар
	LD (IX+3),A
	LD A,(IX+2)
	JR HvA1
HvAdel	 LD A,(IX+4)	;FX-эффект удара
	 LD HL,typSND	;
	 CALL BA	;
	 CALL SOUNDn	;
	LD A,(IX+4)
	LD HL,TimDEL
	CALL BA
	ADD A,%10000000
	LD (IX+3),A
	LD A,(IX+2)
	ADD A,4
	AND 7
HvA1	EX AF,AF
	LD A,(IX+4)
	LD HL,AT_TY_
	CALL BA
	RRCA
	RET C
	EX AF,AF
	JR Hv2_

HERMOV	;LD A,(IX+3) ;перемещение (п/п нижн. уровня)
	;OR A
	;RET Z
	CP #80 ;в А ix+3
	JR NC,HvA
	EX AF,AF
	DEC (IX+3)
	LD A,(IX+7)
	AND %111
	CP 2
	JR Z,Hv2
	JP C,Hv1
	CP 3
	JP NZ,Hv4
	EX AF,AF
	CP 1
	JR Z,Hv2
	CP 4
	JR Z,Hv2
Hv3	LD A,(IX+2)
	LD HL,HvT1
	CALL DA
	INC HL
	PUSH HL
	LD D,(HL)
	LD E,A
	LD L,(IY+0)
	LD H,(IY+1)
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD (IY+0),L
	LD (IY+1),H
	POP HL
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD L,(IY+2)
	LD H,(IY+3)
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD (IY+2),L
	LD (IY+3),H
	RET
Hv2	LD A,(IX+2)
Hv2_	LD HL,HvT1
	CALL DA
	INC HL
	PUSH HL
	LD D,(HL)
	LD E,A
	LD L,(IY+0)
	LD H,(IY+1)
	ADD HL,DE
	ADD HL,DE
	LD (IY+0),L
	LD (IY+1),H
	POP HL
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD L,(IY+2)
	LD H,(IY+3)
	ADD HL,DE
	ADD HL,DE
	LD (IY+2),L
	LD (IY+3),H
	RET
Hv1	LD A,(IX+2)
	LD HL,HvT1
	CALL DA
	INC HL
	PUSH HL
	LD D,(HL)
	LD E,A
	LD L,(IY+0)
	LD H,(IY+1)
	ADD HL,DE
	LD (IY+0),L
	LD (IY+1),H
	POP HL
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD L,(IY+2)
	LD H,(IY+3)
	ADD HL,DE
	LD (IY+2),L
	LD (IY+3),H
	RET
Hv4	LD A,(IX+2)
	LD HL,HvT1
	CALL DA
	INC HL
	PUSH HL
	LD D,(HL)
	LD E,A
	LD L,(IY+0)
	LD H,(IY+1)
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD (IY+0),L
	LD (IY+1),H
	POP HL
	INC HL
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD L,(IY+2)
	LD H,(IY+3)
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	ADD HL,DE
	LD (IY+2),L
	LD (IY+3),H
	RET

go_IX3	;нач знач фазы IX+3
	CALL HL_IX0 ;сместить ук в map2 (в DE)
	CALL GMAP2
	LD C,(HL)
	LD (HL),0
	EX DE,HL
	CALL IX0_HL
	CALL GMAP2
	LD (HL),C
	LD HL,HvTHs ;нач del
	LD A,(IX+2)
	RRCA
	JR NC,gX0
	LD HL,HvTDs
gX0	CALL gPAR
	LD C,8
	CP 2
	JR Z,gX1
	LD C,16
	JR C,gX1
	CP 3
	LD C,6
	JR Z,gX1
	LD C,4
gX1	LD (IX+3),C
	LD C,A
	LD A,(IX+7)
	AND %11111000
	OR C
	LD (IX+7),A
	RET

