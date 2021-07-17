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
        ld (joy1state),a
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

       ifdef CLIENT
       if TCP
       if CLIENT
;отправить joy1
        ld de,joy1state ;ptr
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

;принять сколько получится из TCP в очередь
;если там есть, то дешифровать истинные joy1(от сервера), joy2(наш с задержкой)
;костыль: принимаем сколько есть, если >=2, то берём последние 2 байта
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
        ld bc,2
        or a
        sbc hl,bc
        jr c,client_gotnothing
        add hl,de
        ld a,(hl)
        ld (joy1state),a
        inc hl
        ld a,(hl)
        ld (joy2state),a
client_gotnothing

       else ;SERVER
;принять сколько получится из TCP в очередь
;если там есть полный joy2, то дешифровать
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

;отправить joy1, joy2
        ld de,joy1state ;ptr
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
        
       endif
       else ;UDP
;TODO
       if CLIENT
       else ;SERVER
       endif
       endif
       endif
        
        ld a,(curpg16k) ;ok
        push af
        ld a,(curpg32klow) ;ok
        push af
        ld a,(curpg32khigh) ;ok
        push af
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
joy1state
        db 0xff
joy2state
        db 0xff
       endif
       
       ifdef CLIENT
inetbuf_sz=256
inetbuf
        ds inetbuf_sz
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
