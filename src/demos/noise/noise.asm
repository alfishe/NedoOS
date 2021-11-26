        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

INTSTACK=0x3f00
STACK=0x4000
scrbase=0x8000

music=0x4000

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

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,h
        ld (pg16c0),a
        ld a,l
        ld (pg16c1),a
        ld a,e
        LD (pgmusic),A

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,e
        ;ld (setpgs_scr0_low),a
	;ld a,d
        ;ld (setpgs_scr0_high),a
        ;ld a,l
        ;ld (setpgs_scr1_low),a
	;ld a,h
        ;ld (setpgs_scr1_high),a

        ld a,(pg16c0)
        SETPG4000        
        ld de,bmpfilename
        OS_OPENHANDLE
        push bc
        ld de,0x4000
        ld hl,0x4000
        OS_READHANDLE
        ld a,(pg16c1)
        SETPG4000        
        pop bc
        push bc
        ld de,0x4000
        ld hl,0x4000
        OS_READHANDLE
        pop bc
        push bc
        ld hl,32
        ld de,palbuf16c
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
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
        SETPG4000
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

        call setpgmusic
        ld hl,wasmusic
        ld de,music
        ld bc,sz_music
        ldir

        ld hl,module
        call INIT

        ld a,(pgmusic)
        ld hl,PLAY
        OS_SETMUSIC

        call swapimer
MUSICPATTERNSIZE=256;192
        OS_GETTIMER
        ld (oldtimer),de

showpic_mainloop

showpic0
        call setpgs_scr0       
        call showpic
        ld de,palbuf
        OS_SETPAL
        call halt_testquit
        ld e,0
        OS_SETSCREEN

        call setpgs_scr1
        call showpic
        call halt_testquit
        ld e,1
        OS_SETSCREEN
        
        call gettimer        
        ld bc,MUSICPATTERNSIZE
        or a
        sbc hl,bc
        jr c,showpic0
        call settimer

        call setpgs_scr0       
        call showpic16c
        ld de,palbuf16c
        OS_SETPAL
        call halt_testquit
        ld e,0
        OS_SETSCREEN

        call setpgs_scr1
        call showpic16c
        call halt_testquit
        ld e,1
        OS_SETSCREEN

showpic1
        call gettimer        
        ld bc,MUSICPATTERNSIZE
        or a
        sbc hl,bc
        jr c,showpic1
        call settimer
        
        jr showpic_mainloop
quit
        call swapimer

	  ld a,(pgmusic)
	  ld hl,MUTE
	  OS_SETMUSIC 
          halt
        ;call setpgmusic
        ;call MUTE
        QUIT

halt_testquit
        YIELDGETKEY ;out: nz=nokey, a=keylang, c=keynolang
        cp key_esc
        jr z,quit
        ret

gettimer
        ;ld hl,(timer)
        OS_GETTIMER
        ex de,hl
oldtimer=$+1
        ld de,0
        ld (oldtimer),hl
        or a
        sbc hl,de ;hl=time delta
mytimer=$+1
        ld de,0
        add hl,de
settimer
        ;ld (timer),hl
        ld (mytimer),hl
        ret

pg16c0
        db 0
pg16c1
        db 0

showpic
showpiccurpgpoi=$+1
        ld hl,ttexpgs
        ld de,0x8000
        call ldirpg
        call ldirpg       
        res 5,l
        ld (showpiccurpgpoi),hl
        ret

showpic16c
        ld de,0x8000
        ld a,(pg16c0)
        call ldirpg_a
        ld a,(pg16c1)
        call ldirpg_a
        ret

setpgmusic
pgmusic=$+1
        ld a,0
        SETPG4000
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
	ld (on_int_hl),hl
	ld (on_int_sp),sp
	pop hl
	ld (on_int_sp2),sp
        ld (on_int_jp),hl
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
        ex af,af' ;'
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
        
        call oldimer ;ei
        
        pop hl
        pop de
        pop bc
        pop af
        exx
        ex af,af' ;'
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
        ;ei
on_int_jp=$+1
	jp 0

setpgs_scr0
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok
        SETPG32KHIGH
        ret

setpgs_scr1
        ld a,(user_scr1_low) ;ok
        SETPG32KLOW
        ld a,(user_scr1_high) ;ok
        SETPG32KHIGH
        ret

ldirpg
        ld a,(hl)
        inc l
ldirpg_a
        SETPG4000
        push hl
        ld hl,0x4000
        ld bc,0x4000
        ldir
        pop hl
        ret

texfilename
        db "noise/forest.dat",0
bmpfilename
        db "noise/forest.16c",0

palbuf
        ds 32
palbuf16c
        ds 32

;timer
;        dw 0
        
        align 256
ttexpgs
        ds 32

wasmusic
        disp music
        include "ptsplay.asm"
module
        incbin "NOISE20.pt3"
        ent
sz_music=$-wasmusic

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "noise.com",begin,end-begin
