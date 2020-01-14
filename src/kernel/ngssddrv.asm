;кодировка 866
;опознаётся неправильно
;поэтому напишем много текста кириллицей
;LAST UPDATE: 30.06.2019 savelij

;АДРЕС ЦИКЛА ОБЩЕНИЯ СО СПЕКОМ
COMINT_		EQU 0X026E

_DEV_READ=2
_DEV_WRITE=3

P_DATA          EQU 0X57
P_CONF          EQU 0X77

CMD_09          EQU 0X49        ;SEND_CSD
CMD_12          EQU 0X4C        ;STOP_TRANSMISSION
CMD_17          EQU 0X51        ;READ_SINGLE_BLOCK
CMD_18          EQU 0X52        ;READ_MULTIPLE_BLOCK
CMD_24          EQU 0X58        ;WRITE_BLOCK
CMD_25          EQU 0X59        ;WRITE_MULTIPLE_BLOCK
CMD_55          EQU 0X77        ;APP_CMD
CMD_58          EQU 0X7A        ;READ_OCR
CMD_59          EQU 0X7B        ;CRC_ON_OFF
ACMD_41         EQU 0X69        ;SD_SEND_OP_COND

;АДРЕС УСТАНОВЩИКА ДРАЙВЕРА НА NeoGS
;SETUPSD		EQU 0X5B00

;ДРАЙВЕР SD-CARD ДЛЯ NGS

;ВХОДНЫЕ ПАРАМЕТРЫ ОБЩИЕ:
;HL-АДРЕС ЗАГРУЗКИ В ПАМЯТЬ
;BCDE-32-Х БИТНЫЙ НОМЕР СЕКТОРА
;A-КОЛИЧЕСТВО БЛОКОВ (БЛОК=512 БАЙТ)
;ТОЛЬКО ДЛЯ МНОГОБЛОЧНОЙ ЗАПИСИ/ЧТЕНИИ

;ОШИБКИ ВЫДАВАЕМЫЕ НА ВЫХОДЕ:
;A=0-ИНИЦИАЛИЗАЦИЯ ПРОШЛА УСПЕШНО
;A=1-КАРТА НЕ НАЙДЕНА ИЛИ НЕ ОТВЕТИЛА

;ЗАПИСЬ "A" СЕКТОРОВ
;SDWRMUL		EX AF,AF'
writesectorsGS
		LD A,_DEV_WRITE
		CALL COMM2SD
		EX AF,AF'
		PUSH DE
		PUSH BC
		LD BC,GSDAT
SDWRSN1		EX AF,AF'
		OUT (GSCOM),A
		CALL WC_
		LD DE,0X0200
SDWRSN2		OUTI
		CALL WD_
		DEC DE
		LD A,D
		OR E
		JR NZ,SDWRSN2
		EX AF,AF'
		DEC A
		JR NZ,SDWRSN1
		CALL WN_
		;IN A,(GSDAT)
		;CP 0X99				;КАРТА ПОТЕРЯЛАСЬ ПО ВРЕМЯ ЧТЕНИЯ/ЗАПИСИ
		;JP Z,SD_CARD_LOST
		POP BC
		POP DE
		XOR A
		RET

;ЧТЕНИЕ "A" СЕКТОРОВ
;SDRDMUL		EX AF,AF'
readsectorsGS
		LD A,_DEV_READ
		CALL COMM2SD
		EX AF,AF'
		PUSH DE
		PUSH BC
		;LD D,A
		;LD A,IYL
		;BIT 1,A
		;JR NZ,SDRDSN3
		;AND A
		;JR NZ,SDRDSN5
;SDRDSN3		
;		LD A,(R_7FFD)
		;READ_7FFD
		;AND 0X10
		;LD BC,(B0_CPU2)
		;JR Z,SDRDSN4
		;LD BC,(B1_CPU2)
;SDRDSN4
                ;LD A,0X37
		;OR B
		;LD B,A
		;LD A,C
		;LD C,LOW (WIN_A0)
		;OUT (C),A
;SDRDSN5
		;LD A,D
		LD BC,GSDAT
SDRDSN1		EX AF,AF'
		OUT (GSCOM),A
		IN A,(GSCOM)
		RRA
		JR C,$-3
		LD DE,0X0200			;ПРОДОЛЖАЕМ ЕСЛИ ВСЕ В ПОРЯДКЕ
SDRDSN2		IN A,(GSCOM)
		RLA
		JR NC,$-3
		INI
		DEC DE
		LD A,D
		OR E
		JR NZ,SDRDSN2
		EX AF,AF'
		DEC A
		JR NZ,SDRDSN1
		IN A,(GSCOM)
		RLA
		JR NC,$-3
		;IN A,(GSDAT)
		;CP 0X99				;КАРТА ПОТЕРЯЛАСЬ ПО ВРЕМЯ ЧТЕНИЯ/ЗАПИСИ
		;JP Z,SD_CARD_LOST
		;LD BC,WIN_P6
		;XOR A
		;OUT (C),A
		POP BC
		POP DE
		RET

GS_INIT
        jr SD_NO ;savelij13: please fix
;ПРОВЕРКА НАЛИЧИЯ КАРТОЧКИ
;GSDCMP		;LD H,CMOS_BYTE_01
		;ROMCALL READCMOS,ROM_RST82
		;LD A,L
		;AND M_ACCESSSDG			;ПРОВЕРКА РАЗРЕШЕНИЯ ДОСТУПА К SD КАРТЕ NEOGS
		;JR Z,SD_NO			;ВЫХОД ЕСЛИ ДОСТУП К КАРТОЧКЕ ЗАПРЕЩЕН
		;LD A,(FLAGS_DRV)
		;AND B_INST_SDG
		;JR Z,SD_NO			;ВЫХОД ЕСЛИ ДРАЙВЕР НЕ УСТАНОВЛЕН
		XOR A
		OUT (GSDAT),A
		LD A,0X1D
		OUT (GSCOM),A
		IN A,(GSCOM)
		RRA
		JR C,$-3
		IN A,(GSDAT)
		LD D,A
		AND 0X0F
		LD E,A
		LD A,D
		AND 0XF0
		RRCA
		RRCA
		RRCA
		RRCA
		CP E
		LD A,1
		JR NZ,GSDINIT1
		CALL INSTSDD

;ИНИЦИАЛИЗАЦИЯ КАРТОЧКИ
GSDINIT		XOR A
GSDINIT1	CALL COMM2SD
		CALL WN_
GSDINIT2	IN A,(GSDAT)
GSDINIT3	;CP 0X99				;КАРТА ПОТЕРЯЛАСЬ ПО ВРЕМЯ ЧТЕНИЯ/ЗАПИСИ
		;JP Z,SD_CARD_LOST
		CP 0X77
		JR NZ,SD_NO
		XOR A
		RET

SD_NO		LD A,1
		RET

;ПЕРЕДАТЧИК КОМАНД/ПАРАМЕТРОВ В ДРАЙВЕР НА NeoGS
COMM2SD		OUT (GSDAT),A		;УШЛА КОМАНДА ДРАЙВЕРУ
		LD A,0X1E
		OUT (GSCOM),A
		CALL WC_		;УШЛА КОМАНДА ПРОШИВКЕ
		LD A,B
		OUT (GSDAT),A
		CALL WD_		;УШЛИ БИТЫ 31-24 ПАРАМЕТРОВ ;savelij13: тут виснет
		LD A,C
		OUT (GSDAT),A
		CALL WD_		;УШЛИ БИТЫ 23-16 ПАРАМЕТРОВ
		LD A,D
		OUT (GSDAT),A
		CALL WD_		;УШЛИ БИТЫ 15-8 ПАРАМЕТРОВ
		LD A,E
		OUT (GSDAT),A
		CALL WD_		;УШЛИ БИТЫ 7-0 ПАРАМЕТРОВ
		EX AF,AF'
		OUT (GSDAT),A
		EX AF,AF'
		ds 9,0
		RET			;УШЛО КОЛ-ВО СЕКТОРОВ

;ОЖИДАНИЕ КОГДА NeoGS БАЙТ ЗАБЕРЕТ
WD_		IN A,(GSCOM)
		RLA
		JR C,$-3
		RET

;ОЖИДАНИЕ КОГДА NeoGS ДАСТ БАЙТ
WN_		IN A,(GSCOM)
		RLA
		JR NC,$-3
		RET

;ОЖИДАНИЕ КОГДА NeoGS КОМАНДУ ЗАБЕРЕТ
WC_		IN A,(GSCOM)
		RRA
		JR C,$-3
		RET

;УСТАНОВЩИК ДРАЙВЕРА НА NeoGS
INSTSDD		LD A,0X80
		OUT (GSCTR),A			;ПОЛНЫЙ СБРОС NEOGS
		;EI
		HALT
		;EI
		HALT
		;EI
		HALT
		;DI
		LD A,0XF3
		OUT (GSCOM),A
		LD B,0X30
ISDD1		;EI
		HALT
		;DI
		DEC B
		JR Z,SD_NO
		IN A,(GSCOM)
		RRA
		JR C,ISDD1
		LD BC,GSDAT
		IN A,(C)
		LD DE,0X0300
		LD HL,SETUPSD
		OUT (C),E
		LD A,0X14
		OUT (GSCOM),A
		CALL WC_
		OUT (C),D
		CALL WD_
		OUT (C),L
		CALL WD_
		OUT (C),H
		CALL WD_
		LD HL,UKLAD1
ISDD3		OUTI
		CALL WD_
		DEC DE
		LD A,D
		OR E
		JR NZ,ISDD3
		LD HL,SETUPSD
		OUT (C),L
		LD A,0X13
		OUT (GSCOM),A
		CALL WC_
		OUT (C),H
		;EI
		HALT
		;EI
		HALT
		;DI
		LD B,3
		IN A,(GSDAT)
		DEC B
		JP Z,SD_NO
		CP 0X77
		JP NZ,SD_NO
		XOR A
		RET

UKLAD1	;ОТКУДА КОД НА НГС ЗАКИДЫВАТЬ

		;PHASE SETUPSD
SETUPSD=$
;САМ УСТАНОВЩИК ДРАЙВЕРА ДЛЯ NeoGS
		;DI
		LD A,0X9C
		OUT (SCTRL),A		;КОНФИГУРАТОР NeoGS
		CALL AVTODET
		AND A
		LD A,0X77		;0X77-NeoGS НАЙДЕН
		JR Z,$+4
		LD A,0XCC		;0XCC-НАЙДЕН OLDGS
		OUT (ZXDATWR),A
		OUT (CLRCBIT),A
		JP NZ,COMINT_
		;DI
		IN A,(GSCFG0)
		RES B_RAMRO,A
		OUT (GSCFG0),A
		LD HL,0X1D00
		LD (0X0300+(0X1E*2)),HL
		LD DE,UKLAD2
		LD BC,GSDDRVE-GSDDRV
		EX DE,HL
		LDIR
		IN A,(GSCFG0)
		SET B_RAMRO,A
		OUT (GSCFG0),A
		JP COMINT_

;ПРОВЕРКА ЧТО ЭТО NeoGS И ВКЛЮЧЕНИЕ ЧАСТОТЫ 24MHz
AVTODET		IN A,(GSCFG0)
		AND 0XCF
		OUT (GSCFG0),A		;ОБРАТНАЯ ЗАПИСЬ В ПОРТ СО СБРОШЕННЫМИ
					;БИТАМИ 5-4 ВКЛЮЧАЕТ ЧАСТОТУ ПРОЦЕССОРА
					;РАВНЫМ 24 МГц
		LD D,A
		IN A,(GSCFG0)
		CP D
		LD A,0
		RET Z
		DEC A
		RET

UKLAD2	;ОТКУДА КОД ПЕРЕКИДЫВАТЬ

		;DEPHASE

		;PHASE 0X1D00
_shift=0x1d00-$

;ОБЩАЯ ТОЧКА ВХОДА ДЛЯ РАБОТЫ С SD КАРТОЙ
GSDDRV=$+_shift
                DI
		IN A,(ZXDATRD)		;ПРИЕМ КОМАНДЫ ДРАЙВЕРА
		OUT (CLRCBIT),A		;СБРОС COMANDBIT
		LD HL,COMINT_
		PUSH HL
		PUSH IY
		LD IYH,0X77
		ADD A,A
		LD E,A
		LD D,0
		LD HL,TABLSDG
		ADD HL,DE
		LD E,(HL)
		INC HL
		LD D,(HL)
		EX DE,HL
		CALL WDY
		IN A,(ZXDATRD)		;ПРИЕМ БИТОВ 31-24 ПАРАМЕТРА
		LD B,A
		CALL WDY
		IN A,(ZXDATRD)		;ПРИЕМ БИТОВ 23-16 ПАРАМЕТРА
		LD C,A
		CALL WDY
		IN A,(ZXDATRD)		;ПРИЕМ БИТОВ 15-8 ПАРАМЕТРА
		LD D,A
		CALL WDY
		IN A,(ZXDATRD)		;ПРИЕМ БИТОВ 7-0 ПАРАМЕТРА
		LD E,A
		CALL WDY
		IN A,(ZXDATRD)		;ПРИЕМ КОЛ-ВО СЕКТОРОВ
		JP (HL)

TABLSDG=$+_shift
		DW SDINITG		;0 ПАРАМЕТРОВ НЕ ТРЕБУЕТ, НА ВЫХОДЕ A
					;СМОТРИ ВЫШЕ ПЕРВЫЕ 2 ЗНАЧЕНИЯ
		DW SDCMPG		;1 ПРОВЕРКА НАЛИЧИЯ SD КАРТЫ
		DW RDMULG		;2 ЧИТАТЬ "A" СЕКТОРОВ
		DW WRMULG		;3 ПИСАТЬ "A" СЕКТОРОВ

SDCMPG=$+_shift
		LD A,CMD_58
		LD BC,SD_RSTR
		CALL OUT_COG
		CALL INOOUTG
		IN A,(C)
		NOP
		IN H,(C)
		NOP
		IN H,(C)
		NOP
		IN H,(C)
		INC A
		JP NZ,OK_WORK
		LD IYH,0X88			;КАРТА НЕ ПРОШЛА ПРОВЕРКУ НА НАЛИЧИЕ
		JP OK_WORK

ZAW003G		LD IYH,0XEE			;КАРТА НЕ ОБНАРУЖЕНА
		JP OK_WORK

SDINITG=$+_shift
		CALL CSHIGHG
		LD BC,SD_SEND
		LD DE,0X20FF
		OUT (C),E
		DEC D
		JR NZ,$-3
		LD BC,SD_RSTR
		XOR A
		EX AF,AF'
ZAW001G		LD HL,CMD00G
		CALL OUTCOMG
		CALL INOOUTG
		EX AF,AF'
		DEC A
		JR Z,ZAW003G
		EX AF,AF'
		DEC A
		JR NZ,ZAW001G
		LD HL,CMD08G
		CALL OUTCOMG
		CALL INOOUTG
		IN H,(C)
		NOP
		IN H,(C)
		NOP
		IN H,(C)
		NOP
		IN H,(C)
		LD HL,0
		BIT 2,A
		JR NZ,ZAW006G
		LD H,0X40
ZAW006G		LD A,CMD_55
		CALL OUT_COG
		CALL INOOUTG
		LD BC,SD_SEND
		LD A,ACMD_41
		OUT (C),A
		NOP
		OUT (C),H
		NOP
		OUT (C),L
		NOP
		OUT (C),L
		NOP
		OUT (C),L
		LD A,0XFF
		OUT (C),A
		CALL INOOUTG
		AND A
		JR NZ,ZAW006G
ZAW004G		LD A,CMD_59
		CALL OUT_COG
		CALL INOOUTG
		AND A
		JR NZ,ZAW004G
ZAW005G		LD HL,CMD16G
		CALL OUTCOMG
		CALL INOOUTG
		AND A
		JR NZ,ZAW005G
		JP OK_WORK

CSHIGHG=$+_shift
		PUSH AF
		LD A,M_SDNCS+M_SNCLR	;0X81
		OUT (SCTRL),A
		POP AF
		RET

CSLOWG=$+_shift
		PUSH AF
		LD A,M_SDNCS		;1
		OUT (SCTRL),A
		POP AF
		RET

OUTCOMG=$+_shift
		CALL CSLOWG
		PUSH BC
		LD BC,0X0600+SD_SEND
		OTIR
		POP BC
		RET

OUT_COG=$+_shift
		PUSH BC
		CALL CSLOWG
		LD BC,SD_SEND
		OUT (C),A
		XOR A
		OUT (C),A
		NOP
		OUT (C),A
		NOP
		OUT (C),A
		NOP
		OUT (C),A
		DEC A
		OUT (C),A
		POP BC
		RET

SECM20G=$+_shift
		PUSH HL
		PUSH DE
		PUSH BC
		PUSH AF
		PUSH BC
		LD A,CMD_58
		LD BC,SD_RSTR
		CALL OUT_COG
		CALL INOOUTG
		IN A,(C)
		NOP
		IN H,(C)
		NOP
		IN H,(C)
		NOP
		IN H,(C)
		INC A
		JR NZ,SECN20G1
		LD IYH,0X99			;КАРТА ПОТЕРЯЛАСЬ
SECN20G1	DEC A
		BIT 6,A
		POP HL
		JR NZ,SECN20G
		EX DE,HL
		ADD HL,HL
		EX DE,HL
		ADC HL,HL
		LD H,L
		LD L,D
		LD D,E
		LD E,0
SECN20G		POP AF
		LD BC,SD_SEND
		OUT (C),A
		NOP
		OUT (C),H
		NOP
		OUT (C),L
		NOP
		OUT (C),D
		NOP
		OUT (C),E
		LD A,0XFF
		OUT (C),A
		POP BC
		POP DE
		POP HL
		RET

INOOUTG=$+_shift
		PUSH DE
		LD DE,0X80FF
INWAITG		IN A,(SD_RSTR)
		CP E
		JR NZ,INEXITG
		DEC D
		JR NZ,INWAITG
INEXITG		POP DE
		RET

CMD00G=$+_shift
		DB 0X40,0X00,0X00,0X00,0X00,0X95	;GO_IDLE_STATE
CMD08G=$+_shift
		DB 0X48,0X00,0X00,0X01,0XAA,0X87	;SEND_IF_COND
CMD16G=$+_shift
		DB 0X50,0X00,0X00,0X02,0X00,0XFF	;SET_BLOCKEN

;ПЕРЕДАЧА ОДНОГО СЕКТОРА В SD КАРТУ
WRSECTG=$+_shift
		LD BC,SD_SEND
		OUT (SD_SEND),A
		IN A,(ZXSTAT)
		RRA
		JR NC,$-3
		OUT (CLRCBIT),A
		LD HL,0X0200
WRSECTG1	CALL WDY
		IN A,(ZXDATRD)
		DEC HL
		OUT (C),A
		LD A,H
		OR L
		JR NZ,WRSECTG1
		LD A,0XFF
		OUT (C),A
		NOP
		OUT (C),A
		RET

;ПЕРЕДАЧА ОДНОГО СЕКТОРА НА СПЕК
RDSECTG=$+_shift
		IN A,(ZXSTAT)
		RRA
		JR NC,$-3
		OUT (CLRCBIT),A
		LD BC,SD_RSTR
		LD HL,0X0200
RDSECTG1	IN A,(C)
		DEC HL
		OUT (ZXDATWR),A
		CALL WDN
		LD A,H
		OR L
		JR NZ,RDSECTG1
		IN A,(C)
		NOP
		IN A,(C)
		RET

;ЗАПИСЬ "A" СЕКТОРОВ
WRMULG=$+_shift
		EX AF,AF'
		LD A,CMD_25
		CALL SECM20G
		LD A,IYH
		CP 0X99
		JR Z,ERR_WR_LOST
WRMULG3		CALL INOOUTG
		INC A
		JR NZ,WRMULG3
		EX AF,AF'
WRMULG1		EX AF,AF'
		LD A,0XFC
		CALL WRSECTG
WRMULG2		CALL INOOUTG
		INC A
		JR NZ,WRMULG2
		EX AF,AF'
		DEC A
		JR NZ,WRMULG1
		LD C,SD_SEND
		LD A,0XFD
		OUT (C),A
		CALL INOOUTG
		INC A
		JR NZ,$-4
		JP OK_WORK

ERR_WR_LOST	LD BC,SD_SEND
		OUT (SD_SEND),A
		IN A,(ZXSTAT)
		RRA
		JR NC,$-3
		OUT (CLRCBIT),A
		LD HL,0X0200
ERRWRLOST1	CALL WDY
		IN A,(ZXDATRD)
		DEC HL
		LD A,H
		OR L
		JR NZ,ERRWRLOST1
		JP OK_WORK

ERR_RD_LOST     IN A,(ZXSTAT)
		RRA
		JR NC,$-3
		OUT (CLRCBIT),A
		LD BC,SD_RSTR
		LD HL,0X0200
ERRRDLOST1	XOR A
		OUT (ZXDATWR),A
		CALL WDN
		DEC HL
		LD A,H
		OR L
		JR NZ,ERRRDLOST1
		JP OK_WORK

;ЗАГРУЗКА "A" СЕКТОРОВ
RDMULG=$+_shift
		EX AF,AF'
		LD A,CMD_18
		CALL SECM20G
		LD A,IYH
		CP 0X99
		JR Z,ERR_RD_LOST
		EX AF,AF'
RDMULG1		EX AF,AF'
		CALL INOOUTG
		CP 0XFE
		JR NZ,$-5
RDMULG5		CALL RDSECTG
		EX AF,AF'
		DEC A
		JR NZ,RDMULG1
		LD A,CMD_12
		CALL OUT_COG
RDMULG3		CALL INOOUTG
		INC A
		JR NZ,RDMULG3

OK_WORK=$+_shift
		CALL CSHIGHG
		LD A,IYH
		POP IY

OUTSTAT=$+_shift
		OUT (ZXDATWR),A

;ОЖИДАНИЕ КОГДА СПЕК ЗАБЕРЕТ БАЙТ ДАННЫХ
WDN=$+_shift
		IN A,(ZXSTAT)
		RLA
		JR C,$-3
		RET

;ОЖИДАНИЕ КОГДА СПЕК ДАСТ БАЙТ ДАННЫХ
WDY=$+_shift
		IN A,(ZXSTAT)
		RLA
		JR NC,$-3
		RET
GSDDRVE=$+_shift
		;DEPHASE
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
;поэтому напишем много текста кириллицей
