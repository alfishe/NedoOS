	
	MODULE 	BUF_RX
	PUBLIC 	int_play, int_null
	PUBLIC	buf_rx, ptr_in_rx, ptr_out_rx, u32_intcount
	PUBLIC	msg_hello, msg_framesync
	PUBLIC	flag_play
	
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
	
int_play:
	ld a,1
	ld (flag_play),a
	
	ld bc,1
	ld hl,(u32_intcount)
	add hl,bc
	ld (u32_intcount),hl
	ld c,0
	ld hl,(u32_intcount+2)
	adc hl,bc
	ld (u32_intcount+2),hl
	
	
	
	ret
	
flag_play
	defs 1
msg_hello
	defb 0x00,7,'I','\'','M',' ','Y','A','D'
msg_framesync
	defb 0x01
u32_intcount
	defs 4
msg_syncrply
	defb 0x02,0x00,0x00,0x00,0x00
	END
	