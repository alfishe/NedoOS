swapimer
	di
        ld de,0x0038
        ld hl,oldimer
        ld bc,3
swapimer0
        ld a,(de)
        ldi ;[oldimer] -> [0x0038]
        dec hl
        ld (hl),a ;[0x0038] -> [oldimer]
        inc hl
        jp pe,swapimer0
	ei
        ret
oldimer
        jp on_int ;заменится на код из 0x0038
        jp 0x0038+3

on_int
       if INT_USE_BC
;restore stack with bc
        ld (on_int_hl),hl
        pop hl
        push bc
	LD (on_int_jp),HL
	LD (on_int_sp),SP
	LD SP,INTSTACK
        push af
        push de
       else
;restore stack with de
        EX DE,HL
	EX (SP),HL ;de="hl", в стеке "de"
	LD (on_int_jp),HL
	LD (on_int_sp),SP
	LD SP,INTSTACK
        push af
        push bc
        push de ;"hl"
       endif
        exx
        ex af,af' ;'
        push af
        push bc
        push de
        push hl
        push ix
        push iy

curscrnum_int=$+1
        ld e,0
        OS_SETSCREEN
        
        call oldimer ;ei ;а что если выйдем поздно (по yield)? надо в конце обработчика убрать ei, но и это не поможет, т.к. yield сейчас с включенными прерываниями!!!
        di
        
       if 1==0
        GET_KEY
        ld a,c ;кнопка без учёта языка
        or a
        jr z,$+5
        ld (curkey),a
        OS_GETKEYMATRIX
	rr c ;'a'
	rla ;A
	rr c ;'s'
	rla ;B
	ld c,lx
	rr c ;'Space'
	rla ;Select
	ld c,hx
	rr c ;'Enter'
	rla ;Start
	add a,a
	bit 3,h ;7
	jr z,$+3
	inc a ;Up
	add a,a
	bit 4,h ;6
	jr z,$+3
	inc a ;Down
	add a,a
	bit 4,e ;5
	jr z,$+3
	inc a ;Left
	add a,a
	bit 2,h ;8
	jr z,$+3
	inc a ;Right
        cpl 
        ld (joystate),a
;bit - button (ZX key)
;7 - A (A)
;6 - B (S)
;5 - Select (Space)
;4 - Start (Enter)
;3 - Up (7)
;2 - Down (6)
;1 - Left (5)
;0 - Right (8) 
       endif
        ld a,(curpg4000) ;ok
        push af
        ld a,(curpg8000) ;ok
        push af
        ;ld a,(curpgc000) ;ok
        ;push af
       call setpgsmain40008000
	call IMS ;ваш обработчик прерываний (не забывайте сохранить CURPG...)
        ;pop af
        ;SETPG32KHIGH
        pop af
        SETPG8000
        pop af
        SETPG4000

        ;ld hl,timer
        ;inc (hl)

        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
       if INT_USE_BC
on_int_hl=$+1
        ld hl,0
        pop de
        pop af        
on_int_sp=$+1
	ld sp,0
        pop bc
       else
        pop hl
        pop bc
        pop af        
on_int_sp=$+1
	ld sp,0
        pop de
       endif
	ei
on_int_jp=$+1
	jp 0

;timer
        ;db 0
