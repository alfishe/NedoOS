	
	MODULE 	BUF_RX
	PUBLIC 	int_play, int_null, ptr_increment
	PUBLIC	buf_rx, ptr_in_rx, ptr_out_rx, u32_intcount
	PUBLIC	msg_hello, msg_framesync
	PUBLIC	flag_int_change, flag_syncrply
	
	RSEG	RXBUF
buf_rx:
	defs 1024*6

ptr_in_rx
	defs 2
ptr_out_rx
	defs 2
	

	RSEG	PLAYER
int_null:
	ret	;пустышка
	
play_exit
	ex de,hl
	ld hl,buf_rx+(1024*4)-1
	xor a
	sbc hl,de
	jr nc,no_out_over
	ld de,buf_rx
no_out_over
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
	ld hl,(ptr_out_rx)
	ld a,h
	or l
	ret z	;ничего нет
parse_loop
	ld a,(hl)
	inc hl
	inc a
	ret z	;маркер 0xFF, ничего нет
	dec a
	jr z,play_exit ;TODO SHUTUP пока нету
	dec a
	jr nz,no_dump
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
	inc a
	cp 13
	jr nz,dump_loop
	ld a,(hl)
	inc hl
	cp d
	jr z,play_exit
	dec hl
	ld b,d
	ld a,13
	out (c),a
	ld b,e
	outi
	jr play_exit
no_dump
	dec a
	jr nz,play_exit	;нет такой команды
syncreq
	ld a,1
	ld (flag_syncrply),a
	ld de,msg_syncrply + 1
	ldi
	ldi
	ldi
	ldi
	jr parse_loop
	
ptr_increment: ;DE-count
	ld hl,(ptr_in_rx)
	push hl
	add hl,de
	ex de,hl
	ld hl,buf_rx+(1024*4)-1
	xor a
	sbc hl,de
	jr nc,no_buf_over
	ld de,buf_rx
no_buf_over
	ld (ptr_in_rx),de
	dec a
	ld (de),a	;маркер конца 0xFF
	pop hl
	ld de,(ptr_out_rx)
	ld a,e
	or d
	ret nz
	ld (ptr_out_rx),hl
	ret

flag_syncrply
	defb 0
flag_int_change
	defs 0
msg_hello
	defb 0x00,7,'I','\'','M',' ','Y','A','D'
msg_framesync
	defb 0x01
u32_intcount
	defs 4
msg_syncrply
	defb 0x02,0x00,0x00,0x00,0x00
	END
	