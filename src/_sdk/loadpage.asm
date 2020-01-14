;TODO переделать на handle
cmd_loadpage
;a=loadaddr/256
;out: a=error, bc=bytes read
;keeps hl,de
        push de
        push hl
        ld d,a
        ld e,0
        neg
        add a,a
        ld b,a
        push bc
        OS_SETDTA
        pop bc
        ld hl,0
cmd_loadpage0      
        push bc
        push hl
        ld de,fcb
        OS_FREAD
        pop hl
        xor 128
        ld c,a
        ld b,0
        add hl,bc
        pop bc
        xor 128
        jr nz,cmd_loadpageq ;not full block loaded - end of file
        djnz cmd_loadpage0
cmd_loadpageq
        ld b,h
        ld c,l
        pop hl
        pop de
        ret
