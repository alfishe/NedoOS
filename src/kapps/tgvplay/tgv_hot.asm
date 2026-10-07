; tgvplay hot path ? one module: tables/blit + decode + flip/map.
; Inlined: blit in dec_do_chrx; IY restore + map_draw in tgv_flip.
;
; A finished frame is switched in the top border. If an IRQ already arrived
; while the frame was drawing, the beam has moved on and we switch at once.
; Otherwise HALT, then SETSCREEN, so a fast frame is not cut mid-picture.
;
	MODULE tgv_hot
	PUBLIC tgv_blit_tables_init
	PUBLIC tgv_capture_task_iy
	PUBLIC tgv_decode_sector
	PUBLIC tgv_flip
	PUBLIC tgv_map_draw
	PUBLIC tgv_qwait_flush
	PUBLIC tgv_int_hook
	PUBLIC tgv_int_unhook
	PUBLIC g_front
	PUBLIC g_scr0_low
	PUBLIC g_scr0_high
	PUBLIC g_scr1_low
	PUBLIC g_scr1_high
	PUBLIC fmv_mounted
	PUBLIC tgv_flip_halt
	PUBLIC tgv_ev_last
	PUBLIC tgv_qmode
	EXTERN secbase
	EXTERN secpos
	EXTERN frame_open
	EXTERN tgv_pace_on
	EXTERN tgv_pace_ticks
	EXTERN tgv_pace_num
	EXTERN tgv_pace_den
	EXTERN tgv_ev_on
	EXTERN tgv_ev_key
	EXTERN tgv_ev_hit
	EXTERN tgv_ev_fail
	EXTERN tgv_ev_open
	EXTERN tgv_ev_close
	EXTERN tgv_snd_n
	EXTERN tgv_cover
	EXTERN tgv_hint
	EXTERN tgv_mark_paint
	EXTERN user_abort
	#include "sysdefs.asm"

FMV_SLOTS	EQU	113
FMV_SECSIZE	EQU	2048
FMV_TAIL	EQU	14
QCAP		EQU	512

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
	PUBLIC tgv_frm_n
	PUBLIC tgv_irq_n
	PUBLIC tgv_irq_seen
	PUBLIC tgv_pace_acc
tgv_frm_n:
	DEFS 2
tgv_irq_n:
	DEFS 2
tgv_irq_seen:
	DEFS 2
tgv_pace_acc:
	DEFS 2
tgv_qmode:
	DEFS 1
tgv_vsync:
	DEFS 1
q_count:
	DEFS 2
q_ptr:
	DEFS 2
q_buf:
	DEFS 2048
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

	xor a
	ld (tgv_qmode),a
	ld (tgv_vsync),a
	ld (q_count),a
	ld (q_count+1),a
	pop ix
	pop iy
	ret

; ===========================================================================
; decode (+ inlined blit)
; ===========================================================================
tgv_decode_sector:
	push iy				; IAR C: keep IX/IY; AF/BC/DE/HL free
	push ix
	ld iy,(secbase)
	ld de,(secpos)
	add iy,de
	ld ixh,FMV_SLOTS
	ei				; so the IRQ hook can see a field pass

dec_loop:
	ld a,(iy+0)
	inc iy
	ld ixl,a
	bit 7,a
	jr z,dec_do_chrx		; plain tile, the common case
	cp 0xff
	jp z,dec_end
	add a,a
	jp m,dec_do_chrx		; 11xxxxxx is still a tile
	ld a,(frame_open)
	or a
	jr z,dec_frame_mark
	call tgv_flip_sync
dec_frame_mark:
	ld a,1
	ld (frame_open),a

dec_do_chrx:
	ld a,ixl
	and 31
	ld c,a				; chry
	cp 24
	jr nc,dec_skip17
	ld a,(iy+0)			; chrx, IY not moved yet
	cp 36				; 4 columns of margin still fit in 40
	jr nc,dec_skip17
	inc iy
	add a,4				; (320-256)/8 = 4, 32 pixels each side
	add a,a
	add a,a				; chrx*4
	ld b,a
	ld a,ixl
	rlca
	rlca
	and 1				; bplane
	add a,b
	ld b,a				; pair
	ld h,HIGH ty40_lo
	ld l,c
	ld e,(hl)
	inc h				; ty40_hi is the next page
	ld d,(hl)
	ld h,HIGH tx_lo
	ld l,b
	ld a,(hl)
	add a,e
	ld e,a
	inc h				; tx_hi
	ld a,(hl)
	adc a,d
	ld h,a
	ld l,e				; HL=dst0
	ld (blit_dst0),hl
	ld e,iyl
	ld d,iyh			; DE=payload
	ld bc,16
	add iy,bc
dec_blit_sp:
	di				; SP-blit must not take the IRQ hook
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

	ld hl,(blit_dst0)
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
	ei
	jp dec_next

dec_skip17:
	ld bc,17			; chrx byte plus 16 of payload
	add iy,bc
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
	call tgv_flip_sync
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

; Preserves stream IX/IY. BDOS sees the C task IY.
tgv_switch_screen:
	push iy
	push ix
	ld a,(g_front)
	xor 1
	ld (g_front),a
	ld e,a
	ld iy,(task_iy_save)
	ld c,CMD_SETSCREEN
	call BDOS
	pop ix
	pop iy
	ret

; Show the finished buffer.
; If no IRQ landed while we were drawing, the beam is still in this
; field: HALT, then SETSCREEN in the top border. If an IRQ already
; landed, the frame ran long and we switch at once (no extra field).
tgv_flip:
tgv_flip_sync:
	ld hl,(tgv_frm_n)
	inc hl
	ld (tgv_frm_n),hl
	call tgv_pace_wait
	ld a,(tgv_flip_halt)
	or a
	jr z,sync_switch
	ld a,(tgv_vsync)
	or a
	jr nz,sync_consume
	ei
	halt
sync_consume:
	xor a
	ld (tgv_vsync),a
sync_switch:
	ld a,(tgv_hint)
	ld b,a
	ld a,(tgv_cover)
	or b
	call nz,tgv_mark_paint
	call tgv_switch_screen
	call tgv_map_back
	jp tgv_ev_poll

; Once per displayed frame, and only while a choice window is open.
; Outside that window this returns without touching the keyboard.
tgv_ev_poll:
	ld a,(tgv_ev_on)
	or a
	ret z
	ld a,(tgv_ev_fail)
	or a
	ret nz
	ld hl,(tgv_snd_n)
	ld de,(tgv_ev_open)
	or a
	sbc hl,de
	ret c
	ld hl,(tgv_snd_n)
	ld de,(tgv_ev_close)
	or a
	sbc hl,de
	jr z,ev_key
	jr c,ev_key
	ld a,(tgv_ev_hit)
	or a
	ret nz
	ld a,1
	ld (tgv_ev_fail),a
	xor a
	ld (tgv_ev_on),a
	ret

; Called from the script when the sound frame has moved past the window.
; The picture with the mark is still on screen: the key may be waiting.
tgv_ev_last:
	ld a,(tgv_ev_on)
	or a
	ret z
	ld a,(tgv_ev_hit)
	or a
	ret nz
	jp ev_key
ev_key:
	push ix
	push iy
	rst 0x08			; OS_GETKEY, key in A
	ld b,a
	cp 27				; Esc (space is the same code)
	jr z,ev_esc
	ld a,(tgv_ev_key)
	cp 1				; 1 = fire: Enter, 0 or m
	jr nz,ev_one
	ld a,b
	cp 13
	jp z,ev_yes
	cp '0'
	jp z,ev_yes
	cp 'm'
	jp z,ev_yes
	cp 'M'
	jp z,ev_yes
	jp ev_key_out
ev_esc:
	ld a,1
	ld (user_abort),a
	ld (tgv_ev_fail),a
	xor a
	ld (tgv_ev_on),a
	jp ev_restore
ev_one:
	ld d,a			; expected cursor code
	ld a,b
	call ev_canon
	cp d
	jp z,ev_yes
	or a
	jp nz,ev_key_out	; a different direction
	ld a,c			; key without the language shift
	call ev_canon
	cp d
	jp z,ev_yes
	or a
	jp nz,ev_key_out
	jp ev_restore		; not a direction, keep the window open

; A = raw key. Returns the cursor code, or 0 if this is not a direction.
; Original matrix: CS+5/6/7/8 and also O/P/Q/A (left/right/up/down).
ev_canon:
	cp 0xF8
	ret z
	cp 0xF9
	ret z
	cp 0xFA
	ret z
	cp 0xFB
	ret z
	cp 0xB5			; ext left
	jr nz,ev_c6
	ld a,0xF8
	ret
ev_c6:
	cp 0xB6			; ext down
	jr nz,ev_c8
	ld a,0xF9
	ret
ev_c8:
	cp 0xB8			; ext right
	jr nz,ev_c7
	ld a,0xFB
	ret
ev_c7:
	cp 0xB7			; ext up
	jr nz,ev_cq
	ld a,0xFA
	ret
ev_cq:
	cp 'q'
	jr z,ev_as_up
	cp 'Q'
	jr z,ev_as_up
	cp 0xA9			; ©
	jr z,ev_as_up
	cp 0x89			; ‰
	jr z,ev_as_up
	cp 'a'
	jr z,ev_as_down
	cp 'A'
	jr z,ev_as_down
	cp 0xE4			; ä
	jr z,ev_as_down
	cp 0x94			; ”
	jr z,ev_as_down
	cp 'o'
	jr z,ev_as_left
	cp 'O'
	jr z,ev_as_left
	cp 0xE9			; é
	jr z,ev_as_left
	cp 0x99			; ™
	jr z,ev_as_left
	cp 'p'
	jr z,ev_as_right
	cp 'P'
	jr z,ev_as_right
	cp 0xA7			; §
	jr z,ev_as_right
	cp 0x97			; ‡
	jr z,ev_as_right
	xor a
	ret
ev_as_up:
	ld a,0xFA
	ret
ev_as_down:
	ld a,0xF9
	ret
ev_as_left:
	ld a,0xF8
	ret
ev_as_right:
	ld a,0xFB
	ret
ev_yes:
	ld a,(tgv_hint)
	ld (tgv_cover),a
	xor a
	ld (tgv_hint),a
	ld a,1
	ld (tgv_ev_hit),a
	jr ev_restore
ev_key_out:
	ld a,b
	or a				; 0 = no key, keep waiting
	jr z,ev_restore
	ld a,1
	ld (tgv_ev_fail),a
	xor a
	ld (tgv_ev_on),a
ev_restore:
	pop iy
	pop ix
	jp tgv_map_back		; GETKEY may have moved the pages

; Hold the frame for the detected fps. tgv_pace_* set from C once
; a few sound blocks have been seen. 1024/175 ticks per sound block,
; shared across the frames in that block.
tgv_pace_wait:
	ld a,(tgv_pace_on)
	or a
	ret z
	ld a,(tgv_pace_ticks)
	ld c,a
	ld hl,(tgv_pace_acc)
	ld de,(tgv_pace_num)
	add hl,de
	ld de,(tgv_pace_den)
	ld a,d
	or e
	jr z,pace_no_extra
	push hl
	or a
	sbc hl,de
	pop hl
	jr c,pace_no_extra
	or a
	sbc hl,de
	inc c
pace_no_extra:
	ld (tgv_pace_acc),hl
pace_tick:
	ld a,c
	or a
	ret z
	ld hl,(tgv_irq_n)
	ld de,(tgv_irq_seen)
	or a
	sbc hl,de
	ld a,h
	or l
	jr z,pace_halt
	ld hl,(tgv_irq_seen)
	inc hl
	ld (tgv_irq_seen),hl
	dec c
	jr pace_tick
pace_halt:
	ei
	halt
	ld hl,(tgv_irq_seen)
	inc hl
	ld (tgv_irq_seen),hl
	dec c
	jr pace_tick

; C and asm. IX/IY preserved. Returns with EI.
tgv_qwait_flush:
	push ix
	push iy
	ld a,(tgv_vsync)
	or a
	jr nz,qwait_go
	ei
	halt
qwait_go:
	call tgv_qflush
	ei
	pop iy
	pop ix
	ret

; DI on return. Maps the hidden buffer, then writes queued tiles.
tgv_qflush:
	di
	xor a
	ld (tgv_qmode),a
	call tgv_map_back
	ld hl,q_buf
qflush_lp:
	ld a,(q_count)
	ld b,a
	ld a,(q_count+1)
	or b
	ret z
	ld e,(hl)
	inc hl
	ld d,(hl)
	inc hl
	ld c,(hl)
	inc hl
	ld b,(hl)
	inc hl
	push hl
	ld hl,(q_count)
	dec hl
	ld (q_count),hl
	ld h,d
	ld l,e
	ld d,b
	ld e,c
	call blit_queued
	pop hl
	jr qflush_lp

tgv_map_back:
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

; HL = dst0, DE = src. DI. Clobbers AF/BC/DE/HL.
blit_queued:
	ld (blit_dst0),hl
	ld (task_sp_save),sp
	ex de,hl
	ld sp,hl
	ex de,hl
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
	ld hl,(blit_dst0)
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
	ret

; User IRQ is push af/bc/de then ld a; out (#FD). Swap those 3 bytes
; with jp tgv_on_int. After the flag store, jp #003B enters the kernel.
tgv_int_hook:
	ld a,(tgv_hooked)
	or a
	ret nz
	push ix
	push iy
	call tgv_int_swap
	pop iy
	pop ix
	ld a,1
	ld (tgv_hooked),a
	xor a
	ld (tgv_vsync),a
	ret

tgv_int_unhook:
	ld a,(tgv_hooked)
	or a
	ret z
	push ix
	push iy
	call tgv_int_swap
	pop iy
	pop ix
	xor a
	ld (tgv_hooked),a
	ld (tgv_qmode),a
	ret

tgv_int_swap:
	di
	ld b,3
	ld de,0038h
	ld hl,tgv_oldimer
tgv_swap0:
	ld a,(de)
	ld c,a
	ld a,(hl)
	ld (de),a
	ld (hl),c
	inc hl
	inc de
	djnz tgv_swap0
	ei
	ret

tgv_on_int:
	push af
	push hl
	ld hl,(tgv_irq_n)
	inc hl
	ld (tgv_irq_n),hl
	pop hl
	ld a,1
	ld (tgv_vsync),a
	pop af
	jp tgv_oldimer

tgv_hooked:
	DEFB 0
tgv_oldimer:
	jp tgv_on_int
	jp 003Bh

	ENDMOD
	END
