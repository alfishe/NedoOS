MOON_BASE = 0xc4
MOON_REG1 = MOON_BASE
MOON_DAT1 = MOON_BASE+1
MOON_REG2 = MOON_BASE+2
MOON_DAT2 = MOON_BASE+3
MOON_STAT = MOON_BASE
MOON_WREG = 0xc2
MOON_WDAT = MOON_WREG+1

;TODO: is this good enough for ATM2?
	macro opl4_wait
	in a,(MOON_STAT)
	rrca
	jr c,$-3
	endm

;makes ZXM-Moonsound firmware 1.01 switch PCM ports from default 7E and 7F to C2 and C3
	macro switch_to_pcm_ports_c2_c3
	in a,(MOON_REG2)
	endm

ismoonsoundpresent
;out: zf=1 if Moonsound is present, zf=0 if not
	switch_to_pcm_ports_c2_c3
	in a,(MOON_STAT)
	cp 255
	ccf
	sbc a,a
	ret nz
;FIXME: f***ing kempston joystick in Unreal :-\
	ld bc,0
.loop	in a,(MOON_STAT)
	and 3
	ret z
	dec bc
	ld a,b
	or c
	jr nz,.loop
	dec a
	ret

MOONSOUNDROMSIZE = 0x200000
MOONWAVEHEADERSIZE = 12
MOONRAMWAVETABLESIZE = 128
