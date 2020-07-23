        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

RECODEINPUT=0;1

STDINBUF_SZ=256

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
        ld de,stdinbuf
        ld hl,STDINBUF_SZ
stdinhandle=$+1
        ld b,0
        ;ld b,0xff
        OS_READHANDLE
;hl=size
        ld a,h
        or l
        jr z,mainloop_afterkey
        ld b,h
        ld c,l
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

        
mainloop_afterkey
        GET_KEY
        or a ;cp NOKEY ;keylang==0?
        ;jr nz,$+3
        ;cp c ;keynolang==0?
        jr z,mainloop
        cp key_redraw
        ;jr z,
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
        
quit
;TODO close cmd!!!

        ld a,(stdinhandle)
        ld b,a
        OS_CLOSEHANDLE
        ld a,(stdouthandle)
        ld b,a
        OS_CLOSEHANDLE
        QUIT

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

sendchar
        cp 0x80
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
        YIELD
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

term_prfsm_prchar
;e=char
        OS_PRCHAR
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

stdinbuf
        ds STDINBUF_SZ

;cmdbuf
;        db "cmd.com autoexec.bat",0 ;чтобы потом входить в интерактивный режим (cmd проверяет первое слово), иначе придётся прописать в autoexec.bat команду cmd и иметь две задачи cmd (одну висящую в ожидании другого cmd)
        
end
	savebin "term.com",begin,end-begin
