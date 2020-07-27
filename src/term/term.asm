        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

;TODO при закрытии cmd term должен закрыться

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
        ld (pgscrbuf_low),a
        ld a,l
        ld (pgscrbuf_high),a
        
        ld e,COLOR
        call BDOS_cls

        ld a,(stdinhandle)
        ld e,a
        ld a,(stdouthandle)
        ld d,a
        ld h,0xff ;rnd
;b=id, e=stdin, d=stdout, h=stderr        
        OS_SETSTDINOUT

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
        ld (waitpid_id),a
        OS_RUNAPP

execcmd_error
        ;jr mainloop
mainloop_afternokey
mainloop_afterkey
;mainloop
        YIELD
         ;ld a,4
         ;out (0xfe),a
;unprint cursor
unprint_cursor_color=$+1
        ld e,COLOR
         ;ld a,r
         ;ld e,a
        call BDOS_prattr
        
waitpid_id=$+1
        ld e,0
        OS_WAITPID ;TODO проверять, что пайп с той стороны не закрыт
        or a
        jp z,quit
        
        call type_stdin ;stdin to screen
        YIELDKEEP
        call type_stdin ;stdin to screen
         ;ld a,5
         ;out (0xfe),a
       
        call BDOS_countattraddr
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
         ;ld a,7
         ;out (0xfe),a
        ld e,CURSORCOLOR
        call BDOS_prattr
         ;ld a,6
         ;out (0xfe),a
noprintcursor

         ;ld a,6
         ;out (0xfe),a
;mainloop_afterkey
        GET_KEY
         ;push af
         ;ld a,7
         ;out (0xfe),a
         ;pop af
        or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        jr z,mainloop_afternokey
        cp key_redraw
        jr z,redraw
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
        
redraw
        ld a,(pgscrbuf_low)
        SETPG32KLOW
        ld a,(user_scr0_low) ;ok
        SETPG32KHIGH
        ld hl,0x8000
        ld de,0xc000
        ld bc,0x4000
        ldir
        ld a,(pgscrbuf_high)
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok
        SETPG32KHIGH
        ld hl,0x8000
        ld de,0xc000
        ld bc,0x4000
        ldir
        jp mainloop_afterkey
        
quit
;cmd closed!!!

        ld a,(stdinhandle)
        ld b,a
        OS_CLOSEHANDLE
        ld a,(stdouthandle)
        ld b,a
        OS_CLOSEHANDLE
        QUIT

type_stdin
        ld de,stdinbuf
        ld hl,STDINBUF_SZ
stdinhandle=$+1
        ld b,0
        ;ld b,0xff
        OS_READHANDLE
;hl=size
        ld a,h
        or l
        ret z ;jr z,nostdinmsg;mainloop_afterkey

        push hl
         OS_GETTIMER ;hlde=timer
         ld (lastsdtinmsgtimer),de
        pop bc
        ld hl,stdinbuf
term_print0
        push bc
        push hl
        ;ld a,(hl)
        ;PRCHAR
        ld e,(hl)
        call term_prfsm;OS_PRCHAR
        pop hl
        pop bc
        cpi
        jp pe,term_print0
;nostdinmsg
        ret

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
        ;OS_SETXY
        call BDOS_setxy
         call forcereprintcursor ;не прокатит, в начале печати cmd тоже setxy
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

term_prfsm_prchar
;e=char
        ;OS_PRCHAR
        jp BDOS_prchar

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

        if 1==0
BDOS_getxy
;out: de=yx ;GET CURSOR POSITION
        ld hl,(pr_textmode_curaddr)
        ;ld l,(iy+app.textcuraddr)
        ;ld h,(iy+app.textcuraddr+1)
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
        ;BDOSSETPGSSCR
        ld a,(pgscrbuf_low)
        SETPG32KLOW ;attr
        ld hl,(pr_textmode_curaddr)
        ;ld l,(iy+app.textcuraddr)
        ;ld h,(iy+app.textcuraddr+1)
        ld a,h
        xor 0x60 ;attr + 0x20
        ld h,a
         and 0x20
        jr nz,$+3
        inc l
        ret
        
BDOS_prattr
;e=color byte
        call BDOS_countattraddr
        ld (hl),e
        BDOSSETPGSSCR
        ld (hl),e
        ret

BDOS_setxy
;de=yx
        call BDOS_countxy
BDOS_settextcuraddr
        ld (pr_textmode_curaddr),hl
        ;ld (iy+app.textcuraddr),l
        ;ld (iy+app.textcuraddr+1),h
        ;xor a ;success
        ret
        
BDOS_prchar_controlcode
        cp 0x0a
        jr z,BDOS_prchar_lf
        cp 0x0d
        jp nz,BDOS_prchar_nocontrolcode
        ;jr z,BDOS_prchar_cr
BDOS_prchar_cr
        ld a,l
        and 0xc0
        ld l,a
        res 5,h
        jr BDOS_settextcuraddr
        ;jp BDOS_prchar_q
        
BDOS_prchar_lf
        ld a,l
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr ;BDOS_prchar_q ;ret nc
        jr BDOS_prchar_lf_q

BDOS_prchar
;e=char
        ld a,e
BDOS_prchar_a
;портит только 0xc000+, но сама восстанавливает там pgkillable (для быстрого вызова через rst)
	ld h,trecode/256
	ld l,a
	ld a,(hl)
pr_textmode_curaddr=$+1
        ld hl,0xc1c0
        ;ld l,(iy+app.textcuraddr)
        ;ld h,(iy+app.textcuraddr+1)
        cp 0x0e
        jr c,BDOS_prchar_controlcode
BDOS_prchar_nocontrolcode
        ld e,a
        ld a,(user_scr0_high) ;ok ;pgscr0_1
        SETPG32KHIGH ;call sys_setpgc000
        ld (hl),e
pgscrbuf_high=$+1
        ld a,0 ;ok ;pgscr0_1
        SETPG32KHIGH ;call sys_setpgc000
        ld (hl),e
        ld a,(user_scr0_low) ;ok ;pgscr0_0
        SETPG32KHIGH ;call sys_setpgc000
;BDOS_prchar_skip        

        ;ld de,0x2000 + pgkillable
        
         ;push af

        ld a,h
        xor 0x20;d;0x20 ;attr + 0x20
        ld h,a
        and 0x20;d;0x20
        jr nz,$+3
        inc l

pr_textmode_curcolor=$+1
        ld e,7
        ld (hl),e
pgscrbuf_low=$+1
        ld a,0 ;ok ;pgscr0_0
        SETPG32KHIGH ;call sys_setpgc000
        ld (hl),e

        ld a,l
        and 0x3f
        cp 80/2
        ld (pr_textmode_curaddr),hl
        ;ld (iy+app.textcuraddr),l
        ;ld (iy+app.textcuraddr+1),h
        ret nz ;jr nz,BDOS_prchar_q ;ret nz ;нет переноса строки
        ld a,l
        and 0xc0
        add a,0x40
        ld l,a
        jr nc,BDOS_settextcuraddr ;BDOS_prchar_q ;ret nc
BDOS_prchar_lf_q
        inc h
        bit 3,h
        jr z,BDOS_settextcuraddr ;BDOS_prchar_q ;нет выхода за последнюю строку
BDOS_scrolllock0
        ld a,0xfe
        in a,(0xfe)
        rra ;Caps Shift
        jr nc,BDOS_scrolllock0
        ;ld hl,(appaddr)
        ;ld de,(focusappaddr)
        ;or a
        ;sbc hl,de
        ;jr nz,BDOS_prchar_skipscroll
;scroll+clear bottom line
        call BDOS_scrollpage ;attr
        ld a,(pgscrbuf_high) ;ok ;pgscr0_0 ;text
        SETPG32KHIGH ;call sys_setpgc000
        call BDOS_cllastline
        ld a,(pgscrbuf_low) ;ok ;pgscr0_0 ;attr
        SETPG32KHIGH ;call sys_setpgc000
        call BDOS_cllastline
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        SETPG32KHIGH ;call sys_setpgc000
        call BDOS_cllastline
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        SETPG32KHIGH ;call sys_setpgc000
        call BDOS_cllastline
        ;ld a,pgkillable
        ;ld bc,memportc000
        ;out (c),a
        ;call sys_setpgc000
BDOS_prchar_skipscroll
        ld hl,0xc7c0
BDOS_prchar_q
        jp BDOS_settextcuraddr
        ;;ld (pr_textmode_curaddr),hl
        ;ld (iy+app.textcuraddr),l
        ;ld (iy+app.textcuraddr+1),h
        ;ret
        
BDOS_scrollpage
        ld a,40
        ld (BDOS_scrollpagelinelayer_wid),a
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
        ld a,(pgscrbuf_high) ;ok ;pgscr0_1 ;text
        or a
        call BDOS_scrollpagelinelayers ;text
        ld a,(pgscrbuf_low) ;ok ;pgscr0_0 ;attr
        scf
        call BDOS_scrollpagelinelayers ;attr
        ld a,(user_scr0_high) ;ok ;pgscr0_1 ;text
        or a
        call BDOS_scrollpagelinelayers ;text
        ld a,(user_scr0_low) ;ok ;pgscr0_0 ;attr
        scf
BDOS_scrollpagelinelayers
        ;ld bc,memportc000
        ;out (c),a
        SETPG32KHIGH ;call sys_setpgc000
        push af
        push de
        push hl
        set 5,h
        set 5,d
        or a
        call BDOS_scrollpagelinelayer
        pop hl
        pop de
        pop af
BDOS_scrollpagelinelayer
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

BDOS_scrolldown
;de=topyx, hl=hgt,wid
;x, wid even
         ;push hl
         ;ld hl,(appaddr)
         ;ld bc,(focusappaddr)
         ;or a
         ;sbc hl,bc
         ;pop hl
         ;ret nz
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
         ;push hl
         ;ld hl,(appaddr)
         ;ld bc,(focusappaddr)
         ;or a
         ;sbc hl,bc
         ;pop hl
         ;ret nz
        call BDOS_scroll_prepare
        jp BDOS_scrollpage0
        
BDOS_cllastline
        ld hl,0xc7c0
        call BDOS_scrollpage_clline
        ;ld de,0xc7c1
        ;ld bc,64-1
        ;ld (hl),b
        ;ldir
        ld hl,0xe7c0
BDOS_scrollpage_clline        
        ld d,h
        ld e,l
        inc e
        ld bc,64-1
        ld (hl),b
        ldir ;clear bottom line
        ret
        
BDOS_setcolor
;e=color byte
        ld a,e
        ld (pr_textmode_curcolor),a
        ;ld (iy+app.curcolor),e
        ret
        
BDOS_cls
         ;ld hl,(appaddr)
         ;ld bc,(focusappaddr)
         ;or a
         ;sbc hl,bc
         ;ret nz
        ;ld iy,(appaddr)
;e=color byte
        ld a,(pgscrbuf_low)
        SETPG32KLOW
        ld a,(pgscrbuf_high)
        SETPG32KHIGH
        call clspp

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

;sys_setpgc000
;        SETPG32KHIGH
;        ret

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
