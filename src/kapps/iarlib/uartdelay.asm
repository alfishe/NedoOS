	MODULE uart_delay1k
	PUBLIC uart_delay1k
	RSEG CODE
uart_delay1k:
		di
		push de
		ld e, 0xFA
loop2:		
		NOP
		dec e
		jr nz,loop2
		pop de
		ei
		ret
	ENDMOD
	END
