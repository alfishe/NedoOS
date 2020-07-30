        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

;при закрытии cmd term должен закрыться

RECODEINPUT=1

STDINBUF_SZ=256

COLOR=7
CURSORCOLOR=0x38

        macro BDOSSETPGSSCR
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        SETPG32KHIGH
        endm

        org PROGSTART
begin
        ld sp,0x4000
        ld e,6 ;textmode
        OS_SETGFX
	;OS_GETMAINPAGES ;dehl
	;push de
	;push hl
	;ld e,l
	;OS_DELPAGE
	;pop hl
	;ld e,h
	;OS_DELPAGE
	;pop de
	;OS_DELPAGE
 
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
        ld a,h
        ld (pgscrbuf),a
        ;ld (pgscrbuf_low),a
        ;ld a,l
        ;ld (pgscrbuf_high),a
        
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

execcmd_error
mainloop_afternokey
mainloop_afterkey
        YIELD
        call BDOS_countattraddr
unprint_cursor_color=$+1
        ld (hl),COLOR

mainloop_afterredraw
        
waitpid_id=$+1
        ld e,0
        OS_WAITPID ;TODO проверять, что пайп с той стороны не закрыт
        or a
        jp z,quit
        
        call type_stdin ;stdin to screen
        YIELDKEEP
        call type_stdin ;stdin to screen
       
        ld a,(pgscrbuf) ;ok
        SETPG16K
         ld hl,(pr_buf_curaddr)
        ld a,l
        add a,0x40 ;attr
        adc a,0
        ld l,a
        ld a,(hl) ;из pgscrbuf_low
        ld (unprint_cursor_color),a

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
        ld bc,0;2
        or a
        sbc hl,bc
        pop hl
        jr c,noprintcursor
         ;ld (lastsdtinmsgtimer),hl
         ld hl,4
         ld (cursortimelimit),hl
        call BDOS_countattraddr
        ld (hl),CURSORCOLOR
noprintcursor

;mainloop_afterkey
        GET_KEY
        or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        jr z,mainloop_afternokey
        cp key_redraw
        push af
        call z,redraw
        pop af
         cp key_pgup
         jr z,term_pgup
        cp key_esc
        jr z,term_esckey
        if RECODEINPUT
        call sendchar
        else
        call sendchar_byte_a
        endif
        jr mainloop_afterkey
term_esckey
        if RECODEINPUT
        call sendchar
        ld a,key_esc
        call sendchar
        else
        call sendchar_byte_a
        endif
        jr mainloop_afterkey
        
term_pgdown
        ld hl,redraw_scroll
        ld a,(hl)
        cp 24
        jr z,$+3
        dec a
        ld (hl),a
        jr term_pgup0redraw
term_pgup
        ld hl,redraw_scroll
        ld a,(hl)
        cp 63
        jr z,$+3
        inc a
        ld (hl),a
term_pgup0redraw
        call redraw
term_pgup0
        YIELD
        GET_KEY
        or a
        jr z,term_pgup0
         cp key_pgup
         jr z,term_pgup
         cp key_pgdown
         jr z,term_pgdown
        ld a,24
        ld (redraw_scroll),a
        call redraw
        jp mainloop_afterredraw

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

type_stdin
        ld de,stdinbuf
        ld hl,STDINBUF_SZ
stdinhandle=$+1
        ld b,0
        ;ld b,0xff
        OS_READHANDLE ;6933t (incl. 5350=ldir 255 bytes)
;hl=size
        ld a,h
        or l
        ret z ;jr z,nostdinmsg;mainloop_afterkey

        push hl
         OS_GETTIMER ;hlde=timer
         ld (lastsdtinmsgtimer),de
        ld a,(user_scr0_high) ;ok ;pgscr0_1
        SETPG32KHIGH
        ld a,(user_scr0_low) ;ok ;pgscr0_0
        SETPG32KLOW
        pop bc
        ld hl,stdinbuf
term_print0
        push bc
        push hl
        ld a,(hl)
        call term_prfsm ;520/521t
        pop hl
        pop bc
        cpi
        jp pe,term_print0
;nostdinmsg
        ret

sendchar_esckey
        push bc
         ;call forcereprintcursor
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

sendchar
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
        call type_stdin
        jr sendchar_repeat

term_prfsm
;a=char
TERM_ST_SINGLE=1 ;1: wait for single symbol
TERM_ST_AFTERESC=2 ;2: after 0x1b
TERM_ST_AFTERESCBRACKET=2 ;3: after 0x1b [ [number] (might be more digits)
term_prfsm_curstate=$+1
        ld b,TERM_ST_SINGLE
        djnz term_prfsm_nosingle
        cp 0x1b
        jp nz,BDOS_prchar_a
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERESC
        ret
term_prfsm_nosingle
        djnz term_prfsm_noafteresc
        ;cp '['
        ;jr nz,term_prfsm_prchar ;считаем, что после esc всегда [
        ld hl,term_prfsm_curstate
        inc (hl) ;TERM_ST_AFTERESCBRACKET
        xor a
        ld (term_prfsm_curnumber),a
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
        ret
term_prfsm_afterescbracket_nonumber
        add a,'0'
        cp ';'
        jr nz,term_prfsm_afterescbracket_nosemicolon
        ld a,(term_prfsm_curnumber)
        ld (term_prfsm_curnumber1),a
        xor a
        ld (term_prfsm_curnumber),a
        ret
term_prfsm_afterescbracket_nosemicolon
        ld hl,term_prfsm_curstate
        ld (hl),TERM_ST_SINGLE
        cp 'H'
        jr z,term_prfsm_afterescbracket_H
        cp 'm'
        jr z,term_prfsm_afterescbracket_m
;TODO J etc.
        cp '~'
        jr z,term_prfsm_afterescbracket_tilde
        ;cp 'A' ;A..D = up, down, right, left
        ret
term_prfsm_afterescbracket_tilde
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

term_prfsm_afterescbracket_H
        ld a,(term_prfsm_curnumber1) ;row
        dec a
        ld d,a
        ld a,(term_prfsm_curnumber) ;column
        dec a
        ld e,a
        call BDOS_setxy
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
        
term_prfsm_afterescbracket_m
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
;1  -  BRIGHT ON: Включение яркости INK. (Bold, VT100.)
;21  -  BRIGHT OFF: Выключение яркости INK. (Doubly-underlined, ECMA-48 3rd.)
        ld a,(term_prfsm_curnumber)
        sub 30
        ld (pr_textmode_curcolor),a
        ret

        if 1==0
BDOS_scroll_prepare
        ld a,l
        srl a
        ld (BDOS_scrollpagelinelayer_wid),a
        ld b,h
        dec b
BDOS_countxy
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

BDOS_getxy
;out: de=yx ;GET CURSOR POSITION
        ld hl,(pr_textmode_curaddr)
        ld a,h
        rla
        rla
        rla ;bit5
        ld a,l
        rla
        and 0x7f
        ld e,a ;x
        add hl,hl
        add hl,hl ;h=y*4 + const + n*0x80
        ld a,h
        sub 0x87 ;0xe1c0*4=0x8700
        and 0x1f
        ld d,a ;y
        ;xor a ;success
        ret
        endif

BDOS_countattraddr
        ;ld a,(pgscrbuf_low)
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW ;attr ;TODO считывать из scrbuf!
        ld hl,(pr_textmode_curaddr)
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
         and 0x20
        jr nz,$+3
        inc l
        ret

        if 1==0
BDOS_prattr
;e=color byte
        call BDOS_countattraddr
        ld (hl),e
         
        ld a,(pgscrbuf) ;ok
        SETPG16K
         ld hl,(pr_buf_curaddr)
        ld a,l
        add a,0x40 ;attr
        adc a,0
        ld l,a
        ld (hl),e
        ret
        endif

getscrbuftop_a
        ld hl,(pr_buf_curaddr)
        ld a,h
redraw_scroll=$+1
        sub 24
         cp 0x40
         jr nc,$+4
         ld a,0x40 ;TODO prevpg
        ret

BDOS_setxy
;de=yx
        ;call BDOS_countxy
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
        cp 0x0a
        jr z,BDOS_prchar_lf
        cp 0x0d
        jp nz,BDOS_prchar_nocontrolcode
        ;jr z,BDOS_prchar_cr
BDOS_prchar_cr
         ld a,0x40
         ld (pr_buf_curaddr),a
        ld a,l
        and 0xc0
        ld l,a
        res 5,h
        jr BDOS_settextcuraddr
        
BDOS_prchar_lf
        push hl
        ld hl,(pr_buf_curaddr)
        inc h
        call m,scrollscrbuf
        ld (pr_buf_curaddr),hl
        pop hl
        
        ld a,l
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr
        jr BDOS_prchar_lf_q

BDOS_prchar_a
;портит только 0xc000+, но сама восстанавливает там pgkillable (для быстрого вызова через rst)
pr_textmode_curaddr=$+1
        ld hl,0xc1c0
        cp 0x0e
        jr c,BDOS_prchar_controlcode
	ld d,trecode/256
	ld e,a
	ld a,(de)
BDOS_prchar_nocontrolcode
        ld e,a
pr_textmode_curcolor=$+1
        ld d,7
        ;ld a,(user_scr0_high) ;ok ;pgscr0_1
        ;SETPG32KHIGH
        ;ld a,(user_scr0_low) ;ok ;pgscr0_0
        ;SETPG32KLOW
        ld (hl),e

        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
        and 0x20
        jr nz,$+3
        inc l

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
pgscrbuf=$+1
         ld a,0
         SETPG16K ;TODO вне prchar
         ld (hl),e
        ld a,l
        add a,0x40 ;attr
        adc a,0
        ld l,a
         ld (hl),d
        add a,0x40 ;text (next)
        ld l,a
        ld (pr_buf_curaddr),hl

        and 0x3f
        cp 80/2
        ret nz ;нет переноса строки
        
        inc h
        call m,scrollscrbuf
        ld (pr_buf_curaddr),hl
        
        ld hl,(pr_textmode_curaddr)
        ld a,l
        and 0xc0
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr
BDOS_prchar_lf_q
        inc h
        bit 3,h
        jr z,BDOS_settextcuraddr ;нет выхода за последнюю строку
BDOS_scrolllock0
        ld a,0xfe
        in a,(0xfe)
        rra ;Caps Shift
        jr nc,BDOS_scrolllock0
;scroll+clear bottom line
        call BDOS_scrollpage ;attr
        ;ld a,(pgscrbuf_high) ;ok ;pgscr0_0 ;text
        ;SETPG32KHIGH ;call sys_setpgc000
        ;call BDOS_cllastline
        ;ld a,(pgscrbuf_low) ;ok ;pgscr0_0 ;attr
        ;SETPG32KHIGH ;call sys_setpgc000
        ;call BDOS_cllastline
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        SETPG32KHIGH ;call sys_setpgc000
        xor a
        call BDOS_cllastline
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        SETPG32KHIGH ;call sys_setpgc000
        ld a,COLOR
        call BDOS_cllastline
        ld a,(user_scr0_high) ;ok ;pgscr0_1
        SETPG32KHIGH
        ld a,(user_scr0_low) ;ok ;pgscr0_0
        SETPG32KLOW
BDOS_prchar_skipscroll
        ld hl,0xc7c0
        jp BDOS_settextcuraddr
        
scrollscrbuf
;TODO reserve page
;TODO unreserve very old page
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
        pop hl
        ret

BDOS_scrollpage
;156046t [195810t]
        ;ld a,40
        ;ld (BDOS_scrollpagelinelayer_wid),a
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
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        ;or a
        call BDOS_scrollpagelinelayers ;text
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        ;scf
BDOS_scrollpagelinelayers
        SETPG32KHIGH ;call sys_setpgc000
        push af
        push de
        push hl
        set 5,h
        set 5,d
        ;or a
        call copylinelayer
        pop hl
        pop de
        pop af
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

        if 1==0
BDOS_scrolldown
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
        ret

BDOS_scrollup
;de=topyx, hl=hgt,wid
;x, wid even
        call BDOS_scroll_prepare
        jp BDOS_scrollpage0
        endif
        
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


term_prfsm_curnumber
         db 0
term_prfsm_curnumber1
         db 0

cmd_filename
        db "cmd.com",0

tpipename
        db "z:",0

stdoutbuf
        db 0

stdinbuf
        ds STDINBUF_SZ

        align 256
trecode
	incbin "../_sdk/codepage/866toatm"
        
end
	savebin "term.com",begin,end-begin
	
	LABELSLIST "..\..\us\user.l"
