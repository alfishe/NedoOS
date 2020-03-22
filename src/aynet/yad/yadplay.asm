	MODULE	SHUTUPMOD
	PUBLIC	shutup
	RSEG	PLAYER
shutup
	xor a
	ld d,0xff
	ld e,a
	ld c,0xfd
shutup_loop
	ld b,d
	out (c),a
	ld b,0xbf
	out (c),e
	inc a
	cp 14
	jr nz,shutup_loop
	ret
	ENDMOD
	
	MODULE	PTR_INCREMENT
	PUBLIC	ptr_increment
	EXTERN	ptr_in_rx, ptr_out_rx
	RSEG	CODE
ptr_increment: ;DE-count
	ld hl,(ptr_in_rx)
	push hl
	add hl,de
	res 4,h
	ld (ptr_in_rx),hl
	pop hl
	ld de,(ptr_out_rx)
	ld a,e
	or d
	ret nz
	ld (ptr_out_rx),hl
	ret
	ENDMOD
	
	MODULE 	BUF_RX
	PUBLIC 	int_play, int_null
	PUBLIC	buf_rx, ptr_in_rx, ptr_out_rx, u32_intcount
	PUBLIC	msg_hello, msg_framesync, syncreq
	PUBLIC	flag_int_change, flag_syncrply
	EXTERN	shutup
	RSEG	RXBUF
buf_rx:
	defs 1024*4

ptr_in_rx
	defs 2
ptr_out_rx
	defs 2
	

	RSEG	PLAYER
int_null:
	ret	;пустышка
	
play_exit
	ex de,hl
	ld (ptr_out_rx),de
	ld hl,(ptr_in_rx)
	xor a
	sbc hl,de
	ret nz
	ld h,a
	ld l,a
	ld (ptr_out_rx),hl
	ret
	
int_play:
	ld a,1
	ld (flag_int_change),a
	ld bc,1
	ld hl,(u32_intcount)
	add hl,bc
	ld (u32_intcount),hl
	ld c,0
	ld hl,(u32_intcount+2)
	adc hl,bc
	ld (u32_intcount+2),hl
	ld de,(ptr_out_rx)
	ld a,d
	or e
	ret z	;ничего нет
parse_loop
	ld a,(de)
	or a
	jr nz,not_shutup 
	ex de,hl
	inc hl
	res 4,h
	call shutup
	jr play_exit
not_shutup
	dec a
	jr nz,no_dump
	ld hl,(ptr_in_rx)
	or a
	sbc hl,de
	jr z,dump_full
	ld a,h
	and 0x0f
	ld h,a
	ld bc,15
	sbc hl,bc
	ret c
dump_full
	ex de,hl
	inc hl
	res 4,h
	ld a,(flag_syncrply)
	inc a
	ld (flag_syncrply),a
	xor a
	ld d,0xff
	ld e,0xbf + 1
	ld c,0xfd
dump_loop
	ld b,d
	out (c),a
	ld b,e
	outi
	res 4,h
	inc a
	cp 13
	jr nz,dump_loop
	ld b,d
	out (c),a
	ld a,(hl)
	inc hl
	res 4,h
	cp d
	jr z,play_exit
	ld b,0xbf
	out (c),a
	jp play_exit
no_dump
	dec a
	jp nz,0x0000	;нет такой команды. Что делать непонятно
syncreq
	ld hl,(ptr_in_rx)
	or a
	sbc hl,de
	jr z,sync_full
	ld a,h
	and 0x0f
	ld h,a
	ld bc,15+5
	sbc hl,bc
	ret c
sync_full
	ex de,hl
	inc hl
	res 4,h
	ld a,1
	ld (flag_syncrply),a
	ld de,msg_syncrply + 1
	ldi
	res 4,h
	ldi
	res 4,h
	ldi
	res 4,h
	ldi
	res 4,h
	ex de,hl
	jp parse_loop

	

flag_syncrply
	defb 0
flag_int_change
	defb 0
msg_hello
	defb 0x00,7,'I','\'','M',' ','Y','A','D',0x00
msg_framesync
	defb 0x01
u32_intcount
	defb 0,0,0,0
msg_syncrply
	defb 0x02,0x00,0x00,0x00,0x00
	END
	