        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

INTSTACK=0x3f00
STACK=0x4000
scrbase=0x8000

        org PROGSTART
begin
        ld sp,STACK

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr0_low),a
	ld a,d
        ld (setpgs_scr0_high),a
        ld a,l
        ld (setpgs_scr1_low),a
	ld a,h
        ld (setpgs_scr1_high),a

        ld de,texfilename
        OS_OPENHANDLE

        ld hl,ttexpgs
        ld c,32
getttexpgs0
        push bc
        push hl

        push bc
        OS_NEWPAGE
        ld a,e
        SETPG16K
        pop bc        
        push de
        ld de,0x4000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE        
        pop de
        
        pop hl
        ld (hl),e
        inc hl
        pop bc
        dec c
        jr nz,getttexpgs0

        OS_CLOSEHANDLE

        ld hl,0x4000+0x1f40
        ld de,palbuf
        ld b,16
copypal0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        ld (de),a
        inc de
        djnz copypal0
        ld de,palbuf
        OS_SETPAL

        ld hl,module
        call INIT

        call swapimer

        ld hl,ttexpgs
showpic0
        call setpgs_scr0
        ld de,0x8000
        call ldirpg
        call ldirpg       
        push hl
        YIELD
        ld e,0
        OS_SETSCREEN
        pop hl
        call setpgs_scr1
        ld de,0x8000
        call ldirpg
        call ldirpg       

        push hl
        YIELDGETKEY ;out: nz=nokey, a=keylang, c=keynolang
        push af
        ld e,1
        OS_SETSCREEN
        pop af
        pop hl
        res 5,l
        cp key_esc
        jr nz,showpic0
        
        call MUTE
        call swapimer
        QUIT

swapimer
	di
         ld hl,(0x0038+3) ;адрес intjp
         ld (intjpaddr),hl        
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

on_int
;restore stack with de
	ld (on_int_hl),hl
	ld (on_int_sp),sp
	pop hl
	ld (on_int_sp2),sp
intjpaddr=$+1
	ld (0),hl ;(on_int_jp),hl
	
	ld sp,INTSTACK
	
	push af
	push bc
	push de
	
;imer_curscreen_value=$+1
         ;ld a,0
         ;ld bc,0x7ffd
         ;out (c),a

	ex de,hl;ld hl,0
on_int_sp=$+1
	ld (0),hl ;восстановили запоротый стек
        
        push ix
        push iy
        ex af,af'
        exx
        push af
        push bc
        push de
        push hl
        ;ld a,(curscreen)
        ;ld e,a
        ;OS_SETSCREEN ;вызываем здесь, а не в рандомном месте, иначе даже с одной задачей можем получить непредсказуемую задержку, которую не фиксирует наш таймер? с несколькими задачами надо учитывать и системный - TODO
;curpalette=$+1
        ;ld de,wolfpal
        ;OS_SETPAL
;        GET_KEY
;        ld (curkey),a
        
;pgmuznum=$+1
;        ld a,0
;        SETPG32KHIGH
        call PLAY ;muzplay
;pgc000=$+1
;        ld a,0
;        SETPG32KHIGH
        
        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af,af'
        pop iy
        pop ix
        
	;ld hl,(timer)
	;inc hl
	;ld (timer),hl

	pop de
	pop bc
	pop af
	
on_int_hl=$+1
	ld hl,0
on_int_sp2=$+1
	ld sp,0
;        ei
;on_int_jp=$+1
;	jp 0

        push de
        ex de,hl
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        jp 0x0038+5

;вход в стандартный обработчик:
        ;ex de,hl ;de="hl", hl="de"
        ;ex (sp),hl ;hl=адрес выхода, de="hl", в стеке "de"
        ;ld (intjp),hl ;TODO писать не прямо в intjp, а в промежуточную локацию (иначе хвост обработчика нельзя с ei - он сам не может сменить режим обработки прерывания после jp)
;(intjp)=адрес выхода
;de="hl", в стеке "de"
        ;ld l,a
;user_fdvalue6=$+1
        ;ld a,fd_system
        ;out (0xfd),a ;10 b

setpgs_scr0
setpgs_scr0_low=$+1
        ld a,0
        SETPG32KLOW
setpgs_scr0_high=$+1
        ld a,0
        SETPG32KHIGH
        ret

setpgs_scr1
setpgs_scr1_low=$+1
        ld a,0
        SETPG32KLOW
setpgs_scr1_high=$+1
        ld a,0
        SETPG32KHIGH
        ret

ldirpg
        ld a,(hl)
        inc l
        SETPG16K
        push hl
        ld hl,0x4000
        ld bc,0x4000
        ldir
        pop hl
        ret

texfilename
        db "noise/forest.dat"

palbuf
        ds 32

;oldtimer
;        dw 0
        
        align 256
ttexpgs
        ds 32

        include "ptsplay.asm"
module
        incbin "NOISE20.pt3"

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "noise.com",begin,end-begin
