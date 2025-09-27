OPNA1_REG = 0xf4c1 ;write: SSG + FM 1-3 address, read: status_0
OPNA1_DAT = 0xf5c1 ;write: SSG + FM 1-3 value, read: SSG value
OPNA2_REG = 0xf6c1 ;write: ADPCM + FM 4-6 address, read: status_1
OPNA2_DAT = 0xf7c1 ;write: ADPCM + FM 4-6 value, read: ADPCM value

	macro opna_write_reg reg,dat
;bc = address port
;e = register
;d = value
	ld bc,reg
	in f,(c)
	jp m,$-2
	out (c),e
	in f,(c)
	jp m,$-2
	ld bc,dat
	out (c),d
	endm

opnawriteall
;e = register
;d = value
	call opnawritefm2
opnawritefm1
;e = register
;d = value
	opna_write_reg OPNA1_REG,OPNA1_DAT
	ret

opnawritefm2
;e = register
;d = value
	opna_write_reg OPNA2_REG,OPNA2_DAT
	ret

	macro opna_write_regs fm,incr,incd
;e = base register
;d = value
;l = count
.loop	if fm == 1
	call opnawritefm1
	endif
	if fm == 2
	call opnawritefm2
	endif
	if fm == 0
	call opnawriteall
	endif
	if incr
	inc e
	endif
	if incd
	inc d
	endif
	dec l
	jr nz,.loop
	endm

opnainit
	ld l,0x88
	ld de,0x0030
	opna_write_regs 0,1,0
;panpots
	ld l,4
	ld de,0xc0b4
	opna_write_regs 0,1,0
;6 voice mode
	ld de,0x8029
	call opnawritefm1
;ADPCM 1bit / DRAM / panpot
	ld de,0xc001
	jp opnawritefm2

opnastoptimers
	ld de,0x3027
	call opnawritefm1
	ld de,0x0027
	jp opnawritefm1

opnamute
	call opnastoptimers
;mute SSG
	ld l,3
	ld de,0x0008
	opna_write_regs 1,1,0
	ld l,14
	ld de,0
	opna_write_regs 1,1,0
;mute ADPCM
	ld de,0x0100
	call opnawritefm2
	ld de,0x0001
	call opnawritefm2
;mute rhythm
	ld de,0xbf10
	call opnawritefm1
;max release rate
	ld l,16
	ld de,0x0f80
	opna_write_regs 0,1,0
;min total level
	ld l,16
	ld de,0x7f40
	opna_write_regs 0,1,0
;key off
	ld l,8
	ld de,0x0028
	opna_write_regs 1,0,1
	ret
