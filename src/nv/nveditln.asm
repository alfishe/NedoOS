editline
;de=yx
;hl=textaddr
;a=maxsz
;out: a=Enter/csSpace
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
        OS_SETXY
	OS_GETATTR
         ld e,a
	 push de ;color under cursor
        ld e,CURSORCOLOR;#38
        OS_PRATTR ;draw cursor
        YIELDGETKEYLOOP
	 pop de ;d=color under file cursor
        push af
        OS_PRATTR ;remove cursor
        pop af
        cp key_redraw
        jr z,editline_mainloop
        cp Enter
        ret z
        cp csSpace
        ret z
        ld hl,editline_mainloop
        push hl
        ld hl,(editline_text)
        cp cs5
        jr z,editline_left
        cp cs8
        jr z,editline_right
        cp cs0
        jr z,editline_backspace
        cp cs9
        jr z,editline_del
        cp 32
        ret c
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
        OS_SETXY
editline_text=$+1
        ld hl,0
        ld c,0 
        call cmdprtext
;добьём остаток строки пробелами
editline_prspc0
        ld a,c
editline_maxsz=$+1
        cp 0
        ret z
        push bc
        ld a,' '
        PRCHAR
        pop bc
        inc c
        jp editline_prspc0
