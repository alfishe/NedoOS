       macro asmgetchar
        ld a,(de)
        ;or 0x20
       endm
       macro asmnextchar
        inc de
       endm        

;поддержать откручивание на 2 байта назад (чтобы проверить конец слова после rp, и если не конец, то проверять метку). Если мы не в начале буфера, то тривиально. А в начале оставить копию конца прошлого буфера
       macro asmbackchar
        dec de
        ld a,(de)
       endm        
       macro asmback2chars
        dec de
        dec de
        ld a,(de)
       endm        


       macro asmputbyte_a
        ld (hl),a
        inc hl
       endm
       macro asmputbyte_c
        ld (hl),c
        inc hl
       endm
       macro asmputbyte_b
        ld (hl),b
        inc hl
       endm
       macro asmputbyte data
        ld (hl),data
        inc hl
       endm

