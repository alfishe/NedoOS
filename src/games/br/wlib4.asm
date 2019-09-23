;----ВЫБОР ГЕРОЕВ--------

oneSEL	;кто выбран в xy=HL
        ;jr $
	LD HL,(PX)
	LD A,L
	DEC A
	CP 62
	RET NC
	LD A,H
	DEC A
	CP 62
	RET NC
	CALL oneSE_
	LD HL,(PX)
	LD DE,(BX)
	RRC D
	LD A,E
	JR C,oS1
	RRCA
	JR C,oS01
	LD HL,(PX)
	DEC L
	CALL oneSE_
	LD HL,(PX)
	DEC L
os0_	DEC H
	CALL oneSE_
	LD HL,(PX)
	DEC H
os_	CALL oneSE_
	RET ;!
oS01	INC L
	CALL oneSE_
	LD HL,(PX)
	INC L
	JR os0_
oS1	RRCA
	JR C,oS11
	DEC L
	CALL oneSE_
	LD HL,(PX)
	DEC L
os1_	INC H
	CALL oneSE_
	LD HL,(PX)
	INC H
	JR os_
oS11	INC L
	CALL oneSE_
	LD HL,(PX)
	INC L
	JR os1_
	;
oneSE_	CALL GMAP ;норм вых - лишний POP!
	BIT 7,(HL)
	RET NZ
	SET 4,H
	LD A,(HL)
	CP 2
	RET C
	CP #80
	JR C,homSEL
	SUB #80
	LD HL,SEL_T
	CP #30
	LD E,1
	JR C,ones1
	LD E,7
ones1	LD (HL),E
	INC HL
	LD (HL),A
	POP AF ;!
	RET
homSEL	CP #38
	JR C,hS1
	SUB #38
	LD HL,SEL_T
	LD (HL),8
	INC HL
	LD (HL),A
	POP AF ;!
	RET
hS1	RES 4,H
	LD A,(HL)
	AND #7F
	SUB 120
	RET C
	SET 4,H
	PUSH HL
	LD HL,GSAT
	CALL WT
	POP DE
	ADD HL,DE
	LD A,(HL)
	JR homSEL

selBOX	;выбор в боксе
	LD HL,(BOXX)
	SRL L
	SRL L
	SRL L
	SRL H
	SRL H
	SRL H
	LD DE,(BX)
	XOR A
	PUSH HL
	SBC HL,DE
	POP HL
	JP Z,oneSEL
	SRL L
	SRL H
	LD DE,(X0)
	ADD HL,DE
	LD DE,(PX)
	LD (SEL_T),A
	LD A,D
	SUB H
	JR NC,sbX1
	NEG
	LD H,D
sbX1	INC A
	LD C,A
	LD A,E
	SUB L
	JR NC,sbX2
	NEG
	LD L,E
sbX2	INC A
	EX AF,AF
	CALL GMAP
sbXL0	PUSH HL
	EX AF,AF
	LD B,A
	EX AF,AF
sbXL1	PUSH HL
	BIT 7,(HL)
	JR NZ,sbXL2
	SET 4,H
	LD A,(HL)
	CP 2
	JR C,sbXL2
	CP #80
	JR C,sbXbu
	SUB #80
	LD E,A
	LD HL,SEL_T
	CP #30
	JR NC,sbXk
	LD A,(HL)
	CP 6
	JR C,sbXh
	XOR A
sbXh	INC A
	LD (HL),A
	PUSH AF
	CALL BA
	POP AF
	LD (HL),E
	CP 6
	JR C,sbXL2
	POP AF
	POP AF
	RET
sbXk	LD A,(HL)
	OR A
	JR NZ,sbXL2
	LD (HL),7
	INC HL
	LD (HL),E
	JR sbXL2
sbXbu	CP #38
	JR C,sbXb1
	LD E,A
	LD HL,SEL_T
	LD A,(HL)
	OR A
	JR NZ,sbXL2
	LD A,E
	SUB #38
	LD (HL),8
	INC HL
	LD (HL),A
	JR sbXL2
sbXb1	RES 4,H
	LD A,(HL)
	AND #7F
	SUB 120
	JR C,sbXL2
	SET 4,H
	PUSH HL
	LD HL,GSAT
	CALL WT
	POP DE
	ADD HL,DE
	LD A,(HL)
	JR sbXbu
sbXL2	POP HL
	INC HL
	DJNZ sbXL1
	POP HL
	LD DE,64
	ADD HL,DE
	DEC C
	JR NZ,sbXL0
	RET


centrS	;поместить в центр
	LD A,(isMAP)
	OR A
	RET NZ
	LD A,(SEL_T)
	OR A
	RET Z
	CP 8
	LD A,(SEL_N)
	PUSH AF
	CALL NC,B_IX
	POP AF
	CALL C,N_IX
	LD A,(IX)
	CALL cesS
	LD L,A
	LD A,(IX+1)
	CALL cesS
	LD H,A
	LD (X0),HL
	RET
cesS	SUB 6
	JR NC,ces1
	XOR A
	RET
ces1	CP 52
	RET C
	LD A,52
	RET

deSEL	;исключить А из N_SEL
	EX AF,AF
	LD HL,SEL_T
	LD A,(HL)
	OR A
	RET Z
	INC HL
	CP 7
	JR C,dL1
	RET NZ
	;враг
	EX AF,AF
	CP (HL)
	RET NZ
	DEC HL
	LD (HL),0
	RET
dL1	;наш
	LD B,A
	EX AF,AF
dL0	CP (HL)
	JR Z,dL2
	INC HL
	DJNZ dL0
	RET
dL2	DEC B
	JR Z,dL3
	PUSH HL
	POP DE
	INC HL
	LD C,B
	LD B,0
	LDIR
dL3	LD HL,SEL_T
	DEC (HL)
	RET

flpSEL	;flip пометки селект
	LD HL,SyLOCK
	LD BC,#7FFE ;SYM Shift
	IN A,(C)
	AND %1111
	CP %1101
	JR Z,fP1
	LD (HL),0
	RET
fP1	LD A,(HL)
	OR A
	RET NZ
	INC (HL)
	  CALL EVENTr
	LD A,(SEL_T)
	OR A
	JP Z,addSEL
	CP 7
	RET NC
	LD HL,(PX)
	CALL GMAP2
	LD A,(HL)
	SUB #80
	RET C
	CP #30
	RET NC
	LD BC,(SEL_T)
	PUSH BC
	CALL deSEL
	POP BC
	LD A,(SEL_T)
	CP C
	RET NZ
addSEL	LD HL,(PX)
	CALL GMAP2
	LD A,(HL)
	SUB #80
	RET C
	CP #30
	RET NC
	LD B,A
	LD HL,SEL_T
	LD A,(HL)
	CP 6
	RET NC
	INC (HL)
	INC HL
	CALL BA
	LD (HL),B
	RET

;процедуры выбора
capSEL	;Выбор/рамка по CAPS
	LD HL,(MX)
	LD A,(T_FIRE)
	CP 2
	JR Z,BB1
	LD A,(isMAP)
	OR A
	JR NZ,BB0
	LD A,(begBOX)
	OR A
	RET Z
	CALL EVENTr
	CALL selBOX
BB0	XOR A
	LD (begBOX),A
	RET
BB1	;pCAPS
	LD A,L
	CP 192
	RET NC
	LD A,(isMAP)
	OR A
	JR NZ,BBM
	LD A,(begBOX)
	OR A
	RET NZ
	INC A
	LD (begBOX),A
	LD A,L
	CP 192
	JR C,BB4
	LD L,191
BB4	LD (BOXX),HL
	LD HL,(PX)
	CALL EVENTr
	 JP oneSEL
BBM	LD HL,(PX)
	CALL EVENTr
	CALL oneSE_ ;!
	RET

SELECT	;Выбор ф-ции на панели упр
	;функц кнопки
	LD BC,#F7FE
	IN A,(C)
	LD DE,#500
fun0	RRCA
	JR NC,fun1
	INC E
	DEC D
	JR NZ,fun0
	LD B,#FD
	IN A,(C)
	AND 7
	CP E
	JR Z,fun1
	LD E,#FF
fun1	LD A,E
	LD (_n_FUN),A
	CP #FF
	RET C
	;fire на панели
	LD A,(T_FIRE)
	DEC A
	RET NZ
	LD HL,(BX)
	LD A,L
	CP 25
	RET C
	LD A,H
	CP 19
	RET Z
	JR NC,dwnPP
	CP 9
	RET Z
	JR NC,midPP
upPP	CP 4
	RET C
	LD A,(NAME)
	CP 42
	JP NZ,centrS
	LD A,(ext_M)
	XOR 1
	LD (ext_M),A
	JP EVENT
dwnPP	CP 26
	RET NC;индик предупр
	;гл.меню *********
	XOR A
	LD (T_FIRE),A
	JP gmMENU
midPP	LD A,L
	SUB 25
	CP 6
	RET NC
	LD L,0
	LD E,L
	CP 3
	JR C,mi1
	INC L
mi1	LD A,H
	SUB 10
	CP 3
	JR C,mi2
	LD E,2
	CP 6
	JR C,mi2
	LD E,4
mi2	LD A,E
	ADD A,L
	LD (_n_FUN),A
	RET

;----------------------------------------------
FIRBUT	;обработка нажатия иконки + подсветка
	LD A,#FF
	LD (N_FUN1),A
	LD HL,_n_FUN
	CP (HL)
	JR NZ,nSQ0
	INC HL
	LD (HL),A
	RET
nSQ0	LD A,(N_FUNC)
	CP #FF
	RET C
	LD A,(HL)
	INC HL
	LD (HL),A
	INC HL
	LD (HL),A
	LD B,A
	LD HL,BUT_N
	CALL BA
	OR A
	RET Z ;пустая кн
	LD C,A
	CP 71	  ;/катап _ cвободная стрельба?/
	JR Z,nSQ1
	CP 50
	JR NC,procB
	LD HL,spc_DO
	CALL BA
	OR A
	JR Z,procB
	CP 2
	LD A,(SEL_T)
	JR C,nSQ1
	CP 7
	JR NC,procB
nSQ1	LD A,B
	LD (F_FUNC),A ;выбор без немедл. действия
	RET
procB	;обработка нажатий на кнопки (B-#кн,C-её тип)
	LD A,(SEL_T)
	CP 7
	RET Z
	JP NC,prcBLT
	;для людей/отряда
	LD A,(BUT_H)
	CP 24
	JR NZ,pBH4
	LD A,(ext_M)
	OR A
	JR Z,pBH4
	;один из отряда
	LD A,B
	LD HL,SEL_N
	PUSH HL
	CALL BA
	POP HL
	LD (HL),A
	DEC HL
	LD (HL),1
	JP EVENTr

pBH4	LD A,C
	CP 7
	JR NC,pBH1
	DEC A
	DEC A
	JR pBH0
pBH1	CP 24
	JR NC,pBH2
	SUB 15
	JR pBH0
pBH2	SUB 39
pBH0	LD HL,pBHt
	CALL WT
	JP (HL)
pBHt	DEFW pBF2,pBF3,pBF4,pBF4,pBF4,pBF20,pBF21,pBF22,pBF23
	DEFW pBF48,pBF48,pBF50
pBF2	;возвр в меню0
	JP EVENTr
pBF20	;осн меню стр-ва
	LD A,1
pBF20_	CALL _EXT
	LD A,#FF
	LD (F_FUNC),A
	RET
pBF21	;доп меню стр-ва
	LD A,2
	JR pBF20_
pBF23	;сбросить груз
	LD HL,SEL_T
	LD B,(HL)
pBF23a	INC HL
	PUSH BC
	PUSH HL
	LD A,(HL)
	CALL N_IX
	LD A,(IX+4)
	CP 3
	LD A,9
	JR NC,pb01
	XOR A
pb01	LD (IX+4),A
	CALL IX_98
	POP HL
	POP BC
	DJNZ pBF23a
	JP EVENTr
pBF3	;стоять на смерть
	LD C,1
	JR pb03
pBF4	;остановиться
	LD C,0
pb03	LD HL,SEL_T
	LD B,(HL)
pb02	INC HL
	PUSH HL
	LD A,(HL)
	CALL N_IX
	LD (IX+8),0
	LD (IX+9),C
	POP HL
	DJNZ pb02
	RET
pBF22	;идти на базу
	XOR A
	LD (SIDE_N),A
	LD HL,SEL_T
	LD B,(HL)
pBF22a	INC HL
	PUSH BC
	PUSH HL
	LD A,(HL)
	CALL N_IX
	CALL basTAR
	POP HL
	POP BC
	DJNZ pBF22a
	RET
pBF50	;родить монстра
	LD B,MANA-1
	LD A,(BUT_H)
	CP 57
	LD C,12
	JR Z,pb05
	LD C,15
	JR pb05
pBF48	;родить пауков
	LD B,MANA/4
	LD A,(BUT_H)
	CP 57
	LD C,10
	JR Z,pb05
	LD C,13
pb05	LD A,(SEL_N)
	CALL N_IX
	LD A,(IX+6)
	CP B
	JR C,pb07
	LD (IX+9),C
	LD (IX+8),0
	RET
pb07	LD A,25 ;no mana
	JP dirTX

;---кнопки зданий--------------
prcBT1	DEFB 29,30,31,32,33,34,0,4,3,8,7,5,6
	DEFB #FF,#FF,#FF,9,13,12,17,16,14,15
prcBT0	DEFB 27,28,#FF,22,23
	DEFB #FF,20,21,24,25,26

prcBLT	;C-k.typ
	LD A,C
	CP 51
	JR C,pCB4
	CP 68
	JR NC,pCB4
	;для ПР-ВА юнитов проверить наличе пищи (4*N+1)
	PUSH BC
	CALL oNUMh ;едоки->C
	PUSH BC
	CALL oHOMh ;пища->A
	POP BC
	INC C
	CP C
	POP BC
	JR NC,pCB4
	LD A,43
	JP dirTX
pCB4	PUSH BC
	LD A,(N_FUNC)
	CALL GETmw
	CALL dMN_WD
	POP BC
	JP C,nMN_WD
	CALL EVENT
	LD A,(SEL_N)
	CALL B_IX
	LD A,C
	CP 16
	JR C,pCB1
	CP 68
	RET NC
	SUB 45
	RET C
	;закл/герои
	LD HL,prcBT1
pCB2	CALL BA
	LD (IX+4),A
	LD HL,hcTIME
	CALL BA
	LD (IX+5),A
	RET
pCB1	SUB 5
	LD HL,prcBT0
	JR NC,pCB2
	CP -3
	RET NZ
	LD A,(IX+4)
	CP #80
	JR C,pCBr
	;уничт.здание
	LD (IX+3),0
	RET
	;прекр.разработку
pCBr	LD (IX+4),255
	RET

;NN производств: 255-none
;0..8 наши
;9..17 враги
;20-лук1, 21-лук2, 22-меч1, 23-меч2, 24-конь1, 25-конь2, 26-конь3
;27-щит1, 28-щит2, 29-волш1,30-волш2,31-волш3
;32-закл1, 33-закл2, З4-закл3
;(40..-то же для врагов)
hcTIME	;время на пр-во
	DEFB 100,100,100,120,120,140,150,200,140 ;наши
	DEFB 100,100,100,120,120,140,150,200,140 ;враги
	DEFB 1,1 ;none
	DEFB 150,200,150,200,100,150,200, 150,200, 150,200,250
	DEFB 120,180,230 ;наши разр

;/	DEFB 0,0,0,0,0
;/	DEFB 150,200,150,200,100,150,200, 150,200, 150,200,250
;/	DEFB 120,180,230 ;;0,0,0,0,0 ;их разр

