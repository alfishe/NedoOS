TRUE=0xff
FALSE=0x00

_JPHL.
	EXPORT _JPHL.
	jp (hl)

;l << e
;out: l
_SHLB.
	EXPORT _SHLB.
;
        inc e
        dec e
        ret z
	ld b,e
	sla l
	djnz $-2
	ret

;hl << de
;out: hl
_SHL.
	EXPORT _SHL.
        inc e
        dec e
        ret z
	ld b,e
	add hl,hl
	djnz $-1
	ret

;hl, de << bc, ix
;out: hl(high), de(low)
_SHLLONG.
	EXPORT _SHLLONG.
	ld b,lx
        inc b
        dec b
        ret z
	ex de,hl
	add hl,hl
	rl e
	rl d
	djnz $-2-2-1
	ex de,hl
	ret

;l >> e
;out: l
_SHRB.
	EXPORT _SHRB.
        inc e
        dec e
        ret z
	ld b,e
	srl l
	djnz $-2
	ret
	;ld h,0

;hl >> de
;out: hl
_SHR.
	EXPORT _SHR.
        inc e
        dec e
        ret z
	ld b,e
	srl h
	rr l
	djnz $-2-2
	ret

;hl >> de
;out: hl
_SHRSIGNED.
	EXPORT _SHRSIGNED.
        inc e
        dec e
        ret z
	ld b,e
	sra h
	rr l
	djnz $-2-2
	ret

;hl, de >> bc, ix
;out: hl(high), de(low)
_SHRLONG.
	EXPORT _SHRLONG.
	ld b,lx
        inc b
        dec b
        ret z
	srl h
	rr l
	rr d
	rr e
	djnz $-2-2-2-2
	ret

;l * e
;out: l
_MULB.
	EXPORT _MULB.
	xor a
	ld b,8
_MULB0.
	add a,a
	rl l
	jr nc,$+3
	add a,e
	djnz _MULB0.
	ld l,a
	ret

;hl * de
;out: hl
_MULSIGNED.
	EXPORT _MULSIGNED.
;signed mul is equal to unsigned mul
	;bit 7,h
	;jr z,_MUL.
	;xor a
	;sub l
	;ld l,a
	;sbc a,h
	;sub l
	;ld h,a
	;call _MUL.
	;xor a
	;sub l
	;ld l,a
	;sbc a,h
	;sub l
	;ld h,a
	;ret

;hl * de
;out: hl
_MUL.
	EXPORT _MUL.
	ld a,h
	ld c,l
	ld hl,0
	ld b,16
_MUL0.
	add hl,hl
	rl c
	rla
	jr nc,$+3
	add hl,de
	djnz _MUL0.
	ret

;hl, de * bc, ix
;out: hl(high), de(low)
_MULLONG.
	EXPORT _MULLONG.
;signed mul is equal to unsigned mul
;hlde*bcix = hlde*b000 + hlde*c00 + hlde*i0 + hlde*x
	ld a,lx
	push af ;lx
	push ix ;hx
	ld a,c
	push af ;c
	ld a,b
;bcde <= hlde:
	ld b,h
	ld c,l
;hlix <= 0
	ld hl,0
	;ld ix,0
	push hl
	pop ix
	call _MULLONGP. ;hlix = (hlix<<8) + "b*hlde"
	pop af ;c
	call _MULLONGP. ;hlix = (hlix<<8) + "c*hlde"
	pop af ;hx
	call _MULLONGP. ;hlix = (hlix<<8) + "hx*hlde"
	pop af ;lx
	call _MULLONGP. ;hlix = (hlix<<8) + "lx*hlde"
	push ix
	pop de
	ret
;hlix = (hlix<<8) + a*bcde
_MULLONGP.
	exx
	ld b,8
_MULLONG0.
	exx
	add ix,ix
	adc hl,hl
	rla
	jr nc,$+2+2+2
	add ix,de
	adc hl,bc
	exx
	djnz _MULLONG0. ;можно по a==0 (первый вход с scf:rla, далее add a,a)
	exx
	ret

;l / e
;out: l
_DIVB.
	EXPORT _DIVB.
	ld h,0
	ld d,h
	;ret

;hl / de
;out: hl
_DIV.
	EXPORT _DIV.
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

;hl / de
;out: hl
_DIVSIGNED.
	EXPORT _DIVSIGNED.
	ld a,h
	xor d
	push af
	;bit 7,h
	;call nz,invhl.
	ld a,h
	rla
	call c,invhl.
	;jr z,$+2+6
	;xor a
	;sub l
	;ld l,a
	;sbc a,h
	;sub l
	;ld h,a
;hl>=0
	;bit 7,d
	;jr z,$+2+6
	ld a,d
	rla
	jr nc,$+2+6
	xor a
	sub e
	ld e,a
	sbc a,d
	sub e
	ld d,a
;de>=0
	call _DIV.
	pop af
	ret p;z
invhl.
	xor a
	sub l
	ld l,a
	sbc a,h
	sub l
	ld h,a
	ret

;hl, de / bc, ix
;out: hl(high), de(low)
_DIVLONG.
	EXPORT _DIVLONG.
;unsigned!!!
;hl'hl,de'de <= hlde,bcix:
	push bc
	exx
	pop de ;de' = "bc_in"
	ld hl,0
	exx
	ld a,e
	ex af,af' ;e_in
	push de ;d_in
	ld c,l ;l_in
	ld a,h ;h_in
	ld hl,0
	push ix
	pop de ;de = "ix_in"
	;a="h_in"
;hl'hla <= 0000h_in
	call _DIVLONGP. ;"h"
	ld b,c ;"l_in"
	ld c,a ;"h"
	ld a,b ;a="l_in"
;hl'hla <= 000hl_in
	call _DIVLONGP. ;"l"
	ld b,a ;"l"
	pop af ;a="d_in"
	push bc ;b="l"
;hl'hla <= 00hld_in
	call _DIVLONGP. ;"d"
	ex af,af' ;a="e_in", a'="d"
	;a="e_in"
;hl'hla <= 0hlde_in
	call _DIVLONGP. ;"e"
	ld e,a ;"e"
	ex af,af' ;"d"
	ld d,a
	pop hl ;h="l"
	ld l,h
	ld h,c ;"h"
	ret
;a = hl'hla/de'de
;c not used
_DIVLONGP.
;do 8 bits
	ld b,8
_DIVLONG0.
;shift left hl'hla
	rla
	adc hl,hl
	exx
	adc hl,hl
	exx
;no carry
;try sub
	sbc hl,de
	exx
	sbc hl,de
	exx
	jr nc,$+2+1+1+2+1
	add hl,de
	exx
	adc hl,de
	exx
;carry = inverted bit of result
	djnz _DIVLONG0.
	rla
	cpl
	ret
