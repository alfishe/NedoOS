;
; Paint one 80-column text row to BDOS screen VRAM (ATM countxy layout).
; C sets tv_row_ptr -> 80 CP866 chars; tv_scr_pg_text/attr from OS_GETSCR0.
; void tv_paint_row(unsigned char y, unsigned char attr);  IAR: E=y, C=attr
;
	MODULE tv_paint
	PUBLIC tv_paint_row
	PUBLIC tv_scr_pg_text, tv_scr_pg_attr, tv_scr_home
	PUBLIC tv_row_ptr
	EXTERN SETPG32KHIGH

	RSEG UDATA0
tv_scr_pg_text:	DEFS 1
tv_scr_pg_attr:	DEFS 1
tv_scr_home:	DEFS 1
tv_row_ptr:	DEFS 2
tp_y:		DEFS 1
tp_attr:	DEFS 1
tp_scr:		DEFS 2
tp_src:		DEFS 2

	RSEG CODE

tv_paint_row:
	push ix
	push iy
	push bc
	push de
	ld a,e
	ld (tp_y),a
	ld a,c
	ld (tp_attr),a

	ld a,(tv_scr_pg_text)
	ld e,a
	call SETPG32KHIGH

	ld a,(tp_y)
	ld d,a
	ld e,0
	call countxy
	ld (tp_scr),hl
	ld hl,(tv_row_ptr)
	ld (tp_src),hl

	ld b,80
tp_text:
	push bc
	ld de,(tp_src)
	ld a,(de)
	inc de
	ld (tp_src),de
	pop bc
	push af
	ld hl,(tp_scr)
	pop af
	ld (hl),a
	call step_xy
	ld (tp_scr),hl
	djnz tp_text

	ld a,(tv_scr_pg_attr)
	ld e,a
	call SETPG32KHIGH

	ld a,(tp_y)
	ld d,a
	ld e,0
	call countxy
	ld (tp_scr),hl

	ld b,80
tp_aloop:
	push bc
	ld hl,(tp_scr)
	ld a,(tp_attr)
	ld c,a
	push hl
	ld a,h
	xor 020h
	ld h,a
	and 020h
	jr nz,tp_as
	inc l
tp_as:
	ld (hl),c
	pop hl
	call step_xy
	ld (tp_scr),hl
	djnz tp_aloop

	ld a,(tv_scr_home)
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
