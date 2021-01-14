editline
;de=yx
;hl=textaddr
;a=maxsz
;out: a=key_enter/key_esc
        ld (editline_maxsz),a
        ld (editline_xy),de
        ld (editline_text),hl
        call strlen ;hl=len
        ld a,l
        ld (editline_curx),a
        
editline_mainloop
        call editline_pr
        ld de,(editline_xy)
editline_curx=$+1
        ld a,0
        add a,e
        ld e,a
       if PRSTDIO
        SETXY_
       else
        OS_SETXY
       endif
	;OS_GETATTR
        ; ld e,a
	; push de ;color under cursor
        ;ld e,CURSORCOLOR;#38
        ;OS_PRATTR ;draw cursor
       if PRSTDIO
        call yieldgetkeyloop
       else
        YIELDGETKEYLOOP
       endif
	; pop de ;d=color under file cursor
        ;push af
        ;OS_PRATTR ;remove cursor
        ;pop af
        cp key_redraw
        jr z,editline_mainloop
        cp key_enter
        ret z
        cp key_esc
        ret z
        ld hl,editline_mainloop
        push hl
        ld hl,(editline_text)
        cp key_left
        jr z,editline_left
        cp key_right
        jr z,editline_right
        cp key_backspace
        jr z,editline_backspace
        cp key_del
        jr z,editline_del
        cp 0x20
        ret c ;прочие системные кнопки не нужны
        ld e,a
        push hl
        call strlen ;hl=len
        ld a,(editline_maxsz)
        cp l
        pop hl
        ret z
        ld a,(editline_curx)
        ld c,a
        ld b,0
        add hl,bc
        inc a
        ld (editline_curx),a
        jp strinsch
editline_backspace
        ld a,(editline_curx)
        or a
        ret z
        ld c,a
        ld b,0
        add hl,bc
        dec a
        ld (editline_curx),a
        jp strdelch ;стирает предыдущий символ
        
editline_del
        ld a,(editline_curx)
        ld c,a
        ld b,0
        add hl,bc
        ld a,(hl)
        or a
        ret z
        inc hl
        jp strdelch ;стирает предыдущий символ

editline_left
        ld hl,editline_curx
        ld a,(hl)
        or a
        ret z
        dec (hl)
        ret

editline_right
        call strlen ;hl=len
        ld a,l
        ld hl,editline_curx
        cp (hl)
        ret z
        inc (hl)
        ret
        
editline_pr
editline_xy=$+1
        ld de,0
       if PRSTDIO
        SETXY_
       else
        OS_SETXY
       endif
editline_text=$+1
        ld hl,0
        ld c,0 
        call prtext
;добьём остаток строки пробелами
editline_prspc0
        ld a,c
editline_maxsz=$+1
        cp 0
        ret z
        push bc
        ld a,' '
       if PRSTDIO
        PRCHAR_
       else
        PRCHAR
       endif
        pop bc
        inc c
        jp editline_prspc0
