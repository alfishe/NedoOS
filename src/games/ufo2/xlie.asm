MXDM	DEFM	"////////////////////////" ;табл.альтернатив

ZT	DEFW	Z0,Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9,ZA,ZB,ZC,ZD,ZE,ZT
MBU2	EQU	#DB00;(1024B-128)		;
MBU	EQU	#DE80;(48B/128)			;Pg7
ScrBU	EQU	#DF00;(1728B/1792)		;
SwpMEM	EQU	#E600;(6656B)			;
SwpADR	EQU	#7580 ;swap-адр

MBEG	DEFB 1      ;у-1я стр. меню
MEND	DEFB 22     ;у-последняя
MOLD	DEFB 255    ;у-текущая предыдущая
MTMP	DEFB 255    ;у-текущая
MPOS	DEFB 0	    ;пункт меню [0..MEND-MBEG]
MXSH	DEFB 1      ;x-отступ
MLEN	DEFB 2      ;ширина пункта меню
MC21	DEFB 1	    ;0-восстановить строки 21-23
TXM	DEFW 0      ;текст меню
MCOLOR	DEFB 0	    ;цвет

;команды: 0-набор WORDS, 1/2-высота 1/2, 3/4-центрир.фраза/слово(N),
; 5-ВК/ПС, 6/7-нецентрир.фраза/слово(N),8/9/<?>-вывод byte,word,double,
; <->/<.>/<,>-меню по усл."равно"/"неравно"/без условия
; <:>-набор NAMES

MENU	PUSH	IX
	CALL 	STD
	LD	HL,MTXTM
	LD	(MTXT+1),HL
	LD	HL,MTX0M
	LD	(MTX0+1),HL
	LD	HL,#FFFF
	LD	(MOLD),HL
	LD	(MBEG),HL
	LD	L,(IX)
	INC	L
	INC	IX
	LD	H,(IX)
	LD	(SX),HL
	INC	IX
	LD	A,(IX)
	LD	(MLEN),A
	INC	IX
	LD A,(C_ONOF)
	OR A
	LD A,#38
	JR NZ,Coff
	LD	A,(IX)
	LD	HL,DMCOL
	CALL	BT
Coff	LD	(MCOLOR),A
	XOR	A
	LD	(HIGH),A
	LD	A,(SX)
	LD	(MXSH),A

	Ms	1
	LD	HL,MENUS
	LD	A,(IX)
	INC	IX
	OR	A
	JR	Z,JF
	LD	B,A
JH	LD	A,(HL)
	INC	HL
	CP	#7F
	JR	NZ,JH
	DJNZ	JH
JF	LD	(TXM),HL
	CALL	MTOP
	CALL	MTXT
	LD	HL,WORDS
	LD	(_words),HL
	XOR	A
	LD	(HIGH),A
	POP	IX
	JR	MBOT

BLNK	PUSHs;$
	LD	DE,(SX)
	LD	A,(MXSH)
	LD	E,A
	INC	D
	LD	(SX),DE
	DEC	E
	LD	BC,FONT
	LD	L,104
	LD	A,1
	CALL	SYMBOL
	LD	A,(MLEN)
	LD	L,15
	CALL	SYMBOL
	LD	A,1
	LD	L,111
	CALL	SYMBOL
	CALL	MPAI
	POPs;$
	RET

MTOP	LD	DE,(SX)
	DEC	E
	LD	BC,FONT
	LD	A,1
	LD	L,106
	CALL	SYMBOL
	LD	A,(MLEN)
	LD	L,105
	CALL	SYMBOL
	LD	A,1
	LD	L,107
	CALL	SYMBOL
	JR	MPAI

MBOT	LD	DE,(SX)
	DEC	E
	LD	BC,FONT
	LD	A,1
	LD	L,108
	CALL	SYMBOL
	LD	A,(MLEN)
	LD	L,110
	CALL	SYMBOL
	LD	A,1
	LD	L,109
	CALL	SYMBOL

MPAI	LD	HL,(SX)
	DEC	L
	LD	BC,(MLEN-1)
	INC	B
	INC	B
	LD	C,1
	LD	A,(MCOLOR)
	JP	ATRBAR

MTXTM	CALL	BLNK
	LD	HL,(TXM)
	LD	A,(HL)
	OR	#80
	INC	A
	RET	Z
	CALL	BLNK
	LD	HL,SY
	DEC	(HL)
MTX0M	LD	HL,(TXM)
	LD	A,(HL)
	INC	HL
	LD	(TXM),HL
	LD	HL,ZT
	CALL	WT
	JP	(HL)

MTX0	JP	MTX0M
MTXT	JP	MTXTM

Z0	LD	HL,WORDS
Z0E	LD	(_words),HL
	JR	MTX0
ZE	LD	HL,NAMES
	JR	Z0E
Z1	XOR	A
	JR 	Z2_1
Z2	LD	A,#1
Z2_1	LD	(HIGH),A
	JR	MTX0
Z5	LD	A,(HIGH)
	OR	A
	JR	Z,MTXT
	LD	HL,SY
	INC	(HL)
	JR	MTXT
Z6	LD	HL,(TXM)
	CALL	WORDHL
	LD	HL,(TXT)
	LD	(TXM),HL
	JP	MTX0
Z7	LD	A,(IX)
	INC	IX
	CALL	NWRD
	JP	MTX0
Z8	LD	L,(IX)
	LD	H,(IX+1)
	INC	IX
	INC	IX
	CALL	WBHL
	JP	MTX0
Z9	LD	L,(IX)
	LD	H,(IX+1)
	INC	IX
	INC	IX
	CALL	WW
	JP	MTX0
ZA	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	CALL	WD
	JP	MTX0

Z3	LD	HL,(TXM)
	LD	(TXT),HL
	LD	B,-1
Z33	LD	A,(HL)
	INC	HL
	INC	B
	CP	128
	JR	C,Z333
	INC 	B
Z333	CP	126
	JR	NZ,Z33
	LD	(TXM),HL
	LD	A,(MLEN)
	SUB	B
	SRL	A
	LD	DE,(SX)
	ADD	A,E
	LD	E,A
	LD	(SX),DE
	CALL	WORD
	JP	Z5

Z46	LD	A,(HL)
	INC	HL
	CP	126
	JR	NZ,Z46
	DJNZ	Z46
	LD	(TXT),HL
	LD	B,-1
Z47	LD	A,(HL)
	INC	HL
	INC	B
	CP	128
	JR	C,Z48
	INC	B
Z48	CP	126
	JR	NZ,Z47
	LD	A,(MLEN)
	SUB	B
	SRL	A
	LD	DE,(SX)
	ADD	A,E
	LD	E,A
	LD	(SX),DE
	JP	WORD

Z4	LD	HL,(_words)
	LD	B,(IX)
	INC	IX
	CALL	Z46
	JP	Z5

ZD	XOR	A
	LD	(HIGH),A
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	LD	B,(IX)
	INC	IX
	LD	DE,MXDM
	LD	A,(SY)
	LD	(MBEG),A
	LD	C,0
Z_3	PUSHs;$
	LD	B,(HL)
	LD	HL,(_words)
	CALL	Z46
	POPs;$
	INC	HL
	LD	A,(SY)
	LD	(MEND),A
	CALL	BLNK
	LD	A,C
	LD	(DE),A
	INC	C
	INC	DE
	DJNZ	Z_3
	JP	MTXT

ZB	LD	A,#20;jr nz
	LD	(Z_E),A
	JR	Z11
ZC	LD	A,#28;jr z
	LD	(Z_E),A
Z11	XOR	A
	LD	(HIGH),A
	LD	DE,MXDM
	LD	C,0
	LD	A,(SY)
	LD	(MBEG),A
	DEC	A
	LD	(MEND),A
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	LD	B,(IX)
	INC	IX
	EXX
	LD	B,(IX)
	INC	IX
	LD	L,(IX)
	INC	IX
	LD	H,(IX)
	INC	IX
	EXX
Z_1	EXX
	LD	A,(HL)
	INC	HL
	CP	B
	EXX
Z_E	JR	NZ,Z_7
	PUSHs;$
	LD	B,(HL)
	LD	HL,(_words)
	CALL	Z46
	POPs;$
	LD	A,(SY)
	LD	(MEND),A
	CALL	BLNK
	LD	A,C
	LD	(DE),A
	INC	DE
Z_7	INC	C
	INC	HL
	DJNZ	Z_1
	JP	MTXT

;------------------------
SWAP_X	LD	A,(HL) ;Обмен по XOR
	XOR	#C6
	EX	AF,AF
	LD	A,(DE)
	XOR	#C6
	EX	AF,AF
	LD	(DE),A
	EX	AF,AF
	LD	(HL),A
	INC	HL
	INC	DE
	DEC	BC
	LD	A,C
	OR	B
	JR	NZ,SWAP_X
	RET	Z

DECM	LD	IX,MONEY
DECR	EX	DE,HL
	LD	L,(IX)
	LD	H,(IX+1)
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	EXX
	CALL	SUBDW
	RET	C
IM3	LD	(IX),L
	LD	(IX+1),H
	EXX
	LD	(IX+2),L
	LD	(IX+3),H
	EXX
	RET

INCM	LD	IX,MONEY
INCR	EX	DE,HL
	LD	L,(IX)
	LD	H,(IX+1)
	EXX
	LD	L,(IX+2)
	LD	H,(IX+3)
	EXX
	CALL	ADDDW
	JR	NC,IM3
	LD	HL,#FFFE
	EXX
	LD	HL,#0FFF  ;до268млн
	EXX
	JR	IM3

DD	RLCA
WA	RLCA
BA	ADD	A,L
	LD	L,A
	JR	NC,BA_
	INC	H
BA_	LD	A,(HL)
	RET

INS	LD	A,(IX) ;точка в боксе
	CP	L
	RET	NC
	LD	A,L
	CP	(IX+2)
	RET	NC
	LD	A,(IX+1)
	CP	H
	RET	NC
	LD	A,H
	CP	(IX+3)
	RET

NAL	CALL	STD ;наличные
	LD	HL,#1700
	LD	(SX),HL
	XOR	A
	LD	(HIGH),A
	LD	A,132
	CALL	NWRDM
	LD	HL,MONEY
	CALL	WD
	JP	WORD



_words	DEFW	WORDS;/NAMES

NWRD	LD	B,A
	INC 	B
	LD	HL,(_words)
NW0	LD	A,(HL)
	INC	HL
	CP      #7E
	JR	NZ,NW0
	DJNZ	NW0
	JP	WORDHL

NWRDM	LD	L,A
	Ms	1
	LD	A,L
	CALL	NWRD
	JP	MEM7

BACK	LD	HL,SCR
	LD	DE,DSCR
	LD	BC,6912
	LDIR
	RET

NOKEYw	CALL CONTR ;ждать ненажатия
	AND %111111
	JR NZ,NOKEYw
	LD A,14
	JP DELAY

TMOF	;ждать FIRE
	CALL NOKEYw
TMOf	CALL CONTR
	AND %111111
	RET NZ
	JR TMOf
;Цвета меню
DMCOL	DEFB	#38,#30,#70,#4D,#69,000,000,#79,#39,#72
	DEFB	#7A,#68,#38,#69,#71,#78,#6B,#7A,#72,#38
	DEFB	#79,#38,#46,#68,#78,#78,#58,#30,#78,#78
	DEFB	#43,#38,#38,#68,#79,#68,#38,#68,#68,#4D
	DEFB	#79,#38,#46,#68,#47,#71,#56,#72,#30,#7A
	DEFB	#39,#38,#69,#57,#60,#78,#7A,#38,#38,#71
	DEFB	#60,#79,#30,#7A,#7A,#78,#78,#78,#7A,#57
	DEFB	#7A,#7A,#38,#69,#71,#78,#7A,#79,#72,#79
	DEFB	#71,#7A,#38,#38,#39,#78,#38,#38,#38,#38
	DEFB	000,000,000,#4F,#6A,#7A,#38,#38

;============параметры ландшафта
L_LAND	DEFB 1 ;ТИП ландшафта (0-7,8-КолонII,9-UбазаII,10-корабльII)
L_UFO	DEFB 6 ;тип НЛО (0..8)
L_MOD	DEFB 1 ;модификация ландш.
L_IPOS	DEFW 1 ;поз.истр
B_RET	DEFB 1 ;рез-т боя(0/1/2-гибель/эвак/победа)
;===========пришельцы
A_RASA	DEFB 4 ;раса(1..5)
A_NUM	DEFB 22 ;макс число (4..22)
;===============================

WEAPON  ;парам оруж(TU,TUp,PREC,PRECp,HE,FR,Quantity,POWER)
	DEFB	25,50,60,90,32,0,25,0
	DEFB	45,90,50,110,90,0,6,1
	DEFB	90,90,120,120,210,0,5,2
	DEFB    55,75,70,120,0,120,6,0
	DEFB	40,75,60,90,60,0,16,1
	DEFB 	30,30,100,100,80,0,0,0
	DEFB	25,25,100,100,150,0,0,0
	DEFB	45,80,50,100,105,0,15,3
	DEFB	40,60,75,110,75,0,25,2
	DEFB	50,70,80,115,130,0,14,3
	DEFB	45,45,100,100,120,0,0,2
	DEFB	40,40,100,100,0,80,0,0
	DEFB	40,60,70,105,0,0,7,0
	DEFB	45,45,100,100,0,0,0,0
	DEFB 	24,24,100,100,0,0,0,0
	DEFB	0,0,0,0,60,0,0,2 ;для взрыв.предм
	DEFB	TIM_6,TIM_6,100,100,0,0,0,0 ;для тентак
;Цена выстрела
WP_PRC	DEFW	55,900,3500,2400,550,0,0,1100,700,950,0,300,0,0,0

ATRB2	INC H
	INC H
	JP ATRBAR

B_DRAW	DEFB 0; 0 -из меню, 1 -из боя
SOLDAT	DEFB 0
SOLD_D	DEFW 0
Db	DEFB	1

DRAW_P  LD IX,(SOLD_D)
;----рис.поле.параметров
	CALL OFFD
	CALL STD
	LD A,#13
	LD (Db),A
	LD (HIGH),A
	LD B,6
	LD HL,#40A
	PUSH IX
	CHNs XOR_
DWP	PUSH BC
	PUSH HL
	LD (SX),HL
	LD A,(IX+3)
	CALL WB
	LD A,(Db)
	ADD A,16
	LD (Db),A
	LD D,A
	LD E,#70
	LD H,0
	LD L,(IX+3)
	INC L
	INC IX
	ADD HL,DE
	LD B,11
DR4     CALL LINE
	INC H
	INC D
	DJNZ DR4
	POP HL
	INC H
	INC H
	POP BC
	DJNZ DWP
	POP IX
	Ms 3
	CALL STD
	ATRs 0,#2018,#28;всё
	LD BC,#1C04
	LD A,#30   ;Ф.И.О.
	CALL ATRBAR
	ATRs #400,#40C,#79;оруж
	LD B,4
	LD DE,xWBUTTN
P12	PUSH BC
	LD BC,#403
	CALL PUTSIM
	INC H
	INC H
	INC H
	POP BC
	DJNZ P12
	ATRs #406,#30C,#72;парам
	LD B,3
	LD DE,xPARAM
	CALL PUTSIM
	LD HL,#20E
	LD BC,#E02
	LD A,#38  ;парам.линии
	CALL ATRB2
	LD A,#70
	CALL ATRB2
	LD A,#58
	CALL ATRB2
	LD A,#78
	CALL ATRB2
	LD A,#60
	CALL ATRB2
	LD A,#68
	CALL ATRB2
	LD B,4
	LD DE,xBUTTON
	LD HL,28
P14	PUSH BC
	LD BC,#404
	CALL PUTSIM
	LD A,4
	ADD A,H
	LD H,A
	POP BC
	DJNZ P14
	LD BC,#202
	LD HL,#FD1D
	LD DE,xLABEL
	CALL PBL
	LD DE,4*32+xLABEL
	CALL PBL
	LD DE,24*32+xLABEL
	CALL PBL
	LD DE,3*32+xLABEL
	CALL PBL
	LD E,(IX+1)
	LD L,3*3*8
	CALL MULB
	LD HL,xSIGN
	ADD HL,DE
	PUSH HL
	ATRs #1100,#303,#70 ;звание
	POP DE
	CALL PUTSIM
	LD E,(IX+2)
	LD L,3*3*8
	CALL MULB
	LD HL,24*24+xSIGN
	ADD HL,DE
	PUSH HL
	ATRs #110F,#303,#78 ;защита
	POP DE
	CALL PUTSIM
	LD B,4   ;оружие
	PUSH IX
	LD A,(B_DRAW)
	OR A
	JR Z,DR50
	LD A,17-9 ;(из боя)
	CALL HER_BA
	PUSH HL
	POP IX
DR50	LD HL,#2400
DR5	PUSH BC
	LD A,(IX+9)
	INC IX
	CP 255
	JR Z,DR6
	PUSH HL
	LD L,A
	LD E,4*2*8
	CALL MULB
	LD HL,xWEAPON
	ADD HL,DE
	EX DE,HL
	POP HL
	LD BC,#410
	CALL PUTSCR
DR6	LD A,H
	ADD A,24
	LD H,A
	POP BC
	DJNZ DR5
	POP IX
	LD A,2
	LD (HIGH),A
	LD A,(IX+1)
	LD HL,#1204
	LD (SX),HL
	ADD A,80
	CALL NWRDM
	LD A,#13
	LD (SX),A
	LD A,(IX+2)
	OR A
	JR Z,DW1
	ADD A,14
	JR DW2
DW1     LD A,160
DW2	CALL NWRDM
	LD HL,#101
	LD (SX),HL
	LD HL,NAMES
	LD (_words),HL
	LD A,(IX)
	DEC A
	CALL NWRDM
	LD HL,WORDS
	LD (_words),HL
	XOR A
	LD (HIGH),A
	WRDs #1104,158
	WRDs #1113,159
	JP MEM7

PBL	INC H
	INC H
	INC H
	INC H
	JP PUTSIM

SELM	LD HL,SELmr ;Выбор без выводa инф.
SELTX   LD (sx1+1),HL ;HL-Sub.ADR
	LD (sx2+1),HL
	CALL MEM7
	CALL INIMNU ;Выбор c выводом инф.
	CALL MENUC
SELTN	CALL MARK_
	JR C,SELTN
	LD A,(MPOS)
sx2	CALL 15635
selm_   CALL MARK
	PUSH AF
sx1	CALL 15635
	POP AF
	JR NC,selm_
	CP 254
	RET NC ;NC-отмена
	LD HL,MXDM
	CALL BA
	SCF
SELmr	RET

E_I	pushs;$
	EI
	HALT
	DI
	pops;$
	RET

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

RESNUM	;выч числа иссл 
	LD HL,RS
	LD BC,#5000
RESU1	LD A,(HL)
	INC HL
	OR A
	JR NZ,RESU2
	INC C
RESU2	DJNZ RESU1
	LD A,C
	SUB #1F
	RET


;===================================

VICTRY	;полная победа
	CALL LDASM3
	CALL POBEDA
	CALL LDASM2
	CALL NW_GE
	CALL OFFS
	CALL MLOOP

WAREND	DEFB 0 ;не 0 - нет Пси-контр
BATRES	DEFB 2 ;рез-т боя
BATTL_	CALL PREBAT ;один бой
	CALL LDASM3
	CALL L_Land
	CALL L_OFF
	CALL SWPBAT
	CALL PT128
	LD (BATRET+1),SP
	CALL COMBAT
BATRET  ;A=0-гибель,1-эвак.,2-победа
	LD SP,#4022
	LD (BATRES),A
	PUSH AF
	CALL PICK
	CALL TO_INT
	CALL SWPBAT
	CALL LDASM1
	CALL LDASM2
	CALL MEM7
	POP AF
	RET

L_ON	LD HL,#E000 ;[]-откр поле
	LD BC,#2000
	LD A,(xHACK)
	CP #7F
	RET NZ
LQWE	RES 7,(HL)
	INC HL
	DEC BC
	LD A,C
	OR B
	JR NZ,LQWE
	RET

;LODT	DEFW LESHA,ASMBL1,ASMBL2
;LODLEN	DEFW #1500,#1500,#1800
;LODLPc  PUSH AF
;	LD HL,LODLEN
;	CALL WT
;	POP AF
;	PUSH HL
;	LD HL,LODT ;без компр
;	CALL WT
;	XOR A
;	CALL MEM
;	POP BC
;	LDIR
;	RET

       if 0
LODLPc	LD HL,#4000 ;c компр
	CALL WT
	XOR A
	CALL MEM
	JP DELPC
       endif

BATREE	LD (WAREND),A
	JR BATRET

SWPBAT	CALL MEM7
	LD DE,SwpADR
	LD HL,SwpMEM
	LD BC,#1A00
	JP SWAP_X

LDASM1  LD DE,#AB00
	LD A,1
	JR lda
LDASM3	LD DE,SwpADR
	LD A,3
	JR lda
LDASM2	LD DE,SwpADR
	LD A,2
lda	CALL LODmlz;LODLPc
	JP MEM7

LODALX	LD DE,DSCR
	PUSH DE
	XOR A
	CALL LODmlz;LODLPc
	CALL PT128
	LD BC,#1500
	POP HL
	LD DE,#B000
	LDIR
	RET

B_LOOP	;вызов 1-3х этапов боя
	CALL CLEAR
	LD A,(T_TYPE)
	CP 7
	JR C,BP1
	LD A,5
	CALL BAT_A
	CP 2
	JP C,SMERT
	LD A,8
	CALL BAT_A
	CP 2
	JP C,SMERT
	LD A,7
	CALL BAT_A
	CP 2
	JP C,SMERT
	CALL VICTRY
BP1	CALL BAT_A
	JP Z,EVAC
	JP C,ALLDIE
	LD A,(RS+57)
	OR A
	JR NZ,BPOK ;не знаем о нижн этажах
	LD A,(T_TYPE)
	CP 1
	JR Z,BP21
	CP 5
	JR C,BPOK ;нет нижн эт
	ADD A,3
	JR BP2
BP21	LD A,10
BP2	CALL BAT_A
	JP Z,EVAC
	JP C,ALLDIE
BPOK	CALL BACK
	LD IX,MU95
	JP MNU

MU95	DEFW #404,#5F14
BAT_A	LD (L_LAND),A
	CALL BATTL_
	CP 1
	RET

BATTLE    ;бой с нло
	CALL SEABAT

BATTL1	 ;битва
        jr $
	DI
	CALL NOKEYw
	 LD A,R
	 LD (RNB),A
;	JR RRJR ;==
;	 LD HL,256*5+13 ;GUN
;	 LD (AQNAVT+9),HL
;	 LD HL,256*11+12 ;GUN
;	 LD (AQNAVT+11),HL
;	 LD A,1
;	 LD (T_TYPE),A
	
RRJR	CALL B_LOOP
	CALL POSTBAT
	CALL GOhome
	JP MLOOP
