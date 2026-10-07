; GS ports: command 0xBB, data 0xB3.
; A command argument is written and then the command is sent. The card
; reads that byte inside the command. Waiting for bit 7 before the
; command never ends: nothing is reading the latch yet, the wait times
; out, and every later call gives up. That is what followed the reset
; click.
; Stream bytes are the other way round. #38 enters the loader, and each
; byte is written only once bit 7 is clear.
;
; #38 stores one unsigned sample (silence is 0x80). The ROM gives it
; note 60, volume 0x40 and all four channels, and #39 plays it.
; The ROM keeps only 60 samples. A warm reset clears that list, but it
; also stalls the player, so it is done every 48 blocks rather than
; before each one.

	MODULE gs_pcm
	PUBLIC gs_pcm_init
	PUBLIC gs_pcm_play
	PUBLIC gs_pcm_stop

GS_CMD	EQU	0BBh
GS_DAT	EQU	0B3h
GS_KEEP	EQU	48

	RSEG UDATA0
gs_ok:		DEFS 1
gs_n:		DEFS 1
gs_handle:	DEFS 1

	RSEG CODE

; A=1 if the card finished its memory test.
gs_pcm_init:
	push ix
	push iy
	xor a
	ld (gs_ok),a
	ld (gs_n),a
	call gs_getdat
	in a,(GS_CMD)
	and 129
	jr nz,init_done
	ld a,0F4h
	call gs_sendcmd
	jr c,init_done
	ld b,64
init_wait:
	in a,(GS_DAT)
	or a
	jr nz,init_vol
	ld hl,0
init_spin:
	dec hl
	ld a,h
	or l
	jr nz,init_spin
	djnz init_wait
	jr init_done
init_vol:
	ld a,40h
	call gs_senddatnv
	ld a,2Bh
	call gs_sendcmd
	jr c,init_done
	ld a,1
	ld (gs_ok),a
init_done:
	ld a,(gs_ok)
	pop iy
	pop ix
	ret

; DE=sample, BC=length. Unsigned bytes, as #38 stores them.
gs_pcm_play:
	push ix
	push iy
	ld a,(gs_ok)
	or a
	jp z,play_out
	ld a,(gs_n)
	cp GS_KEEP
	jr c,play_new
	xor a
	ld (gs_n),a
	ld a,0F3h
	call gs_sendcmd
	jp c,play_out
play_new:
	push de
	push bc
	ld a,38h
	call gs_sendcmd
	jr c,play_drop
	call gs_getdat
	ld (gs_handle),a
	pop bc
	pop hl
play_lp:
	ld a,b
	or c
	jr z,play_end
	ld a,(hl)
	call gs_senddat
	jr c,play_out
	inc hl
	dec bc
	jr play_lp
play_end:
	ld a,0D2h
	call gs_sendcmd
	jr c,play_out
	ld a,(gs_handle)
	call gs_senddatnv
	ld a,39h
	call gs_sendcmd
	jr c,play_out
	ld hl,gs_n
	inc (hl)
	jr play_out
play_drop:
	pop bc
	pop de
play_out:
	pop iy
	pop ix
	ret

gs_pcm_stop:
	push ix
	push iy
	ld a,(gs_ok)
	or a
	jr z,stop_out
	ld a,0FFh
	call gs_senddatnv
	ld a,3Ah
	call gs_sendcmd
stop_out:
	pop iy
	pop ix
	ret

gs_senddatnv:
	out (GS_DAT),a
	ret

gs_getdat:
	in a,(GS_DAT)
	ret

; OUT (0xBB), A, then wait until bit 0 clears. Carry = timeout.
; HL is the caller's pointer: the wait must not keep it.
gs_sendcmd:
	push hl
	out (GS_CMD),a
	ld hl,8000h
sendcmd_lp:
	in a,(GS_CMD)
	and 1
	jr z,sendcmd_ok
	dec hl
	ld a,h
	or l
	jr nz,sendcmd_lp
	pop hl
	jr gs_fail
sendcmd_ok:
	pop hl
	ret

; OUT (0xB3), A, then wait until bit 7 clears. Carry = timeout.
gs_senddat:
	push hl
	out (GS_DAT),a
	ld hl,2000h
senddat_lp:
	in a,(GS_CMD)
	and 128
	jr z,senddat_ok
	dec hl
	ld a,h
	or l
	jr nz,senddat_lp
	pop hl
	jr gs_fail
senddat_ok:
	pop hl
	ret

gs_fail:
	xor a
	ld (gs_ok),a
	scf
	ret

	ENDMOD
	END
