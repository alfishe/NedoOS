        DEVICE ZXSPECTRUM128
	include "settings.asm"

NTEXPGS=5
NSPRPGS=2;1

SPOIL6BSTACK=0x4000
STACK=SPOIL6BSTACK-6
INTSTACK=0x3e80
;scrbase=0x8000

addhlbc=1 ;можно scrhgt=200 и в одной странице
customscales=0;1

IMPOSSIBLECOLOR=0b01000111;0x01 ;(b+w)

muz=0x8000

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,0;+0x80
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+0x80=keep screen ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
		
		ld de,res_path
		OS_CHDIR

        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        LD (pgmain4000),A
        ld a,h
        LD (pgmain8000),A
        ld a,l
        LD (pgscalersnum),A

       if 0;OLDMUZ
        ld hl,wasmuz
        ld de,muz
        ld bc,wasmuz_sz
        ldir
        call muz
       else
        ld hl,muzfilename
        call loadpage
        ld (pgsfx),a
        call loadpage
        ld (pgmusic),a
        SETPG4000
        
;это относится к загрузке уровня
        push af
        call 0x4000 ;init
        
        ld a,(pgsfx)
        SETPG8000
        pop af
        ld hl,0x4005 ;play
        OS_SETMUSIC
        call setpgsmain40008000
        ld a,(pgscalersnum)
        SETPGC000
       endif
        
        ;pop af ;LD a,(pg8000)
        ;SETPG8000

        OS_NEWPAGE
        ld a,e
        ld (pgmapnum),a

        if 1;TEXBMP
        ld de,texfilename
        call openfile_skipbmpheader
;b=handle
        ld hl,ttexpgs+NTEXPGS-1
        ld c,NTEXPGS
gettexpgs0
        push bc
        push hl
        call ldpgrecodebmp
        
        push de
        
;2. проходим по hl правый верхний треугольник текстуры, а по de - левый нижний, меняем их местами
        ld hl,0x4000
gettexpgsrot0
        push hl    
        ld b,64
gettexpgsrot1
        push bc
        push hl
        ld d,h
        ld e,l
gettexpgsrot2
        ld c,(hl)
        ld a,(de)
        ld (hl),a
        ld a,c
        ld (de),a
        inc l
        inc d
        djnz gettexpgsrot2
        pop hl
        inc l
        inc h
        pop bc
        djnz gettexpgsrot1
        pop hl
        ld a,l
        add a,64
        ld l,a
        jr nz,gettexpgsrot0
        
        pop de
        pop hl
        ld (hl),e
        dec hl
        pop bc
        dec c
        jr nz,gettexpgs0

        OS_CLOSEHANDLE

        ld de,sprfilename
        call openfile_skipbmpheader
;b=handle
        ld hl,ttexpgs+NTEXPGS+NSPRPGS-1
        ld c,NSPRPGS
getsprpgs0
        push bc
        push hl
        call ldpgrecodebmp        
        pop hl
        ld (hl),e
        dec hl
        pop bc
        dec c
        jr nz,getsprpgs0

        OS_CLOSEHANDLE

        else ;~TEXBMP
        
        ld hl,ttexpgs
        ld b,5
getttexpgs0
        push bc
        push hl
        OS_NEWPAGE
        
        push de
        ld a,e
        SETPG4000
        ld de,texfilename
        OS_OPENHANDLE
        push bc
        ld de,0x4000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE
        
        ld hl,texfilenamenum
        inc (hl)
        pop de
        
        pop hl
        ld (hl),e
        inc hl
        pop bc
        djnz getttexpgs0

        endif


        LD HL,tID
REtID0  LD A,(HL)
        add a,ttexpgs&0xff
        ld e,a
        adc a,ttexpgs/256
        sub e
        ld d,a
        ld a,(de)
;basepggfx=$+1
;        ADD A,0
        LD (HL),A
        INC L
        INC L
        jr NZ,REtID0
         ld hl,tID+128
         ld de,tID
         ld bc,128
         ldir ;ID_DOOR < 128

        ld ix,tscales
        ld hl,tscales_rev
        ld b,64
revscale0
        push bc
        push hl
        ld c,(ix)
        inc ix
        ld b,(ix)
        inc ix
        ld de,256
;деление
;DE=+-7.8;BC=+7.8
;DE=DE/BC=+-8.7/2
    ;BC сохраняется!!!
        call MONDIV
        pop hl
        sla e
        rl d
        ld (hl),e
        inc hl
        ld (hl),d
        inc hl
        pop bc
        djnz revscale0

        call genscalers

        call swapimer

        call TEXCODEGO
        
        call swapimer
        
        ;call shutay        
pgmusic=$+1
        ld a,0
        SETPG4000
        halt
        ld hl,0x4000;0x4008+3 ;stop
        OS_SETMUSIC
        halt
        QUIT

setpgsmain40008000
pgmain4000=$+1
        ld a,0
        SETPG4000
pgmain8000=$+1
        ld a,0
        SETPG8000
        ret

        if 1==0
setpgsscr40008000_current
        call getuser_scr_low_cur
        SETPG4000
        call getuser_scr_high_cur
        SETPG8000
        ret

setpgsscr40008000
        call getuser_scr_low
        SETPG4000
        call getuser_scr_high
        SETPG8000
        ret

setpgscrlow4000
        call getuser_scr_low
        SETPG4000
        ret

setpgscrhigh4000
        call getuser_scr_high
        SETPG4000
        ret
        endif

getuser_scr_low
getuser_scr_low_patch=$+1
getuser_scr_low_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr1_low) ;ok
        ret

getuser_scr_high
getuser_scr_high_patch=$+1
getuser_scr_high_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr1_high) ;ok
        ret

getuser_scr_low_cur
getuser_scr_low_cur_patch=$+1
getuser_scr_low_cur_patchN=0xff&(user_scr0_low^user_scr1_low)
        ld a,(user_scr0_low) ;ok
        ret

getuser_scr_high_cur
getuser_scr_high_cur_patch=$+1
getuser_scr_high_cur_patchN=0xff&(user_scr0_high^user_scr1_high)
        ld a,(user_scr0_high) ;ok
        ret

changescrpg_current
;        ld a,(setpgs_scr_low)
;setpgs_scr_scrxor=$+1
;        xor 0
;        ld (setpgs_scr_low),a
        ld hl,getuser_scr_low_patch
        ld a,(hl)
        xor getuser_scr_low_patchN
        ld (hl),a
        ld hl,getuser_scr_high_patch
        ld a,(hl)
        xor getuser_scr_high_patchN
        ld (hl),a
        ld hl,getuser_scr_low_cur_patch
        ld a,(hl)
        xor getuser_scr_low_cur_patchN
        ld (hl),a
        ld hl,getuser_scr_high_cur_patch
        ld a,(hl)
        xor getuser_scr_high_cur_patchN
        ld (hl),a

        ld a,1
curscrnum=$+1
        xor 0
        ld ($-1),a
         ;add a,a
         ;add a,a
         ;add a,a
         ;ld (imer_curscreen_value),a
        ret
        
changescrpg
        ;jr $
        call changescrpg_current
        ;ld (curscrnum_physical),a
	ld e,a
	OS_SETSCREEN
        ret

openfile_skipbmpheader
        OS_OPENHANDLE
        push bc
        ld de,bmpbuf;0x4000 ;addr
        ld hl,14+2;0x0076 ;size
        OS_READHANDLE ;b=handle
        pop bc
        push bc
        ld de,bmpbuf;0x4000 ;addr
        ld hl,(bmpbuf+14)
        dec hl
        dec hl
        OS_READHANDLE ;b=handle
        pop bc
        push bc
        ld de,bmpbuf;0x4000 ;addr
        ld hl,4*16;0x0076 ;size
        OS_READHANDLE ;b=handle
        pop bc
        ret

ldpgrecodebmp
        push bc
        OS_NEWPAGE
        ld a,e
        SETPG4000
        pop bc ;b=handle
        push de
        
        ld de,0x4000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE

        ld hl,0x4000
        ld d,trecolor/256
gettexpgsrecode0
        ld e,(hl)
        ld a,(de)
        ld (hl),a
        inc hl
        bit 7,h
        jr z,gettexpgsrecode0

;повернуть текстуры на 90 градусов (для стен, а для спрайтов просто перевернуть?)
;1. переворот текстур
        ld hl,0x4000
        ld de,0x4000+0x3f00
        ld b,32
gettexpgsturn0
gettexpgsturn1
        ld c,(hl)
        ld a,(de)
        ld (hl),a
        ld a,c
        ld (de),a
        inc l
        inc e
        jr nz,gettexpgsturn1
        inc h
        dec d
        djnz gettexpgsturn0
        
        pop de ;e=pg
        ret

shutay
	ld de,0xe00
shutay0
	dec d
	ld bc,0xfffd
	out (c),d
	ld b,0xbf
	out (c),e
	jr nz,shutay0
	ret
	
texfilename
        if 1;TEXBMP
        db "wolftex3.bmp",0
        else
        db "wolftex.0",0
texfilenamenum=$-2
        endif
sprfilename
        db "wolfspr3.bmp",0

        align 256
t1x
        db 255
        dup 255
        db (255*2/($&0xff)+1)/2
        edup
ttexpgs
        ds NTEXPGS+NSPRPGS

setpgmap4000
pgmapnum=$+1
        ld a,0
        SETPG4000
        ret

	include "int.asm"

loadpage
;заказывает страничку и грузит туда файл (имя файла в hl)
;out: hl=после имени файла, a=pg
        push hl
        OS_NEWPAGE
        pop hl
        ld a,e
        push af ;pg
        SETPGC000
        push hl
        ex de,hl
        OS_OPENHANDLE
        push bc
        ld de,0xc000 ;addr
        ld hl,0x4000 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE                
        pop hl
        ld b,1
        xor a
        cpir ;after 0
        pop af ;pg
        ret

muzfilename
        db "sfx.bin",0
        db "music.bin",0

wolfpal
        ;dw 0xffff,0x0c0c,0x3f3f,0xdede,0xfefe,0xdfdf,0x4c4c,0xaeae
        ;dw 0xbdbd,0xfdfd,0xbfbf,0xeded,0x8d8d,0x7d7d,0xecec,0x1f1f
        include "pal.ast"

        include "WATM2.asm"

scale2ytop
;bc=scale
;out: de=Y, lx=y
        XOR A
        LD L,A
        ld H,A
        SBC HL,BC ;-scale = -0x40..-0x410
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL ;*32 = -0x800..-0x8200
        EXD 
        LD LX,E
        LD a,D
        LD D,-1
        ADD A,Ycenter ;0x64
        LD E,A
        ret nc ;jr NC,$+3
        INC D
        ret

YtoADDR
       PUSH HL
        LD H,D
        ld L,E
        ADD HL,HL
        ADD HL,HL
        ADD HL,DE ;*5
        ADD HL,HL
        ADD HL,HL
        ADD HL,HL ;*40
        LD DE,scrbase
        ADD HL,DE
;genX=$+1
;        LD DE,0
;        ADD HL,DE
        EXD 
       POP HL
        RET 
        ;align 256;DS .(-$)
tscales
       IF customscales == 0
        INCBIN "scalesw3" ;сначала мелкие
       ELSE 
        DS 8,5,0
        DS 7,6,0
        DS 6,7,0
        DS 5,8,0
        DS 4,9,0
        DS 3,10,0
        DS 2,11,0
        DS 1,12,0
        DS 1,13,0
        DS 1,14,0
        DS 1,15,0
        DS 1,16,0
        DS 1,17,0
        DS 1,18,0
        DS 1,19,0
        DS 1,20,0
        DS 1,21,0
        DS 1,22,0
        DS 1,23,0
        DS 1,24,0
        DS 1,25,0
        DS 1,26,0
        DS 1,27,0
        DS 1,28,0
        DS 1,29,0
        DS 1,30,0
        DS 1,31,0
        DS 1,32,0
        DS 1,33,0
        DS 1,34,0
        DS 1,35,0
        DS 1,36,0
        DS 1,38,0
        DS 1,40,0
        DS 1,42,0
        DS 1,44,0
        DISPLAY $-tscales,"=#80"
       ENDIF 
tscales_rev
        ds 128

	include "anims.asm"
	include "savestate.asm"

        align 256
trecolor
;%00003210 => %.3...210
        dup 256
_3=$&8
_210=$&7
_3L=($>>4)&8
_210L=($>>4)&7
        db (_3L*0x08) + (_210L*0x01) + (_3*0x10) + (_210*0x08)
        edup

bmpbuf

        display "free before stack=",0x3e00-$

        ds 0x8000-$

       IF atm
        ;ORG #C000;,pgscalers
        ;ds 0xc000-$
        ;INCBIN "scalers"
wasmuz
        ;ds 9,201
        incbin "DOOM-MUS" ;TODO load
wasmuz_sz=$-wasmuz

        include "genscale.asm"

        display "WASMAP=",$
WASMAP
        INCBIN "mapatm.E" ;TODO load
szMAP=$-WASMAP

res_path
	defb "wolf3d",0
      

       else ;~atm
       ENDIF 
end

	;display "End=",end
	;display "Free after end=",/d,#c000-end
	;display "Size ",/d,end-begin," bytes"
	
	savebin "wolf3d.com",begin,end-begin
	
	LABELSLIST "../../../us/user.l",1
