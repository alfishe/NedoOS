        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

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
        QUIT

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
        db "forest.dat"

palbuf
        ds 32

;oldtimer
;        dw 0
        
        align 256
ttexpgs
        ds 32

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "noise.com",begin,end-begin
