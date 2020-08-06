print_hl
	ld a,(hl)
	or a
	ret z
	push hl
	PRCHAR_
	pop hl
	inc hl
	jr print_hl

print_nl
	ld a,0x0D
	PRCHAR_
	ld a,0x0A
	PRCHAR_
	ret 

printbyte_a
	ld de,strprintbuf
	call bytetostr_atode
	ld hl,strprintbuf
	call print_hl
	ret

printushort_hl
	ld de,strprintbuf
	call ushorttostr_hltode
	ld hl,strprintbuf
	call print_hl
	ret

printhex_a
	ld de,strprintbuf
	call bytetohexstr_atode
	ld hl,strprintbuf
	call print_hl
	ret



skipword_hl
	ld a,(hl)
	or a
	ret z
	cp ' '
	ret z
	inc hl
	jr skipword_hl

skipspaces_hl
	ld a,(hl)
	cp ' '
	ret nz
	inc hl
	jr skipspaces_hl

strcopy_hltode
	ld a,(hl)
	ld (de),a
	or a
	ret z
	inc hl
	inc de
	jr strcopy_hltode

bytetostr_hltode
	ld a,(hl)
bytetostr_atode
	ld bc,0
bytetostr_hun
	sub 100
	jr c, bytetostr_dec
	inc b
	jr bytetostr_hun
bytetostr_dec
	add 100
bytetostr_dec0
	sub 10
	jr c, bytetostr_ed
	inc c
	jr bytetostr_dec0
bytetostr_ed
	add 10
	ex af,af'
	ld a,b
	or a
	jr z,bytetostr_nohun
	add 0x30
	ld (de),a
	inc de
bytetostr_nohun
	ld a,c
	or b
	jr z,bytetostr_nodec
	ld a,c
	add 0x30
	ld (de),a
	inc de
bytetostr_nodec
	ex af,af'
	add 0x30
	ld (de),a
	inc de
	xor a
	ld (de),a
	inc hl
	ret

ushorttostr_hltode
	push de
	ld ix,strbuf
	ld d,0x27 ;10000
	ld e,0x10
	xor a
ushorttostr_decth
	sbc hl,de
	jr c, ushorttostr_th
	inc a
	jr ushorttostr_decth
ushorttostr_th
	add hl,de
	ld (ix),a
	inc ix
	ld d,0x03 ;1000
	ld e,0xe8
	xor a
ushorttostr_th0
	sbc hl,de
	jr c, ushorttostr_hun
	inc a
	jr ushorttostr_th0
ushorttostr_hun
	add hl,de
	ld (ix),a
	inc ix
	ld d,0 ;100
	ld e,0x64 
	xor a
ushorttostr_hun0
	sbc hl,de
	jr c, ushorttostr_dec
	inc a
	jr ushorttostr_hun0
ushorttostr_dec
	add hl,de
	ld (ix),a
	inc ix
	ld e,0x0A ;10
	xor a
ushorttostr_dec0
	sbc hl,de
	jr c, ushorttostr_ed
	inc a
	jr ushorttostr_dec0
ushorttostr_ed
	add hl,de
	ld (ix),a
	inc ix
	ld a,l
	ld (ix),a
	inc ix
	ld a,0xFF
	ld (ix),a

	ld ix,strbuf-1
ushorttostr_res0
	inc ix
	ld a,(ix)
	or a
	jr z,ushorttostr_res0

	pop de
	ld a,(ix)
	cp 0xFF
	jr nz,ushorttostr_res1
	ld a,0x30
	ld (de),a
	inc de
	jr ushorttostr_ret
ushorttostr_res1
	ld a,(ix)
	cp 0xFF
	jr z,ushorttostr_ret
	add a,0x30
	ld (de),a
	inc de
	inc ix
	jr ushorttostr_res1
ushorttostr_ret
	xor a
	ld (de),a
	ret

bytetohexstr_atode
	ld b,a
	srl a
	srl a
	srl a
	srl a
	call bytetohexstr_putsymb
	ld a,b
	and 15
	call bytetohexstr_putsymb
	xor a
	ld (de),a
	ret
bytetohexstr_putsymb
	sub 10
	jr c,bytetohexstr_men16
	add 7
bytetohexstr_men16
	add 0x3A
	ld (de),a
	inc de
	ret

strtodigit_a ;a=FF - err
	sub 0x30
	jr c,str_digit_a_err
	sub 10
	jr nc,str_digit_a_err
	add 10
	ret
str_digit_a_err
	ld a,0xFF
	ret

strtobyte_hltode ; a=0 ok a=FF error
	ld a,(hl)
	call strtodigit_a
	inc a
	or a
	jr z,strtobyte_err

	dec a
	ld c,a
	inc hl
	ld a,(hl)
	call strtodigit_a
	inc a
	or a
	jr nz,strtobyte_2digit
	ld a,c
	ld (de),a
	xor a
	inc de
	ret

strtobyte_2digit
	inc hl
	dec a;в а вторая цифра
	ex af,af'
	ld a,c
	ld b,9
strtobyte_2digit0
	add c
	djnz strtobyte_2digit0
	ld c,a
	ex af,af'
	add c
	ld c,a

	ld a,(hl)
	call strtodigit_a
	inc a
	or a
	jr nz,strtobyte_3digit
	ld a,c
	ld (de),a
	xor a
	inc de
	ret
strtobyte_3digit
	inc hl
	dec a; в a третья цифра
	ex af,af'
	ld a,c
	ld b,9
strtobyte_3digit0
	add c
	jr c,strtobyte_err
	djnz strtobyte_3digit0
	ld c,a
	ex af,af'
	add c
	jr c,strtobyte_err
	ld (de),a
	xor a
	inc de
	ret
strtobyte_err
	ld a,0xFF
	ret

strtoushort_hltode; return a=0 ok a=ff - error
	ld bc,0
	ld de,strbuf
strtoushort_hltode0
	ld a,(hl)
	call strtodigit_a
	inc a
	jr z,strtoushort_hltode1
	dec a
	ld (de),a
	inc hl
	inc de
	inc b
	jr strtoushort_hltode0
strtoushort_hltode1
;в зависимости от b выбрать варианты
	ld a,b
	or a
	jr z,strtoushort_hltode_err

	push hl
	ld ix,strbuf
	ld de,0
	ld hl,0

strtoushort_hltode2
	ld d,h ; multiply by 10
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	add hl,hl
	push af
	ld a,(ix)
	ld d,0
	ld e,a
	add hl,de
	pop af
	inc ix
	dec a
	jr nz,strtoushort_hltode2

	ex hl,de
	pop hl
	ret
strtoushort_hltode_err
	ld a,0xFF
	ret

strischar_a
	sub 0x41
	jr c,strischar_no
	add 0x41
	sub 0x7b
	jr nc,strischar_no
	xor a
	ret
strischar_no
	ld a,0xFF
	or a
	ret

strisdigit_a
	sub 0x30
	jr c,strisdigit_no
	add 0x30
	sub 0x3A
	jr nc,strisdigit_no
	xor a
	ret
strisdigit_no
	ld a,0xFF
	or a
	ret

strprintbuf ds 6
strbuf ds 6