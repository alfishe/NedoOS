;----Player Data 				;-не менять!!!
DATA

Pr_Q	DEFB 0 ;К-во единиц продукции
Pr_N	DEFB 0 ;N пр-ва
Pr_Z	DEFB 0 ;К-во зерб
Pr_PRC	DEFW 0 ;Cтоимость пр-ва
Pr_HWR	DEFW 0 ;К-во часов на изготовление
Pr_H_	DEFW 0 ;К-во прошедших часов
Pr_DAY	DEFW 0 ;К-во дней на изгот. партии

PERIOD	DEFB	0 ;период войны (0..5)
T_INTR  DEFB 	255;=====255;Тип истр.(0,1,2,255-НЕТ)
INTR	DEFB	95,19 ;Коорд. истр.
INTR_T	DEFB	95,19 ;Целевые коорд. истр
UFO	DEFB	255,255 ;Коорд. НЛО
UFO_T	DEFB	255,255 ;врем.цель НЛО
UFOV	DEFB 	0   ; НЛО видим/нет (0/1)
RNAgen	DEFW	1997;  --""-- RNA
RNBgen	DEFB	7   ; нач.уст RNB для генер целей
TARoff	DEFB	0   ; время (ч) до генерации цели
TARon	DEFB	0   ;время жизни цели
TARlst	DEFB	7   ;последняя цель
T_TYPE  DEFB	255 ;тип цели (0-7,255-база)
T_UFO	DEFB	255 ;Цели: Tип НЛО(0..2,255)
T_SHP	DEFB	255 ;судно
T_TWN	DEFB	255 ;порт
T_ISL	DEFB	255 ;остров
T_BAS	DEFB    255 ;наша база
T_COL	DEFB	255 ;колония
T_UBS	DEFB	255 ;их база
Tleth	DEFB	255 ;Тлеф(0/255)
RSN	DEFB	10 ;к-во учёных
ENG	DEFB	10 ;к-во инженеров
AQU	DEFB	0 ;К-во акванавтов
REYTING	DEFB	0;рейтинг 0,1,2->RIP

TIM	DEFB	0,4,14,4,4,14,4,4 ;Время
DAT	DEFB	1,5 ;День
	DEFB    37,21,18,33,16,28,47,15 ;Месяц
	DEFB	2,0,1,7 ;Год
	DEFB	1; (N месяца 0-11)
e255	EQU	255
e254	EQU	254
RS	;Исследов. (255-нет,0-есть,N-к-во дней)
	DEFB	0,0,e255,e255,0
	DEFS	6,e255
	DEFB 	e254,e255,e254,e254
	DEFS	3,e255
	DEFB	0
	DEFS	40,e255
	DEFB	0
	DEFS 	20,e255
nDAT	DEFW	1;Номер дня
DUMMY2	DEFB	2
DOLG 	DEFW 	0,0 ;долг
BASE	DEFB	0,0,0,0,0,0,0,0 ;Базы (% повреждений, >=100-уничтожена)
MONEY	DEFW	33920,30
eq	EQU	0;1
S_GUN	DEFS	12*2,eq ;хранится: оружие
S_EQU	DEFS	3*2,eq ;оборуд
S_ARM	DEFS	3*2,eq ;защита
S___	DEFW	0;Для нет
S_UFO	DEFS	6*2,eq ;типы НЛО
S_ART	DEFS	10*2,eq ;артефакты(от ион.уск+корп.НЛО+тела)
S_PROF	DEFS	20*2,eq;проф.инопл
S_LIV	DEFS	7*2,eq ;живые инопл
S_TMP	DEFW	0 ;если 5 пси-контр.
	DEFW	0 ;если хакер
	DEFW	0

DUMMY3	DEFB	#FF
R_TM	DEFB	0;Время иссл.
R_NUM	DEFB	5-#1F;Число заверш иссл-#1F []
N_AQU	DEFB	1 ;Имя нанимаемого акв.(1-192)
DUMMY1	DEFB	1
AQNAVT	DEFB   0;ИМЯ(0-нет)
	DEFB   1;ранг(0-7)
	DEFB   2 ;защита(0-нет,1,2,3)
	DEFB   3;Time Units
	DEFB   4;Energy
	DEFB   5;Health
	DEFB   6;Wound
	DEFB   7;Moral Level
	DEFB   8;Precision
	DEFB   9;Gun 1 (255-no)
	DEFB   10;Gun 2
	DEFB   11;Gun 3
	DEFB   12;Gun 4
	DEFB   13;Дни до след. звания
	DEFB 	0;--
	DEFB 	0;--
	DEFS   9*16,0

DATLEN  EQU $-DATA;длина игровых данных <480
NEWDAT  EQU #C000+13500 ;копия нач данных (480)
ALLDAT	EQU NEWDAT+480  ;5 игр сост x480

U_GUN	DEFS	12,0 ;хранится: оружие
	DEFS	3,0 ;оборуд
U_ART	DEFS	10,0 ;артефакты(от ион.уск+корп.НЛО+тела)
U_LIV	DEFS	7,0 ;живые инопл
U_len	EQU $-U_GUN
