        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

;при закрытии cmd term должен закрыться

RECODEINPUT=1

READPASTABUF_SZ=80
STDINBUF_SZ=256

HTMLTOPY=0
HTMLHGT=25

COLOR=7
CURSORCOLOR=0x38

REPEATNOKEY=2 ;0

        macro BDOSSETPGSSCR
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        SETPG32KHIGH
        endm

        org PROGSTART
begin
        ld sp,0x4000
        OS_HIDEFROMPARENT
        ld e,6 ;textmode
        OS_SETGFX
        ld de,ansipal
        OS_SETPAL
        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
        ld a,e
        ld (pgscrbuf),a
	push hl
	ld e,l
	OS_DELPAGE
	pop hl
	ld e,h
	OS_DELPAGE

        OS_SETSYSDRV
 
        ld de,tpipename
        push de
        OS_OPENHANDLE
        ld a,b
        ld (stdinhandle),a
        pop de
        OS_OPENHANDLE
        ld a,b
        ld (stdouthandle),a
        
        ld e,COLOR
        call BDOS_cls

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

        ld hl,trecode
        ld d,trecodeback/256
maketrecodeback0
        ld e,(hl)
        ld a,l
        ld (de),a
        inc l
        jr nz,maketrecodeback0

execcmd_error
mainloop_afternokey
;если два раза подряд нет событий, то надо делать YIELD, иначе YIELDKEEP
;т.е. когда нет событий, идёт всё время YIELD. А если событие,пусто,событие,пусто, то всё время YIELDKEEP
;тогда курсор исчезает - плохо
        if REPEATNOKEY != 0
wasnokey=$+1
        ld a,1
        dec a
        jr nz,mainloop_yieldkeep
        ;scf
        ;ld a,55 ;"scf"
        ;ld (wasnokey),a
        ;jr nc,mainloop_yieldkeep
        endif
       call printcursor
         ld hl,(pr_buf_curaddr)
         ld (wascursorcuraddr),hl        
        call getmousexy
        ld (mousecursor_wasxy),de
        call BDOS_countattraddr_mousecursor
        ld a,(hl)
        cpl
        ld (hl),a
         ;ld (hl),CURSORCOLOR

        YIELD
        ld a,(pgscrbuf) ;ok
        SETPG16K
        call BDOS_countattraddr
wascursorcuraddr=$+1
        ld de,killbuf_byte
        ld a,e
        add a,0x40 ;attr
        adc a,0
        ld e,a
        ld a,(de) ;из pgscrbuf
        ld (hl),a;COLOR

        jr mainloop_afterkeyq
mainloop_afterkey
        if REPEATNOKEY != 0
        ;ld a,55+128 ;"or a"
        ;ld (wasnokey),a
        ld a,REPEATNOKEY;2
mainloop_yieldkeep
        ld (wasnokey),a
        endif
        YIELDKEEP
mainloop_afterkeyq
mousecursor_wasxy=$+1
        ld de,0
         call getscrbuftop_a
         add a,d ;0..24
         ld h,a
         ld a,e
         or 0x80
         rrca ;(x/2)+0x40 или 0xc0
        add a,0x40 ;attr
        adc a,0
        ld l,a
        ld a,(hl) ;из pgscrbuf
        push af
        call BDOS_countattraddr_mousecursor
        pop af
        ld (hl),a ;screen

mainloop_afterredraw
        
waitpid_id=$+1
        ld e,0
        OS_WAITPID ;TODO проверять, что пайп с той стороны не закрыт
        or a
        jp z,quit
        
        jr mainloop_type0_go
mainloop_type0
        YIELDKEEP

mainloop_type0_go
        call type_stdin ;stdin to screen
        jr nc,mainloop_type0 ;data present
       
        if 1==0
;if long time no message from stdin, print cursor
        OS_GETTIMER ;hlde=timer
        push de
        ex de,hl
lastsdtinmsgtimer=$+1
        ld de,0
         ;ld (lastsdtinmsgtimer),hl
        or a
        sbc hl,de ;hl=timer-oldtimer
cursortimelimit=$+1
        ld bc,1
        or a
        sbc hl,bc
        pop hl
        jr c,noprintcursor
         ;ld (lastsdtinmsgtimer),hl
        
        ld a,4
        out (0xfe),a
        call printcursor
        ld a,1
        ld (cursortimelimit),a

        ld a,2
        out (0xfe),a
        jr noprintcursorq
noprintcursor
        ld a,7
        out (0xfe),a
noprintcursorq
        endif

        GET_KEY ;out: a=key (NOKEY=no key), de=mouse position (y,x), l=mouse buttons (bits 0,1,2: 0=pressed)+mouse wheel (bits 7..4), h=high bits of key|register, bc=keynolang, nz=no focus (mouse position=0, ignore it!)
        jp nz,mainloop_afternokey ;no focus

        ;or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        ;jp z,mainloop_afternokey
        cp key_redraw
        jp z,term_redraw
        ld b,a

        ld a,l
        and 0xf0
control_imer_oldmousewheel=$+2
        ld hx,0
        ld (control_imer_oldmousewheel),a
        sub hx
        ;ld (mouse_scrollvalue),a
        jr z,nowheelmove
        jp m,term_pgdown
        jp term_pgup
nowheelmove
        ;ld a,0
        ;ld (mouse_scrollvalue),a ;default scrollvalue

        ld a,b
        or a
        jp nz,term_sendchar        
;no action? mouse coords change is also an action
control_imer_oldmousecoords=$+1
        ld bc,0
        ld (control_imer_oldmousecoords),de
        ld a,b
        sub d
        ld d,a
        ld a,e
        sub c
        ld e,a
        or d
        jr z,nomousemove
        push hl
        call mousemove
        pop hl
        jr sendmouseevent
nomousemove
        ld a,l ;mouse buttons
oldmousebuttons=$+1
        ld h,0
        ld (oldmousebuttons),a
        xor h
        and 7
        jr nz,sendmouseevent
        jp mainloop_afternokey
sendmouseevent
        ld a,l
        cpl
        and 7
        jr z,sendmouseevent_noclick
        call getmousexy
        ld a,d
        or e
        jr nz,sendmouseevent_noclicktopleft
        ld de,tpastaname
        OS_CREATEHANDLE
        ld a,b
        ld (pastahandle),a
        
        ld a,(pgscrbuf)
        SETPG16K
        ld hl,0x4040
savepasta0
        push hl
        call savepastaline
        pop hl
        inc h
        jp p,savepasta0        
        ld a,(pastahandle)
        ld b,a
        OS_CLOSEHANDLE
        jp mainloop_afterkey
sendmouseevent_noclicktopleft
        ld a,d
        sub 24
        or e
        jr nz,sendmouseevent_click
        ld de,tpastaname
        OS_OPENHANDLE
        ld a,b
        ld (pastahandle),a
        ld de,readpastabuf
        push de
        ld hl,READPASTABUF_SZ
        OS_READHANDLE ;hl=реально прочитано
        pop de
        call sendchars
        ld a,(pastahandle)
        ld b,a
        OS_CLOSEHANDLE
        jp mainloop_afterkey
sendmouseevent_noclick
        ld b,'@' ;mouse move
        jr sendmouseevent_ok
sendmouseevent_click
        ld a,l ;mouse buttons
        ld b,1+32
        rra
        jr nc,sendmouseevent_ok
        inc b
        rra
        jr nc,sendmouseevent_ok
        inc b
        rra
        jr nc,sendmouseevent_ok
        ld b,0+32 ;unclick
sendmouseevent_ok
;send mousemove event
        ld hl,stdoutbuf
        ld (hl),0x1b
        inc hl
        ld (hl),'['
        inc hl
        ld (hl),'M'
        inc hl
        ld (hl),b
        inc hl
        call getmousexy
         ld a,e
         add a,32
        ld (hl),a
        inc hl
         ld a,e
         add a,32
        ld (hl),a
        ld de,stdoutbuf
        ld hl,6
        call sendchars
        jp mainloop_afterkey
        
printcursor
         ;ld hl,4
         ;ld (cursortimelimit),hl
        call BDOS_countattraddr
        ld (hl),CURSORCOLOR
        ret

term_sendchar
        cp key_esc
        jr z,term_esckey
        if RECODEINPUT
        call sendkey
        else
        call sendchar_byte_a
        endif
        jp mainloop_afterkey
term_esckey
        if RECODEINPUT
        call sendchar_byte_a
        ld a,key_esc
        call sendchar_byte_a
        else
        call sendchar_byte_a
        endif
        jp mainloop_afterkey

term_pgdown
        ld hl,redraw_scroll
        ld a,(hl)
        cp 0;24
        jr z,$+3
        dec a
        ld (hl),a
        call redraw
        jp mainloop_afterredraw
term_pgup
        ld hl,redraw_scroll
        ld a,(hl)
        cp 63 -24
        jr z,$+3
        inc a
        ld (hl),a
        call redraw
        jp mainloop_afterredraw

term_redraw
        ld hl,redraw_scroll
        ld (hl),0
        call redraw
        jp mainloop_afterredraw

redraw_to_base
        ld hl,redraw_scroll
        inc (hl)
        dec (hl)
        ret z
        ld (hl),0
        push af
        call redraw
        pop af
        ret
redraw
;scrbuf состоит из строк длиной 256 байт
;каждая из них из 4 слоёв:
;+0x40: аналог +0x4000 (text0) ;1
;+0x80: аналог +0x2000 (attr0) ;3
;+0xc0: аналог +0x6000 (text1) ;2
;+0x01: аналог +0x0001 (attr1) ;4
        ld a,(pgscrbuf)
        SETPG16K
        BDOSSETPGSSCR
         call getscrbuftop_a
        ld h,a
        ld de,0xc1c0
        ld b,25
redrawlines0
        push bc
        ld l,0x40
        push de
        call copylinelayer
        set 5,d
        set 7,l
        call copylinelayer
        res 6,d
        res 6,l
        call copylinelayer
        res 5,d
        res 7,l
        call copylinelayer
        pop de
        ex de,hl
        ld bc,0x0040
        add hl,bc
        ex de,hl
        inc h ;TODO nextpg
        pop bc
        djnz redrawlines0
        ret
        
quit
;cmd closed!!!

        dup 2 ;close twice - as stdin and as stdout! на случай, если клиент не закрыл у себя
        ld a,(stdinhandle)
        ld b,a
        OS_CLOSEHANDLE
        ld a,(stdouthandle)
        ld b,a
        OS_CLOSEHANDLE
        edup
        QUIT

savepastaline
;hl=lineaddr
;текст лежит в 0x40, 0xc0, 0x41, 0xc1,.... 0xfe, 0x7f, 0xff
;ищем конец строки (первый символ с конца, не равный 0/0x20)
        ld l,0xc0+39 ;end of text
        ld b,80
savepastaline_findend0
        ld a,(hl)
        or a
        jr z,savepastaline_findend0ok
        cp 0x20
        jr nz,savepastaline_findendq
savepastaline_findend0ok
        ld a,l
        sub 0x80
        sbc a,0
        ld l,a
        djnz savepastaline_findend0
        jr savepastaline_skip
savepastaline_findendq
;hl=end of line
;сохраняем всю строку до конца
        ld l,0x40 ;start of text
savepastaline0
        ld a,(hl)
        or a
        jr nz,$+4
        ld a,0x20
        push bc
        push hl
        call writechar2pasta
        pop hl
        pop bc
        ld a,l
        add a,0x80
        adc a,0
        ld l,a
        djnz savepastaline0
savepastaline_skip
        ld a,0x0d
        call writechar2pasta
        ld a,0x0a
writechar2pasta
        ld d,trecodeback/256
        ld e,a
        ld a,(de)
        ld de,pastabuf
        ld (de),a
        ld hl,1
pastahandle=$+1
        ld b,0
        OS_WRITEHANDLE
        ret

getmousexy
mousexy=$+1
        ld de,0
        ret

type_stdin
;out: CY=no data
        ld de,stdinbuf
        ld hl,STDINBUF_SZ
stdinhandle=$+1
        ld b,0
        ;ld b,0xff
        OS_READHANDLE ;6933t (incl. 5350=ldir 255 bytes)
;hl=size
        ld a,h
        or l
        scf ;out: CY=no data
        ret z ;jr z,nostdinmsg;mainloop_afterkey
        if REPEATNOKEY != 0
         ld a,REPEATNOKEY;2
         ld (wasnokey),a
        endif

        push hl
        call redraw_to_base
         ;OS_GETTIMER ;hlde=timer
         ;ld (lastsdtinmsgtimer),de
        BDOSSETPGSSCR
pgscrbuf=$+1
        ld a,0 ;ok
        SETPG16K
        pop bc
        push bc
        ld b,c
        ld hl,stdinbuf
TERM_ST_SINGLE=1 ;wait for single symbol
TERM_ST_AFTERESC=2 ;after 0x1b
TERM_ST_AFTERESCBRACKET=3 ;after 0x1b [ [number] (might be more digits)
term_prfsmcurstate=$+1
         ld a,TERM_ST_SINGLE
         dec a
         jr nz,term_prfsm
term_print0
        ld a,(hl)
        cp 0x1b+1
        jr c,term_print0_maybecontrolcode
        push hl
        call BDOS_prchar_a_nocrlf ;226/227t
        ;call term_prfsm ;520/521t
        pop hl
term_print0_maybecontrolcodeq
        inc hl
        djnz term_print0
         ld a,TERM_ST_SINGLE
        jp term_print0q
term_print0_maybecontrolcode
        cp 0x1b
        jr z,term_prfsm_afteresc ;next state
        push hl
        call BDOS_prchar_a
        pop hl
        jp term_print0_maybecontrolcodeq
        
term_prfsm
         dec a
         jr nz,term_prfsm_afterescbracket
term_prfsm_afteresc0
        xor a
        ld (term_prfsm_curnumber),a
        ld (term_prfsm_curnumber1),a
        ld (term_prfsm_curnumber2),a
        ld (term_prfsm_curnumber3),a
        ;ld a,(hl) ;todo check bracket
        jp term_prfsm_afterescbracket_ok ;next state
term_prfsm_afteresc
        inc hl
        djnz term_prfsm_afteresc0
         ld a,TERM_ST_AFTERESC
        jp term_print0q

term_prfsm_afterescbracket_nosemicolon
        push hl
        call term_prfsm_letter
        pop hl
        jp term_print0_maybecontrolcodeq ;initial state
term_prfsm_afterescbracket
term_prfsm_afterescbracket0
        ld a,(hl)
        sub '0'
        cp 10
        jr nc,term_prfsm_afterescbracket_nonumber
        ;push de
        ld e,a
        ld a,(term_prfsm_curnumber)
        ld d,a
        add a,a
        add a,a
        add a,d
        add a,a ;*10
        add a,e
        ld (term_prfsm_curnumber),a
        ;pop de
        jp term_prfsm_afterescbracket_ok
term_prfsm_afterescbracket_nonumber
        add a,'0'
        cp ';'
        jr nz,term_prfsm_afterescbracket_nosemicolon
        ld a,(term_prfsm_curnumber2)
        ld (term_prfsm_curnumber3),a
        ld a,(term_prfsm_curnumber1)
        ld (term_prfsm_curnumber2),a
        ld a,(term_prfsm_curnumber)
        ld (term_prfsm_curnumber1),a
        xor a
        ld (term_prfsm_curnumber),a
term_prfsm_afterescbracket_ok
        inc hl
        djnz term_prfsm_afterescbracket0
         ld a,TERM_ST_AFTERESCBRACKET
term_print0q
         ld (term_prfsmcurstate),a
        pop hl
        ld bc,STDINBUF_SZ
        or a
        sbc hl,bc
        ret z ;out: NC=data present
        scf
        ret ;no more data

sendchar_esckey
        push bc
         ;call forcereprintcursor
        ld hl,stdoutbuf
        ld (hl),0x1b
        inc hl
        ;call sendchar_byte_a
        ld (hl),'['
        ;call sendchar_byte_a
        ld de,stdoutbuf
        ld hl,2
        call sendchars
        pop bc
        jr sendchar_byte

sendchar_esckey2
        push bc
        ld hl,stdoutbuf
        ld (hl),0x1b
        inc hl
        ;call sendchar_byte_a
        ld (hl),'['
        inc hl
        ;call sendchar_byte_a
        pop bc
        push bc
        ld (hl),b
        ;call sendchar_byte_a
        ld de,stdoutbuf
        ld hl,3
        call sendchars
        pop bc
        jr sendchar_byte

        if 1==0
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

sendkey
;key to stdout
        ;cp 0x80
        ;jr nc,sendchar_rustoutf8
        ;cp 0x08 ;backspace
        ;cp 0x0d ;enter
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
        ld c,a
sendchar_byte
        ld a,c
sendchar_byte_a
sendchar
        ;cp 0x80
        ;jr nc,sendchar_rustoutf8
;sendchar_byte_a
        ld (stdoutbuf),a
        ld hl,1
        ld de,stdoutbuf
sendchars
;send chars to stdout (in: de=buf, hl=size, out: A=error)
        ld b,5 ;attempts
sendchars0
        push bc
        push de
        push hl
stdouthandle=$+1
        ld b,0
        OS_WRITEHANDLE ;1436t ;[2718t (1225 before BDOS_writehandle + 195 before BDOS_writehandle_pipe + 477 ..findpipe_byhandle + 301 pipe + 192 end BDOS_writehandle + 326 end BDOS)]
        ld b,h
        ld c,l ;bytes actually written
        pop hl
        pop de
        pop ix
         or a
          ret nz ;error ;TODO обработать? а так пока просто избегаем зацикливания
         sbc hl,bc ;datasize-byteswritten
         ret z
         ex de,hl
         add hl,bc ;dataaddr+byteswritten
         ex de,hl
;hl=remaining data size
;de=remaining data addr
        push ix
        push de
        push hl
        YIELDKEEP ;2158t
        call type_stdin
        pop hl
        pop de
        pop bc
        djnz sendchars0
        xor a ;z=no error
        ret ;клиент завис, но не сдох

term_prfsm_letter
        ;ld hl,term_prfsm_curstate
        ;ld (hl),TERM_ST_SINGLE
         ;ld b,TERM_ST_SINGLE
        cp 'H'
        jr z,term_prfsm_afterescbracket_H
        cp 'G'
        jr z,term_prfsm_afterescbracket_G
        cp 'm'
        jr z,term_prfsm_afterescbracket_m
        cp 'K'
        jr z,term_prfsm_afterescbracket_clearline
;TODO J etc.
        ;cp 'A' ;cursor_up
        cp 'B'
        jp z,cursor_down
        cp 'C'
        jp z,cursor_right
        cp 'D'
        jp z,cursor_left
        cp 's'
        jp z,cursor_store
        cp 'd' ;NON-STANDARD!
        jp z,term_prfsm_afterescbracket_scrolldown
        cp 'u' ;NON-STANDARD!
        jp z,term_prfsm_afterescbracket_scrollup ;+cursor remember
        ;cp '~'
        ;jr z,term_prfsm_afterescbracket_tilde
        ret
;term_prfsm_afterescbracket_tilde
;        ret

term_prfsm_afterescbracket_clearline
;не двигает курсор
        push bc
        ld de,(pr_textmode_curaddr)
        ld hl,(pr_buf_curaddr)
        ld bc,0x0040
term_prfsm_afterescbracket_clearline0
        xor a
        ld (de),a
        ld a,d
        xor 0x60 ;attr + 0x20
        ld d,a
        and 0x20
        jr nz,$+3
        inc e
        xor a
        ld (de),a
        set 6,d
        ld (hl),a
        ld a,l
        add a,c;0x40 ;attr
        adc a,b;0
        ld l,a
        ld (hl),b;0
        add a,c;0x40 ;text (next)
        ld l,a
        cp 0x40+(80/2)
        jp nz,term_prfsm_afterescbracket_clearline0
        pop bc
        ret

term_prfsm_afterescbracket_G
        ld a,(term_prfsm_curnumber) ;column
        dec a
        ld e,a
        jp BDOS_setx

term_prfsm_afterescbracket_H
        ld a,(term_prfsm_curnumber1) ;row
        dec a
        ld d,a
        ld a,(term_prfsm_curnumber) ;column
        dec a
        ld e,a
        jp BDOS_setxy
        
        if 1==0
        ;jp forcereprintcursor ;не прокатит? в начале печати cmd тоже setxy
forcereprintcursor
        ;push de
        ;push hl
        ;OS_GETTIMER ;hlde=timer
        ;dec d
        ;ld (lastsdtinmsgtimer),de
         ld hl,0;2
         ld (cursortimelimit),hl
        ;pop hl
        ;pop de
        ret
        endif
        
term_prfsm_afterescbracket_m
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
        ld a,(pr_textmode_curcolor)
        ld e,a
        ld a,(term_prfsm_curnumber)
        call term_setcolorpp
        ld a,(term_prfsm_curnumber1)
        call term_setcolorpp
        ld a,e
        ld (pr_textmode_curcolor),a
        ret

term_prfsm_afterescbracket_scrolldown
        push bc
        ld a,(term_prfsm_curnumber1)
        ld e,a ;xtop
        ld a,(term_prfsm_curnumber)
        ld d,a ;ytop
        ld hl,(term_prfsm_curnumber3) ;первый по счёту
        ld a,(term_prfsm_curnumber2) ;wid
        ld h,a ;hgt
        push de
        push hl
        ld a,l
        cp 80
        jr nz,term_prfsm_afterescbracket_scrolldown_OS
;de=topyx, hl=hgt,wid
;x, wid even
        ld a,d
        add a,h
        dec a
        ld d,a ;ybottom
        call BDOS_scroll_prepare
BDOS_scrolldown0
        push bc
        ld d,h
        ld e,l
        ld bc,-64
        add hl,bc
        call BDOS_scrollpageline
        pop bc
        djnz BDOS_scrolldown0
        jr term_prfsm_afterescbracket_scrolldown_OSq
term_prfsm_afterescbracket_scrolldown_OS
        OS_SCROLLDOWN
term_prfsm_afterescbracket_scrolldown_OSq
        pop hl
        pop de        
        ld a,d
        add a,h
        dec a
        ld d,a ;ybottom
        call BDOS_scrollbuf_prepare
       ld (BDOS_scrolldown_call),de
BDOS_scrolldown_buf0
        push bc
        ld d,h
        ld e,l
        dec h
BDOS_scrolldown_call=$+1
        call BDOS_scrollpageline_bufwindow
        pop bc
        djnz BDOS_scrolldown_buf0
        pop bc
        ret
        
cursor_store
        ld hl,(pr_textmode_curaddr)
        ld (cursor_remember_scraddr),hl
        ld hl,(pr_buf_curaddr)
        ld (cursor_remember_bufaddr),hl
        ret
cursor_remember
cursor_remember_scraddr=$+1
        ld hl,0xc1c0
        ld (pr_textmode_curaddr),hl
cursor_remember_bufaddr=$+1
        ld hl,0x4040
        ld (pr_buf_curaddr),hl
        ret

term_prfsm_afterescbracket_scrollup
        push bc
        ld a,(term_prfsm_curnumber1)
        ld e,a ;xtop
        ld a,(term_prfsm_curnumber)
        ld d,a ;ytop
        ld hl,(term_prfsm_curnumber3) ;wid ;первый по счёту
        ld a,(term_prfsm_curnumber2)
        ld h,a ;hgt
        ld a,l
        or a
        jr z,cursor_remember
        push de
        push hl
        cp 80
        jr nz,term_prfsm_afterescbracket_scrollup_OS
;de=topyx, hl=hgt,wid
;x, wid even
        call BDOS_scroll_prepare
        call BDOS_scrollpage0 ;62927 t
        jr term_prfsm_afterescbracket_scrollup_OSq
term_prfsm_afterescbracket_scrollup_OS
        OS_SCROLLUP ;95597 t
term_prfsm_afterescbracket_scrollup_OSq
        pop hl
        pop de
        call BDOS_scrollbuf_prepare
       ld (BDOS_scrollup_call),de
BDOS_scrollup_buf0
        push bc
        ld d,h
        ld e,l
        inc h
BDOS_scrollup_call=$+1
        call BDOS_scrollpageline_bufwindow
        pop bc
        djnz BDOS_scrollup_buf0 ;62131[91221] t
        pop bc
        ret

BDOS_scrollbuf_prepare
        ld a,(pgscrbuf)
        SETPG16K
        ld a,l
        srl a
        ld (BDOS_scrollpagelinelayer_wid),a
        ld b,h
        dec b
         call getscrbuftop_a
         add a,d ;0..24
         ld h,a
         ld a,e
         or 0x80
         rrca ;(x/2)+0x40 или 0xc0
         ld l,a
        ld a,(BDOS_scrollpagelinelayer_wid)
        cp 40
        ld de,BDOS_scrollpageline_buf
        ret z
        ld de,BDOS_scrollpageline_bufwindow
        ret

BDOS_scroll_prepare
        BDOSSETPGSSCR
        ;ld a,l
        ;srl a
        ;ld (BDOS_scrollpagelinelayer_wid),a
        ld b,h
        dec b
;BDOS_countxy
;keeps bc
        ld a,d ;y
        sub -0x87&0xff ;0xe1c0*4=0x8700
        rra
        ld h,a
         ld a,0;16
        rra
        sra h
        rra
        ld l,e ;x
        srl l
        jr c,$+4
        res 5,h
        add a,l
        ld l,a
        ret

BDOS_scrollpageline_bufwindow
        or a
        call BDOS_scrollpageline_bufwindowlayers ;text
        res 6,l ;attr
        res 6,e ;attr
        scf
        call BDOS_scrollpageline_bufwindowlayers ;attr
        set 6,l ;text
        ret
BDOS_scrollpageline_bufwindowlayers
        push af
        push de
        push hl
        set 7,l
        set 7,e
        or a
        call BDOS_scrollpageline_bufwindowlayer
        pop hl
        pop de
        pop af
BDOS_scrollpageline_bufwindowlayer
        push de
        push hl
        jr nc,$+4
        inc hl
        inc de
BDOS_scrollpagelinelayer_wid=$+1
        ld bc,39;40
        ldir
        pop hl
        pop de
        ret

BDOS_scrollpageline_buf
        dup 39
        ldi
        edup
        ld a,(hl)
        ld (de),a
        set 7,l
        set 7,e        
        dup 39
        ldd
        edup
        ld a,(hl)
        ld (de),a

        res 6,l ;attr
        res 6,e ;attr
        
        dup 39
        ldi
        edup
        ld a,(hl)
        ld (de),a
        res 7,l
        res 7,e
        inc l
        inc e
        dup 39
        ldd
        edup
        ld a,(hl)
        ld (de),a

        ld l,0x40 ;text
        ret

BDOS_scrollpage
;156046t [195810t]
        BDOSSETPGSSCR
        ld hl,0xc1c0
        ld b,24
BDOS_scrollpage0
        push bc
        ld d,h
        ld e,l
        ld bc,64
        add hl,bc
        call BDOS_scrollpageline
        pop bc
        djnz BDOS_scrollpage0
        ret
BDOS_scrollpageline
        dup 39
        ldi
        edup
        ld a,(hl)
        ld (de),a
        set 5,h
        set 5,d
        dup 39
        ldd
        edup
        ld a,(hl)
        ld (de),a
        
        res 6,h ;attr
        res 6,d ;attr
        
        dup 39
        ldi
        edup
        ld a,(hl)
        ld (de),a
        res 5,h
        res 5,d
        inc l
        inc e
        dup 39
        ldd
        edup
        ld a,(hl)
        ld (de),a
        dec l
        dec e
        set 6,h
        set 6,d
        ret
        
copylinelayer
        push de
        push hl
        dup 40
        ldi
        edup
        ld a,(hl)
        ld (de),a
        pop hl
        pop de
        ret

term_setcolorpp
        cp 8
        jr z,term_setinvisible
        ret c
        cp 28
        jr z,term_setvisible
        cp 90
        jr c,term_nosetbrightink
        sub 90-64 ;ink + bright
        xor e
        and 0x47
        xor e
        ld e,a
        ret
term_nosetbrightink
        cp 40
        jr c,term_nosetpaper
        sub 40 ;paper
        add a,a
        add a,a
        add a,a
        xor e
        and 0x38
        xor e
        ld e,a
        ret
term_nosetpaper
        sub 30 ;ink
        xor e
        and 0x47
        xor e
        ld e,a
        ret
term_setvisible
        xor a
        ld (finvisible),a
        ld (finvisible2),a
        ret
term_setinvisible
        ld a,0x5e ;"ld e,(hl)"
        ld (finvisible),a
        ;ld a,0x4e ;"ld c,(hl)"
        ld (finvisible2),a
        ret

MOUSEFACTOR=8
mousemove
;de=mouse delta
;чтобы двигать не резко, надо отдельно хранить младшие части x,y (не отображаемые на экране)
        ld hl,(mousexy)
htmlcursorxylow=$+1
        ld bc,0 ;bits 7..5 (for Y) 7..6 (for X), others=0
        dup 3
        sla b
        rl h
        edup        
        ld a,h
        add a,d
        bit 7,d
        jr z,html_mousemove_yplus
        jr nc,html_mousemove_yminus_overflow
        cp HTMLTOPY*MOUSEFACTOR
        jr nc,html_mousemove_yq
html_mousemove_yminus_overflow
        ld a,HTMLTOPY*MOUSEFACTOR
        jr html_mousemove_yq
html_mousemove_yplus
        jr c,html_mousemove_yplus_overflow
        cp MOUSEFACTOR*(HTMLTOPY+HTMLHGT-1)
        jr c,html_mousemove_yq
html_mousemove_yplus_overflow
        ld a,MOUSEFACTOR*(HTMLTOPY+HTMLHGT-1)
html_mousemove_yq  
        srl a
        rr b
        rra
        rr b
        rra
        rr b
        ld (mousexy+1),a

        ld h,0
        sla c
        rl l
        sla c
        adc hl,hl
        ld a,e
        rla
        sbc a,a
        ld d,a
        add hl,de
        bit 7,e
        jr z,html_mousemove_xplus
        jr c,html_mousemove_xq
        ld hl,0 ;ld a,HTMLTOPY*MOUSEFACTOR
        jr html_mousemove_xq
html_mousemove_xplus
        ld de,MOUSEFACTOR/2*(80-1)
        jr c,html_mousemove_xplus_overflow
        ;or a
        sbc hl,de
        add hl,de
        jr c,html_mousemove_xq
html_mousemove_xplus_overflow
        ex de,hl
html_mousemove_xq
        ld a,l
        rr h
        rra
        rr c
        rra
        rr c
        ld (mousexy),a

        ld (htmlcursorxylow),bc
        ret

BDOS_countattraddr_mousecursor
;de=yx
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW ;attr ;TODO убрать? считывать из scrbuf!
        ld a,d ;y
        sub -0x87&0xff ;0xe1c0*4=0x8700
        rra
        ld h,a
         ld a,0;16
        rra
        sra h
        rra
        ld l,e ;x
        srl l
        jr c,$+4
        res 5,h
        add a,l
        ld l,a
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
         and 0x20
        ret nz ;jr nz,$+3
        inc l
        ret

BDOS_countattraddr
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW ;attr ;TODO убрать? считывать из scrbuf!
        ld hl,(pr_textmode_curaddr)
textaddrtoattraddr
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
         and 0x20
        ret nz ;jr nz,$+3
        inc l
        ret

getscrbuftop_a
        ld hl,(pr_buf_curtopaddr)
        ld a,h
redraw_scroll=$+1
        sub 0;24
         cp 0x40
         jr nc,$+4
         ld a,0x40 ;TODO prevpg
        ret

cursor_left
;TODO с переходом на предыдущую строку
        ld hl,(pr_textmode_curaddr)
        ld a,h
        xor 0x20 ;attr + 0x20
        ld h,a
        and 0x20
        jr z,$+3
        dec l
        ld (pr_textmode_curaddr),hl
        ld hl,(pr_buf_curaddr)
        ld a,l
        sub 0x40
        sub 0x40
        sbc a,0
        ld l,a
        ld (pr_buf_curaddr),hl
        ret

cursor_right
        xor a
        ld (writed1),a
        ld (writed2),a
        ld (writee1),a
        ld (writee2),a
        push bc
        ld a,(term_prfsm_curnumber)
        sub 1
        adc a,1 ;0->1
        ld b,a
cursor_right0
        ld a,' '
        call BDOS_prchar_a_nocrlf
        djnz cursor_right0
        pop bc
        ld a,0x72 ;"ld (hl),d"
        ld (writed1),a
        ld (writed2),a
        ld a,0x73 ;"ld (hl),e"
        ld (writee1),a
        ld (writee2),a
        ret

BDOS_setx
;e=x
        ld a,e
        or 0x80
        rrca ;(x/2)+0x40 или 0xc0
        ld (pr_buf_curaddr),a
        ld hl,(pr_textmode_curaddr)
        ld a,e ;x
        rra
        set 5,h
        jr c,$+4
        res 5,h
        xor l
        and 0x3f
        xor l
        ld l,a
        jr BDOS_settextcuraddr

BDOS_setxy
;de=yx
         call getscrbuftop_a
         add a,d ;0..24
         ld h,a
         ld a,e
         or 0x80
         rrca ;(x/2)+0x40 или 0xc0
         ld l,a
         ld (pr_buf_curaddr),hl
        
        ld a,d ;y
        sub -0x87&0xff ;0xe1c0*4=0x8700
        rra
        ld h,a
         ld a,0;16
        rra
        sra h
        rra
        ld l,e ;x
        srl l
        jr c,$+4
        res 5,h
        add a,l
        ld l,a
BDOS_settextcuraddr
        ld (pr_textmode_curaddr),hl
        ret
        
BDOS_prchar_controlcode
         ld hl,(pr_textmode_curaddr)
        cp 0x0a
        jr z,BDOS_prchar_lf
        cp 0x0d
        jp nz,BDOS_prchar_nocontrolcode
BDOS_prchar_cr
         ld a,0x40
         ld (pr_buf_curaddr),a ;x=0
        ld a,l
        and 0xc0
        ld l,a
        res 5,h
        jr BDOS_settextcuraddr
        
buftopaddr_down
pr_buf_curtopaddr=$+1
        ld hl,0x4040
        inc h
        ld (pr_buf_curtopaddr),hl
        ret
        
BDOS_prchar_lf
        push hl
        ld hl,(pr_buf_curaddr)
        inc h
        call m,scrollscrbuf
        ld (pr_buf_curaddr),hl
        ;call buftopaddr_down
        pop hl
        
        ld a,l
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr
        jp BDOS_prchar_lf_q

cursor_down
        ld a,0x0a ;lf
BDOS_prchar_a
;keeps bc!
        cp 0x0e
        jr c,BDOS_prchar_controlcode
BDOS_prchar_a_nocrlf
pr_textmode_curaddr=$+1
        ld hl,0xc1c0
	ld d,trecode/256
	ld e,a
	ld a,(de)
BDOS_prchar_nocontrolcode
        ld e,a
pr_textmode_curcolor=$+1
        ld d,7
finvisible=$
        nop ;/ld e,(hl)
writee1=$
        ld (hl),e

        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
        and 0x20
        jr nz,$+3
        inc l
writed1=$
        ld (hl),d

        set 6,h
        ld (pr_textmode_curaddr),hl

;scrbuf состоит из строк длиной 256 байт
;каждая из них из 4 слоёв:
;+0x40: аналог +0x4000 (text0)
;+0x80: аналог +0x2000 (attr0)
;+0xc0: аналог +0x6000 (text1)
;+0x01: аналог +0x0001 (attr1)

pr_buf_curaddr=$+1
        ld hl,0x4000+0x40 ;text0
finvisible2=$
        nop ;/ld e,(hl)
writee2=$
         ld (hl),e
        ld a,l
        add a,0x40 ;attr
        adc a,0
        ld l,a
writed2=$
         ld (hl),d
        add a,0x40 ;text (next)
        ld l,a
        ld (pr_buf_curaddr),hl

        cp 0x40+(80/2)
        ret nz ;нет переноса строки
        ld l,0x40
        inc h
        call m,scrollscrbuf
        ld (pr_buf_curaddr),hl
        ;call buftopaddr_down
        
        ld hl,(pr_textmode_curaddr)
        ld a,l
        and 0xc0
        add a,0x40
        ld l,a
        jp nc,BDOS_settextcuraddr
BDOS_prchar_lf_q
        inc h
        bit 3,h
        jp z,BDOS_settextcuraddr ;нет выхода за последнюю строку
BDOS_scrolllock0
        ld a,0xfe
        in a,(0xfe)
        rra ;Caps Shift
        jr nc,BDOS_scrolllock0
;scroll+clear bottom line
       push bc
        call buftopaddr_down
        call BDOS_scrollpage ;attr
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        SETPG32KHIGH ;call sys_setpgc000
        xor a
        call BDOS_cllastline
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        SETPG32KHIGH ;call sys_setpgc000
        ld a,COLOR
        call BDOS_cllastline
        BDOSSETPGSSCR
       pop bc
        ld hl,0xc7c0
        jp BDOS_settextcuraddr
        
scrollscrbuf
;TODO reserve page
;TODO unreserve very old page
       push bc
        dec h
        push hl
        ld de,0x4000 ;0x4040 ;text ;TODO scroll attr
        ld hx,0x3f*4;*2
scrollscrbuf0
        ld h,d
        ld l,e
        inc h
        dup 40
        ldi
        edup
        ld a,(hl)
        ld (de),a
        ld bc,64-40;128-40
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
        dec hx
        jp nz,scrollscrbuf0
        xor a
        ld hl,0x7f40 ;text
        call BDOS_scrollpage_cllinelayer
        ld hl,0x7fc0 ;text
        call BDOS_scrollpage_cllinelayer
        ld a,COLOR
        ld hl,0x7f01 ;attr
        call BDOS_scrollpage_cllinelayer
        ld hl,0x7f80 ;attr
        call BDOS_scrollpage_cllinelayer
        ld hl,pr_buf_curtopaddr+1
        dec (hl) ;compensate shift
        pop hl
       pop bc
        ret

BDOS_cllastline
        ld hl,0xc7c0
        call BDOS_scrollpage_cllinelayer
        ld hl,0xe7c0
BDOS_scrollpage_cllinelayer
        ld d,h
        ld e,l
        inc e
        ld bc,41-1;64-1
        ld (hl),a
        ldir ;clear bottom line
        ret

BDOS_cls
;e=color byte
        ;ld a,(pgscrbuf_low)
        ;SETPG32KLOW
        ;ld a,(pgscrbuf_high)
        ;SETPG32KHIGH
        ;call clspp
        ld a,(pgscrbuf)
        SETPG16K
        ld hl,0x4000
        ld de,0x4001
        ld bc,0x0040
        ld (hl),COLOR
        ldir
        ld c,0x40
        ld (hl),b;0
        ldir
        ld c,0x40
        ld (hl),COLOR
        ldir
        ld c,0x40
        ld (hl),b;0
        ldir        
        dec h;ld hl,0x4000
        ld de,0x4100
        ld b,0x3f
        ldir
;TODO reset current number of lines in buf

        BDOSSETPGSSCR

;textmode (6)
clspp
        ld a,e
         ld hl,0x8000
         call cls_halfpg
         ld hl,0xa000
         call cls_halfpg

        xor a
         ld hl,0xc000
         call cls_halfpg
         ld hl,0xe000
cls_halfpg
         ld bc,0x1aff
        ld d,h
        ld e,l
        inc de
        ld (hl),a
        ldir
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
        ret nz
        ld a,e
        call cmd_loadfullpage
        ret nz
        ld a,h
        call cmd_loadfullpage
        ret nz
        ld a,l
cmd_loadfullpage
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
        or a
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
        inc hl ;ldi
        jr skipword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

ansipal
	;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
	;dw 0x1f1f,0x1e1e,0x1d1d,0x1c1c,0x0f0f,0x0e0e,0x0d0d,0x0c0c
	dw 0xffff,0xfdfd,0xefef,0xeded,0xfefe,0xfcfc,0xeeee,0xecec
	dw 0x1f1f,0x1d1d,0x0f0f,0x0d0d,0x1e1e,0x1c1c,0x0e0e,0x0c0c

term_prfsm_curnumber
         db 0
term_prfsm_curnumber1
         db 0
term_prfsm_curnumber2
         db 0
term_prfsm_curnumber3
         db 0

cmd_filename
        db "cmd.com",0

tpastaname
        db "pasta.txt",0

tpipename
        db "z:",0

killbuf_byte
        db COLOR;0

pastabuf    
        db 0

readpastabuf
        ds READPASTABUF_SZ

stdoutbuf
        ds 6

stdinbuf
        ds STDINBUF_SZ

        align 256
trecode
	incbin "../_sdk/codepage/866toatm"
trecodeback
        ds 256
        
end
	savebin "term.com",begin,end-begin
	
	LABELSLIST "..\..\us\user.l"
