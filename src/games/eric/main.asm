        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

EGA=1
bmpbuf=0xbf00
egagfx=0x6000 ;converted gfx (256 tiles *32 bytes vertically) = 0x2000

muz=0xc000
muzplay=muz+3

INTSTACK=0x3f00

        org PROGSTART
begin
        ld sp,0x4000
        OS_HIDEFROMPARENT

        if EGA
        ld e,0 ;EGA
        else
        ld e,3 ;6912
        endif
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        if EGA
        ld e,0
        OS_CLS

        ;jr $
        ;ld de,dirname
        ;OS_CHDIR
        ld de,gfxname
        call openstream_file
        ;or a
	;jp nz,noloadgfx
	ld de,bmpbuf
        ld hl,14+2
;DE = Buffer address, HL = Number of bytes to read
        call readstream_file
        ld de,bmpbuf
        ld hl,(bmpbuf+14)
        dec hl
        dec hl
;DE = Buffer address, HL = Number of bytes to read
        call readstream_file
        ld de,bmpbuf
	ld hl,16384+(4*16);16504 ;8bit bmp 128x128
;DE = Buffer address, HL = Number of bytes to read
        call readstream_file
        call closestream_file

        call recodepal
        ld de,pal
        OS_SETPAL
        
        ld hl,bmpbuf+(128*127)+(4*16);+0x76 ;bottom
        ld e,0
recodegfx0
        push hl
        ld lx,16
recodegfx0bmpline
        ld d,egagfx/256
        call recodegfxsubchr
        inc hl
        inc hl
        call recodegfxsubchr
        inc hl
        inc hl
        call recodegfxsubchr
        inc hl
        inc hl
        call recodegfxsubchr
        inc hl        
        inc hl
        inc e
        dec lx
        jr nz,recodegfx0bmpline
        pop hl
        ld bc,-(128*8)
        add hl,bc
        
        inc e
        dec e
        jr nz,recodegfx0
        
        endif


        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,l
        LD (pgmuznum),A
        ld hl,wasmuz
        ld de,muz
        ld bc,muzsz
        ldir

        ;OS_GETSCREENPAGES
        ;if EGA
        ;ld a,e
        ;SETPG32KLOW
        ;ld a,d
        ;ld (pgc000),a
        ;SETPG32KHIGH
        ;else ;6912
        ;ld a,d
        ;SETPG16K
        ;endif
        ;call setpgs_scr

	 ld a,(pgmuznum)
        SETPG32KHIGH
	 ;ld a,(pgmuznum)
         ld hl,muzplay
         OS_SETMUSIC 

        call swapimer

	include "eric1.asm"

;oldtimer
;        dw 0
quiter
        halt
pgmuznum=$+1
        ld a,0
        SETPG32KHIGH
        ;ld a,(pgmuznum)
	  ld hl,muz
	  OS_SETMUSIC 
        ;call muz ;shutay
        halt
        call swapimer
	QUIT ;rasmer


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
	ld (0),hl ;ok ;восстановили запоротый стек
        
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
        
        call oldimer ;ei
        
        GET_KEY
        ld (curkey),a

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
        ;ei
on_int_jp=$+1
	jp 0


        if EGA
        
        macro RECODEBYTE
        ld a,(hl)
        ld ($+4),a
        ld a,(trecodebyteleft)
        ld b,a
        inc hl
        ld a,(hl)
        dec hl
        ld ($+4),a
        ld a,(trecodebyteright)
        or b
        endm
        
recodegfxsubchr
;из hl в de
;de растёт по +256 (сохраняем положение в конце)
;hl растёт по -128 (возвращаем в конце как было)
        push bc
        push hl
        ld c,128
        dup 7
        RECODEBYTE
        ld b,0xff
        ld (de),a
        inc d
        add hl,bc
        edup
        RECODEBYTE        
        ld (de),a
        inc d
        pop hl
        pop bc
        ret

recodepal
        ld hl,bmpbuf;+54
        ld ix,pal
        ld b,16
recodepal0
        ld e,(hl)
        inc hl
        ld d,(hl)
        inc hl
        push hl
        ld l,(hl) ;e=B, d=G, l=R
        call readfile_rgbtopal
        pop hl
        inc hl
        inc hl
        djnz recodepal0
        ret

readfile_rgbtopal
;e=B, d=G, l=R
        call calcRGBtopal_pp
        ld (ix+1),a
        call calcRGBtopal_pp
        ld (ix),a
        inc ix
        inc ix
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

;INTSTACK ;затирает процедуры выше (по доке надо 0x3b00+)

pal
        ds 32
     
	include "../../_sdk/file.asm"
;dirname
;        db "eric",0
gfxname
        db "eric/ericgfx.bmp",0

        align 256
trecodebyteleft
        dup 256
;%00003210 => %.3...210
_3=$&8
_210=$&7
        db (_3*0x08) + (_210*0x01)
        edup
        
trecodebyteright
        dup 256
;%00003210 => %3.210...
_3=$&8
_210=$&7
        db (_3*0x10) + (_210*0x08)
        edup

        endif

wasmuz
        incbin "ericmuz.bin"
muzsz=$-wasmuz

end

	display "End=",end
	;display "Free after end=",/d,#c000-end
	display "Size ",/d,end-begin," bytes"
	savebin "eric.com",begin,end-begin