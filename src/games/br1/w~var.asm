;************************************************************
;**************** локальные переменные	*********************
;;*L+
      DEFB #D;ummy
;Interupt entry
INTRP	EX DE,HL
	EX (SP),HL
	LD (INTRQ+1),HL
	EX DE,HL
	POP DE
	LD (INTRS+1),SP
	LD SP,DBL_SP
	CALL INAR0
INTRS	LD SP,#0000 ;(**)
	EI
INTRQ	JP #0000 ;(**)
;/CONTRL
CONTRB	DEFB	0
;/RND
RNA	DEFW	911
RNB	DEFB	20
;/XDLPZ
DLPCB	DEFM "Чего"

;/ROTATE
isROT	DEFB 0 ;идёт скролл?
;/SW_OFF
isSWFF	DEFB 0 ;1-погасить курсор

;/OU_MAP
delMAP	DEFB 0 ;задержка на выв карты

;/MANUAL
Z_LOCK	DEFB 0 ;"Z" нажата?
T_FIRE	DEFB 0 ;тип нажатого FIRE (0-2)
fixTAR	DEFB 0 ;1-цель зафиксирована

;/BLITER
V_LINE	DEFB 0 ;текущ выв линия
V_FLAG	DEFB 0 ;режим отобр курсора: 0-norm, 1-refresh, 2-none
P_FLAG	DEFB 0 ;если 1, выполнить отображение курсора
;/V_...
G_MX	DEFB  010
G_MY	DEFB  010
G_SIZE	DEFB 8	    ;высота курс
G_IMG	DEFW G_MAP1 ;изобр курс
GBU1	DEFS 16,#F0 ;копия из SCR
GBAD1	DEFW 0x0800;0	    ;адр копии в SCR ;запарывает это место при первом вызове
GBU2	ds 16     ;копия из DSCR
GBAD2	DEFW 0	    ;

;/X_PUT - параметры спрайта
SHIFTh	DEFB	0
IMGh	DEFW	#FE00
ScrADh	DEFW	0
Xh	DEFB	010	;(з/м)
Yh	DEFB	011	;(pix)
Wh	DEFB	2
Hh	DEFB	16
BHh	DEFB	16

;/MAKE_R
MAXLEN	DEFB 64 ;макс глубина просмотра 64-обычн/120-катакомб)
MAXTRY	DEFB 5	;макс число трассировок

MINLEN	DEFB 0	;min дл обх
MINDIS	DEFB 0	;мин дистанц
NROUND	DEFB 02 ;напр обх
MAX_II	DEFB 0
ss_num	DEFB 05 ;номер и адр в карте тек гер
ss_pos	DEFW 04
makTRY	DEFB 0 ;число обращений к MAKE_R

;/wGrLib
PUTsHL	DEFW 0
SCRADR	DEFB SCR/256
ATRADR	DEFB #D8
FONT	DEFW WFONT

;/SHEDUL
HER_N	DEFB 09 ;текущ герой
SIDE_N	DEFB 01 ;текущ армия (0-свои,1-враги,2-пленники)

;/MOVING
en_IX	DEFW 0 ;IX врага, на которого идёт удар
en_A	DEFB 0 ;N врага, --""--

;/MMOV
COORD	DEFW	#887F
OLDCO	DEFW	014	;WORKING
MX	EQU	COORD
MY	EQU	MX+1
MXOLD	DEFW	0
ENDX	DEFB	248	;\
MtSTEP	DEFB	1	;/

;/работа с курсором
PX	DEFB 01;map-ptr
PY	DEFB 02
BCAP	DEFB 0	;caps 1-нажато
BENTER	DEFB 01 ;enter/x
BXOLD	DEFB 0
BYOLD	DEFB 0
UBY	DEFB 0;
BATR	DEFW 0
BADR	DEFW 0
B_ABUF	DEFB 0
B_BUF	ds 8
BX	DEFB 0;scr-коорд/8
BY	DEFB 0;
UATR	DEFW 0
UADR	DEFW 0
U_ABUF	DEFB 0
U_BUF	ds 8
B_ONOF	DEFB 0	;0/1 -выкл/вкл

;/hLINE
LMask	DEFB #C3 ;маска линии
LMask_	DEFB 10

;/TST7[**]
t7pos	DEFW #2820

;/flpSEL
SyLOCK	DEFB 0 ;sym нажат?
;/capSEL
begBOX	DEFB 0; caps был нажат, строить рамку
BOXX	DEFB 01; коорд нач
BOXY	DEFB 02
;/SELECT
_n_FUN	DEFB 255 ;внутр
N_FUNC	DEFB 255 ;функция 0-5, или 255-none
N_FUN1	DEFB 255 ;дубль для подсветки
F_FUNC	DEFB 1	 ;функция по нажатию space

;/ресурсы
MONEY1	DEFW #0 ;деньги на пр-во
WOOD1	DEFW #150 ;леc на пр-во

;/oINDY
IND1	DEFB 127	;тек знач ind1
IND1MX	DEFB 145	;макc знач
IND2	DEFB 10
IND2MX	DEFB 67
IND2TP	DEFB 2		;тип ind2 (0-none,1-magic,2-%)


;/Кнопки: внутр. перем
_BUT_H	DEFB 00 ;внутр	\
_BUT_N	DEFS 6,#FF;	/
;/Кнопки: номера
NAME	DEFB 0 ;номер назв
BUT_H	DEFB 0;изобр героя
BUT_N	DEFB 0,0,0,0,0,0;изобр кнопок
;/Кнопки: деньги&леc
BUT_mn	DEFW #750,#1500,#4869,#110,#0,#50
BUT_wd	DEFW #50,#100,#150,#0,#10,#0

;/BUTING
ext_M	DEFB 0; дополнит.меню (1,2)
_event	DEFB 0; если 1 - cмена меню

;/ONSEE/ONSEE2
ONSEE	JP onsee  ;для врагов заменяется на RET
ONSEE2	JP onsee2 ; --""--

;/aMONEY/dMONEY/setCRC/chkCRC
MNYcrc	DEFB 5 ;контр.сумма денег

;/ZZ0
ZZ00	JP kINTEL ;для врагов - интеллект; для наших - RET

;/ZZ6
BrWOOD	DEFB 1 ;число ударов по дверям/дереву

;/QSC
QSC	JP QSCt1 ;тип сканирования: QSCt1,QSCt1H,QSCt2,QSCt2h

;/BCD
DCstr	db "Cлавa"
	DEFB #7F
;/SAVlev
TXMgme	DEFB 20,51,64,48,91,0,0,0,127

;/dMAGIC
mag_TM	DEFB 0 ;cчётчик блоков

;/peonN
peon_W	DEFB 02 ;число лесорубов врага \
	DEFB 02 ;число золотоискателей /

;/ZZ19,...
ZZ_tar	DEFW 0 ;центр заклинания

;/vFLAME
brNUM	DEFB 0 ;к-во поврежд зданий
brBLT	ds 24 ;список повреждённых зданий

;----------параметры героев----

;/BUTING
hBUT	;изобр героев
	DEFB 51,51,51,53,52,56,57,55,54
	DEFB 61,61,61,63,62,66,67,65,64
	DEFB 68,70,58,72,73,75,71,69,59

hMSG	;назв героев
	DEFB 1,1,1,3,2,6,7,5,4
	DEFB 10,10,10,12,11,14,15,5,13
	DEFB 16,19,8,21,22,24,20,17,9

;/HERMOV
HvTHs	;скорость гориз перемещ
	DEFB 2,2,2,2,2,2,2,1,#2
	DEFB 2,2,2,2,2,2,2,1,#3
	DEFB 3,2,3,1,2,2,2,3,3
HvTDs	;cкорость диаг перемещ
	DEFB 2,2,2,2,2,2,2,1,#2
	DEFB 2,2,2,2,2,2,2,1,#2
	DEFB 2,2,2,1,2,2,2,2,2

;/SHED_p /IMPACT
BFORCE	;сила снаряда
	DEFB #3 ;(1)стрелы людей
	DEFB #4 ;(2)cтрелы орков
	DEFB 1	;(3)огонь свящ
	DEFB 0
	DEFB 2	;(5)огонь волш
	DEFB 73 ;(6)снар.катап (в эпицентре в 3-ое больше!)
	DEFB 20 ;(7)снар стеногр
	DEFB #5 ;(8)снар огн дождя (<-rnd(127))
	DEFB 0,0,0
	DEFB 15 ;(12)закл - смерчь
	DEFB 0
	DEFB 5	;(14)закл огн кольца

FORCE	;сила удара
	DEFB  0,0,0,0,#3,0,0,0,#8
	DEFB  0,0,0,0,#3,0,0,0,#8
	DEFB  1,2,1,3,0,0, 10,15,0

DEFENC	;защита 0..4 (x/4-вероятность снижения силы удара в двое)
	DEFB  0,0,0, #0,#0,0,0,0,#0
	DEFB  0,0,0, #0,#0,0,0,0,#0
	DEFB  0,1,0,2,0,0, 1,1,1
;/ONSEE
sRANGE	;дальность видимости(+2)
	DEFB	0,0,0,#1,0,0,2,3,1
	DEFB	0,0,0,#0,0,0,2,3,1
	DEFB	0,0,0,0,0,0, 2,2,2
sSCAN	;дальность сканирования (0-не сканир)
	DEFB	0,0,0,#3,1,2,4,8,1
	DEFB	0,0,0,#2,1,2,4,8,1
	DEFB	1,1,1,1,0,0, 1,2,3
ksSCAN	;дальность сканирования охраной противника соотв. типу
	DEFB	5,4,4, 6,5,5,7,10,5
	DEFB	5,4,4, 6,5,5,7,10,5
	DEFB	4,4,4,4,4,4, 4,6,6

;внимание - у лучников дисбаланс/сила дальность

;--------- Эти параметры зависят от DIFFIC ----

;/WW07
KATrng	CP 9 ;определение дальности стрельбы катап-1 (0:9/1:8)
	RET
;/HELPme
HLPrng	CP 6 ;радиус вызова подмоги (0:6/1:10)
	RET

;/WW03/WW12
ARCrng	JP ARvsKT ;лучники vs катап

;/kwwMAG
deMRCH	DEFB %1110 ;скорость отступл волш (0:%111/1:%1)

;------------технические параметры-----

fram	DEFB 0
X0	DEFB 20 ;угол окна отобр
Y0	DEFB 25
_X0pos	DEFW 0 ;отриц поз X0 в пикс
_Y0pos	DEFW 05
TIC_UP	DEFB 0 ;время вражеского апгрейда
ANIM	DEFB 01
COLRsc	DEFB #60 ;цвет скрол курс
MCOLOR	DEFB 0	 ;цвет панели
LEV_T	DEFB 0	;тип карты - 0/1 - обычн/подземелье [MAP+0]==0/1
TIC3	DEFB 1	;\ внутр таймер 0..2
TIC	DEFB 0	;/ внутр таймер 0..255
isMAP	DEFB 0	;0/1 - поле/карта
        nop ;isTST8	DEFB 3	;[**]
SET_SP	LD SP,0 ;(**) - изм
	RET	;
JP_SUB	JP 0	;(**)

;-------- общие параметры игры -------
DIFFIC	DEFB 0 ; сложность игры (0-нормальная, 1-повышенная)

;наличие заклинаний - передаются от уровня к уровню
hCLRIC	DEFB 0,0,0 ;cвящ (1-есть закл) (0,0,0)
hWIZRD	DEFB 0,0,0 ;волш  (0,0,0)
RESULT	DEFB 0,0,0,43,0,0,127 ;время прохождения

hCLRI_	DEFB 0,0,0 ;копия
hWIZR_	DEFB 0,0,0 ;копия
RESUL_	DEFB 0,0,0,43,0,0 ;нач.копия времени прохождения

;--------------Параметры настройки игры---

KEYS	DEFW	KBR
KEYJOY	DEFB	0 ;(1-K.-stick)

PMOUSE	DEFB 0	;(1-K.-mouse)
MUSONF	DEFB 1	;музыка вкл/выкл (1/0)	 (*)
AY_FX	DEFB 1	;AY_эффекты			(*)
isCOLR	DEFB 1	;Игра цветная(1), Ч/Б(0)	(*)
SAVDSK	DEFB 0	;Диск для отгрузок(0-A/1-B)	(*)
M_STEP	DEFB 2	;cкорость перемещ курс(1..17)	(*)
SLOW	DEFB 0	;замедлитель (0-20)		(*)
isANI	DEFB 1	;анимация (1-вкл)		(*)
shadwT	DEFB 1	;невидим поле (0/1-фигурн/чёрн) (*)

VOL_M	DEFB 40 ;уровень			(unused)
VOL_FX	DEFB 30 ; -''-- 			(unused)

;-------