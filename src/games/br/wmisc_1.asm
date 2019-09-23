;****** всп.подпр Рage 1 *** (272бт)
;---ремонт вражьих задний
REMONT	LD A,(TIC)
	CP 127
	RET C
	AND #1F
	ADD A,#28
	CALL B_IX
	LD A,(IX+0)
	OR A
	RET Z ;нету
	LD A,(IX+2)
	LD HL,bHEALT
	CALL BA
	LD A,(IX+3)
	CP (HL)
	RET NC ;ок
	CALL HL_IX0
	CALL loop_K
rrm0	LD A,(IX+0)
	OR A
	JR Z,rrm1
	LD A,(IX+4)
	OR A
	JR Z,rrm2
	CP 9
	JR NZ,rrm1
rrm2	;свободн. крестьянин
	LD A,(IX+9)
	CP 8 ;уже? или в здании?
	JR NC,rrm1
	LD (IX+8),#80
	LD (IX+9),8
	JP IXt_HL
rrm1	ADD IX,DE
	DJNZ rrm0
	RET ;нет рабочих

;-----работа с данн гер


NEWALL	CALL CLRALL ;расстановка сил
	LD HL,datHER
nA0	LD A,(HL)
	CP 255
	RET Z
	PUSH HL
	CP 2
	JR NC,nA1
	LD A,(MASTER)
	XOR (HL)
nA1	PUSH AF
	EX AF,AF
	INC HL
	LD A,(HL)
	EX AF,AF
	INC HL
	LD E,(HL)
	INC HL
	LD H,(HL)
	LD L,E
	CALL NEWHER
	POP AF
	OR A
	CALL Z,ONSEE1 ;не та страница
	POP HL
	LD DE,5 ;длина init-записи о герое
	ADD HL,DE
	JR nA0

NEWenm	;распределение начальных ролей для врагов
	CALL loop_K
nee0	LD A,(IX)
	OR A
	JR Z,nee1
	LD (IX+13),1 ;охрана
	LD A,(IX+4)
	CP 9
	JR C,nee2
	SUB 9
nee2	CP 3
	JR NC,nee10
	CP 1
	LD (IX+13),8 ;<ремонтник>
	JR C,nee1
	JR Z,nee3
	DEC (IX+13) ;золотодобытч
	DEC (IX+4)
	JR nee4
nee3	LD (IX+13),6 ;лесоруб
nee4	DEC (IX+4)
	JR nee1
	;
nee10	CP 5
	JR NZ,nee20
	LD (IX+13),10 ;свящ-охр
	JR nee1
nee20	CP 6
	JR NZ,nee1
	LD (IX+13),11 ;волш-охр
	;
nee1	ADD IX,DE
	DJNZ nee0
	RET

ANIset	LD A,(isANI)
	OR A
	JR Z,ANIMOF
	;
ANIMON	LD HL,MAP
	LD BC,#1000
ANN1	LD A,(HL)
	AND #7F
	CP 56
	JR C,ANN0
	CP 61
	JR NC,ANN0
	LD A,(HL)
	ADD A,113-56
	LD (HL),A
ANN0	INC HL
	DEC BC
	LD A,B
	OR C
	JR NZ,ANN1
	RET Z

ANIMOF	LD HL,MAP
	LD BC,#1000
ANF1	LD A,(HL)
	AND #7F
	CP 113
	JR C,ANF0
	CP 119
	JR NC,ANF0
	LD A,(HL)
	ADD A,56-113
	LD (HL),A
ANF0	INC HL
	DEC BC
	LD A,B
	OR C
	JR NZ,ANF1
	RET Z

