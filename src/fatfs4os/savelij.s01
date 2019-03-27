MODULE SAVELIJ  ;15950
  PUBLIC disk_initialize
  PUBLIC disk_read
  PUBLIC disk_write
  PUBLIC disk_status
  EXTERN dio_par
  
  RSEG NEAR_Z

  RSEG CODE
		
ds_m:
        DEFB 1,1,1,1
		
disk_status:
        ld d,0
        ld hl,ds_m
        add hl,de
        ld a,(hl)
		ret
		
disk_initialize:
		call disk_status
        or a
        ret z
        ld h,b
        ld l,c
	LD A,e
	or a
	jr nz,di_l1
	call zsd_init
	ld (ds_m),a
	ret
di_l1	dec a
	jr nz,di_l2
	ld a,0xe0
	call nemo_init
	ld (ds_m+1),a
	ret
di_l2	dec a
	jr nz,di_l3
	ld a,0xf0
	call nemo_init
	ld (ds_m+2),a
	ret
di_l3	dec a
	jr nz,di_l4
	call GSDINIT
	ld (ds_m+3),a
	ret
di_l4	ld a,1
	ret

	
get_params
        ld hl,(dio_par+3)
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld c,(hl)
        inc hl
        ld b,(hl)
        ld hl,(dio_par+1)
        ld a,(dio_par+5)
        ex af,af
        ld a,(dio_par)
        or a
	ret
	
disk_read:
        call get_params
	jp z,zsd_read
	dec a
	jr nz,disk_read_nomaster
	ld a,$e0
	jp nemo_read
disk_read_nomaster
	dec a
	jr nz,disk_read_nonemo
	ld a,$f0
	jp nemo_read
disk_read_nonemo
	dec a
	jp z,SDRDMUL
	ld a,1
	ret
	
disk_write:
        call get_params
	jp z,zsd_write
	dec a
	jr nz,disk_write_nomaster
	ld a,$e0
	jp nemo_write
disk_write_nomaster
	dec a
	jr nz,disk_write_nonemo
	ld a,$f0
	jp nemo_write
disk_write_nonemo
	dec a
	jp z,SDWRMUL
	ld a,1
	ret
;Входные параметры общие:
;HL-адрес загрузки в память
;BCDE-32-х битный номер сектора
;A-количество блоков (блок=512 байт)
;только для многоблочной записи/чтении

P_1F7	EQU 0xF0			;РЕГИСТР СОСТОЯНИЯ/РЕГИСТР КОМАНД
P_1F6	EQU 0xD0			;CHS-НОМЕР ГОЛОВЫ И УСТР/LBA АДРЕС 24-27
P_1F5	EQU 0xB0			;CHS-ЦИЛИНДР 8-15/LBA АДРЕС 16-23
P_1F4	EQU 0x90			;CHS-ЦИЛИНДР 0-7/LBA АДРЕС 8-15
P_1F3	EQU 0x70			;CHS-НОМЕР СЕКТОРА/LBA АДРЕС 0-7
P_1F2	EQU 0x50			;СЧЕТЧИК СЕКТОРОВ
P_1F1	EQU 0x30			;ПОРТ ОШИБОК/СВОЙСТВ
P_1F0	EQU 0x10			;ПОРТ ДАННЫХ
P_3F6	EQU 0xC8			;РЕГИСТР СОСТОЯНИЯ/УПРАВЛЕНИЯ
P_HI	EQU 0x11			;СТАРШИЕ 8 БИТ
PRT_RW	EQU P_1F0*256+P_HI	;ПОРТЫ ЧТЕНИЯ/ЗАПИСИ ОДНИМ СЛОВОМ

;НА ВЫХОДЕ:
;H-ДЛЯ MASTER 0-HDD, 1-CDROM, 0xFF-NONE
;L-ДЛЯ SLAVE  0-HDD, 1-CDROM, 0xFF-NONE
nemo_init:
		PUSH HL
		CALL ID_DEV
		POP HL
		AND A
		CALL Z,INIT_91
nemo_off:
		RET

INIT_91:
		PUSH HL
		ld d,h
		ld e,l
		LD hl,49*2+1
		add hl,de
		LD A,(HL)
		AND 2
		JR Z,INI_912
		LD BC,0xFF00+P_1F2
		LD hl,0x0C
		add hl,de
		LD A,(HL)
		OUT (C),A
		LD hl,6
		LD C,P_1F6
		add hl,de
		LD A,(HL)
		DEC A
		OUT (C),A
		LD C,P_1F7
		LD A,0x91
		OUT (C),A
		LD DE,0x1000
INI_911:
		DEC DE
		LD A,D
		OR E
		JR Z,INI_912
		IN A,(C)
		AND 0x80
		JR NZ,INI_911
		POP HL
		RET

INI_912:
		LD A,0xFF
		POP HL
		RET

;READ "A" SECTORS HDD
nemo_read:        
	        add a,b
	        ld b,a
		CALL SETHREG
		EX AF,AF
		LD C,0xf0
		LD A,0x20
		OUT (C),A
		LD C,0xf0
HDDRD1:
		IN A,(C)
		AND 0x88
		CP 8
		JR NZ,HDDRD1
		EX AF,AF
HDDRD2:
		EX AF,AF
		CALL READSEC
		LD C,0xf0
HDDRD3:	
		IN A,(C)
		AND 0x80
		JR NZ,HDDRD3
		EX AF,AF
		DEC A
		JR NZ,HDDRD2
		JR EXITNHD

;WRITE "A" SECTORS HDD
nemo_write:
	        add a,b
	        ld b,a
		CALL SETHREG
		EX AF,AF
		LD C,P_1F7
		LD A,0x30
		OUT (C),A
		LD C,P_1F7
HDDWR1:	
		IN A,(C)
		AND 0x88
		CP 8
		JR NZ,HDDWR1
		EX AF,AF
HDDWR2:	
                
		EX AF,AF
		CALL WRITSEC
		inc h
		inc h
		LD C,P_1F7
HDDWR3:	
		IN A,(C)
		AND 0x80
		JR NZ,HDDWR3
		EX AF,AF
		DEC A
		JR NZ,HDDWR2
EXITNHD:
		ld a,0
		RET

;READ SECTOR (512 BYTES)
READSEC:
		LD A,0x40
		LD C,P_1F0	;HI
READSC1:
		IN E,(C)
		INC C
		IN D,(C)
		DEC C
		LD (HL),E
		INC HL
		LD (HL),D
		INC HL
		IN E,(C)
		INC C
		IN D,(C)
		DEC C
		LD (HL),E
		INC HL
		LD (HL),D
		INC HL
		IN E,(C)
		INC C
		IN D,(C)
		DEC C
		LD (HL),E
		INC HL
		LD (HL),D
		INC HL
		IN E,(C)
		INC C
		IN D,(C)
		DEC C
		LD (HL),E
		INC HL
		LD (HL),D
		INC HL
		DEC A
		JR NZ,READSC1
		RET

;SAVE SECTOR (512 BYTES)
WRITSEC:
		PUSH HL
		LD (WR_SEC_SP+1),SP
		LD SP,HL
		LD A,0x40
		LD HL,PRT_RW
WR_SEC1:
		POP DE
		LD C,L
		OUT (C),D
		LD C,H
		OUT (C),E
		POP DE
		LD C,L
		OUT (C),D
		LD C,H
		OUT (C),E
		POP DE
		LD C,L
		OUT (C),D
		LD C,H
		OUT (C),E
		POP DE
		LD C,L
		OUT (C),D
		LD C,H
		OUT (C),E
		DEC A
		JR NZ,WR_SEC1
WR_SEC_SP	LD SP,0
		POP HL
		RET

;SET HDD PORTS
SETHREG:
		PUSH DE
		LD D,B
		LD E,C
		LD BC,0xffd0
		OUT (C),D
		LD C,0xf0
SETHRE1:
		IN A,(C)
		AND 0x80
		JR NZ,SETHRE1
		LD C,0xb0
		OUT (C),E
		POP DE
		LD C,0x90
		OUT (C),D
		LD C,0x70
		OUT (C),E
		LD C,0x50
		EX AF,AF
		OUT (C),A
		RET

;HL-АДРЕС БУФЕРА СЕКТОРА ИДЕНТИФИКАЦИИ
;A=E0-ДЛЯ MASTER, A=F0-ДЛЯ SLAVE
ID_DEV:
		LD BC,0xFF00+P_1F6
		OUT (C),A
		LD C,P_1F7
		LD D,26
ID_DEV3:
		HALT
		DEC D
		JR Z,NO_DEV
		IN A,(C)
		BIT 7,A
		JR NZ,ID_DEV3
		AND A
		JR Z,NO_DEV
		INC A
		JR Z,NO_DEV
		XOR A
		LD C,P_1F5
		OUT (C),A
		LD C,P_1F4
		OUT (C),A
		LD A,0xEC
		LD C,P_1F7
		OUT (C),A
		LD C,P_1F7
ID_DEV1:
		IN A,(C)
		AND A
		JR Z,NO_DEV
		INC A
		JR Z,NO_DEV
		DEC A
		RRCA
		JR C,ID_DEV2
		RLCA
		AND 0x88
		CP 8
		JR NZ,ID_DEV1
ID_DEV2:
		LD C,P_1F4
		IN E,(C)
		LD C,P_1F5
		IN D,(C)
		LD A,D
		OR E
		JP Z,READSEC
		LD HL,0xEB14
		SBC HL,DE
		LD A,1
		RET Z
NO_DEV:
		LD A,0xFF
		RET


;Драйвер SD карты
;LAST UPDATE 14.04.2009 savelij
;Входные параметры общие:
;HL-адрес загрузки в память
;BCDE-32-х битный номер сектора
;A-количество блоков (блок=512 байт) - только для многоблочной записи/чтения
;Ошибки выдаваемые на выходе:
;A=0 - инициализация прошла успешно
;A=1 - карта не найдена или не ответила
;A=2 - карта защищена от записи
;A=3 - попытка записи в сектор 0 карты
P_DATA    EQU 0x0057    ;порт данных
P_CONF    EQU 0x8057    ;порт конфигурации
CMD_12    EQU 0x4C    ;STOP_TRANSMISSION
CMD_17    EQU 0x51    ;READ_SINGLE_BLOCK
CMD_18    EQU 0x52    ;READ_MULTIPLE_BLOCK
CMD_24    EQU 0x58    ;WRITE_BLOCK
CMD_25    EQU 0x59    ;WRITE_MULTIPLE_BLOCK
CMD_55    EQU 0x77    ;APP_CMD
CMD_58    EQU 0x7A    ;READ_OCR
CMD_59    EQU 0x7B    ;CRC_ON_OFF
ACMD_41   EQU 0x69   ;SD_SEND_OP_COND

zsd_init
    CALL CS_HIGH    ;включаем питание карты при снятом выборе
    LD BC,P_DATA
    LD DE,0x20FF    ;бит выбора карты в <1>
SD_INITloop
    OUT (C),E    ;записываем в порт много единичек
    DEC D    ;количество единичек несколько больше
    JR NZ,SD_INITloop    ;чем надо
    XOR A    ;запускаем счетчик на 256
    EX AF,AF    ;для ожидания инициализации карты
ZAW001    
    LD HL,CMD00    ;даем команду сброса
    CALL OUTCOM    ;этой командой карточка переводится в режим SPI
    CALL IN_OOUT    ;читаем ответ карты
    EX AF,AF
    DEC A
    JR Z,ZAW003    ;если карта 256 раз не ответила, то карты нет
    EX AF,AF
    DEC A
    JR NZ,ZAW001    ;ответ карты <1>, перевод в SPI прошел успешно
    LD HL,CMD08    ;запрос на поддерживаемые напряжения
    CALL OUTCOM    ;команда поддерживается начиная со спецификации
    CALL IN_OOUT    ;версии 2.0 и только SDHC, мини и микро SD картами
    IN H,(C)    ;в A=код ответа карты
    NOP    ;считываем 4 байта длинного ответа
    IN H,(C)    ;но не используем
    NOP
    IN H,(C)
    NOP
    IN H,(C)
    LD HL,0    ;HL=аргумент для команды инициализации
    BIT 2,A    ;если бит 2 установлен, то карта стандартная
    JR NZ,ZAW006    ;стандартная карта выдаст <ошибка команды>
    LD H,0x40    ;если ошибки не было, то карта SDHC, мини или микро SD
ZAW006    
    LD A,CMD_55    ;запускаем процесс внутренней инициализации
    CALL OUT_COM    ;для карт MMC здесь должна быть другая команда
    CALL IN_OOUT    ;соответственно наличие в слоте MMC-карты
    LD A,ACMD_41    ;вызовет зависание драйвера, от применения
    OUT (C),A    ;общей команды запуска инициализации я отказался
    NOP    ;бит 6 установлен для инициализации SDHC карты
    OUT (C),H    ;для стандартной сброшен
    NOP
    OUT (C),L
    NOP
    OUT (C),L
    NOP
    OUT (C),L
    LD A,0xFF
    OUT (C),A
    CALL IN_OOUT    ;ждем перевода карты в режим готовности
    AND A    ;время ожидания примерно 1 секунда
    JR NZ,ZAW006
ZAW004    LD A,CMD_59    ;принудительно отключаем CRC16
    CALL OUT_COM
    CALL IN_OOUT
    AND A
    JR NZ,ZAW004
ZAW005    LD HL,CMD16    ;принудительно задаем размер блока 512 байт
    CALL OUTCOM
    CALL IN_OOUT
    AND A
    JR NZ,ZAW005
;включение питания карты при снятом сигнале выбора карты
CS_HIGH    
    PUSH AF
    LD A,3
    ld bc,P_CONF
    OUT (c),A    ;включаем питание, снимаем выбор карты
    XOR A
    dec b	; P_DATA
    OUT (c),A    ;обнуляем порт данных
    POP AF    ;обнуление порта можно не делать, просто последний
    ld a,0
    RET    ;записанный бит всегда 1, а при сбросе через вывод
        ;данных карты напряжение попадает на вывод питания
        ;карты и светодиод на питании подсвечивается
;возврат при не ответе карты с кодом ошибки 1
ZAW003    
    CALL zsd_off
    ld a,3
    RET
zsd_off    ;patch
    XOR A
	ld bc,P_CONF
    OUT (c),A    ;выключение питания карты
	dec b		;P_DATA
    OUT (c),A    ;обнуление порта данных
    RET
;выбираем карту сигналом 0
CS__LOW    ;patch
    PUSH AF
    LD A,1
	ld bc,P_CONF
    OUT (c),A
    POP AF
    RET
;запись в карту команды с неизменяемым параметром из памяти
;адрес команды в <HL>
OUTCOM    ;patch
    CALL CS__LOW
    LD BC,0x600+P_DATA
    OTIR    ;передаем 6 байт команды из памяти
    RET
;запись в карту команды с нулевыми аргументами
;А-код команды, аргумент команды равен 0
OUT_COM    ;patch
    CALL CS__LOW
    LD BC,P_DATA
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
    OUT (C),A    ;пишем пустой CRC7 и стоповый бит
    RET
;запись команды чтения/записи с номером сектора в BCDE для карт стандартного размера
;при изменяемом размере сектора номер сектора нужно умножать на его размер, для карт 
;SDHC, мини и микро размер сектора не требует умножения
SECM200    PUSH HL  ;patch
    PUSH DE
    PUSH BC
    PUSH AF
    PUSH BC
    LD A,CMD_58
    LD BC,P_DATA
    CALL OUT_COM
    CALL IN_OOUT
    IN A,(C)
    NOP
    IN H,(C)
    NOP
    IN H,(C)
    NOP
    IN H,(C)
    BIT 6,A    ;проверяем 30 бит регистра OCR (6 бит в <А>)        
    POP HL    ;при установленном бите умножение номера сектора
    JR NZ,SECN200    ;не требуется
    EX DE,HL    ;при сброшенном бите соответственно
    ADD HL,HL    ;умножаем номер сектора на 512 (0x200)
    EX DE,HL
    ADC HL,HL
    LD H,L
    LD L,D
    LD D,E
    LD E,0
SECN200    
    POP AF    ;заготовленный номер сектора находится в <HLDE>
    OUT (C),A    ;пишем команду из <А> на SD карту
    NOP    ;записываем 4 байта аргумента
    OUT (C),H    ;пишем номер сектора от старшего
    NOP
    OUT (C),L
    NOP
    OUT (C),D
    NOP
    OUT (C),E    ;до младшего байта
    LD A,0xFF
    OUT (C),A    ;пишем пустой CRC7 и стоповый бит
    POP BC
    POP DE
    POP HL
    RET
;чтение ответа карты до 32 раз, если ответ не 0xFF - немедленный выход
IN_OOUT    ;patch
    push de
    LD DE,0x20FF
	ld bc,P_DATA
IN_WAIT    IN A,(c)
    CP E
    JR NZ,IN_EXIT
IN_NEXT    DEC D
    JR NZ,IN_WAIT
IN_EXIT    POP DE
    RET
CMD00    DEFB  0x40,0x00,0x00,0x00,0x00,0x95 ;GO_IDLE_STATE
    ;команда сброса и перевода карты в SPI режим после включения питания
CMD08    DEFB  0x48,0x00,0x00,0x01,0xAA,0x87 ;SEND_IF_COND
    ;запрос поддерживаемых напряжений
CMD16    DEFB 0x50,0x00,0x00,0x02,0x00,0xFF ;SET_BLOCKEN
    ;команда изменения размера блока
;читаем один сектор из карты в память, адрес чтения в <HL>
RD_SECT    PUSH BC
    LD BC,P_DATA+0x7F00
    INIR
    LD B,0x7F
    INIR
    LD B,0x7F
    INIR
    LD B,0x7F
    INIR
    LD B,0x04
    INIR
    NOP
    IN A,(C)
    NOP
    IN A,(C)
    POP BC
    RET
;записываем один сектор из памяти в карту, адрес записи в <HL>
WR_SECT    PUSH BC
    LD BC,P_DATA
    OUT (C),A
    LD B,0x80
    OTIR
    LD B,0x80
    OTIR
    LD B,0x80
    OTIR
    LD B,0x80
    OTIR
    LD A,0xFF
    OUT (C),A
    NOP
    OUT (C),A
    POP BC
    RET
;многосекторное чтение
zsd_read ld a,1
    out (0xbf),a
    LD A,CMD_18
    CALL SECM200    ;даем команду многосекторного чтения
    EX AF,AF
RDMULT1    EX AF,AF
RDMULT2
    CALL IN_OOUT
    CP 0xFE
    JR NZ,RDMULT2    ;ждем маркер готовности 0xFE для начала чтения
    CALL RD_SECT    ;читаем сектор
    EX AF,AF
    DEC A
    JR NZ,RDMULT1    ;продолжаем пока не обнулится счетчик
    LD A,CMD_12    ;по окончании чтения даем команду карте <СТОП>
    CALL OUT_COM    ;команда мультичтения не имеет счетчика и
RDMULT3
    CALL IN_OOUT    ;должна останавливаться здесь командой 12
    INC A
    JR NZ,RDMULT3    ;ждем освобождения карты
    JP CS_HIGH    ;снимаем выбор с карты и выходим с кодом 0

;многосекторная запись
zsd_write ld a,1
    out (0xbf),a
    LD A,CMD_25 ;даем команду мультисекторной записи
    CALL SECM200
WRMULTI2
    CALL IN_OOUT
    INC A
    JR NZ,WRMULTI2 ;ждем освобождения карты
    EX AF,AF
WRMULT1 EX AF,AF
    LD A,0xFC ;пишем стартовый маркер, сам блок и пустое CRC16
    CALL WR_SECT
WRMULTI3
    CALL IN_OOUT
    INC A
    JR NZ,WRMULTI3 ;ждем освобождения карты
    EX AF,AF
    DEC A
    JR NZ,WRMULT1 ;продолжаем пока счетчик не обнулится
    LD C,P_DATA
    LD A,0xFD
    OUT (C),A ;даем команду остановки записи
WRMULTI4
    CALL IN_OOUT
    INC A
    JR NZ,WRMULTI4 ;ждем освобождения карты
    JP CS_HIGH ;снимаем выбор карты и выходим с кодом 0
    
    
;------------------------------------------------------
;---------------------------=NeoGS=--------------------
;------------------------------------------------------



GSCOM		EQU 0XBB	; write-only, command for NGS
GSDAT		EQU 0XB3	; read-write
GSCTR		EQU 0X33	; write-only, control register for NGS:
;АДРЕС УСТАНОВЩИКА ДРАЙВЕРА НА NeoGS
SETUPSD		EQU 0x5B00

;NGSSDT		DEFW GSDINIT		;ИНИТ SD КАРТЫ
;		DEFW GSDOFF		;ОТКЛЮЧЕНИЕ SD КАРТЫ
;		DEFW SDRDSIN		;ЧИТАТЬ 1 СЕКТОР
;		DEFW SDRDMUL		;ЧИТАТЬ "A" СЕКТОРОВ
;		DEFW SDWRSIN		;ПИСАТЬ 1 СЕКТОР
;		DEFW SDWRMUL		;ПИСАТЬ "A" СЕКТОРОВ

;ЗАПИСЬ "A" СЕКТОРОВ
SDWRMUL		LD A,5
SDWRSN3		CALL COMM2SD
		EX AF,AF
		PUSH DE
		PUSH BC
		LD BC,GSDAT
SDWRSN1		EX AF,AF
		OUT (GSCOM),A
		CALL WC_
		LD DE,0x0200
SDWRSN2		OUTI
		CALL WD_
		DEC DE
		LD A,D
		OR E
		JR NZ,SDWRSN2
		EX AF,AF
		DEC A
		JR NZ,SDWRSN1
		CALL WN_
		IN A,(C)
		CP 0x77
		JR NZ,$-4
		POP BC
		POP DE
		XOR A
		RET

;ЧТЕНИЕ "A" СЕКТОРОВ
SDRDMUL		LD A,3
SDRDSN3		CALL COMM2SD
		EX AF,AF
		PUSH DE
		PUSH BC
		LD BC,GSDAT
SDRDSN1		EX AF,AF
		OUT (GSCOM),A
		CALL WC_
		LD DE,0x0200
SDRDSN2		CALL WN_
		INI
		DEC DE
		LD A,D
		OR E
		JR NZ,SDRDSN2
		EX AF,AF
		DEC A
		JR NZ,SDRDSN1
		CALL WN_
		IN A,(C)
		CP 0x77
		JR NZ,$-4
		POP BC
		POP DE
		XOR A
		RET

;ОТКЛЮЧЕНИЕ ВЫБОРА КАРТОЧКИ
GSDOFF		LD A,1
		JR GSDINIT+1

;ИНИЦИАЛИЗАЦИЯ КАРТОЧКИ
GSDINIT		CALL INSTSDD
                OR A
                RET NZ
                XOR A
		CALL COMM2SD
		CALL WN_
		IN A,(GSDAT)
		CP 0x77
		JR NZ,SD_NO
		XOR A
		RET

SD_NO		LD A,1
		RET

;ПЕРЕДАТЧИК КОМАНД/ПАРАМЕТРОВ В ДРАЙВЕР НА NeoGS
COMM2SD		OUT (GSDAT),A			;УШЛА КОМАНДА ДРАЙВЕРУ
	        LD A,0x1E
	        OUT (GSCOM),A
	        CALL WC_			;УШЛА КОМАНДА ПРОШИВКЕ
		LD A,B
		OUT (GSDAT),A
		CALL WD_			;УШЛИ БИТЫ 31-24 ПАРАМЕТРОВ
		LD A,C
		OUT (GSDAT),A
		CALL WD_			;УШЛИ БИТЫ 23-16 ПАРАМЕТРОВ
		LD A,D
		OUT (GSDAT),A
		CALL WD_			;УШЛИ БИТЫ 15-8 ПАРАМЕТРОВ
		LD A,E
		OUT (GSDAT),A
		CALL WD_			;УШЛИ БИТЫ 7-0 ПАРАМЕТРОВ
		EX AF,AF
		OUT (GSDAT),A
		EX AF,AF
		DEFS 9
		RET				;УШЛО КОЛ-ВО СЕКТОРОВ

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
INSTSDD		LD A,0x80
		OUT (GSCTR),A
		HALT
		HALT
		LD A,0xF3
		LD B,0x30
		OUT (GSCOM),A
ISDD1	HALT
		DEC B
		JR Z,SD_NO
		IN A,(GSCOM)
		RRA
		JR C,ISDD1
		LD BC,GSDAT
		IN A,(C)
		LD DE,0x0300
		LD HL,SETUPSD
		OUT (C),E
		LD A,0x14
		OUT (GSCOM),A
		CALL WC_
		OUT (C),D
		CALL WD_
		OUT (C),L
		CALL WD_
		OUT (C),H
		CALL WD_
		LD HL,(0x0006)
ISDD3		OUTI
		CALL WD_
		DEC DE
		LD A,D
		OR E
		JR NZ,ISDD3
		LD HL,SETUPSD
		OUT (C),L
		LD A,0x13
		OUT (GSCOM),A
		CALL WC_
		OUT (C),H
		HALT
		HALT
		IN A,(GSDAT)
		CP 0x77
		JP NZ,SD_NO
		XOR A
		RET



ENDMOD
END


