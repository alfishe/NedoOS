
	MODULE term_paint
	PUBLIC term_putchar_stay
	#include "sysdefs.asm"
	RSEG CODE

; void term_putchar_stay(unsigned char ch);  E=ch
; Write at current cursor without advancing (avoids BDOS scroll on row 24 col 79).
term_putchar_stay:
	push bc
	push ix
	push iy
	ld d,0xff
	ld c,CMD_RESERV_1
	call BDOS
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD

	MODULE term_scroll
	PUBLIC term_scroll_up_n, term_scroll_down_n
	#include "sysdefs.asm"
	RSEG CODE

; void term_scroll_up_n(unsigned char count);  E=count
term_scroll_up_n:
	ld b,e
	or b
	ret z
tsu_loop:
	push bc
	ld de,0
	ld h,25
	ld l,80
	ld c,CMD_SCROLLUP
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop bc
	djnz tsu_loop
	ret

; void term_scroll_down_n(unsigned char count);  E=count
term_scroll_down_n:
	ld b,e
	or b
	ret z
tsd_loop:
	push bc
	ld de,0
	ld h,25
	ld l,80
	ld c,CMD_SCROLLDOWN
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop bc
	djnz tsd_loop
	ret
	ENDMOD

	MODULE term_palette
	PUBLIC term_set_ansi_palette, term_palette_save
	PUBLIC term_palette_begin, term_palette_restore
	#include "sysdefs.asm"
	RSEG CODE

term_palette_save:
	push ix
	push iy
	ld de,saved_pal
	ld c,CMD_GETPAL
	call BDOS
	pop iy
	pop ix
	ret

term_set_ansi_palette:
	push ix
	push iy
	ld de,ansi_pal
	ld c,CMD_SETPAL
	call BDOS
	pop iy
	pop ix
	ret

term_palette_begin:
	call term_palette_save
	jp term_set_ansi_palette

term_palette_restore:
	push ix
	push iy
	ld de,saved_pal
	ld c,CMD_SETPAL
	call BDOS
	pop iy
	pop ix
	ret

; Same as src/telnet/telnet.asm ansi_pal (original PC ANSI colours).
ansi_pal:
	DEFB 0F3h,0F3h,0F1h,0F1h,0E3h,0E3h,0E1h,0E1h
	DEFB 0F2h,0F2h,0F0h,0F0h,0E2h,0E2h,0E0h,0E0h
	DEFB 013h,013h,0B1h,0B1h,063h,063h,021h,021h
	DEFB 0D2h,0D2h,090h,090h,042h,042h,000h,000h

saved_pal:
	DEFS 32,0
	ENDMOD

	END
