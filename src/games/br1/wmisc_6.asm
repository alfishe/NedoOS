;******* ВСПОМОГАТЕЛЬНЫЕ ПОДПРОГРАММЫ ****** page6

SLOWER	;замедлитель
	EI
	XOR A
	OUT (254),A ;sys установки
	LD A,(MAXTRY)
	LD (makTRY),A ;ограничитель числа трассировок
	;
	LD A,(SLOW)
	OR A
	RET Z
	LD B,A
ssLW	LD DE,4000 ;x112000тактов
ssL1	DEC DE
	LD A,E
	OR D
	JR NZ,ssL1
	DJNZ ssLW
	RET

TIMER	LD A,(TIC) ;таймер
	CP 97
	RET NZ
	LD HL,TIC_UP
	INC (HL)
	LD A,(LEVEL)
	ADD A,(HL)
	CP 53 ;_____= время на апгрейд - Nlev
	JR C,timU
	LD (HL),0
	CALL UP_TIM
timU	LD HL,RESULT+5
	CALL time
	LD HL,LEVRES+5
	;
time	;HL-указ на младш. цифру 999:59
	INC (HL)
	LD A,(HL)
	CP 10
	RET C
	LD (HL),0  ;
	DEC HL
	INC (HL)
	LD A,(HL)
	CP 6
	RET C
	LD (HL),0   ;
	DEC HL
	DEC HL
	INC (HL)
	LD A,(HL)
	CP 10
	RET C
	LD (HL),0   ;;
	DEC HL
	INC (HL)
	LD A,(HL)
	CP 10
	RET C
	LD (HL),0  ;;
	DEC HL
	INC (HL)
	RET

XY1st	;первонач X0,Y0
	LD HL,(HUMAN)
	LD A,L
	SUB 6
	JR C,xys1
	LD L,A
xys1	LD A,H
	SUB 6
	JR C,xys2
	LD H,A
xys2	LD (X0),HL
	RET

RNDcrr	LD A,R ;увеличение случайности
	LD HL,RNB
	XOR (HL)
	LD (HL),A
	RET

;-------расчёт параметров после исследов

HvFrc	DEFB 3,4, 4,6, 5,8 ;воин/конник
cBLADE	;расчёт силы удара
	LD A,(kBLADE)
	EX AF,AF
	LD A,(MASTER)
	OR A
	LD A,(hBLADE)
	JR Z,cBB1
	EX AF,AF
cBB1	LD HL,HvFrc
	PUSH HL
	CALL WA
	LD (FORCE+4),A
	INC HL
	LD A,(HL)
	LD (FORCE+8),A
	POP HL
	EX AF,AF
	CALL BA
	LD (FORCE+13),A
	INC HL
	LD A,(HL)
	LD (FORCE+17),A
	RET

cSHILD	;расчёт величина защиты
	LD A,(kSHILD)
	EX AF,AF
	LD A,(MASTER)
	OR A
	LD A,(hSHILD)
	JR Z,cSS1
	EX AF,AF
cSS1	LD HL,DEFENC+3
	CALL cSS2
	EX AF,AF
	LD HL,DEFENC+12
cSS2	LD (HL),A ;лу
	INC HL
	LD (HL),A ;во
	INC HL
	INC HL
	INC HL
	INC HL
	LD (HL),A ;ко
	RET

cTIC	;расчёт TIC,TIC3 и параметров
	LD HL,TIC3 ;трёхфазный счётчик 0-2
	INC (HL)
	LD A,(HL)
	CP 3
	JR C,ctt1
	LD (HL),0
ctt1	INC HL	;TIC cчётчик 0-255
	INC (HL)
	LD A,(HL)
	RRA
	JR NC,cTT0
	RRA
	JR C,cHORSE
	JR cBLADE
cTT0	RRA
	JR C,cSHILD
	;
cARC	;расчёт видимости/дальности стрельбы из лука
	LD A,(kARC)
	EX AF,AF
	LD A,(MASTER)
	OR A
	LD A,(hARC)
	JR Z,cAA1
	EX AF,AF
cAA1	LD HL,tARChu
	CALL WA
	LD (sRANGE+3),A
	ADD A,2
	LD (sSCAN+3),A
	INC HL
	LD A,(HL)
	LD (BFORCE+0),A
	EX AF,AF
	LD HL,tARCkg
	CALL WA
	LD (sRANGE+12),A
	ADD A,2
	LD (sSCAN+12),A
	INC HL
	LD A,(HL)
	LD (BFORCE+1),A
	RET

tARChu	DEFB 2,3, 2,4, 2,5 ;дальность+2/сила
tARCkg	DEFB 1,4, 1,6, 2,6


HvThor	DEFB 2,2, 3,2, 3,3, 4,4 ;скорость лошади 0-3

cHORSE	;расчёт скорости лошадей
	LD A,(kHORSE)
	EX AF,AF
	LD A,(MASTER)
	OR A
	LD A,(hHORSE)
	JR Z,cHH1
	EX AF,AF
cHH1	LD HL,HvThor
	PUSH HL
	CALL WA
	LD (HvTHs+8),A
	INC HL
	LD A,(HL)
	LD (HvTDs+8),A
	POP HL
	EX AF,AF
	CALL WA
	LD (HvTHs+17),A
	INC HL
	LD A,(HL)
	LD (HvTDs+17),A
	RET

dMAGIC	;--изменение маны (ix+6) для 16и героев
	LD HL,mag_TM
	LD A,(HL)
	DEC (HL)
	OR A
	JR NZ,dMG6
	LD (HL),5 ;к-во блоков -1
dMG6	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,A ;x16
	CALL N_IX
	LD DE,16
	LD B,16 ;число героев в блоке
dMG0	LD A,(IX+0)
	OR A
	JR Z,dMGe
	LD A,(IX+4)
	LD HL,HEALTH+1
	CALL WA
	OR A
	JR Z,dMGe
	CP #80
	LD A,(IX+6)
	JR C,dMG1
	;креатуры
	OR A
	JR Z,dMG2
	DEC (IX+6) ;dec маны
	JR dMGe
dMG2	LD A,(IX+5)
	SUB 6 ;dec здоровья
	JR NC,dMG3
	XOR A
dMG3	LD (IX+5),A
	JR dMGe
dMG1	;маги
	CP MANA
	JR NC,dMGe
	INC (IX+6)
dMGe	ADD IX,DE
	DJNZ dMG0
	RET

;-----скука/повороты
SPLIN	CALL RND
	AND 127
	CP 102
	RET NC
	CALL C,N_IX
	LD A,(IX+8)
	INC A
	RET NZ
	LD A,(IX+4)
	CP 9
	JR C,spli1
	SUB 9
spli1	CP 7
	RET NC
	LD A,R
	RRCA
	LD A,(IX+2)
	JR C,spli2
	INC A
	JR spli3
spli2	DEC A
spli3	AND 7
	LD (IX+2),A
	RET

;----воcст крестьян----

peonN	;подсчёт пеонов
	LD HL,0 ;(L/H - лес/золт)
	CALL loop_K
pen0	LD A,(IX+0)
	OR A
	JR Z,pen1
	LD A,(IX+13)
	CP 7
	JR Z,penG
	CP 6
	JR NZ,pen1
	INC L ;лес
	JR pen1
penG	INC H ;золото
pen1	ADD IX,DE
	DJNZ pen0
	RET ;HL

REpeon	;восст пеонов
	LD A,(TIC)
	AND %111111
	CP %110101
	RET NZ
	CALL peonN
	LD DE,(peon_W)
	LD A,L
	CP E
	JR C,reoW
	LD A,H
	CP D
	RET NC
	LD C,7;золото
	JR reo1
reoW	LD C,6;лес
reo1	;поиск любой базы
	PUSH BC
	LD B,16
reo2	CALL RND
	AND #1F
	ADD A,#28
	CALL B_IX
	LD A,(IX+0)
	OR A
	JR Z,reo3
	LD A,(IX+2)
	OR A
	JR Z,reobz
	CP 10
	JR Z,reobz
reo3	DJNZ reo2
	POP BC
	RET ;база не найдена
reobz	;произв крестьянина
	CALL HL_IX0
	CALL stayON
	LD A,(MASTER)
	OR A
	LD A,9
	JR Z,reo5
	XOR A
reo5	EX AF,AF
	LD A,1
	CALL NEWHER
	POP BC
	RET NZ ;mem?
	LD (IX+13),C ;тип
	;затормозить сборы отряда
	LD A,(pntDEL)
	ADD A,20 ;delay
	LD (pntDEL),A
	RET
;*L+
WMUSIC	EQU 60535
	ds WMUSIC-$

	DISP DSCR ;???
	DEFS 6,#C9
	JP outSND
;*B ..\BOBOV\CROW_B1.MUS ;0!
;*B ..\BOBOV\CROW_B2.MUS ;1
;*B ..\BOBOV\CROW_A2.MUS ;2
;*B ..\BOBOV\CROW_3.MUS  ;3
;*B ..\BOBOV\CROW_4.MUS  ;4
;*B ..\BOBOV\CROW_5.MUS  ;5
;*B ..\BOBOV\OSEN.MUS	 ;6
;*B ..\BOBOV\X_TXY.MUS	 ;7

;---------начальный опрос пользователя------
;---эти п/п будут удалены

ITX01	DEFB 1,10,109,10, 25,62,50,48,79,10, 56,51,64,48,10
	DEFB 55,48,10, 59,78,52,53,57, 127 ;нов.люд
ITX02	DEFB 2,10,109,10, 25,62,50,48,79,10, 56,51,64,48,10
	DEFB 55,48,10, 58,67,61,51,62,50, 127 ;нов.кунг
ITX04	DEFB 4,10,109,10, 14,53,64,61,67,66,74,65,79,10
	DEFB 50,10, 30,82,91,102,26,83, 127 ;exit
ITX03	DEFB 3,10,109,10, 14,62,65,65,66,48,61,62,50,56,66,74,10
	DEFB 56,51,64,67, 127 ;load

        macro ATRRs _hl,_bc,_e
	LD HL,_hl
	LD BC,_bc
	LD E,_e
	CALL ATRRBR
	ENDM

ATRRBR	PUSHs
	INC H
	INC L
	LD E,#40
	CALL ATRBAR
	POPs
	JP ATRBAR


NO_NUM	LD BC,#7000
nnU0	DEC BC
	LD A,C
	OR B
	JR NZ,nnU0
	;
	LD BC,#F7FE
	IN A,(C)
	CPL
	AND %11111
	JR NZ,NO_NUM
	LD B,#EF
	IN A,(C)
	CPL
	AND %11111
	JR NZ,NO_NUM
	RET

NUMBER	LD BC,#F7FE
	IN A,(C)
	CPL
	AND %11111
	JR NZ,nmr1
	LD B,#EF
	IN A,(C)
	CPL
	AND %11110
	JR Z,NUMBER
	;6-9
	LD E,A
	LD A,9
	RR E
	RR E
	RET C
	DEC A
	RR E
	RET C
	DEC A
	RR E
	RET C
	DEC A
	RET
	;
nmr1	LD E,A
	LD A,1
	RR E
	RET C
	INC A
	RR E
	RET C
	INC A
	RR E
	RET C
	INC A
	RR E
	RET C
	INC A
	RET

INIprn	CALL INIpr1
	INC D
	RET

INIpr1	PUSH DE
	CALL PRINTS
	POP DE
	INC D
	RET

INImg1	CALL STS
	LD DE,#703
	LD BC,#1C0B
	CALL MU_BOX
	ATRRs #703,#0B1C,#71
	LD DE,#905
	PUSH DE
	LD HL,ITX01
	CALL INIprn
	LD HL,ITX02
	CALL INIprn
	LD HL,ITX03
	CALL INIprn
	LD HL,ITX04
	CALL INIprn
	POP HL
	RET

INImg2	PUSH AF
	DEC A
	ADD A,A
	ADD A,H
	LD H,A
	LD BC,#118
	LD E,#72
	CALL ATRBAR
	POP AF
	RET

INI123	DI
	LD SP,#403E
	CALL MEM6
	CALL invTAB
	CALL outSND
	CALL MEM7
	CALL INImg1
ipp0	CALL NUMBER ;(1-4)
	CP 5
	JR NC,ipp00 ;секретная комбинация
	CALL INImg2
	CP 3
	JP Z,INIlod ;загрузка отгрузки
	JR C,INInew ;новая игра (1/2)
	;exit
	CALL NO_NUM
	LD DE,#808
	LD BC,#0C05
	CALL MU_BOX
	ATRRs #808,#050C,#72
	LD DE,#A0A
	LD HL,ITX4
	CALL PRINTS

        if 1==1
;NedoOS
        call swapimer
        im 1
        QUIT
        
        else
        
	EI
	LD B,120
EEE	HALT
	DJNZ EEE
	;exit
	DI
	IM 0
	LD HL,#4000
	LD DE,#4001
	LD (HL),#44
	LD B,#20
	LDIR
	XOR A
	LD BC,#7FFD
	OUT (C),A
	JP 0
        endif

ITX4	DEFB  25,67,10,56,10, 55,64,79,47,127
ipp00	CP 8
	JR C,ipp0
	JP NC,NoDoIt

ITX1z	DEFB  29,59,62,54,61,62,65,66,74,10, 56,51,64,75,43,127;diff
ITX11	DEFB  1,10,109,10, 26,49,75,71,61,48,79, 127;norm
ITX12	DEFB  2,10,109,10, 27,62,50,75,72,53,61,61,48,79,127;high

INInew	;нов
	DEC A
	LD (MASTER),A
	CALL NO_NUM
	LD DE,#D08
	LD BC,#1309
	CALL MU_BOX
	ATRRs #D08,#0913,#60
	LD DE,#F0A
	PUSH DE
	LD HL,ITX1z
	CALL INIprn
	LD HL,ITX11
	CALL INIprn
	LD HL,ITX12
	CALL INIprn
ipp1	CALL NUMBER
	CP 3
	JR NC,ipp1
	POP HL
	PUSH AF
	ADD A,A
	ADD A,H
	LD H,A
	LD BC,#10F
	LD E,#7B
	CALL ATRBAR
	POP AF
	DEC A
	LD (DIFFIC),A
	CALL NO_NUM
	JP LODnew

ITX3z	DEFB 31,58,48,54,56,66,53,10, 61,62,60,53,64,127
ITX3x	DEFB 62,66,59,62,54,53,61,61,62,57,10, 56,51,64,75,43,10,127

ndi0	LD A,(LEVEL);1/2-(+/-Level);3-(on/off) убить всех;  6-выход
	INC A
	CP 10
	LD L,0
	JR C,ndi1
	LD L,1
	SUB 10
ndi1	LD H,A
	LD (NDIstr+2),HL
	LD A,(MORTE)
	LD (NDIstr+7),A
	LD HL,NDIstr
	LD DE,#0
	CALL PRINTS
	;----изм парам
	CALL NO_NUM
	CALL NUMBER
	CP 6
	RET Z ;вых
	LD HL,LEVEL
	CP 2
	JR Z,ndiLP
	JR C,ndiLM
	CP 3
	JR NZ,ndi0
	LD A,(MORTE)
	XOR 86
	LD (MORTE),A
	JR ndi0
ndiLM	LD A,(HL)
	DEC (HL)
	OR A
	JR NZ,ndi0
	LD (HL),16
	JR ndi0
ndiLP	LD A,(HL)
	INC (HL)
	CP 16
	JR C,ndi0
	LD (HL),0
	JR ndi0

INIlod	;загр. сост
	CALL NO_NUM
	LD DE,#F01   ;номер отгр
	LD BC,#1606
	CALL MU_BOX
	ATRRs #F01,#0616,#68
	LD DE,#1103
	LD HL,ITX3z
	CALL INIprn
	DEC D
	LD HL,ITX3x
	CALL PRINTS
	PUSH DE
	LD A,%11000101
	LD HL,ATR+596
	LD (HL),A
	PUSH HL
ppi4	CALL NUMBER
	CP 9
	JR NC,ppi4
	POP HL
	LD (HL),#70
	POP DE
	PUSH AF
	CALL PRINT
	CALL NO_NUM
	LD DE,#407  ;дисковод  отгр
	LD BC,#1608
	CALL MU_BOX
	ATRRs #407,#0816,#69
	LD DE,#609
	LD HL,TXdsT1
	CALL INIpr1
	LD HL,TXdsT2
	CALL INIpr1
	LD HL,TXdsk2
	CALL INIpr1
	LD HL,TXdsk3
	CALL PRINTS
	PUSH DE
	LD HL,ATR+314
	LD (HL),#69+#80
	PUSH HL
	CALL A_or_B
	LD (DISK_T),A
	POP HL
	LD (HL),#71
	ADD A,12
	POP DE
	CALL PRINT
	CALL MEM6
	POP AF
	DEC A
	JP LODgam

TXdsT1	DEFB 14,65,66,48,50,74,66,53,10, 30,82,91,102,26,83, 127 ;вст.ТР-ДОС
TXdsT2	DEFB 52,56,65,58,10, 65,10, 62,66,51,64,67,55,58,48,60,56, 127 ;д с отгр

;TODO убрать???
A_or_B	;возвр: 0/1 - A/B
	NOP
	LD BC,#7FFE
	IN A,(C)
	AND %10000
	LD A,1
	RET Z
	LD B,#FD
	IN A,(C)
	AND %1
	RET Z
	JR NZ,A_or_B

TXdsk1	DEFB 14,65,66,48,50,74,66,53,10, 52,56,65,58,10, 2,127 ;insert d2
TXdsk2	DEFB 56,10, 67,58,48,54,56,66,53,10, 56,60,79,127 ;и укажите имя
TXdsk3	DEFB 52,56,65,58,62,50,62,52,48,10, 87,12,90,13,88,43,10,127 ;д-ва

;TODO убрать???
INI_D2	CALL MEM7
	CALL STS
	LD DE,#105  ;дисковод c диском 2
	LD BC,#1607
	CALL MU_BOX
	ATRRs #105,#0716,#7A
	LD DE,#307
	LD HL,TXdsk1
	CALL INIpr1
	LD HL,TXdsk2
	CALL INIpr1
	LD HL,TXdsk3
	CALL PRINTS
	PUSH DE
	LD HL,ATR+184
	LD (HL),#7A;+#80
	PUSH HL
	CALL A_or_B
	LD (DISK_2),A
	POP HL
	LD (HL),#72
	ADD A,12
	POP DE
	CALL PRINT
	RET

	db " *    THIS IS A SOME OF TEXT.   "
	db " *    GENS4 RULEZ FOREVER :-)   "
	db " *    AMIGA - SUXX & MUSTDIE!   "
	db " *    COMING SOON NEW LEVELS!   "
	db " * WHY DON'T WE DO IT IN A ROAD?"
	db " *    MY PHONE IS 812-1433303   "
	db " * "

BF_256	DEFS 1024,#BF
LOD1st	;первичн загр

        if 1==0

	CALL selD_2
	CALL TR000
	LD DE,#09
	LD B,1
	LD HL,BF_256
	PUSH HL
	CALL D_READ ;загр. табл.ф-лов
	POP HL
	JR C,LOD1st
	;проверка метки диска D2,F1
	LD A,(HL)
	CP #D2
	JR NZ,LOD1st
	INC HL
	LD A,(HL)
	CP #F1
	JR NZ,LOD1st
	INC HL
	;перенос тб.ф-лов
	LD DE,WX_LEN
	LD BC,numFL
	LDIR
        
        endif
        
	;выбрать: князь или гризольда?
	LD A,(MASTER) ;в зависимости от того, за кого играем
	OR A
	RET Z
	CALL MEM6
	LD HL,WGRIZ
	LD DE,#DC00
	LD BC,1024
	LDIR
	RET

INXbad	DEFB 26,72,56,49,58,48,10, 71,66,53,61,56,79,10, 56,90,56,59,56, 127
INXba2	DEFB 62,66,51,64,67,55,58,48,10, 61,53,10, 61,48,57,52,53,61,48, 127

LODbad	DI
	CALL MEM7
	CALL STS
	LD HL,WFONT
	LD (FONT),HL
	LD DE,#204  ;ошибка чтения
	LD BC,#1706
	CALL MU_BOX
	ATRRs #204,#0617,#F2
	LD DE,#406
	LD HL,INXbad
	CALL INIpr1
	LD HL,INXba2
	CALL PRINTS
	;
lggB	LD BC,#7FFE
	IN A,(C)
	AND %1
	JR NZ,lggB
	;
	LD HL,ATR
	LD DE,ATR+1
	LD BC,767
	LD A,%00110110
	LD (HL),A
	OUT (254),A
	LDIR
	CALL INImg1
	LD A,3
	CALL INImg2
	JP INIlod

invTAB	;постр табл инв байтов для монстров 6:#C300
	LD HL,#C300
	XOR A
itq0	PUSH AF
	LD C,0
	RRCA
	RL C
	RRCA
	RL C
	RRCA
	RL C
	RRCA
	RL C
	RRCA
	RL C
	RRCA
	RL C
	RRCA
	RL C
	RRCA
	RL C
	LD (HL),C
	POP AF
	INC HL
	INC A
	JR NZ,itq0
	RET

NDIstr	DEFB 112,109,0,0,10,60,109,0,127
NoDoIt	;86275-вход в режим отладки
	LD A,44
	CALL hexPRN
	CALL hexDIG
	LD H,A
	PUSH HL
	CALL hexDIG
	POP HL
	LD L,A
	LD DE,ndi0-#6275
	ADD HL,DE
	CALL ndiS
	JP INI123
ndiS	JP (HL)

hexDIG	CALL NO_NUM ;ввод #XX
	CALL NUMBER
	CALL hexPRN
	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,A
	PUSH AF
	CALL NO_NUM
	CALL NUMBER
	CALL hexPRN
	POP BC
	ADD A,B
	RET
	;
hexPRN	PUSH AF
	LD DE,#17
	CALL PRINT
	POP AF
	RET

WGRIZ
        incbin "data/wgrizold.dat"
;-------------------
	ent ;ENDD
;----исполняются отседа

lggTRY	DEFB 50

LODgam	;восст игры A=0-7
	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,4 ;тр:4,12,20,28,36,44,52,60
	LD D,A ;трек
	LD A,5 ;к_во ретрай-попыток
	LD (lggTRY),A
	LD A,(DISK_T)
	LD (tDRIVE),A
	PUSH DE
	CALL TR000
	POP DE
	LD HL,G_DATA
	LD A,5
lgg0	LD SP,#403E
	PUSH AF
	CP 1
	LD B,16
	JR NZ,lgg1
	LD B,9
lgg1	LD E,1
lgg11t	PUSH DE
	CALL POS
	POP DE
lgg11	PUSHs  ;чтение отгрузки
	XOR A
	LD (SIDE),A
	LD B,1
	PUSH DE
	DI
	CALL d_rea_
	DI
	POP DE
	JR NC,SEC_ok
	  CALL TR000 ;обр. ошибки
	  POPs
	  LD A,(lggTRY)
	  DEC A
	  LD (lggTRY),A
	  OR A
	  JR NZ,lgg11t
	  POP AF
badbad	  CALL LDItmp
	  JP LODbad
SEC_ok	POPs
	INC E
	INC H
	DJNZ lgg11
	INC D
	POP AF
	DEC A
	JR NZ,lgg0
	CALL DECODE
	JR NZ,badbad;ошибка загрузки/нет данных об игре
lgg_OK	CALL LDItmp
	LD A,(DISK_T)
	LD (SAVDSK),A
	JP CONTgm  ;перейти к диску 2

LDItmp	;загр временного кода
	DI
	;
	CALL outSND
	;
	LD HL,WMUSIC
	LD DE,DSCR
	LD BC,#1800
	LDIR
	;
	DI
	LD A,2
	LD (V_FLAG),A
	RET

outSND	;выруби AY
	LD B,16
oss0	PUSH BC
	LD A,B
	DEC A
	LD BC,#FFFD
	OUT (C),A
	LD B,#BF
	CP 7
	LD A,0
	JR NZ,oss7
	CPL
oss7	OUT (C),A
	POP BC
	DJNZ oss0
	RET

LDI123	CALL LDItmp
	CALL INI123 ;->>
;???
;относятся к загрузке игры
;*L+
	DEFS #FE00-$,98
	;старт #fe00
	DI
	LD HL,#4000
	LD DE,#8000
swp5_2	LD C,(HL) ;обмен страниц 5 и 2
	LD A,(DE)
	LD (HL),A
	LD A,C
	LD (DE),A
	INC HL
	INC DE
	LD A,D
	CP #C0
	JR C,swp5_2
	JP JP_ST ;на старт игры
