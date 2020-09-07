prword
;hl=num
        exx
        ld hl,0
        exx
prdword
;hl'hl=num
        ld de,prdwordbuf
        push de
        call prdword_de_withspaces
        pop hl
        ld de,10
        jp cmdprNchars
prdword_de_withspaces
        ld a,0x12 ;"ld (de),a"
        jr prdword_de_a
prdword_de
;hl'hl=num
;de=buf
        xor a
prdword_de_a
        ld (prnumdwordcmd_zero_lddea),a
        ld a,' '
        ld (prnumdwordcmd_zero_sym),a
        exx
        ld a,h
        or l
        jr z,prdword_skiphsw
        ld bc,1000000000/65536
        exx
        ld bc,1000000000&0xffff
        call prnumdwordcmdbcbc0
        exx
        ld bc,100000000/65536
        exx
        ld bc,100000000&0xffff
        call prnumdwordcmdbcbc0
        exx
        ld bc,10000000/65536
        exx
        ld bc,10000000&0xffff
        call prnumdwordcmdbcbc0
        exx
        ld bc,1000000/65536
        exx
        ld bc,1000000&0xffff
        call prnumdwordcmdbcbc0
        exx
        ld bc,100000/65536
        exx
        ld bc,100000&0xffff
        call prnumdwordcmdbcbc0
        jp prdword_skiphswq
prdword_skiphsw
        exx
        call prnumdwordcmd_azero
        call prnumdwordcmd_azero
        call prnumdwordcmd_azero
        call prnumdwordcmd_azero
        call prnumdwordcmd_azero
prdword_skiphswq
        exx
        ld bc,0
        exx
        ld bc,10000
        call prnumdwordcmdbcbc0
        ld bc,1000
        call prnumdwordcmd0
        ld bc,100
        call prnumdwordcmd0
        ld  c,10
        call prnumdwordcmd0
        ld a,l
        add a,'0'
        ld (de),a
        inc de
        ret
        ;ld a,0x12 ;"ld (de),a"
        ;ld (prnumdwordcmd_zero_lddea),a
        ;ld bc,1
prnumdwordcmd0
;bc=digit weight
        ld a,'0'-1
        or a
prnumdwordcmd1
        inc a
        sbc hl,bc
        jp nc,prnumdwordcmd1
        add hl,bc
prnumdwordcmd_digok
        cp '0'
        jr z,prnumdwordcmd_azero
        ld (de),a
        inc de
        ld a,0x12 ;"ld (de),a"
        ld (prnumdwordcmd_zero_lddea),a
        ld a,'0'
        ld (prnumdwordcmd_zero_sym),a
        ret
prnumdwordcmd_azero
prnumdwordcmd_zero_sym=$+1
        ld a,' '
prnumdwordcmd_zero_lddea=$
        ld (de),a
        inc de
        ret   
prnumdwordcmdbcbc0
;bc'bc=digit weight
        ld a,'0'-1
        or a
prnumdwordcmdbcbc1
        inc a
        sbc hl,bc
        exx
        sbc hl,bc
        exx
        jp nc,prnumdwordcmdbcbc1
        add hl,bc
        exx
        adc hl,bc
        exx
        jp prnumdwordcmd_digok

prdwordbuf
        db "1234567890"