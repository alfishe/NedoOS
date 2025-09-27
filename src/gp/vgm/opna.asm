opnawritemusiconlyfm1
;e = register
;d = value
	call opnawritefm1
	ld a,e
	sub 0x10
	ret nz
	dec a
	jr nz,$-1
	ret

opnawritemusiconlyfm2
;e = register
;d = value
	jp opnawritefm2

opnaloaddatablock
;dhl = data+header size
	push de
	push hl
	ld e,6+8 ;textmode + noturbo
	OS_SETGFX
	YIELD
	YIELD
	YIELD
	pop hl
	pop de
;continue uploading at 3.5Mhz
	exx
	call memorystreamread4 ;adbc = total ram size
	call memorystreamread4 ;adbc = start address
	exx
	ld bc,8
	call sub24x16
	jp z,.done
	call setup24bitscounterloop
	ex de,hl
	ld e,b
	exx
;address in 4-bytes blocks for 1-bit RAM mode
	srl d : rr bc
	srl d : rr bc
	push bc
	ld de,0x0100
	call opnawritefm2
	ld de,0x6000
	call opnawritefm2
	ld de,0x0001
	call opnawritefm2
	ld de,0x1310
	call opnawritefm2
	ld de,0x8010
	call opnawritefm2
	pop hl
	ld d,l : ld e,0x02
	call opnawritefm2
	ld d,h : ld e,0x03
	call opnawritefm2
	ld de,0xff04
	call opnawritefm2
	ld de,0xff05
	call opnawritefm2
	ld de,0xff0c
	call opnawritefm2
	ld de,0xff0d
	call opnawritefm2
;start uploading the data
	ld bc,OPNA2_DAT
	ld hl,(memorystreamcurrentaddr)
	exx
	ld bc,OPNA2_REG
	in f,(c)
	jp m,$-2
	ld a,0x08
	out (c),a
.uploadloop
	in f,(c)
	jp m,$-2
	exx
	memory_stream_read_byte a
	out (c),a
	exx
	dec e
	jr nz,.uploadloop
	dec hl
	ld a,h
	or l
	jr nz,.uploadloop
	exx
	ld (memorystreamcurrentaddr),hl
	ld de,0x8010
	call opnawritefm2
	ld de,0x0100
	call opnawritefm2
.done	ld e,6 ;go back full speed
	OS_SETGFX
	ret
