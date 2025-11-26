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
	call turnturbooff
	jp opninit

vgmopnmute
	call opnmute
	jp turnturboon
