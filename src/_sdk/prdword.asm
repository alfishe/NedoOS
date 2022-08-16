prdword_dehl ;для печати на экран
;dehl=num
        ld bc,prdwordbuf
        push bc
        call prdword_dehl_tobc
        pop de
        ld hl,10
        jp sendchars

prdword_dehl_tobc ;для печати в буфер
;dehl=num
;bc=buf
        push de
        push hl
        exx
        pop iy
        pop hl ;hliy=num ;bc'=buf addr
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
        jp _prword_hliy

prword_hl_tobc ;для печати в буфер
;hl=num
;bc=buf
        push hl
        exx
        pop iy
        ld a,' '
        ld (prnumdwordcmd_zero_sym),a
        ld hl,0
        jr _prword_hliy ;hliy=num ;bc'=buf addr
prdword_skiphsw
        call prnumdwordcmd_azero
        call prnumdwordcmd_azero_a
        call prnumdwordcmd_azero_a
        call prnumdwordcmd_azero_a
        call prnumdwordcmd_azero_a
_prword_hliy ;hliy=num ;bc'=buf addr
        ld bc,+(-10000>>16)
        ld de,+(-10000&0xffff)
        call prdig32bit
        push iy
        pop hl
;hl=num
;bc'=buf addr
        ld bc,+(-1000&0xffff)
        call prdig16bit
        ld bc,+(-100&0xffff)
        call prdig16bit
        ld  c,+(-10&0xff)
        call prdig16bit
        ld a,l
        add a,'0'
        exx
        ld (bc),a
        inc bc
        ret
prdig16bit
;hl=num
;bc=-divisor
;bc'=buf addr
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
        ld (bc),a
        inc bc
        exx
        ld a,0x02 ;"ld (bc),a"
        ld (prnumdwordcmd_zero_ldbca),a ;все последующие нули видимые
        ld a,'0'
        ld (prnumdwordcmd_zero_sym),a ;все последующие нули печатаем не пробелом, а нулём
        ret
prnumdwordcmd_azero ;печать нуля
prnumdwordcmd_zero_sym=$+1
        ld a,' '
prnumdwordcmd_azero_a
        exx
prnumdwordcmd_zero_ldbca=$ ;0: для вывода размера файла (не портит содержимое буфера под незначащими нулями) ;0x02 "ld (bc),a": для вывода files, size
        ld (bc),a
        inc bc
        exx
        ret   
prdig32bit
;hliy=num
;bcde=-divisor
;bc'=buf addr
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
