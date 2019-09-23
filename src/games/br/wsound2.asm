
        if 1==0
_TST#8	LD HL,isTST8 ;[**]
	LD A,(HL)
	AND %1111
	RET NZ
	DEC (HL)
	;
	LD C,0
	LD DE,invBUF
	PUSH DE
	CALL t8dst
	LD C,(HL)
	POP HL
	CP C
	JR Z,t8ex_
	LD DE,KUNGE-invBUF+#100
	ADD HL,DE	;err
t8ex_	LD BC,#40FF
t8ex	LD (HL),C
	INC HL
	DJNZ t8ex
	SCF
	RET

t8dst	PUSH DE ;[**]
	LD HL,t8tab
t8d0	LD A,(HL)
	INC HL
	CP #80
	JR Z,t8d1
	JR NC,t8d2
	CP #38
	JR Z,t8d1
	JR t8d3
t8d2	CP #FE
	RET Z
t8d3	INC C
	LD (DE),A
	INC DE
t8d1	JR t8d0
	;
	POP DE
	LD A,C
	RET

        endif


;звуковые эффекты   (C) Copper Feet [sept.1997]
;--------------- Звук (в осн.стр)-----------------

;частотаМЛ (FF-конец),частотаСТ,громкость,шум (FF-НЕТ)

SOU4	;выстрел из катапульты
	DEFW 1096
	DEFB 11,31
	DEFW 946
	DEFB 12,20
	DEFW 2096
	DEFB 14,17
	DEFW 796
	DEFB 15,20
	DEFW 3094
	DEFB 15,22
	DEFW 646
	DEFB 15,26
	DEFW 4094
	DEFB 15,28
	DEFW 596
	DEFB 14,29
	;
SOU3	;выстрел из лука
	DEFW 4094
	DEFB 14,30
	DEFW 596
	DEFB 14,27
	DEFW 4094
	DEFB 13,25
	DEFW 596
	DEFB 11,20
	DEFW 3094
	DEFB 09,10
	DEFB #FF


;0-меч,1-топор,2-взрыв катапульты,3-выстрел из лука,
;4-выстрел из катапульты, 5-колдовство, 6-волшебники стреляют
;7-укус, 8-малый взрыв
tSOUND	DEFW SOU0,SOU1,SOU2,SOU3,SOU4,SOU5,SOU6,SOU7,SOU8
prvSND	; приоритет
	DEFB   10,   5,  20,   6,   15, 12,   9,   8,  14
typSND	;кто какой звук при ударе даёт (#FF-нет)
	DEFB 1,#FF,#FF,3,0,#FF,#FF,#FF,0
	DEFB 1,#FF,#FF,3,0,#FF,#FF,#FF,0
	DEFB 7,1,7,1,#FF,#FF,1,0,#FF

;#EEC9(стр.6) - адрес хранения упр. регистра AY для протрекера
;часть эффектов в стр.3


SOUNDy	;играть звук A (IY+5,IY+6 - коорд источника)
	PUSH HL
	LD L,(IY+5)
	LD H,(IY+6)
	LD (sIY56),HL
	POP HL
SOUND9	LD IX,sIY56
	;
SOUNDn	;играть звук A (IX+0,IX+1 - коорд источника)
	CP #FF
	RET Z ;пустой звук
	PUSH HL
	PUSH BC
	PUSH AF
	LD C,A
	LD A,(AY_FX)
	OR A
	JR Z,son1 ;эфф запрещ
	LD A,C
	LD HL,prvSND
	CALL BA
	LD A,(priv_S)
	CP (HL)
	JR NC,son1 ;приоритет эффекта ниже проигрываемой
	LD A,(HL)
	LD (priv_2),A
	LD A,C
	LD HL,tSOUND  ;инициализ мелодии #A
	CALL WT
	LD (NOTA2),HL
	;
	;опр видимости источника звука
	CALL HL_IX0
	CALL GMAP
	BIT 7,(HL)
	JR NZ,son1
	;опред громкости в зависимости от дальности
	LD HL,(X0)
	LD A,L
	ADD A,6
	LD L,A
	LD A,H
	ADD A,7
	LD H,A ;центр экр
	CALL DIST2
	SUB 6
	JR NC,lso1
	;в экране - макс громкость
	XOR A
lso0	LD (levSND),A
	LD HL,(NOTA2)
	LD (NOTA),HL
	LD A,(priv_2)
	LD (priv_S),A
	JR son1
lso1	CP 6
	JR C,lso0;в радиусе 12
son1	POP AF
	POP BC
	POP HL
	RET

;форматы нот
;(#ff) - конец мелодии
;(N4,N5,N10,Nшум) - значение 4,5,10  и 6  регистров для С


pSOUND	;вып. ноту мелодии
	LD A,(priv_S) ;проигрыватель не занят
	OR A
	RET Z
	LD A,(#EEC9) ;из протрекера
	LD E,A
        if 1==0
	LD A,3	 ;стр. с эффектами
	CALL MEM
        else
        call MEM_snd
        endif
	LD HL,(NOTA)
	LD A,(HL)
	CP #FF
	JR NZ,ppsC ;конец эффекта?
	XOR  A
	LD (priv_S),A ;завершение мелодии
	RET
ppsC	;
	LD BC,#FFFD
	LD A,4 ;частотаМЛ
	OUT (C),A
	LD B,#BF
	OUTI
	;
	LD B,#FF
	INC A ;частотаCT
	OUT (C),A
	LD B,#BF
	OUTI
	;
	LD B,#FF
	LD A,10 ;громкость
	OUT (C),A
	LD A,(levSND)
	LD B,A
	LD A,(HL)
	INC HL
	SUB B ;коррект громкости по расстоянию
	JR NC,pps1
	XOR A
pps1	LD B,#BF
	OUT (C),A
	;
	LD B,#FF
	LD A,7 ;управление
	OUT (C),A
	LD B,#BF
	LD A,E ;из протрекера
	BIT 7,(HL)
	JR Z,pps2
	AND %11111011 ;без шума
	JR pps3
pps2	AND %11011011
pps3	OUT (C),A
	;
	LD B,#FF
	LD A,6 ;шум
	OUT (C),A
	BIT 7,(HL)
	JR NZ,pps4
	OUTI
	JR pps5
pps4	INC HL
pps5	LD (NOTA),HL
	RET

        if 1==0
yw  EQU #38
yv  EQU #80
t8tab	DEFB yv,#AF,yv,yw      ;   TST#8   XOR A [**]
	DEFB #21,yv,#50,yw,yv,#40  ;	       LD HL,#4050
	DEFB #01,#00,yv,#36  ;		 LD BC,#3600
	DEFB #AE,yv,yv,yv      ;   tst80   XOR (HL)
	DEFB #86,yw	 ;	     ADD A,(HL)
	DEFB #23      ; 	  INC HL
	DEFB #0D,yw	 ;	     DEC C
	DEFB #20,#FA	;	    JR NZ,tst80
	DEFB #05      ; 	  DEC B
	DEFB #20,yv,yv,#F7    ; 	  JR NZ,tst80
	DEFB #21,yv,#00,yv,#FF	;	    LD HL,#FF00
	DEFB #C9,yw,yw,  #FE	      ;RET (!cp(hl))
        endif
