	MODULE uart_delay1k
	PUBLIC uart_delay1k
	RSEG CODE
uart_delay1k:
		push de
		ld e, 0xFA
loop2:		
		NOP
		dec e
		jr nz,loop2
		pop de
		ret
	ENDMOD
	END
