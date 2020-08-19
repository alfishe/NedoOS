;EXPORT:
;initstdio
;receivechar (macro GETCHAR_) - read char from stdin (out: A=char, CY=error)
;receivechars - read chars from stdin (de=buf, hl=size, out: bc=bytes actually read (if EOF), CY=error(EOF))
;receivekey (macro GETKEY_) - read key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
;yieldgetkeyloop - wait key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
;setcolor (macro SETCOLOR_) - set color attribute (in: d=paper, e=ink)
;setcolor_invisible - NON-STANDARD
;setcolor_visible - NON-STANDARD
;scrolldown ;de=topyx, hl=hgt,wid ;x, wid even
;scrollup ;de=topyx, hl=hgt,wid ;x, wid even
;setxy (macro SETXY_) - set cursor position (in: de=YX, top left is 0;0)
;setx (macro SETX_) - set cursor X position (in: e=X, left is 0)
;sendchar (macro PRCHAR_) - send char to stdout (in: A=char)
;sendchars - send chars to stdout (in: de=buf, hl=size, out: A=error)
;setstdouthandle - in: A=handle
;setstdinhandle - in: A=handle
;clearrestofline - clear line after cursor
;clearrestofline_crlf - clear line after cursor, go to next line
;clearterm - print 25 lines of spaces except one

STDINBUF_SZ=255

initstdio
        ;OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
		ld c,CMD_GETSTDINOUT
		call BDOS
        ld a,e
        ld (stdinhandle),a
        ld a,d
setstdouthandle
        ld (stdouthandle),a
        ret
setstdinhandle
        ld (stdinhandle),a
        ret

setstdinout
        OS_GETMAINPAGES ;out: dehl=номера страниц в 0000,4000,8000,c000, c=flags, b=id
        ld a,(stdinhandle)
        ld e,a
        ld a,(stdouthandle)
        ld d,a
;b=id, e=stdin, d=stdout, h=stderr (TODO)
        OS_SETSTDINOUT
        ret

getkey
;out: NC=no error, nz=event (a=key, l=mousebuttons, de=mouxexy)
getkey0
        xor a
        ld (wasmouseevent),a
        call receivekey
         ret c ;error
        ld hl,(term_prfsm_curstate)
        dec l
        jr nz,getkey0 ;пока не примем кнопку до конца
        inc l ;nz
;был mouse event? считаем за нажатие, а приложение будет смотреть координаты и кнопку мыши
stdio_mousebuttons=$+1
        ld l,0
stdio_mousex=$+1
stdio_mousey=$+2
        ld de,0
wasmouseevent=$
        ret ;NC=no error, nz=event ;/nop
        or a
        ret

yieldgetkeyloop
;wait key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
;в одном фрейме может прийти много кнопок (управляющий esc-код)!
        ;jr yieldgetkey_afteryield
;yieldgetkey_nokey
;может быть, мы в середине esc-кода? тогда надо yieldgetkeyloop
        ;ld a,(term_prfsm_curstate)
        ;dec a
        ;jr nz,yieldgetkeyloop
        ld c,CMD_YIELD
        call BDOS	;YIELD
        call getkey
        ret c ;error
        ;ret nz ;event
        ;or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        jr z,yieldgetkeyloop ;no event
         scf
         ccf ;no error
        ret
;yieldgetkey_nokey
;может быть, мы в середине esc-кода? тогда надо yieldgetkeyloop
;        ld a,(term_prfsm_curstate)
;        dec a
;        jr nz,yieldgetkeyloop

;последовательности слать одним куском!

scrolldown
;de=topyx, hl=hgt,wid
;x, wid even
        ld b,h ;hgt
        ld c,l ;wid
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld a,c ;wid
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,b ;hgt
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,e ;topx
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,d ;topy
        call sendchar_num
        ld (hl),'d' ;NON-STANDARD!!!
        jr setcolorqq
        
scrollup
;de=topyx, hl=hgt,wid
;x, wid even
        ld b,h ;hgt
        ld c,l ;wid
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld a,c ;wid
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,b ;hgt
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,e ;topx
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,d ;topy
        call sendchar_num
        ld (hl),'u' ;NON-STANDARD!!!
        jr setcolorqq

setcolor
;set color attribute (in: d=paper, e=ink)
;CSI Pm m Character Attributes (SGR)
;Ps = 30  Set foreground color to Black.
;Ps = 31  Set foreground color to Red.
;Ps = 32  Set foreground color to Green.
;Ps = 33  Set foreground color to Yellow.
;Ps = 34  Set foreground color to Blue.
;Ps = 35  Set foreground color to Magenta.
;Ps = 36  Set foreground color to Cyan. (Grey?)
;Ps = 37  Set foreground color to White.
;Ps = 39  Set foreground color to default, ECMA-48 3rd.
;Ps = 40  Set background color to Black.
;Ps = 41  Set background color to Red.
;Ps = 42  Set background color to Green.
;Ps = 43  Set background color to Yellow.
;Ps = 44  Set background color to Blue.
;Ps = 45  Set background color to Magenta.
;Ps = 46  Set background color to Cyan.
;Ps = 47  Set background color to White.
;Ps = 49  Set background color to default, ECMA-48 3rd.
;Ps = 8   Invisible, i.e., hidden, ECMA-48 2nd, VT300. (не работает в Putty!!!)
;Ps = 28  Visible, i.e., not hidden, ECMA-48 3rd, VT300. (не работает в Putty!!!)
;Assume that xterm's resources are set so that the ISO color codes are the first 8 of a set of 16. Then the aixterm colors are the bright versions of the ISO colors:
;Ps = 90  Set foreground color to Black.
;Ps = 91  Set foreground color to Red.
;Ps = 92  Set foreground color to Green.
;Ps = 93  Set foreground color to Yellow.
;Ps = 94  Set foreground color to Blue.
;Ps = 95  Set foreground color to Magenta.
;Ps = 96  Set foreground color to Cyan.
;Ps = 97  Set foreground color to White.
;TODO 1  -  BRIGHT ON: Включение яркости INK. (Bold, VT100.)
;TODO 22 - Normal (neither bold nor faint), ECMA-48 3rd. [21  -  BRIGHT OFF: Выключение яркости INK. (Doubly-underlined, ECMA-48 3rd.)]
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld a,e ;a=ink
        cp 8
        jr c,$+4
        add a,90-30-8
        add a,30
        call sendchar_num
        ld (hl),';'
        inc hl
        ld a,d ;a=paper
        and 7
        add a,40
setcolorq
        call sendchar_num
        ld (hl),'m'
setcolorqq
        inc hl
       pop de
       or a
       sbc hl,de ;de=buf, hl=size
        jp sendchars

setcolor_invisible
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld a,8
        jr setcolorq
        
setcolor_visible
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld a,28
        jr setcolorq

clearrestofline
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld (hl),'K'
        jr setcolorqq

clearterm
        ld a,0x0d ;carriage return
        call sendchar
        ld b,24
clearterm0
        push bc
        ;ld de,clearterm_data
        ;ld hl,80
        ;call sendchars
        call clearrestofline_crlf
        pop bc
        djnz clearterm0
        ;ld de,clearterm_data
        ;ld hl,79
        ;call sendchars
        call clearrestofline
        ld de,0
        jp setxy
;clearterm_data
;        DEFB "                                                                                "

clearrestofline_crlf
        ld de,tclearrestofline_crlf
        ld hl,tclearrestofline_crlf_sz
        jp sendchars
tclearrestofline_crlf
        DEFB 0x1b,'[','K',0x0d,0x0a
tclearrestofline_crlf_sz=$-tclearrestofline_crlf

setxy
;set cursor position (in: de=YX, top left is 0;0)
        ld hl,stdoutbuf
       push hl
        ;push de
        ;ld a,0x1b
        ;call sendchar_byte_a
        ld (hl),0x1b
        inc hl
        ;ld a,'['
        ;call sendchar_byte_a
        ld (hl),'['
        inc hl
        ;pop de
        ;push de
        ld a,d ;y
        inc a
        call sendchar_num
        ;ld a,';'
        ;call sendchar_byte_a
         ld (hl),';'
         inc hl
        ;pop de
        ld a,e ;x
        inc a
        call sendchar_num
        ;ld a,'H'
        ld (hl),'H'
        jp setcolorqq

setx
;set cursor X position (in: e=X, left is 0)
        ld hl,stdoutbuf
       push hl
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld a,e ;x
        inc a
        call sendchar_num
        ld (hl),'G'
        jp setcolorqq

sendchar_num
;a=num
        push bc
        ld c,'0'-1
        inc c
        sub 10
        jr nc,$-3
        ;push af
        ;ld a,c
        ;call sendchar_byte_a
        ;pop af
         ld (hl),c
         inc hl
        add a,'0'+10
        ;jr sendchar_byte_a
         ld (hl),a
         inc hl
        pop bc
        ret

sendchar
        ;cp 0x80
        ;jr nc,sendchar_rustoutf8
;sendchar_byte_a
        ld (stdoutbuf),a
        ld hl,1
        ld de,stdoutbuf
sendchars
;send chars to stdout (in: de=buf, hl=size, out: A=error)
        xor a
        ld (sendchars_yieldkeepcount),a
sendchars0
        push de
        push hl
stdouthandle=$+1
        ld b,0
        ld c,CMD_WRITEHANDLE
        call BDOS;OS_WRITEHANDLE ;1436t ;[2718t (1225 before BDOS_writehandle + 195 before BDOS_writehandle_pipe + 477 ..findpipe_byhandle + 301 pipe + 192 end BDOS_writehandle + 326 end BDOS)]
        ld b,h
        ld c,l ;bytes actually written
        pop hl
        pop de
         or a
          ret nz ;error ;TODO обработать? а так пока просто избегаем зацикливания
         sbc hl,bc ;datasize-byteswritten
         ret z
         ex de,hl
         add hl,bc ;dataaddr+byteswritten
         ex de,hl
;hl=remaining data size
;de=remaining data addr
        push de
        push hl
;чтобы избежать бесконечного YIELDKEEP с постоянным попаданием прерывания в керналь
;ограничим число YIELDKEEP, а потом будет YIELD
sendchars_yieldkeepcount=$+1
        ld a,0
        sub 8
        ld (sendchars_yieldkeepcount),a
        ld c,CMD_YIELDKEEP
        jr nc,$+4
        ld c,CMD_YIELD
        call BDOS ;YIELDKEEP ;2158t
        pop hl
        pop de
        jr sendchars0

;receivechars - read chars from stdin
receivechars
;de=buf, hl=size
;out: de=end addr in buf (if EOF), CY=error(EOF))
receivechars0
        push de
        push hl
        ld a,(stdinhandle)
        ld b,a
        ld c,CMD_READHANDLE
        call BDOS ;OS_READHANDLE ;hl=size actually received
        ld b,h
        ld c,l
        pop hl
        pop de
        or a
        scf
        ret nz ;error
        ex de,hl
        add hl,bc ;addr+=readed
        ex de,hl
        or a
        sbc hl,bc ;size-=readed
        jr nz,receivechars0
        ret

receivechar
;read char from stdin (out: A=char(maybe 0), CY=error)
stdindatacount=$+1
        ld a,0
        or a
        jr z,receivechar_doreceive
        dec a
        ld (stdindatacount),a
stdindatapointer=$+1
        ld hl,0
        ld a,(hl)
        inc hl
        ld (stdindatapointer),hl
        or a ;NC=no error
        ret
receivechar_doreceive
        ld hl,STDINBUF_SZ
        ld de,stdinbuf
        ld (stdindatapointer),de
stdinhandle=$+1
        ld b,0
        ld c,CMD_READHANDLE
        call BDOS ;OS_READHANDLE ;hl=size actually received
        or a
        scf
        ret nz ;error
        ld a,h
        or l
        ;ld c,a
        ret z ;NC=no error
        ;ld a,l
        ld (stdindatacount),a
        jr receivechar

receivekey
;read key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
        call receivechar
        ret c ;error
         or a
         ld c,a
         ret z ;NC=no error
;a=char
TERM_ST_SINGLE=1 ;1: wait for single symbol
TERM_ST_AFTERESC=2 ;2: after 0x1b
TERM_ST_AFTERESCBRACKET=3 ;3: after 0x1b [ [number] (might be more digits)
TERM_ST_AFTERMOUSE=4
TERM_ST_AFTERMOUSEb=5
TERM_ST_AFTERMOUSEbx=6
term_prfsm_curstate=$+1
        ld b,TERM_ST_SINGLE
        djnz term_prfsm_nosingle
         ;cp 0x0a
         ;ld c,0x0d
         ;jp z,term_prfsm_keycok
        cp 0x1b
        ld c,a
        jp nz,term_prfsm_keycok
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERESC
        jp term_prfsm_nokey
term_prfsm_nosingle
        djnz term_prfsm_noafteresc
        cp 'O'
        jr z,escO
        ;cp '['
        ld c,0x1b
        cp c
        jp z,term_prfsm_keycok ;esc esc -> esc_key
escO ;костыль! esc O P/Q/R/S = F1..F4
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERESCBRACKET
term_prfsm_0curnumber_nokey
        xor a
        ld (term_prfsm_curnumber),a
        ;xor a ;no key, no error
        ld c,a
        ret
term_prfsm_noafteresc
        djnz term_prfsm_noafterescbracket
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
        jr term_prfsm_nokey
term_prfsm_afterescbracket_nonumber
        add a,'0'
        cp ';'
        jr nz,term_prfsm_afterescbracket_nosemicolon
        ld a,(term_prfsm_curnumber)
        ld (term_prfsm_curnumber1),a
        jr term_prfsm_0curnumber_nokey
term_prfsm_afterescbracket_nosemicolon
        ld hl,term_prfsm_curstate
        ld (hl),TERM_ST_SINGLE
        ;cp 'H'
        cp '~'
        jp z,term_prfsm_afterescbracket_tilde
        cp 'A'
        ld c,key_up
        jr z,term_prfsm_keycok
        cp 'B'
        ld c,key_down
        jr z,term_prfsm_keycok
        cp 'C'
        ld c,key_right
        jr z,term_prfsm_keycok
        cp 'D'
        ld c,key_left
        jr z,term_prfsm_keycok
         cp 'P'
         ld c,key_F1
         jr z,term_prfsm_keycok
         cp 'Q'
         ld c,key_F2
         jr z,term_prfsm_keycok
         cp 'R'
         ld c,key_F3
         jr z,term_prfsm_keycok
         cp 'S'
         ld c,key_F4
         jr z,term_prfsm_keycok
        cp 'M'
        jr z,term_prfsm_mouse
term_prfsm_nokey
        xor a ;no key, no error
        ld c,a
        ret
;escO
;        jr $
term_prfsm_noafterescbracket
        djnz term_prfsm_noaftermouse
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERMOUSEb
         and 0x1f ;TODO как отличить движение мыши от unclick?
         ld l,0xff
         dec a
         jr nz,$+3
         dec l
         dec a
         jr nz,$+4
         res 1,l
         dec a
         jr nz,$+4
         res 2,l
         ld a,l
         ld (stdio_mousebuttons),a
        xor a ;no key, no error
        ld c,a
        ret
term_prfsm_noaftermouse
        djnz term_prfsm_aftermousebx;term_prfsm_noaftermouseb
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERMOUSEbx
         sub 32
         ld (stdio_mousex),a
        xor a ;no key, no error
        ld c,a
        ret
term_prfsm_aftermousebx
        ld hl,term_prfsm_curstate
        ld (hl),TERM_ST_SINGLE
         sub 32
         ld (stdio_mousey),a
        ld a,0xc9
        ld (wasmouseevent),a
        xor a ;no key, no error
        ld c,a
        ret

term_prfsm_keycok
        ld hl,term_prfsm_curstate
        ld (hl),TERM_ST_SINGLE
        xor a
        or c ;NC=no error
        ret
term_prfsm_mouse
        ld hl,term_prfsm_curstate
        ld (hl),TERM_ST_AFTERMOUSE
        xor a ;no key, no error
        ld c,a
        ret

term_prfsm_afterescbracket_tilde
        ld a,(term_prfsm_curnumber)
;        if 1==1
;        display $
        cp tcontrolkeys_sz
        jr nc,term_prfsm_nokey
        ld hl,tcontrolkeys
        add a,l
        ld l,a
        jr nc,$+3
        inc h
        ld c,(hl)
        jr term_prfsm_keycok
;        else
;        cp 3
;        ld c,key_del
;        jr z,term_prfsm_keycok
;        cp 1
;        ld c,key_home
;        jr z,term_prfsm_keycok
;        cp 4
;        ld c,key_end
;        jr z,term_prfsm_keycok
;        cp 2
;        ld c,key_ins
;        jr z,term_prfsm_keycok
;        cp 5
;        ld c,key_pgup
;        jr z,term_prfsm_keycok
;        cp 6
;        ld c,key_pgdown
;        jr z,term_prfsm_keycok
;        endif
        jr term_prfsm_nokey

tcontrolkeys
        DEFB 0
        DEFB key_home ;1
        DEFB key_ins ;2
        DEFB key_del ;3
        DEFB key_end ;4
        DEFB key_pgup ;5
        DEFB key_pgdown ;6
        DEFB 0 ;7
        DEFB 0 ;8
        DEFB 0 ;9
        DEFB 0 ;10
        DEFB key_F1 ;11
        DEFB key_F2 ;12
        DEFB key_F3 ;13
        DEFB key_F4 ;14
        DEFB key_F5 ;15
        DEFB 0 ;16
        DEFB key_F6 ;17
        DEFB key_F7 ;18
        DEFB key_F8 ;19
        DEFB key_F9 ;20
        DEFB key_F10 ;21
        ;DEFB 0 ;22
        ;DEFB key_F11 ;23
        ;DEFB key_F12 ;24
tcontrolkeys_sz=$-tcontrolkeys

term_prfsm_curnumber
         DEFB 0
term_prfsm_curnumber1
         DEFB 0

stdoutbuf
        DEFB "-[00;00;00;00m"

stdinbuf
        DEFS STDINBUF_SZ
