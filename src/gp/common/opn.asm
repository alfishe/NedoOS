;Define ENABLE_FM to enable FM DACs

OPN_REG = 0xfffd
OPN_DAT = 0xbffd

	macro opn_write_fm_reg chip_n
;e = register
;d = value
	ld bc,OPN_REG
	ifdef ENABLE_FM
	ld a,chip_n+%11111000
	else
	ld a,chip_n+%11111100
	endif
	out (c),a
	nop
	nop
	nop
	nop
	in f,(c)
	jp m,$-6
	out (c),e
	nop
	nop
	nop
	nop
	in f,(c)
	jp m,$-6
	ld bc,OPN_DAT
	out (c),d
	endm

opnwriteall
;e = register
;d = value
	call opnwritefm2
opnwritefm1
;e = register
;d = value
	opn_write_fm_reg 0
.extradelay ;additional delay for FPGA systems
	ld b,8
	djnz $
	ret

opnwritefm2
;e = register
;d = value
	opn_write_fm_reg 1
.extradelay ;additional delay for FPGA systems
	ld b,8
	djnz $
	ret

	macro opn_write_fm_regs incr,incd
;e = base register
;d = value
;l = count
.loop	call opnwriteall
	IF incr
	inc e
	ENDIF
	IF incd
	inc d
	ENDIF
	dec l
	jr nz,.loop
	endm

opndisableextradelay
	ld a,0xc9 ;ret opcode
	ld (opnwritefm1.extradelay),a
	ld (opnwritefm2.extradelay),a
	ret

opninit
	ld l,0xb4
	ld de,0x0000
	opn_write_fm_regs 1,0
;configure prescaler
	ld de,0x002f
	call opnwriteall
	ld de,0x002d
	jp opnwriteall

opnstoptimers
	ld de,0x3027
	call opnwriteall
	ld de,0x0027
	jp opnwriteall

opnmute
	call opnstoptimers
;mute SSG
	ld l,3
	ld de,0x0008
	opn_write_fm_regs 1,0
	ld l,14
	ld de,0x0000
	opn_write_fm_regs 1,0
;max release rate
	ld l,0x10
	ld de,0x0f80
	opn_write_fm_regs 1,0
;min total level
	ld l,0x10
	ld de,0x7f40
	opn_write_fm_regs 1,0
;key off
	ld l,0x04
	ld de,0x0028
	opn_write_fm_regs 0,1
;default tfm state
	ld bc,OPN_REG
	ld a,%11111111
	out (c),a
	ret
