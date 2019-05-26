        ;org #7a46
        
        if 1==1
;driver_curdrive=fatfs.tabl+20
;driver_curdmaaddr=driver_curdrive+1
;driver_curpblockpars=driver_curdmaaddr+2
;driver_curnsectors=driver_curpblockpars+2
;driver_tempword=#7a4c ;..7a4d
;driver_buf8=#7a4d
;driver_counter=#7a51
;device_states=#7a53
        
        else
        
driver_curdrive ;#7a46
        db #01
driver_curdmaaddr ;#7a47
        dw #4000
driver_curpblockpars ;#7a49
        dw 0
driver_curnsectors ;#7a4b
        db 0
driver_tempword ;??? #7a4c..7a4d
        db 0
driver_buf8 ;??? #7a4d
        ds 4
driver_counter ;??? #7a51
        dw 0
        
        endif
        
device_states ;#7a53
        db 1
        db 1
        db 1
        db 1
disk_status:
        ld d,0
        ld hl,device_states
        add hl,de
        ld a,(hl)
		ret
;???????????????????????? вызывается в #58cb
devices_init
        xor a
        ld d,a
	ld hl,device_states
	add hl,de
	cp (hl)
	ret z
	ld h,b
	ld l,c
	or e ;a=e
	jr nz,devices_init_noSD
        if atm==3
	call SD_INIT
        else
        ld a,1
        endif
	ld (device_states),a
	ret  
devices_init_noSD
	dec a
	jr nz,devices_init_noIDEmaster
	ld a,#e0
	call IDE_INIT
	ld (device_states+1),a
	ret  
devices_init_noIDEmaster
	dec a
	jr nz,devices_init_noIDEslave
	ld a,#f0
	call IDE_INIT
	ld (device_states+2),a
	ret  
devices_init_noIDEslave
	dec a
	jr nz,devices_init_noGS
	call GS_INIT
	ld (device_states+3),a
	ret  
devices_init_noGS
	ld a,#01 ;нет такого устройства
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
	or a
	ret
        
;?????????????????????????????? чтение секторов, вызывается из #443e
devices_read
	call diskgetpars
	jp z,readsectorsSD
	dec a
	jr nz,readsectors_noIDEmaster
	ld a,#e0 ;master ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp readsectorsIDE
readsectors_noIDEmaster
	dec a
	jr nz,readsectors_noIDEslave
	ld a,#f0 ;slave ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp readsectorsIDE
readsectors_noIDEslave
	dec a
	jp z,readsectorsGS
	ld a,#01
	ret  

;?????????????????????????????? запись секторов, вызывается из #4433
devices_write
	call diskgetpars
	jp z,writesectorsSD
	dec a
	jr nz,writesectors_noIDEmaster
	ld a,#e0 ;master ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp writesectorsIDE
writesectors_noIDEmaster
	dec a
	jr nz,writesectors_noIDEslave
	ld a,#f0 ;slave ;почему bit6=1???
;b+a=head+device
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	jp writesectorsIDE
writesectors_noIDEslave
	dec a
	jp z,writesectorsGS
	ld a,#01
	ret  

;;;;;;;;;;;;;;;;;;;;;;;;;;; IDE
        
IDE_INIT
;a=device (#e0/f0)
	push hl
	call readidentIDE
	pop hl
	and a
	ret nz
	;jp checkidentIDE
checkidentIDE
;зачем сохранять hl? TODO убрать
	push hl
	ld d,h
	ld e,l
	ld hl,#0063
	add hl,de
	ld a,(hl)
	and #02
	jr z,ldaff_pophl
	;ld bc,#ff00+hddcount;????
	ld bc,hddcount
	ld hl,#000c
	add hl,de
	ld a,(hl) ;#3f???
	out (C),a
	ld hl,#0006
	ld bc,hddhead
	add hl,de
	ld a,(hl)
	dec a ;#0f???
	out (C),a
	ld bc,hddcmd
	ld a,#91
	out (C),a
	ld de,#1000
nobsywithtimeout0
	dec de
	ld a,d
	or e
	jr z,ldaff_pophl
	in a,(C)
	and #80
	jr nz,nobsywithtimeout0
	pop hl
	ret  
ldaff_pophl	
        ld a,#ff
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
	ld a,#20
	out (C),a
	ld bc,hddstat
waitDRQ0
	in a,(C)
	and #88
	cp #08
	jr nz,waitDRQ0 ;ожидание готовности передачи данных
	exa  
readsectorsIDE0
	exa  
	call readsecIDE
	ld bc,hddstat
nobsy0
	in a,(C)
	and #80
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
	ld a,#30
	out (C),a
	ld bc,hddstat
waitDRQ01
	in a,(C)
	and #88
	cp #08
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
	and #80
	jr nz,nobsy01
	exa  
	dec a
	jr nz,writesectorsIDE0
lda0	
        xor a;ld a,#00
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
        ;jr $
        if (hdddatlo != #10)
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
        ld bc,#0000 + hdddathi
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
	;ld bc,#ff00+hddhead ;зачем ff???
        ld bc,hddhead
	out (C),d ;head
	ld bc,hddstat
nobsy02
	in a,(C)
	and #80
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
        ;jr $
	;ld bc,#ff00+hddhead ;зачем ff???
        ld bc,hddhead
	out (C),a
	ld bc,hddstat
	ld d,#1a
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
	ld a,#ec
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
	and #88
	cp #08
	jr nz,LL7c29
LL7c3c	ld bc,hddcyllo
	in e,(C)
	ld bc,hddcylhi
	in d,(C)
	ld a,d
	or e
	jp z,readsecIDE
	ld hl,#eb14 ;???
	sbc hl,de
	ld a,#01
	ret z
ldaff	
        ld a,#ff
	ret  
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Z-Controller (SD-card) ;;;;;;;;;;;;;;;;

SD_INIT
        call cs_highSD ;включаем питание карты при снятом выборе
	ld bc,#0057
	ld de,#20ff
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
	jr z,errexitSD ;если карта 256 раз не ответила, то карты нет
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
	ld h,#40
LL7c92	ld a,#77 ;запускаем процесс внутренней инициализации
	call outcom_zeroparsSD
	call read32byteswaitnoffSD
	ld a,#69
	out (C),a ;бит 6 установлен для инициализации SDHC карты
	nop  
	out (C),h
	nop  
	out (C),l
	nop  
	out (C),l
	nop  
	out (C),l
	ld a,#ff
	out (C),a
	call read32byteswaitnoffSD ;ждем перевода карты в режим готовности
	and a ;время ожидания примерно 1 секунда
	jr nz,LL7c92
LL7cb4	ld a,#7b ;принудительно отключаем CRC16
	call outcom_zeroparsSD
	call read32byteswaitnoffSD
	and a
	jr nz,LL7cb4
LL7cbf	ld hl,cmd16SD ;SET_BLOCKEN ;команда изменения размера блока
	call outcom_hlSD ;принудительно задаем размер блока 512 байт
	call read32byteswaitnoffSD
	and a
	jr nz,LL7cbf
;включение питания карты при снятом сигнале выбора карты 
cs_highSD
        push af
	ld a,#03
	ld bc,#8057
	out (C),a ;включаем питание, снимаем выбор карты
	xor a
	dec b
	out (C),a ;обнуляем порт данных
;обнуление порта можно не делать, просто последний записанный бит всегда 1, а при сбросе через вывод данных карты напряжение попадает на вывод питания карты и светодиод на питании подсвечивается 
	pop af
	xor a;ld a,#00
	ret  

errexitSD	
        call SD_OFF
	ld a,#03
	ret  

SD_OFF	
        xor a
	ld bc,#8057
	out (C),a ;выключение питания карты
	dec b
	out (C),a ;обнуление порта данных
	ret  

;выбираем карту сигналом 0
cs_lowSD	
        push af
	ld a,#01
	ld bc,#8057
	out (C),a
	pop af
	ret  

;запись в карту команды с неизменяемым параметром из памяти
;адрес команды в HL
outcom_hlSD
        call cs_lowSD
	ld bc,#0657
	otir  
	ret  

;запись в карту команды с нулевыми аргументами
;А=код команды, аргумент команды равен 0 
outcom_zeroparsSD
        call cs_lowSD
	ld bc,#0057
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

;запись команды чтения/записи с номером сектора в BCDE для карт стандартного размера
;при изменяемом размере сектора номер сектора нужно умножать на его размер, для карт
;SDHC, мини и микро размер сектора не требует умножения
setcmdparsSD
        push hl
	push de
	push bc
	push af
	push bc
	ld a,#7a ;READ_OCR
	ld bc,#0057
	call outcom_zeroparsSD
	call read32byteswaitnoffSD
	in a,(C)
	nop  
	in h,(C)
	nop  
	in h,(C)
	nop  
	in h,(C)
	bit 6,a ;проверяем 30 бит регистра OCR (6 бит в «А»)
	pop hl       ;при установленном бите умножение номера сектора
	jr nz,LL7d40 ;не требуется
	exd       ;при сброшенном бите соответственно
	add hl,hl ;умножаем номер сектора на 512 (#200)
	exd  
	adc hl,hl
	ld h,l
	ld l,d
	ld d,e
	ld e,#00
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
	ld a,#ff
	out (C),a ;пишем пустой CRC7 и стоповый бит
	pop bc
	pop de
	pop hl
	ret
        
;чтение ответа карты до 32 раз, если ответ не #FF - немедленный выход 
read32byteswaitnoffSD
        push de
	ld de,#20ff
	ld bc,#0057
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
        db #40
        db #00
        db #00
        db #00
        db #00
        db #95
cmd08SD
;SEND_IF_COND
;запрос поддерживаемых напряжений 
        db #48
        db #00
        db #00
        db #01
        db #aa
        db #87
cmd16SD
;SET_BLOCKEN
;команда изменения размера блока 
        db #50
        db #00
        db #00
        db #02
        db #00
        db #ff

readsecSDcard	
        push bc
	ld bc,#7f57
	inir  
	ld b,#7f
	inir  
	ld b,#7f
	inir  
	ld b,#7f
	inir  
	ld b,#04
	inir  
	nop  
	in a,(C)
	nop  
	in a,(C)
	pop bc
	ret

writesecSDcard	
        push bc
	ld bc,#0057
	out (C),a
	ld b,#80
	otir  
	ld b,#80
	otir  
	ld b,#80
	otir  
	ld b,#80
	otir  
	ld a,#ff
	out (C),a
	nop  
	out (C),a
	pop bc
	ret

readsectorsSD
        ld a,#52
	call setcmdparsSD
	exa  
LL7dbd	exa  
LL7dbe	call read32byteswaitnoffSD
	cp #fe
	jr nz,LL7dbe
	call readsecSDcard
	exa  
	dec a
	jr nz,LL7dbd
	ld a,#4c
	call outcom_zeroparsSD
LL7dd1	call read32byteswaitnoffSD
	inc a
	jr nz,LL7dd1
	jp cs_highSD

writesectorsSD	
        ld a,#59
	call setcmdparsSD
LL7ddf	call read32byteswaitnoffSD
	inc a
	jr nz,LL7ddf
	exa  
LL7de6	exa  
	ld a,#fc
	call writesecSDcard
LL7dec	call read32byteswaitnoffSD
	inc a
	jr nz,LL7dec
	exa  
	dec a
	jr nz,LL7de6
	ld c,#57
	ld a,#fd
	out (C),a
LL7dfc	call read32byteswaitnoffSD
	inc a
	jr nz,LL7dfc
	jp cs_highSD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;NeoGS
writesectorsGS
        ld a,#05
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	call setblockparsGS
	exa  
	push de
	push bc
	ld bc,#00b3
writesectorsGS0
	exa  
	out (#bb),a
	call loop_errGS
	ld de,#0200
writesecGS200
	outi  
	call no_bsyGS
	dec de
	ld a,d
	or e
	jr nz,writesecGS200
	exa  
	dec a
	jr nz,writesectorsGS0
	call wait_bsyGS
writesecGS_waitready0
	in a,(C)
	cp #77
	jr nz,writesecGS_waitready0 ;??? ожидаем непонятно чего
	pop bc
	pop de
	xor a
	ret
        
readsectorsGS
        ld a,#03
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	call setblockparsGS
	exa  
	push de
	push bc
	ld bc,#00b3
readsectorsGS0
	exa  
	out (#bb),a
	call loop_errGS
	ld de,#0200
readsecGS0
	call wait_bsyGS
	ini  
	dec de
	ld a,d
	or e
	jr nz,readsecGS0
	exa  
	dec a
	jr nz,readsectorsGS0
	call wait_bsyGS
readsecGS_waitready0
	in a,(C)
	cp #77
	jr nz,readsecGS_waitready0 ;??? ожидаем непонятно чего
	pop bc
	pop de
	xor a
	ret  

;??????? not used        
	db #3e,#01 ;ld a,#01
	db #18,#01 ;jr LL7e68
        
GS_INIT
        call writesecGS
	or a
	ret nz
	xor a
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
	call setblockparsGS
	call wait_bsyGS
	in a,(#b3)
	cp #77 ;какое-то состояние GS???
	jr nz,lda1
	xor a
	ret  
lda1	
        ld a,#01
	ret  

setblockparsGS	
;a=? 0/3/5
;b=head
;c=cylHI
;d=cylLO
;e=sec
;a'=count	
        out (#b3),a
	ld a,#1e
	out (#bb),a
	call loop_errGS
	ld a,b
	out (#b3),a
	call no_bsyGS
	ld a,c
	out (#b3),a
	call no_bsyGS
	ld a,d
	out (#b3),a
	call no_bsyGS
	ld a,e
	out (#b3),a
	call no_bsyGS
	exa  
	out (#b3),a
	exa  
	nop  
	nop  
	nop  
	nop  
	nop  
	nop  
	nop  
	nop  
	nop  
	ret

;ожидание освобождения устройства
no_bsyGS	
        in a,(#bb)
	rla  
	jr c,no_bsyGS
	ret  
wait_bsyGS	
        in a,(#bb)
	rla  
	jr nc,wait_bsyGS
	ret  
loop_errGS	
        in a,(#bb)
	rra  
	jr c,loop_errGS ;c=error???
	ret

writesecGS	
        ld a,#80
	out (#33),a
	;ei  
	halt  
	halt  
	;di  
	ld a,#f3
	ld b,#30 ;количество повторов (*1/50 с)
	out (#bb),a
waitGS0
        ;ei  
	halt  
	;di  
	dec b
	jr z,lda1
	in a,(#bb)
	rra  
	jr c,waitGS0
	ld bc,#00b3
	in a,(C)
	ld de,#0300
	ld hl,#5b00
	out (C),e
	ld a,#14
	out (#bb),a
	call loop_errGS
	out (C),d
	call no_bsyGS
	out (C),l
	call no_bsyGS
	out (C),h
	call no_bsyGS
	ld hl,(#0006)
writesecGS300	
        outi  
	call no_bsyGS
	dec de
	ld a,d
	or e
	jr nz,writesecGS300
	ld hl,#5b00
	out (C),l
	ld a,#13
	out (#bb),a
	call loop_errGS
	out (C),h
	;ei  
	halt  
	halt  
	;di  
	in a,(#b3)
	cp #77
	jp nz,lda1
	xor a
	ret  

get_fattime:
;de=buf
        ld hl,sys_time_date
        ldi
        ldi
        ldi
        ldi
        ret
sys_time_date
        ds 4

        if 1==0
;????????????????????????? адресуется в #549d
;список неподдерживаемых символов в имени файла, 0 конец
        db #22
        db #2a
        db #2b
        db #2c
        db #3a
        db #3b
        db #3c
        db #3d
        db #3e
        db #3f
        db #5b
        db #5d
        db #7c
        db #7f
        db 0
        endif
