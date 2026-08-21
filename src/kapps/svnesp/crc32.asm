; Fast ZIP CRC-32 for IAR Z80 / NedoOS (from pkzip/crc32.asm)

	MODULE crc32
	PUBLIC crc32_reset
	PUBLIC crc32_update
	PUBLIC crc32_get

	RSEG UDATA0(10)
TCRC:
	DEFS 1024

	RSEG UDATA0
crc_lo:
	DEFS 2
crc_hi:
	DEFS 2
crc_ready:
	DEFS 1
crc_buf:
	DEFS 2
crc_len:
	DEFS 2

	RSEG CODE

crc32_reset:
	push iy
	push ix
	ld a,(crc_ready)
	or a
	call z,crc32_build
	ld hl,0xffff
	ld (crc_lo),hl
	ld (crc_hi),hl
	pop ix
	pop iy
	ret

crc32_update:
	push iy
	push ix
	ld a,b
	or c
	jr z,upd_done
	ld (crc_buf),de
	ld (crc_len),bc
	ld de,(crc_lo)
	ld bc,(crc_hi)
upd_loop:
	push bc
	ld bc,(crc_len)
	ld a,b
	or c
	jr z,upd_end
	dec bc
	ld (crc_len),bc
	ld hl,(crc_buf)
	ld a,(hl)
	inc hl
	ld (crc_buf),hl
	pop bc
	xor e
	ld l,a
	ld h,high(TCRC)
	ld a,(hl)
	xor d
	ld e,a
	inc h
	ld a,(hl)
	xor c
	ld d,a
	inc h
	ld a,(hl)
	xor b
	ld c,a
	inc h
	ld b,(hl)
	jr upd_loop
upd_end:
	pop bc
	ld (crc_lo),de
	ld (crc_hi),bc
upd_done:
	pop ix
	pop iy
	ret

crc32_get:
	push iy
	push ix
	ld hl,(crc_lo)
	ld a,l
	cpl
	ld l,a
	ld a,h
	cpl
	ld h,a
	ld bc,(crc_hi)
	ld a,c
	cpl
	ld c,a
	ld a,b
	cpl
	ld b,a
	pop ix
	pop iy
	ret

crc32_build:
	push bc
	push de
	push hl
	ld l,0
bld_i:
	ld b,8
	ld c,0
	ld d,c
	ld e,c
	ld a,l
bld_bit:
	srl c
	rr d
	rr e
	rra
	jr nc,bld_nox
	push af
	ld a,c
	xor 0xed
	ld c,a
	ld a,d
	xor 0xb8
	ld d,a
	ld a,e
	xor 0x83
	ld e,a
	pop af
	xor 0x20
bld_nox:
	djnz bld_bit
	ld h,high(TCRC)
	ld (hl),a
	inc h
	ld (hl),e
	inc h
	ld (hl),d
	inc h
	ld (hl),c
	inc l
	jr nz,bld_i
	ld a,1
	ld (crc_ready),a
	pop hl
	pop de
	pop bc
	ret

	ENDMOD
	END
