        device zxspectrum128

        ; Compile from this file with sjasmplus !!!!!!!!!!!

DEBUG = 0
;MACHINE = 9 		; 9k version with basic loader
; MACHINE = 16 		; 16k cartrige version
; MACHINE = 48  	; 48k full version
MACHINE = 1024  	; ATM2+ with NedoOS
//--------------------------------------------------------------------------

	include "code/struct.asm"

   	if MACHINE == 9
		include "code/basic.asm" 	; for basic loader
	endif

	if MACHINE == 16
		include "code/rom.asm" 		; for cartrige
	endif

	if MACHINE == 1024
        include "../../_sdk/sys_h.asm"  

STACK=0x4000;0x61a8
GAMESTACK=0x4000;0xFFFF
L_FDFD=0xfdfd
L_FE00=0xfe00

scrbase=0x4000+4
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=192;200
INTSTACK=0x3f80
tempsp=0x3f86 ;6 bytes for prspr
;UVSCROLL_SCRWID=320 ;8*(TILEMAPWID-2)
;UVSCROLL_SCRHGT=192 ;(делится на 16!!!) ;8*(TILEMAPHGT-2) ;чтобы выводить всегда 12 метатайлов (3 блока по 8) по высоте

;screenYtable=0x8b00

EGA=0;1

        org PROGSTART
begin
        ;jp begin2 ;/prsprqwid (sprites in file are made so that they return here)
;begin2
        ld sp,STACK
        OS_HIDEFROMPARENT

        ld e,3+0x80 ;6912+keep
        ;ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)

        ld e,0 ;color byte
        OS_CLS

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ld (pgmain4000),a
        ld a,h
        ld (pgmain8000),a
        ld a,l
        ld (pgspr),a 

        ld hl,wassprites
        ld de,0xc000
        ld bc,sz_sprites
        ldir

        ;OS_NEWPAGE
        ;ld a,e
        ;ld (pgmain4000),a

       if 1==0
	ld de,res_path
	OS_CHDIR

        call setpgsscr40008000

        ld de,emptypal
        OS_SETPAL
        ;ld de,bmpfilename
        ;call openstream_file
        ;call readbmphead_pal
        ;call readbmpscr
        ;call closestream_file
        ;ld de,path
        ;OS_CHDIR
        ;ld a,(pgscrdata0)
        ld de,filename0 ;имя файла
        ld hl,0x4000 ;куда грузим
        call loadfile_in_hl ;загрузили один экранный файл в одну страницу
        ;ld a,(pgscrdata1)
        ld de,filename1 ;имя файла
        ld hl,0x8000 ;куда грузим
        call loadfile_in_hl ;загрузили другой экранный файл в другую страницу
        ld hl,0x4000+8000 ;там в картинке палитра (по байту на цвет)
        ld de,pal
        ld b,16
copypal0
        ld a,(hl)
        inc hl
        ld (de),a
        inc de
        ld (de),a
        inc de
        djnz copypal0 ;скопировали палитру в pal (по 2 байта на цвет)
        ld de,pal
        OS_SETPAL
        
        call setpgsmain40008000

        ;ld b,50
        ;halt
        ;djnz $-1
        YIELDGETKEYLOOP

        ld e,3+8+0x80 ;6912+noturbo+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
        ld de,standardpal
        OS_SETPAL
        YIELD
       endif

       if 0
        call setpgsscr40008000_current
        
        ld de,floor_2
        ld hl,0x4000
        ld bc,0x1008
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
        call primgega_onescreen
        ;jr $
       endif

        ld a,(user_scr0_high) ;ok
        SETPG16K
        
        call swapimer

       if 0;EGA
        ld hl,prsprqwid
        ld (0x0101),hl ;sprites in file are made so that they return in 0x0100
       endif

        ;YIELDGETKEYLOOP
        
        ;jp GO
code:
        include "includes.asm"
        include "mem.asm"
        include "int.asm"

set6912
        ld de,emptypal
        OS_SETPAL
        ld e,3+0x80 ;6912+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld a,(user_scr0_high) ;ok
        SETPG16K
        ld e,0
        OS_CLS
        ld de,standardpal
        OS_SETPAL
        ret

setEGA
        ld de,emptypal
        OS_SETPAL
        ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ld e,0 ;color byte
        OS_CLS
        call setpgsscr40008000_current
        ld de,pal
        OS_SETPAL
        ret

primgega_onescreen
;b=hgt,c=wid (/2)
;de=gfx
;hl=scr
       push ix
primgega0
        push bc
        ld hx,b
        push hl
        ld bc,40
primgegacolumn0
        ld a,(de)
        inc de
        ld (hl),a
        add hl,bc
        dec hx
        jr nz,primgegacolumn0
        pop hl
        ld a,0x9f;0xa0
        cp h
        ld bc,0x4000
        adc hl,bc
        jp pe,primgegacolumn0q ;в половине случаев
;8000->с000 (надо 6000) или a000->e001 (надо 4001)
         inc a
        xor h
        ld h,a
primgegacolumn0q
        pop bc
        dec c
        jr nz,primgega0
       pop ix
        ret

setpgsprc000
pgspr=$+1
        ld a,0
        SETPGC000
        ret
SEED
        dw 0
cartrigeFont
        incbin "font/font.SpecCHR"
        include "variables.asm"
        include "prspr.asm"
        
        display $,"<0x3f00"
        
wassprites
       disp 0xc000
        include "sprites.ast"
        include "pal.ast"
standardpal
        STANDARDPAL
emptypal
        ds 32,0xff        
       if EGA
ss:
        include "sprites/storage.asm"
        
        display enemy_1-enemy_0
       endif
       ent
sz_sprites=$-wassprites
 	endif

    display "level CELLS address: ",/A,levelCells
    display "getDrawData address: ",/A,getDrawData
    display "object data size: ",/A,OBJECT_DATA_SIZE
    display "OBJECTS DATA : ",/A,objectsData

    display "LEVELS_MAP: ",/A,LEVELS_MAP
    display "LEVELS_BEGIN: ",/A,LEVELS_BEGIN

    display "SPRITE_STORAGE: ",/A,SPRITE_MAP


    display "::::::::: ",/A,PASS.input.printNext

	display "SPRITE STORAGE SIZE = ",/A, ess - ss
	display "ALL LEVELS SIZE = ",/A, elds - lds

	if MACHINE == 48 || MACHINE == 9
        display "CODE SIZE = ",/A, vars - basic
        display "FULL SIZE = ",/A, $ - basic
	endif
end

    display "LAST ADDRESS = ",/A, $

	if MACHINE == 9 && __ERRORS__ == 0
		SHELLEXEC "P:\ZX\Emulators\ue\unreal.exe Wow.tap" 
	endif

	if MACHINE == 16 && __ERRORS__ == 0
		SHELLEXEC "P:\ZX\Emulators\xpeccy_0.6.20210407_win32\xpeccy.exe Wow.bin" 
	endif

	if MACHINE == 1024 && __ERRORS__ == 0
	display "Size ",/d,end-begin," bytes"
	savebin "wow.com",begin,end-begin
	LABELSLIST "../../../us/user.l"
 	endif
