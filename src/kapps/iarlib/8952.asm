	MODULE cmd2ve
	PUBLIC cmd2ve
	#include "sysdefs.asm"
	RSEG CODE
cmd2ve:	;e=command	 возвращаем результат в A
		di
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,e				;команда из E переноcим в B
		in	a,(c)			;выполнить команду
		pop bc
		ei
		ret
	ENDMOD
	
	MODULE send2ve
	PUBLIC send2ve
	#include "sysdefs.asm"
	RSEG CODE
send2ve:	;e=command b=data
		di
		ld d,c
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,e				;команда 
		IN	a,(c)
		ld	b,d				;Параметр
		in	a,(c)
		ei
		ret
	ENDMOD
	
	END
