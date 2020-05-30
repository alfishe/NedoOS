;font48 = 256 aligned vertical 2K

        SHAPESPROC shapes_prtext_num
;печатает на экране hl текст (de), потом число bc, переводит адрес экрана на 8 строк вниз, de на следующий текст (после терминатора)
        push hl
        push bc
        call shapes_prtext48ega_oncolor
        ex de,hl
        ex (sp),hl
        call shapes_prnum
        pop de
        inc de ;пропускаем терминатор строки
        pop hl
        ld bc,40*8
        add hl,bc ;next screen chr line
        ret

        SHAPESPROC shapes_prnumdword        
;de=scr
;hl'hl=num
        ld a,' '
        ld (prnumdword_zero),a
        exx
        ld bc,1000000000/65536
        exx
        ld bc,1000000000&0xffff
        call prnumdword0
        exx
        ld bc,100000000/65536
        exx
        ld bc,100000000&0xffff
        call prnumdword0
        exx
        ld bc,10000000/65536
        exx
        ld bc,10000000&0xffff
        call prnumdword0
        exx
        ld bc,1000000/65536
        exx
        ld bc,1000000&0xffff
        call prnumdword0
        exx
        ld bc,100000/65536
        exx
        ld bc,100000&0xffff
        call prnumdword0
        exx
        ld bc,0
        exx
        ld bc,10000
        call prnumdword0
        ld bc,1000
        call prnumdword0
        ld bc,100
        call prnumdword0
        ld bc,10
        call prnumdword0
        ld a,'0'
        ld (prnumdword_zero),a
        ld bc,1
prnumdword0
;bc=digit
        ld a,'0'-1
prnumdword1
        inc a
        or a
        sbc hl,bc
        exx
        sbc hl,bc
        exx
        jr nc,prnumdword1
        add hl,bc
        exx
        adc hl,bc
        exx
        ex de,hl
        cp '0'
        jr nz,prnumdword_nozero
prnumdword_zero=$+1
        ld a,' '
        jr prnumdword_nozeroq
prnumdword_nozero
        push af
        ld a,'0'
        ld (prnumdword_zero),a
        pop af
prnumdword_nozeroq
        call shapes_prchar48ega
        ex de,hl
        ret        

        SHAPESPROC shapes_prtext48ega_black
;lx=color %33210210
;hl=scr
;de=text
        ld bc,prchar48ega_black
        jr prtext48egago
        SHAPESPROC shapes_prtext48ega_oncolor
;lx=color %33210210
;hl=scr
;de=text
        ld bc,prchar48ega_whiteoncolor
        jr prtext48egago
        SHAPESPROC shapes_prtext48ega_white7oncolor
;lx=color %33210210
;hl=scr
;de=text
        ld bc,prchar48ega_white7oncolor
        jr prtext48egago
        SHAPESPROC shapes_prtext48ega
;hl=scr
;de=text
        ld bc,prchar48ega_white
prtext48egago
        ld (prchar48ega_colorproc),bc
prtext48ega0
        ld a,(de)
        or a
        ret z
        call shapes_prchar48ega
        inc de
        jp prtext48ega0
        
        SHAPESPROC shapes_prchar48ega
;a=char
;hl=scr
        push de
        ld e,a
        ld d,font48/256
        push hl
        ld b,+((40-0x4000)&0xff00)/256
        ld hx,8
prchar48ega_colorproc=$+1
        call prchar48ega_white
        pop hl
        pop de
        ld a,h
        xor 0x20
        ld h,a
        and 0x20
        ret nz
        inc hl
        ret

        SHAPESPROC shapes_prnum
;de=scr
;hl=num
        ld bc,prchar48ega_whiteoncolor
        ld (prchar48ega_colorproc),bc
        ld bc,1000
        call prdig
        ld bc,100
        call prdig
        ld bc,10
        call prdig
        ld bc,1
prdig
;bc=digit
        ld a,'0'-1
prdig0
        inc a
        or a
        sbc hl,bc
        jr nc,prdig0
        add hl,bc
        ;ld a,(hl)
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        ret
        
        
        SHAPESPROC shapes_prNN
;de=scr
;hl=num =a
        ld h,0
        ld l,a
        ld bc,prchar48ega_whiteoncolor
        ld (prchar48ega_colorproc),bc
        ld bc,10
        call prdigNN
        ld bc,1
prdigNN
;bc=digit
        ld a,'0'-1
prdigNN0
        inc a
        or a
        sbc hl,bc
        jr nc,prdigNN0
        add hl,bc
        ;ld a,(hl)
        ex de,hl
        call shapes_prchar48ega
        ex de,hl
        ret
        
        SHAPESPROC shapes_prNchars
;hl=scr
;de=text
;a=Nchars
        ld bc,prchar48ega_whiteoncolor
        ld (prchar48ega_colorproc),bc
        ld b,a
prNchars0
        push bc
        ld a,(de)
        inc de
        call shapes_prchar48ega
        pop bc
        djnz prNchars0
        ret
        
        SHAPESPROC shapes_prhexbyte
;ld a,0x30;a=0x30 - 0,1,2..9 0x41 - A,B,C,D,E,F 0x61 - a,b,c..
;a=XX 
;lx=color %33210210
;hl=scr
        push hl
        ld hl,prchar48ega_white7oncolor
        ld (prchar48ega_colorproc),hl
        pop hl
        ;push hl
        ;push af
        rrca
        rrca
        rrca
        rrca
        call pronehexdigit
        rlca
        rlca
        rlca
        rlca
        ;call pronehexdigit
        ;pop af
        ;pop hl
        ;ret
pronehexdigit
;a=?X
        push bc
        push af
        and 0xf
        cp 10
        jr c,prcharbit_noletter
        add a,'a'-('0'+10)
prcharbit_noletter
        add a,'0'
        call shapes_prchar48ega
        pop af
        pop bc
        ret
        
        
prchar48ega_black
prchar48ega_black0
        ld a,(de)
        ld c,a
        ld a,(hl)
        rl c
        jr nc,$+4
        and 0xb8;%10111000
        rl c
        jr nc,$+4
        and 0x47;%01000111
        ld (hl),a
        set 6,h
        ld a,(hl)
        rl c
        jr nc,$+4
        and 0xb8;%10111000
        rl c
        jr nc,$+4
        and 0x47;%01000111
        ld (hl),a
        inc d
        ld c,+(40-0x4000)&0xff
        add hl,bc
        dec hx
        jp nz,prchar48ega_black0
        ret
        
prchar48ega_white
prchar48ega_white0
        ld a,(de)
        ld c,a
        ld a,(hl)
        rl c
        jr nc,$+4
        or 0x47;%01000111
        rl c
        jr nc,$+4
        or 0xb8;%10111000
        ld (hl),a
        set 6,h
        ld a,(hl)
        rl c
        jr nc,$+4
        or 0x47;%01000111
        rl c
        jr nc,$+4
        or 0xb8;%10111000
        ld (hl),a
        inc d
        ld c,+(40-0x4000)&0xff
        add hl,bc
        dec hx
        jp nz,prchar48ega_white0
        ret

prchar48ega_whiteoncolor
;lx=color %33210210
prchar48ega_whiteoncolor0
        ld a,(de)
        ld c,a
        ld a,lx
        rl c
        jr nc,$+4
        or 0x47;%01000111
        rl c
        jr nc,$+4
        or 0xb8;%10111000
        ld (hl),a
        set 6,h
        ld a,lx
        rl c
        jr nc,$+4
        or 0x47;%01000111
        rl c
        jr nc,$+4
        or 0xb8;%10111000
        ld (hl),a
        inc d
        ld c,+(40-0x4000)&0xff
        add hl,bc
        dec hx
        jp nz,prchar48ega_whiteoncolor0
        ret

prchar48ega_white7oncolor
;lx=color %33210210
prchar48ega_white7oncolor0
        ld a,(de)
        ld c,a
        ld a,lx
        rl c
        jr nc,$+4
        or 0x07;%00000111
        rl c
        jr nc,$+4
        or 0x38;%00111000
        ld (hl),a
        set 6,h
        ld a,lx
        rl c
        jr nc,$+4
        or 0x07;%00000111
        rl c
        jr nc,$+4
        or 0x38;%00111000
        ld (hl),a
        inc d
        ld c,+(40-0x4000)&0xff
        add hl,bc
        dec hx
        jp nz,prchar48ega_white7oncolor0
        ret
