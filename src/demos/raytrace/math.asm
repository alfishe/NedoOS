	macro SQDELOOP
;+de*+de
        ld hl,0
        ld d,l;0
;полное умножение требует 16(15) проходов, а мы сделаем по частям в 8(7) проходов
;0de0 * 0de0 = de0*d + de*e = (d*d<<16) + (d*e<<9) + (e*e)
;(d*e<<9) -> hl0
        rlca ;"d"
        jr nc,$+4
        ld l,e ;"0e"
        add hl,hl
        dup 6
        rlca ;"d"
        jr nc,$+3
        add hl,de ;"0e"
        add hl,hl
        edup
;hl0 = (d*e<<9)
        
        if 1==0 ;don't use bc (невыгодно по сравнению с sqde:ld iy,de:...:sqde:add iy,de:...:sqde:add iy,de
        ex de,hl
        ld h,tsqr/256+1
        ld h,(hl) ;(e*e)
         ld l,a
         ld a,h
        ld h,tsqr/256
        ld h,(hl) ;(d*d<<16)
        ld l,a
        add hl,de
        ex de,hl
        else
        
         ld c,a
        ld d,tsqr/256+1
        ld a,(de) ;(e*e)
        add a,l
        ld e,a
        ld b,tsqr/256
        ld a,(bc) ;(d*d<<16)
        adc a,h
        ld d,a
        endif
;out: 0de0
	endm

	macro SQDE
        ld a,d
        rlca
        jr nc,$+2+3+3
         xor a
         sub e
         ld e,a
         sbc a,d
         sub e
         rlca ;"d"
        if SQUARESQR
        scf
        rra
        ld d,a
        res 0,e
        ex de,hl
        ld e,(hl)
        inc l
        ld d,(hl)
	ld a,l
	cp 8 ;костыль для младшего бита
        rl e;sla e
        rl d
        ;ld a,(hl)
        ;inc l
        ;ld h,(hl)
        ;ld l,a
        ;add hl,hl ;выигрыш 1 байт по сравнению с оптимизированным
        ;ex de,hl
        else
         
	SQDELOOP
	endif
	endm
	
	macro SQHL
        ld a,h
        rlca
        jr nc,$+2+3+3
         xor a
         sub l
         ld l,a
         sbc a,h
         sub l
         rlca ;"h"
        if SQUARESQR
        scf
        rra
        ld h,a
        res 0,l
        ;ex de,hl
        ld e,(hl)
        inc l
        ld d,(hl)
	;ld a,l
	;cp 8 ;костыль для младшего бита
        rl e;sla e
        rl d
        ;ld a,(hl)
        ;inc l
        ;ld h,(hl)
        ;ld l,a
        ;add hl,hl ;выигрыш 1 байт по сравнению с оптимизированным
        ;ex de,hl
        else
         
	ex de,hl
	SQDE
	endif
	endm
	
        macro DIVLOOP
;(keep bc)
;hla = "0de"
;a = hla/bc0
;do 7 bits
;shift left hla, try sub, keep carry (inverted bit of result)
	rla;add a,a
	adc hl,hl ;no carry ;rl l нельзя
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
        dup 7
	adc hl,hl ;no carry
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
        edup
        cpl
        ld d,a ;"res_l"
;hl = "de"
;a = hla/bc0
;do 7 bits
;shift left hla, try sub, keep carry (inverted bit of result)
        dup 7
	add hl,hl ;no carry
	sbc hl,bc
	jr nc,$+3
	add hl,bc
	rla
        edup

	add hl,hl ;no carry
	sbc hl,bc
	;jr nc,$+3
	;add hl,bc
        rla
        cpl
	ld e,a
;out: de
        endm

        macro DIVDEBC_POSITIVE
;(keep bc)
        ld h,0
        ld l,d
        ld a,e
;hla = "0de"
        DIVLOOP
;out: de
        endm

        macro DIVDEBC_AXSIGN_NONEGBC
;(keep bc)
        ld a,d
        rla
        jr nc,$+2+6;idivnonegde
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
;idivnonegde
;out: de
;idiv_0de0_00bc
        DIVDEBC_POSITIVE
        ex af,af' ;M=разные знаки ;'
        jp p,$+3+6;ret p
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
        ;ret
        endm

        macro DIVDEBC_ASIGN
        ex af,af' ;M=разные знаки ;'
        ld a,b
        rla
        jr nc,$+2+6;idivnonegbc
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ld b,a
;idivnonegbc
        DIVDEBC_AXSIGN_NONEGBC
        endm

        macro ROOTHL
        if 1==1
    xor a
    ld b,a

    ld e,l
    ld l,h
    ld h,a

    sla l;add hl,hl
    sla l;add hl,hl
    ;cp h
    ;jr nc,$+5
    ;dec h
    ;ld a,4

    add hl,hl
    add hl,hl
    ld c,a
    sub h
    jr nc,$+6
    cpl
    ld h,a
    inc c
    inc c

    ld a,c
    add hl,hl
    add hl,hl
    add a,a
    ld c,a
    sub h
    jr nc,$+6
    cpl
    ld h,a
    inc c
    inc c

    ld a,c
    add hl,hl
    add hl,hl
    add a,a
    ld c,a
    sub h
    jr nc,$+6
    cpl
    ld h,a
    inc c
    inc c

    ld a,c
    ld l,e

    add hl,hl
    add hl,hl
    add a,a
    ld c,a
    sub h
    jr nc,$+6
    cpl
    ld h,a
    inc c
    inc c

    ld a,c
    add hl,hl
    add hl,hl
    add a,a
    ld c,a
    sub h
    jr nc,$+6
    cpl
    ld h,a
    inc c
    inc c

    ld a,c
    add a,a
    ld c,a
    add hl,hl
    add hl,hl
    jr nc,$+6
    sub h
    jp $+6
    sub h
    jr nc,$+6
    inc c
    inc c
    cpl
    ld h,a

     ld e,1
     
    ld a,l
    ld l,h
    add a,a
    ld h,a
    adc hl,hl
    adc hl,hl
    sll c 
    rl b
    sbc hl,bc
    jr nc,$+3
    add hl,bc
    sbc a,a 
    ;add a,a 
    ;inc a 
     or e;1
    add a,c 
    ld c,a

;iteration 9
    add hl,hl 
    add hl,hl
    sll c 
    rl b
    sbc hl,bc
    jr nc,$+3
    add hl,bc
    sbc a,a 
    ;add a,a 
    ;inc a 
     or e;1
    add a,c 
    ld c,a

    add hl,hl 
    add hl,hl
    sll c 
    rl b
    sbc hl,bc
    jr nc,$+3
    add hl,bc
    sbc a,a 
    ;add a,a 
    ;inc a 
     or e;1
    add a,c 
    ld c,a

    add hl,hl 
    add hl,hl
    sll c 
    rl b
    sbc hl,bc
    jr nc,$+3
    add hl,bc
    sbc a,a ;0/-1
    ;add a,a ;0/-2
    ;inc a ;+1/-1
     or e;1
    add a,c 
    ;ld c,a

    ;add hl,hl 
    ;add hl,hl
    ;sll c 
    ;rl b
    ;sbc hl,bc
    ;jr nc,$+3
    ;add hl,bc
    ;sbc a,a 
    ;add a,a 
    ;inc a 
    ;add a,c 
    ;ld c,a
;12th iteration completed
; output in BC
    ;srl b 
    ;rr c
    ld h,b
    ld l,a;c
        
        else
        
;root0hl0
        or a ;NC
        ld bc,64 ;c=64 (const), eb будет результат
        ld a,l
        ld l,h
        ld h,b;0
        ld e,b;0
        
;0hla=00NN
        dup 4
        sbc hl,bc
        jr nc,$+3
        add hl,bc
        ccf
        rl b
        rla
        adc hl,hl
        rla
        adc hl,hl
        edup
        
;ahl0=0??0
        sbc hl,bc
        jr nc,$+3
        add hl,bc
        ccf
        rl b
        rl e
        add hl,hl
        rla
        add hl,hl
        rla
        dup 3
        sbc hl,bc
        sbc a,e
        jr nc,$+4
        add hl,bc
        adc a,e
        ccf
        rl b
        rl e
        add hl,hl
        rla
        add hl,hl
        rla
        edup
        
;ahl0=???0
        dup 3
        sbc hl,bc
        sbc a,e
        jr nc,$+4
        add hl,bc
        adc a,e
        ccf
        rl b
        rl e
        add hl,hl
        rla
        add hl,hl
        rla
        edup
        sbc hl,bc
        sbc a,e
        jr nc,$+4
        add hl,bc
        adc a,e
        ccf
        ;rl b
        ;rl e
;eb=результат q=[sqrt N]
        ld l,b
        ld h,e
        adc hl,hl
;out: hl ;NC
        endif
        endm

        macro MULDEBCLOOP
;0de * 0bc = (de * b)<<8 + (de * c) => ah
;a=b<<1
;keep de! (можно портить биты 0,15)
        if SQUAREMUL
;d.e * b.c = 0.5*(d.e+b.c)^2 - 0.5*d.e^2 - 0.5*b.c^2
        rra
        ld b,a
        res 0,c
        ;set 7,d
        ;res 0,e

;адрес в таблице: %1hhhhhhh.lllllll0
        if 1==1
        ld h,d
        ld l,e
        add hl,bc ;d.e+b.c
        ;ld ($+4),hl
        ;ld hl,(0)
        ;set 7,b
        ;ld ($+6),bc
        ;ld bc,(0)
        ;sbc hl,bc
        ;ld ($+6),de
        ;ld bc,(0)
        ;sbc hl,bc
         set 7,b
         ex de,hl
         ld a,(bc)
         inc c
         add a,(hl)
         inc l
         ld lx,a
         ld a,(bc)
         adc a,(hl)
         ld b,a ;0.5*d.e^2 + 0.5*b.c^2
         ex de,hl
        ld a,(hl) ;0.5*(d.e+b.c)^2
        sub lx
        inc l
         ld c,a
        ld a,(hl)
        sbc a,b
         ;ld h,c
         ;add hl,hl ;11t = 1 s
;out: ah = 0.5*(d.e+b.c)^2 - 0.5*d.e^2 - 0.5*b.c^2
        else
        
        ld h,d
        ld l,e
        add hl,bc ;d.e+b.c
        ex de,hl
        ld a,(de) ;0.5*(d.e+b.c)^2
        inc e
        sub (hl) ;0.5*d.e^2
        inc l
         ld lx,a
        ld a,(de)
        sbc a,(hl)
         ld hx,a
        ex de,hl
        ;ix = 0.5*(d.e+b.c)^2 - 0.5*d.e^2
        ld h,b
        ld l,c
        set 7,h
        ld a,lx
        sub (hl)
        inc l
         ld c,a
        ld a,hx
        sbc a,(hl)
         ;ld h,c
;out: ac = 0.5*(d.e+b.c)^2 - 0.5*d.e^2 - 0.5*b.c^2
        endif
         
        else
;hl=0
        add a,a
        add a,a
        add a,a
        jr nc,$+5;4
         ld h,d
         ld l,e
         add hl,hl
        add a,a
        jr nc,$+3
        add hl,de
        dup 3;4
        add hl,hl
        add a,a
        jr nc,$+3
        add hl,de
        edup
        ld b,h ;b = hsb(de * b)
        ld h,a;0 ;l = lsb(de * b)
;c*de => ahl
         ld a,c
         ld c,h;0
        dup 7
        add hl,hl
        rla
        jr nc,$+4
        add hl,de
        adc a,c;0
        edup
        add hl,hl
        rla
        jr nc,$+3;4
        add hl,de
        ;adc a,c;0
;ahl = (de * c) + lsb(de * b)<<8
        adc a,b ;b = hsb(de * b)
        endif
;out: ah
        endm

        macro MULDEBC_SIGNED
;+de0 * +bc0 -> .de.
        ld a,d
        xor b
        ex af,af' ;M=разные знаки '
        ld a,d
        rla
        jr nc,$+2+6;mul_noneghld0
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
;mul_noneghld0
        ld a,b
        add a,a
        jr nc,$+2+6;mul_nonegbcx0
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ;ld b,a
        add a,a
;mul_nonegbcx0
        if SQUAREMUL
        set 7,d
        res 0,e
        else
        ld hl,0
        endif
;0de * 0bc = (de * b)<<8 + (de * c) => de
;a=b<<1
         ;ld a,b
         ;add a,a
        MULDEBCLOOP
        if SQUAREMUL
         ld e,c
        else
         ld e,h
        endif 
         ld d,a
;out: de
        ex af,af' ;M=разные знаки '
        jp p,$+3+6;ret p
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
        endm

        macro MULDEBC
        if fastest
        MULDEBC_SIGNED
        else
        call muldebc
        endif
        endm

        macro MULDEBC_TOIY
        if 1==0
        MULDEBC
        ld hy,d
        ld ly,e
        else
;+de0 * +bc0 -> .iy.
        ld a,d
        xor b
        ex af,af' ;M=разные знаки '
        ld a,d
        rla
        jr nc,$+2+6;mul_noneghld0
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
;mul_noneghld0
        ld a,b
        add a,a
        jr nc,$+2+6;mul_nonegbcx0
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ;ld b,a
        add a,a
;mul_nonegbcx0
        if SQUAREMUL
        set 7,d
        res 0,e
        else
        ld hl,0
        endif
;0de * 0bc = (de * b)<<8 + (de * c)
;b*de => hl
         ;ld a,b
         ;add a,a
        MULDEBCLOOP
        if SQUAREMUL
         ld b,a;hy,a
;out: iy
        ex af,af' ;M=разные знаки '
        jp p,$+3+6;8;ret p
        xor a
        sub c
        ld c,a
        sbc a,b;hy
        sub c
        ld b,a;hy,a
	ld hy,b
        ld ly,c
        else
         ld e,h
         ld hy,a
;out: iy
        ex af,af' ;M=разные знаки '
        jp p,$+3+8;ret p
        xor a
        sub e
        ld e,a
        sbc a,hy
        sub e
        ld hy,a
        ld ly,e
        endif
        endif
        endm

        macro MULDEBC_POSITIVE
        if SQUAREMUL
        set 7,d
        res 0,e
        else
        ld hl,0
        endif
;0de * 0bc = (de * b)<<8 + (de * c)
;b*de => hl
        ld a,b
        add a,a
        MULDEBCLOOP
        if SQUAREMUL
         ld e,c
        else
         ld e,h
        endif
         ld d,a
;out: de
        endm

        macro MULDEBC_TOHL_POSITIVE
        if SQUAREMUL
        set 7,d
        res 0,e
        else
        ld hl,0
        endif
;0de * 0bc = (de * b)<<8 + (de * c)
;b*de => hl
        ld a,b
        add a,a
        MULDEBCLOOP
        if SQUAREMUL
         ld l,c
        else
         ld l,h
        endif
         ld h,a
;out: hl
        endm

        macro MULDEBC_TOHL_DEPOSITIVE
        if SQUAREMUL
        set 7,d
        res 0,e
        endif
;+de0 * +bc0 -> .hl. (keeps de)
        xor a
        if !SQUAREMUL
        ld l,a
        ld h,a
        endif
        xor b
        ex af,af' ;M=разные знаки '
        ld a,b
        add a,a
        jr nc,$+2+6;mul_nonegbcx0
        xor a
        sub c
        ld c,a
        sbc a,b
        sub c
        ;ld b,a
        add a,a
;mul_nonegbcx0
;0de * 0bc = (de * b)<<8 + (de * c)
;b*de => hl
         ;ld a,b
         ;add a,a
        MULDEBCLOOP
        if SQUAREMUL
         ld l,c
        else
         ld l,h
        endif
         ld h,a
;out: HL
        ex af,af' ;M=разные знаки '
        jp p,$+3+6;ret p
        xor a
        sub l
        ld l,a
        sbc a,h
        sub l
        ld h,a
        endm
