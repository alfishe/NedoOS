//TCRC=0x4000 ;size 0x400, divisible by 0x100

CS_SYMLEN	equ	8 ;length of checksum in ascii: 8 for CRC32


CS_PREPARE:	; precalculate CRC table

	xor	a
	ld	l,a
.tbloop
	exx	
	ld	hl,0
	ld	d,h
	ld	e,a
	ld	b,8
.bitloop
	srl	h
	rr	l
	rr	d
	rr	e
	jr	nc,.skipxor
	ex	af,af'
	ld	a,e
	xor	0x20
	ld	e,a
	ld	a,d
	xor	0x83
	ld	d,a
	ld	a,l
	xor	0xb8
	ld	l,a
	ld	a,h
	xor	0xed
	ld	h,a
	ex	af,af'
.skipxor
	djnz	.bitloop
	push	hl
	push	de
	exx	
	ld	h,TCRC/256
	pop	de
	ld	(hl),e
	inc	h
	ld	(hl),d
	inc	h
	pop	de
	ld	(hl),e
	inc	h
	ld	(hl),d
	inc	l
	inc	a
	jr	nz,.tbloop

	ret



CS_START:	;start/init calculation anew
		
		ld	hl,0xFFFF
		ld	[CRCArea+0],hl
		ld	[CRCArea+2],hl
		ret


CS_APPEND:	;append chunk of data to calculation
		;in: bc - size
		;in: hl - ptr
	
		;kills: everything

		exx
		ld	bc,[CRCArea+0]
		ld	de,[CRCArea+2]
		exx
.crc_loop
	ld	a,[hl]		;7
	exx			;4

	xor	c		;4
	ld	l,a		;4

	ld	h,TCRC/256	;7
	ld	a,[hl]		;7
	xor	b		;4
	ld	c,a		;4

	inc	h		;4
	ld	a,[hl]		;7
	xor	e		;4
	ld	b,a		;4

	inc	h		;4
	ld	a,[hl]		;7
	xor	d		;4
	ld	e,a		;4

	inc	h		;4
	ld	d,[hl]		;7

	exx			;4
	cpi			;16
	jp	pe,.crc_loop	;10
				; == 120 tc/byte
		
		exx
		ld	[CRCArea+0],bc
		ld	[CRCArea+2],de
		ret


CS_FINALIZE:	;finish calculation, generate asciiz string with checksum

		;in: HL - place of CS_SYMLEN+1 bytes to place asciiz string of checksum

		;kills: everything

		push	hl

		ld	hl,CRCArea+1
		ld	de,CRCArea+2

		 DUP	2
		ld	a,[hl]
		cpl
		ld	b,a
		ld	a,[de]
		cpl
		ld	[hl],a
		ld	a,b
		ld	[de],a
		dec	hl
		inc	de
		 EDUP
		org	$-2

		pop	de
		call	hexconv4
		xor	a
		ld	[de],a
		ret

hexconv4
	call	hexconv2
hexconv2
	call	hexconv
hexconv
	ld	a,(hl)
	rrca
	rrca
	rrca
	rrca
	call	.digit
	ld	a,(hl)
	inc	hl
.digit
	or	0xf0
	daa
	add	a,0xa0
	adc	a,0x40
	ld	[de],a
	inc	de
	ret


CRCArea
        ds 4,0xff


	org	($+255)&0xFF00
TCRC	ds	0x400

