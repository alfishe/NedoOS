;EXPORT:
;initstdio
;receivechar (macro GETCHAR_) - read char from stdin (out: A=char, CY=error)
;receivekey (macro GETKEY_) - read key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
;yieldgetkeyloop - wait key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
;setcolor (macro SETCOLOR_) - set color attribute (in: A=attribute=0bPIpppiii)
;setink
;setxy (macro SETXY_) - set cursor position (in: de=YX, top left is 0;0)
;sendchar (macro PRCHAR_) - send char to stdout (in: A=char)
;sendchars - send chars to stdout (in: de=buf, hl=size, out: A=error)
;setstdouthandle - in: A=handle
;setstdinhandle - in: A=handle

initstdio
        OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ld a,e
        ld (stdinhandle),a
        ld a,d
setstdouthandle
        ld (stdouthandle),a
        ret
setstdinhandle
        ld (stdinhandle),a
        ret

yieldgetkeyloop
;wait key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
;в одном фрейме может прийти много кнопок (управл€ющий esc-код)!
	YIELDKEEP
        jr yieldgetkey_afteryield
yieldgetkey_nokey
        YIELD ;если в прошлый раз ничего не было, то YIELD, а не YIELDKEEP
yieldgetkey_afteryield
        call receivekey
         ret c ;error
        or a ;cp NOKEY ;keylang==0?
        jr nz,$+3
        cp c ;keynolang==0?
        jr z,yieldgetkey_nokey
         scf
         ccf ;no error
        ret

setcolor
;set color attribute (in: A=attribute=0bPIpppiii)
;CSI Pm m Character Attributes (SGR)
;Ps = 30  Set foreground color to Black.
;Ps = 31  Set foreground color to Red.
;Ps = 32  Set foreground color to Green.
;Ps = 33  Set foreground color to Yellow.
;Ps = 34  Set foreground color to Blue.
;Ps = 35  Set foreground color to Magenta.
;Ps = 36  Set foreground color to Cyan.
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
;Ps = 8   Invisible, i.e., hidden, ECMA-48 2nd, VT300.
;Ps = 28  Visible, i.e., not hidden, ECMA-48 3rd, VT300.
;1  -  BRIGHT ON: ¬ключение €ркости INK. (Bold, VT100.)
;21  -  BRIGHT OFF: ¬ыключение €ркости INK. (Doubly-underlined, ECMA-48 3rd.)
        push af
        ld a,0x1b
        call sendchar_byte_a
        ld a,'['
        call sendchar_byte_a
        pop af
        and 7
        add a,30 ;TODO paper, bright
        call sendchar_num
        ld a,'m'
        jp sendchar_byte_a

setcolor_invisible
        ld a,0x1b
        call sendchar_byte_a
        ld a,'['
        call sendchar_byte_a
        ld a,8
        call sendchar_num
        ld a,'m'
        jp sendchar_byte_a
        
setcolor_visible
        ld a,0x1b
        call sendchar_byte_a
        ld a,'['
        call sendchar_byte_a
        ld a,28
        call sendchar_num
        ld a,'m'
        jp sendchar_byte_a

clearterm
        ld b,24
clearterm0
        push bc
        ld de,clearterm_data
        ld hl,80
        call sendchars
        pop bc
        djnz clearterm0
        ld de,clearterm_data
        ld hl,79
        call sendchars
        ld de,0
        jp setxy
clearterm_data
        ds 80,' '

setxy
;set cursor position (in: de=YX, top left is 0;0)
        push de
        ld a,0x1b
        call sendchar_byte_a
        ld a,'['
        call sendchar_byte_a
        pop de
        push de
        ld a,d
        inc a
        call sendchar_num
        ld a,';'
        call sendchar_byte_a
        pop de
        ld a,e
        inc a
        call sendchar_num
        ld a,'H'
        jr sendchar_byte_a

sendchar_num
;a=num
        ld c,'0'-1
        inc c
        sub 10
        jr nc,$-3
        push af
        ld a,c
        call sendchar_byte_a
        pop af
        add a,'0'+10
        jr sendchar_byte_a

sendchar
        ;cp 0x80
        ;jr nc,sendchar_rustoutf8
sendchar_byte_a
        ld (stdoutbuf),a
        ld hl,1
        ld de,stdoutbuf
sendchars
;send chars to stdout (in: de=buf, hl=size, out: A=error)
sendchars0
        push de
        push hl
stdouthandle=$+1
        ld b,0
        OS_WRITEHANDLE ;1436t ;[2718t (1225 before BDOS_writehandle + 195 before BDOS_writehandle_pipe + 477 ..findpipe_byhandle + 301 pipe + 192 end BDOS_writehandle + 326 end BDOS)]
        ld b,h
        ld c,l ;bytes actually written
        pop hl
        pop de
         or a
          ret nz ;error ;TODO обработать? а так пока просто избегаем зацикливани€
         sbc hl,bc ;datasize-byteswritten
         ret z
         ex de,hl
         add hl,bc ;dataaddr+byteswritten
         ex de,hl
;hl=remaining data size
;de=remaining data addr
        push de
        push hl
        YIELDKEEP ;2158t
        pop hl
        pop de
        jr sendchars0

receivechar
;read char from stdin (out: A=char, CY=error)
        ld hl,1
        ld de,stdinbuf
stdinhandle=$+1
        ld b,0
        OS_READHANDLE
        or a
        scf
        ret nz ;error
        ld a,h
        or l
        ;ld c,a
        ret z ;NC=no error
        ld a,(stdinbuf)
        ret ;NC=no error
        
receivekey
;read key from stdin (out: A=keylang, C=keynolang(???TODO), CY=error)
        call receivechar
        ret c ;error
;a=char
TERM_ST_SINGLE=1 ;1: wait for single symbol
TERM_ST_AFTERESC=2 ;2: after 0x1b
TERM_ST_AFTERESCBRACKET=2 ;3: after 0x1b [ [number] (might be more digits)
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
        jr term_prfsm_nokey
term_prfsm_nosingle
        djnz term_prfsm_noafteresc
        cp '['
        ld c,0x1b
        jr nz,term_prfsm_keycok ;esc esc -> esc_key
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERESCBRACKET
term_prfsm_0curnumber_nokey
        xor a
        ld (term_prfsm_curnumber),a
        ;xor a ;no key, no error
        ld c,a
        ret
term_prfsm_noafteresc
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
        jr z,term_prfsm_afterescbracket_tilde
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
term_prfsm_nokey
        xor a ;no key, no error
        ld c,a
        ret
term_prfsm_afterescbracket_tilde
        ld a,(term_prfsm_curnumber)
        cp 3
        ld c,key_del
        jr z,term_prfsm_keycok
        cp 1
        ld c,key_home
        jr z,term_prfsm_keycok
        cp 4
        ld c,key_end
        jr z,term_prfsm_keycok
        cp 2
        ld c,key_ins
        jr z,term_prfsm_keycok
        jr term_prfsm_nokey

term_prfsm_keycok
        ld hl,term_prfsm_curstate
        ld (hl),TERM_ST_SINGLE
        xor a
        or c ;NC=no error
        ret

term_prfsm_curnumber
         db 0
term_prfsm_curnumber1
         db 0

stdoutbuf
        db 0

stdinbuf
        db 0 ;ds STDINBUF_SZ
