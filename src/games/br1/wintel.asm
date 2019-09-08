;интеллект воинов компьютера и играющего (28.05.97)

;BUF512 array[64], где [i = X/8+Y%8], array[i]={ссылка на первого врага
;	в квадранте|#00,если квадрант пуст}
;+256	список врагов (номер врага)(ссылка на следующего|#00}

;----------2D-сортировка наших (обычная)

QH1SRT	LD DE,HBUILD ;сортировка наших зданий
	LD BC,#2088
	LD A,7
	LD (qad__+1),A
	CALL QAD_
	LD A,15
	LD (qad__+1),A
	RET

Q1SORT	LD DE,HUMAN ;сортировка наших воинов --""--
	LD BC,#3000
QAD_	LD HL,BUF512+64
	XOR A
qadC	DEC L ;очистка
	LD (HL),A
	JR NZ,qadC
	PUSH BC
	EXX
	POP BC
	LD HL,BUF512+256
qad1	EXX
	LD A,(DE)
	INC E
	OR A
	JR Z,qad0 ;мёртв
	LD L,A
	;выч адр
	SRA L
	SRA L
	SRA L
	LD A,(DE)
	CP #80
	JR NC,qad0 ;в здании
	AND %00111000
	OR L
	LD L,A
	LD H,BUF512/256
	LD A,(HL)
	OR A
	JR Z,qad5
	LD H,BUF512/256+1
qad6	LD L,A
	LD A,(HL)
	OR A
	JR NZ,qad6
qad5	EXX
	LD (HL),C
	INC L
	LD (HL),0
	LD A,L
	INC L
	EXX
	LD (HL),A
qad0	LD A,E
qad__	ADD A,15
	LD E,A
	JR NC,qad10
	INC D
qad10	EXX
	INC C
	DJNZ qad1
	RET

;--------------- 2D-cортировка врагов с учётом видимости

QH2SRT	LD DE,KBUILD ;сортировка вражих зданий
	LD BC,#20A8
	LD A,7
	LD (qvd__+1),A
	CALL QVD_
	LD A,15
	LD (qvd__+1),A
	RET

Q2SORT	LD DE,KUNGE ;сортировка врагов по квадратам 8х8
	LD BC,#3030
QVD_	LD HL,BUF512+64
	XOR A
qvdC	DEC L ;очистка
	LD (HL),A
	JR NZ,qvdC
	PUSH BC
	EXX
	POP BC
	LD HL,BUF512+256
qvd1	EXX
	LD A,(DE)
	INC E
	OR A
	JR Z,qvd0 ;мёртв
	LD L,A
	LD A,(DE)
	CP #80
	JR NC,qvd0 ;в здании
	LD H,A
	PUSH HL
	CALL GMAP ;пров видим
	LD A,(HL)
	POP HL
	RLA
	JR C,qvd0
	;выч адр
	SRA L
	SRA L
	SRA L
	LD A,H
	AND %00111000
	OR L
	LD L,A
	LD H,BUF512/256
	LD A,(HL)
	OR A
	JR Z,qvd5
	LD H,BUF512/256+1
qvd6	LD L,A
	LD A,(HL)
	OR A
	JR NZ,qvd6
qvd5	EXX
	LD (HL),C
	INC L
	LD (HL),0
	LD A,L
	INC L
	EXX
	LD (HL),A
qvd0	LD A,E
qvd__	ADD A,15
	LD E,A
	JR NC,qvd10
	INC D
qvd10	EXX
	INC C
	DJNZ qvd1
	RET

QNUM	LD L,(IX+0) ;найти номер квадрата
	SRA L
	SRA L
	SRA L
	LD A,(IX+1)
	AND %00111000
	OR L
	LD L,A
	LD H,BUF512/256
	RET

;--------- СКАНИРОВАНИЕ ---------------------------

;номера П/П сканирования QSC_N
;12223
;40005
;40005
;67778

SCAN	LD A,(TIC)
	RRCA
;	JP NC,kSCAN

;--------- СКАНИРОВАНИЕ ДЛЯ ЛЮДЕЙ ------------

hSCAN	;*** наши сканируют врага ***
	CALL Q2SORT ;сканирование воинов
	LD HL,QSCt2
	LD (QSC+1),HL
	CALL loop_H
hww0	LD A,(IX+0)
	OR A
	JR Z,hww1
	LD A,(IX+9)
	CP 28
	JR Z,hww3
	CP 2
	JR NC,hww1
hww3	LD E,#FF ;E=мин дист
	CALL hwwSCA ;cканировать, если тек действия 0 или 1 или 28
	LD A,E
	CP #FF
	JR NC,hww1a ;в поле зрения не было никого
	;иначе атаковать цель D
	LD A,(IX+9)
	DEC A
	LD A,4 ;норм.атака
	JR NZ,hww4
	LD A,26 ;атака не сходя с места
hww4	LD (IX+9),A
	LD (IX+12),D
	CALL HL_IX0
	CALL IXt_HL
hww1a	LD DE,16
hww1	ADD IX,DE
	DJNZ hww0
	;;
hwwH	LD A,(TIC) ;50%
	RRCA
	RET C
	CALL QH2SRT;сканирование зданий
	LD HL,QSCt2H
	LD (QSC+1),HL
	CALL loop_H
hww50	LD A,(IX+0)
	OR A
	JR Z,hww51
	LD A,(IX+9)
	CP 2
	JR NC,hww51
	LD E,#FF ;E=мин дист
	CALL hwwSCA ;cканировать, если текущ действия 0 или 1
	LD A,E
	CP #FF
	JR NC,hww51a ;в поле зрения не было никого
	;иначе атаковать цель D
	LD A,(IX+9)
	OR A
	LD A,28 ;норм.атака (м.быть прервана)
	JR Z,hww54
	LD A,26 ;атака не сходя с места
hww54	LD (IX+9),A
	LD (IX+12),D
	CALL HL_IX0
	CALL IXt_HL
hww51a	LD DE,16
hww51	ADD IX,DE
	DJNZ hww50
	RET

;------------ СКАНИРОВАНИЕ ДЛЯ ВРАГА --------

kSCAN	;*** сканируet враг ***
	CALL Q1SORT ;сканирование воинов
	CALL loop_K
kww0	LD A,(IX+0)
	OR A
	JR Z,kww1
	LD A,(IX+9) ;сканировать для 0,3,28
	OR A
	JR Z,kww3c
	CP 3
	JR Z,kww3a
	CP 28
	JR NZ,kww1
kww3a	LD HL,QSCt1m ;п/п для атакующих
	LD A,(IX+13)
	CP 6
	JR C,kww3
	CALL kwwMAG
	JR kww1a
kww3c	LD A,(IX+4) ;катапульты - всегда максимальн скан
	CP 7
	JR Z,kww3a
	CP 16
	JR Z,kww3a
	LD HL,QSCt1 ;п/п для охраны
kww3	LD (QSC+1),HL
	LD E,#FF ;E=мин дист
	CALL hwwSCA
	LD A,E
	CP #FF
	JR NC,kww1a ;в поле зрения не было никого
	;иначе атаковать цель D
	CALL HELPme ;норм.атака + помощь
kww1a	LD DE,16
kww1	ADD IX,DE
	DJNZ kww0
	;;
kwwH	LD A,(TIC) ;50%
	RRCA
	RET NC
	CALL QH1SRT;сканирование зданий
	LD HL,QSCt1H
	LD (QSC+1),HL
	  CALL loop_K
kww50	LD A,(IX+0)
	OR A
	JR Z,kww51
	LD A,(IX+9)
	OR A
	JR NZ,kww51
	LD A,(IX+13)
	CP 6
	JR NC,kww51 ;волшебники/крестьяне не атакуют
	LD E,#FF ;E=мин дист
	CALL hwwSCA ;cканировать, если текущ действия 0
	LD A,E
	CP #FF
	JR NC,kww51a ;в поле зрения не было никого
	;иначе атаковать цель D
	LD (IX+9),28 ;норм.атака (м.быть прервана)
	LD (IX+12),D
	CALL HL_IX0
	CALL IXt_HL
kww51a	LD DE,16
kww51	ADD IX,DE
	DJNZ kww50
	RET

kwwMAG	CP 10 ;IX+13
	RET C ;крестьяне не сканируют
	LD HL,QSCt1W ;п/п для волшебников
	LD (QSC+1),HL
	LD E,#FF ;E=мин дист
	CALL hwwSCA
	LD A,E
	CP #FF
	JR Z,kwwM1
	CP 10 ;миним. расст. сближения
	JP NC,IX_98 ;близко - никого
	LD A,R
	LD HL,deMRCH ;ск.отступл - зависит от DIFFIC
	AND (HL)
	JP NZ,IX_98
	LD HL,(pntX)
	CALL IXt_HL
	JP IX_93
kwwM1	LD A,R
	AND %11101 ;компенс глюков 8х8 :-(
	RET NZ
	JP IX_98

HELPme	;позвать на помощь врагов
	LD A,(DIFFIC)
	ADD A,A
	ADD A,A
	ADD A,6
	LD (HLPrng+1),A
	PUSH BC
	PUSH IX
	CALL HL_IX0 ;коор ц
	LD C,D	    ;N ц
	CALL loop_K
hme0	LD A,(IX+0)
	OR A
	JR Z,hme1
	 LD A,(IX+13) ;не звать волшебников/крестьян
	 CP 6
	 JR C,hme7
	 LD A,(IX+9)
	 CP 4
	 JR NC,hme1 ;0..3->0, остальные действуют
	 CALL IX_98
	 JR hme1
hme7	LD A,(IX+9) ;звать на помощь, если тек действия 0,3,28
	OR A
	JR Z,hme2
	CP 3
	JR Z,hme2
	CP 28
	JR NZ,hme1
hme2	PUSH BC
	CALL DIST2
	CALL HLPrng ;дальность
	JR NC,hme10
	LD (IX+12),C
	LD (IX+9),4 ;немедл нападение
	PUSH HL
	CALL HL_IX0
	CALL IXt_HL
	POP HL
	LD A,(IX+13)
	CP 1
	CALL Z,ZAMENA
	 LD A,(levTYP) ;на нач уровнях засада переходит в атаку
	 OR A
	 JR Z,hme10
	 LD (IX+13),3
hme10	POP BC
hme1	ADD IX,DE
	DJNZ hme0
	POP IX
	POP BC
	RET

actRUN	;атакующим убегать?
	LD A,(levTYP)
	OR A
	RET NZ ;только на обычн уровнях
	LD A,(DIFFIC)
	XOR %110111
	LD L,A
	LD A,R
	AND L
	RET NZ
	JR OUTme

isRUN	;охране убегать?
	LD A,(TIC)
	AND 63
	CP 48
	RET NC
	ADD A,48
	CALL N_IX
	LD A,(IX+0)
	OR A
	RET Z
	LD A,(IX+13)
	CP 1
	RET NZ
	;охр
	LD L,(IX+14)
	LD H,(IX+15)
	CALL DIST2
	CP 6
	RET C
	LD A,R
	AND %101110
	RET NZ
	;
OUTme	;отступаем!!!
	PUSH IX
	CALL HL_IX0 ;коор ц
	CALL loop_K
ome0	LD A,(IX+0)
	OR A
	JR Z,ome1
	LD A,(IX+4)
	CP 18
	JR NC,ome1 ;магические - не отступают
	PUSH BC
	CALL DIST2
	CP 9 ;радиус оповещения об отступлении
	JR NC,ome10
	 LD A,(IX+13)
	 CP 6
	 JR NC,ome10 ;не звать пеонов/волш
	PUSH HL
	CP 1
	JR NZ,ome3
	;охр. бегут
	LD L,(IX+14)
	LD H,(IX+15)
	JR ome31
ome3	;атакующ бегут
	LD (IX+13),2
	LD HL,(pntX)
ome31	CALL IXt_HL
	POP HL
	CALL IX_92
ome10	POP BC
ome1	ADD IX,DE
	DJNZ ome0
	POP IX
	RET

ZAMENA	;по возможности замени охранника
	PUSH IX
	LD L,(IX+14)
	LD H,(IX+15)
	LD C,(IX+4)
	CALL loop_K
zmn0	LD A,(IX+0)
	OR A
	JR Z,zmn1
	LD A,(IX+4) ;такой же?
	CP C
	JR NZ,zmn1
	LD A,(IX+13) ;из нов отряда?
	CP 2
	JR NZ,zmn1
	LD (IX+14),L
	LD (IX+15),H
	DEC (IX+13) ; -> охр
	POP IX
	LD (IX+13),3 ;охр -> атак
	RET
zmn1	ADD IX,DE
	DJNZ zmn0
	POP IX
	RET

;----сканир: вспом.процедуры ----------------

QSCt1H	;cкан одного квадрата 8Х8 (поиск наших зданий)
	PUSH HL ;\\ в квадрате враг
	PUSH BC
	INC H ;=BUF512/256
qskh10	LD L,A
	PUSH HL ;\\\
	DEC L
	LD A,(HL) ;=номер врага
	LD C,A
	PUSH IX
	AND #7F
	CALL B_IX
	CALL HL_IX0
	LD A,(IX+2)
	POP IX
	CALL DISTsH
	CP E
	JR NC,qskh20
	CP 7 ;радиус сканирования здания!
	JR NC,qskh20 ;вне досягаемости
qskh11	LD E,A
	LD D,C
qskh20	POP HL	;///
	LD A,(HL)
	OR A
	JR NZ,qskh10
	POP BC
	POP HL ;//
	RET

QSCt1	;cкан одного квадрата 8Х8 (поиск наших вражеской охраной)
	PUSH HL ;\\ в квадрате враг
	PUSH BC
	INC H ;=BUF512/256
qsk10	LD L,A
	PUSH HL ;\\\
	DEC L
	LD A,(HL) ;=номер врага
	LD C,A
	PUSH IX
	CALL N_IX
	LD HL,ksSCAN
	CALL gPAR
	LD B,A
	CALL HL_IX0
	POP IX
	PUSH BC
	CALL DIST2
	POP BC
	CP B ; Зона досяг врага (зависит от типа обнаруженного воина)
	JR NC,qsk20 ;вне досягаемости
	CP E
	JR NC,qsk20
	LD E,A
	LD D,C
qsk20	POP HL	;///
	LD A,(HL)
	OR A
	JR NZ,qsk10
	POP BC
	POP HL ;//
	RET

QSCt1W	;cкан одного квадрата 8Х8 (поиск волшебниками врага)
	PUSH HL ;\\ в квадрате враг
	PUSH BC
	LD B,11 ;величина зоны+1 сканирования
	JR qsk10w
QSCt1m	;cкан одного квадрата 8Х8 (поиск наших идущими в атаку)
	PUSH HL ;\\ в квадрате враг
	PUSH BC
	LD B,9	;величина зоны+1 сканирования
qsk10w	INC H ;=BUF512/256
qsk10m	LD L,A
	PUSH HL ;\\\
	DEC L
	LD A,(HL) ;=номер врага
	LD C,A
	PUSH IX
	CALL N_IX
	CALL HL_IX0
	POP IX
	PUSH BC
	CALL DIST2
	POP BC
	CP B ; Зона досяг врага
	JR NC,qsk20m ;вне досягаемости
	CP E
	JR NC,qsk20m
	LD E,A
	LD D,C
qsk20m	POP HL	;///
	LD A,(HL)
	OR A
	JR NZ,qsk10m
	POP BC
	POP HL ;//
	RET


QSCt2H	;cкан одного квадрата 8Х8 (поиск вражих зданий)
	PUSH HL ;\\ в квадрате враг
	PUSH BC
	INC H ;=BUF512/256
qsch10	LD L,A
	PUSH HL ;\\\
	DEC L
	LD A,(HL) ;=номер врага
	LD C,A
	PUSH IX
	AND #7F
	CALL B_IX
	CALL HL_IX0
	LD A,(IX+2)
	POP IX
	CALL DISTsH
	CP E
	JR NC,qsch20
	LD B,A
	LD A,(IX+4)
	LD HL,sSCAN
	CALL BA
	CP 8
	JR NC,qschkt
	CP B
	JR C,qsch20 ;вне досягаемости
qsch11	LD E,B
	LD D,C
qsch20	POP HL	;///
	LD A,(HL)
	OR A
	JR NZ,qsch10
	POP BC
	POP HL ;//
	RET
	;
qschkt	;для катап
	LD A,B
	CP 3
	JR C,qsch20 ;слишком близко
	CP 9
	JR NC,qsch20 ;слишком далеко
	JR qsch11


QSCt2	;cкан одного квадрата 8Х8 (поиск врагов)
	PUSH HL ;\\ в квадрате враг
	PUSH BC
	INC H ;=BUF512/256
qsc10	LD L,A
	PUSH HL ;\\\
	DEC L
	LD A,(HL) ;=номер врага
	LD C,A
	PUSH IX
	CALL N_IX
	CALL HL_IX0
	LD (en_IX),HL
	POP IX
	CALL DIST2
	CP E
	JR NC,qsc20
	LD B,A
	LD A,(IX+4)
	LD HL,sSCAN
	CALL BA
	CP 8
	JR NC,qcs_kt
	CP B
	JR C,qsc20 ;вне досягаемости
qsc11	LD E,B
	LD D,C
qsc20	POP HL	;///
	LD A,(HL)
	OR A
	JR NZ,qsc10
	POP BC
	POP HL ;//
	RET
	;
qcs_kt	;для катап
	LD A,B
	CP 3
	JR C,qsc20 ;слишком близко
	CP 9
	JR NC,qsc20 ;слишком далеко
	PUSH DE
	CALL qscOWN
	POP DE
	JR Z,qsc20 ;наши рядом
	JR NZ,qsc11


DISTsH	;DIST2 для здания при сканировании (A-тип здания)
	CP 8
	JR Z,dhh1
	CP 18
	JR Z,dhh1
	;для обычн зданий
dhh0	CALL DIST2
	DEC A
	RET
dhh1	;для хибар и изб
	LD A,L
	CP (IX+0)
	JP C,DIST2
	LD A,H
	CP (IX+1)
	JP C,DIST2
	JR dhh0

qscOWN	LD HL,(en_IX) ;есть ли рядом наши (NZ/Z-нет/есть)
humOWN	DEC H ;для катапульты
	DEC L
	CALL GMAP2
	CALL qscOW1
	CALL qscOW1
	CALL qscOW1
	LD DE,61
	ADD HL,DE
	CALL qscOW1
	INC L
	CALL qscOW1
	ADD HL,DE
	CALL qscOW1
	CALL qscOW1
	CALL qscOW1
	INC A ;nz
	RET ;!!

qscOW1	LD A,(HL)
	INC L
	CP #80
	RET C
	CP #B0
	RET NC
	POP HL ;!!
	XOR A
	RET ; z- нельзя стрелять


        macro qsKs
	LD A,(HL)
	CP #B0
	RET NC ;nc-нельзя стрелять
	ENDM

qkkOWN	LD HL,(en_IX) ;есть ли рядом враги (С/NC-нет/есть)
kunOWN	DEC H ;для катапульты
	DEC L
	CALL GMAP2
	qsKs
	INC L
	qsKs
	INC L
	qsKs
	LD DE,62
	ADD HL,DE
	qsKs
	INC L
	INC L
	qsKs
	ADD HL,DE
	qsKs
	INC L
	qsKs
	INC L
	LD A,(HL)
	CP #B0
	RET ;nc/C

;-------скан с соблюд граничн условий

        macro QSCs
	LD A,(HL)
	OR A
	CALL NZ,QSC
	ENDM

QSC_0	LD A,L
	SUB 9
	LD L,A
	QSCs
	INC L
	QSCs
	INC L
	QSCs
	LD A,L
	ADD A,6
	LD L,A
	QSCs
	INC L
	QSCs
	INC L
	QSCs
	LD A,L
	ADD A,6
	LD L,A
	QSCs
	INC L
	QSCs
	INC L
	QSCs
	RET
	;
hwwSCA	CALL QNUM ;выбор П/П сканирования
	CP 8
	JR C,hwwTOP
	CP 56
	JR NC,hwwBOT
	AND 7
	JR Z,QSC_4
	CP 7
	JR NZ,QSC_0
	JR QSC_5
hwwTOP	OR A
	JP Z,QSC_1
	CP 7
	JR NZ,QSC_2
	JR QSC_3
hwwBOT	JR Z,QSC_6
	CP 63
	JR C,QSC_7
	JR QSC_8
	;
QSC_5	LD A,L
	SUB 9
	JR QSC_4a
QSC_4	LD A,L
	SUB 8
QSC_4a	LD L,A
	QSCs
	INC L
	QSCs
	LD A,L
	ADD A,7
	LD L,A
	QSCs
	INC L
	QSCs
	LD A,L
	ADD A,7
	LD L,A
	QSCs
	INC L
	QSCs
	RET
	;
QSC_2	DEC L
	JR QSC_7a
QSC_7	SUB 9
	LD L,A
QSC_7a	QSCs
	INC L
	QSCs
	INC L
	QSCs
	LD A,L
	ADD A,6
	LD L,A
	QSCs
	INC L
	QSCs
	INC L
	QSCs
	RET

QSC_8	SUB 9
	LD L,A
	JR QSC_1
QSC_6	SUB 8
	LD L,A
	JR QSC_1
QSC_3	DEC L
QSC_1	QSCs
	INC L
	QSCs
	LD A,L
	ADD A,7
	LD L,A
	QSCs
	INC L
	QSCs
	RET

;-------------------------------------------------
;--------- ВРАЖЕСКИЙ ИНТЕЛЛЕКТ -------------------
;-------------------------------------------------
kPROF	DEFW AI00,AI01,AI02,AI03,AI04,AI05,AI06,AI07,AI08
	DEFW AI09
	DEFW AI10,AI11, AI12,AI13,AI14, AI15,AI16,AI17

kINTEL	LD A,(IX+13) ;занять работой
	LD HL,kPROF
	CALL WT
	JP (HL)

AI00	;none
	;\
AI01	;охранник возвращается на старт-позицию
	LD L,(IX+14)
	LD H,(IX+15)
	CALL DIST2
	OR A
	RET Z
	;go home
	CALL IXt_HL
	JP IX_93

AI09	;
AI04	;
AI05	;
AI02	;произведённый воин - идёт к точке сбора
	RET

AI03	;воин идёт к цели
	CALL AI03_
	RET Z
	JP ZZ3
	;
AI03_	LD A,(pntTAR)
	CP #FF
	RET Z ;цель не выбрана
	PUSH IX
	CP #80
	JR NC,ai03a
	CALL N_IX ;цель-человек
	JR ai03b
ai03a	AND #7F
	CALL B_IX ;цель-здание
ai03b	CALL HL_IX0
	LD A,L
	OR A
	POP IX
	RET Z; цель погибла
	CALL IXt_HL
	JP IX_93 ;nz


AI08	;peмонтник
	RET


AI06	;рубка леса
	LD A,(IX+4)
	CP 9
	JR C,ai06a
	SUB 9
ai06a	OR A
	JP NZ,basTAR ;с дровами _ вали на базу
	;ищи лес
	LD B,8 ;-к-во попыток поиска
ai060	CALL R_awa_
	CALL HL_IXt
	CALL GMAP
	LD A,(HL)
	AND #7F
	CP 61
	JR C,ai06b
	CP 63
	JR C,ai06C
ai06b	DJNZ ai060
ai06C	LD (IX+9),6
	RET

AI07	;поход за золотом
	LD A,(IX+4)
	CP 9
	JR C,ai07a
	SUB 9
ai07a	OR A
	JP NZ,basTAR ;c мешком - вали на базу
	;ищи шахту поближе
	CALL HL_IX0
	LD C,#FF ;миним расст
	PUSH IX
	LD B,8
	LD DE,8
	LD IX,MINE
ai070	LD A,(IX+0)
	OR A
	JR Z,ai071
	;расст меньше минимального?
	PUSH BC
	CALL DIST2
	POP BC
	CP C
	JR NC,ai071
	LD C,A
	LD (en_IX),IX
ai071	ADD IX,DE
	DJNZ ai070
	LD A,C
	CP #FF
	JR NZ,ai072
	;некуда идти
	POP IX
	LD (IX+13),6 ;стань лесорубом
	JP IX_98
ai072	;идти на ближайшую шахту
	LD IX,(en_IX)
	CALL HL_IX0
	POP IX
	CALL IXt_HL
	LD (IX+9),7
	LD (IX+8),#80
	RET

