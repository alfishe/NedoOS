; tgvplay hot path ? one module: tables/blit + decode + flip/map.
; Inlined: blit in dec_do_chrx; IY restore + map_draw in tgv_flip.
;
	MODULE tgv_hot
	PUBLIC tgv_blit_tables_init
	PUBLIC tgv_capture_task_iy
	PUBLIC tgv_decode_sector
	PUBLIC tgv_flip
	PUBLIC tgv_map_draw
	PUBLIC g_front
	PUBLIC g_scr0_low
	PUBLIC g_scr0_high
	PUBLIC g_scr1_low
	PUBLIC g_scr1_high
	PUBLIC fmv_mounted
	PUBLIC tgv_flip_halt
	EXTERN secbase
	EXTERN secpos
	EXTERN frame_open
	#include "sysdefs.asm"

FMV_SLOTS	EQU	113
FMV_SECSIZE	EQU	2048
FMV_TAIL	EQU	14

; ---------------------------------------------------------------------------
; UDATA
; ---------------------------------------------------------------------------
; Page-aligned tables (DEFS 256, no ALIGN pad ? avoids xlink w28/w29).
	RSEG UDATA0(8)
tx_lo:
	DEFS 256
tx_hi:
	DEFS 256
ty40_lo:
	DEFS 256
ty40_hi:
	DEFS 256
task_iy_save:
	DEFS 2
task_sp_save:
	DEFS 2
blit_dst0:
	DEFS 2

	RSEG UDATA0
dec_chrx_b:
	DEFS 1
g_front:
	DEFS 1
g_scr0_low:
	DEFS 1
g_scr0_high:
	DEFS 1
g_scr1_low:
	DEFS 1
g_scr1_high:
	DEFS 1
fmv_mounted:
	DEFS 1
tgv_flip_halt:
	DEFS 1

	RSEG CODE

; ===========================================================================
; IY save / tables
; ===========================================================================
tgv_capture_task_iy:
	ld (task_iy_save),iy
	ret

tgv_blit_tables_init:
	push iy				; IAR C: keep IX/IY only
	push ix

	ld hl,tx_lo
	ld c,0
init_lo:
	ld a,c
	srl a
	srl a
	ld (hl),a
	inc hl
	inc c
	ld a,c
	cp 160
	jr nz,init_lo

	ld hl,tx_hi
	ld c,0
init_hi:
	ld a,c
	and 3
	jr z,bank80
	dec a
	jr z,bankc0
	dec a
	jr z,banka0
	ld a,0xe0
	jr bank_store
bank80:
	ld a,0x80
	jr bank_store
bankc0:
	ld a,0xc0
	jr bank_store
banka0:
	ld a,0xa0
bank_store:
	ld (hl),a
	inc hl
	inc c
	ld a,c
	cp 160
	jr nz,init_hi

	ld c,0
init_ty:
	push bc
	ld a,c
	add a,a
	add a,a
	add a,a
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld e,l
	ld d,h
	add hl,hl
	add hl,hl
	add hl,de
	ex de,hl
	pop bc
	ld b,0
	ld hl,ty40_lo
	add hl,bc
	ld (hl),e
	ld hl,ty40_hi
	add hl,bc
	ld (hl),d
	inc c
	ld a,c
	cp 24
	jr nz,init_ty

	pop ix
	pop iy
	ret

; ===========================================================================
; decode (+ inlined blit)
; ===========================================================================
tgv_decode_sector:
	push iy				; IAR C: keep IX/IY; AF/BC/DE/HL free
	push ix
	di

	ld iy,(secbase)
	ld de,(secpos)
	add iy,de
	ld ixh,FMV_SLOTS

dec_loop:
	ld a,(iy+0)
	inc iy
	cp 0xff
	jp z,dec_end
	ld ixl,a

	add a,a				; bit7 ? C (4T vs bit 7,a = 8T)
	jr nc,dec_do_chrx		; bit7 was 0 ? tile
	jp m,dec_do_chrx		; was 11xxxxxx, not NEWPLANE (#80)
	ld a,(frame_open)
	or a
	jr z,dec_frame_mark
	push iy
	ei				; HALT needs INT; decode runs under DI
	call tgv_flip
	di
	pop iy
dec_frame_mark:
	ld a,1
	ld (frame_open),a

dec_do_chrx:
	ld a,(iy+0)			; chrx
	inc iy
	ld (dec_chrx_b),a
	ld e,iyl
	ld d,iyh			; DE=payload
	ld bc,16
	add iy,bc

	ld a,ixl
	and 31
	cp 24
	jp nc,dec_next
	ld c,a				; C=chry
	ld a,(dec_chrx_b)
	cp 40
	jp nc,dec_next
	add a,a
	add a,a				; chrx*4
	ld b,a
	ld a,ixl
	rlca
	rlca
	and 1				; bplane
	add a,b
	ld b,a				; pair0
	; --- stack blit: SP?src, POP DE = 2 bytes; HL = VRAM +40 ---
	; BUGFIX: addr calc must not kill DE=src; save dst0 (can't PUSH while SP=src).
	; IY still needs +16 above ? POP only reads payload, does not advance IY.
	push de				; src on real stack
	ld h,HIGH ty40_lo
	ld l,c
	ld e,(hl)
	ld h,HIGH ty40_hi
	ld d,(hl)			; DE=ty (src is on stack)
	ld h,HIGH tx_lo
	ld l,b
	ld a,(hl)
	add a,e
	ld e,a
	ld h,HIGH tx_hi
	ld a,(hl)
	adc a,d
	ld h,a
	ld l,e				; HL=dst0
	ld (blit_dst0),hl
	pop de				; DE=src
	ld (task_sp_save),sp
	ex de,hl			; HL=src, DE=dst0
	ld sp,hl			; SP=src
	ex de,hl			; HL=dst0
	ld bc,40

	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d
	add hl,bc
	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d
	add hl,bc
	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d
	add hl,bc
	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d

	ld hl,(blit_dst0)		; exact plane0 base (no fragile ?280)
	ld a,h
	xor 020h
	ld h,a

	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d
	add hl,bc
	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d
	add hl,bc
	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d
	add hl,bc
	pop de
	ld (hl),e
	add hl,bc
	ld (hl),d

	ld sp,(task_sp_save)
	; --- end blit ---

dec_next:
	dec ixh				; Z when slots exhausted
	jp nz,dec_loop
	jp dec_tail

dec_end:
	ld de,FMV_SECSIZE
	ld (secpos),de
	ld a,(frame_open)
	or a
	jr z,dec_eof
	ei
	call tgv_flip
	di
	xor a
	ld (frame_open),a
dec_eof:
	ld hl,1
	jr dec_out

dec_tail:
	ld bc,FMV_TAIL
	add iy,bc
	ld e,iyl
	ld d,iyh
	ld hl,(secbase)
	ex de,hl
	or a
	sbc hl,de
	ld (secpos),hl
	ld de,FMV_SECSIZE
	or a
	sbc hl,de
	ld hl,0
	jr z,dec_out
	jp nc,dec_err
	jr dec_out

dec_err:
	ld hl,0xffff
dec_out:
	ei
	pop ix
	pop iy
	ret

; ===========================================================================
; flip / map_draw
; ===========================================================================
; C/asm: may clobber AF,BC (IAR). No push.
tgv_map_draw:
	ld a,(g_front)
	xor 1
	or a
	jr nz,map_s1
	ld a,(g_scr0_low)
	rst 020h
	ld a,(g_scr0_high)
	rst 028h
	jr map_done
map_s1:
	ld a,(g_scr1_low)
	rst 020h
	ld a,(g_scr1_high)
	rst 028h
map_done:
	ld a,1
	ld (fmv_mounted),a
	ret

; AF/BC/DE/HL free to clobber. IX/IY saved around BDOS only.
tgv_flip:
	ld a,(g_front)
	xor 1
	ld (g_front),a
	ld e,a
	ld iy,(task_iy_save)
	push ix
	push iy
	ld c,CMD_SETSCREEN
	call BDOS
	pop iy
	pop ix
	ld a,(tgv_flip_halt)
	or a
	jr z,flip_no_halt
	ei				; never HALT under DI
	halt
flip_no_halt:
	; inline map_draw
	ld a,(g_front)
	xor 1
	or a
	jr nz,flip_map_s1
	ld a,(g_scr0_low)
	rst 020h
	ld a,(g_scr0_high)
	rst 028h
	jr flip_map_done
flip_map_s1:
	ld a,(g_scr1_low)
	rst 020h
	ld a,(g_scr1_high)
	rst 028h
flip_map_done:
	ld a,1
	ld (fmv_mounted),a
	ret

	ENDMOD
	END
