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


		ld de,testsend
		ld a,65
		ld hl,159
		call tcpsend


		YIELD
		YIELD
		YIELD


		ld a,65
		ld de,answerbuffer
		ld hl,512 
		call OS_WIZNETREAD
				
		call OS_NETSHUTDOWN

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
		push de
comparestr2		
		ld a, (hl)
		ld d, a
		ld a, (bc)
		cp d
		jp nz, notequal
		inc bc
		inc hl
		ld a, (bc)
		cp 0
		jp nz, comparestr2
		ld a, 1
		pop de
		ret
notequal:
		pop de
		ld a,0
		ret
 		
;****************************************************************************
readanswer:					;Read 1 line out at answerbuffer with clear
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
		call uart_read
		ld (hl), 0
		;call flushbuf
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
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0xC3			;??????? - ???????? ????? ????
		in	a,(c)			;??????? ???????
		ld	b,e				;?????? - ???????? ????? ???? 19200(6) 38400(3) 115200(1) 57600(2) 9600(12) 14400(8)
		in	a,(c)			;??????? ??????
		pop bc
		ei
		ret
;****************************************************************************
uart_write:	;e=byte to send
		di
		push bc
readytx:
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x42			;??????? - ?????? ?????
		in	a,(c)
		bit	6,a				;??????? - TX 
		jp z,readytx		; ???????? ?? ???? ???
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x03			;??????
		in	a,(c)
		ld	b,e				;???? ??? ??????
		in	a,(c)			; ->
		pop bc
		ei		
		ret
;****************************************************************************
uart_flashrts:
		push bc
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x43			;??????? - ???????? ?????
		IN	a,(c)
		ld	b,0x03			;??????? - ???? RTS (START)
		in	a, (c)
		pop bc
		push bc
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x43			;??????? - ???????? ?????
		in	a,(c)
		ld	b,0x00			;??????? - ???????? RTS (STOP)
		in	a,(c)
		pop bc
		ret
;****************************************************************************
uart_startrts:
		push bc
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x43			;??????? - ???????? ?????
		IN	a,(c)
		ld	b,0x03			;??????? - ???? RTS (START)
		in	a, (c)
		pop bc
		ret
;****************************************************************************
uart_stoprts:
		push bc
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x43			;??????? - ???????? ?????
		in	a,(c)
		ld	b,0x00			;??????? - ???????? RTS (STOP)
		in	a,(c)
		pop bc
		ret
;****************************************************************************
uart_read:					;out e = byte
		di
		push bc
read2:
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0xC2			;??????? - ???? ????? ???? ????
		in	a,(c)			;?????? ?? ???? ? ????
		or a
		jp nz,togetb		; ? ???? ???? ????
		call uart_startrts
		call uart_stoprts
		jp read2			; ? ???? ?????

togetb:		
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0x02			;??????? - ???? 
		in	a,(c)			;?????? ???? ? ?
		ld e,a
		pop bc
		ei
		ret	
;****************************************************************************
uart_queue:					;out e = queue
		push bc
		ld	bc,0x55FE		;???? 8952
		in	a,(c)			;???? ? ??? ???????
		ld	b,0xC2			;??????? - ???? ????? ???? ????
		in	a,(c)			;?????? ?? ???? ? ????
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
        ld bc,0 ;??? ?? ???? ??????
        xor a
        cpir ;????? ?????, ?? ?????=0, ? bc=-1 ? ?.?.
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
; ?????? ?????????? ??????, ??????? ???? ? ????.
		call flushbuf
		
		ld hl, atcipclose
		call sendtext
		YIELD
		call readanswer
		call flushbuf
		ld hl, ate0
		call sendtext
		YIELD
		call readanswer
		call flushbuf
		ld hl, atcipmux0
		call sendtext
		YIELD
		call readanswer
		call flushbuf
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
		call flushbuf
		ld hl, atcipdinfo
		call sendtext
		YIELD
		call readanswer
		call flushbuf
		ld hl, atciprecvmode1
		call sendtext
		YIELD
		call readanswer
		call flushbuf
		call flushbuf
		ret

;****************************************************************
; Based on: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Other:DispHL
; DE(HL) - number
; It will be written to UART
deToNumEsp:
    ld hl,de
hlToNumEsp:
	ld a,0
	ld (firstzero),a
	;ld hl,de
    ld    bc,-10000
    call    n1
    ld    bc,-1000
    call    n1
    ld    bc,-100
    call    n1
    ld    c,-10
    call    n1
    ld    c,-1
n1  ld  a,'0'-1
n2  inc a
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



;****************************************************************
matchval:
;de=numpointer bc=result
        ld a,(de)
        sub '0'
        ld bc,0
        ld h,b
        ld l,c
matchval_dec0 ;bc=hl
        add hl,hl ;2
        add hl,hl ;4
        add hl,bc ;5
        add hl,hl ;10
        add a,l
        ld l,a
        jr nc,$+3
         inc h
        ld b,h
        ld c,l
        inc de
        ld a,(de)
        sub '0'
        cp 10
        jr c,matchval_dec0
        ret ;bc=result

;****************************************************************
OS_NETCONNECT:
;?? ?????? ? ??????:
;A - SOCKET
;DE - ????? ?? ???????? sockaddr_in ?????? IP ???? ? ???? ???.
;???????? ?????? ? ??????:
;L - ?? ??????? ??????  - ???? ????????? ? ?????.
;? - errno ?? ????.
;???????? ????:
;ERR_NOTSOCK  - ?? ???????? ?????? ???
;ERR_ALREADY  - ??? ? ???????
;ERR_HOSTUNREACH - ??? ?? ?????, ???? ??? ?????????.
;++++TCP+++++
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
		pop bc
		ret
okstart:
		ld l,0
		ld a,0
		pop bc
		ret
		
;****************************************************************************
OS_NETSOCKET:
;??????? ???.
;D - ????? ????, ??????????? 8-???? ??, ????????? ?? ?????? 2 (AF_INET).
;E - ????? ????????(0x01 tcp/ip, 0x02 icmp, 0x03 udp/ip)
;???????? ?????? ? ??????:
;L - SOCKET ?? ????????? ??????, ?? ??????? ??????  - ???? ????????? ? ?????.
;? - errno ?? ????.
;  ERR_AFNOSUPPORT - ????? ???? ?? ????????????
;  ERR_NFILE  - ??? ??????? ???
;  ERR_PROTOTYPE - ????? ?? ????????????
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
;?????? ???.
;A - SOCKET
;E - ?????? ???????, 0 - ??????? ??????????, 1 - ??????? ?? ?? ???? ????? ????.
;???????? ?????? ? ??????:
;  L - ?? ??????? ??????  - ???? ????????? ? ?????.
;  ? - errno ?? ????.
;	ERR_NOTSOCK - ?? ???????? ?????? ???
;	ERR_EAGAIN - ???? ????? ?? ????
; ??? ??? ???? ?????? ??????, ????? ????? ???. ?? ? ??? ????.
		call esp_init
		ld l, 0
		ld a, 0
		ret
;****************************************************************************
OS_WIZNETREAD
;Возвращаемые значения в регистрах:
;HL - при отрицательном значении функция завершилась с ошибкой,
;про значении больше нуля возвращается действительный размер(в байтах) принятых данных,
;нулевого значения вызов не возвращает.
;А - errno при ошибке.
;Возможные ошибки:
;ERR_NOTSOCK - не действительный дескриптор сокета
;ERR_EAGAIN - входящих данных пока нет
;ERR_NOTCONN - сокет с неустановленным\пропавшем соединением(при протоколе TCP/IP)
;pseudo socket 65=TCP 66=ICMP 67=UDP
		cp 65
		jp tcpread
		cp 66
		jp icmpread
		cp 67
		jp udpread
		jp errnotsock
tcpread
;При протоколе TCP/IP все аргументы в регистрах:
;A - SOCKET
;DE - указатель на буфер для принятия данных
;HL - размер буфера(в байтах)
		ld (recsize),hl
		ld (recpointer),de
		push bc		
erragain1	;DEBUG!!!!!!
		call flushbuf
		ld hl,recvlen		
		call sendtext
		YIELD
		call readanswer2
		ld hl,answerbuffer
		ld de,12
		adc hl,de
		ld de,hl
		call matchval
		ld (realsize),bc; counter
		ld hl,0
		sbc hl,bc 
		jp z, erragain1		;DEBUG

		ld hl,atrecvdata		
		call sendtext
		ld hl,(recsize)
		call hlToNumEsp
		ld hl,crlf
		call sendtext
		YIELD
		call readanswer; +CIPVRECDATA
skip2coma:
		call uart_read
		ld a,','		
		cp e
		jp nz, skip2coma

answerok:		
		ld hl,(recsize)
		ld de,(realsize)
		sbc hl,de		
		jp s, recrec
		ld bc,(realsize)
		jp recreal		
recrec						;В буфере данных больше чем  запрошено, получаем сколько запросили
		ld bc,(recsize)
recreal						;В буфере данных меньше чем  запрошено, получаем сколько пришло
		ld hl,(recpointer)
nextbyte:
		call uart_read
		ld (hl),e
		inc hl
		dec bc
		ld a,0
		cp b
		jp nz, nextbyte 
		cp c
		jp nz, nextbyte
okrecieve:
		ld (hl),00		;DEBUG

		ld hl,(recpointer)
		call prtext

		ld hl,crlf
		call prtext

		QUIT
		pop bc
		ret
recpointer:
		db 00,00
recsize:
		db 00,00
realsize:
		db 00,00		

icmpread
udpread
;При протоколе отличном от TCP/IP все аргументы в регистрах:
;  A - SOCKET
;  DE - указатель на структуру sockaddr_in, в неё помещается(ядром) IP-адрес и порт хоста отправившего данные.
;  IX - указатель на буфер для принятия данных
;  HL - размер буфера(в байтах)
		push bc	

		jp errnotsock



;****************************************************************************
OS_WIZNETWRITE
;pseudo socket 65=TCP 66=ICMP 67=UDP
		cp 65
		jp tcpsend
		cp 66
		jp icmpsend
		cp 67
		jp udpsend
		jp errnotsock
tcpsend
		push bc
		ld (sendpointer),de
		ld (sendsize),hl
		ld hl, atcipsend
		call sendtext
		ld hl,(sendsize)
		call hlToNumEsp
		ld hl,crlf
		call sendtext
		YIELD
waitprompt:		
		call uart_read
		ld a,e
		cp '>'
		jp nz,waitprompt
		ld hl,(sendsize)
		ld de,(sendpointer)
more2go:
		push de
		ld a,(de)
		ld e,a
		call uart_write
		pop de
		inc de
		dec hl
		ld a,0
		cp h
		jp nz, more2go 
		cp l
		jp nz, more2go
		YIELD

		call readanswer
		ld hl,answerbuffer
		ld bc,recvbytes
		call comparestr
		cp 1
		jp z,bytesok
		ld hl,defaulterror
		call prtext
		QUIT
bytesok
		call flushbuf
		ld de,hl
		call matchval	 ;de=numpointer bc=result
		ld hl,bc
		ld a,0
		pop bc
		ret
sendpointer:
		db 00,00
sendsize:
		db 00,00

icmpsend:
udpsend:
		push bc



errnotsock:
		ld h,255
		ld l,255
		ld a,ERR_NOTSOCK
		pop bc
		ret

errnotconn:
		ld h,255
		ld l,255
		ld a,ERR_NOTCONN
		pop bc
		ret	
erragain:
		ld h,255
		ld l,255
		ld a,ERR_EAGAIN
		pop bc
		ret	
;****************************************************************************




atgmr
		db "AT+GMR",0x0d,0x0a,0
ate0
		db "ATE0",0x0d,0x0a,0		
ate1
		db "ATE1",0x0d,0x0a,0		
atcipmux0
		db "AT+CIPMUX=0",0x0d,0x0a,0		
atcipserver0
		db "AT+CIPSERVER=0",0x0d,0x0a,0
atcipdinfo
		db "AT+CIPDINFO=0",0x0d,0x0a,0				
atcipclose
		db "AT+CIPCLOSE",0x0d,0x0a,0
atciprecvmode1
		db "AT+CIPRECVMODE=1",0x0d,0x0a,0
atcipstart1
		db "AT+CIPSTART=\"TCP\",\"",0
atcipstart2	
		db "\",",0
atcipsend
		db "AT+CIPSEND=",0
atrecvdata
		db "AT+CIPRECVDATA=",0
recvdata2
		db "+CIPRECVDATA:",0
recvlen
		db "AT+CIPRECVLEN?",0x0d,0x0a,0
recvlenansw
		db "+CIPRECVLEN:",0				
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
sendprompt
		db ">",0
recvbytes
		db "Recv ",0

ipdbytes
		db "+IPD,",0

		

adrstruct:
		DB 2
		DB 00,80    ;???? ????????
		DB 217,146,69,13   ;IP ???? ????????
		DB 0,0,0,0,0,0,0,0 ;???

testsend:
	db "GET /api/export:zxPicture/filter:zxPicture/limit:1/start:0/order:date,desc HTTP/1.1"
	db 13, 10
	db "Host: zxart.ee"
	db 13, 10
	db "User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)"
	db 13, 10, 13, 10, 0;
tmp:
	db 0,0,0,0,0,0,0,0

    include "../_sdk/stdio.asm"

; \r = 13 (CR) \n = 10 (LF).

answerbuffer
	db "............................................................................................................................."
	db "............................................................................................................................",0x0d,0x0a,0
end
	savebin "ea.com",begin,end-begin

	LABELSLIST "../../us/user.l"
