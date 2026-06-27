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
;restore stack with de
        EX DE,HL
	EX (SP),HL ;de="hl", в стеке "de"
	LD (on_int_jp),HL
	LD (on_int_sp),SP
	LD SP,INTSTACK
        push af
        push bc
        push de ;"hl"
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

        ld a,(curpg32khigh) ;ok
        push af
        ld a,(curpg32klow) ;ok
        push af
        ld a,(curpg16k) ;ok
        push af

	CALL ON_INT ;ваш обработчик прерываний (не забывайте сохранить CURPG...)

        pop af ;ld a,(curpg16k) ;ok
        SETPG16K
        pop af ;ld a,(curpg32klow) ;ok
        SETPG32KLOW
        pop af ;ld a,(curpg32khigh) ;ok
        SETPG32KHIGH

        ld hl,timer
        inc (hl)

        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af' ;'
        exx
        pop hl
        pop bc
        pop af        
on_int_sp=$+1
	ld sp,0
        pop de
	ei
on_int_jp=$+1
	jp 0

timer
        db 0
