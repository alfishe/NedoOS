        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

INTSTACK=0x3800

        org PROGSTART
begin
        ;ld ix,(1<<9)+(2<<5)+12
        ;ld hl,(7<<11)+(34<<5)+(23/2) ;ix=date, hl=time
        ;OS_SETTIME

        ;ld e,6 ;textmode
        ;OS_SETGFX
        call initstdio
        ld hl,tfreetime
        call prtext

        halt
        call swapimer

        ld de,0
        ld hl,timeloopq
        ds 0x200-1-$
        halt ;quit to timeloop
timeloop
        ld (on_int_q),hl
        ds 256-4-4
        inc de
        jp timeloop
timeloopq
;d,e,c=NOPs
        ld l,c
        ld h,e
        ld e,d
        ld d,0
;dehl=NOPs
        ;ld de,0
        ;ld hl,12345
        call prdword_dehl
        
        call yieldgetkeyloop
        
        call swapimer

        QUIT

prtext
;hl=text
        push hl
        call strlen ;hl=length
        pop de ;de=text
        jp sendchars

strlen
;hl=str
;out: hl=length
        xor a
        ld b,a
        ld c,a ;чтобы точно найти терминатор
        cpir ;найдём обязательно, если длина=0, то bc=-1 и т.д.
        ld hl,-1
        or a
        sbc hl,bc
        ret

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

        call oldimer ;ei ;а что если выйдем поздно (по yield)? надо в конце обработчика убрать ei, но и это не поможет, т.к. yield сейчас с включенными прерываниями!!!      

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
	ld bc,0;jp 0
on_int_q=$+1
        jp timeloop ;/timeloopq

tfreetime
        db "Free time with generic user INT handler (NOPs)=",0
        
        include "../_sdk/stdio.asm"
        include "../_sdk/prdword.asm"
end
	savebin "freetime.com",begin,end-begin

	LABELSLIST "../../us/user.l",1
