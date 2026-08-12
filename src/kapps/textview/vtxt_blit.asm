;
; Fast present: linear 80x25 char+attr -> ATM text VRAM at C000.
; Addressing matches BDOS_countxy / BDOS_paint_row_step.
; Chars in the backbuffer are already ATM codes (vtxt.c applies 866toatm).
;
	MODULE vtxt_blit
	PUBLIC vtxt_blit, vtxt_blit_row, vtxt_blit_rows
	PUBLIC vtxt_pg_text, vtxt_pg_attr
	PUBLIC vtxt_ptr_ch, vtxt_ptr_at, vtxt_saved_c000
	EXTERN SETPG32KHIGH

	RSEG UDATA0
vtxt_pg_text:	DEFS 1
vtxt_pg_attr:	DEFS 1
vtxt_ptr_ch:	DEFS 2
vtxt_ptr_at:	DEFS 2
vtxt_saved_c000: DEFS 1
blit_y:		DEFS 1
blit_scr:	DEFS 2
blit_src:	DEFS 2
blit_y1:	DEFS 1
blit_y2:	DEFS 1

	RSEG CODE

; void vtxt_blit(void);  full 0..24
vtxt_blit:
	push ix
	push iy
	push bc
	push de
	xor a
	ld (blit_y1),a
	ld a,25
	ld (blit_y2),a
	jr blit_range

; void vtxt_blit_rows(unsigned char y0, unsigned char y1); E=y0, C=y1 (y1 exclusive)
vtxt_blit_rows:
	push ix
	push iy
	push bc
	push de
	ld a,e
	ld (blit_y1),a
	ld a,c
	ld (blit_y2),a
	jr blit_range

; void vtxt_blit_row(unsigned char y); E=y  (one row)
vtxt_blit_row:
	push ix
	push iy
	push bc
	push de
	ld a,e
	ld (blit_y1),a
	inc a
	ld (blit_y2),a

blit_range:
	; ---- text plane ----
	ld a,(vtxt_pg_text)
	ld e,a
	call SETPG32KHIGH

	ld a,(blit_y1)
	ld (blit_y),a
text_row:
	ld a,(blit_y)
	ld d,a
	ld e,0
	call countxy
	ld (blit_scr),hl

	ld a,(blit_y)
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,h
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	ld de,(vtxt_ptr_ch)
	add hl,de
	ld (blit_src),hl

	ld hl,(blit_scr)
	ld de,(blit_src)
	ld b,80
text_cell:
	ld a,(de)
	inc de
	ld (hl),a
	call step_xy
	djnz text_cell

	ld a,(blit_y)
	inc a
	ld (blit_y),a
	ld hl,blit_y2
	cp (hl)
	jr c,text_row

	; ---- attr plane ----
	ld a,(vtxt_pg_attr)
	ld e,a
	call SETPG32KHIGH

	ld a,(blit_y1)
	ld (blit_y),a
attr_row:
	ld a,(blit_y)
	ld d,a
	ld e,0
	call countxy
	ld (blit_scr),hl

	ld a,(blit_y)
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,h
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	ld de,(vtxt_ptr_at)
	add hl,de
	ld (blit_src),hl

	ld hl,(blit_scr)
	ld de,(blit_src)
	ld b,80
attr_cell:
	ld a,(de)
	inc de
	ld c,a
	push hl
	ld a,h
	xor 020h
	ld h,a
	and 020h
	jr nz,attr_store
	inc l
attr_store:
	ld (hl),c
	pop hl
	call step_xy
	djnz attr_cell

	ld a,(blit_y)
	inc a
	ld (blit_y),a
	ld hl,blit_y2
	cp (hl)
	jr c,attr_row

	ld a,(vtxt_saved_c000)
	ld e,a
	call SETPG32KHIGH

	pop de
	pop bc
	pop iy
	pop ix
	ret

countxy:
	ld a,d
	sub 079h
	rra
	ld h,a
	ld a,0
	rra
	sra h
	rra
	ld l,e
	srl l
	jr c,countxy_odd
	res 5,h
countxy_odd:
	add a,l
	ld l,a
	ret

step_xy:
	ld a,h
	xor 020h
	ld h,a
	and 020h
	ret nz
	inc l
	ret

	ENDMOD
	END
