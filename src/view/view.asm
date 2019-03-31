	device pentagon1024 ;don't trust this line, it's for ATM2 :)
        include "../_sdk/sys_h.asm"

STACK=0x4000

FILE888TO=0x4000 ;,0x4800FILE888FROM=0xb800T888FOUND=0x8800 ;temp

deblcscradr=0xc000

grfadr=#4000grfatr=grfadr+#84
        
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
        
         ;jr $
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
        jr nc,quit
        
        ld bc,quit
        push bc
        
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
        
        
openerror
quit
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
        ret

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
        
loadmc
        ld de,0x4000
        call readstream_file
        call closestream_file
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        call convmcscr
        jp waitkeyquit

convmcscr
        ld hl,0x4000
        ld de,0xc000+4
        ld b,192
loadmclines0
        push bc
        push de
        ld b,32
loadmcline0
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
        djnz loadmcline0
        pop de
        ex de,hl
        ld bc,40
        add hl,bc
        ex de,hl
        pop bc
        djnz loadmclines0
        ld de,0x8000+4
        ld b,192
loadmcattrlines0
        push bc
        push de
        ld bc,32
loadmcattrline0
        ld a,(hl)
        ld (de),a
        set 5,d
        ldi
        res 5,d
        jp pe,loadmcattrline0
        pop de
        ex de,hl
        ld bc,40
        add hl,bc
        ex de,hl
        pop bc
        djnz loadmcattrlines0
        ret

loadmcx
        call cleanafter8000
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld de,0x4000
        ld hl,0x1800*2
        call readstream_file
        call convmcscr
        call setpgs_scr2
        call cleanafter8000
        ld de,0x4000
        ld hl,0x1800*2
        call readstream_file
        call convmcscr
        call closestream_file
        jp waitkeyblink


loadgrf
;hl=size
        push hl
        call cleanafter8000
        pop hl
        call setpgtemp8000
        ld de,grfadr
        call readstream_file
        call closestream_file
        ld e,2
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        
        LD HL,grfadr        LD DE,TPAL        CALL GRFPAL        LD de,TPAL        OS_SETPAL        CALL GRF2ATM        jp waitkeyquit
TPAL
        ds 32

cleanafter8000
        ld hl,0x8000
        ld bc,0xffff-0x8000
        jp fillzero

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
        ret
        
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
        
        dw -1 ;end of list
        

        
defaultfilename
        db "0:/scr/rockwell.888",0
curext
        ds 3
        db 0

oldtimer
        dw 0
        
        
        include "deblc.asm"
        include "chr.asm"
        include "888.asm"
        include "grf.asm"
        include "../_sdk/file.asm"
        
cmd_end

	display "Size ",/d,cmd_end-cmd_begin," bytes"

	savebin "view.com",cmd_begin,cmd_end-cmd_begin
	
	;LABELSLIST "../us/user.l"
