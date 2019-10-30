;-----cобытие------

EVENTr	;смена героя - новое меню
	XOR A
_EXT	LD (ext_M),A
	LD A,1
	LD (F_FUNC),A
EVENT	;произошло событие, возможна смена меню
	LD A,1
	LD (_event),A
	RET


;------обновление окна cоcтояний

TX_ADR	;выч адр назв (A->HL)
       if EGA
;[8*4*6 = 192]
;7*4*6
        ;ld l,a
        ;add a,a
        ;add a,l
        ;ld l,a ;x3
        ;ld h,0
        ;add hl,hl
	LD L,A ;x3
	ADD A,A
	ADD A,L
	LD L,A
	LD E,A
	XOR A
	LD H,A
	LD D,A
	ADD HL,HL;x7
	ADD HL,DE
	ADD HL,HL
	ADD HL,DE
	ADD HL,HL;x7
        add hl,hl
        add hl,hl
	LD DE,0xc000+(8*4*192) ;WNAMES
	ADD HL,DE
       else
	LD L,A ;x3
	ADD A,A
	ADD A,L
	LD L,A
	LD E,A
	XOR A
	LD H,A
	LD D,A
	ADD HL,HL;x7
	ADD HL,DE
	ADD HL,HL
	ADD HL,DE
	ADD HL,HL;x7
	LD DE,WNAMES
	ADD HL,DE
       endif
	RET


putTX	;напр на выв cообщ A
	LD HL,_msg
	CP (HL)
	RET Z ;еcли дублируетcя
	LD (HL),A
	CALL TX_ADR
	LD (pTX_AD),HL
	LD A,1
	LD (pTXdel),A
	RET

dirTX	CALL TX_ADR ;экcтр cообщ A
	LD A,(pTXdel)
	OR A
	JR NZ,dtx1
	LD DE,(TX_AD)
	LD (pTX_AD),DE
dtx1	LD (TX_AD),HL
	LD A,6 ;t задер экcтр c
dtx2	LD (pTXdel),A
	CALL MEM7
	CALL otx1
	JP MEM0

outTX	LD HL,pTXdel
	LD A,(HL)
	OR A
	RET Z
	DEC (HL)
	RET NZ
	LD HL,(pTX_AD)
	LD (TX_AD),HL
otx1
        if EGA
	jp TX48x7
        else
	LD BC,#207
	LD HL,#819 ;для isOVER
	LD A,2
	LD (V_FLAG),A
	CALL isOVER
	JR NC,otx2
	CALL V_PUT1
	CALL TX48x7
	CALL V_GET1
	CALL V_MRK1
	JR otx0
otx2	CALL TX48x7
otx0	XOR A
	LD (V_FLAG),A
	RET
        endif


indSYM
        if EGA
;%rlrrrlll
_10=0x47
_01=0xb8
_00=0x00
_11=0xff
indsym_nomana
        db _00,_00,_00,_00
        db _00,_00,_00,_00
        db _00,_00,_00,_00
        db _00,_00,_00,_00
        db _00,_00,_00,_00
indsym_mana
        db _00,_10,_00,_10
        db _00,_11,_01,_10
        db _00,_10,_10,_10
        db _00,_10,_00,_10
        db _00,_10,_00,_10
indsym_percent
        db _00,_11,_00,_10
        db _00,_11,_01,_00
        db _00,_00,_10,_00
        db _00,_01,_01,_10
        db _00,_10,_01,_10
        else
	DEFB #FF,#FF,#FF,#FF,#FF ;no mana indication
	;DEFB #DD,#C9,#D5,#DD,#DD
        db 0b11011101 ;M
        db 0b11001001
        db 0b11010101
        db 0b11011101
        db 0b11011101
	;DEFB #CD,#CB,#F7,#E9,#D9
        db 0b11001101 ;%
        db 0b11001011
        db 0b11110111
        db 0b11101001
        db 0b11011001
        endif

oINDY	;выв инд
        if 1==0
	CALL _TST#7
        endif
        
        if 1==0

        if EGA
        call setpgsscr40008000_current
        call oINDYpp
        call changescrpg_current
        call setpgsscr40008000_current
        call oINDYpp
        call changescrpg_current
        jp setpgsmain40008000
oINDYpp
        endif
        
        else
        
        if EGA
	LD A,2
	LD (V_FLAG),A ;cursor off
	CALL V_PUT1 ;visible screen
        call setpgsscr40008000_current
        call oINDYpp
	CALL V_GET1
        call V_MRK1 ;на видимом экране (в это время G_MX не обновляется, т.к. стрелочка выключена)
	xor a
	LD (V_FLAG),A ;cursor on
	CALL V_PUT2
        call setpgsscr40008000
        call oINDYpp
        call setpgsmain40008000
	jp V_GET_MRK2
oINDYpp
        endif

        endif
        
        if EGA
	LD HL,0x6000+(40*40)+0x1d
        else
	LD HL,SCR+189 ;0xbd
        endif
	LD BC,IND1
	CALL oIND_
	LD A,(IND2TP)
	OR A
        
        if EGA
;mana indication symbol
	PUSH AF
	LD DE,indsym_nomana
	CP 1
	JR C,oiL1
	LD DE,indsym_mana
	JR Z,oiL1
	LD DE,indsym_percent
oiL1
	LD HL,0x4000+(59*40)+0x1e
	LD B,5
oinL
        push hl
	LD A,(DE)
	LD (HL),A
	INC DE
        ld a,h
        add a,0x40
        ld h,a
	LD A,(DE)
	LD (HL),A
	INC DE
        ld a,h
        add a,0x20-0x40
        ld h,a
	LD A,(DE)
	LD (HL),A
	INC DE
        ld a,h
        add a,0x40
        ld h,a
	LD A,(DE)
	LD (HL),A
	INC DE
        pop hl
        ld a,l
        add a,40
        ld l,a
        jr nc,$+3
        inc h
	DJNZ oinL
	POP AF
        
        else ;~EGA
        
	PUSH AF
	LD DE,indSYM
	CP 1
	JR C,oiL1
	LD DE,indSYM+5
	JR Z,oiL1
	LD DE,indSYM+10
oiL1
	LD HL,SCR+#3FE
	LD B,5
oinL	LD A,(DE)
	LD (HL),A
	INC DE
	INC H
	DJNZ oinL
	POP AF
        
        endif ;~EGA
        
        if EGA
	LD HL,0x6000+(40*40)+0x1e
        else
	LD HL,SCR+190 ;0xbe
        endif
	JR NZ,oin0
	LD B,16
	LD E,%10111110
	JR oin3
oin0	LD BC,IND2
oIND_	PUSH HL
	LD A,(BC)
	INC BC
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL;x16
	EX DE,HL
	LD A,(BC)
	LD L,A
	CALL DIVB2;->E
	LD A,E
	OR A
	JR NZ,oin1
	DEC BC
	LD A,(BC)
	OR A
	JR Z,oin1
	LD A,1
oin1	LD C,A
	LD A,16
	SUB C
	POP HL
	JR Z,oin2
	LD B,A
	LD E,%10111110
	CALL oin3
oin2	LD A,C
	OR A
	RET Z
	LD B,C
	LD E,%10100010
oin3	LD (HL),E
        if EGA
        ld a,l
        add a,40
        ld l,a
        jr nc,$+3
        inc h
        else
	INC H
	LD A,H
	AND 7
	JR NZ,oin31
	LD A,H
	SUB 8
	LD H,A
	LD A,L
	ADD A,32
	LD L,A
oin31
        endif
	DJNZ oin3
	RET

;---------кнопки----------
oBUT	LD HL,_BUT_H ;выв кнопок
	EXX
	LD DE,BUT_H ;выв гер
	LD HL,#519
	CALL BUT_1
	LD HL,#A19  ;выв 6 кноп
	LD B,3
obu1	PUSH BC
	PUSH HL
	PUSH HL
	CALL BUT_1
	POP HL
	INC L
	INC L
	INC L
	CALL BUT_1
	POP HL
	INC H
	INC H
	INC H
	POP BC
	DJNZ obu1
	RET

BUT_1	LD A,(DE)
	INC DE
	EXX
	CP (HL)
	LD (HL),A
	INC HL
	EXX
	RET Z
	PUSH DE
	PUSH HL
	LD L,A
	LD H,0
        
        if EGA
        
;*288 = 12 * 24 = 9 * 32
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,de ;*9
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl
        add hl,hl ;*9*32
        ld de,0xa000
        add hl,de
        bit 6,h
        ld a,30
        jr nz,BUT_1_nopg0
        ld d,0x20
        add hl,de
        dec a
BUT_1_nopg0
        call _128
        ex de,hl
        
        else
        
	PUSH HL
	ADD HL,HL
	ADD HL,HL
	PUSH HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	POP DE
	ADD HL,DE
	POP DE
	ADD HL,DE;x69
	LD DE,WBUTT+23
	ADD HL,DE
	EX DE,HL
        
        endif
        
        if 1==0
        
	POP HL
	PUSH HL
	PUSH DE
	LD BC,#404
	LD A,2
	LD (V_FLAG),A
	CALL isOVER ;курсор над кнопками?
	JR NC,btt1
        
        if EGA
	LD A,2
	LD (V_FLAG),A ;выключить стрелочку
	CALL V_PUT1 ;на видимом экране
        pop de
        pop hl
        push de
        push hl
        call setpgsscr40008000_current
	CALL PUTbut ;в конце делает setpgsmain40008000
	CALL V_GET1
        call V_MRK1 ;на видимом экране (в это время G_MX не обновляется, т.к. стрелочка выключена)
	xor a
	LD (V_FLAG),A ;включить стрелочку
        pop hl
        pop de
        call setpgsscr40008000 ;на рисуемом экране
	CALL PUTbut ;в конце делает setpgsmain40008000
        
        else ;~EGA

	CALL V_PUT1
	POP DE
	POP HL
	CALL PUTbut
	CALL V_GET1
	CALL V_MRK1 ;перерисовываем курсор
        
        endif ;~EGA
        
	JR btt0
btt1
;стрелочка не на панели (а вдруг она была на панели и нельзя будет восстановить?)
        if EGA
	LD A,2
	LD (V_FLAG),A ;выключить стрелочку
	CALL V_PUT1 ;на видимом экране
        pop de
        pop hl
        push de
        push hl
        call setpgsscr40008000_current
	CALL PUTbut
	CALL V_GET1
        call V_MRK1 ;на видимом экране (в это время G_MX не обновляется, т.к. стрелочка выключена)
	xor a
	LD (V_FLAG),A ;включить стрелочку
        pop hl
        pop de
        call setpgsscr40008000 ;на рисуемом экране
	CALL PUTbut
        else ;~EGA
	POP DE
	POP HL
	CALL PUTbut
        endif ;~EGA
        
btt0	XOR A
	LD (V_FLAG),A
	POP DE
	RET

        else
        
	POP HL

        if EGA
	PUSH HL
	PUSH DE

	 ;LD BC,#404
	 ;LD A,2
	 ;LD (V_FLAG),A
	 ;CALL isOVER ;курсор над кнопками?
	 ;JR C,$ ;над кнопками

	LD A,2
	LD (V_FLAG),A ;выключить стрелочку
	CALL V_PUT1 ;на видимом экране
	POP DE
	POP HL
        push de
        push hl
        call setpgsscr40008000_current
	CALL PUTbut ;в конце делает setpgsmain40008000
	CALL V_GET1
        call V_MRK1 ;на видимом экране (в это время G_MX не обновляется, т.к. стрелочка выключена)
	xor a
	LD (V_FLAG),A ;включить стрелочку
	CALL V_PUT2 ;на рисуемом экране
        pop hl
        pop de
        call setpgsscr40008000 ;на рисуемом экране
	CALL PUTbut ;в конце делает setpgsmain40008000
	CALL V_GET_MRK2 ;на рисуемом экране
        
        else ;~EGA

	PUSH HL
	PUSH DE
	LD BC,#404
	LD A,2
	LD (V_FLAG),A
	CALL isOVER ;курсор над кнопками?
	JR NC,btt1        
	CALL V_PUT1
	POP DE
	POP HL
	CALL PUTbut
	CALL V_GET1
	CALL V_MRK1 ;перерисовываем курсор        
	JR btt0
btt1
;стрелочка не на панели (а вдруг она была на панели на другом экране и нельзя будет восстановить?)
	POP DE
	POP HL
	CALL PUTbut
btt0	XOR A
	LD (V_FLAG),A
       
        endif ;~EGA

	POP DE
	RET
        
        endif

PUTbut
        if EGA
;hl=yx (chrs)
        ld a,l
        ld l,h
        ld h,0
        sla l
        sla l
        sla l ;y*8
        ld b,0x40/8
        ld c,l
        add hl,hl
        add hl,hl
        add hl,bc
        add hl,hl
        add hl,hl
        add hl,hl ;y*8*40
        add a,l
        ld l,a
        jr nc,$+3
        inc h
;hl=scr
        ld bc,0x180c
        jp primgega_pixsz ;в конце делает setpgsmain40008000

        else ;~EGA
        
	LD B,3
ptg0	PUSH BC
	PUSH HL
	PUSH DE
	 EX DE,HL
	 LD A,(HL)
	 PUSH AF
	 LD (HL),0
	 LD BC,-23
	 ADD HL,BC
	EX DE,HL
	LD BC,#301
	CALL PUTSYM
	POP AF
	POP HL
	LD (HL),A
	LD BC,23
	ADD HL,BC
	EX DE,HL
	POP HL
	POP BC
	INC L
	DJNZ ptg0
	RET
        
        endif



isOVER	;?перкр курcор и обл вывода? NC-не перекр
	;HL-угол,BC-размер окна+1
	LD A,(G_MX)
	RRA
	RRA
	RRA
	AND %11111
	INC A
	SUB L
	CP C
	RET NC
	LD A,(G_MY)
	RRA
	RRA
	RRA
	AND %11111
	INC A
	SUB H
	CP B
	RET


outNUM	;выв чисел для шахты/избы
	LD A,(BUT_N+2)
	CP 80
	JR Z,oNmine
	CP 77
	RET NZ
	;изба
	CALL oNUMh
	LD E,C
	LD HL,#E1D
	CALL oNbcd
	CALL oHOMh
	LD E,A
	LD HL,#B1D
oNbcd	PUSH HL
	CALL BCD
	POP DE
	LD A,(DCstr+3)
	CALL iPRINT
	LD A,(DCstr+4)
	JP iPRINT
	;
oNUMh	;число юнитов, которым нужна пища ->C
	LD HL,HUMAN
	LD D,0
	LD BC,#3000
oNh1	LD A,(HL)
	OR A
	JR NZ,oNh2
	LD E,16
	JR oNh3
oNh2	LD E,4
	ADD HL,DE
	LD A,(HL)
	CP 18
	JR NC,oNh4
	INC C
oNh4	LD E,12
oNh3	ADD HL,DE
	DJNZ oNh1
	RET
	;
oHOMh	LD A,8 ;число предост пищи (4*N_ферм+1)->A
	CALL searcB
	ADD A,A
	ADD A,A
	INC A
	RET
	;
oNmine	;шахта
	LD A,(SEL_T)
	CP 8
	RET NZ
	LD A,(SEL_N)
	CALL B_IX
	LD E,(IX+4)
	LD D,(IX+5)
	CALL BCD
	LD DE,#E19
	LD HL,DCstr+1
	LD B,4
oNm1	LD A,(HL)
	INC HL
	CALL iPRINT
	DJNZ oNm1
	XOR A
	CALL iPRINT
	XOR A
	JP iPRINT

searcB	;поиск здания A; кол-во построеных->A
	LD C,A
	XOR A
	EX AF,AF
	LD HL,HBUILD
	LD D,0
	LD B,32
oNi1	LD A,(HL)
	OR A
	JR NZ,oNi2
	LD E,8
	JR oNi3
oNi2	INC L
	INC L
	LD A,(HL)
	CP 10
	JR C,oNi6
	SUB 10
oNi6	CP C	;то?
	LD E,6
	JR NZ,oNi3
	INC HL
	INC HL
	LD E,4
	LD A,(HL) ;построено?
	INC A
	CP 253
	JR NC,oNi3
	EX AF,AF
	INC A
	EX AF,AF
oNi3	ADD HL,DE
	DJNZ oNi1
	EX AF,AF
	RET

DCMM	DEFW 10000,1000,100,10,1
;DCstr	DEFM "roXet"
;	DEFB #7F

BCD	;BCD-конв DE->DCstr
	EXX
	LD HL,DCstr
	EXX
	LD HL,DCMM
	LD B,5
bcd0	LD A,(HL)
	INC HL
	PUSH HL
	LD H,(HL)
	LD L,A
	EX DE,HL
	XOR A
bcd1	AND A
	SBC HL,DE
	JR C,bcd2
	INC A
	JR bcd1
bcd2	ADD HL,DE
	EX DE,HL
	EXX
	LD (HL),A
	INC HL
	EXX
	POP HL
	INC HL
	DJNZ bcd0
	RET

iPRINT	;inv печать символа А в поз DE(yx)
	PUSHs
        if EGA
        call prchar
        else
	LD C,A
	CALL SCOORD
	EX DE,HL
	LD A,C
	ADD A,A
	LD BC,(FONT)
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,BC
	LD B,4
iPR1	LD A,(HL)
	CPL
	LD (DE),A
	INC HL
	INC D
	LD A,(HL)
	CPL
	LD (DE),A
	INC HL
	INC D
	DJNZ iPR1
        endif
	POPs
	INC E
	RET

spc_DO	;1-команда иcп по space ;2-исполняется только для героев
	DEFB 0,1,0,0,0,0,0,2,2,2
	DEFB 2,2,2,0,0,0,1,1,1,1
	DEFB 0,0,0,0,0,1,1,1,1,1
	DEFB 1,1,1,1,1,1,1,1,1,1
	DEFB 1,1,1,1,1,2,2,2,0,2
	;оcтальные -0

sq1	EQU ATR+345
sqrADR	DEFW sq1,sq1+3,sq1+96,sq1+99,sq1+192,sq1+195


sqrCOL	;закрасить квадр. c HL цветом A
        if EGA
;TODO
        ret
        else
	PUSH DE
	LD DE,30
	LD (HL),A
	INC L
	LD (HL),A
	INC L
	LD (HL),A
	ADD HL,DE
	LD (HL),A
	INC L
	LD (HL),A
	INC L
	LD (HL),A
	ADD HL,DE
	LD (HL),A
	INC L
	LD (HL),A
	INC L
	LD (HL),A
	POP DE
	RET
        endif


outSQR	LD A,(F_FUNC) ;выв 6и квдр
	LD B,A
	LD DE,sqrADR
	XOR A
oQ0	PUSH AF
	CP B
	LD A,(MCOLOR) ;текущ действие?
	LD C,A
	JR NZ,oQ1
	INC C
	INC C
	LD A,(isCOLR) ;игра цветная?
	OR A
	JR NZ,oQ1
	RES 3,C
oQ1	LD A,(DE)
	INC DE
	LD L,A
	LD A,(DE)
	INC DE
	LD H,A
	LD A,(HL)
	CP C
	LD A,C
	CALL NZ,sqrCOL
	POP AF
	INC A
	CP 6
	JR C,oQ0
	LD A,(N_FUN1) ;нажатый квдр
	CP #FF
	JR Z,oQ5
	LD C,A
	LD HL,BUT_N
	CALL BA
	CP 77
	JR NC,oQ5
	LD A,C
	LD HL,sqrADR
	CALL WT
	LD A,(HL)
	OR %01111001
	CALL sqrCOL
oQ5	LD A,(SEL_T) ;квдр героя
	CP 7
	LD A,#38
	JR C,oQ2
	LD A,#39
	JR NZ,oQ2
	LD A,#3A
oQ2	LD HL,ATR+185
	CP (HL)
	RET Z
	JR sqrCOL

;----------------
mayBLT	;можно ли разместить здание? Z/NZ-да/нет;
	LD HL,(PX)
	CALL GMAP2
	LD A,(szPLAT)
	CP 1
	JP Z,aB001
	LD C,A
	LD B,A
	LD DE,64
aB0	PUSH HL
	PUSH BC
aB1	LD A,(HL)
	OR A
	JR NZ,aBN
	RES 4,H
	LD A,(HL)
	SET 4,H
	DEC A
	CP 7-1
	JR C,aB1a
	CP 17-1
	JR C,aBN
	CP 26-1
	JR NC,aBN
aB1a	INC L
	DJNZ aB1
	POP BC
	POP HL
	ADD HL,DE
	DEC C
	JR NZ,aB0
	LD HL,(PX)
	CALL GMAP
	LD A,(szPLAT)
	CP 2
	JR NZ,aBh3

      ;дом 2X2
	LD A,(MASTER)
	ADD A,7
	LD DE,-65
	ADD HL,DE
	CP (HL)
	RET Z
	INC L
	CP (HL)
	RET Z
	INC L
	CP (HL)
	RET Z
	INC L
	CP (HL)
	RET Z
	LD DE,61
	ADD HL,DE
	CP (HL)
	RET Z
	INC L
	INC L
	INC L
	CP (HL)
	RET Z
	ADD HL,DE
	CP (HL)
	RET Z
	INC L
	INC L
	INC L
	CP (HL)
	RET Z
	ADD HL,DE
	CP (HL)
	RET Z
	INC L
	CP (HL)
	RET Z
	INC L
	CP (HL)
	RET Z
	INC L
	CP (HL)
	RET
aBN	POP HL
	POP HL
	OR A ;nz
	RET

aBh3  ;дом 3Х3
	LD A,(MASTER)
	ADD A,7
	LD DE,-65
	ADD HL,DE
	LD B,5
aBhL0	CP (HL)
	RET Z
	INC L
	DJNZ aBhL0
	DEC L
	LD DE,60
	LD B,3
aBhL1	ADD HL,DE
	CP (HL)
	RET Z
	INC L
	INC L
	INC L
	INC L
	CP (HL)
	RET Z
	DJNZ aBhL1
	ADD HL,DE
	LD B,5
aBhL2	CP (HL)
	RET Z
	INC L
	DJNZ aBhL2
	DEC B
	RET NZ
aB001 ;1x1
	SET 4,H
	LD A,(HL)
	OR A
	RET NZ
	RES 4,H
	LD A,(HL)
	OR A
	JR Z,aBN1
	CP 26
	JR C,aBB1
	CP 51
	RET NZ
	LD A,(waPLAT)
	DEC A
	RET NZ
aBB1	LD A,(waPLAT)
	OR A
	JR NZ,aBwa
	;дорожка
	LD A,(MASTER)
	ADD A,7
	CP (HL)
	JR Z,aBN1
	DEC L
	CP (HL)
	RET Z
	INC L
	INC L
	CP (HL)
	RET Z
	LD DE,-65
	ADD HL,DE
	CP (HL)
	RET Z
	LD DE,128
	ADD HL,DE
	CP (HL)
	RET
aBwa	;стенка
maxWAL	EQU 4+1 ;макс расст до стенки+1
	 LD A,(HL)
	 CP 7
	 JR C,aBW0
	 CP 17
	 JR C,aBN1
aBW0	LD DE,(PX)
	LD HL,HBUILD
aBW1	LD A,(HL)
	OR A
	JR Z,aBW2
	SUB E
	JR NC,aBW3
	NEG
aBW3	CP maxWAL
	JR NC,aBW2
	INC L
	LD A,(HL)
	DEC L
	SUB D
	JR NC,aBW4
	NEG
aBW4	CP maxWAL
	JR NC,aBW2
	XOR A
	RET
aBW2	LD A,L
	ADD A,8
	LD L,A
	JR NZ,aBW1
aBN1	XOR A
	INC A
	RET


M_PLAT ;показать площадку под стр-во
	CALL ofPLAT
	LD A,(F_FUNC)
	CP #FF
	RET NC
	LD HL,BUT_N
	CALL BA
	CP 16
	RET C
	CP 18
	JR C,M_P1x1
	CP 26
	RET C
	CP 44
	RET NC
	LD C,2
	CP 34
	JR Z,M_Pxx
	CP 43
	JR Z,M_Pxx
	LD C,3
M_Pxx	LD A,C
	LD (szPLAT),A
	JR M_Pxz
M_P1x1	SUB 16
	LD (waPLAT),A
	LD A,1
	LD (szPLAT),A
M_Pxz	CALL mayBLT
	LD A,#10 ;саn't
	JR NZ,plt2
	LD A,(isCOLR)
	OR A
	LD A,#39
	JR Z,plt2
	LD A,(COLOR)
	XOR #8
plt2	EX AF,AF
	LD HL,(BX)
	LD A,L
	CP 24
	RET NC
	AND #FE
	LD L,A
	LD A,H
	AND #FE
	LD H,A
	LD A,(szPLAT)
	ADD A,A
	LD C,A
	LD B,A
	LD A,24
	SUB B
	SUB L
	JR NC,plt0
	ADD A,B
	LD B,A
plt0	LD A,24
	SUB C
	SUB H
	JR NC,plt1
	ADD A,C
	LD C,A
plt1	LD (bcPLAT),BC
	CALL STS
	CALL ACOORD
	LD (adPLAT),HL
	LD (isPLAT),A
	EX AF,AF
	JR PA0

ofPLAT	LD HL,isPLAT;cтереть площадку
	LD A,(HL)
	OR A
	RET Z
	XOR A
	LD (HL),A
	INC HL
	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	INC HL
	LD A,(HL)
	INC HL
	LD H,(HL)
	LD L,A
	LD A,(isCOLR)
	OR A
	LD A,#30
	JR Z,PA0a
	LD A,(COLOR)
PA0a	HALT ;??
PA0	LD E,A
PA1	PUSH BC
	PUSH HL
PA2	LD A,(HL)
	AND #40
	OR E
	LD (HL),A
	INC L
	DJNZ PA2
	POP HL
	LD BC,32
	ADD HL,BC
	POP BC
	DEC C
	JR NZ,PA1
	RET


;------------новый герой------

MANA	EQU #F0 ;-макс.знач. магич. маны
HEALTH	;нач.здоровье (+ [#100 * нач.магия])
	DEFW 50,50,50,60,70,#4000+60,#4000+50,200,120
	DEFW 50,50,50,60,70,#4000+60,#4000+50,200,120
	DEFW #E000+50,#D000+38,#E000+50,88,50,50,150,#E400+200,#E400+180


NEWHER	;A-0,1,2:чел/кунг/пл HL-поз;A'-тип
	;вых Z/NZ - O.K./нет места
	PUSH HL
	CALL sFREE
	POP HL
	RET NZ ;nz ->>
	CALL IX0_HL
	 LD (IX+14),L ;исходная позиц для охранников врага
	 LD (IX+15),H
	PUSH HL
	CALL GMAP2
	LD (HL),C
	EX AF,AF
	LD (IX+4),A
	LD C,A
	CALL RND
	AND 7
	LD (IX+2),A
	CALL IX_98
	LD (IX+3),A
	LD (IX+7),A
	LD HL,HEALTH
	LD A,C
	CALL WT
	LD (IX+5),L
	LD (IX+6),H
	LD A,C
	LD HL,AT_TY_
	CALL BA
	POP HL
NEWiy_	PUSH HL ;вх A=0/1 -2x2/3x3
	CP 1
	JR Z,nH1
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD (IY+0),L
	LD (IY+1),H
	POP AF
	INC A
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	DEC HL
	DEC HL
	DEC HL
	LD (IY+2),L
	LD (IY+3),H
	XOR A
	RET ;z ->>
nH1	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	DEC HL
	DEC HL
	DEC HL
	DEC HL
	LD (IY+0),L
	LD (IY+1),H
	POP AF
	INC A
	ADD A,A
	ADD A,A
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	INC HL
	INC HL
	INC HL
	LD (IY+2),L
	LD (IY+3),H
	XOR A
	RET ;z ->>

CLRALL	LD HL,HUMAN
	LD DE,HUMAN+1
	LD BC,2047
	LD (HL),0
	LDIR
	RET

sFREE	;поиск св.места и уст IX/IY (Вх:A-чей)
	; (вых z/nz - ok/нет места, C - номер+#80)
	CP 1
	LD HL,HUMAN
	LD BC,#3000
	LD DE,16
	JR C,sF1
	LD HL,KUNGE
	LD C,#30
	JR Z,sF1
	LD HL,SLAVE
	LD BC,#660
sF1	INC L;	(ix+1)==0
	PUSH BC
	PUSH HL
	CALL sF10
	LD A,C
	POP HL
	POP BC
	JR Z,sF2
	DEC L ; (ix)==0
	CALL sF10
	LD A,C
	RET NZ ;nz->нет места
sF2	LD C,A
	SET 7,C
	CALL N_IXIY
	XOR A
	RET ;z->выделено место (ix,iy)
	;
sF10	LD A,(HL) ;z-ok
	OR A
	RET Z
	INC C
	ADD HL,DE
	DJNZ sF10
	RET ;nz

stayON	;поиск места, чтобы поставить героя (hl)
	LD C,3
sY00	CALL stay1
	DEC H
	DEC L
	LD B,C
sYupL	CALL stay1
	INC L
	DJNZ sYupL
	DEC L
	INC H
	LD B,C
	DEC B
	DEC B
sYrtL	CALL stay1
	INC H
	DJNZ sYrtL
	LD B,C
sYdwL	CALL stay1
	DEC L
	DJNZ sYdwL
	INC L
	DEC H
	LD B,C
	DEC B
	DEC B
sYlfL	CALL stay1
	DEC H
	DJNZ sYlfL
	INC C
	INC C
	JR sY00

stay1	;пров позиции; вых POP AF!!
	LD A,L
	CP 63
	RET NC
	LD A,H
	CP 63
	RET NC
	PUSH HL
	CALL GMAP2
	LD A,(HL)
	POP HL
	OR A
	RET NZ
	POP AF ;!
	RET

CORiy_	;коррекция коорд (E+iy(0,1); D+iy(2,3))
	PUSH IY
	POP HL
cii_	CALL cii0
	INC HL
	LD E,D
cii0	LD A,(HL)
	ADD A,E
	LD (HL),A
	INC HL
	EX AF,AF
	LD A,E
	RLCA
	JR C,cii1
	EX AF,AF
	RET NC
	INC (HL)
	RET
cii1	EX AF,AF
	LD A,(HL)
	ADC A,#FF
	LD (HL),A
	RET

;--------------------

colorL	;цвета индикаторов
	DEFB #58,#60,#70,#28,#60,#50

outLED	;подсветка 6-и индикаторов
	;+0-атакует враг
	;+1-здание построено
	;+2-здание/шахта разрушены
	;+3-атакуем мы
	;+4-появился новый человек
	;+5-наше здание горит
       if EGA
;TODO!!!
       else
	LD HL,colorL
	EXX
	LD HL,LED
	LD DE,ATR+664
	PUSH DE
	CALL oLL_
	LD DE,ATR+728
	PUSH DE
	CALL oLL_
	POP HL
	LD DE,ATR+760
	LD C,6
	LDIR
	POP HL
	LD DE,ATR+696
	LD C,6
	LDIR
	RET
	;
oLL_	LD B,3
oLL0	LD A,(HL)
	OR A
	JR Z,oLL2
	DEC (HL)
	AND 1
	JR Z,oLL2
	EXX
	LD A,(HL)
	EXX
	JR oLL1
oLL2	LD A,#8
oLL1	INC HL
	LD (DE),A
	INC E
	LD (DE),A
	INC E
	EXX
	INC HL
	EXX
	DJNZ oLL0
	RET
       endif

;--[**]----супер энергия ;отключить на время - войти в режим карты
HiENER	LD C,32
	LD A,(MORTE)
	CP 86
	RET NZ
	CALL Z,loop_H
hie0	LD (IX+5),C
	ADD IX,DE
	DJNZ hie0
	RET
