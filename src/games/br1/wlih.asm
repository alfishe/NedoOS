;------главный цикл обработки персонажей

MOVZZ	;п/п обр действий ix+9
	DEFW ZZ0,ZZ1,ZZ2,ZZ3,ZZ4,ZZ5,ZZ6,ZZ7,ZZ8,09
	DEFW ZZ10,ZZ11,ZZ12,ZZ13,ZZ14,ZZ15
	DEFW ZZ16,ZZ17,ZZ18,ZZ19,ZZ20,ZZ21
	DEFW ZZ22,ZZ23,ZZ24,ZZ25,ZZ26,ZZ27
	DEFW ZZ28

impANS	;ответ на удар (0/х-нет/функция) при действии N
	DEFB 4,26,0,4,0,4,4,4,4,4
	DEFB 0,0,0,0,0,0
	DEFB 0,0,0,0,0,0
	DEFB 0,0,0,4,0,0
	DEFB 4


SHED_H	LD IX,HUMAN ;Л*Ю*Д*И
	LD IY,XY
	XOR A
	LD (HER_N),A
	LD (SIDE_N),A
	;
	LD A,#C9 ;ret
	LD (ZZ00),A ;intel=off
	LD (ARCrng),A ;лучники vs катапульта=off
	LD A,9 ;дальность для наших катап=8
	LD (KATrng+1),A
	;
She0	LD A,(IX+1)
	OR A
	JR Z,She1
	LD A,(IX+0)
	OR A
	CALL Z,SheTro
	CALL NZ,MOVING
She1	LD BC,16
	ADD IX,BC
	LD C,4
	ADD IY,BC
	LD HL,HER_N
	INC (HL)
	LD A,(HL)
	CP 48
	JP C,She0
	RET

SHED_K	;К*У*Н*Г*И
	LD HL,SIDE_N
	INC (HL)
	LD A,#C3 ;jp: intel=ON
	LD (ZZ00),A
	 LD A,(DIFFIC)
	 OR A
	 JR Z,Ske0x
	 ;повышенная сложность (DIFFIC=1)
	 LD A,7
	 LD (KATrng+1),A ;дальность для катап врага=6
	 LD A,#C3 ;jp
	 LD (ARCrng),A ;лучники vs катап=ON
Ske0x	;
Ske0	LD A,(IX+1)
	OR A
	JR Z,Ske1
	LD A,(IX+0)
	OR A
	CALL Z,SheTro
	CALL NZ,MOVING
Ske1	LD BC,16
	ADD IX,BC
	LD C,4
	ADD IY,BC
	LD HL,HER_N
	INC (HL)
	LD A,(HL)
	CP 96
	JP C,Ske0
	RET

NxtTro	;след  фаза трупa
	DEFB #FF,0,1,2 ,#FF,4,5,6, #FF,9,8, 12,#FF,12,12,12, #FF,#FF
SheTro	;гниение трупов
	DEC (IX+3)
	JR NZ,ShtRt
	LD HL,NxtTro
	CALL gPAR
	CP #FF
	JR NZ,SheT1
	LD (IX+1),0
	JR ShtRt
SheT1	CALL NZ,TrooTi
ShtRt	XOR A
	RET

;------------обработка пленников
SHED_p	;П*Л*Е*Н*Н*И*К*И
	LD A,#C9 ;ret - intel off
	LD (ZZ00),A
	;
	LD A,(TIC)
	DEC A
	AND %11
	RET NZ ;раз в 4 такта
Spe0	LD A,(IX+1)
	OR A
	JR Z,Spe1
	LD A,(IX+0)
	OR A
	CALL Z,SheTro
	CALL NZ,PRISON
Spe1	LD BC,16
	ADD IX,BC
	LD HL,HER_N
	INC (HL)
	LD A,(HL)
	CP 102
	JP C,Spe0
	RET

isFRND	;по адр HL в GMAP2 - свой? (вых через POP)
	LD A,(HL)
	INC L
	CP #80
	RET C
	CP #B0
	RET NC
	POP AF ;!!
	LD C,(IX+5)
	LD B,(IX+2)
	PUSH IX
	PUSH BC
	LD A,(HER_N)
	CALL deSEL
	LD A,(IX+4)
	EX AF,AF
	CALL HL_IX0
	CALL IXt_HL
	XOR A
	CALL NEWHER
	POP BC
	JR NZ,iFRn ;mem?
	LD (IX+5),C
	LD (IX+2),B
iFRn	POP IX
	RET NZ ;нет памяти
	;звёзды-пленник свободен
	PUSH IY
	CALL HL_IX0
	PUSH HL
	LD HL,00
	CALL IX0_HL
	POP HL
	CALL NEWB09
	POP IY
	JP EVENT

PRISON	LD L,A
	LD H,(IX+1)
	LD A,(IX+5)
	OR A
	JR Z,Kill ;убитый
	DEC L
	DEC H
	CALL GMAP2
	CALL isFRND
	CALL isFRND
	CALL isFRND
	LD DE,61
	ADD HL,DE
	CALL isFRND
	INC L
	CALL isFRND
	ADD HL,DE
	CALL isFRND
	CALL isFRND
	CALL isFRND ;!!
	RET

;---------------------------
KilNxt	DEFB 3,3,3,3,3,3,3,17,3
	DEFB 7,7,7,7,7,7,7,17,7
	DEFB 13,15,14,11,3,7, 10,10,10
Kill	;убить героя по состоянию здоровья
	LD A,(IX+7);проверить магию 'хруст. шара'
	AND %11111000
	CP  %00010000
	JR Z,noKill
	 ;труп деморализует - убегать?
	 LD A,(SIDE_N)
	 OR A
	 CALL NZ,actRUN
	LD A,(HER_N)
	CALL deSEL ;отменить пометку
	CALL EVENT ;событие
	CALL HL_IX0
	RES 7,H ;если смерть наступила в здании
	CALL IXt_HL
	CALL GMAP2
	XOR A
	LD (HL),A
	LD (IX+0),A
	LD A,(IX+4)
	CP 8
	JR Z,Ki33
	CP 17
	JR NZ,Ki2
Ki33	PUSH IY
	POP HL
	LD A,(HL)
	ADD A,4 ;сдвинуть изобр трупа конников
	LD (HL),A
	JR NC,Ki1
	INC HL
	INC (HL)
Ki1	LD A,(IX+4)
Ki2	LD HL,KilNxt ;нач ф гниения
	CALL BA
	;
TrooTi	;время гниения фазы A
	LD (IX+4),A
	LD HL,TimTro
	CALL BA
	LD (IX+3),A
	RET
TimTro	;время гниения фазы
	DEFB 50,60,60,70, 50,60,60,70, 1,1,1, 50,40,50,50,50, #1,80

;------------------------------
MOVING	;обр.команд живых людей
	LD A,(IX+5)
	OR A
	JR Z,Kill ;убитый
noKill	LD A,(IX+3)  ;
	OR A	     ;
	JR Z,IX3_0   ;
	CALL HERMOV  ;
	LD A,(IX+3)
	OR A
	RET NZ
IX3_0	LD A,(IX+9)
	LD HL,MOVZZ
	CALL WT
	JP (HL)

;-----параметры удара/защиты--

gB_FRC	;получить силу снаряда
	LD HL,BFORCE-1
	LD A,(IY+4)
	JP  BA
gFORCE	;получить знач силы удара
	LD HL,FORCE
gPAR	LD A,(IX+4)
	JP BA

gDEFEN	;получить знач защиты  (Вх/вых: C-удар)
	LD HL,DEFENC
	CALL gPAR
	LD L,A
	LD A,R
	AND %11
	CP L
	RET NC
	INC C ;уменьш силу удара на 50%
	SRA C
	RET

;------нанесение ударов ---
cMPACT	;удар катапульты (9клеток)
	LD L,(IY+5)
	LD H,(IY+6)
	PUSH HL
	CALL GMAP2
	LD A,(HL)
	POP HL
	CP #38
	JR C,ccM0
	CP #80
	RET C ;при ударе в здание - только в центр
ccM0	DEC L
	DEC H
	LD C,3
ccM1	PUSH HL
	LD B,3
ccM2	PUSH BC
	PUSH HL
	CALL _sMPAC
	POP HL
	POP BC
	INC L
	DJNZ ccM2
	POP HL
	INC H
	DEC C
	JR NZ,ccM1
	RET Z

buPACT	;удар по зданию
	CALL gFORCE
	LD C,A
	PUSH IX
	LD IX,(en_IX)
_uPACT	;уменьш энергии здания на С/8 .. (C+7)/8
	LD A,R
	AND #7
	ADD A,C
	LD C,A
	SRL C
	SRL C
	SRL C
	LD A,(IX+3)
	SUB C
	JR NC,smpi0
	XOR A
smpi0	LD (IX+3),A
	 LD A,(HER_N) ;on индик0|3
	  LD D,A
	 AND #7F
	 CP #30
	 LD A,1
	 JR NC,smpi31
	 LD (LED+3),A
	  LD A,R
	  AND %1111
	  CALL Z,HELPme ;обижают здание врага
	  JR smpi3
smpi31	 LD (LED+0),A
smpi3	POP IX
	RET

sMPACT	;огн.дождь наносит удар
	LD L,(IY+5)
	LD H,(IY+6)
_sMPAC	LD A,(IY+7)
	LD (HER_N),A
	CALL GMAP2
	LD A,(HL)
	CP #80
	JR C,smpp1
	SUB #80 ;для врагов
	JR IMPB_
smpp1	CP 2
	RET C ;нельзя атаковать бордюр
	SUB #38
	JR C,smww1
smpp2	;(для враж.зданий)
	PUSH IX
	CALL B_IX
	LD (en_IX),IX ;/для FX
	CALL gB_FRC
	LD C,A
	JR _uPACT
	;
smww1	;возможно стена (видимая)
	RES 4,H
	LD A,(HL)
	AND #7F
	CP 64
	RET C
	CP 78
	RET NC
	CP 71
	JR C,smww2
	CALL RND
	RLCA
	RET NC ;50%
	LD DE,64
	PUSH HL
	ADD HL,DE ;удалить хвостик забора
	LD A,(HL)
	AND #7F
	CP 51
	JR NZ,smww3
	LD A,(HL)
	SUB 50
	LD (HL),A
smww3	POP HL
	LD DE,-64
	LD C,1
	PUSH HL ;если сверху забор - поставить хвостик
	ADD HL,DE
	LD A,(HL)
	AND #7F
	CP 64
	JR C,smww4
	CP 78
	JR NC,smww4
	LD C,51
smww4	POP HL
	LD A,(HL)
	AND #80
	ADD A,C
	LD (HL),A ;добить полуразрушенную
	SET 4,H
	LD (HL),0
	RET
smww2	CALL RND ;частично разрушить
	RLCA
	RET C ;50%
	LD A,(HL)
	ADD A,7
	LD (HL),A
	RET

BMPACT	;пуля наносит удар
	LD A,(IY+7)
	LD (HER_N),A
	CALL N_IX
	LD A,(IY+5)
	BIT 7,A
	JR NZ,smpp2
IMPB_	PUSH IX
	LD (en_A),A
	CALL N_IX
	LD (en_IX),HL
	CALL gB_FRC
	LD C,A
	JR IMPA_
	;
IMPACT	;наносится удар
	LD A,(en_A)
	CP #80	     ;здание?
	JP NC,buPACT
	;наносится удар врагу (en_IX)
	;c учётом защиты
	CALL RND
	AND 7
	JR Z,ipt0 ;1/8 - промах
	CALL gFORCE
ipt0	LD C,A
	PUSH IX
	;учесть защиту
	LD IX,(en_IX)
IMPA_	CALL gDEFEN	; - защита
	;понизить здоровье
	LD A,(IX+5)
	SUB C
	JR NC,ipt1
	XOR A
ipt1	LD (IX+5),A
	POP IX
	;следует ли отвечать потерпевшему?
	RET Z ;трупы не отвечают
	LD A,(en_A)
	CP #30
	LD A,(HER_N)
	JR NC,K_ANSW
	;ударили нашего
	CP #30
	RET C ;ударил наш нашего
	PUSH IX
	LD IX,(en_IX)
	CP #80
	 LD A,1
	 LD (LED+0),A ;индик0 on
	JR C,H_ANSW
	; ударило заклинание - убегать
	LD A,(IX+9)
	CP 2
	JR Z,ipt11 ;уже убегает
	LD A,R
	RRCA ;in 50%
	CALL C,R_away
	JR ipt11
H_ANSW	; ответн удар нашего
	CALL _ANSW
	CALL HL_IX0
	DEC L
	DEC H
	CALL GMAP2
	CALL ANSW1
	CALL ANSW1
	CALL ANSW1
	LD DE,61
	ADD HL,DE
	CALL ANSW1
	INC L
	CALL ANSW1
	ADD HL,DE
	CALL ANSW1
	CALL ANSW1
	CALL ANSW1
ipt11	POP IX
	RET
K_ANSW	;ответ врага
	AND #7F ;%1...
	CP #30
	RET NC ;враг ударил врага
	 LD A,1
	 LD (LED+3),A ;индик3 on
	CALL HL_IX0
	PUSH IX
	LD IX,(en_IX)
	LD A,(IX+9)
	CP 4
	JR NZ,kans2
	;cравнить с текущей целью и ударить
	CALL DIST2 ;до нового обидчика+1
	INC A
	LD C,A
	CALL HL_IXt
	CALL DIST2 ;до старой цели
	CP C
	JR C,ipt11
	CALL answ10
	JR ipt11
kans2	CALL answ09
	JR ipt11


ANSW1	;по адр HL в GMAP2 - свой? (вых через POP)
	LD A,(HL)
	INC L
	SUB #80
	RET C  ;нет (здание)
	CP #30
	RET NC ;нет (чужак)
	EXX ;сохр hl
	CALL N_IX
_ANSW	;направить ответный удар на обидчика (HER_N)
	LD A,(IX+9)
answ09	LD HL,impANS
	CALL BA
	OR A
	JR Z,answ11 ;возможен ответ на удар?
	LD (IX+9),A
answ10	LD A,(HER_N)
	AND #7F  ;%1...
	LD (IX+12),A
	LD (IX+8),#80
	CALL HL_IX0
	CALL IXt_HL
answ11	EXX
	RET


;ZZxx-----собств обработка
ZZ0	;cтоять
	CALL ZZsee0
	JP ZZ00 ;вызов интеллекта врагов
ZZ1	;стоять насмерть
	CALL ZZsee0
	RET

ZZsee0	LD A,#FF ;осмотреться после останова
	CP (IX+8)
	RET Z
	LD (IX+8),A
	JP ONSEE

ZZ27	;капульта атакует пустое место
	LD HL,WW07
	LD (JP_SUB+1),HL
	CALL HL_IXt
	JP ZZ4_
ZZ3	;идти в атаку
ZZ2	;просто идти
	CALL GO_MAN
	LD A,(IX+8)
	OR A
	JP NZ,ONSEE2
	LD (IX+9),A
	RET Z

WATACK	;адреса П/П обработки
	DEFW WW00,WW01,WW02,WW03,WW04,WW05,WW06,WW07,WW08
	DEFW WW09,WW10,WW11,WW12,WW13,WW14,WW15,WW16,WW17
	DEFW WW18,WW19,WW20,WW21,WW22,WW23,WW24,WW25,WW26

ZZ26	;Атака на цель, не покидая позиции
	;\
ZZ28	;Атака на цель, которая м.быть прервана
	;\
ZZ4	;Атака на цель
	LD A,(IX+4)
	LD HL,WATACK
	CALL WT
	LD (JP_SUB+1),HL
	LD A,(IX+12)
	;атака на врага
	PUSH IX
	LD (en_A),A
	BIT 7,A
	JR Z,ZZ4a
	CALL B_IX ;параметры вражеского здания
	LD (en_IX),IX
	CALL HL_IX0
	POP IX
	CALL DIST_H
	LD B,A
	JR ZZ4b
ZZ4a	CALL N_IX ;параметры врага
	LD (en_IX),HL
	CALL HL_IX0
	POP IX
	BIT 7,H
	JR NZ,IX_98a ;враг в здании
ZZ4_	CALL DIST2
	LD B,A
ZZ4b	LD A,L
	AND A
	JR Z,IX_98a ;враг мёртв
	LD A,B
	;в A-дистанция, в HL-коорд цели
	CALL JP_SUB ;!! м.быть вых.через POP, если враг рядом (оружие применено)
	LD A,(IX+9)
	CP 26
	JR Z,ZZ4_26
	PUSH HL ;преследовать,ecли цель далеко
	CALL GO_MAN
	POP HL
	CALL IXt_HL  ; "я умный!"
	LD A,(IX+8)
	OR A
	JP NZ,ONSEE2
	LD (IX+8),#80
	CALL GO_MAN
	LD A,(IX+8)
	OR A
	JP NZ,ONSEE2
	;цель слишком далеко и дороги к ней нет
	;
IX_98a	LD A,(IX+9)
	CP 26
	JP NZ,IX_98
ZZ4_26	;конец атаки на месте (26)
	;если цель мертва или далеко - снова стоять насмерть
	CALL IX_98
	INC (IX+9)
	RET


;WWxx - обработка действия 4 - атака
;........................
WW09	;пеоны
WW10
WW11
WW00	;крестьяне
WW01
WW02	LD A,(SIDE_N)
	OR A
	JR Z,R_away
	LD A,(DIFFIC)
	OR A
	JR Z,R_away
	LD HL,(pntX) ;бежать к точке сбора
	CALL IXt_HL
	JP IX_92
R_away	LD (IX+9),2 ;убегать случайно
R_awa_	LD (IX+8),#80
	LD C,(IX+0)
	CALL RNDshf
	LD (IX+10),A
	LD C,(IX+1)
	CALL RNDshf
	LD (IX+11),A
	RET

RNDshf	CALL RND ;нов коорд при убегании (C->A)
	AND %1111
	SUB 7 ;-7..8
	ADD A,C
	CP 63
	JR NC,RNDshf
	RET

WW22	;князь
WW23	;гризольда
	LD (IX+9),0
	RET
;........................
WW13	;кунг
WW17	;грюнвер
WW18	;паук
WW19	;скелет
WW20	;скорп
WW21	;звезда
WW24	;костолом
WW25	;демон
WW08	;всадник
WW04	;воин
	CP 2 ;дальность оружия
	RET NC
	EX DE,HL ;применить оружие
	CALL HL_IX0
	CALL DIR
	LD (IX+2),A
	CALL IMPIX3
	LD (IX+8),0
	CALL IMPACT
	POP AF
	JP ONSEE ;надо бы один раз :(

;........................
WW03	;лучник
	LD C,A
	LD A,(sRANGE+3)
	INC A
	INC A
	CALL ARCrng
	CP C
	RET C
	CALL WWFire
	CALL NEWB01
	POP HL ;dec sp
	RET

WW12	;лангольер c луком
	LD C,A
	LD A,(sRANGE+12)
	INC A
	INC A
	CALL ARCrng
	CP C
	RET C
	CALL WWFire
	CALL NEWB02
	POP HL ;dec sp
	RET

ARvsKT	;лучники врага против наших катап (если да и DIFFIC=1, то A=2)
	PUSH AF
	LD A,(IX+12)
	BIT 7,A
	JR NZ,arv1
	PUSH IX
	PUSH HL
	CALL N_IX
	LD A,(IX+4)
	POP HL
	POP IX
	CP 7
	JR Z,arv2
	CP 16
	JR Z,arv2
arv1	POP AF ;норм дист
	RET
arv2	POP AF
	LD A,2 ;катап - короткая дистанция
	RET

WWFire	EX DE,HL ;подготовиться применить оружие
	PUSH DE
	CALL HL_IX0
	PUSH HL
	CALL DIRF
	LD (IX+2),A
	CALL Z,ONSEE ;надо бы один раз :(
	POP HL
	CALL IMPIX3
	LD (IX+8),0
	POP DE
	RET

WW14	;\
WW05	;свящ/некром
	CP 3
	RET NC
	CALL WWmana
	CALL WWFire
	CALL NEWB03
	JR WW06a
WW15	;\
WW06	;волш/варлок
	CP 5
	RET NC
	CALL WWmana
	CALL WWFire
	CALL newb05
WW06a	 LD A,6      ;FX
	 CALL SOUNDn ;
	POP HL;dec sp
	RET

WWmana	;уменьш маны при стрельбе (no mana - 2xPOP,RET)
	LD A,(IX+6)
	SUB 3 ;декремент mana
	JR C,WWma1
	LD (IX+6),A
	RET
WWma1	POP HL ;!!
	POP DE ;!!
	RET

WW16	;\
WW07	;катапульта
	CALL KATrng
	RET NC
	CP 3
	LD A,(SIDE_N)
	JR C,WW07b
	;(проверь вокруг)
	OR A
	JR NZ,WW07d
	;наша кат не порань наших
	BIT 7,(IX+12)
	JR NZ,WW07c
	PUSH HL
	CALL humOWN ;nz - можно стрелять
	POP HL
	JR NZ,WW07c
	JR Z,WW07a1 ;смени цель
WW07d	;враг не порань врага
	BIT 7,(IX+12)
	JR NZ,WW07c  ;огонь по зданию
	PUSH HL
	CALL kunOWN ;C - можно стрелять
	POP HL
	CALL NC,IX_98
	JR NC,WW07a ;cмени цель
WW07c	CALL WWFire
	CALL NEWB06
	CALL onsee2
	  LD A,4      ;FX
	  CALL SOUNDn ;
	LD A,(IX+9)
	CP 27 ;режим одиночного выстрела?
WW07a1	CALL Z,IX_98a
WW07a	POP HL ;dec sp
	RET
WW07b	OR A
	JR Z,WW07a
	LD A,(IX+8)
	OR A
	RET NZ
	JP R_awa_ ;вражеская катапульта умеет отъезжать

WW26	;стеногр
	CP 4
	RET NC
	CALL WWFire
	CALL NEWB07
	 LD A,5 	;FX
	 CALL SOUNDn	;
	POP DE ;dec sp
	RET

;---ix+9-ф-ции-крестьян---
ZZ5	;идти на базу
	CALL HL_IXt
	CALL DIST2
	CP 3
	JP NC,ZZ2
	CALL GMAP
	LD A,(HL)
	AND #7F
	;база ещё не разрушена?
	CP 86
	JR Z,ZZ5a
	CP 100
	JP NZ,IX_98
ZZ5a	;чья база?
	LD A,(SIDE_N)
	OR A
	JR Z,ZZ5hum
	;кунгов
	CALL deGRUZ
	;(принять ресурсы врага)
	JR ZZ5ex
ZZ5hum	;людей
	CALL deGRUZ
	LD DE,#100
	PUSH AF
	CALL Z,aWOOD
	POP AF
	CALL NZ,aMONEY
ZZ5ex	LD (IX+9),24
	LD (IX+3),#80+10;время нахожд. на базе
ZZ57	CALL HL_IX0
	CALL GMAP2
	LD (HL),0
	LD A,(HER_N)
	CALL deSEL
	CALL EVENT
	JP unseeM


deGRUZ	;разгрузить (Z/NZ - был лес/золото)
	LD A,(IX+4)
	CP 9
	JR C,dgu1
	SUB 9
dgu1	DEC A
	RET

ZZ6	;идти за лесом
ZZ61	CALL GO_MAN
	LD A,(IX+8)
	OR A
	PUSH AF
	CALL NZ,ONSEE2
	POP AF
	JR Z,ZZ6A
	BIT 7,(IX+3)
	RET Z
	CALL HL_IXt
	CALL DIST2
	CP 6 ;макс дистанция до леса
	RET NC
ZZ6A	;есть ли рядом лес?
	LD (IX+3),0
	LD A,(IX+2)
	CALL isTREE
	JR C,ZZ6B ;он перед носом
	LD B,8
ZZ6a1	LD A,B
	DEC A
	CALL isTREE
	JR C,ZZ6B_
	DJNZ ZZ6a1
	;поискать поблизости
	LD BC,60*256+8
ZZ6a2	LD A,C
	CALL isTREE
	JR C,ZZ6a4
ZZ6a6	INC C
	DJNZ ZZ6a2
	;не нашли - стоп
	JP IX_98
ZZ6a4	LD A,C ;нашли рядом - идти
	LD HL,GO_Ntb
	CALL WT
	LD A,(IX+0)
	ADD A,L
	LD L,A
	CP 63
	JR NC,ZZ6a6 ;вне карты
	LD A,(IX+1)
	ADD A,H
	LD H,A
	CP 63
	JR NC,ZZ6a6 ;вне карты
	CALL IXt_HL
	LD (IX+8),#80
	CALL GO_MAN
	LD A,(IX+8) ;перед лесом препятствие
	OR A
	JP Z,IX_98
	RET NZ
ZZ6B_	DEC B
	LD (IX+2),B
ZZ6B	;приступить к рубке леса
	CALL ONSEE
	LD (IX+9),25
	LD (IX+8),0
	LD A,(BrWOOD) ;кол_во ударов по дереву
	LD (IX+12),A
	RET

ZZ7	;идти за золотом в шахту
	CALL HL_IXt
	CALL DIST2
	CP 3
	JP NC,ZZ2
	CALL GMAP
	LD A,(HL)
	AND #7F
	;шахта ещё не разрушена?
	CP 78
	JP NZ,IX_98
ZZ7a	;вычет денег из шахты
	SET 4,H
	PUSH IX
	LD A,(HL)
	SUB #38
	CALL B_IX
	LD L,(IX+4)
	LD H,(IX+5)
	DEC HL
	LD (IX+4),L
	LD (IX+5),H
	LD A,L
	OR H
	JR NZ,ZZ7b
	LD (IX+3),A ;разрушЬ шахту
ZZ7b	CALL HL_IX0
	POP IX
	LD (IX+14),L ;запомнить коорд шахты
	LD (IX+15),H
	LD (IX+9),23
	LD (IX+3),#80+15;время нахожд. в шахте
	JP ZZ57

ZZ8	;идти на стр-во
	CALL DISTpH
	;подошли к зданию?
	CP 2
	JP NC,ZZ2
	;начать стройку/ремонт
	PUSH IX
	CALL HL_IXt
	CALL GMAP2
	LD A,(HL)
	SUB #40 ;шахты не чинить
	JR C,ZZ8_0
	CP 64
	JR NC,ZZ8_0
	ADD A,8
	CALL B_IX
	LD A,(IX+0)
	OR A
	JR NZ,ZZ8_1
	;здания нет
ZZ8_0	POP IX
	JP IX_98
ZZ8_1	LD A,(IX+4)
	CP 253
	JR Z,ZZ8_2
	CP 254
	JR Z,ZZ8_2
	;ремонт
	LD A,(IX+2)
	LD HL,bHEALT
	CALL BA
	CP (IX+3)
	JR Z,ZZ8_0 ;ремонт не нужен
	LD A,(SIDE_N)
	OR A
	JR NZ,ZZ8k ;для врага - бесплатно
	LD DE,#02
	LD BC,#03
	CALL dMN_WD ;для наших - уменьшить MN/WD
	JP C,ZZ8n
ZZ8k	INC (IX+3)
	POP IX
	CALL HL_IXt ;направить удар ремонтника
	EX DE,HL
	CALL HL_IX0
	CALL DIR
	LD (IX+2),A
	JP IMPIX3
ZZ8n	POP IX;нет средств на ремонт
	CALL nMN_WD
	JP IX_98
ZZ8_2	;cтройка
	LD A,(IX+7)
	INC A
	JR NZ,ZZ8_0 ;строитель уже есть
	LD A,(HER_N)
	LD (IX+7),A
	POP IX
	CALL HL_IX0
	CALL GMAP2
	LD (HL),0
	CALL HL_IXt
	CALL IX0_HL
	LD (IX+9),22
unseeM	;сделать человека невидимым
	SET 7,(IX+1)
	SET 7,(IY+1)
	RET

DISTpH	;расст до здания для крестьян
	CALL HL_IXt
DIST_H	CALL DIST2 ;-""- для воинов
	CP 3
	RET NC
	PUSH HL
	PUSH AF
	CALL GMAP2
	LD A,(HL)
	SUB #38
	PUSH IX
	CALL B_IX
	CALL HL_IX0
	LD A,(IX+2)
	POP IX
	CP 8
	JR Z,ddp1
	CP 18
	JR Z,ddp1
ddp_0	POP AF
	POP HL
	DEC A
	RET
ddp1	LD A,L
	CP (IX+0)
	JR C,ddp_1
	LD A,H
	CP (IX+1)
	JR NC,ddp_0
ddp_1	POP AF
	POP HL
	RET

;----допустимость применения магии---

ZZddin	;опред дистанции до движ цели
	LD A,(IX+12)
	PUSH IX
	CALL N_IX ;параметры врага
	LD (en_IX),HL
	CALL HL_IX0
	POP IX
	CALL IXt_HL
	LD A,L
	OR A
	JR Z,_ex98 ;цель погибла
	BIT 7,H
	JR NZ,_ex98 ;цель в здании
	CALL DIST2
	JR ZZd1

ZZdist	CALL HL_IXt ;опредление дистанции
	CALL DIST2
	OR A
	JR Z,_ex98
ZZd1	CP 9 ;дистанция до объекта магии-1
	RET C
	POP HL ;!!
	JP NC,ZZ2 ;цель далеко

isMANA	;есть волш энергия? (С)
	LD A,(IX+6)
	SUB C
	JR C,noMANA
	LD (IX+6),A
	RET
noMANA	LD A,(SIDE_N)
	OR A
	CALL Z,pb07
_ex98	POP HL ;!!
	JP IX_98

;------ix+9---магия волш-------

ZZ12	;cтеногрыз
	LD BC,MANA-1+#1A00
	JR ZZ10a
ZZ13	;паук
	LD BC,MANA/4+#1200
	JR ZZ10a
ZZ15	;демон
	LD BC,MANA-1+#1900
	JR ZZ10a

ZZ10	;cкорп
	LD BC,MANA/4+#1400
ZZ10a	;пров. возможность
	LD A,(IX+6)
	SUB C
	JP C,IX_98
	LD (IX+6),A
	;родить чудище
	PUSH IX
	PUSH IY
	LD A,B
	EX AF,AF
	CALL HL_IX0
	CALL stayON
	CALL NEWB09 ;звёзды
	LD A,(SIDE_N)
	CALL NEWHER
	JR NZ,ZZ10b ;mem?
	LD (IX+13),3;чудище->в атаку
	CALL HL_IX0
ZZ10b	POP IY
	POP IX
	JP NZ,IX_98 ;нет памяти
	JR ZZ_En2

ZZ14	;смерч
	CALL ZZdist
	LD A,(TIC)
	AND 7
	RET NZ
	LD C,MANA/6
	CALL isMANA
	CALL NEWB12
	CALL HL_IXt
	JR ZZ_En2

ZZ11	;огненый дождь
	CALL ZZdist
	LD C,MANA/14 ;часть дождя
	CALL isMANA
	PUSH IY
	EX DE,HL
	LD B,4 ;кол-во дождинок
ZZ11a	CALL RND
	RRA
	LD C,31 ;в 50% - более точное прицеливание
	JR C,ZZ11c
	LD C,63
ZZ11c	CALL RND
	AND C
	LD HL,GO_Ntb
	CALL WT
	LD A,L
	ADD A,E
	CP 63
	JR NC,ZZ11b
	LD L,A
	LD A,H
	ADD A,D
	CP 63
	JR NC,ZZ11b
	LD H,A
	CALL NEWB08
ZZ11b	DJNZ ZZ11a
	POP IY
	CALL HL_IXt
	JR ZZ_En2


ZZ_EnV	LD HL,(PX)
ZZ_End	;конец действия
	CALL IX_98
ZZ_En2	;HL-напр колд
	EX DE,HL
	CALL HL_IX0
	CALL DIR_F
	LD (IX+2),A
	JP IMPIX3


;------магия свящ

ZZ16	;дать здоровье
	CALL ZZddin
	LD A,(IX+6)
	CP MANA/32 ;нижний придел
	JP C,IX_98
	LD HL,(en_IX)
	LD DE,4
	ADD HL,DE
	LD A,(HL) ;тип объекта
	INC HL
	EX DE,HL
	LD HL,HEALTH
	CALL WA
	LD C,A
	EX DE,HL
	LD A,(HL) ;текущ здоровье
	CP C
	JR NC,ZZ_EnV
	LD B,64 ;количество попыток передачи здоровья
ZZ16a	LD A,(HL)
	CP C
	JR NC,ZZ16b ;уже полностью здоров
	LD A,(IX+6)
	SUB 2
	JR C,ZZ16b ;кончилась мана
	LD (IX+6),A
	INC (HL) ;добавить здоровья (1HP for 2MANA)
	DJNZ ZZ16a
ZZ16b	PUSH IY
	LD HL,(en_IX);звёздочки
	LD A,(HL)
	INC HL
	LD H,(HL)
	LD L,A
	PUSH HL
	CALL NEWB09
	POP HL
	POP IY
	JR ZZ_End

ZZ20	;чёрное зрение
ZZ17	;белое зрение
	LD HL,(PX)
	PUSH HL
	CALL GMAP
	LD A,(HL)
	POP HL
	OR A
	JP Z,IX_98 ;на границе
	LD C,MANA/2
	CALL isMANA
	PUSH IY
	PUSH HL
	CALL ONSEEm
	POP HL
	PUSH HL
	INC L
	;звёзды
	CALL NEWB09
	POP HL
	PUSH HL
	DEC L
	CALL NEWB09
	POP HL
	PUSH HL
	INC H
	CALL NEWB09
	POP HL
	DEC H
	CALL NEWB09
	POP IY
	JP ZZ_EnV

ZZ19	;оживление скелетов
	CALL ZZdist
	JP NC,ZZ2
	LD (ZZ_tar),HL
	LD HL,HUMAN
	LD B,102
ZZ19a	LD A,(HL)
	OR A
	JR NZ,ZZ19b
	INC L
	LD A,(HL)
	DEC L
	OR A
	JR Z,ZZ19b
	LD A,(IX+6) ;маны достаточно?
	CP MANA/4
	JR C,ZZ19x
	PUSH BC
	PUSH HL
	PUSH IX
	 PUSH HL
	 POP IX
	LD A,(IX+4)
	CP 8 ;труп оживляем (0..7) ?
	JR NC,ZZ19c
	LD HL,(ZZ_tar)
	CALL DIST
	CP 4 ;радиус оживления -1
	JR NC,ZZ19c
	;убрать труп
	LD (IX+1),0
	;поднять скелета
	PUSH IY
	CALL HL_IXt
	CALL stayON
	CALL NEWB09 ;звёзды
	LD A,19
	EX AF,AF
	LD A,(SIDE_N)
	CALL NEWHER
	JR NZ,ZZ19z ;нет памяти
	LD (IX+13),3
ZZ19z	POP IY
	POP IX
	LD A,(IX+6)
	SUB MANA/4
	LD (IX+6),A
	JR ZZ19d
ZZ19c	POP IX
ZZ19d	POP HL
	POP BC
ZZ19b	LD DE,16
	ADD HL,DE
	DJNZ ZZ19a
ZZ19x	;мана кончилась
	LD HL,(ZZ_tar)
	JP ZZ_End


ZZ18	;огн пояс
	LD A,%00001000 ;(1)
	JR ZZ21a
ZZ21	;хруст сфера
	LD A,%00010000 ;(2)
ZZ21a	EX AF,AF
	CALL ZZddin
	LD C,MANA-1
	CALL isMANA
	PUSH IX
	LD HL,(en_IX)
	LD DE,7
	ADD HL,DE
	POP IX
	LD A,(HL)
	AND %11111000
	JP NZ,IX_98 ;уже есть заклинание
	EX AF,AF
	LD C,A
	LD A,(HL)
	AND %00000111
	OR C
	LD (HL),A
	LD A,C
	CP %00001000
	LD C,14
	JR Z,ZZ21b
	DEC C
ZZ21b	CALL NEWB14
	JP Z,ZZ16b
	LD A,(HL) ;неудача - нет места
	AND %111
	LD (HL),A
	JP ZZ16b

;-----ix+9---крестьяне работают---------------
ZZ22	;строит дом
	RET ;none
ZZ23	;выйти из шахты
	INC (IX+4)
	INC (IX+4)
	LD C,5
	CALL basOUT
	JP basTAR

ZZ24	;выйти из базы
	LD A,(IX+4)
	LD C,6
	CP 9
	JR NC,ZZ24a
	LD (IX+4),0
	DEC A
	JR ZZ24ex
ZZ24a	LD (IX+4),9
	SUB 10
ZZ24ex	JR Z,ZZ24c
	INC C
ZZ24c	;\
basOUT	;выйти из базы/шахты (C-нов действие)
	LD (IX+9),C
	LD (IX+8),#80
	LD A,(IX+2) ;развернись
	ADD A,4
	AND 7
	LD (IX+2),A
	;попробуй выйти, где вошёл
	RES 7,(IX+1)
	RES 7,(IY+1)
	CALL HL_IX0
	CALL GMAP2
	LD A,(HL)
	OR A
	JR Z,bos11
	;найти другую позицию
	CALL HL_IXt
	CALL stayON
	CALL IX0_HL
	PUSH HL
	XOR A
	CALL NEWiy_
	POP HL
	CALL GMAP2
bos11	LD A,(HER_N)
	ADD A,#80
	LD (HL),A
	LD L,(IX+14)
	LD H,(IX+15)
	JP IXt_HL


ZZ25	;pубит лес
	LD A,(IX+2)
	CALL isTREE
	JR NC,noWOOD
	DEC (IX+12)
	;удар по дереву
	JP NZ,IMPIX3
ZZ25a	;повалить дерево
	CALL deTREE
	CALL HL_IXt
	LD (IX+14),L
	LD (IX+15),H
	LD A,(LEV_T)
	OR A
	JP NZ,IX_98 ;для подземелий
	;идти на базу
	CALL basTAR
	INC (IX+4)
	JP EVENT
noWOOD	;нет леса перед носом
	LD (IX+9),6
	LD (IX+8),#80
	RET

basTAR ;найти базу и направить на неё
	CALL HL_IX0
	LD C,#FF ;миним расст
	PUSH IX
	LD B,32
	LD DE,8
	LD IX,HBUILD
	LD A,(SIDE_N)
	OR A
	JR Z,bst0
	LD IX,KBUILD
bst0	LD A,(IX+2)
	;это база?
	OR A
	JR Z,bst1
	CP 10
	JR NZ,bst2
	;расст меньше минимального?
bst1	LD A,(IX+0)
	OR A
	JR Z,bst2
	PUSH BC
	CALL DIST2
	POP BC
	CP C
	JR NC,bst2
	LD C,A
	LD (en_IX),IX
bst2	ADD IX,DE
	DJNZ bst0
	LD A,C
	CP #FF
	JR NZ,bstt
	;некуда идти
	POP IX
	JP IX_98
bstt	;идти на ближайшую базу
	LD IX,(en_IX)
	CALL HL_IX0
	POP IX
	CALL IXt_HL
	LD (IX+9),5
	LD (IX+8),#80
	RET

isTREE	;в направлении A - дерево? (С-да/NC-нет)
	LD HL,GO_Ntb
	CALL WT
	LD A,(IX+0)
	ADD A,L
	LD L,A
	LD A,(IX+1)
	ADD A,H
	LD H,A
isTRE_	CALL GMAP
	LD A,(HL)
	AND #7F
	SUB 61	;деревья 61,62,63
	CP 3
	RET

deTREE	;повалить дерево ;HL-адр в мап
	LD A,(HL)
	LD C,A
	AND #80
	ADD A,6
	LD (HL),A
	CALL deT1
	LD A,C
	AND #7F
	CP 62
	JR C,deTTOP
	JR Z,deTMID
deTBOT	LD DE,-64 ;низ
	ADD HL,DE
	LD A,(HL)
	OR A
	RET Z
	LD C,A
	AND #7F
	CP 62
	LD A,63
detb0	JR Z,detb1
	LD A,6
detb1	LD (HL),A
	BIT 7,C
	JR Z,detb2
	SET 7,(HL)
detb2	CP 6
	JR Z,deT1
	RET
	;
deTTOP	LD DE,64 ;верх
deTTO2	ADD HL,DE
	LD A,(HL)
	OR A
	RET Z
	LD C,A
	AND #7F
	CP 62
	LD A,61
	JR detb0
deTMID	CALL deTBOT
	LD DE,128
	JR deTTO2
	;
deT1	SET 4,H
	LD A,(HL)
	CP 2
	JR NZ,deT11
	LD (HL),0
deT11	RES 4,H
	RET

;------главный цикл обработки шахт-------
MINER	XOR A
	LD (brNUM),A ;очистить список погорельцев
	LD IX,MINE
	LD BC,#800
	LD E,B ;LD DE,8
	LD D,C ;
Mim0	LD A,(IX)
	OR A
	JR Z,Mim1
	LD A,(IX+3)
	OR A
	JR Z,KilMim
	CP (IX+6)
	CALL C,HomBrk
	LD A,(IX+4)
	OR (IX+5)
	JR Z,KilMim
Mim1	ADD IX,DE
	INC C
	DJNZ Mim0
	RET

KilMim	;разрушить шахту
	CALL DESTRY
	JR Mim1

;------главный цикл обработки зданий ------------------------
HOMER	LD HL,SIDE_N
	LD (HL),0 ;свои здания
	PUSH HL
	CALL HOMER_
	POP HL
	INC (HL)  ;здания врага
HOMER_	LD B,32 ;в С - номер
Hom0	LD A,(IX)
	OR A
	JR Z,Hom1
	LD A,(IX+3)
	OR A
	JR Z,KilHom
	CP (IX+6)
	CALL C,HomBrk
	LD A,(IX+4)
	INC A
	JR Z,Hom1
	CP #80
	PUSH AF
	CALL NC,HomBld
	POP AF
	CALL C,HomFct
Hom1	ADD IX,DE
	INC C
	DJNZ Hom0
	RET

HomBrk	;занести повреждённое здание в список brHom для vFLAME
	LD HL,brNUM
	LD A,(HL)
	CP 24
	RET NC
	INC (HL)
	INC HL
	CALL BA
	LD (HL),C
	LD A,(SIDE_N)
	OR A
	RET NZ
	LD A,(DIFFIC) ;индикация/горение
	OR A
	JR Z,Hmbr1
	LD A,(TIC)
	AND #7
	JR NZ,Hmbr1
	DEC (IX+3) ;наши здания сгорают :( при DIFFIC=1
Hmbr1	 LD A,1
	 LD (LED+5),A ;on индик5
	RET

KilHom	;разрушть здание
	CALL DESTRY
	JR Hom1

DESTRY	;разрушить объект IX (C-его номер)
	PUSHs
	 LD A,21
	 LD (LED+2),A ;on индик2
	 LD A,2
	 CALL SOUNDn  ;FX
	CALL EVENT
	;отменить пометку
	LD HL,SEL_T
	LD A,(HL)
	CP 8
	JR C,pec4
	INC HL
	LD A,(HL)
	CP C
	JR NZ,pec4
	DEC HL
	LD (HL),0
pec4	;выпустить строителя, если он там
	LD A,(IX+4)
	CP 253
	JR C,pec0
	INC A
	JR Z,pec0
	LD A,(IX+7)
	INC A
	CALL NZ,outMAN
pec0	;вызвать облако
	CALL NEWB11
	;разрушить зд
	CALL HL_IX0
	LD (IX+0),0
	CALL GMAP
	LD A,(IX+2)
	CP 8
	JR Z,pec1
	CP 18
	JR Z,pec1
	LD C,17
	CALL pecDES
	DEC HL
	CALL pecDES
	LD DE,-64
	ADD HL,DE
	CALL pecDES
	INC HL
	CALL pecDES
	INC HL
	CALL pecDES
	LD DE,64
	ADD HL,DE
	CALL pecDES
	ADD HL,DE
	CALL pecDES
	DEC HL
	CALL pecDES
	DEC HL
	CALL pecDES
	JR pec2
pec1	LD C,23
	CALL pecDES
	DEC HL
	LD C,25
	CALL pecDES
	LD DE,-64
	ADD HL,DE
	LD C,19
	CALL pecDES
	INC HL
	LD C,21
	CALL pecDES
pec2	POPs
	RET
	;
pecDES	;уничт кусочек здания с учётом видим
	SET 4,H
	LD (HL),0
	RES 4,H
	LD A,(HL)
	AND #80
	OR C
	LD (HL),A
	INC C
	RET

HomBld	;строительство
	LD A,(IX+7)
	INC A
	RET Z ;нет строителя
	DEC (IX+5)
	RET NZ
	PUSH BC
	PUSH DE
	INC (IX+4)
	LD A,(IX+4)
	INC A
	CALL Z,outMA_
	LD A,(IX+2)
	LD HL,bcTIME
	CALL BA
	LD (IX+5),A
	LD A,C
	CALL placeB
	POP DE
	POP BC
	JP EVENT

outMA_	 LD A,15
	 LD (LED+1),A ;on индик1
outMAN	CALL HL_IX0
	PUSH IX  ;отпусти строителя
	PUSH BC
	LD A,(IX+7)
	PUSH AF
	PUSH HL
	CALL N_IXIY
	POP HL
	CALL stayON
	CALL IX0_HL
	CALL IX_98
	PUSH HL
	XOR A
	CALL NEWiy_
	POP HL
	CALL GMAP2
	POP AF
	ADD A,#80
	LD (HL),A
	POP BC
	POP IX
	RET

HomFct	;пр_во/иссл
	DEC (IX+5)
	RET NZ
	CALL EVENT
	LD A,(IX+4)
	LD (IX+4),255
	CP 18
	JR C,HFChum
	SUB 20
	PUSH AF
	LD HL,HFCvar
	CALL WT
	LD A,(SIDE_N)
	OR A
	JR Z,HoFc1
	LD DE,kTOWER-hTOWER ;теперь неверно
	ADD HL,DE
HoFc1	POP AF
	PUSH HL
	LD HL,HFCdat
	CALL BA
	POP HL
	LD (HL),A
	RET

HFChum	;появляется новый член общества A
	EX AF,AF
	CALL HL_IX0
	PUSH IX
	PUSHs
	CALL stayON
	LD A,(SIDE_N)
	OR A
	JR NZ,hFC1
	 LD A,11
	 LD (LED+4),A ;on индик4
	 XOR A
hFC1	CALL NEWHER
	POPs
	POP IX
	RET


HFCvar	DEFW hARC,hARC, hBLADE,hBLADE, hHORSE,hHORSE,hHORSE
	DEFW hSHILD,hSHILD, hCLRIC+0,hCLRIC+1,hCLRIC+2
	DEFW hWIZRD+0,hWIZRD+1,hWIZRD+2
HFCdat	DEFB 1,2, 1,2, 1,2,3
	DEFB 1,2, 1,1,1, 1,1,1
	;(за врагов можно проводить исследования)

