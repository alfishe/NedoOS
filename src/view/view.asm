	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

STACK=0x4000
        
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

        OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ld a,e
        ld (setpgs_scr_low),a
        ;ld (setpgs_scr_attr),a
        ld a,d
        ld (setpgs_scr_high),a
        ;ld (setpgs_scr_pixels),a
        ld a,l
        ld (setpgs_scr2_low),a
        ld a,h
        ld (setpgs_scr2_high),a
        
        
        ld hl,COMMANDLINE
        call skipword
        call skipspaces
        ld a,(hl)
        or a
        jr nz,$+5
         ld hl,defaultfilename
        ex de,hl
        
         ;jr $
        ;ld de,filename
        call openstream_file
        or a
        jr nz,openerror
        
        call setpgs_scr
        ld hl,0xc000
        ld de,0xc001
        ld bc,0x1800
        ld (hl),l;0
        ldir
        ld bc,0x2ff
        ld (hl),7
        ldir
        
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

        
loadq
        call closestream_file
        
control0
        call yieldgetkeynolang
        jr z,control0
        
openerror
error
quit
        QUIT

readerror
;TODO restore stack
        call closestream_file
        jr error

loadscr
;hl=size
        ld de,0xc000
        call readstream_file
        jr loadq
        
loadfnt
;hl=size
        ld de,0xc000
        push de
        call readstream_file
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
        jr loadq

load3
;B,R,G
        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld hl,0x8000
        ld bc,0x7fff
        call fillzero
 
;0.чёрная палитра TODO
;1.загрузим в 0x4000
;2.перекодируем в 0x8800
;3.копируем в 0x8000
;4.нормальная палитра TODO
        ld de,0x4000
        ld hl,0x4800
        push de
        call readstream_file
        pop hl
        ;jr $
        ld de,0x8800 +4
        ld hl,0x4000
        ld b,192
load3lines
        push bc
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
        ;ex (sp),hl
        ;ld de,40
        ;add hl,de
        ;ex de,hl
        ;pop hl
        ld bc,40-(40*192*3)
        ex de,hl
        add hl,bc
        ex de,hl
        call downhl
        pop bc
        djnz load3lines
        ;jr $
        ld hl,0x8800
        ld de,0x8000
        call load3copylayer
        ld de,0xa000
        call load3copylayer
        ld de,0xc000
        call load3copylayer
        ld de,0xe000
        call load3copylayer
        jp loadq
        
load3copylayer
        ld bc,40*192
        ldir
        push hl
        ex de,hl
        ld bc,40*(200-192)-1
        call fillzero
        pop hl
        ret
        

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

controlimg0
        ld a,1
        xor 0
        ld ($-1),a
        ld e,a
        OS_SETSCREEN ;e=screen=0..1
        call yieldgetkeynolang
        jr z,controlimg0
        jp quit
        
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
setpgs_scr_low=$+1
        ld a,0 ;scr0_0
        SETPG32KLOW
setpgs_scr_high=$+1
        ld a,0 ;scr0_1
        SETPG32KHIGH
        ret
        
setpgs_scr2
setpgs_scr2_low=$+1
        ld a,0
        SETPG32KLOW
setpgs_scr2_high=$+1
        ld a,0
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

defaultfilename
        db "0:/scr/0844.3",0

oldtimer
        dw 0
        
        
        include "../_sdk/file.asm"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "view.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
