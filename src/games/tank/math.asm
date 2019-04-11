;bc * de результат в hl
mulbcde
        ld hl,0
        ld a,b
        dup 8
        rla
        jr nc,$+3 ; c - был перенос, nc - не было переноса    
        add hl,de
        add hl,hl
        edup
        ld a,c
        dup 7
        rla
        jr nc,$+3 ; c - был перенос, nc - не было переноса    
        add hl,de
        add hl,hl
        edup
        rla
        ret nc;jr nc,$+3 ; 
        add hl,de
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

rnd
;0..c-1
        ld a,r
rnd0
        sub c
        jr nc,rnd0
        add a,c
        ret

