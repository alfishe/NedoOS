OPN_REG = 0xfffd
OPN_DAT = 0xbffd

	macro opn_write_fm_reg chip_n
;e = register
;d = value
	ld bc,OPN_REG
	ld a,chip_n+%11111000
	out (c),a
	in a,(c)
	rlca
	jr c,$-3
	out (c),e
	in a,(c)
	rlca
	jr c,$-3
	ld bc,OPN_DAT
	out (c),d
	endm

opnwritemusiconlyfm1
;skips writes to control registers
;e = register
;d = value
	ld a,e
	cp 0x2d ;prescaler
	ret z
	cp 0x2e ;prescaler
	ret z
	cp 0x2f ;prescaler
	ret z
	cp 0x27 ;timers control
	jr nz,opnwritefm1
	ld a,d
	ld (opntimerctrl),a
	or %00001010 ;avoid altering timer B
	ld d,a
opnwritefm1
;e = register
;d = value
	opn_write_fm_reg 0
	ret

opnwritemusiconlyfm2
;skips writes to control registers
;e = register
;d = value
	ld a,e
	cp 0x2d ;prescaler
	ret z
	cp 0x2e ;prescaler
	ret z
	cp 0x2f ;prescaler
	ret z
opnwritefm2
;e = register
;d = value
	opn_write_fm_reg 1
	ret

	macro opn_write_fm_regs incr,incd
;e = base register
;d = value
;l = count
.loop
	call opnwritefm1
	call opnwritefm2
	IF incr
	inc e
	ENDIF
	IF incd
	inc d
	ENDIF
	dec l
	jr nz,.loop
	endm

opninit
	ld l,0xb4
	ld de,0x0000
	opn_write_fm_regs 1,0
	ld de,0x002f
	call opnwritefm1
	call opnwritefm2
	ld de,0x002d
	call opnwritefm1
	jp opnwritefm2

opnmute
	ld l,3
	ld de,0x0008
	opn_write_fm_regs 1,0 ;mute SSG
	ld l,14
	ld de,0x0000
	opn_write_fm_regs 1,0
	ld l,0x10
	ld de,0x0f80
	opn_write_fm_regs 1,0 ;max release rate
	ld l,0x10
	ld de,0x7f40
	opn_write_fm_regs 1,0 ;min total level
	ld l,0x04
	ld de,0x0028
	opn_write_fm_regs 0,1 ;key off
	ld bc,OPN_REG
	ld a,%11111111
	out (c),a
	ret

opninittimer60hz
;	ld de,0xc626
	ld de,0xca26
	call opnwritefm1
	ld de,0x2a27
	jp opnwritefm1

opnwaittimer60hz
	ld bc,OPN_REG
	ld a,%11111000
	out (c),a
.waitloop
	in a,(c)
	and 2
	jr z,.waitloop
	ld de,0x2a27
opntimerctrl=$+1
	ld a,0
	or d
	ld d,a
	jp opnwritefm1
