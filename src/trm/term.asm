        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

STDINBUF_SZ=256

        org PROGSTART
begin
        ld e,6 ;textmode
        OS_SETGFX

        OS_GETSTDINOUT ;e=stdin, d=stdout, h=stderr
        ld a,e
        ld (stdinhandle),a
        ld a,d
        ld (stdouthandle),a

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
        jr z,quit
        ld (stdoutbuf),a
         ;ld e,a
         ;OS_PRCHAR
        ld de,stdoutbuf
        ld hl,1
stdouthandle=$+1
        ld b,0
        OS_WRITEHANDLE
        jr mainloop_afterkey
quit

        ld a,(stdinhandle)
        ld b,a
        OS_CLOSEHANDLE
        ld a,(stdouthandle)
        ld b,a
        OS_CLOSEHANDLE
        QUIT

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

stdinfn
        db "stdin",0
stdoutfn
        db "stdout",0

stdoutbuf
        db 0

stdinbuf
        ds STDINBUF_SZ

end
	savebin "term.com",begin,end-begin
