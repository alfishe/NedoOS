;
; Fast present: linear 80x25 char+attr -> ATM text VRAM at C000.
; Addressing matches BDOS_countxy / BDOS_paint_row_step.
; Chars in the backbuffer are already ATM codes (vtxt.c applies 866toatm).
;
; Globals (UDATA0), set by vtxt.c before call:
;   vtxt_pg_text, vtxt_pg_attr, vtxt_ptr_ch, vtxt_ptr_at, vtxt_saved_c000
;
	MODULE vtxt_blit
	PUBLIC vtxt_blit
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

	RSEG CODE

; void vtxt_blit(void);
vtxt_blit:
	push ix
	push iy
	push bc
	push de

	; ---- text plane ----
	ld a,(vtxt_pg_text)
	ld e,a			; SETPG32KHIGH expects page in E
	call SETPG32KHIGH

	xor a
	ld (blit_y),a
text_row:
	ld a,(blit_y)
	ld d,a			; y
	ld e,0			; x=0
	call countxy
	ld (blit_scr),hl

	; src = vtxt_ptr_ch + y*80
	ld a,(blit_y)
	ld l,a
	ld h,0
	add hl,hl		; *2
	add hl,hl		; *4
	add hl,hl		; *8
	add hl,hl		; *16
	ld d,h
	ld e,l
	add hl,hl		; *32
	add hl,hl		; *64
	add hl,de		; *80
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
	cp 25
	jr c,text_row

	; ---- attr plane ----
	ld a,(vtxt_pg_attr)
	ld e,a
	call SETPG32KHIGH

	xor a
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
	cp 25
	jr c,attr_row

	; restore caller C000
	ld a,(vtxt_saved_c000)
	ld e,a
	call SETPG32KHIGH

	pop de
	pop bc
	pop iy
	pop ix
	ret

; in: d=y e=x; out: hl = VRAM addr (within page @ C000)
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
