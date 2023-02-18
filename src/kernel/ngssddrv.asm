;кодировка 866
;опознаётся неправильно
;поэтому напишем много текста кириллицей
;LAST UPDATE: 30.06.2019 savelij

;АДРЕС ЦИКЛА ОБЩЕНИЯ СО СПЕКОМ
COMINT_		EQU 0X026E

_DEV_READ=2
_DEV_WRITE=3


;АДРЕС УСТАНОВЩИКА ДРАЙВЕРА НА NeoGS
SETUPSD		EQU 0X5B00

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
		IN A,(GSDAT)
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
		OUT (GSCOM),A	;FC
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
		IN A,(GSDAT)
		CP 0X99				;КАРТА ПОТЕРЯЛАСЬ ПО ВРЕМЯ ЧТЕНИЯ/ЗАПИСИ
		;JP Z,SD_CARD_LOST
		;LD BC,WIN_P6
		XOR A
		;OUT (C),A
		POP BC
		POP DE
		RET
		
		display "GS_INIT ",$
GS_INIT
        XOR A
        OUT (GSDAT),A
        ld a,0x23 ;Get number of RAM Pages
        OUT (GSCOM),A
        halt
        halt
        IN A,(GSDAT)
        inc a
        cp 3+1
        jr c,SD_NO ;не может быть <3 pages or 0xff pages
		
		;в еве драйвер уже установлен ЕРСом
		if atm != 1
        JP INSTSDD
		endif

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
		bit 6,a	;ждет ли команда данные
		jr z,SD_DRV_PRESENT
		pop af ;снимем со стека адрес возврата
		xor a
		JR SD_NO ;если команда не ждет данные, то считаем что драйвер не установлен
SD_DRV_PRESENT:
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

		if atm != 1
;УСТАНОВЩИК ДРАЙВЕРА НА NeoGS
INSTSDD
		LD BC,GSCFG0
		IN A,(C)
		CP 0xFF
		JP NZ,NEOGSINIT
;ИНИЦИАЛИЗАЦИЯ ОРИГИНАЛЬНОГО GS ПОКА НИЧЕГО НЕ ДЕЛАЕМ, 2МБ версия может резетится 10 секунд, нужно выждать перед повторным сбросом и после, перед следующими коммандами.
ORGGSINIT
;		LD A,0xF4
;		OUT (GSCOM),A			;ПОЛНЫЙ СБРОС GS
		JP SD_NO
;ИНИЦИАЛИЗАЦИЯ NeoGS
NEOGSINIT
		LD A,0X80
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
		JP GSDINIT

UKLAD1	;ОТКУДА КОД НА НГС ЗАКИДЫВАТЬ
	incbin "ngssd.bin"
	
		endif