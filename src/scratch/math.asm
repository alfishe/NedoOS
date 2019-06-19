minhl_bc_tobc
        or a
        sbc hl,bc
        add hl,bc
        ret nc ;bc<=hl
        ld b,h
        ld c,l
        ret

div4signedup
        or a
        jp m,$+5
        add a,3
        sra a
        sra a
        ret

subhldecheck0
        xor a
        sbc hl,de
        ret nc
        ld h,a
        ld l,a
        ret

;bc * de результат в ahl
mulbcde_ahl
        xor a
        ld h,a
        ld l,a
        dup 8
        rlc b
        jr nc,$+5 ; c - был перенос, nc - не было переноса    
        add hl,de
        adc a,0
        add hl,hl
        rla
        edup
        dup 7
        rlc c
        jr nc,$+5 ; c - был перенос, nc - не было переноса    
        add hl,de
        adc a,0
        add hl,hl
        rla
        edup
        rlc c
        ret nc
        add hl,de
        adc a,0
        ret

genmuldewid_ahl
        ld de,(curbitmapwid_view)
        ld hl,muldewid_ahl+3
        ld a,d
        or e
        jr z,genmuldewid_ahlq ;иначе запорет начало процедуры
        xor a
        ld b,16
genmuldewid_ahl_0
        rl e
        rl d
        jr nc,genmuldewid_ahl_z
        inc a
        ld (hl),0x19 ;add hl,de
        inc hl
        ld (hl),0xce ;adc a,0
        inc hl
        ld (hl),0
        inc hl
genmuldewid_ahl_z
        or a
        jr z,genmuldewid_ahl_noadd
        ld (hl),0x29 ;add hl,hl
        inc hl
        ld (hl),0x17 ;rla
        inc hl
genmuldewid_ahl_noadd
        djnz genmuldewid_ahl_0
        dec hl
        dec hl
genmuldewid_ahlq
        ld (hl),0xc9 ;ret
        ret

;нельзя в pgshapes, т.к. нужно для bitmap        
muldewid_ahl
;не портит bc
        xor a
        ld h,a
        ld l,a
        ds (5*16)
;[add hl,de:adc a,0]
;add hl,hl:rla ;начать только с бита, который установлен, и в конце не ставить

divhldesigned
        ld a,h
        xor d
        push af
        xor d
        call m,neghl
        ld a,d
        or a
        call m,negde
        call divhlde
        pop af
        ret p ;одинаковые знаки
neghl
        xor a
        sub l
        ld l,a
        sbc a,h
        sub l
        ld h,a
        ret
negde
        xor a
        sub e
        ld e,a
        sbc a,d
        sub e
        ld d,a
        ret

;hl / de результат в hl
divhlde
	ld c,h
	ld a,l
	ld hl,0
	ld b,16
;don't mind carry
_DIV0.
;shift left hlca
	rla
	rl c
	adc hl,hl
;no carry
;try sub
	sbc hl,de
	jr nc,$+3
	add hl,de
;carry = inverted bit of result
	djnz _DIV0.
	rla
	cpl
	ld l,a
	ld a,c
	rla
	cpl
	ld h,a
        ret
