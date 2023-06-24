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

RBR_THR equ 0xF8EF
IER		equ	0xF9EF
IIR_FCR	equ	0xFAEF
LCR		equ	0xFBEF
MCR		equ	0xFCEF
LSR		equ	0xFDEF
MSR		equ	0xFEEF
SR		equ	0xFFEF


        org PROGSTART
begin
		call initstdio
	
		ld hl, thello
		call prtext
	
		ld e, 1
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

	
		ld de,testsend	; Buff pointer
		ld a,65			; Socket
		ld hl,159		; SizeOfData
		call tcpsend	; WIZNETSEND

		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD

		ld a,65
		ld de,testsend
		ld hl,15 
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
		call uart_read
		call uart_read

		jp readanswer3
readanswer2:
		push de
		push hl
		ld hl,answerbuffer
readanswer3:
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
		call flushbuf
		pop hl
		pop de
		ret
;****************************************************************************
flushbuf:
		;push bc
		;push de
		call uart_startrts
		YIELD
flushbuf2:
		call uart_queue
		ld a, e
		cp 0
		jp z, exitflush
readjunk:
		call uart_read
		jp flushbuf2
exitflush:
		call uart_stoprts
		;pop de
		;pop bc
		ret
;****************************************************************************
uart_init:	;e=divisor
	push bc

	ld bc,MCR       // Assert RTS. In Evo only  bit #1 is used. For RTS control
    ld a, 0x00
	out (c),a

	ld bc,IIR_FCR   // Enable fifo 8 level, and clear it
    ld a, 0x87
	out (c),a

	ld bc,LCR       // 8n1, DLAB=1
    ld a, 0x83
	out (c),a

	ld bc,RBR_THR   // 115200 (divider 1-115200, 3 - 38400)
    ld a, e
	out (c),a

	ld bc,IER       // (divider 0). Divider is 16 bit, so we get (0x0002 divider)
    ld a, 0x00
	out (c),a

	ld bc,LCR       // 8n1, DLAB=0
    ld a, 0x03
	out (c),a

	ld bc,IER       // Disable int
    ld a, 0x00
	out (c),a

	pop bc
    ret
;****************************************************************************
uart_write:			;e=byte to send
    push bc
.wait
	ld bc, LSR      ;FIFO is free?
	in a, (c)
    and 0x20
    jr z, .wait     ;No. Wait more.
	ld a,e
	ld bc,RBR_THR   ;Write data to FIFO
	out (c),a
	pop bc	
    ret
;****************************************************************************
uart_flashrts:
	di
	ld bc,MCR           // Open the gate
    ld a, 2
	out (c),a
    call uart_delay3k   // Wait while FIFO
    ld bc,MCR           // Close the gate
    ld a, 0
	out (c),a
    ei
	ret
;****************************************************************************
uart_startrts:			// RTS enable
	push bc
	ld bc,MCR           // Open the gate
    ld a, 2
	out (c),a
	pop bc
	ret
;****************************************************************************
uart_stoprts:			// RTS disable
	push bc
    ld bc,MCR           // Close the gate
    ld a, 0
	out (c),a
	pop bc
	ret
;****************************************************************************
uart_read:					;out e = byte
	ld bc, LSR          	// Test FIFO for data
	in a, (c)
    rrca
    call nc,uart_flashrts    	// No data in FIFO let's set RTS for awile
readData:
    ld bc, RBR_THR      	// Recieve data from FIFO
	in a, (c)
	ld e,a
    ret
;****************************************************************************
uart_queue:					;out e = queue
	push bc
    ld e,0
	ld bc, LSR          	// Test FIFO for data
	in a, (c)
	rrca
	jp nc,no_uart_queue    // No data in FIFO
	ld e,1
no_uart_queue:
	pop bc
	ret
;****************************************************************************
uart_delay3k:      			 // Determined delay. More then 1 byte to recieve, less then time for fullfill FIFO buffer
		push de
		ld e, 0xFA
loop2:		
		NOP
        NOP
		NOP
		dec e
		jr nz,loop2
		pop de
		ret
;****************************************************************************
prtext ; in: hl=text spoils de
		ld de,hl		;de=text
       	push bc
	    call strlen 	;hl=length
		pop bc
        jp sendchars	;send chars to stdout (in: de=buf, hl=size, out: A=error)
strlen					; in: hl=str  out: hl=length
		ld bc,0
        xor a
        cpir
        ld hl,-1
        or a
        sbc hl,bc
        ret
;****************************************************************************
sendtext				;in: hl=text
		push bc
		push de
		push hl			
		call strlen 	;hl=length
		pop bc			;bc=text
more2send
		ld a, (bc)
		ld e, a
		call uart_write
		inc bc
		dec hl
		xor a
		cp h
		jp nz, more2send
		cp l
		jp nz, more2send
		pop de
		pop bc
		ret
;****************************************************************
esp_init:
		;ld hl, resetmodule
		;	call sendtext
		;	YIELD
		;	YIELD
		;	YIELD
		;call readanswer
		call flushbuf
		ld hl, ate0
		call sendtext
		YIELD
		call readanswer
		ld hl, atcipclose
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
		ld hl,atcipdinfo
		call sendtext
		YIELD
		call readanswer
		ld hl, atciprecvmode1
		call sendtext
		YIELD
		call readanswer
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
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
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
OS_NETSOCKET: ;return pseudo socket 65=TCP 66=ICMP 67=UDP
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
;�����頥�� ���祭�� � ॣ�����:
;HL - �� ����⥫쭮� ���祭�� �㭪�� �����訫��� � �訡���,
;�� ���祭�� ����� ��� �����頥��� ����⢨⥫�� ࠧ���(� �����) �ਭ���� ������,
;�㫥���� ���祭�� �맮� �� �����頥�.
;� - errno �� �訡��.
;�������� �訡��:
;ERR_NOTSOCK - �� ����⢨⥫�� ���ਯ�� ᮪��
;ERR_EAGAIN - �室��� ������ ���� ���
;ERR_NOTCONN - ᮪�� � ����⠭�������\�ய��襬 ᮥ��������(�� ��⮪��� TCP/IP)
;pseudo socket 65=TCP 66=ICMP 67=UDP
		cp 65
		jp tcpread
		cp 66
		jp icmpread
		cp 67
		jp udpread
		jp errnotsock
tcpread
;�� ��⮪��� TCP/IP �� ��㬥��� � ॣ�����:
;A - SOCKET
;DE - 㪠��⥫� �� ���� ��� �ਭ��� ������
;HL - ࠧ��� ����(� �����)
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
		YIELD
		YIELD
		YIELD
		YIELD
		YIELD
		;call readanswer; +CIPVRECDATA (do not uncomment)
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
recrec						;� ���� ������ ����� 祬  ����襭�, ����砥� ᪮�쪮 ����ᨫ�
		ld bc,(recsize)
recreal						;� ���� ������ ����� 祬  ����襭�, ����砥� ᪮�쪮 ��諮
		ld hl,(recpointer)
nextbyte:
		push bc
		call uart_read
		pop bc
		ld (hl),e
		inc hl
		dec bc
		xor a
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
;�� ��⮪��� �⫨筮� �� TCP/IP �� ��㬥��� � ॣ�����:
;  A - SOCKET
;  DE - 㪠��⥫� �� �������� sockaddr_in, � ��� ����頥���(�஬) IP-���� � ���� ��� ��ࠢ��襣� �����.
;  IX - 㪠��⥫� �� ���� ��� �ਭ��� ������
;  HL - ࠧ��� ����(� �����)
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
resetmodule
		db "AT+RST",0x0d,0x0a,0x00						
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

answerbuffer:
	db "............................................................................................................................."
	db "............................................................................................................................",0x0d,0x0a,0

databuffer:
	ds 2048
end
	savebin "esp32e.com",begin,end-begin

	LABELSLIST "../../us/user.l"
