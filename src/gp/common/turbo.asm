turnturbooff
	ld e,6+8 ;textmode + noturbo
	OS_SETGFX
	YIELD
	YIELD
	YIELD
	ret

turnturboon
	ld e,6 ;textmode
	OS_SETGFX
	ret
