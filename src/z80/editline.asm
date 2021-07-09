EditLine_xyde_widb
        ld (EditLine_addr),hl
        ld (EditLine_xy),de
        ld a,b
        ld (EditLine_wid),a
        xor a
        ld (EditLine_curx),a
        call EditLine_Redraw
EditLine0
        call EditLine_drawcursor
        YIELDGETKEYLOOP
        push af
        ;call EditLine_undrawcursor
        call EditLine_Redraw
        pop af
        cp key_esc
        ret z
        cp key_enter
        ret z
        ld hl,EditLine0
        push hl
        cp key_left
        jr z,EditLineLeft
        cp key_right
        jr z,EditLineRight
        cp key_backspace
        jr z,EditLineBackSpace
        call EditLine_edit
EditLine_Redraw
        ld de,(EditLine_xy)
        OS_SETXY
        ld hl,disasmtextbuf
        ld a,(EditLine_wid)
        ld b,a
        jp Debugger_PrChars_hl_b

EditLineBackSpace
        call EditLineLeft
        call EditLine_curaddr
        ld (hl),' '
        jp EditLine_Redraw
        
EditLineLeft
        ld hl,EditLine_curx
        dec (hl)
        ret p
        inc (hl)
        ret
EditLineRight
        ld hl,EditLine_curx
        ld a,(EditLine_wid)
        inc (hl)
        cp (hl)
        ret nz
        dec (hl)
        ret

EditLine_edit
        call EditLine_curaddr
        ld (hl),a
        call EditLineRight
        jp EditLine_Redraw

EditLine_curaddr
        ld hl,(EditLine_addr)
        ld bc,(EditLine_curx)
        ld b,0
        add hl,bc
        ret

EditLine_drawcursor
        ld de,(EditLine_xy)
        ld a,(EditLine_curx)
        add a,e
        ld e,a
        OS_SETXY
        ld e,DEBUGGER_COLORCURSOR;0x38
        OS_PRATTR
        ret

EditLine_curx
        db 0
EditLine_xy
        dw 0
EditLine_wid
        db 0
EditLine_addr
        dw 0
