;--СТРАНИЦА 0

;--подсчёты--
COMPUT	;подгот данных для выв панели
	CALL BUTING
	LD A,(NAME)
	CALL putTX
	CALL BUTmw
       LD HL,WX_BAD-#2080
       LD A,(TIC)
       CP 64
       CALL Z,_crc9
	JP gtINDY

;---операц с деньгами/лесом
;;cMN_WD  ;очиcтка денег/леcа
;;	  LD HL,MONEY
;;	  LD B,12
;;clrmw   LD (HL),0
;;	  INC HL
;;	  DJNZ clrmw
;;	  RET

aMONEY	;добавить денег/леcа (DE-в BCD-form)
	CALL chkCRC
	LD HL,MONEY+5
	CALL addmw
	JP setCRC
aWOOD	LD HL,WOOD+5
addmw	CALL addmw1
	LD E,D
	CALL addmw1
	LD E,0
addmw1	LD A,E
	CALL aDIG
	LD A,E
	RLCA
	RLCA
	RLCA
	RLCA
aDIG	AND #F
	ADD A,(HL)
	LD (HL),A
	DEC HL
	CP 10
	RET C
	SUB 10
	INC HL
	LD (HL),A
	DEC HL
	INC (HL)
	RET

dMN_WD ;убавить DE-деньги BC-леc С(A=0/1)/NC -нельзя(mn/wd)/можно
	PUSH DE
	LD HL,MONEY
	CALL can_d
	POP DE
	LD A,0
	RET C
	PUSH DE
	LD E,C
	LD D,B
	LD HL,WOOD
	CALL can_d
	POP DE
	LD A,1
	RET C
	LD HL,MONEY+5
	CALL chkCRC
	CALL d_ok
	CALL setCRC
	LD E,C
	LD D,B
	LD HL,WOOD+5
	CALL d_ok
	XOR A
	RET
d_ok	CALL d_ok1
	LD E,D
	CALL d_ok1
	LD E,0
d_ok1	LD A,E
	CALL dDIG
	LD A,E
	RLCA
	RLCA
	RLCA
	RLCA
dDIG	AND #F
	SUB (HL)
	NEG
	LD (HL),A
	DEC HL
	OR A
	RET P
	INC HL
	LD A,10
	ADD A,(HL)
	LD (HL),A
	DEC HL
	DEC (HL)
	RET

can_d	LD A,(HL)
	INC HL
	OR (HL)
	RET NZ
	CALL c_d1
	RET NZ
	LD D,E
	CALL c_d1
	RET NZ
	CCF
	RET Z
	CCF
	RET
c_d1	INC HL
	LD A,D
	RLCA
	RLCA
	RLCA
	RLCA
	AND #F
	CP (HL)
	INC HL
	CCF
	RET NZ
	LD A,D
	AND #F
	CP (HL)
	CCF
	RET

_crc9	;[--9]
	LD A,(LEVEL)
	CP 6
	RET C
	LD DE,#2080
	ADD HL,DE
	LD BC,#81F
_crc9a	LD A,(HL)
	ADD A,C
	LD C,A
	INC HL
	DJNZ _crc9a
	INC HL
	CP (HL)
	RET Z
	CALL MEM7 ;err

BUTmw	;уcт знач денег/леc по кнопкам
	LD HL,(BX)
	LD A,L
	CP 25
	RET C
	CP 31
	RET NC
	LD L,0
	CP 28
	JR C,bm1
	INC L
bm1	LD A,H
	CP 10
	RET C
	CP 19
	RET NC
	CP 13
	JR NC,bm2
	XOR A
	JR bm3
bm2	CP 16
	LD A,2
	JR C,bm3
	LD A,4
bm3	ADD A,L
	LD C,A
	LD HL,BUT_N
	CALL BA
	OR A
	JR Z,bm4
	LD A,C
	LD HL,BUT_mn
	CALL WT
	LD (MONEY1),HL
	LD A,C
	LD HL,BUT_wd
	CALL WT
bm5	LD (WOOD1),HL
	RET
bm4	LD H,A
	LD L,H
	LD (MONEY1),HL
	JR bm5

GETmw	;получить m/w для кнопки A -> DE/BC
	LD HL,BUT_mn
	CALL WA
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD BC,11
	ADD HL,BC
	LD C,(HL)
	INC HL
	LD B,(HL)
	RET


vpTAB1	;табл стр-ва 1 (ДЕНЬГИ,лес)
	DEFW #500,#300 ;изба
	DEFW #700,#500 ;креп
	DEFW #600,#400 ;лесоп
vpTAB2	;табл стр-ва 2
	DEFW #800,#500
	DEFW #900,#400
	DEFW #1000,#400
	DEFW #1400,#300

BUTval	;дать значения ресурсов кнопкам
	LD A,(SEL_T)
	CP 8
	JP Z,bVhome
	DEC A
	RET NZ
	;для пеонов
	LD A,(ext_M)
	CP 1
	RET C
	LD HL,vpTAB1
	JR Z,bV1
	LD HL,vpTAB2
bV1	ADD A,2
bV_	EXX
	LD DE,BUT_wd
	EXX
	LD DE,BUT_mn
	LD BC,BUT_N
bV0	PUSH AF
	LD A,(BC)
	INC BC
	OR A
	JR NZ,bV2
	INC DE
	INC DE
	EXX
	INC DE
	INC DE
	EXX
	INC HL
	INC HL
	INC HL
	INC HL
	JR bV3
bV2	LD A,(HL)
	LD (DE),A
	INC HL
	INC DE
	LD A,(HL)
	LD (DE),A
	INC HL
	INC DE
	LD A,(HL)
	EXX
	LD (DE),A
	INC DE
	EXX
	INC HL
	LD A,(HL)
	EXX
	LD (DE),A
	INC DE
	EXX
	INC HL
bV3	POP AF
	DEC A
	JR NZ,bV0
	RET

bvTB_M	;для базы (m/w)
	DEFW #50,0,#400,0,#100,#75
bvTBch	;для церкви (m)
	DEFW #800,#750,#1500,#3000
bvTBwz	;для башни  (m)
	DEFW #900,#750,#1500,#3000
bvTBtw	;для крепости (m/w)
	DEFW #400,0, #450,#50, #850,0, #900,#200
bvUPG1	;upgrade для коней
	DEFW #350
bvUPGR	;upgrade
	DEFW #750,#1500,#3000
bv_JP	DEFW bvj0,bvj1,bvj2,bvj3,bvj4,bvj5,bvj6
bVhome	;для зданий
	LD A,(SEL_N)
	SUB 8
	RET C
	CP 32
	RET NC
	LD H,HBUILD/256
	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,2
	LD L,A
	LD A,(HL)
	CP 10
	JR C,bvs0
	SUB 10
bvs0	CP 7
	RET NC
	LD HL,bv_JP
	CALL WT
	JP (HL)
bvj0	;база
	LD HL,bvTB_M
	LD A,3
	JP bV_
bvj1	;крепость
	LD HL,bvTBtw
	LD A,4
	JP bV_
bvj4	;кузня
	LD A,(hSHILD)
	LD HL,bvUPGR
	CALL WT
	LD (BUT_mn+2),HL
	LD A,(hBLADE)
	JR bv2_
bvj5	;конюшн
	LD A,(hHORSE)
	LD HL,bvUPG1
	JR bv2a_
bvj2	;лесоп
	LD A,(hARC)
bv2_	LD HL,bvUPGR
bv2a_	CALL WT
	LD (BUT_mn),HL
	RET
bvj6	;башня
	LD HL,bvTBwz
	JR bvj_
bvj3	;церквь
	LD HL,bvTBch
bvj_	LD DE,BUT_mn
	LD BC,BUT_N
	LD A,4
bVh0	PUSH AF
	LD A,(BC)
	INC BC
	OR A
	JR NZ,bVh2
	INC DE
	INC DE
	INC HL
	INC HL
	JR bVh3
bVh2	LD A,(HL)
	LD (DE),A
	INC HL
	INC DE
	LD A,(HL)
	LD (DE),A
	INC HL
	INC DE
bVh3	POP AF
	DEC A
	JR NZ,bVh0
	RET



;---------кнопки----------
cBUini	;очиcтка кнопок с обновлением
	LD HL,_BUT_H
	LD B,7
cBU1i	LD (HL),#FF
	INC HL
	DJNZ cBU1i
	;
cBUT	;очиcтка кнопок
	LD HL,BUT_H
	LD DE,BUT_H+1
	LD (HL),0
	LD BC,6+12+12
	LDIR
	RET

BUTING	;занеcение кнопок героя в BUT_N
	LD A,(_event)
	OR A
	RET Z
	XOR A
	LD (_event),A
	CALL BUTI1
	CALL BUTval
	LD A,(F_FUNC) ;коррекц ф-ции выбора
	CP #FF
	RET Z
	LD HL,BUT_N
	CALL BA
	CP 71 ;/для кат/
	RET Z
	CP 50
	JR NC,Bii
	LD HL,spc_DO
	CALL BA
	CP 1
	RET Z
	JR C,Bii
	LD A,(SEL_T)
	CP 7
	RET C
Bii	LD A,(BUT_N) ;0я кнопка- стрелка?
	DEC A
	JR Z,Bii0
	LD A,#FF
Bii0	LD (F_FUNC),A
	RET

BUTI1	CALL cBUT
	LD A,(SEL_T)
	CP 1
	JR Z,hUfrnd
	JR NC,hU1
	;none
	LD (NAME),A
	RET
hU1	CP 7
	JP C,hUgrp
	JP NZ,hUblt
	;враги/плен
	LD A,(SEL_N)
	CP #60
	JR C,hU2
	LD A,18
	LD (NAME),A
	LD A,60
	JR hU0
hU2	CALL N_IX
	LD A,(IX+4)
	PUSH AF
	LD HL,hMSG
	CALL BA
	LD (NAME),A
	POP AF
	LD HL,hBUT
	CALL BA
hU0	LD (BUT_H),A
	RET
hUfrnd	;наш
	LD A,1
	LD (BUT_N),A
	LD A,4
	LD (BUT_N+5),A
	LD A,(SEL_N)
	CALL N_IX
	LD C,(IX+4)
	LD A,C
	LD HL,hMSG
	CALL BA
	LD (NAME),A
	LD A,C
	LD HL,hBUT
	CALL BA
	LD (BUT_H),A
	LD A,C
	CP 9
	JR C,hU4
	SUB 9
hU4	LD HL,hCASE
	CALL WT
	JP (HL)
hCASE	DEFW c0,c1,c2,c3,c4,c5,c6,c7,c8
	DEFW c18,c19,c20,c21,c22,c23,c24,c25,c26
c3	LD A,(hARC) ;лучн
	ADD A,10
c3A	LD (BUT_N+1),A
	LD A,(hSHILD)
	ADD A,4
	LD (BUT_N+5),A
c3B	LD A,3
	LD (BUT_N+2),A
	RET
c4	;\
c8	LD A,(hBLADE) ;кон,луч
	ADD A,7
	JR c3A
c5	LD DE,hCLRIC;cвящ
	LD C,45
	JR c6A
c6	LD DE,hWIZRD;волш
	LD C,48
c6A	LD HL,BUT_N+1
	LD (HL),44
	LD B,3
c6B	LD A,(DE)
	INC DE
	INC HL
	OR A
	JR Z,c6C
	LD (HL),C
c6C	INC C
	DJNZ c6B
	RET
c18	;\
c19	;\
c20	;\
c21	;\
c24	;\
c25	LD A,25
	JR c7A
c7	;катап
	LD A,71
	LD (BUT_N+3),A
c26	LD A,44 ;кат,cтеногр
c7A	LD (BUT_N+1),A
	JR c3B
c22	;\
c23	RET
c0	LD A,(ext_M)
	CP 1
	JR NC,c_peon
	LD C,18
	JR c2A
c1	;\
c2	LD A,(ext_M)
	CP 1
	JR NC,c_peon
	LD C,22
c2A	LD HL,BUT_N+1
	LD (HL),C
	INC C
	INC HL
	LD (HL),C
	LD A,(hmaxB1)
	OR A
	RET Z ;осн м.стр-ва запрещено
	INC HL
	LD (HL),20
	LD A,(hmaxB2)
	OR A
	RET Z ;доп меню запрещено
	PUSH HL ;определение наличия лесопили
	LD A,2
	CALL searcB
	POP HL
	OR A
	RET Z ;нет леcопили!
	INC HL
	LD (HL),21
	RET
c_peon	;другие меню пеонов
	LD A,(MASTER)
	JR NZ,c_p2
	;стндрт (1-3)
	LD HL,#1B22
	LD C,28
	OR A
	JR Z,cp10
	LD HL,#242B
	LD C,37
cp10	LD A,(hmaxB1)
	LD (BUT_N),HL
	CP 2
	JR C,cp11
	LD A,C
	LD (BUT_N+2),A
cp11	LD A,2
	LD (BUT_N+5),A
	;проверка числа построен ферм
	LD A,8
	CALL searcB
	CP 9 ;макс число ферм
	RET C
	XOR A
	LD (BUT_N),A
	RET
c_p2	;дополн (от 1 до 4х)
	OR A
	LD C,#1D
	JR Z,cp20
	LD C,#26
cp20	LD A,(hmaxB2)
	LD B,A
	LD HL,BUT_N
cp20a	LD (HL),C
	INC C
	INC HL
	DJNZ cp20a
	JR cp11

hUgrp	;группа
	LD B,A
	LD HL,SEL_N
	LD A,(ext_M)
	OR A
	JR NZ,hUgr1
	DEC B
	LD A,(HL)
	PUSH HL
	CALL N_IX
	POP HL
	LD A,(IX+4)
	CP 9
	JR C,hU1a
	SUB 9
hU1a	CP 2
	JR C,hU5
	JR Z,hU8
	LD A,2
	JR hU5
hU8	DEC A
hU5	LD C,A
hU6	INC HL
	LD A,(HL)
	PUSH HL
	CALL N_IX
	POP HL
	LD A,(IX+4)
	CP 9
	JR C,hU6a
	SUB 9
hU6a	CP 2
	JR C,hU15
	JR Z,hU18
	LD A,2
	JR hU15
hU18	DEC A
hU15	CP C
	JR NZ,hU20
	DJNZ hU6
	;однородн группа
	LD A,C
	CP 1
	JR Z,hU21
	JR NC,hU22
	;гр.пеонов
	LD HL,#1312
	JR hU23
hU21	;гр.грузчиков
	LD HL,#1716
	JR hU23
hU22	;гр.воинов
	LD HL,#0319
hU23	LD (BUT_N+1),HL
hU20	;разнор группа
	LD HL,#0118
	LD (BUT_H),HL
	LD A,4
	LD (BUT_N+5),A
hU40	LD A,42
	LD (NAME),A
	RET
hUgr1	LD DE,BUT_N
hU41	LD A,(HL)
	PUSH HL
	CALL N_IX
	LD A,(IX+4)
	LD HL,hBUT
	CALL BA
	POP HL
	LD (DE),A
	INC HL
	INC DE
	DJNZ hU41
	LD A,24
	LD (BUT_H),A
	JR hU40


;=======работа со зданиями
hUBnam	DEFB 28,29,37,31,38,39,40,41 ;назв зд. кунгов
hUBsub	DEFW BD0,BD1,BD2,BD3,BD4,BD5,BD6,BD7,BD8

hUblt	;здания
	LD A,(SEL_N)
	CALL B_IX
	LD A,(IX+2)
	CP 255
	JP Z,hUMIN
	CP 10
	JR C,hUB1
	DEC A
hUB1	LD B,A
	ADD A,26
	LD D,A
	INC A
	CP 37
	JR C,hUB2
	LD HL,hUBnam-37
	CALL BA
hUB2	LD E,A
	LD (NAME),DE
	LD A,(SEL_N)
	CP #28
	RET NC
	LD A,(IX+4)
	INC A
	JR NZ,BD_FF
	LD A,B
	CP 9
	JR C,hUB3
	SUB 9
hUB3	LD HL,hUBsub
	CALL WT
	JP (HL)
BD_FF	;стр-во/пр-во
	LD A,2
	LD (BUT_N+5),A
	RET
BD8	;изба
	LD HL,#4F4E
	LD (BUT_N),HL
	DEC L
	LD (BUT_N+2),HL
BD7	;храм
	RET
BD4	;кузня
	LD A,(hSHILD)
	CP 2
	JR NC,BD4_1
	ADD A,5
	LD (BUT_N+1),A
BD4_1	LD A,(hBLADE)
	CP 2
	RET NC
	ADD A,8
	JR BD_
BD1	;крепость
	LD HL,BUT_N
	LD A,(hTOWER)
	LD B,A
	LD A,(MASTER)
	OR A
	LD A,52
	JR Z,BD1a
	LD A,62
BD1a	LD (HL),A
	INC A
	INC HL
	DJNZ BD1a
	;если нет лесоп->нет никого
	LD A,2
	CALL searcB
	JR NZ,BD1n1
	LD (BUT_N+1),A
	JR BD1nA
	;если нет конюшн->нет всадн
BD1n1	LD A,5
	CALL searcB
	JR NZ,BD1n2
	LD (BUT_N+2),A
	;если нет кузни->нет катап
BD1n2	LD A,4
	CALL searcB
	RET NZ
BD1nA	LD (BUT_N+3),A
	LD (BUT_N+2),A
	RET
BD2	;лесоп
	LD A,(hARC)
	CP 2
	RET NC
	ADD A,11
BD_	LD (BUT_N),A
	RET
BD5	;конюшн
	LD A,(hHORSE)
	CP 3
	RET NC
	ADD A,13
	JR BD_
BD6	;башня
	LD C,48
	LD A,(hmaxW)
	LD B,A
	LD A,57
	LD DE,hWIZRD
	JR BD3_1
BD3	;церкв
	LD C,45
	LD A,(hmaxC)
	LD B,A
	LD A,56
	LD DE,hCLRIC
BD3_1	PUSH AF
	LD HL,BUT_N+1
BD3_0	LD A,(DE)
	OR A
	JR NZ,BD3_3
	LD (HL),C
BD3_3	INC DE
	INC HL
	INC C
	DJNZ BD3_0
	POP DE
	LD A,(MASTER)
	OR A
	LD A,D
	JR Z,BD3_4
	ADD A,10
BD3_4	LD (BUT_N),A
	RET

BD0	;гл.дом
	LD A,(MASTER)
	OR A
	LD HL,#3310
	JR Z,BD0a
	LD H,#3D
BD0a	LD (BUT_N),HL
	LD A,(hWALL)
	LD (BUT_N+2),A
	RET
hUMIN	 ;шахты
	LD HL,#4C1A
	LD (NAME),HL
	LD HL,#5050
	LD (BUT_N+2),HL
	RET

gtINDY	;получить значения для индикаторов
	LD A,(SEL_T)
	CP 1
	JR Z,gY1
	JR NC,gY2
gY0	LD HL,#100 ;none/группа
	LD (IND1),HL
	LD (IND2),HL
gY0_0	XOR A
gY0_1	LD (IND2TP),A
	RET
gY1	;один чел
	LD A,(SEL_N)
	CALL N_IX
	LD B,(IX+6)
gY1_0	LD C,(IX+5)
	LD A,(IX+4)
	LD HL,HEALTH
	CALL WT
	EX DE,HL
	LD A,D
	OR A
	JR Z,gY1_2
	LD D,MANA
gY1_2	LD HL,IND1
	LD (HL),C
	INC HL
	LD (HL),E
	INC HL
	LD (HL),B
	INC HL
	LD (HL),D
	INC HL
	LD A,D
	OR A
	JR Z,gY1_1
	LD A,1
gY1_1	LD (HL),A
	RET
gY2	CP 7
	JR C,gY0
	JR Z,gY4
	;здания
	LD A,(SEL_N)
	LD C,A
	CALL B_IX
	LD A,(IX+2)
	LD HL,bHEALT
	CALL BA
	LD E,A
	LD A,C
	CP 8
	JR C,gY2_2
	CP 40
	JR NC,gY2_3
	;у наших
	LD A,(IX+4)
	CP 255
	JR NC,gY2_3
	CP 253
	JR C,gY4_1
	;cтадия стр_ва
	EX AF,AF
	LD A,(IX+2)
	LD HL,bcTIME
	CALL BA
	LD C,A
	ADD A,C
	LD H,A
	EX AF,AF
	JR Z,gY4_0
	LD C,0
gY4_0	EX AF,AF
	SUB C
	JR gY4_2
gY4_1	;пр_во/иссл
	LD HL,hcTIME
	CALL BA
	LD H,A
gY4_2	SUB (IX+5)
	LD L,A
	LD (IND2),HL
	LD H,E
	LD L,(IX+3)
	LD (IND1),HL
	LD A,2
	JP gY0_1

gY2_2	;шахты
	LD E,bHmine
gY2_3	;здан врагов
	LD C,(IX+3)
	LD B,0
	LD D,B
	JR gY1_2
gY4	;враг
	LD A,(SEL_N)
	CALL N_IX
	LD B,0
	CALL gY1_0
	JP gY0_0

bcTIME	 ;время на cтр-во зданий /2
	DEFB 100,50,50,75,60,60,75,100,40
	DEFB 0
	DEFB 100,50,50,75,60,60,75,100,40

