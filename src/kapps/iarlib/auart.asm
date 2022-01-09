	MODULE uart_init
	PUBLIC uart_init
	#include "sysdefs.asm"
	RSEG CODE
uart_init:	;e=divisor
		di
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0xC3			;команда - установить скорость порта
		in	a,(c)			;выполнить команду
		ld	b,e				;параметр - установить скорость порта 19200(6) 38400(3) 115200(1) 57600(2) 9600(12) 14400(8)
		in	a,(c)			;становить параметр
		pop bc
		ei
		ret
	ENDMOD
	
	MODULE uart_write
	PUBLIC uart_write
	#include "sysdefs.asm"
	RSEG CODE
uart_write:	;e=byte to send
		di
		push bc
readytx:
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x42			;команда - прочесть статус
		in	a,(c)
		bit	6,a				;Параметры - TX 
		jp z,readytx		; вернуться если байта нет
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x03			;запись
		in	a,(c)
		ld	b,e				;БАЙТ для пересылки
		in	a,(c)			; ->
		pop bc
		ei		
		ret
	ENDMOD	




	MODULE uart_flashrts
	PUBLIC uart_flashrts
	#include "sysdefs.asm"
	RSEG CODE
uart_flashrts:
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x43			;команда - установить статус
		IN	a,(c)
		ld	b,0x03			;Параметры - убрать RTS (START)
		in	a, (c)
		pop bc
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x43			;команда - установить статус
		in	a,(c)
		ld	b,0x00			;Параметры - установить RTS (STOP)
		in	a,(c)
		pop bc
		ret
	ENDMOD





	MODULE uart_startrts
	PUBLIC uart_startrts
	#include "sysdefs.asm"
	RSEG CODE
uart_startrts:
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x43			;команда - установить статус
		IN	a,(c)
		ld	b,0x03			;Параметры - убрать RTS (START)
		in	a, (c)
		pop bc
		ret
	ENDMOD

	MODULE uart_stoprts
	PUBLIC uart_stoprts
	#include "sysdefs.asm"
	RSEG CODE
uart_stoprts:
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x43			;команда - установить статус
		in	a,(c)
		ld	b,0x00			;Параметры - установить RTS (STOP)
		in	a,(c)
		pop bc
		ret
	ENDMOD

	MODULE uart_read
	PUBLIC uart_read
	#include "sysdefs.asm"
	RSEG CODE
uart_read:					;out e = byte
		di
		push bc
read2:
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0xC2			;команда - чтение счетчика буфера приема
		in	a,(c)			;Получили число байт в буфере
		or a
		jp nz,togetb		; В буфере есть байт
		jp read2			; А теперь есть?

togetb:		
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0x02			;команда - чтение 
		in	a,(c)			;Получаем байт в А
		ld e,a
		pop bc
		ei
		ret	
	ENDMOD

	MODULE uart_queue
	PUBLIC uart_queue
	#include "sysdefs.asm"
	RSEG CODE
uart_queue:					;out e = queue
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0xC2			;команда - чтение счетчика буфера приема
		in	a,(c)			;Получили число байт в буфере
		ld e,a
		pop bc
		ret
	ENDMOD
	
	MODULE uart_delay10k
	PUBLIC uart_delay10k
	#include "sysdefs.asm"
	RSEG CODE
uart_delay10k:
		di
		push de
		ld e, 0xFA
loop2:		
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP		
		dec e
		jr nz,loop2
		pop de
		ei
		ret

	ENDMOD
	
	END
