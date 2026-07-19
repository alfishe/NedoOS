; Fast ZIP CRC-32 for IAR Z80 / NedoOS.
; Columnar 1K table (src/crc/crc.asm).
;
; No EXX / EX AF,AF' / CPI ? safe under NedoOS interrupts with IAR C.
;
; C ABI (iccz80 -ml):
;   ptr -> DE, 2nd uint -> BC, ulong ret -> BC:HL
; Preserve IY.

	MODULE crc32
	PUBLIC crc32_reset
	PUBLIC crc32_update
	PUBLIC crc32_get

	RSEG UDATA0(10)		; align 1024
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

; void crc32_reset(void);
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

; void crc32_update(const unsigned char *buf, unsigned int len);
; DE=buf, BC=len
;
; Loop regs: DE=crc_lo (E=c0,D=c1), BC=crc_hi (C=c2,B=c3)
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
	push bc				; save crc_hi
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
	pop bc				; BC=crc_hi

	xor e
	ld l,a
	ld h,high(TCRC)

	ld a,(hl)			; t0
	xor d
	ld e,a				; c0'

	inc h
	ld a,(hl)			; t1
	xor c
	ld d,a				; c1'

	inc h
	ld a,(hl)			; t2
	xor b
	ld c,a				; c2'

	inc h
	ld b,(hl)			; c3' = t3
	jr upd_loop

upd_end:
	pop bc				; discard saved crc_hi
	ld (crc_lo),de
	; BC was crc_hi from last iter ? still valid in DE/BC
	; but we popped the PUSH from previous iteration's save...
	; After jr z,upd_end we still have crc_hi on stack from push at loop top.
	; DE still has crc_lo. Need crc_hi: we popped into... wait we went to
	; upd_end WITHOUT popping in the zero path ? we have push bc still on stack,
	; then `pop bc` discards the OLD crc_hi from when len hit 0.
	; DE is current crc_lo. But BC after pop is the pushed crc_hi from START
	; of this iteration ? which is the CURRENT crc_hi before we'd update.
	; When len hits 0 we haven't updated this iteration, so pushed BC IS current crc_hi.
	ld (crc_hi),bc
upd_done:
	pop ix
	pop iy
	ret

; unsigned long crc32_get(void);
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

; Build table without EX AF,AF'
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
