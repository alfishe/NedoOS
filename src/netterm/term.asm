        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

STDINBUF_SZ=256
NETINBUF_SZ=256

PORT=2323

SHUT_RDWR 		EQU 2
ERR_EAGAIN		EQU 35		;/* Try again */
ERR_EWOULDBLOCK	EQU ERR_EAGAIN	;/* Operation would block */
ERR_INTR 		EQU 4
ERR_NFILE 		EQU 23
ERR_ALREADY 	EQU 37
ERR_NOTSOCK 	EQU 38
ERR_EMSGSIZE 	EQU 40    ;/* Message too long */
ERR_PROTOTYPE 	EQU 41
ERR_AFNOSUPPORT EQU 47
ERR_HOSTUNREACH EQU 65
ERR_ECONNABORTED EQU	53	;/* Software caused connection abort */
ERR_CONNRESET 	EQU 54
ERR_NOTCONN 	EQU 57

;************************* Протоколы соединений *************************
SOCK_STREAM EQU 0x01		;tcp/ip
SOCK_ICMP 	EQU 0x02		;icmp
SOCK_DGRAM 	EQU 0x03		;udp/ip

AF_INET EQU 2

        org PROGSTART
begin
gotostart
        ld sp,0x4000
        OS_HIDEFROMPARENT
        ;ld e,6 ;textmode
        ;OS_SETGFX
	OS_GETMAINPAGES ;dehl
	push de
	push hl
	ld e,l
	OS_DELPAGE
	pop hl
	ld e,h
	OS_DELPAGE
	pop de
	OS_DELPAGE
 
;1. s = OS_NETSOCKET
	LD D,AF_INET
	LD E,SOCK_STREAM
	OS_NETSOCKET
	BIT 7,L
	JP NZ,inet_exiterr	;обработка ошибки
	LD A,L
        ld (soc),a
;2. OS_BIND(s)
	ld a,(soc)
	LD DE,destination_host
	OS_BIND
	BIT 7,L
	JP NZ,inet_exiterr
;3. OS_LISTEN(s)
	ld a,(soc)
	OS_LISTEN
	bit 7,l
	JP NZ,inet_exiterr
;4. s1 = OS_ACCEPT(s)
;5. если s1<0 гото 4
WAIT_CLIENTS
	LD A,(soc)
	OS_ACCEPT
	BIT 7,L
	JR Z,ESTABLISHED
	CP ERR_EAGAIN
	JP NZ,inet_exiterr	;обработка ошибки
	YIELD	;не обязательно. Если время реагирования на подключение не критично,
				;то отдадим квант времени системе.
	JR WAIT_CLIENTS	;никто не подключился, ждём
ESTABLISHED
	LD A,L				;удачно
	LD (soc_client),A	;сохраняем дескриптор сокета.
;6. OS_NETSHUTDOWN(s)
;close_wait:
	LD A,(soc)
	LD E,0 ;0 - закрыть немедленно, 1 - закрыть только если буфер отправки пуст
	OS_NETSHUTDOWN
	;BIT 7,L
	;jp z,close_ok       ;сокет закрылся
	;CP ERR_EAGAIN
	;JP NZ,inet_exiterr		;обработка ошибки не связанной с ожиданием отправки.
	;YIELD		;не обязательно. Если время не критично,
					;то отдадим квант времени системе.
	;JR close_wait ;ожидаем отправки данных
close_ok
;7. если надо то OS_WIZNETWRITE(s1)
;8. hl = OS_WIZNETREAD(s1)           
;9. if hl > 0 then обработаем и goto 7
;10. if A == ERR_EAGAIN goto 7
;11. OS_NETSHUTDOWN(s1)
;12. goto 1

        ld de,tpipename
        push de
        OS_OPENHANDLE
        ld a,b
        ld (stdinhandle),a
        pop de
        OS_OPENHANDLE
        ld a,b
        ld (stdouthandle),a

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,(stdinhandle)
        ld e,a
        ld a,(stdouthandle)
        ld d,a
        ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        OS_SETSTDINOUT

;TODO запускать файл, указанный в параметре (по умолчанию cmd, искать в bin)
        ld de,cmd_filename
        OS_OPENHANDLE
        or a
        jr nz,execcmd_error
        
        call readapp ;делает CLOSE
        
        push af
        ld b,a
        ld a,(stdinhandle)
        ld d,a
        ld a,(stdouthandle)
        ld e,a
        ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        OS_SETSTDINOUT
        
        pop af ;id

        ld e,a ;id
        ld (waitpid_id),a
        OS_RUNAPP

execcmd_error

mainloop
        YIELD
        call checkquit
        
        call send_stdin ;stdin to internet client
        
mainloop_afterkey
        call readsocket_key ;GET_KEY
        or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        jr z,mainloop
        
         ;push af
         ;call prhex ;debug
         ;pop af
        
         cp 240 ;telnet codes
         jr nc,parsetelnetcodes
will_do_flag=$
        or a
        jr c,will_do_off ;skip one byte
subnegotiation_flag=$
        or a
        jr c,mainloop_afterkey
        call sendchar
        jr mainloop_afterkey

parsetelnetcodes
         ;cp 240
         jr z,subnegotiation_off
         cp 250
         jr z,subnegotiation_on
         cp 251
         jr z,will_do_on ;skip next byte
         cp 253
         jr z,will_do_on ;skip next byte
         jr mainloop
        
will_do_off
        ;ld a,255
        ;call term_prfsm_prchar
        ;ld a,253 ;will
        ;call term_prfsm_prchar
        ;ld a,34
        ;call term_prfsm_prchar
       
        ;ld a,255
        ;call term_prfsm_prchar
        ;ld a,251 ;do
        ;call term_prfsm_prchar
        ;ld a,0x2d
        ;call term_prfsm_prchar
       
        ;ld a,255
        ;call term_prfsm_prchar
        ;ld a,0xfd
        ;call term_prfsm_prchar
        ;ld a,0x2d
        ;call term_prfsm_prchar ;disable local echo
        
        ld a,255
        call term_prfsm_prchar
        ld a,250 ;Начало субопции
        call term_prfsm_prchar
        ld a,34
        call term_prfsm_prchar
        ld a,1
        call term_prfsm_prchar
        ld a,0
        call term_prfsm_prchar
        ld a,255
        call term_prfsm_prchar
        ld a,240 ;Завершение согласования параметров (конец субопции)
        call term_prfsm_prchar ;disable local line editing

        ld a,255
        call term_prfsm_prchar
        ld a,254 ;don't
        ;ld a,251 ;do
        call term_prfsm_prchar
        ld a,1 ;echo
        call term_prfsm_prchar
       
        ;ld a,255
        ;call term_prfsm_prchar
        ;ld a,251
        ;call term_prfsm_prchar
        ;ld a,1
        ;call term_prfsm_prchar

        ld a,55+128 ;or a
        jr will_do_onoff
will_do_on
        ld a,55 ;scf
will_do_onoff
        ld (will_do_flag),a
        jr mainloop_afterkey

subnegotiation_off       
        ld a,55+128 ;or a
        jr subnegotiation_onoff
subnegotiation_on
        ld a,55 ;scf
subnegotiation_onoff
        ld (subnegotiation_flag),a
        jr mainloop_afterkey


checkquit
waitpid_id=$+1
        ld e,0
        OS_WAITPID
        or a
        jp z,quit
        ret

quit
;cmd closed!!!
	LD A,(soc_client)
	LD E,0 ;0 - закрыть немедленно, 1 - закрыть только если буфер отправки пуст
	OS_NETSHUTDOWN

        dup 2 ;close twice - as stdin and as stdout! на случай, если клиент не закрыл у себя
        ld a,(stdinhandle)
        ld b,a
        OS_CLOSEHANDLE
        ld a,(stdouthandle)
        ld b,a
        OS_CLOSEHANDLE
        edup
inet_exiterr
        jp gotostart

        QUIT

        if 1==0
prhex
        push af
        ld a,'#'
        PRCHAR
        pop af
        call prhexdigit
prhexdigit
        rrca
        rrca
        rrca
        rrca
        push af
        or 0xf0
        daa
        add a,0xa0
        adc a,0x40
        PRCHAR
        pop af
        ret
        endif

readsocket_key
datain_size=$+1
        ld hl,0
        ld a,h
        or l
        jr z,WAIT_DATA
datain_addr=$+1
        ld hl,netinbuf
        ld a,(hl)
        inc hl
        ld (datain_addr),hl
        ld hl,(datain_size)
        dec hl
        ld (datain_size),hl
        ret
WAIT_DATA
;out:hl=datain_size
        ld hl,netinbuf
        ld (datain_addr),hl
wait_data0
	LD A,(soc_client)
	LD DE,netinbuf
	LD HL,NETINBUF_SZ
	OS_WIZNETREAD
	BIT 7,H
	JR Z,RECEIVED	;ошибок нет
	CP ERR_EAGAIN
	JP NZ,inet_exiterr	;обработка ошибки
	YIELD		;не обязательно. Если время реагирования на пришедшие данные не критично,
						;то отдадим квант времени системе.
        call checkquit
        call send_stdin
	JR wait_data0	;данных нет, ждём
RECEIVED
	ld (datain_size),HL	;удачно. если требуется, то сохраняем количество принятых данных.
        ;push hl
        ;call term_print
        ;pop hl
        jr readsocket_key

sendchar
;to stdout
        ;cp 0x80
        ;jr nc,sendchar_rustoutf8
        ;cp 0x08 ;backspace
        ;cp 0x0d ;enter
;        ld c,a
;sendchar_byte
;        ld a,c
sendchar_byte_a
        ld (stdoutbuf),a
sendchar_repeat
        ld hl,1
        ld de,stdoutbuf
stdouthandle=$+1
        ld b,0
        OS_WRITEHANDLE
        ld a,h
        or l
        ret nz
        YIELDKEEP
        call checkquit
        jr sendchar_repeat

send_stdin
;stdin to internet client
        ld de,stdinbuf
        ld hl,STDINBUF_SZ
stdinhandle=$+1
        ld b,0
        ;ld b,0xff
        OS_READHANDLE
;hl=size
        ld a,h
        or l
        ret z;jr z,mainloop_afterkey
        ld b,h
        ld c,l
        ld hl,stdinbuf
term_print0
        push bc
        push hl
        ld a,(hl)
        call term_prfsm_prchar ;to internet client
        pop hl
        pop bc
        cpi
        jp pe,term_print0
        ret

term_prfsm_prchar
;to internet client
;a=char
        ld (netoutbuf),a        
send_data0
	LD A,(soc_client)
send_data_addr=$+1
	LD DE,netoutbuf
send_data_size=$+1
	LD HL,1
	OS_WIZNETWRITE
	BIT 7,H
	JR Z,send_ok	;ошибок нет
	CP ERR_EMSGSIZE
	JP NZ,inet_exiterr	;обработка ошибки
	YIELD		;не обязательно. Если время не критично,
						;то отдадим квант времени системе.
        call checkquit
	JR send_data0	;буфер отправки переполнен, ждём освобождения
send_ok
	;LD (DATA_SIZE),HL	;удачно. если требуется, то сохраняем количество отправленных данных.
        ;ld bc,(send_data_size)
        ;or a
        ;sbc hl,bc        
        ret

readapp
        ld a,b
        ld (curhandle),a
        
        OS_NEWAPP ;для первой создаваемой задачи будут созданы первые два пайпа и подключены
;dehl=номера страниц в 0000,4000,8000,c000 нового приложения, b=id, a=error
        push bc ;b=id

        ld a,d
        SETPG32KHIGH
        push de
        push hl
        ld hl,COMMANDLINE ;command line
        call skipword
        call skipspaces ;пропустили первое слово (там было term.com, а дальше, например, cmd.com autoexec.bat)
        ld de,0xc080
        ld bc,128  
        ldir ;command line
        pop hl
        pop de

        call readfile_pages_dehl

        ld a,(curhandle)
        ld b,a
        OS_CLOSEHANDLE

        pop af ;id
        ret

readfile_pages_dehl
        ld a,d
        SETPG32KHIGH
        ld a,0xc100/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,e
        SETPG32KHIGH
        ld a,0xc000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,h
        SETPG32KHIGH
        ld a,0xc000/256
        call cmd_loadpage
        or a
        ret nz
        
        ld a,l
        SETPG32KHIGH
        ld a,0xc000/256

cmd_loadpage
;out: a=error
;keeps hl,de
        push de
        push hl
        ld d,a
        xor a
        ld l,a
        ld e,a
        sub d
        ld h,a ;de=buffer, hl=size
curhandle=$+1
        ld b,0
        OS_READHANDLE
        pop hl
        pop de
        ret

skipword
;hl=string
;out: hl=terminator/space addr
skipword0
        ld a,(hl)
        or a
        ret z
        sub ' '
        ret z
        inc hl
        jp skipword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

cmd_filename
        db "cmd.com",0

tpipename
        db "z:",0

stdoutbuf
        db 0

netoutbuf
        db 0

stdinbuf
        ds STDINBUF_SZ

netinbuf
        ds NETINBUF_SZ

soc
        db 0
soc_client
        db 0

;struct sockaddr_in {unsigned char sin_family;unsigned short sin_port;
;	struct in_addr sin_addr;char sin_zero[8];};
destination_host		
	DEFB AF_INET 
	DEFB PORT/256,PORT&0xff ;port (big endian)
	DEFB 0,0,0,0			;исходящий IP адрес (не используется в текущей реализации)
	DEFB 0,0,0,0,0,0,0,0	;резерв
        
end
	savebin "netterm.com",begin,end-begin
	
	LABELSLIST "..\..\us\user.l"
