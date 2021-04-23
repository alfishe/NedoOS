;*Z80
*L+
*M-
;*D-
;********ДЕМОНСТРАЦИОННЫЙ МОДУЛЬ ДЛЯ НЛО-2********
iIVAN	EQU 32000
pIVAN	EQU iIVAN+6
*P1
	ORG #C000
SCR
*B      ..\XDEMO\XDEMO0.lpc
*P3
	ORG #C000
*B	..\XDEMO\XDEMOTXT.lpc
*P6
	ORG #C000
*B	..\XDEMO\XDEMOS6.lpc
*P7
	ORG #C000
*B	..\XDEMO\XDEMOS7.lpc
	DEFM " ===Слава Медноногов=== 143/33/03"
*P4
	ORG #C000
*B	..\XDEMO\XDEMO1.lpc
*P0
	ORG #C000
*B	..\XDEMO\XDEMO2.lpc
;---------------------

	ORG #7000
	ENT $
ST1	JR	ST1_
	DEFM "   *** (c) 1996 Mednonogov bros.  "
	DEFM "'UFO-2' Demo Movie v1.03 "
	DEFM " Tel/Fax (812) 1433303 ***   "
ST1_	DI
	LD (OLDSP+1),SP
	LD SP,#BFF0
	EXX
	PUSH HL
	PUSH IY
	IM 2
	LD A,#71
	LD I,A
	CALL iIVAN
	DI
	JP START
	DEFS #7272-$,#72
intr	PUSH DE
	PUSH HL
	PUSH BC
	CALL pIVAN
	CALL KEYs
	POP BC
	POP HL
	POP DE
	EI
	RET
*F 	XGRLIB
MEME	LD BC,#7FFD
	AND #7
	OR 16
	OUT (C),A
	RET

START	CALL DECOMP	
	ATR$ #0,#2018,#70  ;всё поле
	XOR A
	OUT (254),A
	CALL CHNGRG
	DEC A
	CALL SIMBAR
	LD HL,#D00
	LD BC,#1070
	LD DE,XTITLE
	CALL PUTSCR
	ATR$ #1000,#808,#50;экран
	ATR$ #0010,#1012,#68;земной шар
	ATR$ #1208,#1806,#78;текст
	ATR$ #800,#1008,#30;надпись
	CHN$ XOR_
	LD HL,#B939
	LD DE,#B906
	CALL LINE
	DEC D
	LD HL,#8606
	CALL LINE
	INC L
	LD DE,#8639
	CALL LINE
	INC D
	LD HL,#B839
	CALL LINE
	LD HL,BUFFER
	LD DE,BUFFER+1
	LD (HL),#FF
	LD BC,575
	LDIR
	EI

NACH	LD A,0
	CALL E8
	LD A,1
	CALL E8
	LD A,4
	CALL E8
	JP NACH

PAGE	DEFB 7
E8      LD (PAGE),A
	LD B,8
	LD DE,#4000+16+#20
	LD HL,SCR
E88     LD C,1
E89	PUSH$
	HALT
	CALL PTBALL
	POP$
	PUSH$
	HALT
	CALL FLIK
	CALL VOSST
	POP$
	LD A,C
TIM	ADD A,250
	LD C,A
	JR NC,E89
	LD A,H
	ADD A,8
	LD H,A
E78	DJNZ E88
	RET

PTBALL  LD A,(PAGE)
	CALL MEME
	LD B,128
PB0	PUSH BC
	PUSH DE
	LDI
	LDI
	LDI
	LDI;
	LDI
	LDI
	LDI
	LDI ;
	LDI
	LDI
	LDI
	LDI  ;
	LDI
	LDI
	LDI
	LDI   ;
	POP DE
	POP BC
	INC D
	LD A,D
	AND %111
	JR NZ,M74
	LD A,D
	SUB 8
	LD D,A
	LD A,E
	ADD A,32
	LD  E,A
	JR NC,M74
	LD A,8
	ADD A,D
	LD D,A
M74     DJNZ PB0
	RET

DEL	EQU TIM+1
KEYs    PUSH BC
	LD BC,#BFFE
	IN A,(C)
	POP BC
	BIT 2,A
	JR NZ,KY1
	LD A,(DEL);+++
	INC A
	RET Z
	LD (DEL),A
	RET
KY1	BIT 3,A
	JR NZ,KY2
	LD A,(DEL);---
	OR A
	RET Z
	DEC A
	LD (DEL),A
	RET
KY2	BIT 0,A
	RET NZ
	DI
	XOR A
	CALL MEME
	IM 1
	LD BC,65533
	LD A,7
	OUT (C),A
	LD BC,49149
	LD A,#FF
	OUT (C),A
	ATR$ 0,#2018,0
	POP IY
	POP HL
	EXX
	LD BC,1995
OLDSP	LD SP,0
	EI
	RET
;0-пропуск такта
;253 -конец
;255,N-ждать N тактов
;254,С-цвет С
;1-100 и 101-200 - картинки
;201-230 - тексты
FLIK	LD HL,SDELAY
	LD A,(HL)
	OR A
	JR Z,FL1
	DEC (HL)
	RET
FL1	LD HL,(PSCEN)
	LD A,(HL)
	INC HL
	LD (PSCEN),HL
	OR A
	RET Z
	CP 253
	JR NZ,FL2
	LD HL,SCENA ;С начала
	LD (PSCEN),HL
	JP iIVAN
FL2	CP #FE
	JR C,FL3
	JR Z,FCOL
	LD A,(HL)     ;Пауза
	LD (SDELAY),A
	INC HL
	LD (PSCEN),HL
	RET
FCOL	LD A,(HL)      ;Цвет
	INC HL
	LD (PSCEN),HL
	LD HL,#1101
	LD BC,#606
	JP ATRBAR
FL3	CP 201
	JR C,FL4
	SUB 201	       ;Текст
	LD L,A
	LD A,3
	CALL MEME
	LD A,55
	LD (VOSB),A
	LD H,0
	DEFS 6,#29 ;add hl
	PUSH HL
	DEFS 3,#29
	POP DE
	ADD HL,DE
	LD DE,#C000
	ADD HL,DE
	LD DE,BUFFER
	LD BC,576
	LDIR
	RET
FL4	DEC A	;Мультик
	LD L,A
	LD H,0
	CP 100
	LD A,6
	JR C,FL41
	LD A,L
	SUB 100
	LD L,A
	LD A,7
FL41	CALL MEME
	DEFS 5,#29
	PUSH HL
	DEFS 3,#29
	POP DE
	ADD HL,DE
	LD BC,#C000
	ADD HL,BC
	LD DE,#5000+32+1
	LD B,48
FL40	PUSH BC
	PUSH DE
	LDI
	LDI
	LDI
	LDI
	LDI
	LDI
	POP DE
	INC D
	LD A,D
	AND %111
	JR NZ,M38
	LD A,D
	SUB 8
	LD D,A
	LD A,E
	ADD A,32
	LD  E,A
	JR NC,M38
	LD A,8
	ADD A,D
	LD D,A
M38     POP BC
	DJNZ FL40
	RET

VOSB	DEFB 1
VOSST	LD HL,VOSB
	INC (HL)
	LD A,(HL)
	CP 24
	JR C,VS1
	XOR A
	LD (HL),A
VS1	LD DE,#5000+64+768+8
	LD L,A
	ADD A,E
	LD E,A
	LD H,0
	LD BC,BUFFER
	ADD HL,BC
	LD B,24
VS0	PUSH BC
	LD A,(HL)
	LD (DE),A
	LD BC,24
	ADD HL,BC
	INC D
	LD A,D
	AND %111
	JR NZ,M338
	LD A,D
	SUB 8
	LD D,A
	LD A,E
	ADD A,32
	LD  E,A
	JR NC,M338
	LD A,8
	ADD A,D
	LD D,A
M338	POP BC
	DJNZ VS0
	RET

	DEFS iIVAN-17-$,#CC
*B	..\MUSIC\M_IVAN2.$C

BUFFER
XTITLE	
*B	..\DATA\XTITLE.DAT

W	MAC
	DEFB 255,=0
	ENDM

CL	MAC
	DEFB 254,=0
	ENDM

S6	MAC
	DEFB =0
	ENDM

S7	MAC
	DEFB =0+100
	ENDM
T	MAC
	DEFB =0+200
	ENDM
CLEAR	MAC
	DEFB 254,0,1
	ENDM

	DEFM "  24 Earth spr/ 28 Text spr/ 112 Movie spr/ Good music!"

SCENA	;СЦЕНАРИЙ
;Титры и кредиты
	T 7
	CLEAR
	W 170
	T 1
	W 180
	T 3
	W 23
	S6 4
	CL #8
	CL #30
	CL #78
	CL #30
	CL #50
	W 250
	T 7
	W 25
	CL #30
	CL #78
	CL #30
	CL 8
	CLEAR
	W 55
	T 2
	W 23
	S6 3
	CL #10
	CL #30
	CL #78
	CL #70
	CL #38
	W 150
	T 4
	W 220
	T 16
	W 220
	T 7
	W 20
	CL #31
	CL #32
	CL #7E
	CL #7F
	CL #36
	CL 9
	CLEAR
	W 60
	T 5
	W 20
	S6 2
	CL 8
	NOP
	CL #10
	NOP
	CL #18
	NOP
	CL #28
	NOP
	CL #68
	NOP
	CL #78
	NOP
	CL #68
	W 250
	W 100
	T 7
	W 20
	CL #78
	NOP
	CL #68
	NOP
	CL #28
	NOP
	CL #18
	NOP
	CL #10
	NOP
	CL 8
	CLEAR

;Марсианские хроники
	W 80
	S6 5
	CL 8
	NOP
	NOP
	CL #10
	NOP
	NOP
	CL #18
	NOP
	CL #58
	T 6
	W 55
	S6 6
	W 70
	S6 7
	W 70
	S6 8
	W 55
	T 8
	W 14
	S6 9
	W 30
	S6 18
	NOP
	S6 19
	NOP
	S6 20
	NOP
	S6 21
	NOP
	S6 22
	NOP
	S6 23
	NOP
	S6 24
	NOP
	S6 9
	W 15
	S6 10
	W 70
	S6 11
	W 70
	S6 12
	W 60
	T 9
	W 9
	S6 13
	W 70
	S6 14
	W 70
	S6 15
	W 70
	S6 16
	W 70
	S6 17
	W 25
	S6 25
	NOP
;SCENA	;ЛУЧ
	S6 26
	NOP
	S6 27
	CL #59
	S6 28
	NOP
	S6 29
	NOP
	S6 30
	CL #30
	CL #70
	CL #78
	W 5
	T 10
;SCENA;Земля 1999
	CL #70
	W 5
	CL #68
	NOP
	CL #2D
	S6 31
	W 65
	CL #2B
	NOP
	CL #2A
	NOP
	CL #29
	W 35
	T 11
	W 40
	S6 32
	CL #69
	S6 33
	CL #71
	S6 34
	S6 35
	S6 30
	W 7
	CL #6D
	W 3
	S6 31
	CL #2D
	NOP
	CL #2A
	NOP
	CL #29
	W 39
	CL #19
	NOP
	CL #11
	NOP
	CL #49
	S6 1
	T 7
	W 25
;SCENA;Разбуженный пришелец
	T 12
	W 105
	T 13
	S7 25
	CL #51
	W 2
	CL #61
	W 2
	CL #68
	W 2
	CL #70
	W 115
	S7 26
	W 3
	S6 54
	W 3
	S6 55
	W 3
	S6 56
	W 87
	T 7
	W 10
	CL 18
	NOP
	CL 8
	NOP
	CLEAR
	W 60
;Земля-2017
	S7 27
	CL #8
	NOP
	CL #50
	NOP
	CL #68
	NOP
	CL #70
	W 5
	T 14
	W 60
	S7 28
	NOP
	S7 29
	NOP
	S7 30
	NOP
	S7 31
	NOP
	S7 32
	NOP
	S7 33
	NOP
	S7 34
	W 80
	S7 35
	NOP
	S7 36
	NOP
	S6 30
	W 36
	
;Чужаки
	S6 52
	W 2
	S6 53
	W 3
	S7 1
	W 9
	T 15
	W 70
	S7 2
	S7 3
	S7 4
	S7 5
	S7 6
	NOP
	S7 5
	S7 4
	S7 3
	S7 2
	S7 1
	W 15
	S6 53
	W 1
	S6 52
	W 1
	S6 30
	W 16
;SCENA;Нападение на корабль
	CLEAR
	CL #69
	S7 38
	W 10
	T 17
	W 100
	S7 39
	W 2
	S7 40
	W 2
	S7 41
	W 5
	T 18
	W 90
	S7 42
	S7 43
	S7 44
	S7 45
	S7 46
	S7 47
	S7 48
	S7 41
	W 25
	T 19
	W 10
	S7 42
	S7 43
	S7 44
	S7 45
	S7 46
	S7 47
	S7 48
	S7 41
	S7 42
	S7 43
	S7 44
	S7 45
	S7 46
	S7 47
	S7 48
	S7 41
	S7 42
	S7 43
	S7 44
	S7 45
	S7 46
	S7 47
	S7 48
	S7 41
	S7 42
	S7 43
	S7 44
	S7 45
	S7 46
	S7 47
	S7 48
	S7 41
	W 60
	S7 40
	W 2
	S7 39
	W 2
	S7 38
	W 25
	CLEAR
	S7 37
	CL #60
	T 28
	W 110
	CL #61
	CL #6A
	CL #75
	CL #7F
	S6 1
	CL #46
	CL #45
	CL #44
	CL #42
	CL 1
	CLEAR
	W 7
	T 20
	W 140
	
;База
	CL #68
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	T 21
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	T 22
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
	W 4
	S6 46
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 48
	NOP
	NOP
	S6 47
	NOP
	NOP
	S6 46
	NOP
	NOP
	S6 36
	W 4
	S6 49
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 51
	NOP
	NOP
	S6 50
	NOP
	NOP
	S6 49
	NOP
	NOP
	S6 36
;Открыть ШЛЮЗ
	W 10
	S6 37
	W 4		
	S6 38
	W 4
	S6 39
	W 4
	S6 40
	W 4
	S6 42
	W 4
	S6 43
	W 4
	S6 44
	W 4
	S6 45
	W 4
	S6 1
;Тритон выплывает
	W 14
	S7 7
	W 2
	S7 8
	W 2
	S7 9
	W 2
	S7 10
	W 2
	S7 11
	W 2
	S7 12
	W 2
	S7 13
	W 2
	S7 14
	T 23
	S7 15
	W 2
	S6 1
;SCENA;ВРАЩАЮЩИЙСЯ МОНИТОР
	CLEAR
	W 30
	CL 1
	CL 2
	CL 4
	CL 5
	CL #46
	CL #7F
	S7 23
	CL #7D
	S7 24
	CL #78
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	T 24
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	NOP
	S7 24
	NOP
	S7 16
	NOP
	S7 17
	NOP
	S7 18
	NOP
	S7 19
	NOP
	S7 20
	NOP
	S7 21
	NOP
	S7 22
	NOP
	S7 23
	CL #70
	S7 24
	CL #28
	S7 16
	CL #20
	S7 17
	CL #10
	S7 18
	CL #8
	CLEAR
	W 30
;SCENA;Идут акванавты
	T 25
	W 22
	S7 49
	CL #8
	S7 50
	CL #18
	S7 51
	CL #28
	S7 52
	CL #30
	S7 53
	CL #38
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	T     26
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	NOP
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	NOP
	S7 54
	NOP
	S7 55
	NOP
	S7 56
	T 27
	S7 49
	NOP
	S7 50
	NOP
	S7 51
	NOP
	S7 52
	NOP
	S7 53
	CL #30
	S7 54
	CL #20
	S7 55
	CL #10
	S7 56
	CLEAR

;КОНЕЦ
	W 100
	T 26
	W 10
	CL #68
	S6 41
	W 170
	T 27
	W 200
	T 25
	W 170
	T 27
	W 100
	CL 0
	S6 4
	CL #42
	W 100
	T 26
	W 180
	T 27
	W 80
	CL #60
	S6 2
	W 100
	CLEAR
	T 7
	W 45


	DEFW 253

;СЦЕНАРИЙ

SDELAY	DEFB 5
PSCEN	DEFW SCENA

DECOMA  CALL	MEME
	LD	BC,(SCR)
	LD	HL,SCR+2
	ADD	HL,BC
	DEC	HL
	LD	DE,#FFFE
	LDDR
	EX	DE,HL
	INC	HL
	LD	DE,SCR
	CALL	DELPC
	RET

DECOMP  XOR A
	CALL DECOMA
	LD A,1
	CALL DECOMA
	LD A,6
	CALL DECOMA
	LD A,7
	CALL DECOMA
	LD A,4
	CALL DECOMA
	LD A,3
	JP DECOMA

*F xDELPC