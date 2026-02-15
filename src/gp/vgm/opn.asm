	macro opn_write_music_only write_register
	ld a,e
	cp 0x30
	jp nc,write_register
	cp 0x0e
	jp c,write_register
;block both timers and the prescaler (the TFM prescaler is fairly unique)
	cp 0x28
	jp z,write_register
	endm

opnwritemusiconlyfm1
;skips writes to control registers
;e = register
;d = value
	opn_write_music_only opnwritefm1
	ret

opnwritemusiconlyfm2
;skips writes to control registers
;e = register
;d = value
	opn_write_music_only opnwritefm2
	ret

vgmopninit
.callturnturbooff
	call turnturbooff
	jp opninit

vgmopnmute
	call opnmute
	jp turnturboon

opnsettimer
;a = rate in hz
;output: zf=1 if timer is set, zf=0 otherwise
	cp 14
	ret c
	push af
	call settimerstep
	pop af
	ld de,0x07a1
	ld hl,0x2000
	exx
	ld c,a
	ld b,0
	cp 56
	jr c,.usetimerb
	ld de,2633
	call uintmul16
	exx
	call uintdiv32
	xor a
	sub l
	ld l,a
	sbc a,h
	sub l
	ld d,l
;high 8 bits
	rrca : rr d
	rrca : rr d
	ld e,0x24
	call opnwritefm1
;low 2 bits
	ld d,l
	inc e
	call opnwritefm1
	ld de,0x1527
	call opnwritefm1
	ld hl,opnwaittimera
	ld (waittimercallback),hl
	xor a
	ret
.usetimerb
	ld de,42130
	call uintmul16
	exx
	call uintdiv32
	xor a
	sub l
	ld d,a
	ld e,0x26
	call opnwritefm1
	ld de,0x2a27
	call opnwritefm1
	ld hl,opnwaittimerb
	ld (waittimercallback),hl
	xor a
	ret

opnwaittimera
	ld bc,OPN_REG
	ld a,%11111000
	out (c),a
	in a,(c)
	and 1
	jr z,$-4
	ld de,0x1527
	jp opnwritefm1

opnwaittimerb
	ld bc,OPN_REG
	ld a,%11111000
	out (c),a
	in a,(c)
	and 2
	jr z,$-4
	ld de,0x2a27
	jp opnwritefm1
