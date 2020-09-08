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
	;EX DE,HL
	;POP DE
	LD (on_int_sp),SP
	LD SP,INTSTACK        
        push af
        push bc
        push de ;"hl"
        exx
        ex af,af'
        push af
        push bc
        push de
        push hl
        push ix
        push iy

        call oldimer

        GET_KEY
        ld a,c ;кнопка без учёта языка
        or a
        jr z,$+5
        ld (curkey),a
	;CALL .. ;ваш обработчик прерываний
        ld a,(curpg16k) ;ok
        SETPG16K
        ld a,(curpg32klow) ;ok
        SETPG32KLOW
        
        pop iy
        pop ix
        pop hl
        pop de
        pop bc
        pop af
        ex af,af'
        exx
        pop hl
        pop bc
        pop af
on_int_sp=$+1
	ld sp,0
        pop de
	EI
on_int_jp=$+1
	jp 0
