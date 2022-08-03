prdword ;для печати на экран
;hl'hl=num
        ld de,prdwordbuf
        push de
        call prdword_de
        pop de
        ld hl,10
        jp sendchars

prdword_de
;hl'hl=num
;de=buf
        push hl
        pop iy
        exx
;hliy=num
;de'=buf addr
        ld a,' '
        ld (prnumdwordcmd_zero_sym),a
        ld a,h
        or l
        jr z,prdword_skiphsw
        ld bc,+(-1000000000>>16)
        ld de,+(-1000000000&0xffff)
        call prdig32bit
        ld bc,+(-100000000>>16)
        ld de,+(-100000000&0xffff)
        call prdig32bit
        ld bc,+(-10000000>>16)
        ld de,+(-10000000&0xffff)
        call prdig32bit
        ld  c,+(-1000000>>16)
        ld de,+(-1000000&0xffff)
        call prdig32bit
        ld  c,+(-100000>>16)
        ld de,+(-100000&0xffff)
        call prdig32bit
        jp prword_hliy
prdword_skiphsw
        call prnumdwordcmd_azero
        call prnumdwordcmd_azero_a
        call prnumdwordcmd_azero_a
        call prnumdwordcmd_azero_a
        call prnumdwordcmd_azero_a
prword_hliy
;hliy=num
;de'=buf addr
        ld bc,+(-10000>>16)
        ld de,+(-10000&0xffff)
        call prdig32bit
        push iy
        pop hl
;hl=num
;de'=buf addr
        ld bc,+(-1000&0xffff)
        call prdig16bit
        ld bc,+(-100&0xffff)
        call prdig16bit
        ld  c,+(-10&0xff)
        call prdig16bit
        ld a,l
        add a,'0'
        exx
        ld (de),a
        inc de
        ret
prdig16bit
;hl=num
;bc=-divisor
;de'=screen addr
        ld a,'0'-1
prdig16bit0
        inc a
       add hl,bc
        jp c,prdig16bit0
       sbc hl,bc
prdword_digok
        cp '0'
        jr z,prnumdwordcmd_azero
        exx
        ld (de),a
        inc de
        exx
        ld a,0x12 ;"ld (de),a"
        ld (prnumdwordcmd_zero_lddea),a ;все последующие нули видимые
        ld a,'0'
        ld (prnumdwordcmd_zero_sym),a ;все последующие нули печатаем не пробелом, а нулём
        ret
prnumdwordcmd_azero ;печать нуля
prnumdwordcmd_zero_sym=$+1
        ld a,' '
prnumdwordcmd_azero_a
        exx
prnumdwordcmd_zero_lddea=$ ;0: для вывода размера файла (не портит содержимое буфера под незначащими нулями) ;0x12 "ld (de),a": для вывода files, size
        ld (de),a
        inc de
        exx
        ret   
prdig32bit
;hliy=num
;bcde=-divisor
;de'=buf addr
        ld a,'0'-1
prdig32bit0
        inc a
       add iy,de
       adc hl,bc
        jp c,prdig32bit0
       ex af,af' ;'
       ld a,ly
       sub e
       ld ly,a
       ld a,hy
       sbc a,d
       ld hy,a
       sbc hl,bc
       ex af,af' ;'
        jp prdword_digok

prdwordbuf
        db "1234567890"
