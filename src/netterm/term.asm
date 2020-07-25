        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

RECODEINPUT=1

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
        ld sp,0x4000
        ld e,6 ;textmode
        OS_SETGFX

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
	OS_YIELD	;не обязательно. Если время реагирования на подключение не критично,
				;то отдадим квант времени системе.
	JR WAIT_CLIENTS	;никто не подключился, ждём
ESTABLISHED
	LD A,L				;удачно
	LD (soc_client),A	;сохраняем дескриптор сокета.
;6. OS_NETSHUTDOWN(s)
close_wait:
	LD A,(soc)
	LD E,0 ;0 - закрыть немедленно, 1 - закрыть только если буфер отправки пуст
	OS_NETSHUTDOWN
	;BIT 7,L
	;jp z,close_ok       ;сокет закрылся
	;CP ERR_EAGAIN
	;JP NZ,inet_exiterr		;обработка ошибки не связанной с ожиданием отправки.
	;OS_YIELD		;не обязательно. Если время не критично,
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

        ;OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr ;TODO создать пайпы
        ;ld a,e
        ;ld (stdinhandle),a
        ;ld a,d
        ;ld (stdouthandle),a

        ld de,cmd_filename
        OS_OPENHANDLE
        or a
        jr nz,execcmd_error
        
        call idle_readapp ;делает CLOSE
        
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
        OS_RUNAPP

execcmd_error

mainloop
        YIELD

        call send_stdin
        
mainloop_afterkey
        call readsocket_key ;GET_KEY
        or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        jr z,mainloop
        
         push af
         call prhex ;debug
         pop af
        
        ;cp key_redraw
        ;jr z,
        ;cp key_esc
        ;jr z,term_esckey
         cp 251
         jr z,will_do_on
         cp 253
         jr z,will_do_on
         cp 250
         jr z,subnegotiation_on
         cp 240
         jr z,subnegotiation_off
         cp 240 ;other telnet codes
         jr nc,mainloop

will_do_flag=$
        or a
        jr c,will_do_off ;skip one byte
        
subnegotiation_flag=$
        or a
        jr c,mainloop_afterkey
        if RECODEINPUT
        call sendchar
        else
        call sendchar_byte_a
        endif
        jr mainloop_afterkey
        if 1==0
term_esckey
        if RECODEINPUT
        call sendchar
        ld a,key_esc
        call sendchar
        else
        call sendchar_byte_a
        endif
        jr mainloop_afterkey
        endif

will_do_off
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


quit
;TODO close cmd!!!
;TODO close socket!!!

        ld a,(stdinhandle)
        ld b,a
        OS_CLOSEHANDLE
        ld a,(stdouthandle)
        ld b,a
        OS_CLOSEHANDLE
inet_exiterr
        QUIT

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

send_stdin
        ld de,stdinbuf
        ld hl,STDINBUF_SZ
stdinhandle=$+1
        ld b,0
        ;ld b,0xff
        OS_READHANDLE
;hl=size
        call term_print
        ret

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
	OS_YIELD		;не обязательно. Если время реагирования на пришедшие данные не критично,
						;то отдадим квант времени системе.
        call send_stdin
	JR wait_data0	;данных нет, ждём
RECEIVED
	ld (datain_size),HL	;удачно. если требуется, то сохраняем количество принятых данных.
        ;push hl
        ;call term_print
        ;pop hl
        jr readsocket_key

        if 1==0
sendchar_esckey
        push bc
        ld a,0x1b
        call sendchar_byte_a
        ld a,'['
        call sendchar_byte_a
        pop bc
        jr sendchar_byte

sendchar_esckey2
        push bc
        ld a,0x1b
        call sendchar_byte_a
        ld a,'['
        call sendchar_byte_a
        pop bc
        push bc
        ld a,b
        call sendchar_byte_a
        pop bc
        jr sendchar_byte

sendchar_num
;a=num
        ld c,'0'-1
        inc c
        sub 10
        jr nc,$-3
        push af
        call sendchar_byte
        pop af
        add a,'0'+10
        jr sendchar_byte_a
        endif

sendchar
;to stdout
        cp 0x80
        ;jr nc,sendchar_rustoutf8
        ;cp 0x08 ;backspace
        ;cp 0x0d ;enter
        if 1==0
        cp key_left
        ld c,'D'
        jr z,sendchar_esckey
        cp key_right
        ld c,'C'
        jr z,sendchar_esckey
        cp key_down
        ld c,'B'
        jr z,sendchar_esckey
        cp key_up
        ld c,'A'
        jr z,sendchar_esckey
        cp key_del
        ld bc,'3'*256+'~'
        jr z,sendchar_esckey2
        cp key_home
        ld bc,'1'*256+'~'
        jr z,sendchar_esckey2
        cp key_end
        ld bc,'4'*256+'~'
        jr z,sendchar_esckey2
        cp key_ins
        ld bc,'2'*256+'~'
        jr z,sendchar_esckey2
        endif
        ld c,a
sendchar_byte
        ld a,c
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
        YIELD
        jr sendchar_repeat

term_print
;from stdin to screen
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
         ;push hl
         ;ld a,(hl)
         ;PRCHAR ;debug
         ;pop hl
        ld e,(hl)
        call term_prfsm_prchar;term_prfsm;OS_PRCHAR
        pop hl
        pop bc
        cpi
        jp pe,term_print0
        ret

        if 1==0
term_prfsm
;e=char
        ld a,(term_prfsm_curstate)
        or a
        jr nz,term_prfsm_nosingle
        ld a,e
        cp 0x1b
        jr nz,term_prfsm_prchar
        ld a,1
        ld (term_prfsm_curstate),a
        ret
term_prfsm_nosingle
        dec a
        jr nz,term_prfsm_noafteresc
        ;ld a,e
        ;cp '['
        ;jr nz,term_prfsm_prchar
        ld a,2
        ld (term_prfsm_curstate),a
        xor a
        ld (term_prfsm_curnumber),a
        ret
term_prfsm_noafteresc
        ;dec a
        ;jr nz,term_prfsm_noafterescbracket
        ld a,e
        sub '0'
        cp 10
        jr nc,term_prfsm_afterescbracket_nonumber
        ld e,a
        ld hl,term_prfsm_curnumber
        ld a,(hl)
        add a,a
        add a,a
        add a,(hl)
        add a,a ;*10
        add a,e
        ld (hl),a
        ret
term_prfsm_afterescbracket_nonumber
        ld a,e
        cp ';'
        jr nz,term_prfsm_afterescbracket_nosemicolon
        ld a,(term_prfsm_curnumber)
        ld (term_prfsm_curnumber1),a
        xor a
        ld (term_prfsm_curnumber),a
        ret
term_prfsm_afterescbracket_nosemicolon
        xor a
        ld (term_prfsm_curstate),a        
        ld a,e
        cp 'H'
        jr nz,term_prfsm_afterescbracket_noH
        ld a,(term_prfsm_curnumber1) ;row
        dec a
        ld d,a
        ld a,(term_prfsm_curnumber) ;column
        dec a
        ld e,a
        OS_SETXY
        ret
term_prfsm_afterescbracket_noH
        cp '~'
        jr nz,term_prfsm_afterescbracket_notilde
        ;cp key_del
        ;ld bc,'3'*256+'~'
        ;jr z,sendchar_esckey2
        ;cp key_home
        ;ld bc,'1'*256+'~'
        ;jr z,sendchar_esckey2
        ;cp key_end
        ;ld bc,'4'*256+'~'
        ;jr z,sendchar_esckey2
        ;cp key_ins
        ;ld bc,'2'*256+'~'
        ret
term_prfsm_afterescbracket_notilde
        ;cp 'A' ;A..D = up, down, right, left
        ret
        
        endif

term_prfsm_prchar
;e=char
        ;OS_PRCHAR
        ld a,e
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
	OS_YIELD		;не обязательно. Если время не критично,
						;то отдадим квант времени системе.
	JR send_data0	;буфер отправки переполнен, ждём освобождения
send_ok
	;LD (DATA_SIZE),HL	;удачно. если требуется, то сохраняем количество отправленных данных.
        ;ld bc,(send_data_size)
        ;or a
        ;sbc hl,bc
        
        ret

idle_readapp
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
        jr z,skipwordq
        sub ' '
        jr z,skipwordq
        inc hl ;ldi
        jp skipword0
skipwordq
        ;xor a
        ;ld (de),a
        ret

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

term_prfsm_curstate
        db 0
;states:
;0: wait for single symbol
;1: after 0x1b
;2: after 0x1b [ [number] (might be more digits)

term_prfsm_curnumber
         db 0
term_prfsm_curnumber1
         db 0

cmd_filename
        db "cmd.com",0

stdinfn
        db "stdin",0
stdoutfn
        db "stdout",0

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
