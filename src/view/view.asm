        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

STACK=0x4000

FILE888TO=0x4000 ;,0x4800
FILE888FROM=0xb800
T888FOUND=0x8800 ;temp

deblcscradr=0xc000

grfadr=#4000
grfatr=grfadr+#84
        
        org PROGSTART
cmd_begin

        ld sp,STACK
        
        ld e,3 ;6912
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        ld (codepg4000),a
        ld a,h
        ld (temppg8000),a
        ld a,l
        ld (highpgc000),a

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,e
        ;ld (setpgs_scr_low),a
        ;;ld (setpgs_scr_attr),a
        ;ld a,d
        ;ld (setpgs_scr_high),a
        ;;ld (setpgs_scr_pixels),a
        ;ld a,l
        ;ld (setpgs_scr2_low),a
        ;ld a,h
        ;ld (setpgs_scr2_high),a
        
        
        ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
         ld hl,defaultfilename
        push hl
        call findlastdot ;out: de = after last dot or start
        ex de,hl
;commandline might contain spaces after extension
        ld de,curext
        ldi
        ld a,(hl)
        sub ' '
        ld (de),a
        jr z,curextq
        ldi
        ld a,(hl)
        sub ' '
        ld (de),a
        jr z,curextq
        ldi
curextq
        
        pop de
        
        ;ld de,filename
        call openstream_file
        or a
        jr nz,openerror
        
        call setpgs_scr
        ld hl,0xc000
        ld bc,0x1800
        call fillzero
        ld bc,0x2ff
        ld (hl),7
        ldir

        call runext
        jr nc,wrongfile;quit
        
        ;ld bc,quit
        ;push bc
        
        ld a,(filehandle)
        ld b,a
        OS_GETFILESIZE ;dehl=filesize
        ld a,h
        sub 0x1b
        or l
        or d
        or e
        jr z,loadscr ;TODO ещё 6913
        ld a,h
        sub 0x18
        or l
        or d
        or e
        jr z,loadscr
       if 1==0
        ld a,h
        sub 0x08
        or l
        or d
        or e
        jr z,loadfnt
        ld a,h
        sub 0x03
        or l
        or d
        or e
        jr z,loadfnt
        ld a,h
        sub 0x1b*2
        or l
        or d
        or e
        jp z,loadimg
        ld a,h
        sub 0x18*3
        or l
        or d
        or e
        jr z,load3
       endif


;wrong file
        call closestream_file
        
wrongfile
openerror
        ld hl,-1
        ;jr quit
;quit
        QUIT

;readerror
;;TODO restore stack
;        call closestream_file
;        jr error

loadscr
;hl=size
;TODO кнопку A выключения/переключения атрибутов
        ld de,0xc000
        call readstream_file
        call closestream_file
waitkeyquit
control0
        call yieldgetkeynolang
        jr z,control0
waitkeyq        
        ld hl,0
;проверяем стрелки
        cp key_left
        jr z,quitwithkey
        cp key_right
        jr z,quitwithkey
        cp key_up
        jr z,quitwithkey
        cp key_down
        jr z,quitwithkey
        QUIT
quitwithkey
;возвращаем код клавиши (для nv)
        ld l,a
        QUIT

loadplc
;hl=size
        ld de,0x6000
        push de
        call readstream_file
        call closestream_file
        pop hl
        call deblc
        jr waitkeyquit
        
loadfnt
;hl=size
        ld de,0xc000
        push de
        call readstream_file
        call closestream_file
        pop hl
;на случай линейного шрифта - рисуем его снизу
        ld e,0
loadfnt0
        ld d,0xd0
        ld b,8
loadfnt1
        ld a,(hl)
        inc hl
        ld (de),a
        inc d
        djnz loadfnt1
        inc e
        jr nz,loadfnt0
        jr waitkeyquit
        
loadmlt
        call read4000
        call closestream_file
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,0x4000
        ld de,0xc000+4 ;pixels
        call convmgpixelscr_hlde
        ;ld hl,convmcattrline
        ;ld (convmgpixelscr_linepatch),hl
        ld hl,0x5800
        ld de,0x8000+4 ;attrs
        ld bc,0xc001 ;b=hgt in chrs ;c=hgt of chr
        call convmgattrs
        ;ld lx,40
        ;call convmgattrlines
        ;call convmgpixelscr_hlde
        ;ld hl,convmcline
        ;ld (convmgpixelscr_linepatch),hl
        jp waitkeyquit

loadmc
        call read4000
        call closestream_file
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        call convmcscr
        jp waitkeyquit

convmcscr
        ld hl,0x4000
        ld de,0xc000+4 ;pixels
        ld b,192
loadmclines0
        push bc
        call convmcline
        ex de,hl
        ld c,40
        add hl,bc
        ex de,hl
        pop bc
        djnz loadmclines0
        ;ld bc,0xc001
        ;jr convmgattrs
;convmcattrs
        ld de,0x8000+4 ;attrs
        ld bc,0xc020
convmcattrlines
convmcattrlines0
        push bc
        ld b,0
        call convmcattrline
        ex de,hl
        ld c,40
        add hl,bc
        ex de,hl
        pop bc
        djnz convmcattrlines0
        ret
        
readconvmg1attrs
        ld hl,0x0c00
        call read4000
        ld de,0x8000+4+8 ;attrs
        ld bc,0xc010
        jr convmcattrlines

readconvmg1attrs8
        ld hl,0x0c00
        call read4000
        ld de,0x8000+4 ;attrs
        ld b,24
convmg1attr8lines0
        push bc
        ld b,8
convmg1attr8lines1
        push hl
        push bc
        ld bc,8
        call convmcattrline
        ex de,hl
        ld c,24
        add hl,bc
        ex de,hl
        ld c,8
        call convmcattrline
        ex de,hl
        ld c,40-24
        add hl,bc
        ex de,hl
        pop bc
        pop hl
        djnz convmg1attr8lines1
        ld c,16
        add hl,bc
        pop bc
        djnz convmg1attr8lines0
        ret
        
readconvmgattrs
        push bc
        call read4000
        pop bc
convmgattrs
;hl=from
;de=attrs addr
;b=hgt in chrs
;c=hgt of chr
        ld de,0x8000+4 ;attrs
        ld lx,40
convmgattrlines
;hl=from
;de=attrs addr
;b=hgt in chrs
;c=hgt of chr
;lx=40/80 step
convmg2attrlines0
        push bc
        ld b,c;2
convmg2attrlines1
        push hl
        push bc
        ld bc,32
        call convmcattrline
        ex de,hl
        ld c,lx;40
        add hl,bc
        ex de,hl
        pop bc
        pop hl
        djnz convmg2attrlines1
        ld c,32
        add hl,bc
        pop bc
        djnz convmg2attrlines0
        ret
        
convmcattrline
        push de
convmcattrline0
        ld a,(hl)
        ld (de),a
        set 5,d
        ldi
        res 5,d
        jp pe,convmcattrline0
        pop de
        ret

convmcline
        push de
        ld b,32
convmcline0
        dup 4
        rl (hl)
        rla
        add a,a
        edup
        ld c,a
        rrca
        or c
        ld (de),a
        set 5,d
        dup 4
        rl (hl)
        rla
        add a,a
        edup
        ld c,a
        rrca
        or c
        ld (de),a
        res 5,d
        inc de
        inc hl
        djnz convmcline0
        pop de
        ret

readconvmgpixelscr
        call cleanafter8000
        call read40001800
        ;ld hl,0x4000
        ld de,0xc000+4 ;pixels
convmgpixelscr_hlde
        ld b,192
convmglines0
        push bc
        push hl
         ;ld bc,32 ;for convmcattrline
;convmgpixelscr_linepatch=$+1
        call convmcline ;/convmcattrline
        pop hl
        call downhl
        ex de,hl
        ld c,40
        add hl,bc
        ex de,hl
        pop bc
        djnz convmglines0
        ret
        
loadmcx
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,0x1800*2
        call read4000
        call convmcscr
        call setpgs_scr2
        call cleanafter8000
        ld hl,0x1800*2
        call read4000
        call convmcscr
loadmcxq
        call closestream_file
        jp waitkeyblink

loadmg2
        ld bc,0x6002
        ld hl,0x0c00
        jr loadmg_go
loadmg4
        ld bc,0x3004
        ld hl,0x0600
        jr loadmg_go
loadmg8
        ld bc,0x1808
        ld hl,0x0300
loadmg_go
        push bc
        push hl
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,0x100 ;header
        call read4000
        call readconvmgpixelscr
        call setpgs_scr2
        call readconvmgpixelscr
        call setpgs_scr
        pop hl
        pop bc
        push bc
        push hl
        call readconvmgattrs
        call setpgs_scr2
        pop hl
        pop bc
        call readconvmgattrs
        jr loadmcxq

loadmg1
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,0x100 ;header
        call read4000
        call readconvmgpixelscr
        call setpgs_scr2
        call readconvmgpixelscr
        call setpgs_scr
        call readconvmg1attrs
        call setpgs_scr2
        call readconvmg1attrs
        call setpgs_scr
        call readconvmg1attrs8
        call setpgs_scr2
        call readconvmg1attrs8
        jr loadmcxq

read40001800
        ld hl,0x1800
read4000
        ld de,0x4000
        push de
        call readstream_file
        pop hl
        ret
        

loadgrf
;hl=size
        push hl
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        pop hl
        call setpgtemp8000
        ld de,grfadr
        push de
        call readstream_file
        call closestream_file
        pop hl;LD HL,grfadr
        LD DE,TPAL
        push de
        CALL GRFPAL
        pop de;LD de,TPAL
        OS_SETPAL
        CALL GRF2ATM
        jp waitkeyquit
TPAL
        ds 32

cleanafter8000
        ld hl,0x8000
        ld bc,0xffff-0x8000
        jp fillzero

loadrmode
;scr1 (6144 спрайтом) (первый фрейм)
;scr2 (6144 спрайтом) (второй фрейм)
;attr1 (768) ;G/M/C - низ(нечет) первого фрейма
;attr2 (768) ;R/C/M - низ(нечет) второго фрейма
;attr3 (768) ;B/Y - верх(чёт) второго фрейма - переставим на 1-й из-за интерлейса
;attr4 (768) ;W - верх(чёт) первого фрейма - переставим на 2-й из-за интерлейса
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        call read40001800
        call convmcscr
        call setpgs_scr2
        call cleanafter8000
        call read40001800
        call convmcscr
;attr1 (768) ;G/M/C - низ(нечет) первого фрейма
        call setpgs_scr
        ld de,0x8000+4+40 ;attrs
        call readrmodeattrs
;attr2 (768) ;R/C/M - низ(нечет) второго фрейма
        call setpgs_scr2
        ld de,0x8000+4+40 ;attrs
        call readrmodeattrs
;attr3 (768) ;B/Y - верх(чёт) второго фрейма - переставим на 1-й из-за интерлейса
        call setpgs_scr
        call readrmodeattrs_top
;attr4 (768) ;W - верх(чёт) первого фрейма - переставим на 2-й из-за интерлейса
        call setpgs_scr2
        call readrmodeattrs_top
        jp loadmcxq

readrmodeattrs_top
        ld de,0x8000+4 ;attrs
readrmodeattrs
;de=attrs
        push de
        ld hl,0x300
        call read4000
        pop de
        ld bc,0x1804
        ld lx,80
        jp convmgattrlines
        
        if 1==0
;TODO
        call setEGA ;keeps hl
        ld de,0x4000
        call readstream_file
        call closestream_file
;0. найти все цвета attr1,attr2,attr3,attr4
;1. сгенерировать палитру (все комбинации attr4+attr3 2*3 шт, все комбинации attr1+attr2 4*4 шт) со ссылками на спецпалитру
;2. включить спецпалитру
;3. сконвертировать пиксели с учётом атрибутов

        LD de,TRMODEPAL
        OS_SETPAL
        
        jp waitkeyquit
        
TRMODEPAL
;0, r, c, m, g, y, gc, w, mr, mc, [M], [C], bw, yw, [rw], [cw]
;используем уровни 8 (2 на ATM), 15 (3 на ATM)
_0=5*0
_1=5*1;8
_2=5*2;15
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
;high B, high b, low B, low b
        macro palcol r,g,b ;0..15
        db 0xff - (((g&1)<<7) + ((r&1)<<6) + ((b&1)<<5) + ((g&2)<<3) + (r&2) + ((b&2)>>1))
        db 0xff - (((g&4)<<5) + ((r&4)<<4) + ((b&4)<<3) + ((g&8)<<1) + ((r&8)>>2) + ((b&8)>>3))
        endm
        palcol _0,_0,_0 ;0
        palcol _1,_0,_0 ;r
        palcol _0,_1,_1 ;c
        palcol _1,_0,_1 ;m
        palcol _0,_1,_0 ;g
        palcol _1,_1,_0 ;y
        palcol _0,_2,_1 ;gc
        palcol _1,_1,_1 ;w
        palcol _2,_0,_1 ;mr
        palcol _1,_1,_2 ;mc
        palcol _2,_0,_2 ;[M]
        palcol _0,_2,_2 ;[C]
        palcol _1,_1,_2 ;bw
        palcol _2,_2,_1 ;yw
        palcol _2,_1,_1 ;[rw]
        palcol _1,_2,_2 ;[cw]
        endif
        
load16c
        ;jr $
        call setEGA ;keeps hl
        ld hl,0x8000
        ld de,0x8000
        call readstream_file
        ld de,TPAL;curpal
        ld hl,32
        call readstream_file
        call closestream_file
        ld de,TPAL;curpal
        OS_SETPAL
        jp waitkeyquit

        
load3
;B,R,G
;hl=size
        call setEGA ;keeps hl
 
;0.чёрная палитра (уже)
;1.загрузим в 0x4000
;2.перекодируем в 0x8800
;3.копируем в 0x8000
;4.нормальная палитра
        ld de,0x4000
        call readstream_file
        call closestream_file
conv3
        call cleanafter8800
        ld hl,0x4000
        ld de,0x8800 +4
        ld b,192
load3lines
        push bc
        call load3line ;out: de=next line
        call downhl
        pop bc
        djnz load3lines
conv3q
        ld hl,0x8800
        ld de,0x8000
        call load3copylayer
        ld de,0xa000
        call load3copylayer
        ld de,0xc000
        call load3copylayer
        ld de,0xe000
        call load3copylayer
        ld de,palstandard
        OS_SETPAL
        jp waitkeyquit

loady
;packed R,G,B (run from 0xb800, depack to 0xb800, depacker at 0x5b00)
        call setEGA ;keeps hl
        ld de,0xb800
        call readstream_file
        call closestream_file
        ld a,(0xb800)
        cp 0xf3
        ret nz
        call 0xb800
        ld hl,0xb800
        ld de,0x4000+0x1800
        ld bc,0x1800*2
        ldir
        ld de,0x4000
        ld bc,0x1800
        ldir
        ;ld b,192
        jr conv3;loadplusq

loadplus
;MultiStudio
;B,R,G sprites (hgt=128)
;hl=size
        call setEGA ;keeps hl
;0.чёрная палитра (уже)
;1.загрузим в 0x4000
;2.перекодируем в 0x8800
;3.копируем в 0x8000
;4.нормальная палитра
        ld de,0x4000
        ld hl,0x1000
        call readstream_file
        ld de,0x4000+0x1800
        ld hl,0x1000
        call readstream_file
        ld de,0x4000+(2*0x1800)
        ld hl,0x1000
        call readstream_file
        call closestream_file
        call cleanafter8800
        ld b,128
loadplusq
        ld hl,0x4000
        ld de,0x8800 +4
loadpluslines
        push bc
        call load3line ;out: de=next line
        ld bc,32
        add hl,bc
        pop bc
        djnz loadpluslines
        jp conv3q
        
loadimg
        ld de,0xc000
        ld hl,0x1b00
        push de
        push hl
        call readstream_file
        call setpgs_scr2
        pop hl
        pop de
        call readstream_file
        call closestream_file
waitkeyblink
controlimg0
        ld a,1
        xor 0
        ld ($-1),a
        ld e,a
        OS_SETSCREEN ;e=screen=0..1
        call yieldgetkeynolang
        jr z,controlimg0
        jp waitkeyq
        
load888
        call setEGA ;keeps hl
        ;jr $
        ld de,FILE888FROM
        call readstream_file
        call closestream_file
        call DEP888
        jp conv3
        
cleanafter8800
        ld hl,0x8800
        ld bc,0xffff-0x8800
        jp fillzero

palstandard
        STANDARDPAL
palblack
        ds 32,0xf3

load3copylayer
        ld bc,40*192
        ldir
        push hl
        ex de,hl
        ld bc,40*(200-192)-1
        call fillzero
        pop hl
        ret

load3line
        ;push de
        call load3subline
        ;set 6,d
        ld bc,40*192*2
        ex de,hl
        add hl,bc
        ex de,hl
        call load3subline
        ;res 6,d
        ;set 5,d
        ld bc,-(40*192)
        ex de,hl
        add hl,bc
        ex de,hl
        call load3subline
        ;set 6,d
        ld bc,40*192*2
        ex de,hl
        add hl,bc
        ex de,hl
        call load3subline
        ld bc,40-(40*192*3)
        ex de,hl
        add hl,bc
        ex de,hl
        ret

load3subline
        push de
        push hl
        ld a,h
        ld (load3_h0),a
        ld (load3_h0a),a
        add a,0x18
        ;ld (load3_h1),a
        ;ld (load3_h1a),a
        ld b,a
        add a,0x18
        ;ld (load3_h2),a
        ;ld (load3_h2a),a
        ld c,a
load3subline0
;load3_h2=$+1
        ld h,c;0
        rl (hl)
        rla
;load3_h1=$+1
        ld h,b;0
        rl (hl)
        rla
load3_h0=$+1
        ld h,0
        rl (hl)
        rla
        ;a=%GRB
        add a,a
        add a,a
        ;a=%GRB00
;load3_h2a=$+1
        ld h,c;0
        rl (hl)
        rla
;load3_h1a=$+1
        ld h,b;0
        rl (hl)
        rla
load3_h0a=$+1
        ld h,0
        rl (hl)
        rla
        ;a=%GRB00grb
        rlca
        rlca
        rlca
        ;a=%00grbGRB
        ld (de),a
        inc de
        inc l
        ld a,l
        and 0x1f
        jr nz,load3subline0
        pop hl
        pop de
        ret

downhl
        inc h
        ld a,h
        and 7
        ret nz
        ld a,l
        add a,32
        ld l,a
        ret c
        ld a,h
        sub 8
        ld h,a
        ret
        
setEGA
;keeps hl
        push hl
        ld de,palblack
        OS_SETPAL
        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,0x8000
        ld bc,0x7fff
        call fillzero
        pop hl
        ret

fillzero
        ld d,h
        ld e,l
        inc de
        ld (hl),0
        ldir
        ret

yieldgetkeynolang
;out: z=nokey
	YIELDGETKEY
        ld a,c
        ret

setpgcode4000
codepg4000=$+1
        ld a,0
        SETPG16K
        ret

setpgtemp8000
temppg8000=$+1
        ld a,0
        SETPG32KLOW
        ret

setpghighc000
highpgc000=$+1
	ld a,0
	SETPG32KHIGH
	ret

setpgs_scr
        ld a,(user_scr0_low) ;ok
        SETPG32KLOW
        ld a,(user_scr0_high) ;ok
        SETPG32KHIGH
        ret
        
setpgs_scr2
        ld a,(user_scr1_low) ;ok
        SETPG32KLOW
        ld a,(user_scr1_high) ;ok
        SETPG32KHIGH
        ret

skipword
;hl=string
;out: hl=terminator/space addr
getword0
        ld a,(hl)
        or a
        ret z
        cp ' '
        ret z
        inc hl
        jr getword0

skipspaces
;hl=string
;out: hl=after last space
        ld a,(hl)
        cp ' '
        ret nz
        inc hl
        jr skipspaces

;hl = poi to filename in string
;out: de = after last dot or start
findlastdot
	ld d,h
	ld e,l ;de = after last dot
findlastdot0
	ld a,[hl]
	inc hl
	or a
	ret z
	cp '.'
	jr nz,findlastdot0
	jr findlastdot

strcplow
;hl=s1 (lowercase)
;de=s2 (any case)
;out: Z (equal, hl=terminator of s1+1, de=terminator of s2+1), NZ (not equal, hl=erroraddr in s1, de=erroraddr in s2)
strcplow0.
	ld a,[de] ;s2
         or a
         jr z,$+4
         or 0x20
	cp [hl] ;s1
	ret nz
	inc hl
	inc de
	or a
	jr nz,strcplow0.
	ret ;z

runext
;out: CY=error
        ld hl,extlist ;list of internal commands
strcpexec0
        ld c,(hl)
        inc hl
        ld b,(hl)
        inc hl
        ld a,b
        cp -1
        jr z,runext_error ;a!=0: no such ext
        ld de,curext
        push hl
        call strcplow
        pop hl
        jr nz,strcpexec_fail
        ld (runextaddr),bc
        ld a,(filehandle)
        ld b,a
        OS_GETFILESIZE ;dehl=filesize
runextaddr=$+1
        call 0
        or a
        ret
strcpexec_fail
        ld b,-1 ;чтобы точно найти терминатор
        xor a
        cpir ;найдём обязательно
        jr strcpexec0

runext_error
;no such ext
        scf
        ret
        
extlist
        dw loadplus
        db "+",0
        dw loadplus
        db "-",0
        dw load3
        db "3",0
        dw load888
        db "888",0
        dw loadfnt
        db "fnt",0
        dw loady
        db "y",0
        dw loadimg
        db "img",0
        dw loadplc
        db "plc",0
        dw loadgrf
        db "grf",0
        dw loadmc
        db "mc",0
        dw loadmcx
        db "mcx",0
        dw loadchr
        db "ch$",0
        dw loadmg1
        db "mg1",0
        dw loadmg2
        db "mg2",0
        dw loadmg4
        db "mg4",0
        dw loadmg8
        db "mg8",0
        dw loadrmode
        db "rm",0
        dw load16c
        db "16c",0
        dw loadmlt
        db "mlt",0
        
        dw -1 ;end of list
        

        
defaultfilename
        db "m:/scr/rockwell.888",0
curext
        ds 3
        db 0

;oldtimer
;        dw 0
        
        
        include "deblc.asm"
        include "chr.asm"
        include "888.asm"
        include "grf.asm"
        include "../_sdk/file.asm"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "view.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
