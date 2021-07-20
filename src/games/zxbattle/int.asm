swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038
        jp 0x0038+3

on_int
;restore stack with de
	LD (on_int_hl),HL
	LD (on_int_sp),SP
	pop hl
	LD (on_int_jp),HL
	LD (on_int_sp2),SP
	LD SP,INTSTACK
        push af
        push bc
        push de
        ex de,hl
;если стек в экране, то восстанавливаем нулём, иначе de
        ld a,(on_int_sp+1)
        sub 0x40
        cp 0x3f
        jr nc,$+5 ;not screen
        ld hl,0
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек

        exx
        ex af,af' ;'
        push af
        push bc
        push de
        push hl
        push ix
        push iy

int_curborder=$+1
        ld e,0
        OS_SETBORDER

curscrnum_int=$+1
        ld e,0
        OS_SETSCREEN
        
        call oldimer ;ei ;а что если выйдем поздно (по yield)? надо в конце обработчика убрать ei, но и это не поможет, т.к. yield сейчас с включенными прерываниями!!!

        ld a,(curpg16k) ;ok
        push af
        ld a,(curpg32klow) ;ok
        push af
        ld a,(curpg32khigh) ;ok
        push af

        if KEMPSTON
        GET_KEY
        ld a,lx
        ld (kempstonbuttons),a
        endif

        if VIRTUALKEYS
        ;GET_KEY
        ;ld a,c ;кнопка без учёта языка
        ;or a
        ;jr z,$+5
        ;ld (curkey),a
        
        OS_GETKEYMATRIX
	rr c ;'a'
	rla ;A
	rr c ;'s'
	rla ;B
	ld c,lx
	rr c ;'Space'
	rla ;Select
	ld c,hx
	rr c ;'Enter'
	rla ;Start
	add a,a
	bit 3,h ;7
	jr z,$+3
	inc a ;Up
	add a,a
	bit 4,h ;6
	jr z,$+3
	inc a ;Down
	add a,a
	bit 4,e ;5
	jr z,$+3
	inc a ;Left
	add a,a
	bit 2,h ;8
	jr z,$+3
	inc a ;Right
        ;cpl 
       ifdef CLIENT
        ld (joyTMPstate),a ;TODO в очередь, а в логике брать в том же порядке
       else
        ld (joy1state),a
       endif
       ;display "joy1state=",joy1state
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
        endif
        
        call setpgsmain40008000
	;LD	BC,PAGE3
	;LD	A,#C3
	;OUT	(C),A
        call setpgc3

	CALL	PLAYS
	LD	A,(SOUNDW)
	CP	0
	CALL	Z,PLAYS3
	LD	A,5
	LD	(SOUNDGO),A

	LD	A,(TIME)
	INC	A
	CP	2
	CALL	Z,TIME2
	LD	(TIME),A
        
        pop af
        SETPG32KHIGH
        pop af
        SETPG32KLOW
        pop af
        SETPG16K

        ;call logic

        ld hl,timer
        inc (hl)

        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
        pop de
        pop bc
        pop af        
on_int_hl=$+1
	ld hl,0
on_int_sp2=$+1
	ld sp,0
	ei
on_int_jp=$+1
	jp 0

timer
        db 0

       if VIRTUALKEYS
joyTMPstate
        db 0xff
joy1state
        db 0xff
joy2state
        db 0xff
       endif
       
PLAYS
	LD	A,(SOUNDW)
	CP	0
	RET	Z
	LD	A,(MAP)
	CP	15
	JR	Z,BOSSPLA
	CP	31
	JR	Z,BOSSPLA
	CALL	#C005
	LD	A,(SOUNDW)
	DEC	A
	LD	(SOUNDW),A
	RET
BOSSPLA
	CALL	#CBB8+5
	LD	A,(SOUNDW)
	DEC	A
	LD	(SOUNDW),A
	RET
PLAYS3
	CALL	AFXFRAME
	LD	A,(SOUND1)
	DEC	A
	CP	0
	JP	Z,PLAYS4
	LD	(SOUND1),A
	RET
PLAYS4
	LD	A,(NEWLEVEL)
	CP	1
	JR	Z,PLAYS4A
	LD	A,(SOUNDGO)
	CALL	AFXPLAY
	LD	A,8
	LD	(SOUND1),A
	RET
PLAYS4A
	LD	A,(SOUNDGO)
	CP	5
	RET	Z
	CALL	AFXPLAY
	LD	A,8
	LD	(SOUND1),A
	RET
SOUND1	DEFB	8
SOUNDW	DEFB	200

kempstonbuttons
        db 0

       ifdef CLIENT
       if CLIENT
sendjoyTMP
;отправить joyTMP
        ld de,joyTMPstate ;ptr
        ld hl,1 ;сколько слать
	ld a,(datasoc)
	OS_WIZNETWRITE
	;bit 7,h
	;JR Z,SEND_OK	;ошибок нет
	;CP ERR_EMSGSIZE
	;JP NZ,ERR_EXIT	;обработка ошибки
	;OS_YIELD		;не обязательно. Если время не критично,
						;то отдадим квант времени системе.
	;JR WAIT_SEND	;буфер отправки переполнен, ждём освобождения
;SEND_OK
        ret

readstream0_retry
        halt;YIELD
readstream0
;bc=size
	push de ;ptr
	push bc ;размер
	ld h,b
        ld l,c ;ld hl,inetbuf_sz ;сколько читать
	ld a,(datasoc)
	OS_WIZNETREAD
	bit 7,h
	pop bc
	pop de ;ptr
       jr nz,readstream0_retry
 	;jr z,readstream_ok
	;cp ERR_EAGAIN
        ;jr z,readstream0 ;вдруг ответ не успел прийти
	;jp readstream_err
        ;ld hl,0 ;size
;readstream_ok
;hl=сколько прочитали
        ld a,h
        or l
        jr z,readstream0_retry
        ret

twobytes
        dw 0

readfrominet_tojoy1joy2
;hl=адрес процедуры, которую вызвать, если приняли сообщение (и так для всех сообщений в очереди)
        ld (readfrominet_call),hl
;принять одно сообщение из TCP в очередь
;если там есть, то дешифровать истинные joy1(от сервера), joy2(наш с задержкой)
;надо принять гарантированно хотя бы одно!!!
        ld de,twobytes
        call readinetqueue ;чтобы принять гарантированно хотя бы одно сообщение
inetqueue_oldsize=$+1
       ld hl,0 ;до вынимания этого сообщения (2 байт)
inetqueue_oldaddr=$+1
       ld de,0
;hl=сколько есть байтов данных
;de=где
readstream_parse0
        ld a,(de)
       or a
       jr z,readstream_parse_sync
        ld (joy1state),a
        inc de
        ld a,(de)
        ld (joy2state),a
       ;ld (logicindex),a
        inc de
        push de
        push hl
readfrominet_call=$+1
        call 0
        pop hl
        pop de
        dec hl
        dec hl
        ld a,h
        or l
        jr nz,readstream_parse0
       ld (inetqueue_cursize),hl
       ld hl,inetbuf
       ld (inetqueue_curaddr),hl
        ret
readstream_parse_sync
;неожиданно пришёл sync, перестаём парсить
       ld (inetqueue_cursize),hl
       ld (inetqueue_curaddr),de
        ret

readinetqueue_retry
       push de
        ld de,inetbuf
       ld (inetqueue_curaddr),de
        ld bc,inetbuf_sz
        call readstream0
       ld (inetqueue_cursize),hl
       pop de
readinetqueue
;читаем 2 байта из очереди в de
;если в очереди ничего нет, то подчитываем из интернета
inetqueue_cursize=$+1
        ld hl,0
inetqueue_curaddr=$+1
        ld bc,inetbuf
        ld a,h
        or l
        jr z,readinetqueue_retry
       ld (inetqueue_oldsize),hl
       ld (inetqueue_oldaddr),bc
        ld a,(bc)
        ld (de),a
        inc bc
        inc de
        dec hl
        ld a,(bc)
        ld (de),a
        inc bc
        inc de
        dec hl
       ld (inetqueue_cursize),hl
       ld (inetqueue_curaddr),bc
        ret

readinetblock
;de=addr
;hl=size (even)
        push de
        push hl
        call readinetqueue
        pop hl
        pop de
        inc de
        inc de
        dec hl
        dec hl
        ld a,h
        or l
        jr nz,readinetblock
        ret

inet_waitsync
        ;ld hl,inet_waitsync_check
        ;call readfrominet_tojoy1joy2
        ld de,twobytes;joy1state
        call readinetqueue;readstream0
        ld a,(twobytes)
        or a
        jr nz,inet_waitsync
        ld de,rndseed1
        call readinetqueue;readstream0
        ld de,rndseed2
        call readinetqueue;readstream0
        ;ld de,MESTO
        ;call readinetqueue;readstream0
       xor a
       ld (MESTO),a
        ;ld de,UNITS
        ;ld hl,UNITS_blocksz
        ;call readinetblock
       ld hl,0
       ld (logicindex),hl
       ld a,0
       ld (wrlog),a
;inet_waitsync_check
        ret

       else ;SERVER

readfrominet_tojoy2
;принять сколько получится из TCP в очередь
;если там есть полный joy2, то дешифровать для текущего фрейма логики (иначе останется старое значение joy2)
;костыль: принимаем сколько есть, если >=1, то берём последний байт
        ld de,inetbuf
;readstream0
	push de ;ptr
	;push hl ;размер
	ld hl,inetbuf_sz;1 ;сколько читать
	ld a,(datasoc)
	OS_WIZNETREAD
	bit 7,h
	;pop hl
	pop de ;ptr
	jr z,readstream_ok
	;cp ERR_EAGAIN
        ;jr z,readstream0 ;вдруг ответ не успел прийти
	;jp readstream_err
        ld hl,0 ;size
readstream_ok
;hl=сколько прочитали
        ld a,h
        or l
        jr z,serv_gotnothing
        add hl,de
        dec hl
        ld a,(hl) ;last byte received
        ld (joy2state),a
serv_gotnothing
        ret

sendjoy1joy2
       ld a,(joyTMPstate)
       ld (joy1state),a ;атомарно
       ;ld a,(joy2state)
       ;push af
       ;ld a,(logicindex)
       ;ld (joy2state),a
;отправить joy1, joy2
        ld de,joy1state ;ptr
        call sendjoy1joy2_de
       ;pop af
       ;ld (joy2state),a
        ret

        
sendjoy1joy2_de
        ld hl,2 ;сколько слать
	ld a,(datasoc)
	OS_WIZNETWRITE
	;bit 7,h
	;JR Z,SEND_OK	;ошибок нет
	;CP ERR_EMSGSIZE
	;JP NZ,ERR_EXIT	;обработка ошибки
	;OS_YIELD		;не обязательно. Если время не критично,
						;то отдадим квант времени системе.
	;JR WAIT_SEND	;буфер отправки переполнен, ждём освобождения
;SEND_OK
        ret

sendblock
;de=addr
;hl=size (even)
        push de
        push hl
        call sendjoy1joy2_de
        pop hl
        pop de
        inc de
        inc de
        dec hl
        dec hl
        ld a,h
        or l
        jr nz,sendblock
        ret

inet_sendsync
        ld de,twozeros
        call sendjoy1joy2_de
        ld de,rndseed1
        call sendjoy1joy2_de
        ld de,rndseed2
        call sendjoy1joy2_de
        ;ld de,MESTO
        ;call sendjoy1joy2_de
       xor a
       ld (MESTO),a
        ;ld de,UNITS
        ;ld hl,UNITS_blocksz
        ;call sendblock
       ld hl,0
       ld (logicindex),hl
       ld a,0
       ld (wrlog),a
        ret
twozeros
        dw 0
        
       endif ;SERVER

wrlog
       ret ;/nop
logicindex=$+1
        ld hl,0
        ld (logportion+0),hl
        ld hl,(joy1state)
        ld (logportion+2),hl
        ld hl,(rndseed1)
        ld (logportion+4),hl
        ld hl,(rndseed2)
        ld (logportion+6),hl
loghandle=$+1
        ld b,0
        ld de,logportion
        ld hl,8
        OS_WRITEHANDLE
        
        ld hl,(logicindex)
        ld a,h
        cp 15
        ret c
       ld a,0xc9
       ld (wrlog),a
       ld a,(loghandle)
       ld b,a
       OS_CLOSEHANDLE
        ret

logportion
        ds 8 ;time,joy1joy2,rndseed1,rndseed2

       endif
