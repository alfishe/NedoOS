	MODULE OS_PRATTR
	PUBLIC OS_PRATTR
	EXTERN _OS_GFX_CALL
	#include "sysdefs.asm"
	RSEG CODE
OS_PRATTR:
	push bc
	ld c,CMD_PRATTR
	jp _OS_GFX_CALL
	ENDMOD
	
	MODULE OS_GETATTR
	PUBLIC OS_GETATTR
	EXTERN _OS_GFX_CALL
	#include "sysdefs.asm"
	RSEG CODE
OS_GETATTR:
	push bc
	ld c,CMD_GETATTR
	jp _OS_GFX_CALL
	ENDMOD
	
	MODULE OSSETXY
	PUBLIC OS_SETXY,OS_SCROLLUP,OS_SCROLLDOWN
	PUBLIC OS_SCROLL_SCREEN_UP,OS_SCROLL_SCREEN_DOWN
	PUBLIC panel_files_scroll_up,panel_files_scroll_down
	PUBLIC _OS_GFX_CALL,OS_SETXYW
	#include "sysdefs.asm"
	RSEG CODE
OS_SCROLLUP:
	push bc
	ld h,b
	ld l,c
	ld c,CMD_SCROLLUP
	jr label1
OS_SCROLLDOWN:
	push bc
	ld h,b
	ld l,c
	ld c,CMD_SCROLLDOWN
	jr label1
OS_SETGFX:
	push bc
	ld c,CMD_SETGFX
	jr label1
OS_CLS:
	push bc
	ld c,CMD_CLS
	jr label1
OS_SETXYW:
	push bc
    jr os_setxyw1
OS_SETXY:
	push bc
	ld d,c
os_setxyw1
	ld c,CMD_SETXY	;de=yx ;SET CURSOR POSITION
_OS_GFX_CALL
label1:
	push ix
	push iy
	call BDOS
	pop iy
	pop ix
	pop bc
	ret

; void panel_files_scroll_down(unsigned char start_x); E=start_x (0 or 40)
; BDOS scroll: DE=topyx (x even), BC=hgt,wid (even) — same as nv.asm
panel_files_scroll_down:
	ld a,e
	ld e,a
	ld d,3
	ld b,18
	ld c,40
	jp OS_SCROLLDOWN

; void panel_files_scroll_up(unsigned char start_x); E=start_x
panel_files_scroll_up:
	ld a,e
	ld e,a
	ld d,3
	ld b,18
	ld c,40
	jp OS_SCROLLUP

; void OS_SCROLL_SCREEN_UP(unsigned char count); full 80x25 text screen
OS_SCROLL_SCREEN_UP:
	ld b,e
	or b
	ret z
ossu_loop:
	push bc
	xor a
	ld d,a
	ld e,a
	ld b,25
	ld c,80
	call OS_SCROLLUP
	pop bc
	djnz ossu_loop
	ret

; void OS_SCROLL_SCREEN_DOWN(unsigned char count);
OS_SCROLL_SCREEN_DOWN:
	ld b,e
	or b
	ret z
ossd_loop:
	push bc
	xor a
	ld d,a
	ld e,a
	ld b,25
	ld c,80
	call OS_SCROLLDOWN
	pop bc
	djnz ossd_loop
	ret
	ENDMOD
	
	MODULE OSGETXY
	PUBLIC OS_GETXY
	#include "sysdefs.asm"
	RSEG CODE
OS_GETXY:
	push bc
	push de
	ld c,CMD_GETXY	;de=yx ;GET CURSOR POSITION
	push ix
	push iy
	call BDOS
	ex de,hl
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE BDOSPUTS
	PUBLIC bdosputs
	RSEG CODE
bdosputs:
	push ix
	push iy
	push de
ploop:
	pop hl
	ld a,(hl)
	or a
	jr z,pexit
	inc hl
	push hl
	rst 0x10
	jr ploop
pexit:
	ld a,'\r'
	rst 0x10
	ld a,'\n'
	rst 0x10
	ld hl,0x0000
	pop iy
	pop ix
	ret
	ENDMOD
		
	MODULE BDOSPRINT
	PUBLIC print
	RSEG CODE
print:
    push bc
	push ix
	push iy
	push de
ploop:
	pop hl
	ld a,(hl)
	or a
	jr z,pexit
	inc hl
	push hl
	rst 0x10
	jr ploop
pexit:
	pop iy
	pop ix
    pop bc
	ret
	ENDMOD
	
	MODULE BDOSPRCHAR
	PUBLIC bdosputchar
	RSEG CODE
bdosputchar:
    push bc
	push de
	push ix
	push iy
	ld a,e
	rst 0x10
	pop iy
	pop ix
	pop de
    pop bc
	ret
	END
