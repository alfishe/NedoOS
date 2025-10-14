opnawritemusiconlyfm1
;e = register
;d = value
	ld a,e
	cp 0x12
	ret z
	cp 0x21
	ret z
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
	ld a,e
	cp 0x0c
	ret z
	cp 0x0d
	ret z
	cp 0x06
	jp nc,opnawritefm2
	add a,a
	add a,e
	ld (opnafm2commandtable+1),a
opnafm2commandtable
	jr $
	jp opnawritectrl1 ; control 1       (00)
	jp opnawritectrl2 ; control 2       (01)
	jp opnawritefm2   ; start addr low  (02)
	jp opnawritefm2   ; start addr high (03)
	jp opnawritefm2   ; stop addr low   (04)
	jp opnawritefm2   ; stop addr high  (05)

opnawritectrl1
	ld a,d
	and %10110001
	ld d,a
	jp opnawritefm2

opnawritectrl2
	ld a,d
	and 0x03
	call z,opnasetnoconversionhandlers
	call nz,opnasetconversionhandlers
	ld a,d
	and %11000100
	ld d,a
	jp opnawritefm2

opnaconvertstartlo
	ld a,d
	ld (opnastartaddr),a
opnawriteconvertedstartaddr
opnastartaddr=$+1
	ld hl,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,l
	ld e,0x02
	call opnawritefm2
	ld d,h
	inc e
	jp opnawritefm2

opnaconvertstarthi
	ld a,d
	ld (opnastartaddr+1),a
	jr opnawriteconvertedstartaddr

opnaconvertstoplo
	ld a,d
	ld (opnastopaddr),a
opnawriteconvertedstopaddr
opnastopaddr=$+1
	ld hl,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,l
	ld e,0x04
	call opnawritefm2
	ld d,h
	inc e
	jp opnawritefm2

opnaconvertstophi
	ld a,d
	ld (opnastopaddr+1),a
	jr opnawriteconvertedstopaddr

vgmopnainit
	call opnainit
	jr opnasetnoconversionhandlers

	macro opna_set_adpcm_register_handler reg,handler
	ld hl,handler
	ld (opnafm2commandtable+3+reg*3),hl
	endm

opnasetnoconversionhandlers
	opna_set_adpcm_register_handler 2,opnawritefm2
	opna_set_adpcm_register_handler 3,opnawritefm2
	opna_set_adpcm_register_handler 4,opnawritefm2
	opna_set_adpcm_register_handler 5,opnawritefm2
	ret

opnasetconversionhandlers
	opna_set_adpcm_register_handler 2,opnaconvertstartlo
	opna_set_adpcm_register_handler 3,opnaconvertstarthi
	opna_set_adpcm_register_handler 4,opnaconvertstoplo
	opna_set_adpcm_register_handler 5,opnaconvertstophi
	ret

opnaloaddatablock
;dhl = data+header size
	push de
	push hl
	call turnturbooff
	pop hl
	pop de
;continue uploading at 3.5Mhz
	exx
	call memorystreamread4 ;adbc = total ram size
	call memorystreamread4 ;adbc = start address
	exx
	ld bc,8
	call sub24x16
	jp z,turnturboon
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
	jp turnturboon
