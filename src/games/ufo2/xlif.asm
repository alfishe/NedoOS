DELPCmlz=DEC40
L_OFF	;Сброс битов видимости
	LD HL,#E000
	LD BC,#2000
L_OF1	LD A,(HL)
	CP 3
	JR C,L_OF2
	SET 7,(HL)
L_OF2	INC HL
	DEC BC
	LD A,C
	OR B
	JR NZ,L_OF1
	LD HL,(L_IPOS)
	BIT 7,H
	RET NZ
	XOR A
	PUSH HL
	CALL L_Off
	POP HL
	LD A,1
	CALL L_Off
	LD HL,#FFFF
	LD (L_IPOS),HL
	RET
L_Off	CALL FLOOR
	LD C,16
Loo1	LD B,16
	LD (TX),HL
	PUSH HL
Loo0	CALL GSP ;psp
	EXX
	RES 7,(HL)
	EXX
	LD HL,TX
	INC (HL)
	DJNZ Loo0
	POP HL
	INC H
	DEC C
	JR NZ,Loo1
	RET

;-----------------------------------------------
L_Land	CALL PT128
	LD A,(L_LAND) ;загр.ландш
	LD HL,L_LL
	CALL WT
	JP (HL)

;========Формирование ландшафта================================
L_SPR4  CALL L_SPR1;загр спр истр + НЛО
	Ms 3
	LD DE,DSCR
	PUSH DE
	LD HL,xUFO;+2
	CALL DELPCmlz
	CALL PT128
	POP HL
	LD DE,#B800
	LD BC,#1800
	LDIR
	RET

L_SPR1  ;загр спр истр
	LD HL,#B000
	PUSH HL
	LD DE,xATR
	LD BC,96
	LDIR
	PUSH DE
	POP HL
	INC DE
	LD (HL),%10000001 ;xATR трупа
	LD C,31
	LDIR
	Ms 4
	POP DE
	LD HL,xSHIP;+2
	CALL DELPCmlz
	JP PT128

L_L10	CALL SET8x2 ;кop II
	LD HL,7*256+34	;)
	CALL L_4var
	JR L_SPR1

L_L1	CALL SET8x2 ;корабль I
	LD HL,9*256+28
	CALL L_4var
	LD HL,#804
	LD A,16
	CALL L_INTR
	JR L_SPR1

L_L6	CALL PERgt1
	CALL SET4x4 ;Ubase I
	LD HL,4*256+24   ;)
	CALL L_4var
	CALL RND
	AND 3
	LD HL,T_L6
	CALL WT
	CALL L_IN64
	JR L_SPR1

L_L7	CALL PERgt1
	CALL SET4x4 ;Tleth
	LD HL,5*256+40
	CALL L_4var
	JR L_SPR1

T_ML0	DEFB   20,1,22,2,47,13,52,15,50,16,51,17,49,18,53,19
L_L0    ;подв.мир
	CALL RND
	AND 7
	LD HL,T_ML0
	CALL WT
	CALL L_1var
	CALL D2FLR
	CALL L_SWAP
	CALL L_DUP
	CALL L_COPY
	CALL L_InUf
	JP L_SPR4

L_L2    ;город-порт
	LD HL,3*256+23
	CALL RND
	RRCA
	LD A,16
	JR C,L_l2
	LD HL,10*256+44
	LD A,45
L_l2    PUSH AF
	CALL L_1v10
	CALL D2FLR
	CALL L_SWAP
	CALL L_DUP
	CALL L_COPY
	CALL RND
	AND #30
	LD L,A
	CALL RND
	AND #30
	LD H,A
	POP AF
	PUSH AF
	CALL L_INTR
	POP AF
	CP 16
	JR Z,L_l20
	LD BC,#1000 ;порт 2
	LD HL,#F000
L_l21	LD A,(HL)
	CP 11
	JR NZ,L_l22
	LD (HL),48
	JR L_l23
L_l22	CP 15
	JR NZ,L_l23
	LD (HL),50
L_l23	INC HL
	DEC BC
	LD A,C
	OR B
	JR NZ,L_l21
	JP L_SPR1
L_l20   LD HL,(L_IPOS) ;порт 1
	DEC H
	DEC L
	PUSH HL
	LD (TX),HL
	LD B,16
L_l24	LD A,16
	CALL PSP
	LD HL,TX
	INC (HL)
	DJNZ L_l24
	POP HL
	LD (TX),HL
	LD B,16
L_l25	LD A,16
	CALL PSP
	LD HL,TY
	INC (HL)
	DJNZ L_l25
	JP L_SPR1

CHECK3	;[]#3
	LD HL,TAB100+75
	LD A,(HL)
	LD DE,14-75
	ADD HL,DE
	NEG
	CP (HL)
	RET Z
	CALL NZ,MLOOP

L_L8	;колония II
	LD HL,12*256+46
	JR L_L498

L_L4    ;наша база
	LD HL,6*256+33 ;)
L_L498	CALL L_1v10
	CALL D2FLR
	CALL L_SWAP
	CALL L_COPY
	JP L_SPR1

L_L9	;Ubase II
	LD HL,11*256+45
	JR L_L498

       if PROTECT
CHECK7	;[]#7
	LD HL,(TAB100+87)
	LD B,10
	PUSH BC
CH7	INC L
	DEC H
	XOR A
	LD DE,(TAB100+56)
	SBC HL,DE
	POP BC
	RET Z
	DJNZ CH7
       endif
	
L_L3    ;остров
	LD HL,8*256+38
	CALL L_1v10
	LD A,16
	JR l_l35

T_L6	DEFW 0,#30,#3000,#3030
L_L5	;Ucolony I
	CALL PERgt1
	LD HL,14*256+48
	CALL L_1var
	LD A,64
l_l35   PUSH AF
	CALL D2FLR
	CALL L_SWAP
	CALL L_DUP
	CALL L_COPY
	CALL RND
	AND #30
	LD L,A
	CALL RND
	AND #30
	LD H,A
	POP AF
	PUSH AF
	CALL L_INTR
	POP AF
	CP 64
	JP Z,L_SPR4
	JP L_SPR1

L_SWAP	;cоздать MAP16 и тасовать
	LD BC,#1000
	LD HL,MAP16
Lsw0	LD (HL),C
	INC HL
	INC C
	DJNZ Lsw0
	LD DE,MAP16
	LD H,D
	LD B,16
Lsw1	CALL RND
	AND #F
	LD L,A
	LD A,(DE)
	LD C,(HL)
	LD (HL),A
	LD A,C
	LD (DE),A
	INC DE
	DJNZ Lsw1
	RET

L_DUP	;продублировать 0-4
	LD H,MAP16/256
	LD D,H
	CALL RND
	AND 7
	RET Z
	LD B,A
Ldup1	CALL RND
	AND #F
	LD L,A
	CALL RND
	AND #F
	LD E,A
	LD A,(HL)
	LD  (DE),A
	DJNZ Ldup1
	RET

L_C16	;копировать кусок 16x16  ;HL-YX, A- No куска
	LD E,0
	ADD A,#90
	LD D,A
	PUSH DE
	PUSH HL
	XOR A
	CALL LCC1
	POP HL
	POP DE
	LD A,#10
	ADD A,D
	LD D,A
	LD A,1
LCC1	CALL FLOOR
	LD C,16
Lcc1	LD B,16
	LD (TX),HL
	PUSH HL
Lcc0	CALL GSP ;psp
	LD A,(DE)
	INC DE
	EXX
	LD (HL),A
	EXX
	LD HL,TX
	INC (HL)
	DJNZ Lcc0
	POP HL
	INC H
	DEC C
	RET Z
	JR NZ,Lcc1

L_COPY	;Kопировать карту 64x64 по массиву MAP16
MAP16	EQU #B100
	LD DE,MAP16
	LD C,4
	LD H,0
Lcc3	LD B,4
	LD L,0
Lcc4	LD A,(DE)
	INC DE
	PUSHs
	CALL L_C16
	POPs
	LD A,L
	ADD A,16
	LD L,A
	DJNZ Lcc4
	LD A,H
	ADD A,16
	LD H,A
	DEC C
	JR NZ,Lcc3
	RET

L_1var  LD A,L ;H-XM L-XL
	LD (L_MOD),A
	LD A,H
	LD HL,DSCR
	CALL CREAD
	LD HL,DSCR;+2
	LD DE,#B800
	CALL DELPCmlz
	LD BC,96
	LD HL,#B800
	LD DE,#B000
	LDIR
	LD C,96
	LD DE,xCONV
	LDIR
       ld hl,#b800 ;TODO FIX! костыль! где взять данные 96+96 в начале *.LND?
	LD DE,#D000
	LD BC,#1000
	LDIR
	LD A,(L_MOD)
	LD HL,DSCR
	CALL READ
	LD HL,DSCR;+2
	LD DE,#E000
	CALL DELPCmlz
	CALL SET4x4
	RET

L_1v10  LD A,L ;H-XM L-XL
	LD (L_MOD),A
	LD A,H
	LD HL,DSCR
	CALL CREAD
	LD HL,DSCR;+2
	LD DE,#B800
	CALL DELPCmlz
	LD BC,96
	LD HL,#B800
	LD DE,#B000
	LDIR
	LD C,96
	LD DE,xCONV
	LDIR
	LD DE,#B800
	LD BC,#2800
	LDIR
	LD A,(L_MOD)
	LD HL,DSCR
	CALL READ
	LD HL,DSCR;+2
	LD DE,#E000
	CALL DELPCmlz
	CALL SET4x4
	RET

L_4var  CALL RND ;H-XM, L-XLa..d
	AND 3
	ADD A,L
	LD (L_MOD),A
	LD A,H
	LD HL,DSCR
	CALL CREAD
	LD HL,DSCR;+2
	LD DE,#B800
	CALL DELPCmlz
	LD BC,96
	LD HL,#B800
	LD DE,#B000
	LDIR
	LD C,96
	LD DE,xCONV
	LDIR
	LD DE,#B800
	LD BC,#2800
	LDIR
	LD A,(L_MOD)
	LD HL,DSCR
	CALL READ
	LD HL,DSCR;+2
	LD DE,#E000
	CALL DELPCmlz
	RET

D2FLR	;преобр. ландшафт 128x32 в куски 16x16
	LD DE,#9000
	LD HL,#E000
	CALL DCFLR
	LD DE,#A000
	LD HL,#F000
DCFLR	PUSH HL
	CALL DCHALF
	POP HL
	SET 3,H
DCHALF	LD C,8
DCH0	PUSH HL
	LD B,16
DCH1	PUSH BC
	LD BC,16
	LDIR
	LD BC,112
	ADD HL,BC
	POP BC
	DJNZ DCH1
	POP HL
	LD A,16
	ADD A,L
	LD L,A
	DEC C
	JR NZ,DCH0
	RET

L_IN64	LD A,64
L_INTR	;поместить истребитель в поз. HL
	;спр 64 -> (A)
	LD (L_IPOS),HL
	PUSH HL
	PUSH AF
	LD HL,xL0;+2
	CALL DExLP
	LD HL,DSCR+#1000
	LD BC,768
	POP DE
	LD A,64
L_in0	CPIR
	JR NZ,L_in1
	EX AF,AF
	DEC HL
	LD (HL),D
	INC HL
	EX AF,AF
L_in1	JP PE,L_in0
	LD A,(T_INTR)
	POP HL
	JP L_C16

DExLP	Ms 3 ;декомпр и расшифр карту с HL
	LD DE,DSCR
	PUSH DE
	CALL DELPCmlz
	CALL MEM7
	CALL OFFS
	POP HL
	LD DE,SCR
	LD BC,#1000
	PUSH BC
	PUSH DE
	PUSH HL
	PUSH DE
	LDIR
	POP HL
	POP DE
	CALL DCFLR 
	POP DE
	POP BC
	LD HL,DSCR+#1000
	PUSH HL
	PUSH DE
	LDIR
	POP HL
	POP DE
	CALL DCFLR
	JP PT128

CREAD	;загр.+уст.цвет+пров.защиты
	PUSH AF
	EXX
	LD HL,C_ONOF
	BIT 0,(HL)
	JR NZ,CREA1
	LD HL,C_tab-1
	CALL BT
	JR CREA2
CREA1	LD A,#38
CREA2	LD (COLOR),A
	EXX
	POP AF
	CALL READ
       if PROTECT
	CALL TR_SEC ; []
       endif
	CALL PT128
       if PROTECT
	JP CHECK7
       else
        ret
       endif

T_P0	DEFW #0000,#0010,#0020,#0030 ;поз.истр
	DEFW #1030,#2030,#3030,#3020
	DEFW #3010,#3000,#2000,#1000
	DEFW #0000,#0010,#0020,#0030
	DEFW #1030,#2030,#3030,#3020
	DEFW #3010
T_u0	DEFB 8,4,3,9,10,5,6,0,2 ;нач.карт НЛО
L_InUf	CALL RND;пост. Истр+UFO
	AND #F
	CP 12
	JR NC,L_InUf
	PUSH AF
	LD HL,T_P0
	CALL WT
	CALL L_IN64
L_u5	CALL RND
	AND 7
	JR Z,L_u5
	LD E,A
	POP AF
	INC A
	INC A
	ADD A,E
	LD HL,T_P0
	CALL WT
	PUSH HL
	LD A,(L_UFO)
	LD HL,xL0;+2
	CP 7
	JR C,L_u0
	LD HL,xL1;+2
L_u0	CALL DExLP
	LD A,(L_UFO)
	LD HL,T_u0
	CALL BT
	CP 7
	JR C,L_U1
	POP HL	;мал
	JP L_C16
L_U1	CP 3
	JR C,L_UB
	CP 6
	JR NC,L_UB
L_UM	POP HL;мал x2
	EX AF,AF
	LD A,H
	CP #30
	JR C,L_U2
	LD H,#20
L_U2	EX AF,AF
	PUSH AF
	PUSH HL
	CALL L_C16
	POP HL
	LD A,#10
	ADD A,H
	LD H,A
	POP AF
	ADD A,8
	JP L_C16
L_UB	POP HL
	PUSH AF
	EX AF,AF
	LD A,L
	CP #30
	JR C,L_U3
	LD L,#20
L_U3	PUSH HL
	EX AF,AF
	CALL L_UM+1
	POP HL
	LD A,16
	ADD A,L
	LD L,A
	POP AF
	INC A
	JR L_UM+1

L_LL	DEFW L_L0,L_L1,L_L2,L_L3,L_L4,L_L5
	DEFW L_L6,L_L7,L_L8,L_L9,L_L10

	DEFM "++ This program protected by copyright law of Russia ++"

;===================== Победа-Demo ===========

POBEDA	CALL PT128
	LD A,21
	LD HL,SCR+9800
	CALL READ
	LD HL,SCR+9800;+2
	LD DE,SCR
	PUSH DE
	CALL DELPCmlz
	LD HL,(#F002)
	LD DE,DSCR
	LD BC,6144
	PUSH DE
	PUSH BC
	LDIR
	CALL OFFS
	POP BC
	POP HL
	POP DE
	LDIR
	LD BC,736
	PUSH DE
	POP HL
	INC DE
	LD (HL),#70
	LDIR
	LD (HL),0
	LDI
	LD BC,30
	LD (HL),#68
	LDIR
	LD (HL),0
	CALL PT128
	CALL #C000 ;???
	XOR A
	LD (SX),A
	CALL STS
	LD HL,(#F004)
	LD (TXT),HL
		
P_LOOP	CALL E_I
	CALL PT128
       if PROTECT
	CALL #C006 ;???
       endif
	LD HL,SX
	INC (HL)
	LD A,(HL)
	AND 7
	LD (HL),A
	JR NZ,P_L1
	CALL PT128
	LD HL,(TXT)
	INC HL
	LD (TXT),HL
	LD A,(HL)
	CP 126
	JR C,P_L2
	LD HL,(#F004)
	LD (TXT),HL
	LD A,(HL)
P_L2	EX AF,AF
	CALL MEM7
	EX AF,AF
	LD DE,#171F
	LD BC,FONT
	LD L,A
	LD A,1
	CALL SYMBOL
P_L1	CALL MEM7
	CALL P_SCRL
	LD BC,#BFFE
	IN A,(C)
	AND 1
	JR NZ,P_LOOP
	LD BC,65533
	LD A,7
	OUT (C),A
	LD BC,49149
	LD A,#FF
	OUT (C),A
	RET

P_SCRL	LD HL,SCR+#1000+255
	LD B,8
P_SC0	pushs
	LD B,31
P_SC1	RL (HL)
	DEC L
	DJNZ P_SC1
	pops
	INC H
	DJNZ P_SC0
	RET

PERgt1	LD HL,PERIOD ;цель соотв? []
	LD A,(HL)
	CP 2
	RET NC
	JP P_LOOP

	DEFM "Do You like me ?"

C_tab   DEFB #28,#38,#71,#69,#79,#38,#30,#60
	DEFB #78,#70,#78,#71,#30,#28,#68,#70,#78,#60,#71
