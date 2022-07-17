        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

SHUT_RDWR   	EQU 2
ERR_EAGAIN  	EQU 35  		;/* Try again */
ERR_EWOULDBLOCK EQU ERR_EAGAIN 	;/* Operation would block */
ERR_INTR   		EQU 4
ERR_NFILE   	EQU 23
ERR_ALREADY  	EQU 37
ERR_NOTSOCK  	EQU 38
ERR_EMSGSIZE  	EQU 40    ;/* Message too long */
ERR_PROTOTYPE  	EQU 41
ERR_AFNOSUPPORT EQU 47
ERR_HOSTUNREACH EQU 65
ERR_ECONNABORTED EQU 53 ;/* Software caused connection abort */
ERR_CONNRESET  	EQU 54
ERR_NOTCONN  	EQU 57




        org PROGSTART
begin
		call initstdio
	
		ld hl, thello
		call prtext
	
		ld e, 3
		call uart_init
				
		ld hl, uartinited
		call prtext
	
		call esp_init
		
		ld hl, espinited
		call prtext
		

		call OS_NETSOCKET

		ld de,adrstruct
		call OS_NETCONNECT
		ld a,l
		cp 255
		jp z, errorop

		call OS_NETSHUTDOWN
		
		ld hl, asterix
		call prtext
		ld hl, crlf
		call prtext
		QUIT


errorop:
		call OS_NETSHUTDOWN
		ld hl,defaulterror
		call prtext
		QUIT
;****************************************************************************		
comparestr:		
;hl=string to test	bc=string tester
;a = 1 if equal = 0 if not. May be Z flag use later for short test
		ld a, (bc)
		ld d, a
		ld a, (hl)
		cp d
		jp nz, notequal
		inc bc
		inc hl
		cp 0
		jp nz, comparestr
		ld a, 1
		ret
notequal:
		ld a,0
		ret
 		
;****************************************************************************
readanswer:					;Read 1 line
		push de
		push hl
		ld hl,answerbuffer
		call uart_startrts
		call uart_stoprts
		call uart_read
		call uart_startrts
		call uart_stoprts
		call uart_read
		jp readanswer3
readanswer2:
		push de
		push hl
		ld hl,answerbuffer
readanswer3:
		call uart_startrts
		call uart_stoprts
		call uart_read
		ld a, 0x0d
		cp e
		jp z, endline
		ld (hl), e
		inc hl
		jp readanswer3
endline:
		ld (hl), 0
		call flushbuf
		pop hl
		pop de
		ret
;****************************************************************************
flushbuf:
		push bc
		call uart_startrts
		YIELD
flushbuf2:
		call uart_queue
		ld a, e
		cp 0
		jp z, exitflush
		ld b, e
readjunk:
		call uart_read
		dec b
		jp nz, readjunk
		;YIELD
		jp flushbuf2
exitflush:
		call uart_stoprts
		pop bc
		ret
;****************************************************************************
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
;****************************************************************************
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
;****************************************************************************
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
;****************************************************************************
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
;****************************************************************************
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
;****************************************************************************
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
		call uart_startrts
		call uart_stoprts
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
;****************************************************************************
uart_queue:					;out e = queue
		push bc
		ld	bc,0x55FE		;адрес 8952
		in	a,(c)			;Переход в режим команды
		ld	b,0xC2			;команда - чтение счетчика буфера приема
		in	a,(c)			;Получили число байт в буфере
		ld e,a
		pop bc
		ret
;****************************************************************************
uart_delay1k:
		push de
		ld e, 0xFA
loop2:		
		NOP
		NOP
		NOP
		NOP		
		dec e
		jr nz,loop2
		pop de
		ret
;****************************************************************************
prtext
;hl=text
        push hl
        call strlen 	;hl=length
        pop de 			;de=text
        jp sendchars	;send chars to stdout (in: de=buf, hl=size, out: A=error)
strlen
;hl=str
;out: hl=length
        ld bc,0 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret
;****************************************************************************
sendtext
;hl=text
		push de
		push bc
		push hl
        push hl
		call strlen 	;hl=length
        pop bc			;bc=text
more2send
		ld a, (bc)
		ld e, a
		call uart_write
		inc  bc
		dec hl
		ld a, 0
		cp h
		jp nz, more2send
		cp l
		jp nz, more2send
		pop hl
		pop bc
		pop de
		ret
;****************************************************************
esp_init:
; делаем инициализацию настроек, закрываем сокеты и серверы.
		call flushbuf
		
		ld hl, atcipclose
		call sendtext
		YIELD
		call readanswer

		ld hl, ate0
		call sendtext
		YIELD
		call readanswer

		ld hl, atcipmux0
		call sendtext
		YIELD
		call readanswer
		ld hl, answerbuffer
		ld bc, okanswer
		call comparestr
		cp 1
		jp z, nextinit
	
		ld hl, espnotinited
		call prtext
		QUIT
nextinit:					
		ld hl, atcipserver0
		call sendtext
		YIELD
		call readanswer
		
		ld hl, atcipdinfo
		call sendtext
		YIELD
		call readanswer
		
		call flushbuf
		ret



;****************************************************************
; Based on: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispHL
; DE(HL) - number
; It will be written to UART
deToNumEsp:
    ld a,0
	ld (firstzero),a
	ld hl,de
    ld    bc,-10000
    call    n1
    ld    bc,-1000
    call    n1
    ld    bc,-100
    call    n1
    ld    c,-10
    call    n1
    ld    c,-1
n1    ld  a,'0'-1
n2    inc a
    add    hl,bc
    jr    c, n2
    sbc    hl,bc
	ld e,a
    cp '0'
	jp z, zerotest
	ld (firstzero),a
printzero:
	call uart_write
skipzero:
	ret

zerotest:
		ld a, (firstzero)
		cp 0
		jp z, skipzero
		jp printzero

firstzero:
		db 0
toespbuf
		db 0,0,0,0,0,0,0,0,0,0	
;****************************************************************
OS_NETCONNECT:
;Все аргументы в регистрах:
;A - SOCKET
;DE - указатель на структуру sockaddr_in содержащую IP адрес и порт хоста.
;Возвращаемые значения в регистрах:
;L - При отрицательном значении  - функция завершилась с ошибкой.
;А - errno при ошибке.
;Возможные ошибки:
;ERR_NOTSOCK  - не действительный дескриптор сокета
;ERR_ALREADY  - сокет уже подключен
;ERR_HOSTUNREACH - хост не доступн, либо отверг подключение.
;++++TCP+++++
;DEFB AF_INET
;DEFB 0,80    ;порт назначения
;DEFB 1,2,3,4   ;IP адрес назначения
;DEFB 0,0,0,0,0,0,0,0 ;резерв
;atcipstart1		;"AT+CIPSTART=\"TCP\",\"",0
		push bc
		ld hl,atcipstart1
		call sendtext
		ld hl,de
		inc hl
		push hl
		inc hl
		inc hl
		ld e,(hl)
		ld d,0
		push hl
		call deToNumEsp
		pop hl
		ld e,'.'
		call uart_write
		inc hl
		ld e,(hl)
		ld d,0
		push hl
		call deToNumEsp
		pop hl
		ld e,'.'
		call uart_write
		inc hl
		ld e,(hl)
		ld d,0
		push hl
		call deToNumEsp
		pop hl
		ld e,'.'
		call uart_write
		inc hl
		ld e,(hl)
		ld d,0
		push hl
		call deToNumEsp
		pop hl
		ld hl,atcipstart2
		call sendtext
		pop hl
		ld de,(hl)
		ld l,d
		ld h,e
		ex de,hl
		call deToNumEsp
		ld hl,crlf
		call sendtext
		YIELD
		call readanswer2
		ld hl,answerbuffer
		ld bc,connanswer
		call comparestr
		cp 1
		jp z,okstart
		
		ld l,255
		ld a,ERR_HOSTUNREACH
		ret
okstart:
		ld l,0
		ld a,0
		pop bc
		ret
		
;****************************************************************************
OS_NETSOCKET:
;Создаёт сокет.
;D - семейство адресов, беззнаковое 8-битное число, допускается только значение 2 (AF_INET).
;E - протокол соединения(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip)
;Возвращаемые значения в регистрах:
;L - SOCKET при положительном значении, при отрицательном значении  - функция завершилась с ошибкой.
;А - errno при ошибке.
;  ERR_AFNOSUPPORT - семейство адресов не поддерживается
;  ERR_NFILE  - нет свободных сокетов
;  ERR_PROTOTYPE - протокол не поддерживается
		ld a, d
		cp 2
		jp nz, ERRAFNOSUPPORT
		ld a, e
		cp 0
		jp z, ERRPROTOTYPE
		cp 3
		jp c, ERRPROTOTYPE
		add 64			;pseudo socket 65=TCP 66=ICMP 67=UDP
		ld l, a
		ld a, 0
		ret
		
ERRAFNOSUPPORT:
		ld l, 255
		ld a, ERR_AFNOSUPPORT
		ret
ERRPROTOTYPE:
		ld l, 255
		ld a, ERR_PROTOTYPE
		ret
;****************************************************************************
OS_NETSHUTDOWN
;Закрытие сокета.
;A - SOCKET
;E - Варианты закрытия, 0 - закрыть немедленно, 1 - закрыть только если буфер отправки пуст.
;Возвращаемые значения в регистрах:
;  L - При отрицательном значении  - функция завершилась с ошибкой.
;  А - errno при ошибке.
;	ERR_NOTSOCK - не действительный дескриптор сокета
;	ERR_EAGAIN - буфер отправки не пуст
; для теста просто выполним переинит, который закроет сокет. Он у нас один.
		call esp_init
		ld l, 0
		ld a, 0
		ret



atgmr
		db "AT+GMR",0x0d,0x0a,0
ate0
		db "ATE0",0x0d,0x0a,0		
atcipmux0
		db "AT+CIPMUX=0",0x0d,0x0a,0		
atcipserver0
		db "AT+CIPSERVER=0",0x0d,0x0a,0

atcipdinfo
		db "AT+CIPDINFO=0",0x0d,0x0a,0				

atcipclose
		db "AT+CIPCLOSE",0x0d,0x0a,0
		
atcipstart1
		db "AT+CIPSTART=\"TCP\",\"",0
atcipstart2	
		db "\",",0
thello
        db "ESP32 Driver Project(single mode)",0x0d,0x0a,0

asterix
        db "*",0x0d,0x0a,0

plusik
        db "+",0
crlf
        db 0x0d,0x0a,0


uartinited
		db "Uart inited.",0x0d,0x0a,0
 
espinited
		db "ESP inited.",0x0d,0x0a,0

espnotinited
		db "ESP not inited.",0x0d,0x0a,0		

defaulterror
		db "Default error.",0x0d,0x0a,0				

erroranswer
		db "ERROR",0
connanswer
		db "CONNECT",0		
okanswer
		db "OK",0
busyanswer
		db "busy",0

adrstruct:
		DB 2
		DB 00,80    ;порт назначения
		DB 217,146,69,13   ;IP адрес назначения
		DB 0,0,0,0,0,0,0,0 ;резерв





        include "../_sdk/stdio.asm"



answerbuffer
		db "............................................................................................................................."
		db "............................................................................................................................",0x0d,0x0a,0
end
	savebin "ea.com",begin,end-begin

	LABELSLIST "../../us/user.l"
