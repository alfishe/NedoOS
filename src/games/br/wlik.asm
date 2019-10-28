;-------РАБОТА СО СНАРЯДАМИ/ВЗРЫВАМИ/ЗАКЛИНАНИЯМИ/ДЫМОМ------

;----------СНАРЯД ПЕРЕМЕЩАЕТСЯ/ДОСТИГ ЦЕЛИ---
VV14	;огн кольцо
	LD A,(IY+7)
	CALL N_IX
	CALL HL_IX0
	EX DE,HL
	;ударить по врагам
	LD B,8 ;8 кв вокруг
	LD HL,GO_Ntb-2
VV14c	LD A,B
	PUSHs
	CALL WT
	LD A,E
	ADD A,L
	LD L,A
	LD A,D
	ADD A,H
	LD H,A
	CALL _sMPAC
	POPs
	DJNZ VV14c
VV13	;закл "хрст шар"
	PUSH IY
	LD A,(IY+7)
	CALL N_IXIY
	LD L,(IY+0)
	LD H,(IY+1)
	LD E,(IY+2)
	LD D,(IY+3)
	POP IY
	LD (IY+0),L
	LD (IY+1),H
	LD (IY+2),E
	LD (IY+3),D
	LD A,(IX+0)
	OR A
	JR Z,VVx_ ;цель уже погибла
	LD A,(IY+9)
	OR A
	JR NZ,brrX
	LD A,(IX+7) ;кончилось заклинание
	AND %111
	LD (IX+7),A
	JR VVx_

VV11	;облако после пожара
	JR Z,VVx_
	LD A,(IY+2)
	DEC (IY+2)
	OR A
	JR NZ,brrX
	DEC (IY+3)
	JR brrX


VV4	;взр влш огня
VV10	;взр снр катап
VV9	;звeзды
	JR NZ,brrX
	JR Z,VVx_


VV1	;стрелы л
VV2	;cтрелы к
	JR NZ,VVmov
	;разить врага N
	CALL BMPACT
	JR VVx_

vv5	;огонь волш
VV3	;огонь свящ
	JR NZ,VVmov
	;обжечь врага
	CALL BMPACT
	LD (IY+4),4
	LD (IY+9),2;time
	JR brrX

BULLty	;п/п обр пуль/взр
	DEFW VV1,VV2,VV3,VV4,vv5,VV6,VV7,VV8
	DEFW VV9,VV10,VV11,VV12,VV13,VV14
BULLER	;-----обработчик пуль
	LD IY,BULL
	LD B,24
	LD DE,12
brr0	LD A,(IY+4)
	OR A
	JR Z,brr1
	PUSH BC
	PUSH DE
	LD HL,BULLty-2
	CALL WT
	DEC (IY+9) ;уменьшить time
	JP (HL)
VVx_	LD (IY+4),0 ;исчезнов. снар
	JR brrX
VVmov	LD E,(IY+10) ;перемещ снар
	LD D,(IY+11)
	CALL CORiy_
brrX	POP DE
	POP BC
brr1	ADD IY,DE
	DJNZ brr0
	RET

VV6	;снр катап
	JR NZ,VVmov
	;взрыв
	 LD A,2
	 CALL SOUNDy ;FX
	CALL cMPACT
	CALL sMPACT ;для второго удара в эпицентр
	JR VV8a ;для третьего удара в эпицентр

VV8	;огн.дождинка
	JR Z,VV8r
	LD DE,#0A01
	CALL CORiy_
	JR brrX
VV8r	;случайная сила удара дождя
	CALL RND
	AND 127
	ADD A,30
	LD (BFORCE-1+8),A
	;удар по врагу
VV8a	CALL sMPACT
VV8c	LD DE,#8F8
	CALL CORiy_
	LD (IY+4),10
	LD (IY+9),3
	 LD A,8
	 CALL SOUNDy
	JR brrX

VV7	;плевок стеногрыза
	JR NZ,VVmov
	;удар
	CALL BMPACT
	 LD IX,(en_IX)
	 LD A,8
	 CALL SOUNDn
	JR VV8c

VV12	;cмерчь
	JR Z,VVx_
	LD A,(IY+8) ;фаза 0..2
	INC A
	CP 3
	JR C,VV12i
	XOR A
VV12i	LD (IY+8),A
	JR NZ,brrX ;скорость 1/3
	LD L,(IY+0) ;выч коорд смерча
	LD H,(IY+1)
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD E,H
	LD L,(IY+2)
	LD H,(IY+3)
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD L,E
	INC L
	DEC H ;<-H точка удара
	PUSH HL
	CALL GMAP
	LD A,(HL)
	OR A
	POP HL
	JP Z,VVx_ ;вышел на бордюр
	CALL _sMPAC;гасить врагов внизу
	JP VVmov

;--------расчёты перемещения снарядов----
SHFpre	LD BC,0 ;подготовка расчёта траектории
	LD A,E
	SUB L
	JR NC,sgg0
	NEG
	INC C
sgg0	LD E,A
	LD A,D
	SUB H
	JR NC,sgg1
	NEG
	INC B
sgg1	LD D,A
	CP E
	RET

SHFT8	;выч смещения-8 для снарядов
	;hl--->de  вых:iy10,11
	CALL SHFpre
	LD A,8
	PUSH AF
	JR NC,s8g2
	LD A,E
	LD E,D
	LD D,A
s8g2	LD A,E	;E-меньший
	JR s8_16

SHFT16	;выч смещения-16 для снарядов
	;hl--->de  вых:iy10,11
	CALL SHFpre
	LD A,16
	PUSH AF
	JR NC,s16g2
	LD A,E
	LD E,D
	LD D,A
s16g2	LD A,E	;E-меньший
	ADD A,A
s8_16	ADD A,A
	ADD A,A
	ADD A,A ;x16/x8
	INC A
	LD E,A
	LD L,D
	CALL DIVB
	POP AF
	LD D,A
	JR NC,s16g3
	LD A,E
	LD E,D
	LD D,A
s16g3	LD A,C
	OR A
	JR Z,s16g4
	LD A,E
	NEG
	LD E,A
s16g4	LD A,B
	OR A
	JR Z,s16g5
	LD A,D
	NEG
	LD D,A
s16g5	LD (IY+10),E
	LD (IY+11),D
exIY	POP IY
	RET

DISTde	;расст по ф-ле: max(|E-L|,|D-H|) ;Вых.A
	LD A,L
	SUB E
	JR NC,d2e1
	NEG
d2e1	LD B,A
	LD A,H
	SUB D
	JR NC,d2e2
	NEG
d2e2	CP B
	RET NC
	LD A,B
	RET

DIRF	;dir с равномерными секторами
	CALL DIR
	BIT 0,A
	RET Z
	PUSH AF
	LD A,E
	SUB L
	JR NC,RF1
	NEG
RF1	LD L,A
	LD A,D
	SUB H
	JR NC,RF2
	NEG
RF2	LD H,A
	SLA A
	CP L
	JR C,RFM1
	LD A,L
	SLA A
	CP H
	JR C,RFM2
	POP AF
	RET
RFT1	DEFB 2,2,6,6
RFT2	DEFB 0,4,4,0
RFM1	LD HL,RFT1
	JR RFM0
RFM2	LD HL,RFT2
RFM0	POP AF
	SRA A
	JP BA


;---------выделение места в памяти под снаряд-----
NEWBUL	;--нов пуля/взр/закл ->IY! (Z/NZ - оК/нет места)
	EXX
	LD HL,BULL+4
	LD DE,12
	LD B,24
nwb0	LD A,(HL)
	OR A
	JR Z,nwb2
	ADD HL,DE
	DJNZ nwb0
	EXX
	RET ;NZ-noOK
nwb2	DEC HL
	DEC HL
	DEC HL
	DEC HL
	PUSH HL
	POP IY
	EXX
	RET ;Z-ok

;---------------ПОРОЖДЕНИЕ--СНАРЯДОВ-----------

NEWB06	;снаряд катапульты (DE-цель)
	LD C,6
	JR sgg11
newb05	;огонь волш
	LD C,5
	JR sgg11
NEWB03	;огонь свящ (DE-цель)
	LD C,3
	JR sgg11
NEWB07	;плевок стеногр
	LD C,7
	JR sgg11
NEWB01	LD C,1
	JR sgg11
NEWB02	;нов стрела (DE-цель)
	LD C,2
sgg11	PUSH IY
	CALL NEWBUL
	JP NZ,exIY
sgg12	LD (IY+4),C
	LD A,(HER_N)
	LD (IY+7),A
	LD A,(IX+12)
	LD (IY+5),A
	CALL HL_IX0
	PUSH HL
	XOR A
	CALL NEWiy_
	PUSH DE
	LD DE,#FC04
	CALL CORiy_
	POP DE
	POP HL
	LD A,(IX+2)
	LD (IY+8),A
	LD A,C
	CP 3
	JR Z,sgg36 ;для свящ
	CP 5
	JR Z,sgg36 ;для волш
	CP 6
	JR Z,sggk6 ;для кат
	CALL DISTde
	INC A
	LD (IY+9),A
	JP SHFT16
sggk6	LD (IY+5),E
	LD (IY+6),D
sgg36	CALL DISTde
	ADD A,A
	INC A
	LD (IY+9),A
	JP SHFT8

NEWB09	;нов звёзды в HL ;портит IY
	CALL NEWBUL
	RET NZ
	PUSH IX
	PUSH HL
	CALL NEWiy_ ;A=0
	LD (IY+4),9
	LD (IY+9),6 ;time
	 LD A,5
	 POP HL
	 PUSH HL
	 LD (sIY56),HL
	 CALL SOUND9
	POP HL
	POP IX
	RET

NEWB08	;огн.дождинка (AL)
	CALL NEWBUL
	RET NZ
	LD (IY+5),L
	LD (IY+6),H
	LD A,H
	SUB 4  ;высота падения
	LD H,A
	XOR A
	CALL NEWiy_
	LD A,(HER_N)
	OR #80 ;бит7=1 для заклинаний
	LD (IY+7),A
	LD (IY+4),8
	LD (IY+9),7 ;time
	RET

NEWB11	;взр здания IX
	CALL NEWBUL
	RET NZ
	CALL HL_IX0
	CALL NEWiy_ ;A=0
	LD DE,#FCF0
	LD A,(IX+2)
	LD C,20
	CP 8
	JR Z,n11w0
	CP 18
	JR Z,n11w0
	LD DE,#0CF8
	LD C,36
n11w0	CALL CORiy_
	LD (IY+4),11
	LD (IY+9),C ;time
	RET

NEWB14	;ВХ: C=14/13 -огн кольцо/хруст шар (вых Z/NZ -ок/no mem)
	PUSH IY
	CALL NEWBUL
	JP NZ,exIY
	LD (IY+4),C
	LD A,(IX+12)
	LD (IY+7),A
	LD (IY+9),150 ;время жизни заклинания
	JP exIY

NEWB12	;смерчь в HL
	PUSH IY
	CALL NEWBUL
	JP NZ,exIY
	LD C,L
	CALL rn3
	LD L,A
	LD C,H
	CALL rn3
	LD H,A
	CALL NEWiy_ ;A=0
	LD DE,#8F8
	CALL CORiy_
	LD (IY+4),12
	LD (IY+8),0
	CALL RND
	AND 63
	ADD A,64
	LD (IY+9),A ;время жизни заклинания
	LD A,(HER_N)
	OR #80 ;бит7=1 для заклинаний
	LD (IY+7),A
	CALL rn5
	LD (IY+10),A
	CALL rn5
	LD (IY+11),A
	JP exIY
	;
rn5	;rnd(-2..+2)
	CALL RND
	AND 7
	CP 5
	JR NC,rn5
	DEC A
	DEC A
	RET
	;
rn3	;rnd C+(-1,0,0,+1)
	CALL RND
	AND 3
	JR Z,rn3a
	DEC A
	DEC A
rn3a	ADD A,C
	JR Z,rn3b
	CP 63
	RET C
	LD A,62
	RET
rn3b	INC A
	RET

;------------ВЫВОД ПУЛЬ/ВЗРЫВОВ--------
WYbT	DEFW YU1,YU1,YU3,YU4,yu5,YU6,YU7,YU8,YU9
	DEFW YU10,YU11,YU12,YU13,YU14,0,YU16,YU17,YU18

WYbull	;получить Wh(C),Hh(B),IMGh(DE),выбрать страницу

        if EGA
;для EGA не надо тут узнавать размер, это сделает HeF1
        
        ld a,25
        call _128
	LD A,(IY+4)
	LD HL,WYbT-2
	CALL WT
	JP (HL)
YU1	;стрелы
	LD A,(IY+8)
	AND 3
        add a,18
YU1a
        add a,a
        ld ($+3+2),a
        ld iy,(0xc000)
	JP HeF1
yu5	;огонь волшебников
YU3	;огонь свящ
	LD A,(TIC)
	AND 1
        add a,22
	JR YU1a
YU4	;взрыв огня волш
	LD A,(IY+9)
	AND 1
        add a,24
	JR YU1a
YU6	;снаряд катап
	LD A,(IY+8)
        add a,26
	JR YU1a
YU7	;cнаряд стеногрыза
        ld iy,(0xc000+(2*34))
	JP HeF1
YU8	;огн дождь
        ld iy,(0xc000+(2*35))
	JP HeF1
YU9	;волш звзды
        LD A,(TIC3)
        add a,9;37
	JR YU1a
YU10	;взр катап снаряда
	LD A,3
	SUB (IY+9)
        add a,40
	JR YU1a
YU13	;хруст шар
        ld iy,(0xc000+(2*36))
	JP HeF1
YU14	;огн пояс
	LD A,(TIC3)
        add a,37;12
	JR YU1a
YU11	;взрыв здания
	LD A,(TIC3)
        add a,15
	JR YU1a
YU12	;cмерч
	LD A,(IY+8)
        add a,12
	JR YU1a
YU16	;дым,низ50%
        LD A,(TIC3)
        add a,3
	JR YU1a
YU17	;дым,низ25%
        LD A,(TIC3)
        add a,6
	JR YU1a
YU18	;дым,верх
        LD A,(TIC3)
	JR YU1a        
        
        else ;~EGA

	CALL MEM1
	LD A,(IY+4)
	LD HL,WYbT-2
	CALL WT
	JP (HL)
YU1	;стрелы
	LD DE,WMISC1
	LD A,(IY+8)
	AND 3
YU1a	ADD A,A
	ADD A,A
	ADD A,A
	ADD A,A ;x16
	LD L,A
	LD H,0
	ADD HL,DE
	EX DE,HL
YU1b	LD BC,#801
	JP HeF1
yu5	;огонь волшебников
YU3	;огонь свящ
	LD DE,4*16+WMISC1
	LD A,(TIC)
	AND 1
	JR YU1a
YU4	;взрыв огня волш
	LD DE,6*16+WMISC1
	LD A,(IY+9)
	AND 1
	JR YU1a
YU6	;снаряд катап
	LD A,(IY+8)
	LD DE,8*16+WMISC1
	JR YU1a
YU7	;cнаряд стеногрыза
	LD DE,16*16+WMISC1
	JR YU1b
YU8	;огн дождь
	LD DE,17*16+WMISC1
	JR YU1b
YU9	;волш звзды
	LD DE,25*64+WMISC2
YU9a	LD A,(TIC3)
	RRCA
	RRCA ;x64
	LD L,A
	LD H,0
	ADD HL,DE
	EX DE,HL
	LD BC,#1002
	JP HeF1
YU10	;взр катап снаряда
	LD DE,5*144+WMISC3
	LD A,3
	SUB (IY+9)
YU10a	JR Z,YU10c
	CP 1
	LD HL,144
	JR Z,YU10b
	ADD HL,HL
YU10b	ADD HL,DE
	EX DE,HL
YU10c	CALL MEM6
	LD BC,#1803
	JP HeF1
YU13	;хруст шар
	LD DE,144+WMISC3
	JR YU10c
YU14	;огн пояс
	LD DE,288+WMISC3
	LD A,(TIC3)
	OR A
	JR YU10a
YU11	;взрыв здания
	LD DE,WMISC4+768
	LD A,(TIC3)
YU11a	LD BC,#2004
	OR A
	JP Z,HeF1
	INC D
	DEC A
	JP Z,HeF1
	INC D
	JP HeF1
YU12	;cмерч
	LD DE,WMISC4
	LD A,(IY+8)
	JR YU11a
YU16	;дым,низ50%
	LD DE,19*64+WMISC2
	JR YU9a
YU17	;дым,низ25%
	LD DE,22*64+WMISC2
	JR YU9a
YU18	;дым,верх
	LD DE,16*64+WMISC2
	JR YU9a
        
        endif ;~EGA

vBULL	;-------выв.пуль/закл/взр-----------------------
	LD IY,BULL
	LD B,24
	LD DE,12
vbu0	LD A,(IY+4)
	OR A
	JR Z,vbu1
	PUSH BC
	PUSH DE
	CP 13
	CALL NC,vbuCRR
	INC A
         if EGA
         push iy
         endif
	CALL _XPUT
         if EGA
         pop iy
         endif
	POP DE
	POP BC
vbu1	ADD IY,DE
	DJNZ vbu0
	RET

vbuCRR	;получить IY для 13,14
	LD A,(IY+7)
	PUSH IY
	CALL N_IXIY
	LD A,(IX+4)
	LD HL,AT_TY_
	CALL BA
	DEC A
	LD BC,0
	JR Z,vuc1
	LD C,4
vuc1	POP IX
	PUSH IX
	LD L,(IY+0)
	LD H,(IY+1)
	XOR A
	SBC HL,BC
	CALL IX0_HL
	LD L,(IY+2)
	LD H,(IY+3)
	ADD HL,BC
	LD (IX+2),L
	LD (IX+3),H
	POP IY
	INC A
	RET


vFLAME	;--------дым пожарищ------------
	LD IY,BUF512 ;врем данные
	LD HL,brNUM
	LD A,(HL)
	OR A
	RET Z
	LD B,A
vff0	INC HL
	PUSH BC
	PUSH HL
	LD A,(HL)
	CALL B_IX
	CALL HL_IX0
	DEC H
	XOR A
	CALL NEWiy_
	LD A,(IX+2)
	INC A
	LD HL,vffDT
	CALL WT
	EX DE,HL
	LD HL,BUF512
	CALL cii_
	LD A,(IX+6)
	SRL A
	CP (IX+3)
	LD A,16
	JR C,vff5
	INC A
vff5	LD (BUF512+4),A
	OR A
         if EGA
         push iy
         endif
	CALL _XPUT
         if EGA
         pop iy
         endif
	LD HL,(BUF512+2)
	LD DE,-16
	ADD HL,DE
	LD (BUF512+2),HL
	LD A,18
	LD (BUF512+4),A
	OR A
         if EGA
         push iy
         endif
	CALL _XPUT
         if EGA
         pop iy
         endif
	POP HL
	POP BC
	DJNZ vff0
	RET
	;
vffDT	;сдвиг огня по X,Y
	DEFB 0,4
	DEFB 0,5, 0,8, 0,7, -1,0, -2,2, 0,-2, 0,4, 0,0, -4,0
	DEFB 0,0
	DEFB 0,0, 0,8, 6,10, 0,0, 0,10, 0,0, 0,6, 10,-3, -9,-3
