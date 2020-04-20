;cтраница 7
TMOM	LD A,(CONTRB)
	AND %10000
	RET Z
	JR NZ,TMOM

;----работа с меню
bSETUP	;нач
	XOR A
	LD (_S_CFt),A
	LD HL,TXC2-1
	LD (_S_CFx),HL
	;
	LD HL,KEYJOY
	PUSH HL
	LD DE,S_kj
	LD BC,12
	LDIR
	LD HL,S_gSPD
	LD A,18
	SUB (HL)
	LD (HL),A
	DEC HL
	DEC (HL)
	LD HL,0
	LD (S_kb),HL
	POP HL
	LD A,(HL)
	OR A
	RET NZ
	LD HL,(KEYS)
	LD DE,KBR
	SBC HL,DE
	LD HL,S_kb
	JR Z,bSE1
	INC HL
bSE1	INC (HL)
	RET

SETUP	 CALL bSETUP ;вх.уст
	 CALL TMOM
	 CALL oSETUP
	 JP eSETUP

oSETUP	;блок настроек
	CALL STD ;????
        if EGA
;выключить стрелочку 
;стереть стрелочку
	LD A,2
	LD (V_FLAG),A
	CALL V_PUT1
        endif        
	LD HL,setuTB
	LD B,6
sup1	PUSH BC
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD C,(HL)
	INC HL
	LD B,(HL)
	INC HL
	INC HL
	CALL MU_BOX
	POP BC
	DJNZ sup1
	;выв текстов
	LD DE,#102
	LD HL,TXC1
	CALL PRINTS
	LD DE,#402
	LD HL,TXM2
	CALL PRINTS
	LD DE,#502
	LD HL,TXM3
	CALL PRINTS
	LD DE,#602
	LD HL,TXM4
	CALL PRINTS
	LD DE,#903
	LD HL,TXM5
	CALL PRINTS
	LD DE,#C02
	LD HL,TX_MUS
	CALL PRINTS
	LD DE,#D02
	LD HL,TX_EFF
	CALL PRINTS
	LD DE,#E02
	LD HL,TXcolr
	CALL PRINTS
	LD DE,#F02
	LD HL,TXdisc
	CALL PRINTS
	LD DE,#1202
	LD HL,TXM9
	CALL PRINTS
	LD DE,#1502
	LD HL,TXM10
	CALL PRINTS
	;раскрас
	LD HL,setuTB
	CALL STS
	LD B,6
sup2	PUSH BC
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD B,(HL)
	INC HL
	LD C,(HL)
	INC HL
	LD A,(HL)
	INC HL
	PUSH HL
	EX DE,HL
	LD E,A
	CALL ATRBAR
	POP HL
	POP BC
	DJNZ sup2
        if EGA
;прочитать стрелочку
;включить стрелочку
	CALL V_GET1
	xor a
	LD (V_FLAG),A
        else
	LD HL,#2828
	LD (ATR+532),HL
	LD (ATR+564),HL
	LD HL,#3939
	LD (ATR+468),HL
	LD (ATR+436),HL
        endif
Setup0
        if EGA==0
	CALL BLITE2 ;иначе мигает
        endif
	CALL oSETpr

        if EGA
	LD A,2
	LD (V_FLAG),A ;cursor off
	CALL V_PUT1 ;visible screen
        endif
        
	CALL Copper
        
        if EGA
	CALL V_GET1
        call V_MRK1 ;на видимом экране (в это время G_MX не обновляется, т.к. стрелочка выключена)
	xor a
	LD (V_FLAG),A ;cursor on
        endif
        
	CALL BMOV
	CALL fSzone
	HALT ;YIELD никогда не попадёт в наш перехваченный обработчик прерываний
	JR Setup0

BLITE2	CALL BLITER ;копируем на экран, рисуем курсор
	JP V_PUT2 ;стираем курсор

TXM2	DEFB 22,59,48,50,56,48,66,67,64,48, 10, 32,12,26,28,24, 127
TXM3	DEFB 20,61,66,53,64,68,53,57,65, 10, 02, 127
TXM4	DEFB 22,53,60,63,65,66,62,61, 10, 52,54,62,57,65,66,56,58, 127
TXM5	DEFB 22,53,60,63,65,66,62,61, 10, 60,75,72,58,48, 127
TX_MUS	DEFB 12,86,10,24,67,55,75,58,48, 127
TX_EFF	DEFB 12,86,10,40,68,68,53,58,66,75, 127
TXcolr	DEFB 34,50,53,66,61,48,79,10,56,51,64,48, 127
TXdisc	DEFB 26,66,51,64,67,55,58,56,10,61,48,10,87,12,88, 127
TXM9	DEFB 24,84,81,10,10, 22,67,64,65,62,64,10,10, 24,12,33,127
TXM10	DEFB 24,84,81,10, 29,58,62,64,62,65,66,74,10
	DEFB 56,51,64,75,10, 24,12,33,127


;врем парм - порядок неизm
S_kb	DEFB 1
S_in2	DEFB 0
S_kj	DEFB 0

S_km	DEFB 0 ;начальное значение не влияет? см. PMOUSE
S_ayM	DEFB 1
S_ayE	DEFB 0
S_colr	DEFB 1
S_disk	DEFB 0
S_cSPD	DEFB 4
S_gSPD	DEFB 16
S_ani	DEFB 1
S_vis	DEFB 0
S_gsML	DEFB 15 ;unus
S_gsEL	DEFB 2 ;

_S_cnt	DEFB 1
_S_cn_	DEFB 1
_S_CFx	DEFW 0
_S_CFt	DEFB 0
_S_CFc	DEFB 0

_oSlet	LD A,12
	JR _oSpx1
	;
_oSpx	LD A,96
_oSpx1	ADD A,(HL)
	INC HL
	CALL PRINT
	INC D
	DEC E
	RET

oSETpr	;выв парм. сетупа
	CALL STD
	LD DE,#414
	LD HL,S_kb
	LD B,3
oSP1	CALL _oSpx
	DJNZ oSP1
	LD DE,#912
	CALL _oSpx
	LD B,3
	LD DE,#C0F
oSP2	CALL _oSpx
	DJNZ oSP2
	CALL _oSlet
	LD DE,#1302
	LD B,14
	CALL _oSlin
	LD DE,#1602
	LD B,19
	CALL _oSlin
	LD A,(S_ani)
	OR A
	LD A,113
	JR NZ,oSP3
	LD A,56
oSP3	LD DE,#B014
	CALL _oSani
	CALL ANIMTR
	LD A,(S_vis)
	CALL _shdw
	LD A,49
	LD DE,#A8B4
	JP _oSani

_oSlin	;выв рулера (B-длина)
	LD A,92
	CALL PRINT
_oSl1	LD A,93
	CALL PRINT
	DJNZ _oSl1
	LD A,95
	CALL PRINT
	LD A,(HL)
	INC HL
	ADD A,3
	LD E,A
	LD A,94
	JP PRINT

SzoneT	;X,widhtX, Y,widhtY
	DEFB 2,20, 4,3
	DEFB 3,16, 9,1
	DEFB 2,15, 12,4
	DEFB 3,14, 18,3
	DEFB 3,19, 21,3
	DEFB 19,4, 12,3
	DEFB 19,4, 16,3
	DEFB 24,8, 0,24


SFU5	LD HL,S_vis;темнота
	JR SFU_

SFU6	LD HL,S_ani
	JR SFU_

SFU0	LD HL,S_kb ;тип упр
	PUSH HL
	LD (HL),0
	INC HL
	LD (HL),0
	INC HL
	LD (HL),0
	POP HL
	CALL BA
	INC (HL)
	RET

SFU1	LD HL,S_km;мыша
SFU_	LD A,(_S_cnt)
	OR A
	RET NZ
	LD A,(HL)
	XOR 1
	LD (HL),A
	RET

SFU2	EX AF,AF
	LD A,(_S_cnt)
	OR A
	RET NZ
	EX AF,AF
	LD HL,S_ayM ;тип муз
	CALL BA
	XOR 1
	LD (HL),A
	RET

SFU3	LD A,(BX)
	SUB 3
	LD (S_cSPD),A
	RET

SFU4	LD A,(BX)
	SUB 3
	LD (S_gSPD),A
	RET

SFU7	;return
	LD A,(_S_cnt)
	OR A
	RET NZ
	POP AF;!
	RET

SzoneF	DEFW SFU0,SFU1,SFU2,SFU3,SFU4,SFU5,SFU6,SFU7
fSzone	;ф-ции по зонам
	LD HL,_S_cn_
	LD A,(HL)
	LD (_S_cnt),A
	LD A,(CONTRB)
	LD (HL),A
	AND %10000
	RET Z
fS4	LD B,0
	LD HL,SzoneT
fS0	PUSH HL
	CALL _fSzs
	POP HL
	JR C,fS1
	INC HL
	INC HL
	INC HL
	INC HL
	INC B
	LD A,B
	CP 8; макс число зон
	JR C,fS0
	RET NC
fS1	PUSH AF
	LD A,B
	LD HL,SzoneF
	CALL WT
	POP AF
	JP (HL)

_fSzs	LD DE,(BX)
	LD A,E
	SUB (HL)
	INC HL
	CP (HL)
	RET NC
	LD A,D
	INC HL
	SUB (HL)
	INC HL
	CP (HL)
	RET

TXC1	DEFB 10,10,10,10,35,80,64,61,75,57, 10
	DEFB 14,62,64,62,61, 10,10,10,10,127
TXC2	DEFB 12,50,66,62,64, 10
	DEFB 14,45,29,45,24,53,52,61,62,61,62,51,62,50, 127
TXC3	DEFB 29,26,28,28,17,82,10,85,17,17,30,10,10,87,65,88,1,9,9,7,127
TXC4	DEFB 10,10,10, 29,48,61,58,66,91,27,53,66,53,64,49,67,64,51
	DEFB 10,10,10, 127, 126

        if 1==0
;-----pM

tst60a	PUSH DE ;[**] на вх. =#C9
	PUSH AF
tst60	ADD A,(HL) ;[**]
	INC HL
	DEC C
	JR NZ,tst60
	DEC B
	JR NZ,tst60
	LD HL,#DB00
	CP (HL)
	RET NZ;err
	POP AF
	POP HL
	LD (tst60a),HL
	RET
        endif

Copper	LD HL,(_S_CFx)
	LD A,(HL)
	CP 127
	JR NZ,Cop1
	LD HL,_S_CFt
	INC (HL)
	LD A,(HL)
	CP 60
	RET C
	LD A,2
	LD (_S_CFc),A
	LD (_S_CFt),A
	LD HL,(_S_CFx)
	INC HL
	LD A,(HL)
	CP 126
	JR NZ,Cop2
	LD HL,TXC1
Cop2	LD (_S_CFx),HL
	RET
Cop1	LD HL,_S_CFc
	LD E,(HL)
	INC (HL)
	LD D,1
	LD HL,(_S_CFx)
	LD A,(HL)
	INC HL
	LD (_S_CFx),HL
	CALL PRINT
	RET

eSETUP	;out menu
	LD HL,S_kj
	PUSH HL
	LD DE,KEYJOY
	LD BC,12
	LDIR
	LD HL,SLOW
	LD A,18
	SUB (HL)
	LD (HL),A
	DEC HL
	INC (HL)
	POP HL
	LD A,(HL)
	OR A
	RET NZ
	DEC HL
	LD A,(HL)
	OR A
	LD HL,KBR
	JR Z,eSE1
	LD HL,INT2
eSE1	LD (KEYS),HL
	RET



TXMM1	DEFB 31,65,66,48,61,62,50,56,66,74,10, 62,63,70,56,56,127
TXMM2	DEFB 10,29,62,69,64,48,61,56,66,74, 10, 56,51,64,67,127
TXMM3	DEFB 17,73,80,10, 62,52,61,48,10, 63,62,63,75,66,58,48,127
TXMM4	DEFB 10,19,48,58,62,61,71,56,66,74,10, 56,51,64,67,127

M_MENU	;>>главное меню
	LD A,2
	LD (V_FLAG),A
	CALL STS
	;пункты
	LD B,4
	LD HL,#403
M_M1	PUSH BC
	PUSH HL
	LD BC,#312
	LD E,#7A
	CALL ATRBAR
	LD BC,#1203
	POP DE
	PUSH DE
	CALL MU_BOX
	POP HL
	INC H
	INC H
	INC H
	INC H
	POP BC
	DJNZ M_M1
	LD HL,TXMM1
	LD DE,#504
	LD B,4
M_M2	PUSH DE
	CALL PRINTS
	INC HL
	POP DE
	INC D
	INC D
	INC D
	INC D
	DJNZ M_M2
	XOR A
	LD (V_FLAG),A
	;опрос гл.меню
	CALL TMOM
M_M3	CALL Mfunc
	LD B,4
	LD HL,#1003
M_M30	LD A,D
	INC A
	CP B
	LD E,#7A
	JR NZ,M_M31
	LD E,#71
M_M31	PUSHs
	LD BC,#312
	CALL ATRBAR
	POPs
	DEC H
	DEC H
	DEC H
	DEC H
	DJNZ M_M30
	HALT
	LD A,(CONTRB)
	AND %10000
	JR Z,M_M3
	;по ф-циям
	LD A,D
	CP #FF
	RET Z
	OR A
	JP Z,SETUP ;-в уст
	CP 2
	JP C,M_M9
	PUSH AF
	;exit menu
	LD A,2
	LD (V_FLAG),A
	CALL V_PUT1
	LD HL,TXMMex
	LD DE,#1104
	POP AF
	PUSH AF
	JR NZ,M_M5
	LD HL,TXMrst
	LD D,#D
M_M5	CALL PRINTS
	CALL YES_NO
	JR Z,M_M6
	POP AF ;No
	RET
M_M6	POP AF
	JP Z,LODrtr
	;exit
        
        if 1==1
;NedoOS
        call swapimer
        im 1
        call shutay ;outSND уже затёрт?
        ei
        QUIT
shutay
	ld de,0xe00
shutay0
	dec d
	ld bc,0xfffd
	out (c),d
	ld b,0xbf
	out (c),e
	jr nz,shutay0
	ret

        else
        
	DI
	LD HL,#4000
	LD DE,#4001
	LD (HL),4
	LD B,#20
	LDIR
	XOR A
	LD BC,#7FFD
	JP M_Mexi
        endif

YES_NO	LD BC,#DFFE  ;Z-Yes/NZ-No
	IN A,(C)
	AND #10
	RET Z
	LD B,#7F
	IN A,(C)
	CPL
	AND 8
	RET NZ
	JR YES_NO

Mfunc	CALL BMOV ;(D:=#FF,0-3)
	LD D,#FF
	LD A,(BX)
	CP 3
	RET C
	CP 21
	RET NC
	LD A,(BY)
	SUB 4
	RET C
	CP 16
	RET NC
	LD E,A
	AND 3
	CP 3
	RET Z
	LD D,E
	SRL D
	SRL D
	RET

TXMMex	DEFB 27,64,62,73,48,53,60,65,79,10,87,86,90,81,88,44,127
TXMrst	DEFB 10,28,53,65,66,48,64,66,10,87,86,90,81,88,44,10,127
TXMsav	DEFB 61,48,10,52,56,65,58,10,00,43,87,86,90,81,88,44,127 ;на диск Х

M_M9	;меню save
	INC A
	LD (V_FLAG),A
	CALL V_PUT2
	LD HL,#606
	PUSH HL
	LD BC,#C0C
	PUSH BC
	LD E,#4
	CALL ATRBAR
	POP BC
	POP DE
	CALL MU_BOX
	LD B,8
	LD DE,#F08
	LD HL,TXMgme
M_M90	PUSHs
	LD A,B
	LD (TXMgme+7),A
	CALL PRINTS
	POPs
	DEC D
	DJNZ M_M90
	CALL V_GET1
	XOR A
	LD (V_FLAG),A
	CALL TMOM
M_M91	HALT
	CALL BMOV
	LD D,#FF
	LD HL,(BX)
	LD A,L
	SUB 6
	CP 12
	JR NC,M_M92
	LD A,H
	SUB 8
	CP 8
	JR NC,M_M92
	LD D,A
M_M92	LD B,8
	LD HL,#F06
M_M94	PUSHs
	LD A,D
	INC A
	CP B
	LD E,#4
	JR NZ,M_M93
	LD E,#4F
M_M93	LD BC,#10C
	CALL ATRBAR
	POPs
	DEC H
	DJNZ M_M94
	LD A,(CONTRB)
	AND %10000
	JR Z,M_M91
	CALL TMOM
	LD A,D
	CP #FF
	RET Z
	PUSH AF
	LD A,2
	LD (V_FLAG),A
	CALL V_PUT1
	LD BC,#0414
	LD HL,#1102
	LD E,#57
	PUSH HL
	CALL ATRBAR
	POP DE
	LD BC,#1404
	CALL MU_BOX
	LD HL,TXMM2
	LD DE,#1204
	CALL PRINTS
	LD A,(SAVDSK)
	ADD A,12
	LD (TXMsav+8),A
	LD DE,#1304
	LD HL,TXMsav
	CALL PRINTS
	CALL YES_NO
	POP BC
	RET NZ
	LD A,B
	JP SAVgam

;----окончание
MU_END	;A=1/2 -победа/поражение
	PUSH AF
	CALL STS
	LD A,2
	LD (V_FLAG),A
	CALL V_PUT1
	POP AF
	DEC A
	JR NZ,meMIS
	;победа
	LD DE,#701
	PUSH DE
	LD BC,#160C
	CALL MU_BOX
	POP HL
	LD BC,#0C16
	LD E,%01001110
	CALL ATRBAR
	LD DE,#909
	LD HL,Evic1
	CALL PRINTS
	LD DE,#A03
	LD HL,Evic2
	CALL PRINTS
	LD DE,#C05
	CALL TUtime
	LD DE,#1004
	LD HL,TXMM2
	CALL PRINTS
	LD DE,#1109
	LD HL,Ey_n
	CALL PRINTS
	ATRs #1005,#20E,%01011110
	CALL YES_NO
	CALL Z,M_M9
	JP LODnxt
meMIS	;поражение
	LD DE,#802
	PUSH DE
	LD BC,#140A
	CALL MU_BOX
	POP HL
	LD BC,#A14
	LD E,%01111010
	CALL ATRBAR
	LD DE,#A06
	LD HL,Emis1
	CALL PRINTS
	LD DE,#C07
	LD HL,Emis2
	CALL PRINTS
	LD DE,#F05
	PUSH DE
	LD HL,Emis3
	CALL PRINTS
	POP HL
	LD BC,#10F
	LD E,%01101010
	CALL ATRBAR
	CALL bWAIT
	CALL TMOM
	JP LODrtr

setuTB	DEFW #0000,#1807
	DEFB #31
	DEFW #0B01,#170D
	DEFB #4E
	DEFW #0800,#1509
	DEFB #69
	DEFW #0301,#1507
	DEFB #7A
	DEFW #0802,#1203
	DEFB #7B
	DEFW #0C13,#0407
	DEFB #60

;----- п/п вывода панели

oMN_WD	;вывод денег/леcа
	LD HL,(MONEY1)
	LD A,L
	OR H
	JR NZ,oMN1WD
	LD HL,(WOOD1)
	LD A,L
	OR H
	JR NZ,oMN1WD
	LD HL,ATR+57
	EXX
	LD DE,#119
	LD HL,MONEY
	CALL outmw
	LD HL,ATR+121
	EXX
	LD DE,#319
	LD HL,WOOD
outmw	LD C,0
om0	LD A,(HL)
	INC HL
	OR A
	JR NZ,om2
	CP C
	JR NZ,om2
	LD A,11
	LD B,#50
	JR om1
om2	INC C
	LD B,#68
om1	CALL MONEYPRINT
        if EGA==0
	LD A,B
	EXX
	LD (HL),A
	INC HL
	EXX
        endif
	LD A,E
	CP #1E
	JR C,om0
	RET NZ
	LD A,(HL)
	JR om2

oMN1WD	LD HL,ATR+57 ;альт.вывод
	EXX
	LD DE,#119
	LD HL,MONEY1+1
	CALL out1mw
	LD HL,ATR+121
	EXX
	LD DE,#319
	LD HL,WOOD1+1
out1mw	LD C,0
	LD A,11
	CALL MONEYPRINT
	LD A,11
	CALL MONEYPRINT
        if EGA==0
	EXX
	LD (HL),#50
	INC HL
	LD (HL),#50
	INC HL
	EXX
        endif
o1m8	CALL o1m0
o1m0	LD A,(HL)
	RLCA
	RLCA
	RLCA
	RLCA
	CALL o1m7
	LD A,(HL)
	LD (HL),0
	DEC HL
o1m7	AND #F
	OR A
	JR NZ,o1m2
	CP C
	JR NZ,o1m2
	LD A,E
	CP #1E
	LD A,0
	JR NC,o1m2
	LD A,11
	LD B,#50
	JR o1m1
o1m2	INC C
	LD B,#58
o1m1	CALL MONEYPRINT
        if EGA==0
	LD A,B
	EXX
	LD (HL),A
	INC HL
	EXX
        endif
	RET

TX48x7	
;выв.назв.героя
        if EGA
        ld a,24;29
        call _128
	LD A,2
	LD (V_FLAG),A ;выключить стрелочку
	CALL V_PUT1 ;на видимом экране
        LD de,(TX_AD) ;выв.назв.героя (переменная в 8000+!)
        call setpgsscr40008000_current
        call TX48x7doscr ;на выходе должна поставить pgmain
	CALL V_GET1
        call V_MRK1 ;на видимом экране (в это время G_MX не обновляется, т.к. стрелочка выключена)
	xor a
	LD (V_FLAG),A ;включить стрелочку
	CALL V_PUT2 ;на рисуемом экране
        LD de,(TX_AD) ;выв.назв.героя (переменная в 8000+!)
        call setpgsscr40008000 ;на рисуемом экране
        call TX48x7doscr ;на выходе должна поставить pgmain
	jp V_GET_MRK2 ;на рисуемом экране
TX48x7doscr
        ld hl,scrbase+(65*40)+25
        ld bc,0x0718
        jp primgega_pixsz
        else ;~EGA
        LD HL,(TX_AD) ;выв.назв.героя
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD (SET_SP+1),SP
	LD SP,HL
	LD HL,SCR+#900+25
	LD B,3
T4S0	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	LD H,SCR/256+9
	INC L
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	INC H
	POP DE
	LD (HL),E
	INC H
	LD (HL),D
	POP DE
	LD H,SCR/256+9
	INC L
	DJNZ T4S0
	JP SET_SP
        endif

OUTBAR	;общий вывод панели
;TODO выводить это всё на двух экранах и обвязать стиранием стрелочки
	CALL STS
;;	LD HL,WFONT
;;	LD (FONT),HL
	CALL oMN_WD
	CALL outTX
	CALL oINDY
        if EGA
	CALL oBUT ;TODO не перерисовывать кнопки, если они не изменились
	CALL outSQR
        else
	CALL outSQR
	CALL oBUT
        endif
	CALL outNUM
	JP outLED

	;ds #FFFE-$
        ;nop ;CHK_7	DEFB #EE; [**B] чек-сум7 7:#FFFE
        ;ds 1
