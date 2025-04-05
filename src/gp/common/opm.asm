OPM0_REG = 0xf0c1
OPM0_DAT = 0xf1c1
OPM1_REG = 0xf2c1
OPM1_DAT = 0xf3c1

	macro opm_write_reg chip_n
;e = register
;d = value
	ld bc,OPM0_REG+(chip_n*0x200)
	in a,(c)
	rlca
	jr c,$-3
	out (c),e
	in a,(c)
	rlca
	jr c,$-3
	inc b
	out (c),d
	endm

opmwrite0
;e = register
;d = value
	opm_write_reg 0
	ret

opmwrite1
;e = register
;d = value
	opm_write_reg 1
	ret

	macro opm_write_regs incr,incd
;e = base register
;d = value
;l = count
.loop
	call opmwrite0
	call opmwrite1
	IF incr
	inc e
	ENDIF
	IF incd
	inc d
	ENDIF
	dec l
	jr nz,.loop
	endm

opminit
	ld l,0
	ld de,0
	opm_write_regs 1,0
	ret

opmmute
	ld l,0x20
	ld de,0x0fe0
	opm_write_regs 1,0
	ld l,0x20
	ld de,0x7f60
	opm_write_regs 1,0
	ld l,0x08
	ld de,0x0008
	opm_write_regs 0,1
	ret
