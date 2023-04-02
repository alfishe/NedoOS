	MODULE OS_STDIO
	PUBLIC initstdio, receivekey, sendchar, sendchars
	PUBLIC yieldgetkeyloop
	#include "sysdefs.asm"
	RSEG CODE
	#include "stdio.asm"
	ENDMOD
	
	MODULE OS_INITSTDIO
	PUBLIC os_initstdio
	EXTERN initstdio
	RSEG CODE
os_initstdio
	push bc
	push de
	push ix
	push iy
	call initstdio
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE TTYGETKEY
	PUBLIC ttygetkey
	EXTERN receivekey,exit
	#include "sysdefs.asm"
	RSEG CODE
ttygetkey
	push bc
	push de
	push ix
	push iy
	ld c,CMD_YIELD
	call BDOS
	call receivekey
	cp key_esc
	ld de,0
	jp z,exit
	ld l,a
	ld h,0
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD

	MODULE TTYGETKEY_NE
	PUBLIC ttygetkey_ne
	EXTERN receivekey,exit
	#include "sysdefs.asm"
	RSEG CODE
ttygetkey_ne
	push bc
	push de
	push ix
	push iy
	ld c,CMD_YIELD
	call BDOS
	call receivekey
;	cp key_esc
;	ld de,0
;	jp z,exit
	ld l,a
	ld h,0
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE TTYPUTCHAR
	PUBLIC ttyputchar
	EXTERN sendchar
	RSEG CODE
ttyputchar
	push bc
	push de
	push ix
	push iy
	ld a,e
	call sendchar
	pop iy
	pop ix
	pop de
	pop bc
	ret
	ENDMOD
	
	MODULE TTYGETS
	PUBLIC ttygets,bs_loop
	EXTERN yieldgetkeyloop,exit,sendchars
	EXTERN sendchar
	#include "sysdefs.asm"
	RSEG CODE
ttygets
	xor a
	ld (de),a
	ld (str_begin),de
	push bc
	push ix
	push iy
main_loop
	push de
main_loop1
	call yieldgetkeyloop
	or a
	jr z,main_loop1
	pop de
	cp key_esc
	jp z,exit
	cp key_enter
	jr nz,no_enter
	ld de,str_rn
	ld hl,2
	call sendchars
str_begin=$+1
	ld hl,0
	pop iy
	pop ix
	pop bc
	ret
str_rn
	DEFB '\r\n'
no_enter
	cp key_left
	jr nz,no_left
	ld hl,(str_begin)
	sbc hl,de
	jr z,main_loop
	dec de
left_1
	push de
	ld hl,3
	ld de,csi_left
	call sendchars
	jr main_loop1
csi_left
	DEFB '\x1b[D'
no_left	
	cp key_right
	jr nz,no_right
	ld a,(de)
	or a
	jr z,main_loop
right_1
	inc de
	push de
	ld hl,3
	ld de,csi_right
	call sendchars
	jr main_loop1
csi_right
	DEFB '\x1b[C'
no_right
	cp extH
	jr nz,no_backspace
	ld hl,(str_begin)
	sbc hl,de
	jr z,main_loop
	push de
	ld hl,3
	ld de,csi_left
	call sendchars
	pop de
	ld b,d
	ld c,e
	dec de
	ld h,d
	ld l,e
bs_loop
	ld a,(bc)
	ld (hl),a
	inc bc
	inc hl
	or a
	jr nz,bs_loop
	sbc hl,de
	call puts_w_restore
	jp main_loop
no_backspace
	cp 0xfc
	jr nz,no_del
	ld b,d
	ld c,e
	ld h,d
	ld l,e
	inc bc
del_loop
	ld a,(bc)
	ld (hl),a
	inc bc
	inc hl
	or a
	jr nz,del_loop
	sbc hl,de
	call puts_w_restore
	jp main_loop
no_del
	ld (store_ch),a
	ld h,d
	ld l,e
	ld a,(hl)
sh_right
	inc hl
	ld b,(hl)
	ld (hl),a
	or a
	ld a,b
	jr nz,sh_right
store_ch=$+1
	ld a,0
	ld (de),a
	sbc hl,de
	call puts_w_restore
	jr right_1
	
puts_w_restore
	push de
	ld (pw_size),hl
	ld hl,3
	ld de,csi_save_cursor
	call sendchars
	pop de
	push de
pw_size=$+1
	ld hl,0
	call sendchars
	ld hl,4
	ld de,csi_rest_cursor
	call sendchars
	pop de
	ret
csi_save_cursor
	DEFB '\x1b[s'
csi_rest_cursor
	DEFB ' \x1b[u'
	ENDMOD
	
	MODULE TTYPUTS
	PUBLIC ttyputs
	EXTERN sendchars,sendchar
	RSEG CODE
ttyputs
	push bc
	push ix
	push iy
	ld h,d
	ld l,e
	xor a
	ld b,a
	ld c,a
	cpir
	xor a
	sbc hl,de
	dec hl
	call sendchars
	ld a,'\r'
	call sendchar
	ld a,'\n'
	call sendchar
	pop iy
	pop ix
	pop bc
	ld hl,0x0000
	ret
	ENDMOD
	
	MODULE TTY_PUTF
	PUBLIC putf
	EXTERN sendchars,sendchar
	RSEG CODE
putf
	push bc
	push ix
	push iy
	ld h,d
	ld l,e
	xor a
	ld b,a
	ld c,a
	cpir
	xor a
	sbc hl,de
	dec hl
	push hl
	call sendchars
	pop hl
	pop iy
	pop ix
	pop bc
	ret
	ENDMOD
	
	MODULE TTY_PUTCSI
	PUBLIC putcsi
	EXTERN sendchars,sendchar
	RSEG CODE
putcsi2
	ld hl,4
	jr $+3
putcsi
	ld hl,3
	push bc
	push ix
	push iy
	ld (csi+2),de
	ld de,csi
	call sendchars
	pop iy
	pop ix
	pop bc
	ld hl,0x0000
	ret
csi DEFB 0x1b,'[',0,0,0,0
	ENDMOD

	MODULE PUTN
	PUBLIC printn
	EXTERN sendchars
	RSEG CODE
printn
	push ix
	push iy
	ld h,b
	ld l,c
	call sendchars
	pop iy
	pop ix
	ret
	END