;----------------------------------------------------------------------
; Вход: A(символ)
; Печать символа в поток
; ----------------------------------------------------------------------

print_char: push    af
            ;push    bc
            ;push    de
            push    hl
            ld      hl, (video_cursor)
            ;cp      10
            ;jr      z, .pc2                 ; Код переноса на другую строку
            ld (hl),a                 ; Записать 8 бит
            inc hl
            ld (video_cursor),hl
            ; ------------
            ld      hl, _param_cnt
            inc     (hl)
            ; ------------
            pop     hl
            ;pop     de
            ;pop     bc
            pop     af
            ret
