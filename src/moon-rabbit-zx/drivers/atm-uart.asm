    MODULE Uart
		macro getqueue
		ld	a, #55	;подать комнаду контроллеру клавиатуры
		in	a, (#0FE)
		ld	a, #0C2	;команда - чтение счетчика буфера приема
		in	a, (#0FE)
		endm

		macro getbyte
chk_rec:
		ld	a, #55	;подать комнаду контроллеру клавиатуры
		in	a, (#0FE)
		ld	a, #042	;команда - чтение счетчика буфера приема
		in	a, (#0FE)
		AND	01h		;RDY_RX(0)
		JR	Z,chk_rec; не готов? А теперь?	
		ld	a, #55	;подать комнаду контроллеру клавиатуры
		in	a, (#0FE)
		ld	a, #02	;команда - чтение 
		in	a, (#0FE)
		endm
init:
;инициализируем порт
		di
		ld	a, #55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#0C3		;команда - установить скорость порта
		in	a,(#0FE)
		ld	a,3	;параметр - установить скорость порта 19200(6) 38400(3) 115200(1) 57600(2) 9600(12) 14400(8)
		in	a,(#0FE)
		ei
		ret
read:
		di
read2:
		getqueue			;Получили число байт в буфере
		or a
		jp nz,togetb
		call startrts2
		jp read2
togetb:		
		getbyte				;Получаем байт в А
		ei
		ret	
		
; Write single byte to UART
; A - byte to write
; BC will be wasted
write: 
		di
		push bc
		push de		

		ld  c, a		;В А получаем байт, сораняем его в C
readytx:
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#42		;команда - прочесть статус
		in	a,(#0FE)
		bit	 6, a		;Параметры - TX 
		jp z,readytx			; вернуться если байта нет
		ld  a, c
		ei
		PUSH	AF
		
		di
		LD	BC,#55FE	;55FEh
		IN	A,(C)		;Переход в режим команды
		LD	B,#03		;запись
		IN	A,(C)
		POP	AF		
		LD	B,A			;БАЙТ для пересылки
		IN	A,(C)		; ->
		pop de
		pop bc
		ei		
		ret


stoprts
		ld	a,#55	;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43	;команда - установить статус
		in	a,(#0FE)
		ld	a,0	;Параметры - установить RTS (STOP)
		in	a,(#0FE)
		ret

startrts
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43		;команда - установить статус
		in	a,(#0FE)
		ld	a, #03		;Параметры - убрать RTS (START)
		in	a, (#0FE)
		ret


startrts2
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43		;команда - установить статус
		in	a,(#0FE)
		ld	a, #03		;Параметры - убрать RTS (START)
		in	a, (#0FE)
		EX (SP),HL
		EX (SP),HL
		ld	a,#55		;подать комнаду контроллеру клавиатуры
		in	a,(#0FE)
		ld	a,#43		;команда - установить статус
		in	a,(#0FE)
		ld	a,0			;Параметры - установить RTS (STOP)
		in	a,(#0FE)
		ret



delay
		push de
		ld e,0x01
delay2
		EX (SP),HL
		EX (SP),HL
		dec e
		jr nz, delay2
		pop de
		ret

    ENDMODULE
