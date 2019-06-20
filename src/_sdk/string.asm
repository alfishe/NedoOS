print_hl
	ld a,(hl)
	or a
	ret z
	push hl
	PRCHAR
	pop hl
	inc hl
	jr print_hl

print_nl
	ld a,0x0D
	PRCHAR
	ld a,0x0A
	PRCHAR
	ret 

printbyte_a
	ld de,strprintbuf
	call bytetostr_atode
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
	or a
	jr z,bytetostr_nodec
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

bytetohexstr_hltode
	ld a,(hl)
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
	inc hl
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
	jr c,str_digit_hltoa_err
	sub 10
	jr nc,str_digit_hltoa_err
	add 10
	ret
str_digit_hltoa_err
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
	dec a;ג א געמנאÿ צטפנא
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
	dec a; ג a ענועüÿ צטפנא
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


strprintbuf ds 6