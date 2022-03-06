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

;curscrnum_int=$+1
        ;ld e,1;0
;        OS_SETSCREEN
        
        call oldimer ;ei ;а что если выйдем поздно (по yield)? надо в конце обработчика убрать ei, но и это не поможет, т.к. yield сейчас с включенными прерываниями!!!
        
       if 0
        ld bc,0x7ffe
        in a,(c)
        ld lx,a  ;lx=%???bnmS_
        ld b,0xbf
        in a,(c)
        ld hx,a  ;hx=%???hjklE
        ld b,0xdf
        in l,(c)  ;l=%???yuiop
        ld b,0xef
        in h,(c)  ;h=%???67890
        ld b,0xf7
        in e,(c)  ;e=%???54321
        ld b,0xfb
        in d,(c)  ;d=%???trewq
        ld a,0xfd
        in a,(0xfe);c=%???gfdsa
        ld b,c;0xfe
        in b,(c)  ;b=%???vcxzC
        ld c,a
       else
        OS_GETKEYMATRIX ;out: bcdehlix = halfrows cs...space
       endif
        ld (keymatrix),ix
        ld (keymatrix+2),hl
        ld (keymatrix+4),de
        ld (keymatrix+6),bc

	;CALL .. ;ваш обработчик прерываний (не забывайте сохранить CURPG...)
        ;ld a,(curpg16k) ;ok
        ;SETPG16K
        ;ld a,(curpg32klow) ;ok
        ;SETPG32KLOW
        ;ld a,(curpg32khigh) ;ok
        ;SETPG32KHIGH

	;LD HL,SEED
	;INC (HL)
	;JR NZ,$+4
	; INC HL
	; INC (HL)
        call INT_PROC

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
