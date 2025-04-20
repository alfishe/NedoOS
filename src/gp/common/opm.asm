OPM0_REG = 0xf0c1 ;write: address
OPM0_DAT = 0xf1c1 ;write: value, read: status
OPM1_REG = 0xf2c1 ;write: address
OPM1_DAT = 0xf3c1 ;write: value, read: status

	macro opm_write_reg chip_n
;e = register
;d = value
	IF chip_n
	ld bc,OPM1_DAT
	ELSE
	ld bc,OPM0_DAT
	ENDIF
	in f,(c)
	jp m,$-2
	dec b
	out (c),e
	inc b
	in f,(c)
	jp m,$-2
	out (c),d
	endm

opmwritechip0
;e = register
;d = value
	opm_write_reg 0
	ret

opmwritechip1
;e = register
;d = value
	opm_write_reg 1
	ret

opmwriteall
;e = register
;d = value
	call opmwritechip0
	jp opmwritechip1

opmdisablechip1
	ld a,0xc9 ;ret opcode
	ld (opmwritechip1),a
	ret

	macro opm_write_regs incr,incd
;e = base register
;d = value
;l = count
.loop	call opmwriteall
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
;stop timers
	ld de,0x3014
	call opmwriteall
	ld de,0x0014
	call opmwriteall
;max release rate
	ld l,0x20
	ld de,0x0fe0
	opm_write_regs 1,0
;min total level
	ld l,0x20
	ld de,0x7f60
	opm_write_regs 1,0
;key off
	ld l,0x08
	ld de,0x0008
	opm_write_regs 0,1
	ret
