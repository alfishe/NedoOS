
	MODULE OSPLAYCOVOXPLAY
	PUBLIC OS_PLAYCOVOX_PLAY_CORE
	PUBLIC os_covox_play_hx
	PUBLIC os_covox_play_data
	PUBLIC os_covox_play_pt
	#include "sysdefs.asm"
	RSEG CODE

;Globals filled by OS_PLAYCOVOX_PLAY() in covoxplay.c before CORE call.
os_covox_play_hx:
	DEFB 0
os_covox_play_data:
	DEFS 2
os_covox_play_pt:
	DEFS 2

;void OS_PLAYCOVOX_PLAY_CORE(void);
;BDOS: HL=data, DE=pagetable, HX=delay. Restores curpgc000 (rst 0x28).
OS_PLAYCOVOX_PLAY_CORE:
	push ix
	push iy
	ld a,(curpgc000)
	push af
	ld a,(os_covox_play_hx)
	or a
	jr z,os_covox_play_done
	ld d,a
	ld ixh,d		; ld hx,d
	ld ixl,0
	ld hl,(os_covox_play_data)
	ld de,(os_covox_play_pt)
	ld c,CMD_PLAYCOVOX
	call BDOS
os_covox_play_done:
	pop af
	ld e,a
	rst 0x28
	pop iy
	pop ix
	ret
	ENDMOD

	END
