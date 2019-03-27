prword
;hl=num
        exx
        ld hl,0
        exx
prdword
;hl'hl=num
        ld a,' '
        ld (prnumdwordcmd_zero),a
        exx
        ld bc,1000000000/65536
        exx
        ld bc,1000000000&#ffff
        call prnumdwordcmd0
        exx
        ld bc,100000000/65536
        exx
        ld bc,100000000&#ffff
        call prnumdwordcmd0
        exx
        ld bc,10000000/65536
        exx
        ld bc,10000000&#ffff
        call prnumdwordcmd0
        exx
        ld bc,1000000/65536
        exx
        ld bc,1000000&#ffff
        call prnumdwordcmd0
        exx
        ld bc,100000/65536
        exx
        ld bc,100000&#ffff
        call prnumdwordcmd0
        exx
        ld bc,0
        exx
        ld bc,10000
        call prnumdwordcmd0
        ld bc,1000
        call prnumdwordcmd0
        ld bc,100
        call prnumdwordcmd0
        ld bc,10
        call prnumdwordcmd0
        ld a,'0'
        ld (prnumdwordcmd_zero),a
        ld bc,1
prnumdwordcmd0
;bc=digit
        ld a,'0'-1
prnumdwordcmd1
        inc a
        or a
        sbc hl,bc
        exx
        sbc hl,bc
        exx
        jr nc,prnumdwordcmd1
        add hl,bc
        exx
        adc hl,bc
        exx
        push bc
        push de
        push hl
        cp '0'
        jr nz,prnumdwordcmd_nozero
prnumdwordcmd_zero=$+1
        ld a,' '
        jr prnumdwordcmd_nozeroq
prnumdwordcmd_nozero
        ld hl,prnumdwordcmd_zero
        ld (hl),'0'
prnumdwordcmd_nozeroq
        exx
        push bc
        push hl
        PRCHAR
        pop hl
        pop bc
        exx
        pop hl
        pop de
        pop bc
        ret   
