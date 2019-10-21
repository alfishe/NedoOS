;Kурсор на прерываниях	******

BLITER	;обновл экр с уч прерыв
	CALL MEM7
	XOR A
	LD (P_FLAG),A
	DEC A
	LD (V_LINE),A
	LD A,2
	LD (V_FLAG),A
	CALL V_GET2
	CALL V_MRK2
	LD A,1
	LD (V_FLAG),A
       if EGA
        call changescrpg
       else
	CALL DS2SC
       endif
	CALL V_copy ;м.быть уч P_FLAG=1 :)
	XOR A
	LD (V_FLAG),A
	RET

DS2SC	;регенер экр
	LD HL,DSCR
	LD DE,SCR
	LD B,192
DSS0	LD A,H
	CPL
	AND %11000
	RET Z
	PUSH BC
	PUSH DE
	PUSH HL
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	LD HL,V_LINE
	INC (HL)
	POP HL
	POP DE
	POP BC
	INC H
	INC D
	LD A,H
	AND 7
	JR NZ,DSS1
	LD A,L
	ADD A,32
	LD L,A
	LD E,A
	JR C,DSS1
	LD A,H
	SUB 8
	LD H,A
	LD A,D
	SUB 8
	LD D,A
DSS1	LD A,(P_FLAG)
	OR A
	CALL NZ,V_BLIT
	DJNZ DSS0
	RET

Vforce	;принудительный выв A строк
	EXX
	LD B,8
	CALL DSS0
	EXX
	RET

V_BLIT	;выв курс во время рефреша
	DI
	EXX
	XOR A
	LD (P_FLAG),A
	LD HL,V_LINE
	LD A,(G_MY) ;очистка
	CP (HL)
	JR C,vbt1
	JR NZ,vbt2
vbt1	ADD A,8
	CP (HL)
	JR C,vbt4
	CALL Vforce
vbt4	CALL V_copy
vbt2	CALL V_PUT1
	CALL V_PUT2
	LD HL,(MX)  ;взятие в буф
	LD (G_MX),HL
	LD A,H
	LD HL,V_LINE
	CP (HL)
	JR C,vpt1
	JR NZ,vpt2
vpt1	ADD A,8
	CP (HL)
	JR C,vpt4
	CALL Vforce
vpt4	CALL V_GET1
	CALL V_GET2
	LD A,(GBAD2+1)
	XOR #60
	LD (GBAD1+1),A
	CALL V_copy
	CALL V_MRK1
	JR vptR
vpt2	CALL V_GET1
	CALL V_GET2
	CALL V_MRK1
	CALL V_MRK2
vptR	EXX
	EI
	RET

        if 1==0
ON256	LD	A,%10000
	JR	M2
OFF256	XOR	A
M2	LD	BC,#1FFD ;скорп
	OUT	(C),A
	LD	A,%11000
	LD	B,#7F
	OUT	(C),A ;пент
	RET
        endif

INAR0	;Обр прерываний
	PUSHs
	EXX
	PUSHs
	PUSH AF
	EX AF,AF
	PUSH AF
	PUSH IX
	PUSH IY
	LD A,(R128)
	LD (IR128),A
        if EGA
        ld a,(pgmain4000)
        SETPG16K
        ld a,(pgmain8000)
        SETPG32KLOW
        endif
        if 1==0 ;???
	;анти-теневик
antiTM	LD HL,(G_MX) ;[**]
	LD A,H
	OR #C0
	LD H,A
	CALL ON256
	LD E,(HL) ;д.быть #A4 байт-заполнитель или (HL)
	CALL OFF256
	LD A,E
	CP #A4
	JR Z,INAMM
	CP (HL)
	RET NZ
INAMM	
        endif
	;музыка
        CALL MEM6
	LD A,(MUSONF)
	OR A
	JR Z,INA0FX
	;патч к музыке
	 XOR A
	 LD (#EEC9),A
	 LD (#F221),A
	CALL WMUSIC+6  ;6
	JR INA0M
INA0FX	LD BC,#FFFD
	LD A,7
	OUT (C),A
	LD A,B
	LD B,#BF
	OUT (C),A
	LD (#EEC9),A
INA0M	CALL pSOUND ;эффекты
	CALL MMOV
	LD A,(V_FLAG)
	CP 1
	JR Z,INA01
	JR NC,INA02
	CALL MEM7
	LD HL,(JP_SUB+1)
	PUSH HL
	LD HL,(SET_SP+1)
	PUSH HL
	LD HL,(SCRADR)
	PUSH HL
	CALL V_PUT1
	LD HL,(MX)
	LD (G_MX),HL
	CALL V_GET1
	CALL V_MRK1
	POP HL
	LD (SCRADR),HL
	POP HL
	LD (SET_SP+1),HL
	POP HL
	LD (JP_SUB+1),HL
	JR INA02
INA01	LD (P_FLAG),A
INA02	;LD A,(IR128)
IR128=$+1
        ld a,0
	CALL MEM
         ;SETPG32KHIGH
        if EGA
        ld a,(curpg4000)
        SETPG16K
        ld a,(curpg8000)
        SETPG32KLOW
        endif
	POP IY
	POP IX
	POP AF
	EX AF,AF
	POP AF
	POPs
	EXX
	POPs
	RET


;---------------------------------------

G_IMG1	DEFB %11111100,%11111100 ;обычн курсор
	DEFB %11111110,%10000110
	DEFB %11111110,%10000010
	DEFB %11111110,%10000110
	DEFB %11111111,%10000011
	DEFB %11111111,%11010001
	DEFB %01111111,%01111011
	DEFB %00001110,%00001110

G_MAP1	DEFB %11111100,%00000000 ;курсор на карте/при нажатом FIRE
	DEFB %11111110,%01111000
	DEFB %11111110,%01000100
	DEFB %11111110,%01001000
	DEFB %11111111,%01010100
	DEFB %11111111,%00101010
	DEFB %01111111,%00000100
	DEFB %00001110,%00000000

G_FIX1	DEFB %11111100,%00000000 ;курсор при зафикс. цели
	DEFB %11111110,%01111000
	DEFB %11111110,%01111100
	DEFB %11111110,%01111000
	DEFB %11111111,%01111100
	DEFB %11111111,%00101110
	DEFB %01111111,%00000100
	DEFB %00001110,%00000000


V_copy	;gbu2->gbu1
	LD BC,16
	LD HL,GBU2
	LD DE,GBU1
	LDIR
	RET

V_PUT1	;  gbu1->[SCR]
	LD HL,(GBAD1)
         ld a,h
         or a
         ret z
	LD DE,GBU1
	JR v1pEN

V_PUT2	;  gbu2->[DSCR]
	LD HL,(GBAD2)
	LD DE,GBU2
v1pEN	CALL v1p0
	LD A,L
	AND 31
	CP 31
	RET Z
	INC L
v1p0	LD B,8
	PUSH HL
v1p1	LD A,(DE)
	LD (HL),A
	INC DE
	INC H
	LD A,H
	AND 7
	JR NZ,v1p2
	LD A,L
	ADD A,32
	LD L,A
	JR C,v1p3
	LD A,H
	SUB 8
	LD H,A
	JR v1p2
v1p3	LD A,H
	CPL
	AND %11000
	JR Z,v1p6
v1p2	DJNZ v1p1
	POP HL
	RET
v1p5	INC DE
v1p6	DJNZ v1p5
	POP HL
	RET


V_GET1	; HL->gbad1  [SCR]->gbu1
	LD DE,(G_MX) ;выв гр курс
	CALL STS
	CALL PCOORD
	LD (GBAD1),HL
	LD DE,GBU1
	CALL v1g0
	INC L
v1g0	LD B,8
	PUSH HL
v1g1	LD A,(HL)
	LD (DE),A
	INC DE
	INC H
	LD A,H
	AND 7
	JR NZ,v1g2
	LD A,L
	ADD A,32
	LD L,A
	JR C,v1g2
	LD A,H
	SUB 8
	LD H,A
v1g2	DJNZ v1g1
	POP HL
	RET

V_GET2	; HL->gbad2  [DSCR]->gbu2
	LD DE,(G_MX) ;выв гр курс
	CALL STD
	CALL PCOORD
	LD (GBAD2),HL
	LD DE,GBU2
	CALL v2g0
	INC L
v2g0	LD B,8
	LD A,L
	AND 31
	CP 24
	JR C,v2g00
	PUSH HL
	LD HL,GBU1-GBU2
	ADD HL,DE
	LD BC,8
	LDIR
	POP HL
	RET
v2g00	PUSH HL
v2g1	LD A,(HL)
	LD (DE),A
	INC DE
	INC H
	LD A,H
	AND 7
	JR NZ,v2g2
	LD A,L
	ADD A,32
	LD L,A
	JR C,v2g2
	LD A,H
	SUB 8
	LD H,A
v2g2	DJNZ v2g1
	POP HL
	RET


V_MRK2	;mrk->SCR
	LD BC,(GBAD2)
	JR vmr1

V_MRK1	;mrk->SCR
	LD BC,(GBAD1)
         ld a,b
         or a
         ret z
vmr1	LD HL,(G_MX)

        if EGA
        ;TODO
        ret
        
        else

	LD A,H
	SUB 185
	JR C,vmr2
	XOR 7
	JR vmr3
vmr2	LD A,8
vmr3	LD (G_SIZE),A
	LD A,L
	AND 7
	LD HL,HE_N
	CALL WT
	LD (JP_SUB+1),HL
	LD HL,(G_IMG)
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD (SET_SP+1),SP
	LD SP,HL
	LD L,C
	LD H,B
	LD A,(G_SIZE)
	LD B,A
	JP JP_SUB

        endif ;~EGA
