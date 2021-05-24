	DEVICE ZXSPECTRUM128
;    include "ports_ngs.asm"
;    include "sdcomand.asm"
	ORG 0X5B00
START
COMINT_		EQU 0X026E      ;АДРЕС ЦИКЛА ОБЩЕНИЯ СО СПЕКОМ

SCTRL		EQU 0X11		; Serial ConTRoL: read-write, read:
				; current state of below bits, write - see GS_info
ZXDATWR		EQU 0X03		; write-only, ZX DATa WRite: a byte
				; written here is available for ZX in
				; GSDAT upon writing here, data bit is set
CLRCBIT		EQU 0X05		; read-write, upon either reading or
				; writing this port, the Command BIT is CLeaRed
GSCFG0		EQU 0X0F		; read-write, GS ConFiG port 0: acts as
				; memory cell, reads previously written
				; value. Bits and fields follow:
B_RAMRO		EQU 1		; =1 - ram absolute adresses 0X0000-7FFF
				; (zeroth big page) are write-protected
ZXDATRD		EQU 0X02		; read-only, ZX DATa ReaD: a byte
				; written by ZX into GSDAT appears here
				; upon reading this port, data bit is cleared
SD_RSTR		EQU 0X14		; SD card Read and STaRt, read-only,
				; reads previously received byte and
				; starts new byte transfer with 0XFF
SD_SEND		EQU 0X13		; SD card SEND, write-only, when
				; written, byte transfer starts with
				; written byte
ZXSTAT		EQU 0X04		; read-only, read ZX STATus: command and
				; data bits. positions are defined by
				; *_CBIT and *_DBIT above
M_SDNCS		EQU 1
M_SNCLR		EQU 0X80		; M_SETNCLR
;САМ УСТАНОВЩИК ДРАЙВЕРА ДЛЯ NeoGS
		DI
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
		DI
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

CMD_09		EQU 0X49	;SEND_CSD
CMD_12		EQU 0X4C	;STOP_TRANSMISSION
CMD_17		EQU 0X51	;READ_SINGLE_BLOCK
CMD_18		EQU 0X52	;READ_MULTIPLE_BLOCK
CMD_24		EQU 0X58	;WRITE_BLOCK
CMD_25		EQU 0X59	;WRITE_MULTIPLE_BLOCK
CMD_55		EQU 0X77	;APP_CMD
CMD_58		EQU 0X7A	;READ_OCR
CMD_59		EQU 0X7B	;CRC_ON_OFF
ACMD_41		EQU 0X69	;SD_SEND_OP_COND
		DISP 0X1D00

;ОБЩАЯ ТОЧКА ВХОДА ДЛЯ РАБОТЫ С SD КАРТОЙ
GSDDRV		DI
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

TABLSDG		DW SDINITG		;0 ПАРАМЕТРОВ НЕ ТРЕБУЕТ, НА ВЫХОДЕ A
					;СМОТРИ ВЫШЕ ПЕРВЫЕ 2 ЗНАЧЕНИЯ
		DW SDCMPG		;1 ПРОВЕРКА НАЛИЧИЯ SD КАРТЫ
		DW RDMULG		;2 ЧИТАТЬ "A" СЕКТОРОВ
		DW WRMULG		;3 ПИСАТЬ "A" СЕКТОРОВ

SDCMPG
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

ZAW003G		LD IYH,0XEE			;КАРТА НЕОБНАРУЖЕНА
		JP OK_WORK

SDINITG		CALL CSHIGHG
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

CSHIGHG		PUSH AF
		LD A,M_SDNCS+M_SNCLR	;0X81
		OUT (SCTRL),A
		POP AF
		RET

CSLOWG		PUSH AF
		LD A,M_SDNCS		;1
		OUT (SCTRL),A
		POP AF
		RET

OUTCOMG		CALL CSLOWG
		PUSH BC
		LD BC,0X0600+SD_SEND
		OTIR
		POP BC
		RET

OUT_COG		PUSH BC
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

SECM20G		PUSH HL
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

INOOUTG		PUSH DE
		LD DE,0X80FF
INWAITG		IN A,(SD_RSTR)
		CP E
		JR NZ,INEXITG
		DEC D
		JR NZ,INWAITG
INEXITG		POP DE
		RET

CMD00G		DB 0X40,0X00,0X00,0X00,0X00,0X95	;GO_IDLE_STATE
CMD08G		DB 0X48,0X00,0X00,0X01,0XAA,0X87	;SEND_IF_COND
CMD16G		DB 0X50,0X00,0X00,0X02,0X00,0XFF	;SET_BLOCKEN

;ПЕРЕДАЧА ОДНОГО СЕКТОРА В SD КАРТУ
WRSECTG		LD BC,SD_SEND
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
RDSECTG		IN A,(ZXSTAT)
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
WRMULG		EX AF,AF'
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
		JR OK_WORK

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

ERR_RD_LOST	IN A,(ZXSTAT)
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
RDMULG		EX AF,AF'
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

OK_WORK		CALL CSHIGHG
		LD A,IYH
		POP IY

OUTSTAT		OUT (ZXDATWR),A

;ОЖИДАНИЕ КОГДА СПЕК ЗАБЕРЕТ БАЙТ ДАННЫХ
WDN		IN A,(ZXSTAT)
		RLA
		JR C,$-3
		RET

;ОЖИДАНИЕ КОГДА СПЕК ДАСТ БАЙТ ДАННЫХ
WDY		IN A,(ZXSTAT)
		RLA
		JR NC,$-3
		RET
GSDDRVE
		ENT

ENDPROG
	SAVEBIN "ngssd.bin",START,ENDPROG-START

