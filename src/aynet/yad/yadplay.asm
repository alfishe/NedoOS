	
	MODULE 	BUF_RX
	PUBLIC	buf_rx
	RSEG	RXBUF
buf_rx:
	defs 1024*6
	ENDMOD
	
	MODULE 	INT_PLAY
	PUBLIC 	int_play
	RSEG	PLAYER
int_play:
	
	ret
	END
	