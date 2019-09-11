;------------------------------------------
;     Вражеский интеллект - СТРАТЕГИЯ
;------------------------------------------
;*L+
pntINI	;инициализация параметров точки сбора
        if 1==0
	LD H,WX_BAD/256 ;[--10]
	LD A,3
	LD L,WX_BAD&255
	PUSH HL
	CALL BA
	ADD A,63
	LD C,A
	LD A,10
	POP HL
	CALL BA
	CP C
	JR Z,crc10
	;
       LD HL,#FFF0
       LD (KUNGE+16),HL
crc10	;
        endif
	LD A,(DIFFIC)
	OR A
	PUSH AF
	 JR NZ,pniMR ;%1
	 LD A,%1101
pniMR	 LD (deMRCH),A ;скр.отступ.влш
	POP AF
	CALL NZ,UP_DIF
	LD A,#FF ;нач задержка
	LD (pntNUM),A
	LD A,(lev1ST)
	LD (pntDEL),A
	;/опред. возможности пр-ва типов
	LD HL,pntEN+1 ;очистка
	LD B,5
pni0	LD (HL),0
	INC HL
	DJNZ pni0
	LD A,(kTOWER)
	CP 4
	JR NC,pni4
	CP 3
	JR NC,pni3
	CP 2
	JR NC,pni2
	JR pni1
pni4	LD (pntEN+4),A;кат
pni3	LD (pntEN+5),A;конн
pni2	LD (pntEN+0),A;луч
pni1	LD (pntEN+1),A;пех
	LD A,(kmaxC) ;по налич закл
	LD (pntEN+2),A
	LD A,(kmaxW) ;по налич закл
	LD (pntEN+3),A
	;опред нач точки сбора
	LD HL,(KBUILD) ;перв. здание
pniP0	LD A,L
	OR A
	JR Z,pniP
pniPX	LD (pntX),HL
	RET
pniP	LD HL,(KUNGE) ;перв. воин /иначе error
	JR pniP0


pntACT	;-----обработка точки сбора (1 раз в 8 тик)
	LD A,(TIC)
	AND %111
	CP %101
	RET NZ ; раз в 8 кадров (~в секунду)
	LD HL,pntDEL
	LD A,(HL)
	DEC (HL)
	OR A
	RET NZ ;задержка не окончена
	LD HL,pntNUM
	LD A,(HL)
	DEC (HL)
	OR A
	JP Z,pntATA  ;послать в атаку
	CP 128
	JP NC,pntNEW  ;новый сбор
	;
pntNXT	;--------произвести следующего члена отряда
	LD A,(pntUNI)
	OR A
	JR NZ,pnx1
	CALL pnxNXT
pnx1	LD C,A
	LD A,(MASTER)
	OR A
	JR Z,pnx11
	LD HL,pnxBLT-3
	LD A,C
	CP 5
	JR Z,pnxW
	CP 6
	JR NZ,pnx2
	;
pnxW	;если волшебник есть - не производить его, а отозвать
	PUSH AF
	CALL loop_K
pnxW0	LD A,(IX+0)
	OR A
	JR Z,pnxW1
	LD A,(IX+4) ;волш?
	CP C
	JR NZ,pnxW1
	LD A,(IX+13) ;не охр?
	CP 12
	JP NC,pnxFRW ;нашли волш, вернуть на базу
pnxW1	ADD IX,DE
	DJNZ pnxW0
	POP AF
	JR pnx2
	;
pnx11	LD HL,pnxBLT-6 ;для кунгов
	LD A,C
	ADD A,9
	LD C,A
	CP 14
	JR Z,pnxW
	CP 15
	JR Z,pnxW
pnx2	LD (pntMAN),A
	CALL BA
	;//опред здания для пр-ва
	LD C,A
	LD B,#28
	LD IX,KBUILD
	LD HL,(pntX)
	LD DE,#FFFF ;номер/расст
	EXX
	LD B,32
	LD DE,8
pnx0	EXX
	LD A,(IX+0)
	OR A
	JR Z,pnx4
	LD A,(IX+2)
	CP C
	JR NZ,pnx4
	PUSH BC
	CALL DIST2 ;искать ближайшее
	POP BC
	CP E
	JR NC,pnx4
	LD E,A
	LD D,B
pnx4	INC B
	EXX
	ADD IX,DE
	DJNZ pnx0
	EXX
	LD A,D
	CP #FF
	JR NZ,pnxOK
	;//не найдено здание :(
pnxNIL	LD A,2
	LD (pntDEL),A
	RET
pnxOK	;//дать задержку на пр-во
	LD A,D
	CALL B_IX
	LD A,(IX+2)
	LD HL,hcTIME
	CALL BA
	SRL A
	SRL A
	SRL A
	LD (pntDEL),A
	;//произвести воина
	CALL HL_IX0
	CALL stayON
	LD A,(pntMAN)
	PUSH AF
	EX AF,AF
	LD A,1
	CALL NEWHER
	JR NZ,pnoMEM
pnxOK1	LD (IX+13),2 ;ждущий
	LD HL,(pntX)
	CALL IXt_HL
	CALL IX_93
	POP AF
	CP 7
	JR Z,pnxKT
	CP 16
	RET NZ
pnxKT	;катапульты - сразу в бой
	LD (IX+13),3
	JP IX_98
pnoMEM	POP AF ;нет памяти
	RET
pnxFRW	CALL pnxNIL ;волш уже есть
	JR pnxOK1
	;
pnxBLT	;тип производящего здания (3..8, 12..17)
	DEFB 1,1,3,6,1,1, 11,11,13,16,11,11


pntATA	;--------послать отряд в атаку
	 LD A,(levTYP)
	 CP 2
	 JR NZ,pnaa ;для типа 2 выбрать охранника и послать в атаку
	 LD B,10 ;число попыток
att1	 CALL RND
	 AND #3F
	 CP 48
	 JR NC,att1
	 ADD A,48
	 CALL N_IX
	 LD A,(IX+0)
	 OR A
	 JR Z,attx
	 LD (IX+13),3
	 LD B,1
attx	 DJNZ att1
pnaa	;подать всем команду атаковать поз HL
	CALL loop_K
pna0	LD A,(IX+0)
	OR A
	JR Z,pna1
	LD A,(IX+13)
	CP 2
	JR NZ,pna1
	LD (IX+13),3 ;ждущий->атакующий
	;
	LD A,(IX+4)
	CP 9
	JR C,pna50
	SUB 9
pna50	CP 5
	JR Z,pna66
	CP 6
	JR NZ,pna60
	LD C,15 ;волш-атак
	JR pna77
pna66	LD C,12 ;свящ-атак
pna77	CALL pnMAGI
	LD (IX+13),C
	;
pna60	LD A,(IX+3) ;неодновр. старт
	OR A
	JR NZ,pna0a
	CALL RND
	AND %00000111
	OR  %10000000
	LD (IX+3),A
pna0a	CALL IX_98
pna1	ADD IX,DE
	DJNZ pna0
	;/расч del до след сбора = levDEL+RND(32)
	CALL RND
	AND %11111
	LD HL,(levDEL)
	ADD A,L
	LD (pntDEL),A
	RET
	;
pnMAGI	;вх: C=нач уровень магии вых: C+=0..2
	LD A,R
	RRCA
	RET C ;+0 /50%
	INC C
	RRCA
	RET C;+1 /25%
	INC C
	RET ;+2 /25%



pntNEW	;--------начать новый сбор
        if 1==0
	CALL _TST#5
        endif
	;выбор базового здания
	LD B,16
pnw0	CALL RND
	AND #1F
	ADD A,#28
	CALL B_IX
	LD A,(IX+0)
	OR A
	JR NZ,pnw1
	DJNZ pnw0
	JR pnwX ;нет зданий
pnw1	;//выбрать базовую точку (+7..-8)
        if 1==0
	 LD HL,isTST8 ;[**]
	 DEC (HL)
        endif
	CALL HL_IX0
	EX DE,HL
	LD B,16
pnw2	LD C,E
	CALL RNDshf
	LD L,A
	LD C,D
	CALL RNDshf
	LD H,A
	PUSH HL
	CALL GMAP2
	LD A,(HL)
	POP HL
	OR A
	JR Z,pnw3
	DJNZ pnw2
	JR pnwX ;вокруг нет своб места
pnw3	LD (pntX),HL ;нов место сбора
pnwX	;//выбрать число воинов
	LD A,(levMAX)
	CP 2
	JR C,pnwM0
	DEC A
	LD B,A
	LD C,1
pnwM1	CALL RND
	RLCA
	JR C,pnwM3
	INC C
pnwM3	DJNZ pnwM1
	LD A,C
pnwM0	LD (pntNUM),A
	;//выбрать тип отряда (в 20% - однородный)
	CALL RND
	CP 201
	LD A,0
	JR C,pnwU0
	;отряд однородный
pnwNU	CALL pnxNXT
	CP 5
	JR Z,pnwNU ;не волш/свящ
	CP 6
	JR Z,pnwNU
pnwU0	LD (pntUNI),A
	;//задержка=1
	LD A,1
	LD (pntDEL),A
	;--иногда смена цели
	LD A,R
	AND %10100
	RET NZ
	JR Z,selNEW

pnxNXT	CALL pnxNX1 ;тип след члена отряда ->A
	LD A,C
	LD HL,pntEN-3
	CALL BA
	OR A
	JR Z,pnxNXT
	LD A,C
	RET
	;
pnxNX1	CALL RND ;вероятн появл
	LD C,3
	SUB 70
	RET C ;луч (3)
	INC C
	SUB 50
	RET C ;воин (4)
	INC C
	SUB 20
	RET C ;свящ (5)
	INC C
	SUB 25
	RET C ;волш (6)
	INC C
	SUB 10
	RET C ;катап (7)
	INC C
	;sub 75
	RET ;конник (8)

selTAR	;выбор/коррекция общей цели
	LD A,(pntTAR)
	CP #FF
	JR Z,selNEW
	CP #80
	JR NC,sttBU
	;цель-воин - жив?
	CALL N_IX
	LD A,(IX+0)
	OR A
	JR Z,selNEW ;мёртв
	LD A,(IX+1)
	CP #80
	JR NC,selNEW ;в здании
	RET
sttBU	;цель-здание
	AND #7F
	CALL B_IX
	LD A,(IX+0)
	OR A
	RET NZ ;цело
	;
selNEW	;----нов цель
	;поиск здания
	LD B,16 ;число попыток
stt0	CALL RND
	AND #1F
	ADD A,8
	LD C,A
	CALL B_IX
	LD A,(IX+0)
	OR A
	JR NZ,sttNB
	DJNZ stt0
	;поиск человека
	LD B,24 ;число попыток
stt1	CALL RND
	AND #3F
	CP 48
	JR NC,stt1
	LD C,A
	CALL N_IX
	LD A,(IX+0)
	OR A
	JR NZ,sttx
	DJNZ stt1
	LD C,#FF ;цель не найдена
	JR sttx
sttNB	SET 7,C
sttx	LD A,C
	LD (pntTAR),A
	RET


