        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

INTSTACK=0x3f00
STACK=0x4000
scrbase=0x8000

music=0x4000


        org PROGSTART
begin
        ld sp,STACK

        OS_HIDEFROMPARENT
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
        ld de,palbufATM3
        OS_READHANDLE
        
        ld hl,palbufATM3
        ld de,palbufATM3RGB
        ld b,16
mkpalATM3RGB
        push bc
        ld a,(hl)
        inc hl
        push hl
        ld h,(hl)
        ld l,a
        push de
        
        call calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G

        ld a,e ;G
        add a,a
        add a,a
        add a,a
        add a,a
        or d ;R
        pop de
        ld c,a ;GR
        ld a,b
        add a,a
        add a,a
        add a,a
        add a,a
        ld (de),a ;B0
        inc de
        ld a,c
        ld (de),a ;GR
        inc de
        pop hl
        inc hl
        pop bc
        djnz mkpalATM3RGB

        ld hl,palbufATM3RGB
        ld de,palbufATM3
        ld lx,8 ;lx=brightness
        CALL recolour
        
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
        ld de,palbufATM2
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

        ld hl,MDLADDR
        call INIT

        call swapimer
        
waitfreecpu0
        OS_GETTIMER ;out: dehl=timer
        push hl
        dup 5
        halt
        edup
        OS_GETTIMER ;out: dehl=timer
        ld a,l
        pop hl
        sub l
        cp 5
        jr nz,waitfreecpu0

        ld a,(pgmusic)
        ld hl,PLAY
        OS_SETMUSIC

MUSICPATTERNSIZE=256;192
        OS_GETTIMER ;dehl
        ld (oldtimer),hl;de

showpic_mainloop

showpic0
        call setpgs_scr0       
        call showpic
        ld de,palbufATM2
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

        ld de,blackpal
        OS_SETPAL

        call setpgs_scr0       
        call showpic16c
        ;ld de,palbufATM3
        ;OS_SETPAL
        call halt_testquit
        ld e,0
        OS_SETSCREEN

        call setpgs_scr1
        call showpic16c
        call halt_testquit
        ld e,1
        OS_SETSCREEN

        ld lx,0
showpic1_show
        inc lx
        ld hl,palbufATM3RGB
        ld de,palbufATM3
        call recolour
        push ix
        ld de,palbufATM3
        OS_SETPAL
        halt
        halt
        halt
        halt
        halt
        halt
        halt
        halt
        pop ix
        ld a,lx
        cp 8
        jr nz,showpic1_show

showpic1
        call gettimer        
        ld bc,MUSICPATTERNSIZE;-(8*8)
        or a
        sbc hl,bc
        jr c,showpic1

        ld lx,8
showpic1_hide
        ld hl,palbufATM3RGB
        ld de,palbufATM3
        call recolour
        push ix
        ld de,palbufATM3
        OS_SETPAL
        halt
        halt
        halt
        halt
        halt
        halt
        halt
        halt
        pop ix
        inc lx
        ld a,lx
        cp 16
        jr nz,showpic1_hide

        ld hl,0
        call settimer
        
        jp showpic_mainloop
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
        OS_GETTIMER ;dehl
        ;ex de,hl
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

recolour
;hl=palfrom (RGB)
;de=palto (DDp)
;lx=brightness=0..15
        di
        ld (recoloursp),sp
        ld sp,hl
       ld h,tbright/256 ;once
        ld hx,16
bripalATM3
         ;ld a,(hl) ;B0
         ;inc hl
         ;push hl
         ;ld b,(hl) ;GR
       pop bc
       ld a,c
         ;ld h,tbright/256
;de=palto
;h=tbright/256
;lx=brightness
;a,b = B0,GR
         add a,lx
        ld l,a
        ld c,(hl) ;B colour component with brightness
        ld a,b
        and 0xf0
         add a,lx
        ld l,a
        ld a,b
        ld b,(hl) ;G colour component with brightness
        add a,a
        add a,a
        add a,a
        add a,a
         add a,lx
        ld l,a
        ld l,(hl) ;R colour component with brightness

       ld a,b ;G
       rlca ;g??G???? ;G10
       xor l ;R
       and 0b10010000;0b01000010 ;R10
       xor l;gr?G??R?
       rlca ;r?G??R?g
       xor c ;B
       and 0b10100101;0b01000010 ;B10
       xor c;rbG??RBg
       rrca ;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;low %grbG11RB
        inc de ;TODO ld (),a

       ld a,b ;G
       rlca ;?g??G??? ;G32
       xor l ;R
       and 0b01001000;0b00100001 ;R32
       xor l;?gr?G??R
       rlca ;gr?G??R?
       xor c ;B
       and 0b11010010;0b00100001 ;B32
       xor c;grbG??RB
        or 0b00001100 ;unused bits
        ld (de),a ;high %grbG11RB
        inc de ;TODO ld (),a

         ;pop hl
         ;inc hl
         dec hx
         jp nz,bripalATM3 ;TODO dup..edup
recoloursp=$+1
        ld sp,0
        ei
        ret

calchexcolor ;hl=color (DDp palette) ;out: ;b=B, d=R, e=G
;keep c!!!
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b
        ld b,0;0xff
        ld de,0;0xffff
        ld a,h
       cpl
        rra
        rl b ;B high
        rra
        rl d ;R high
        rra
        rra
        rra
        rl e ;G high
        rra
        rl b ;b high
        rra
        rl d ;r high
        rra
        rl e ;g high
        ld a,l
       cpl
        rra
        rl b ;B low
        rra
        rl d ;R low
        rra
        rra
        rra
        rl e ;G low
        rra
        rl b ;b low
        rra
        rl d ;r low
        rra
        rl e ;g low
;b=B
;d=R
;e=G
        ret

calcRGBtopal ;e=B, d=G, l=R ;out: b(high),c=%grbG11RB
        call calcRGBtopal_pp
        ld b,a
        call calcRGBtopal_pp
        ld c,a
        ret

calcRGBtopal_pp
;e=B, d=G, l=R
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        xor a
        rl e  ;B
        rra
        rl l  ;R
        rra
        rrca
        rrca
        rl d  ;G
        rra
        rl e  ;b
        rra
        rl l  ;r
        rra
        rl d  ;g
        rra
        cpl
        ret

texfilename
        db "noise/forest.dat",0
bmpfilename
        db "noise/forest.16c",0

blackpal
        ds 32,0xff

palbufATM2
        ds 32

palbufATM3RGB
        ds 32

palbufATM3
        ds 32

;timer
;        dw 0
        
        align 256
ttexpgs
        ds 32


        macro BRIGHTBYTE x
_=x
        if _>15
_=15
        endif
_g0=~_&1
_g1=(~_>>1)&1
_g2=(~_>>2)&1
_g3=(~_>>3)&1
;0g20G3G3
        ;db _
        db (_g0<<6)+(_g2<<5)+(_g1<<3)+(_g3<<2)+(_g1<<1)+(_g3<<0)
        endm

        align 256
tbright
;brightness levels (black 0..7 less than original, 8 equal, 9..15 to white)
;0, 1/12, 1/8, 3/16, 2/8, 3/8, 4/8, 6/8, 1
_lev=0
        dup 16 ;colour component level
_antilev=15-_lev
        BRIGHTBYTE _lev*0
        BRIGHTBYTE _lev/12
        BRIGHTBYTE _lev*1/8
        BRIGHTBYTE _lev*3/16
        BRIGHTBYTE _lev*2/8
        BRIGHTBYTE _lev*3/8
        BRIGHTBYTE _lev*4/8
        BRIGHTBYTE _lev*6/8

        BRIGHTBYTE _lev

        BRIGHTBYTE 15-(_antilev*6/8)
        BRIGHTBYTE 15-(_antilev*4/8)
        BRIGHTBYTE 15-(_antilev*3/8)
        BRIGHTBYTE 15-(_antilev*2/8)
        BRIGHTBYTE 15-(_antilev*3/16)
        BRIGHTBYTE 15-(_antilev*1/8)
        BRIGHTBYTE 15

_lev=_lev+1
        edup

wasmusic
        disp music
        include "../../_sdk/ptsplay.asm"
MDLADDR
        incbin "NOISE20.pt3"
        ent
sz_music=$-wasmusic

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	
	savebin "noise.com",begin,end-begin

	LABELSLIST "../../../us/user.l"
