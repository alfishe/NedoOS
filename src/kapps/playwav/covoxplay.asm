
	MODULE COVOXPLAY
	PUBLIC covox_hx
	PUBLIC covox_play
	PUBLIC covox_play_pages
	PUBLIC covox_play_stopped
	EXTERN pagetable
	EXTERN sample_pages
	EXTERN page_samples
	EXTERN pages_loaded
	#include "sysdefs.asm"
	RSEG CODE

covox_hx:
	DEFB 0

covox_play_stopped:
	DEFB 0

;void covox_play_pages(void);
;Multi-page loop. Key poll between pages via rst 0x08 (no ei ? long scheduler
;gaps at every 16K boundary were muffling real audio).
covox_play_pages:
	push ix
	push iy
	push bc
	push de
	push hl
	ld a,(curpgc000)
	push af
	xor a
	ld (covox_play_stopped),a
	ld a,(covox_hx)
	or a
	jr z,cpp_done
	ld d,a
	ld ixh,d
	di
	ld b,0
cpp_page_loop:
	ld a,b
	ld hl,pages_loaded
	cp (hl)
	jr nc,cpp_finish
	push bc
	ld c,b
	ld b,0
	ld hl,sample_pages
	add hl,bc
	ld a,(hl)
	ld e,a
	rst 0x28
	pop bc
	push bc
	ld c,b
	ld b,0
	ld hl,page_samples
	add hl,bc
	add hl,bc
	add hl,bc
	add hl,bc
	ld e,(hl)
	inc hl
	ld d,(hl)
	pop bc
	ld hl,0xC000
	ld a,b
	or a
	jr z,cpp_sample_loop
	ld a,ixh
cpp_pre_delay:
	dec a
	jp nz,cpp_pre_delay
cpp_sample_loop:
	ld a,(hl)
	out (0xfb),a
	inc hl
	dec de
	ld a,d
	or e
	jr z,cpp_page_done
	ld a,ixh
cpp_delay:
	dec a
	jp nz,cpp_delay
	jr cpp_sample_loop
cpp_page_done:
	ld a,ixh
cpp_pd_delay:
	dec a
	jp nz,cpp_pd_delay
	push bc
	push de
	push hl
	push ix
	push iy
	rst 0x08
	pop iy
	pop ix
	pop hl
	pop de
	pop bc
	ld (covox_play_stopped),a
	or a
	jr nz,cpp_abort
	inc b
	jr cpp_page_loop
cpp_abort:
	ld a,0x80
	out (0xfb),a
	jr cpp_finish
cpp_finish:
	ei
cpp_done:
	pop af
	ld e,a
	rst 0x28
	pop hl
	pop de
	pop bc
	pop iy
	pop ix
	ret

;void covox_play(void);
covox_play:
	push ix
	push iy
	ld a,(curpgc000)
	push af
	ld a,(covox_hx)
	or a
	jr z,covox_done
	ld d,a
	ld ixh,d
	ld ixl,0
	ld hl,0xC000
	ld de,pagetable
	ld c,CMD_PLAYCOVOX
	call BDOS
covox_done:
	pop af
	ld e,a
	rst 0x28
	pop iy
	pop ix
	ret
	ENDMOD

	END
