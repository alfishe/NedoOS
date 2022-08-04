        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

;при закрытии cmd term должен закрыться

;TEXTMODE=0
       if TEXTMODE
;CHRHGT=8 ;реально нигде не используется в TEXTMODE
HTMLHGT=25
MOUSEFACTOR=8
SCRBASE=0xc1c0
LINESTEP=64
CHRLINESTEP=64
       else
CHRHGT=6
HTMLHGT=33
MOUSEFACTOR=4
SCRBASE=0xc000
LINESTEP=40
CHRLINESTEP=40*CHRHGT
       endif


RECODEINPUT=1

MOUSETIMEOUT=150;50

READPASTABUF_SZ=80
STDINBUF_SZ=256

HTMLTOPY=0
MOUSEFACTORX=4

COLOR=7
CURSORCOLOR=0x38

REPEATNOKEY=0;2


        macro BDOSSETPGSSCR
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        SETPG8000
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        SETPGC000
        endm

        org PROGSTART
begin
        ld sp,0x4000
        OS_HIDEFROMPARENT
       if TEXTMODE
        ld e,6 ;textmode
       else
        ld e,2 ;mc hires
       endif
        OS_SETGFX

        OS_GETMAINPAGES ;out: d,e,h,l=pages in 0000,4000,8000,c000, c=flags, b=id
       push bc ;b=id
        ld a,e
        ld (pgscrbuf),a
	push hl
	ld e,h
	OS_DELPAGE
	pop hl
	ld e,l
	OS_DELPAGE

        ld e,COLOR
        call BDOS_cls ;там SETPGSSCR
        ld de,ansipal
        OS_SETPAL

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

       pop bc ;b=id
        ld a,(stdinhandle)
        ld e,a
        ld a,(stdouthandle)
        ld d,a
        ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        OS_SETSTDINOUT

;TODO запускать файл, указанный в параметре (по умолчанию cmd, искать в bin)
        ld hl,COMMANDLINE ;command line
        call skipword
        ld de,cmd_filename
        call skipspaces ;пропустили первое слово (там было term.com, а дальше, например, cmd.com autoexec.bat)
        ld a,(hl)
        or a
        jr z,norunparameter
        ld d,h
        ld e,l
        call skipword
norunparameter
       ld b,(hl)
        ld (hl),0 ;end filename
       push bc
       push hl
        OS_OPENHANDLE ;out: b=handle, a=error
       pop hl
       pop de
       ld (hl),d ;restore parameters after filename
        or a
        jr nz,execcmd_error
        
        call readapp ;делает CLOSE ;включает какие-то страницы
        
        push af
        ld b,a ;id
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
       if TEXTMODE
        ld hl,trecode
        ld d,trecodeback/256
maketrecodeback0
        ld e,(hl)
        ld a,l
        ld (de),a
        inc l
        jr nz,maketrecodeback0
       endif

execcmd_error
        BDOSSETPGSSCR

mainloop_afternokey
       if REPEATNOKEY != 0
;если два раза подряд нет событий, то надо делать YIELD, иначе YIELDKEEP
;т.е. когда нет событий, идёт всё время YIELD. А если событие,пусто,событие,пусто, то всё время YIELDKEEP
;тогда курсор исчезает - плохо
wasnokey=$+1
        ld a,1
        dec a
        jr nz,mainloop_yieldkeep
        ;scf
        ;ld a,55 ;"scf"
        ;ld (wasnokey),a
        ;jr nc,mainloop_yieldkeep
       else
mainloop_afterkey
       endif
        call printcursor
         ld hl,(pr_buf_curaddr)
         ld (wascursorcuraddr),hl        
        call getmousexy
        ld (mousecursor_wasxy),de
mousetimeout=$+1
	ld a,1
	dec a
	jr z,noshowmouse
	ld (mousetimeout),a
        call BDOS_countattraddr_mousecursor
       if TEXTMODE
        ld a,(hl)
        cpl
        ld (hl),a
       else
        ld de,LINESTEP
        ld b,CHRHGT
        ld a,(hl)
        cpl
        ld (hl),a
        add hl,de
        djnz $-4
       endif
noshowmouse

        ;OS_SETWAITING ;засыпаем, будем просыпаться только при появлении чего-то в пайпе
        YIELD ;вернётся раньше, если что-то появилось в пайпе
        ld a,(pgscrbuf) ;ok
        SETPG4000
        call BDOS_countattraddr
wascursorcuraddr=$+1
        ld de,killbuf_byte
        ld a,e
        add a,0x40 ;attr
        adc a,0
        ld e,a
        ld a,(de) ;из pgscrbuf
       if TEXTMODE
        ld (hl),a;COLOR
       else
        ld de,LINESTEP
        ld b,CHRHGT
        ld (hl),a
        add hl,de
        djnz $-2
       endif

       if REPEATNOKEY != 0
        jr mainloop_afterkeyq
mainloop_afterkey
       ;if REPEATNOKEY != 0
        ;ld a,55+128 ;"or a"
        ;ld (wasnokey),a
        ld a,REPEATNOKEY;2
mainloop_yieldkeep
        ld (wasnokey),a
       ;endif
        ;OS_SETWAITING ;засыпаем, будем просыпаться только при появлении чего-то в пайпе
        YIELD ;вернётся раньше, если что-то появилось в пайпе
mainloop_afterkeyq
       endif
mousecursor_wasxy=$+1
        ld de,0
         call getscrbuftop_a
         add a,d ;0..24
         ld h,a
         ld a,e ;mousex
         or 0x80
         rrca ;(x/2)+0x40 или 0xc0
        add a,0x40 ;attr
        adc a,0
        ld l,a
        ld a,(hl) ;из pgscrbuf
        push af
        call BDOS_countattraddr_mousecursor
        pop af
       if TEXTMODE
        ld (hl),a ;screen
       else
        ld de,LINESTEP
        ld b,CHRHGT
        ld (hl),a
        add hl,de
        djnz $-2
       endif

mainloop_afterredraw
        
waitpid_id=$+1
        ld e,0
        OS_CHECKPID ;TODO проверять, что пайп с той стороны не закрыт
        or a
        jp z,quit ;dead
        
        jr mainloop_type0_go
mainloop_type0
        ;OS_SETWAITING ;засыпаем, будем просыпаться только при появлении чего-то в пайпе
        ;YIELDKEEP

mainloop_type0_go
        call type_stdin ;stdin to screen
        jr nc,mainloop_type0 ;data present
       
        if 1==0
;if long time no message from stdin, print cursor
        OS_GETTIMER ;dehl=timer
        push hl
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
        jp p,term_pgdown
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
        ;jr nz,sendmouseevent
        jp z,mainloop_afternokey
sendmouseevent
	 ld a,MOUSETIMEOUT;50
	 ld (mousetimeout),a
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
        SETPG4000
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
        sub HTMLHGT-1;24
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
       if TEXTMODE
        ld (hl),CURSORCOLOR
       else
        ld de,LINESTEP
        ld bc,CHRHGT*256+CURSORCOLOR
        ld (hl),c
        add hl,de
        djnz $-2
       endif
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
        or a;cp 0;24
        jr z,$+3
        dec a
        ld (hl),a
        call redraw
        jp mainloop_afterredraw
term_pgup
        ld hl,redraw_scroll
        ld a,(hl)
        cp 63 -(HTMLHGT-1);24
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
        SETPG4000
        BDOSSETPGSSCR
         call getscrbuftop_a
        ld b,HTMLHGT;25
       if TEXTMODE
        ld h,a
        ld de,SCRBASE
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
        ld bc,CHRLINESTEP
        add hl,bc
        ex de,hl
        inc h ;TODO nextpg
        pop bc
        djnz redrawlines0
        ret

       else ;mc hires

        ld hx,a
        ld hl,SCRBASE
redrawlines0
        push bc
;scrbuf состоит из строк длиной 256 байт
;каждая из них из 4 слоёв:
;+0x40: аналог +0x4000 (text0)
;+0x80: аналог +0x2000 (attr0)
;+0xc0: аналог +0x6000 (text1)
;+0x01: аналог +0x0001 (attr1)
_ixbase=0x80-40 ;чтобы зациклить по jp p
        ld lx,_ixbase
        ld d,fnt/256
redrawlinechars0
        ld e,(ix-_ixbase+0x40) ;text0
        ld bc,LINESTEP
        dup CHRHGT-1
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        set 5,h
        ld e,(ix-_ixbase+0xc0) ;text1
        ld bc,-LINESTEP
        dup CHRHGT-1
        ld a,(de)
        ld (hl),a
        dec d
        add hl,bc
        edup
        ld a,(de)
        ld (hl),a
        res 6,h ;attr
        ld a,(ix-_ixbase+0x01) ;attr1
        ld bc,LINESTEP
        dup CHRHGT-1
        ld (hl),a
        add hl,bc
        edup
        ld (hl),a
        res 5,h
        ld a,(ix-_ixbase+0x80) ;attr0
        ld bc,-LINESTEP
        dup CHRHGT-1
        ld (hl),a
        add hl,bc
        edup
        ld (hl),a
        set 6,h ;text
        inc hl
        inc lx
        jp p,redrawlinechars0
        ld bc,CHRLINESTEP-40
        add hl,bc
        inc hx ;TODO nextpg
        pop bc
        djnz redrawlines0
       ;затираем последние 2 строки (200 - (33*6) = 2)
        ;call redrawcl2lines
        ;set 5,h
        ;call redrawcl2lines
        res 6,h ;attr
        call redrawcl2lines
        set 5,h ;res 5,d
redrawcl2lines
        push hl
        ld d,h
        ld e,l
        inc de
        ld [hl],0
        ld bc,40*2-1
        ldir
        pop hl
        ret        
       endif


       if TEXTMODE
copylinelayer ;for redraw
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
       endif

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
       if TEXTMODE
        ld d,trecodeback/256
        ld e,a
        ld a,(de)
       endif
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
         ;OS_GETTIMER ;dehl=timer
         ;ld (lastsdtinmsgtimer),hl
        BDOSSETPGSSCR
pgscrbuf=$+1
        ld a,0 ;ok
        SETPG4000
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
       ;ld a,5 ;m
       ;out (-2),a
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
        jp z,term_prfsm_afterescbracket_m
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
       if TEXTMODE
        ld bc,LINESTEP;0x0040
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
       else
;TODO speedup
        ld bc,LINESTEP;40
term_prfsm_afterescbracket_clearline0
        ex de,hl
        xor a
        dup CHRHGT-1
        ld (hl),a
        add hl,bc
        edup
        ld (hl),a
        res 6,h
        ld bc,-LINESTEP
        dup CHRHGT-1
        ld (hl),a
        add hl,bc
        edup
        ld (hl),a
        ld bc,LINESTEP;40
        set 6,h
        bit 5,h
        set 5,h
        jr z,clearline_nextaddr_ok
        res 5,h
        inc hl
clearline_nextaddr_ok
        ex de,hl
        ld (hl),a
        ld a,l
        add a,0x40 ;attr
        adc a,b
        ld l,a
        ld (hl),b
        add a,0x40 ;text (next)
        ld l,a
        cp 0x40+(80/2)
        jp nz,term_prfsm_afterescbracket_clearline0
       endif
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
forcereprintcursor
        ;push de
        ;push hl
        ;OS_GETTIMER ;dehl=timer
        ;dec h
        ;ld (lastsdtinmsgtimer),hl
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
        ld hl,(term_prfsm_curnumber3) ;wid первый по счёту
        ld a,(term_prfsm_curnumber2) ;hgt
        ld h,a ;hgt
        push de
        push hl
        ld a,d
        add a,h
        dec a
        ld d,a ;ybottom
       if TEXTMODE
        ld a,l ;wid
        cp 80
        jr nz,term_prfsm_afterescbracket_scrolldown_OS
;de=bottomyx, hl=hgt,wid
;x, wid even
        call BDOS_scroll_prepare
BDOS_scrolldown0
        push bc
        ld d,h
        ld e,l
        ld bc,-LINESTEP
        add hl,bc
        call BDOS_scrollpageline ;spoils a (ldi)
        pop bc
        djnz BDOS_scrolldown0
        jr term_prfsm_afterescbracket_scrolldown_OSq
term_prfsm_afterescbracket_scrolldown_OS
        ;OS_SCROLLDOWN ;было до пересчёта ybottom
        call BDOS_scroll_prepare
        ld a,b
        ld bc,-LINESTEP
        call BDOS_scrollwindow ;(ldir)
term_prfsm_afterescbracket_scrolldown_OSq
       else
        call BDOS_scroll_prepare
;hl=pixelline(bottom-5)
        ex de,hl
        ld hl,CHRLINESTEP-LINESTEP ;pixelline(bottom)
        add hl,de
        ex de,hl
        ld a,b
        ld bc,-LINESTEP
        add hl,bc
;hl=pixelline(bottom-6)
;de=pixelline(bottom)
        call BDOS_scrollwindow
       endif
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
       if !TEXTMODE
        ld hl,(pr_curlineaddr)
        ld (cursor_remember_scrlineaddr),hl
       endif
        ld hl,(pr_buf_curaddr)
        ld (cursor_remember_bufaddr),hl
        ret
cursor_remember
cursor_remember_scraddr=$+1
        ld hl,SCRBASE
        ld (pr_textmode_curaddr),hl
       if !TEXTMODE
cursor_remember_scrlineaddr=$+1
        ld hl,SCRBASE
        ld (pr_curlineaddr),hl
       endif
cursor_remember_bufaddr=$+1
        ld hl,0x4040
        ld (pr_buf_curaddr),hl
        ret

term_prfsm_afterescbracket_scrollup
        ld a,(term_prfsm_curnumber1)
        ld e,a ;xtop
        ld a,(term_prfsm_curnumber)
        ld d,a ;ytop
        ld hl,(term_prfsm_curnumber3) ;wid ;первый по счёту
        ld a,(term_prfsm_curnumber2)
        ld h,a ;hgt
        ld a,l ;wid
        or a
        jr z,cursor_remember
        push bc
        push de
        push hl
;de=topyx, hl=hgt,wid
;x, wid even
       if TEXTMODE
        cp 80
        jr nz,term_prfsm_afterescbracket_scrollup_OS
        call BDOS_scroll_prepare
        call BDOS_scrollpage0 ;62927 t (ldi)
        jr term_prfsm_afterescbracket_scrollup_OSq
term_prfsm_afterescbracket_scrollup_OS
        ;OS_SCROLLUP ;95597 t
        call BDOS_scroll_prepare
        ld a,b
        ld bc,LINESTEP
        call BDOS_scrollwindow ;(ldir)
term_prfsm_afterescbracket_scrollup_OSq
       else
        call BDOS_scroll_prepare
        ex de,hl
        ld hl,CHRLINESTEP
        add hl,de
        ld a,b
        ld bc,LINESTEP
        call BDOS_scrollwindow
       endif
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
        SETPG4000
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
        ld a,l
        srl a
        ld (BDOS_scrollwindowlinelayer_wid),a
       if TEXTMODE
        ld b,h ;hgt
        dec b
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
       else
        ld a,h ;hgt
        dec a
        ld b,a
        add a,a
        add a,b
        add a,a ;hgt*6 (CHRHGT=6)
        ld b,a
xytoscr
        ld a,e ;x
        call ytoscr
        rra
        jr nc,$+4
        set 5,h
        add a,l
        ld l,a
        ret nc;jr nc,$+3
        inc h
        ret
ytoscr
        ld l,d ;y
        ld h,0
        ld d,h
        ld e,l
        add hl,hl
        add hl,hl
        add hl,de ;y*5
        add hl,hl
        add hl,hl
        add hl,hl ;y*40
        ld d,h
        ld e,l
        add hl,hl
        add hl,de
        add hl,hl ;y*40*6 (CHRHGT=6)
        set 7,h
        set 6,h
        ret
       endif

BDOS_scrollpageline_bufwindow
       if TEXTMODE
        or a
       endif
        call BDOS_scrollpageline_bufwindowlayers ;text
        res 6,l ;attr
        res 6,e ;attr
       if TEXTMODE
        scf
       endif
        call BDOS_scrollpageline_bufwindowlayers ;attr
        set 6,l ;text
        ret
BDOS_scrollpageline_bufwindowlayers
        push af
        push de
        push hl
        set 7,l
        set 7,e
       if TEXTMODE
        or a
       endif
        call BDOS_scrollpageline_bufwindowlayer
        pop hl
        pop de
        pop af
BDOS_scrollpageline_bufwindowlayer
        push de
        push hl
       if TEXTMODE
        jr nc,$+4
        inc hl
        inc de
       endif
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

BDOS_scrollpage ;for lf_q
;156046t [195810t ldir]
        BDOSSETPGSSCR
       if TEXTMODE
        ld hl,SCRBASE
        ld b,HTMLHGT-1;24
       else
        ld hl,SCRBASE+CHRLINESTEP
        ld de,SCRBASE
        ld b,CHRHGT*(HTMLHGT-1)
       endif
BDOS_scrollpage0
        push bc
       if TEXTMODE
        ld d,h
        ld e,l
        ld bc,LINESTEP
        add hl,bc
        call BDOS_scrollpageline
       else
        call BDOS_scrollpageline
        ld bc,LINESTEP
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
       endif
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
       if TEXTMODE
        inc l
        inc e
       endif
        dup 39
        ldd
        edup
        ld a,(hl)
        ld (de),a
       if TEXTMODE
        dec l
        dec e
       endif
        set 6,h
        set 6,d
        ret

BDOS_scrollwindow
;a=hgt-scrollstep
;bc=linestep
;TEXTMODE: hl=top
;!TEXTMODE: hl=topfrom, de=topto
BDOS_scrollwindow0
       if TEXTMODE
        ld d,h
        ld e,l
        add hl,bc
       endif
        push bc
        call BDOS_scrollwindowline
        pop bc
       if !TEXTMODE
        add hl,bc
        ex de,hl
        add hl,bc
        ex de,hl
       endif
        dec a
        jr nz,BDOS_scrollwindow0
        ret

BDOS_scrollwindowline
       if TEXTMODE
        or a
       endif
        call BDOS_scrollwindowlinelayers ;text
       if TEXTMODE
        scf
       endif
        res 6,h ;attr
        res 6,d ;attr
        call BDOS_scrollwindowlinelayers
        set 6,h ;text
        set 6,d ;text
        ret
BDOS_scrollwindowlinelayers
       if TEXTMODE
        push af
       endif
        push de
        push hl
        set 5,h
        set 5,d
       if TEXTMODE
        or a
       endif
        call BDOS_scrollwindowlinelayer
        pop hl
        pop de
       if TEXTMODE
        pop af
       endif
BDOS_scrollwindowlinelayer
        push de
        push hl
       if TEXTMODE
        jr nc,$+4
        inc hl
        inc de
       endif
BDOS_scrollwindowlinelayer_wid=$+1
        ld bc,39;40
        ldir
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
        ld a,FINVISIBLE_OFF
        ld (finvisible),a
        xor a
        ld (finvisible2),a
        ret
term_setinvisible
        ld a,FINVISIBLE_ON
        ld (finvisible),a
        ld a,0x5e ;"ld e,(hl)"
        ld (finvisible2),a
        ret

mousemove
;de=mouse delta
;чтобы двигать не резко, надо отдельно хранить младшие части x,y (не отображаемые на экране)
        ld hl,(mousexy)
htmlcursorxylow=$+1
        ld bc,0 ;bits 7..5 (for Y) 7..6 (for X), others=0
        sla b
        rl h
        sla b
        rl h
       if MOUSEFACTOR == 8
        sla b
        rl h
       endif
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
       if MOUSEFACTOR == 8
        rra
        rr b
       endif
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
        ld de,MOUSEFACTORX*(80-1)
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
        ;ld a,(user_scr0_low) ;ok
        ;SETPG8000 ;attr ;TODO убрать? считывать из scrbuf!
       if TEXTMODE
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
       else
        call xytoscr
        res 6,h ;attr
       endif
        ret

BDOS_countattraddr
        ld a,(user_scr0_low) ;ok
        SETPG8000 ;attr ;TODO убрать? считывать из scrbuf!
        ld hl,(pr_textmode_curaddr)
;textaddrtoattraddr
       if TEXTMODE
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
         and 0x20
        ret nz ;jr nz,$+3
        inc l
       else
        res 6,h
       endif
        ret

getscrbuftop_a
        ld hl,(pr_buf_curtopaddr)
        ld a,h
redraw_scroll=$+1
        sub 0;24
         cp 0x40
         ret nc;jr nc,$+4
         ld a,0x40 ;TODO prevpg
        ret

cursor_left
;TODO с переходом на предыдущую строку?
        ld hl,(pr_textmode_curaddr)
       if TEXTMODE
        ld a,h
        xor 0x20 ;attr + 0x20
        ld h,a
        and 0x20
        jr z,cursor_left_nodec
        ld a,l
        and 0x3f
        jr z,cursor_left_nodec ;остаёмся в начале строки
        dec l
cursor_left_nodec
       else
        bit 5,h
        res 5,h
        jr nz,cursor_left_nodec
        set 5,h
        dec hl
        ld de,(pr_curlineaddr)
        or a
        sbc hl,de
        jr nc,$+3
        ex de,hl ;остаёмся в начале строки
cursor_left_nodec
       endif
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
        ld a,WRITED1_OFF
        ld (writed1),a
        ld a,WRITEE1_OFF
        ld (writee1),a
        xor a
        ld (writed2),a
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
        ld a,WRITED1_ON
        ld (writed1),a
        ld a,WRITEE1_ON
        ld (writee1),a
        ld a,0x72 ;"ld (hl),d"
        ld (writed2),a
        ld a,0x73 ;"ld (hl),e"
        ld (writee2),a
        ret

BDOS_setx
;e=x
        ld a,e
        or 0x80
        rrca ;(x/2)+0x40 или 0xc0
        ld (pr_buf_curaddr),a
       if TEXTMODE
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
       else
        ld hl,(pr_curlineaddr)
        ld a,e ;x
        jr BDOS_setxy_setx
       endif

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
       if TEXTMODE
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
       else
        ld a,e
        call ytoscr
        ld (pr_curlineaddr),hl
BDOS_setxy_setx
        srl a ;rra
        jr nc,$+4
        set 5,h
        add a,l
        ld l,a
        jr nc,$+3
        inc h
       endif
BDOS_settextcuraddr
        ld (pr_textmode_curaddr),hl
        ret

BDOS_prchar_tab
        ld a,' '
        call BDOS_prchar_a_nocrlf
        ld hl,(pr_textmode_curaddr)
        bit 5,h
        jr nz,BDOS_prchar_tab
        ld a,l
        and 3 ;tab = 8 chrs = 4 pairs
        jr nz,BDOS_prchar_tab
        ret

BDOS_prchar_controlcode
         ld hl,(pr_textmode_curaddr)
        cp 0x09
        ;jr z,BDOS_prchar_tab
        cp 0x0a
        jr z,BDOS_prchar_lf
        cp 0x0d
        jp nz,BDOS_prchar_nocontrolcode
BDOS_prchar_cr
         ld a,0x40
         ld (pr_buf_curaddr),a ;x=0
       if TEXTMODE
        ld a,l
        and 0xc0
        ld l,a
        res 5,h
       else
pr_curlineaddr=$+1
        ld hl,SCRBASE
       endif
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
       if TEXTMODE
        ld a,l
        add a,CHRLINESTEP;0x40
        ld l,a
        jr nc,BDOS_settextcuraddr
        jp BDOS_prchar_lf_inchq
       else
        ld de,CHRLINESTEP;40*CHRHGT
        add hl,de
        push hl
        ld hl,(pr_curlineaddr)
        add hl,de
        ld (pr_curlineaddr),hl
        ld de,SCRBASE+(HTMLHGT*CHRLINESTEP)
        sbc hl,de
        pop hl
        jr c,BDOS_settextcuraddr
        jp BDOS_prchar_lf_q
       endif

cursor_down
        ld a,0x0a ;lf
BDOS_prchar_a
;keeps bc!
        cp 0x0e
        jr c,BDOS_prchar_controlcode
BDOS_prchar_a_nocrlf
pr_textmode_curaddr=$+1
        ld hl,SCRBASE
       if TEXTMODE
	ld d,trecode/256
	ld e,a
	ld a,(de)
       endif
BDOS_prchar_nocontrolcode
        ld e,a
       if TEXTMODE
FINVISIBLE_OFF=0
FINVISIBLE_ON=0x5e ;"ld e,(hl)"
WRITEE1_ON=0x73 ;"ld (hl),e"
WRITEE1_OFF=0
finvisible=$
        nop ;/ld e,(hl)
writee1=$ ;patch для cursorright
        ld (hl),e
       else
        push bc
        ld bc,40
        or a
WRITEE1_ON=0x38 ;"jr c"
WRITEE1_OFF=0x30 ;"jr nc"
writee1=$ ;patch для cursorright
        jr c,prchar_skip_e
FINVISIBLE_OFF=0x38 ;"jr c"
FINVISIBLE_ON=0x30 ;"jr nc"
finvisible=$
        jr c,prchar_skip_e
;prchar_skip_e_base=$
        push hl
        ld d,fnt/256
       dup CHRHGT-1
        ld a,(de)
        ld (hl),a
        inc d
        add hl,bc
       edup
        ld a,(de)
        ld (hl),a
        pop hl
prchar_skip_e
;FINVISIBLE_OFF=0 ;no skip
;FINVISIBLE_ON=prchar_skip_e-prchar_skip_e_base
       endif

pr_textmode_curcolor=$+1
        ld d,7
       if TEXTMODE
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
        and 0x20
        jr nz,$+3
        inc l
       else
        res 6,h
       endif
       if TEXTMODE
WRITED1_ON=0x72 ;"ld (hl),d"
WRITED1_OFF=0
writed1=$ ;patch для cursorright
        ld (hl),d
       else
WRITED1_ON=0x38 ;"jr c"
WRITED1_OFF=0x30 ;"jr nc"
writed1=$ ;patch для cursorright
        jr c,prchar_skip_d
;prchar_skip_d_base=$
        push hl
       dup CHRHGT-1
        ld (hl),d
        add hl,bc
       edup
        ld (hl),d
        pop hl
prchar_skip_d
;WRITED1_ON=0 ;no skip
;WRITED1_OFF=prchar_skip_d-prchar_skip_d_base
        pop bc
       endif

       if TEXTMODE
        set 6,h
        ld (pr_textmode_curaddr),hl
       else
        set 6,h
        bit 5,h
        set 5,h
        jr z,pr_nextaddr_ok
        res 5,h
        inc hl
pr_nextaddr_ok
        ld (pr_textmode_curaddr),hl
       endif

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

;new line
       if TEXTMODE
        ld hl,(pr_textmode_curaddr)
        ld a,l
        and 0xc0
        add a,CHRLINESTEP;0x40
        ld l,a
        jp nc,BDOS_settextcuraddr
BDOS_prchar_lf_inchq
        inc h
        bit 3,h
        jp z,BDOS_settextcuraddr ;нет выхода за последнюю строку
       else
        ld hl,(pr_curlineaddr)
        ld de,CHRLINESTEP
        add hl,de
        ld (pr_curlineaddr),hl
        ;or a
        ld de,SCRBASE+(HTMLHGT*CHRLINESTEP)
        sbc hl,de
        add hl,de
        jp c,BDOS_settextcuraddr
;hl=адрес начала следующей строки, но экран кончился, поэтому считаем на строку выше
BDOS_prchar_lf_q
       endif
;hl=адрес внутри следующей строки, но экран кончился, поэтому считаем на строку выше
        ld de,-CHRLINESTEP
        add hl,de
        ld (pr_textmode_curaddr),hl
       if !TEXTMODE
        ld hl,(pr_curlineaddr)
        add hl,de
        ld (pr_curlineaddr),hl
       endif
BDOS_scrolllock0
        ld a,0xfe
        in a,(0xfe)
        rra ;Caps Shift
        jr nc,BDOS_scrolllock0
;scroll+clear bottom line
       push bc
        call buftopaddr_down
        call BDOS_scrollpage
       if TEXTMODE
_lastlineshift=0x07c0
       else
_lastlineshift=(HTMLHGT-1)*CHRHGT*40
       endif
        xor a
        ld hl,0xc000+_lastlineshift
        call BDOS_cllastline_layer
        ld hl,0xe000+_lastlineshift
        call BDOS_cllastline_layer
        ld a,COLOR
        ld hl,0x8000+_lastlineshift
        call BDOS_cllastline_layer
        ld hl,0xa000+_lastlineshift
        call BDOS_cllastline_layer
       pop bc
        ret
        
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

BDOS_cllastline_layer
       if !TEXTMODE
        ld bc,40*CHRHGT-1
        jr BDOS_scrollpage_cllinelayer_bc
       endif
BDOS_scrollpage_cllinelayer ;for buf
        ld bc,41-1
BDOS_scrollpage_cllinelayer_bc
        ld d,h
        ld e,l
        inc e
        ld (hl),a
        ldir ;clear bottom line
        ret

BDOS_cls
;e=color byte
        ld a,(pgscrbuf)
        SETPG4000
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

clspp
;textmode (6)
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
       if TEXTMODE
         ld bc,0x1aff
       else
         ld bc,8000-1
       endif
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
        SETPGC000
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
        SETPGC000
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
        SETPGC000
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
       if TEXTMODE
        db "z:/a25",0
       else
        db "z:/a33",0
       endif

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
       if TEXTMODE
trecode
	incbin "../_sdk/codepage/866toatm"
trecodeback
        ds 256
       else
fnt
        incbin "1125ver6.fnt"
       endif
        
end
       if TEXTMODE
	savebin "term.com",begin,end-begin
       else
	savebin "term33.com",begin,end-begin
       endif

	LABELSLIST "..\..\us\user.l"
