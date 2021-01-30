        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

BINADDR=0x4000

	include "target.asm"

	ifdef EVO

	display "EVO version"

MEM_SLOT0=#37f7
MEM_SLOT1=#77f7
MEM_SLOT2=#b7f7
MEM_SLOT3=#f7f7

INVMASK=#ff

	else

	display "ATM version"

MEM_SLOT0=#3ff7
MEM_SLOT1=#7ff7
MEM_SLOT2=#bff7
MEM_SLOT3=#fff7

INVMASK=#7f

	endif

	ifdef DOS
	display "DOS support"
	endif


        include "pages.asm"
NUMBER_OF_PAGES=10

scrbase=0x4000
sprmaxwid=32
sprmaxhgt=32
scrwid=160 ;double pixels
scrhgt=200
clswid=40 ;*8
clshgt=200

STACK=0x4000
tempsp=0x3f06 ;6 bytes for prspr
INTSTACK=0x3f00


SCR_PAGE1=(1^INVMASK)
SCR_PAGE3=(3^INVMASK)
SCR_PAGE5=(5^INVMASK)
SCR_PAGE7=(7^INVMASK)

SPBUF_PAGE0=(8^INVMASK)
SPBUF_PAGE1=(9^INVMASK)
SPBUF_PAGE2=(10^INVMASK)
SPBUF_PAGE3=(11^INVMASK)

SPTBL_PAGE=(6^INVMASK)

;CC_PAGE0=(12^INVMASK)
CC_PAGE1=(13^INVMASK)
CC_PAGE2=(14^INVMASK)
CC_PAGE3=(12^INVMASK)

SND_PAGE=(0^INVMASK)
PAL_PAGE=4;(4^INVMASK) ;TODO где она в файлах???????
GFX_PAGE=(16^INVMASK)


IMG_LIST =0xd000;#1000

;смещения в SND_PAGE

AFX_INIT =#4000
AFX_PLAY =#4003
AFX_FRAME=#4006
PT3_INIT =#4009
PT3_FRAME=#400c
PT3_MUTE =#400f ;NEW for TFM
TURBOFMON=#4012 ;NEW for TFM

MUS_COUNT=#49fe
SMP_COUNT=#49ff
SFX_COUNT=#5000

MUS_LIST =#4a00
SMP_LIST =#4d00
SFX_DATA =#5100



	macro MDebug color
	push af
	ld a,color
	out (#fe),a
	pop af
	endm

	macro MSetShadowScreen
	ld a,(_screenActive)
	;ld bc,MEM_SLOT1
	;ld (_memSlot1),a
	;out (c),a
        SETPG16K

	;ld b,high MEM_SLOT2
	sub 4
	;ld (_memSlot2),a
	;out (c),a
        SETPG32KLOW
	endm

	macro MRestoreMemMap012
;TODO переделать на (pgcode4000) и т.п.
	;ld bc,MEM_SLOT3
	ld a,CC_PAGE3
	;out (c),a
        call setpgc000;SETPG32KHIGH

	;ld b,high MEM_SLOT1
	ld a,CC_PAGE1
	;ld (_memSlot1),a
	;out (c),a
        call setpg4000;SETPG16K

	;ld b,high MEM_SLOT2
	ld a,CC_PAGE2
	;ld (_memSlot2),a
	;out (c),a
        call setpg8000;SETPG32KLOW
	endm

	macro MRestoreMemMap12
	;ld bc,MEM_SLOT1
	ld a,CC_PAGE1
	;ld (_memSlot1),a
	;out (c),a
        call setpg4000;SETPG16K

	;ld b,high MEM_SLOT2
	ld a,CC_PAGE2
	;ld (_memSlot2),a
	;out (c),a
        call setpg8000;SETPG32KLOW
	endm

        org PROGSTART
begin
        ld sp,STACK
        OS_HIDEFROMPARENT

;        ld b,25
;waitcls0
;        push bc
;        YIELD
;        pop bc
;        djnz waitcls0 ;чтобы nv не перехватил фокус при вызове через комстроку

        ld e,0
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
	ld e,0
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
	ld e,1
	OS_SETSCREEN
        ld e,0 ;color byte
        OS_CLS
        
        OS_GETMAINPAGES
;dehl=номера страниц в 0000,4000,8000,c000
        ld a,e
        LD (pgmain4000),A
        ld a,h
        LD (pgmain8000),A
        ld a,l
        LD (pgmainc000),A
        call setpgsmain40008000 ;записать в curpg...

        ;OS_GETSCREENPAGES
;de=страницы 0-го экрана (d=старшая), hl=страницы 1-го экрана (h=старшая)
        ;ld a,l
        ;ld (setpgs_scr_low),a
	;xor e
        ;ld (setpgs_scr_scrxor),a
        ;ld a,h
         ;ld (ttexpgs+31),a ;ld (IR128),a ;на всякой случай, для прерывания
        ;xor l
        ;ld (setpgs_scr_pgxor),a
        
	ld de,res_path
	OS_CHDIR

        ld de,fnaddr
        OS_OPENHANDLE
        push bc
        ld de,jpaddr ;addr
        ld hl,2 ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE

        ld de,fnbin
        OS_OPENHANDLE
        push bc
         ld de,BINADDR ;addr
         ld hl,0x4000 ;size
         OS_READHANDLE
         pop bc
         push bc
        ld de,BINADDR ;addr
        ld hl,-BINADDR ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE                

        ld de,tpages
        ld b,NUMBER_OF_PAGES
loadloop0
        push bc
        push de
        ld hl,texfilename
        call loadpage
        pop de
        ld (de),a
        inc e
        ld hl,texfilename_pgnumend
loadloop_nextdigit0
        dec hl
        ld a,(hl)
        inc a
        cp "0"+10
        ld (hl),"0"
        jr z,loadloop_nextdigit0
        ld (hl),a
        pop bc
        djnz loadloop0
        
        ld a,(pgmain4000)
        ld (tpages+CC_PAGE1),a
        ld a,(pgmain8000)
        ld (tpages+CC_PAGE2),a
pgmainc000=$+1
        ld a,0
        ld (tpages+CC_PAGE3),a
        
        if 1==0
        call loadpage
        ld (pgmusic),a
        SETPG16K
        push af
        call 0x4000 ;init
        pop af
        ld hl,0x4005 ;play
        OS_SETMUSIC
        endif
        call setpgsmain40008000
        
        call swapimer

        ld de,SUMMERPAL
        OS_SETPAL

        if 1==0
        ;jr $
        ld c,10
        ld b,2
        ld de,0
;c=X, b=Y, de=tile
;координаты в тайлах
        call _draw_tile
        call _swap_screen
        endif
jpaddr=$+1
        jp 0
mainloop
        
        call changescrpg ;с этого момента можем видеть, что нарисовали
        
;waitkey
        halt ;в играх не юзаем YIELD, иначе может сработать чужой обработчик прерываний
curkey=$+1
        ld a,0
        cp key_esc
        jr nz,mainloop;waitkey
        
        call swapimer
pgmusic=$+1
        ld a,0
        SETPG16K
        ld hl,0x4008 ;stop
        OS_SETMUSIC
        halt
        QUIT

        ds 0x0200-$
tpages
        ds 256 ;pages

loadpage
;заказывает страничку и грузит туда файл (имя файла в hl)
;out: hl=после имени файла, a=pg
        push hl
        OS_NEWPAGE
        pop hl
        ld a,e
        push af ;pg
        SETPG32KHIGH
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

SUMMERPAL
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        dw 0xffff,0xfefe,0x1d1d,0x3c3c,0xcdcd,0x4c4c,0x2c2c,0xecec
        dw 0xfdfd,0x2d2d,0xeeee,0x3f3f,0xafaf,0x5d5d,0x4e4e,0x0c0c
;RSTPAL
;        STANDARDPAL


texfilename
texfilename_pgnumend=$+8
        db "page_001.bin",0


setpgsmain40008000
pgmain4000=$+1
        ld a,0
        ;ld (curpg4000),a
        SETPG16K
pgmain8000=$+1
        ld a,0
        ;ld (curpg8000),a
        SETPG32KLOW
        ret

setpgsscr40008000_current
        call getuser_scr_low_cur
        ;ld (curpg4000),a ;TODO kill
        SETPG16K
        call getuser_scr_high_cur
        ;ld (curpg8000),a ;TODO kill
        SETPG32KLOW
        ret

setpgsscr40008000
        call getuser_scr_low
        ;ld (curpg4000),a ;TODO kill
        SETPG16K
        call getuser_scr_high
        ;ld (curpg8000),a ;TODO kill
        SETPG32KLOW
        ret

setpgscrlow4000
        call getuser_scr_low
        SETPG16K
        ret

setpgscrhigh4000
        call getuser_scr_high
        SETPG16K
        ret

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
        ret
        
changescrpg
;TODO убрать
        ;jr $
        call changescrpg_current
        ;ld (curscrnum_physical),a
	ld e,a
	OS_SETSCREEN
        ret

setpg4000
        ld ($+4),a
        ld a,(tpages)
        SETPG16K
        ret

setpg8000
        ld ($+4),a
        ld a,(tpages)
        SETPG32KLOW
        ret

setpgc000
        ld ($+4),a
        ld a,(tpages)
        SETPG32KHIGH
        ret

setShadowScreen
	MSetShadowScreen
	ret

_clear_screen
	and 15
	ld l,a
	ld h,high colorMaskTable
	ld e,(hl)
	call setShadowScreen
	ld hl,#4000
	ld (hl),e
	ld de,#4001
	ld bc,#7fff
	call _fast_ldir
RestoreMemMap12
	MRestoreMemMap12
	ret

_swap_screen
	push ix
	push iy

	ld a,(spritesActive)
	or a
	push af
	jr z,.noSpr0
	call setShadowScreen
	call updateTilesToBuffer
	call prspr
.noSpr0

	halt

	ld a,(_screenActive)
	xor 2
	ld (_screenActive),a
	;ld e,a

	;ld a,#10
	;bit 1,e
	;jr z,$+4
	;or #08
	;ld bc,#7ffd
	;out (c),a
         rra
         and 1 ;+cpl?
         ld e,a
	 OS_SETSCREEN

	pop af
	jr z,.noSpr1

	call setShadowScreen
	call respr
	call updateTilesFromBuffer
	;MRestoreMemMap012
        call RestoreMemMap3;0
        call RestoreMemMap12
.noSpr1
	pop iy
	pop ix
	ret

pal_get_address
	ld h,0
	ld l,a
	add hl,hl
	add hl,hl
	add hl,hl
	add hl,hl
         set 7,h
         set 6,h

	;ld bc,MEM_SLOT0
	ld a,PAL_PAGE
	;out (c),a
        call setpgc000;SETPG32KHIGH
	ret



_pal_select
	call pal_get_address

	ld de,_palette
	ld bc,16
	ldir

	ld a,d
	ld (_palChange),a
RestoreMemMap3;0
	;ld bc,MEM_SLOT0
	ld a,CC_PAGE3;0
	;out (c),a
        call setpgc000;SETPG32KHIGH
	ret



_pal_bright
	cp 7
	jr c,.l1
	ld a,6
.l1
	ld h,a
	ld l,0
	srl h
	rr l
	srl h
	rr l
	ld (_palBright),hl
	ld a,1
	ld (_palChange),a
	ret



_pal_copy
	push de
	call pal_get_address

	ld de,palTemp
	ld bc,16
	ldir

	;ld bc,MEM_SLOT0
	ld a,CC_PAGE3;0
	;out (c),a
        call setpgc000;SETPG32KHIGH

	pop de
	ld hl,palTemp
	ld bc,16
	ldir

	ret


prspr
respr
        ;TODO
        ret


;более быстрая версия ldir, эффективна при bc>12
;из статьи на MSX Assembly Page
;в отличие от нормального ldir портит A и флаги

_fast_ldir
DOSorTFM=0
	ifdef DOS
DOSorTFM=1
        endif
	ifdef TFM
DOSorTFM=1
        endif
        
	if DOSorTFM
	ldir
	ret
	else

	xor a
	sub c
	and 63
	add a,a
	ld (.jump),a
.jump=$+1
	jr nz,.loop
.loop
	dup 64
	ldi
	edup
	jp pe,.loop
	ret

	endif ;~DOSorTFM

	align 256	;#nn00
tileUpdateXTable
	dup 8
	db #01,#02,#04,#08,#10,#20,#40,#80
	edup
.x=0
	dup 64
	db .x>>3
.x=.x+1
	edup


	align 256	;#nn00
colorMaskTable
	db #00,#09,#12,#1b,#24,#2d,#36,#3f	;для двух пикселей
	db #c0,#c9,#d2,#db,#e4,#ed,#f6,#ff
	db #00,#01,#02,#03,#04,#05,#06,#07	;для ink
	db #40,#41,#42,#43,#44,#45,#46,#47
	ds 16,0
	db #00,#08,#10,#18,#20,#28,#30,#38	;для paper
	db #80,#88,#90,#98,#a0,#a8,#b0,#b8


	align 256
_sprqueue
_sprqueue0	;формат 4 байта на спрайт, idh,idl,y,x (idh=255 конец списка)
	ds 256,255
_sprqueue1
	ds 256,255

	align 256	;#nn00
scrTable
adr=#4000
	dup 25
	db low adr
adr=adr+(40*8)
	edup
	align 32	;#nn20
adr=#4000
	dup 25
	db high adr
adr=adr+(40*8)
	edup

tileUpdateMap	;битовая карта обновившихся знакомест, 64x25 бит
	ds 8*25,0


	export _pal_select
	export _pal_copy
	export _pal_bright
	export _swap_screen
	export _clear_screen
	export _fast_ldir

        include "int.asm"
        include "lib_tiles.asm"

	export _draw_tile
	export _draw_image
	export _select_image
	export _draw_tile_key
	export _color_key

        include "lib_input.asm"

	export _joystick
	export _keyboard
	export _mouse_apply_clip


;переменные

musicPage		db 0
tileOffset		dw 0
spritesActive	db 0	;1 если вывод спрайтов разрешён
tileUpdate		db 0	;1 если выводились тайлы, для системы обновления фона под спрайтами
palTemp			ds 16,0
keysPrevState	ds 40,0
	ifdef TFM
;turboFM			db 0	;!=0 если есть TFM
	else
turboSound		db 0	;!=0 если есть TS
	endif

;экспортируемые переменные

	macro rgb222 b2,g2,r2
	db (((r2&3)<<4)|((g2&3)<<2)|(b2&3))
	endm

	align 16
_palette
	rgb222(0,0,0)
	rgb222(0,0,2)
	rgb222(2,0,0)
	rgb222(2,0,2)
	rgb222(0,2,0)
	rgb222(0,2,2)
	rgb222(2,2,0)
	rgb222(2,2,2)
	rgb222(0,0,0)
	rgb222(0,0,3)
	rgb222(3,0,0)
	rgb222(3,0,3)
	rgb222(0,3,0)
	rgb222(0,3,3)
	rgb222(3,3,0)
	rgb222(3,3,3)

;_memSlot1
;curpg4000
;        db 0
;_memSlot2
;curpg8000
;        db 0
;_memSlot3
;curpgc000
;        db 0

_borderCol	db 0
_palBright	dw 3<<6
_palChange	db 1
_screenActive	db 0	;~1 или ~3
_mouse_dx	db 0
_mouse_dy	db 0
_mouse_x	db 80
_mouse_y	db 100
_mouse_cx1	db 0
_mouse_cx2	db 160
_mouse_cy1	db 0
_mouse_cy2	db 200
_mouse_btn	db 0
_mouse_prev_dx	db 0
_mouse_prev_dy	db 0
_time		dd 0

	export changescrpg
        
res_path
        db "nedoload",0 ;в этом относительном пути будут лежать все загружаемые данные игры
fnbin
        db "code0.bin",0
fnaddr
        db "addr.bin",0
end        

	display "begin=",begin
	display "end=",end
	display "Size ",/d,end-begin," bytes"
	
	savebin "nedoload.com",begin,end-begin
	
	LABELSLIST "..\..\..\us\user.l"
