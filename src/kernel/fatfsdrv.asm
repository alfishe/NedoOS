;на входе ожидается pgstructs в c000. на выходе всегда ставить pgstructs

;/* Results of Disk Functions */
;typedef enum {
;	RES_OK = 0,		/* 0: Successful */
;	RES_ERROR,		/* 1: R/W Error */
;	RES_WRPRT,		/* 2: Write Protected */
;	RES_NOTRDY,		/* 3: Not Ready */
;	RES_PARERR		/* 4: Invalid Parameter */
;} DRESULT;
        
device_states
        db 1
        db 1
        db 1
        db 1
        db 1

disk_status:
        ld d,0
        ld hl,device_states
        add hl,de
		if INETDRV != 1
			ld a,(hl)
			ret
		else
			ld a,4
			cp e
			ld a,(hl)
			jr z,.isSL811
			ret
.isSL811
			or a
			ret nz
			ld bc,0x82ab
			in a,(c)
			and 0xaf		;хост-мод и сл811 в портах
			out (c),a	
			ld b,0x80
			ld a,0x0d
			out (c),a
			in a,(0xab)
			jr z,.resSL811
			and 0x40
			ret z
.resSL811
			ld a,1
			ld (hl),a
			ret
		endif
devices_init
;bc=?
;e=device number
;out: a=?
;        xor a
;        ld d,a
;	ld hl,device_states
;	add hl,de
;	cp (hl)
;	ret z
	push bc
	call disk_status
	pop hl
	or a
	ret z
	ld a,e ;a=e
	or a
	jr nz,devices_init_noIDEmaster
	ld a,0xe0
	call IDE_INIT
	ld (device_states+0),a
	ret  
devices_init_noIDEmaster
	dec a
	jr nz,devices_init_noIDEslave
	ld a,0xf0
	call IDE_INIT
	ld (device_states+1),a
	ret  
devices_init_noIDEslave
	dec a
	jr nz,devices_init_noSD
	ifdef KOE
	 ifdef KOEDI
		di
     endif
		call SD_INIT
	 ifdef KOEDI
		ei
     endif
	else
    if (atm==3) || (atm==1)
		call SD_INIT
    else
        ld a,1
    endif
	endif
	ld (device_states+2),a
	ret  
devices_init_noSD
	dec a
	jr nz,devices_init_noGS
	ifdef NGSSD
	call GS_INIT
        else
	ld a,1
        endif
	ld (device_states+3),a
	ret  
devices_init_noGS
	if INETDRV == 1
		dec a
		jr nz,devices_init_noSL811
		call SL811.init
		ld (device_states+4),a
		ret 
devices_init_noSL811
	endif
	ld a,0x01 ;нет такого устройства
	ret  

diskgetpars
	ld hl,(fatfs_org+FFS_DRV.lba_ptr)
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld hl,(fatfs_org+FFS_DRV.dma_addr)
	ld a,(fatfs_org+FFS_DRV.count)
	exa  
	ld a,(fatfs_org+FFS_DRV.dio_drv)
	;or a
;hl=buffer
;a=drive
;bcde=sector
;a'=count
	ret
        
;?????????????????????????????? чтение секторов
devices_read
	call BDOS_setdepage
	call devices_readnopg;devices_read_go
	push af
	call BDOS_setpgstructs
	pop af ;error
	ret
devices_readnopg
	;call BDOS_setpgstructs
	call diskgetpars
devices_read_go_regs
    ifdef KOEDI
		di
		call devices_read_go
		ei
		ret
devices_read_go
    endif
;hl=buffer
;a=drive
;bcde=sector
;a'=count
	 or a
	jr nz,readsectors_noIDEmaster
	ld a,0xe0 ;master ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp readsectorsIDE
readsectors_noIDEmaster
	dec a
	jr nz,readsectors_noIDEslave
	ld a,0xf0 ;slave ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp readsectorsIDE
readsectors_noIDEslave
	dec a
	jp z,readsectorsSD
	dec a
	jp z,readsectorsGS
	if INETDRV == 1
		dec a
		jp z,SL811.RBC_Read
	endif
	ld a,0x01
	ret  

;?????????????????????????????? запись секторов
devices_write
	call BDOS_setdepage
	call devices_writenopg;devices_write_go
        push af
	call BDOS_setpgstructs
	pop af ;error
	ret
devices_writenopg
	;call BDOS_setpgstructs
	call diskgetpars
devices_write_go_regs
    ifdef KOEDI
		di
		call devices_write_go
		ei
		ret
devices_write_go
    endif
;hl=buffer
;a=drive
;bcde=sector
;a'=count
         or a
	jr nz,writesectors_noIDEmaster
	ld a,0xe0 ;master ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp writesectorsIDE
writesectors_noIDEmaster
	dec a
	jr nz,writesectors_noIDEslave
	ld a,0xf0 ;slave ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp writesectorsIDE
writesectors_noIDEslave
	dec a
	jp z,writesectorsSD
	dec a
	jp z,writesectorsGS
	if INETDRV == 1
		dec a
		jp z,SL811.RBC_Write
	endif
	ld a,0x01
	ret  

;;;;;;;;;;;;;;;;;;;;;;;;;;; IDE
        
IDE_INIT
;a=device (0xe0/f0)
	push hl
	call readidentIDE
	pop hl
	and a
	ret nz
	;jp checkidentIDE
checkidentIDE
;зачем сохранять hl? TODO убрать
	push hl
	;ld d,h
	;ld e,l
	ex de,hl
	ld hl,0x0063
	add hl,de
	ld a,(hl)
	and 0x02
	jr z,ldaff_pophl
	;ld bc,0xff00+hddcount;????
	ld bc,hddcount
	ld hl,0x000c
	add hl,de
	ld a,(hl) ;0x3f???
	out (C),a
	ld hl,0x0006
	ld bc,hddhead
	add hl,de
	ld a,(hl)
	dec a ;0x0f???
	out (C),a
	ld bc,hddcmd
	ld a,0x91
	out (C),a
	ld de,0x1000
nobsywithtimeout0
	dec de
	ld a,d
	or e
	jr z,ldaff_pophl
	in a,(C)
	and 0x80
	jr nz,nobsywithtimeout0
	pop hl
	ret
ldaff_pophl
        ld a,0xff
	pop hl
	ret

readsectorsIDE
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count
    add a,b
	ld b,a
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count
	call setblockparsIDE
	exa  
	ld bc,hddcmd
	ld a,0x20
	out (C),a
	ld bc,hddstat
waitDRQ0
	in a,(C)
	and 0x88
	cp 0x08
	jr nz,waitDRQ0 ;ожидание готовности передачи данных
	exa  
readsectorsIDE0
	exa  
	call readsecIDE
	ld bc,hddstat
nobsy0
	in a,(C)
	and 0x80
	jr nz,nobsy0
	exa  
	dec a
	jr nz,readsectorsIDE0
	jr lda0

writesectorsIDE
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count
        add a,b
	ld b,a
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count
	call setblockparsIDE
	exa  
	ld bc,hddcmd
	ld a,0x30
	out (C),a
	ld bc,hddstat
waitDRQ01
	in a,(C)
	and 0x88
	cp 0x08
	jr nz,waitDRQ01 ;ожидание готовности передачи данных
	exa
writesectorsIDE0
	exa  
	call writesecIDE
	;inc h
	;inc h
	ld bc,hddstat
nobsy01
	in a,(C)
	and 0x80
	jr nz,nobsy01
	exa  
	dec a
	jr nz,writesectorsIDE0
lda0	
        xor a;ld a,0x00
	ret

readsecIDE
        ;jr $
        xor a;ld a,0
readsecIDE0
	ld bc,hdddatlo
	in e,(C)
	ld bc,hdddathi
	in d,(C)
	ld (hl),e
	inc hl
	ld (hl),d
	inc hl
	dec a
	jr nz,readsecIDE0
	ret
        
writesecIDE
        if (hdddatlo != 0x10)
        xor a
writesecIDE0
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        ld bc,hdddathi
        out (c),d
        ld bc,hdddatlo
        out (c),e
        dec a
	jr nz,writesecIDE0
        else
        ld bc,0x0000 + hdddathi
writesecIDE0
        ld a,(hl)
        inc hl
        outi
        out (hdddatlo),a
        ld a,(hl)
        inc hl
        outi
        out (hdddatlo),a
        ld a,(hl)
        inc hl
        outi
        out (hdddatlo),a
        ld a,(hl)
        inc hl
        outi
        out (hdddatlo),a
	jr nz,writesecIDE0
        endif
	ret
        
setblockparsIDE
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
        push de
	ld d,b
	ld e,c
	;ld bc,0xff00+hddhead ;зачем ff???
        ld bc,hddhead
	out (C),d ;head
	ld bc,hddstat
nobsy02
	in a,(C)
	and 0x80
	jr nz,nobsy02
	ld bc,hddcylhi
	out (C),e ;cylHI
	pop de
	ld bc,hddcyllo
	out (C),d ;cylLo
	ld bc,hddsec
	out (C),e ;sec
	ld bc,hddcount
	exa  
	out (C),a ;count
	ret
        
readidentIDE
	;ld bc,0xff00+hddhead ;зачем ff???
	;потому что неучаствующие биты в единице обычно
        ld bc,hddhead
	out (C),a
	ld bc,hddstat
	ld d,0x1a
LL7c06	;ei  
	halt  
	;di  
	dec d
	jr z,ldaff
	in a,(C)
	bit 7,a
	jr nz,LL7c06
	and a
	jr z,ldaff
	inc a
	jr z,ldaff
	xor a
	ld bc,hddcylhi
	out (C),a
	ld bc,hddcyllo
	out (C),a
	ld a,0xec
	ld bc,hddcmd
	out (C),a
	ld bc,hddstat
LL7c29	in a,(C)
	and a
	jr z,ldaff
	inc a
	jr z,ldaff
	dec a
	rrca  
	jr c,LL7c3c
	rlca  
	and 0x88
	cp 0x08
	jr nz,LL7c29
LL7c3c	ld bc,hddcyllo
	in e,(C)
	ld bc,hddcylhi
	in d,(C)
	ld a,d
	or e
	jp z,readsecIDE
	ld hl,0xeb14 ;???
	sbc hl,de
	ld a,0x01
	ret z
ldaff	
        ld a,0xff
	ret  
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Z-Controller (SD-card) ;;;;;;;;;;;;;;;;

SD_INIT
        call cs_highSD ;включаем питание карты при снятом выборе
	ld bc,0x0057
	ld de,0x20ff
LL7c5d	out (C),e
	dec d
	jr nz,LL7c5d ;записываем в порт много единичек
	xor a
	exa  
LL7c64	ld hl,cmd00SD ;GO_IDLE_STATE ;команда сброса и перевода карты в SPI режим после включения питания
	call outcom_hlSD ;этой командой карточка переводится в режим SPI
	call read32byteswaitnoffSD
	exa  
	dec a
	jp z,errexitSD ;если карта 256 раз не ответила, то карты нет
	exa  
	dec a
	jr nz,LL7c64
	ld hl,cmd08SD ;SEND_IF_COND ;запрос поддерживаемых напряжений
	call outcom_hlSD
	call read32byteswaitnoffSD
	in h,(C)
	nop  
	in h,(C)
	nop  
	in h,(C)
	nop  
	in h,(C)
	ld hl,0
	bit 2,a
	jr nz,LL7c92
	ld h,0x40
LL7c92	ld a,0x77 ;запускаем процесс внутренней инициализации
	call outcom_zeroparsSD
	call read32byteswaitnoffSD
	ld a,0x69
	out (C),a ;бит 6 установлен для инициализации SDHC карты
	nop  
	out (C),h
	nop  
	out (C),l
	nop  
	out (C),l
	nop  
	out (C),l
	ld a,0xff
	out (C),a
	call read32byteswaitnoffSD ;ждем перевода карты в режим готовности
	and a ;время ожидания примерно 1 секунда
	jr nz,LL7c92
LL7cb4	ld a,0x7b ;принудительно отключаем CRC16
	call outcom_zeroparsSD
	call read32byteswaitnoffSD
	and a
	jr nz,LL7cb4
LL7cbf	ld hl,cmd16SD ;SET_BLOCKEN ;команда изменения размера блока
	call outcom_hlSD ;принудительно задаем размер блока 512 байт
	call read32byteswaitnoffSD
	and a
	jr nz,LL7cbf
	
	;запомним размер блока
	ld a,0x7a ;READ_OCR
	ld bc,0x0057
	call outcom_zeroparsSD
	call read32byteswaitnoffSD
	in a,(C)
	nop  
	in h,(C)
	nop  
	in h,(C)
	nop  
	in h,(C)
	and 0x40
	ld (zsd_blsize),a
	
;включение питания карты при снятом сигнале выбора карты 
cs_highSD
        push af
	ld a,0x03
	ld bc,0x8057
	out (C),a ;включаем питание, снимаем выбор карты
	xor a
	dec b
	out (C),a ;обнуляем порт данных
;обнуление порта можно не делать, просто последний записанный бит всегда 1, а при сбросе через вывод данных карты напряжение попадает на вывод питания карты и светодиод на питании подсвечивается 
	pop af
	xor a;ld a,0x00
	ret  

errexitSD
        call SD_OFF
	ld a,0x03
	ret  

SD_OFF
        xor a
	ld bc,0x8057
	out (C),a ;выключение питания карты
	dec b
	out (C),a ;обнуление порта данных
	ret  

;выбираем карту сигналом 0
cs_lowSD
        push af
	ld a,0x01
	ld bc,0x8057
	out (C),a
	pop af
	ret  

;запись в карту команды с неизменяемым параметром из памяти
;адрес команды в HL
outcom_hlSD
        call cs_lowSD
	ld bc,0x0657
	otir  
	ret  

;запись в карту команды с нулевыми аргументами
;А=код команды, аргумент команды равен 0 
outcom_zeroparsSD
        call cs_lowSD
	ld bc,0x0057
	out (C),a
	xor a
	out (C),a
	nop  
	out (C),a
	nop  
	out (C),a
	nop  
	out (C),a
	dec a
	out (C),a
	ret  
zsd_blsize
        DEFB 0
;запись команды чтения/записи с номером сектора в BCDE для карт стандартного размера
;при изменяемом размере сектора номер сектора нужно умножать на его размер, для карт
;SDHC, мини и микро размер сектора не требует умножения
setcmdparsSD
        push hl
	push de
	push bc
	push af
;	push bc
;	ld a,0x7a ;READ_OCR
;	ld bc,0x0057
;	call outcom_zeroparsSD
;	call read32byteswaitnoffSD
;	in a,(C)
;	nop  
;	in h,(C)
;	nop  
;	in h,(C)
;	nop  
;	in h,(C)
;	bit 6,a ;проверяем 30 бит регистра OCR (6 бит в "А")
;	pop hl       ;при установленном бите умножение номера сектора
	ld h,b
	ld l,c
	call cs_lowSD
	ld bc,0x0057
	ld a,(zsd_blsize)
	or a
	jr nz,LL7d40 ;не требуется
	ex de,hl       ;при сброшенном бите соответственно
	add hl,hl ;умножаем номер сектора на 512 (0x200)
	ex de,hl  
	adc hl,hl
	ld h,l
	ld l,d
	ld d,e
	ld e,0x00
LL7d40	pop af ;заготовленный номер сектора находится в HLDE
	out (C),a ;команда
	nop  
	out (C),h ;;пишем номер сектора от старшего
	nop  
	out (C),l
	nop  
	out (C),d
	nop  
	out (C),e ;до младшего байта
	ld a,0xff
	out (C),a ;пишем пустой CRC7 и стоповый бит
	pop bc
	pop de
	pop hl
	ret
        
;чтение ответа карты до 32 раз, если ответ не 0xFF - немедленный выход 
read32byteswaitnoffSD
        push de
	ld de,0x20ff
	ld bc,0x0057
LL7d5e	in a,(C)
	cp e
	jr nz,LL7d66
	dec d
	jr nz,LL7d5e
LL7d66	pop de
	ret  

cmd00SD
;GO_IDLE_STATE
;команда сброса и перевода карты в SPI режим после включения питания
        db 0x40
        db 0x00
        db 0x00
        db 0x00
        db 0x00
        db 0x95
cmd08SD
;SEND_IF_COND
;запрос поддерживаемых напряжений 
        db 0x48
        db 0x00
        db 0x00
        db 0x01
        db 0xaa
        db 0x87
cmd16SD
;SET_BLOCKEN
;команда изменения размера блока 
        db 0x50
        db 0x00
        db 0x00
        db 0x02
        db 0x00
        db 0xff

readsecSDcard	
        push bc
	ld bc,0x7f57
	inir  
	ld b,0x7f
	inir  
	ld b,0x7f
	inir  
	ld b,0x7f
	inir  
	ld b,0x04
	inir  
	nop  
	in a,(C)
	nop  
	in a,(C)
	pop bc
	ret

writesecSDcard	
        push bc
	ld bc,0x0057
	out (C),a
	ld b,0x80
	otir  
	ld b,0x80
	otir  
	ld b,0x80
	otir  
	ld b,0x80
	otir  
	ld a,0xff
	out (C),a
	nop  
	out (C),a
	pop bc
	ret

readsectorsSD
        ld a,0x52
	call setcmdparsSD
	exa  
LL7dbd	exa  
LL7dbe	call read32byteswaitnoffSD
	cp 0xfe
	jr nz,LL7dbe
	call readsecSDcard
	exa  
	dec a
	jr nz,LL7dbd
	ld a,0x4c
	call outcom_zeroparsSD
readsectorsSD_q
	call read32byteswaitnoffSD_loopnoff
	jp cs_highSD

read32byteswaitnoffSD_loopnoff
	call read32byteswaitnoffSD
	inc a
	jr nz,read32byteswaitnoffSD_loopnoff
	ret

writesectorsSD
        ld a,0x59
	call setcmdparsSD
;LL7ddf	call read32byteswaitnoffSD
;	inc a
;	jr nz,LL7ddf
	call read32byteswaitnoffSD_loopnoff
	exa  
LL7de6	exa  
	ld a,0xfc
	call writesecSDcard
;LL7dec	call read32byteswaitnoffSD
;	inc a
;	jr nz,LL7dec
	call read32byteswaitnoffSD_loopnoff
	exa  
	dec a
	jr nz,LL7de6
	ld c,0x57
	ld a,0xfd
	out (C),a
;LL7dfc	call read32byteswaitnoffSD
;	inc a
;	jr nz,LL7dfc
	;call read32byteswaitnoffSD_loopnoff
	;jp cs_highSD
	jr readsectorsSD_q

    
        include "portsngs.asm"
        include "ngssddrv.asm"
    

get_fattime:
;de=buf
		if atm==1
			call readtime
		endif
        ld hl,sys_time_date
		ld bc,4
        ldir
        ret

	if INETDRV == 1
		include "sl811.asm"
	endif
