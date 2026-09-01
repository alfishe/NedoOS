;
; ATM 320x200 row blit (doc 5.4 four column banks).
; Replaces IAR C plot_row_* : that path was ~8s for 320x200.
;
; IAR: 1st byte in E, 2nd pointer in BC. Keep IX/IY.
;
	MODULE plot
	PUBLIC plot_row, plot_row_4, plot_row_8
	PUBLIC g_pair_tab, g_left8, g_right8
	EXTERN zx_ega_left_tab, zx_ega_right_tab

; 256-aligned LUTs: ld e,index / ld a,(de) with D=page.
	RSEG UDATA0(8)
g_pair_tab:
	DEFS 256
g_left8:
	DEFS 256
g_right8:
	DEFS 256

	RSEG CODE

; HL = 0x8000 + E*40
y_to_bank0:
	ld l,e
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,h
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	ld de,0x8000
	add hl,de
	ret

; void plot_row_4(unsigned char y, const unsigned char *src);
; 160 packed 4bpp bytes -> 40 quartets. g_pair_tab has nibble swap + idx_map.
plot_row_4:
	push iy
	push ix
	push bc
	pop ix
	call y_to_bank0
	ld d,HIGH(g_pair_tab)
	ld c,40
plot4_col:
	ld e,(ix+0)
	ld a,(de)
	ld (hl),a
	set 6,h
	ld e,(ix+1)
	ld a,(de)
	ld (hl),a
	res 6,h
	set 5,h
	ld e,(ix+2)
	ld a,(de)
	ld (hl),a
	set 6,h
	ld e,(ix+3)
	ld a,(de)
	ld (hl),a
	res 6,h
	res 5,h
	inc hl
	push de
	ld de,4
	add ix,de
	pop de
	dec c
	jr nz,plot4_col
	pop ix
	pop iy
	ret

; void plot_row_8(unsigned char y, const unsigned char *src);
; 320 file bytes; g_left8/g_right8 = ATM halves after idx_map.
plot_row_8:
	push iy
	push ix
	push bc
	pop ix
	call y_to_bank0
	ld d,HIGH(g_left8)
	ld c,40
plot8_col:
	ld e,(ix+0)
	ld a,(de)
	ld b,a
	ld e,(ix+1)
	inc d
	ld a,(de)
	or b
	dec d
	ld (hl),a
	set 6,h
	ld e,(ix+2)
	ld a,(de)
	ld b,a
	ld e,(ix+3)
	inc d
	ld a,(de)
	or b
	dec d
	ld (hl),a
	res 6,h
	set 5,h
	ld e,(ix+4)
	ld a,(de)
	ld b,a
	ld e,(ix+5)
	inc d
	ld a,(de)
	or b
	dec d
	ld (hl),a
	set 6,h
	ld e,(ix+6)
	ld a,(de)
	ld b,a
	ld e,(ix+7)
	inc d
	ld a,(de)
	or b
	dec d
	ld (hl),a
	res 6,h
	res 5,h
	inc hl
	push de
	ld de,8
	add ix,de
	pop de
	dec c
	jp nz,plot8_col
	pop ix
	pop iy
	ret

; void plot_row(unsigned char y, const unsigned char *pix);
; 320 already-mapped HW indices 0..15 (letterbox path).
plot_row:
	push iy
	push ix
	push bc
	pop ix
	call y_to_bank0
	ld c,40
plotu_col:
	ld a,(ix+0)
	and 15
	ld e,a
	ld d,0
	push hl
	ld hl,zx_ega_left_tab
	add hl,de
	ld a,(hl)
	ld b,a
	ld a,(ix+1)
	and 15
	ld e,a
	ld d,0
	ld hl,zx_ega_right_tab
	add hl,de
	ld a,b
	or (hl)
	pop hl
	ld (hl),a
	set 6,h
	ld a,(ix+2)
	and 15
	ld e,a
	ld d,0
	push hl
	ld hl,zx_ega_left_tab
	add hl,de
	ld a,(hl)
	ld b,a
	ld a,(ix+3)
	and 15
	ld e,a
	ld d,0
	ld hl,zx_ega_right_tab
	add hl,de
	ld a,b
	or (hl)
	pop hl
	ld (hl),a
	res 6,h
	set 5,h
	ld a,(ix+4)
	and 15
	ld e,a
	ld d,0
	push hl
	ld hl,zx_ega_left_tab
	add hl,de
	ld a,(hl)
	ld b,a
	ld a,(ix+5)
	and 15
	ld e,a
	ld d,0
	ld hl,zx_ega_right_tab
	add hl,de
	ld a,b
	or (hl)
	pop hl
	ld (hl),a
	set 6,h
	ld a,(ix+6)
	and 15
	ld e,a
	ld d,0
	push hl
	ld hl,zx_ega_left_tab
	add hl,de
	ld a,(hl)
	ld b,a
	ld a,(ix+7)
	and 15
	ld e,a
	ld d,0
	ld hl,zx_ega_right_tab
	add hl,de
	ld a,b
	or (hl)
	pop hl
	ld (hl),a
	res 6,h
	res 5,h
	inc hl
	push de
	ld de,8
	add ix,de
	pop de
	dec c
	jp nz,plotu_col
	pop ix
	pop iy
	ret

	ENDMOD
	END
