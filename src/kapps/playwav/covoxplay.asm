
	MODULE COVOXPLAY
	PUBLIC covox_hx
	PUBLIC covox_play
	EXTERN pagetable
	#include "sysdefs.asm"
	RSEG CODE

covox_hx:
	DEFB 0

;void covox_play(void);
;BDOS: HL=0xC000, DE=pagetable, HX=delay.
;Evo: ld hx,d is real but undoc Z80; IAR az80 has no "hx" mnemonic.
;Same opcode DD 62: use ld ixh,d after putting delay into D (see lib_sound.asm).
covox_play:
	push ix
	push iy
	ld a,(curpgc000)
	push af
	ld a,(covox_hx)
	or a
	jr z,covox_done
	ld d,a
	ld ixh,d		; ld hx,d
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
