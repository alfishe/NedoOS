        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

BINADDR=0x4000

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

SND_PAGE=0;(0^INVMASK)
SPTBL_PAGE=1;(6^INVMASK)
PAL_PAGE=2;(4^INVMASK)

SPBUF_PAGE0=3;(8^INVMASK)
SPBUF_PAGE1=4;(9^INVMASK)
SPBUF_PAGE2=5;(10^INVMASK)
SPBUF_PAGE3=6;(11^INVMASK)

CC_PAGE1=7;(13^INVMASK)
CC_PAGE2=8;(14^INVMASK)
CC_PAGE3=9;(12^INVMASK)

GFX_PAGE=10;(16^INVMASK) ;и далее

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
        call setpgsscr40008000
	endm

	macro MRestoreMemMap012
;TODO переделать на (pgmain4000) и т.п. (сейчас с пересчётом по таблице)
	ld a,CC_PAGE3
        call setpgc000;SETPG32KHIGH
	ld a,CC_PAGE1
        call setpg4000;SETPG16K
	ld a,CC_PAGE2
        call setpg8000;SETPG32KLOW
	endm

	macro MRestoreMemMap12
	ld a,CC_PAGE1
        call setpg4000;SETPG16K
	ld a,CC_PAGE2
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

        ld e,0+128 ;+128=keep
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
        ld (tpages+CC_PAGE1),a
        ld a,h
        LD (pgmain8000),A
        ld (tpages+CC_PAGE2),a
        ld a,l
        ld (tpages+CC_PAGE3),a
        call setpgsmain40008000 ;записать в curpg...

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

        ld hl,sndfilename
        call loadpage ;CY=error
        ld (tpages+0),a
        ld hl,sprtblfilename
        call loadpage ;CY=error
        ld (tpages+1),a
        ld hl,palfilename
        call loadpage ;CY=error
        ld (tpages+2),a

        ld de,tpages+GFX_PAGE

        ;ld b,NUMBER_OF_PAGES
loadloop0
        ;push bc
        push de
        ld hl,texfilename
        call loadpage ;CY=error
        pop de
       jr c,loadloop0q
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
        jr loadloop0
        ;pop bc
        ;djnz loadloop0
loadloop0q
        
        ld hl,tpages+SPBUF_PAGE0
        ld b,4
mkpages0
        push bc
        push hl
        OS_NEWPAGE
        pop hl
        ld (hl),e
        inc l
        pop bc
        djnz mkpages0

        call initsfx

        call swapimer

        call setpgsmain40008000
        call RestoreMemMap3
        ld de,fnbin
        ld hl,0x4000
        call loadbinpg
        ld de,fnbin2
        ld hl,0x8000
        call loadbinpg
        ld de,fnbin3
        ld hl,0xc000
        call loadbinpg
        
        ld de,CURPAL
        OS_SETPAL

        call _swap_screen
jpaddr=$+1
        call 0

quit ;TODO
        call swapimer
        call _music_stop
        halt
        QUIT

        ds 0x0200-$
tpages
        ds 256 ;pages

loadbinpg
        push hl
        OS_OPENHANDLE
        pop de ;addr
        push bc
        ld hl,-BINADDR ;size
        OS_READHANDLE
        pop bc
        OS_CLOSEHANDLE                
        ret

loadpage
;заказывает страничку и грузит туда файл (имя файла в hl)
;out: hl=после имени файла, a=pg
;or else CY
        push hl
        ex de,hl
        OS_OPENHANDLE
        pop hl
        or a
        scf
        ret nz
        push hl
       push bc
        OS_NEWPAGE
       pop bc
        pop hl
        ld a,e
        push af ;pg
       push bc
        SETPGC000
       pop bc
        push hl
        ex de,hl
        ;OS_OPENHANDLE
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
        or a ;CY=0
        ret

CURPAL
;DDp palette: %grbG11RB(low),%grbG11RB(high), инверсные
        STANDARDPAL

sndfilename
        db "page_0.bin",0
sprtblfilename
        db "page_1.bin",0
palfilename
        db "page_2.bin",0

texfilename
texfilename_pgnumend=$+7;8
        db "page_10.bin",0




setpgsmain40008000
pgmain4000=$+1
        ld a,0
        SETPG4000
pgmain8000=$+1
        ld a,0
        SETPG8000
        ret

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
        call changescrpg_current
	ld e,a
	OS_SETSCREEN
        ret

setpg4000
        ld b,tpages/256
        ld c,a
        ld a,(bc)
        SETPG16K
        ret

setpg8000
        ld b,tpages/256
        ld c,a
        ld a,(bc)
        SETPG32KLOW
        ret

setpgc000
        ld b,tpages/256
        ld c,a
        ld a,(bc)
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
	;push iy

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
	ld (_screenActive),a ;for select sprqueue
        call changescrpg

	pop af
	jr z,.noSpr1

	call setShadowScreen
	call respr
	call updateTilesFromBuffer
        call RestoreMemMap3;0
        call RestoreMemMap12
.noSpr1
	;pop iy
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

	ld a,PAL_PAGE
        jp setpgc000;SETPG32KHIGH


_pal_select
	call pal_get_address

	ld de,_palette
	ld bc,16
	ldir

	ld a,d
	ld (_palChange),a
RestoreMemMap3;0
	ld a,CC_PAGE3;0
        jp setpgc000;SETPG32KHIGH



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

	ld a,CC_PAGE3;0
        call setpgc000;SETPG32KHIGH

	pop de
	ld hl,palTemp
	ld bc,16
	ldir
	ret


_load_from_file
	
	;file name > de
	ld iy,#2
	add iy,sp
	ld e,(iy)
	inc iy
	ld d,(iy)
	
	OS_OPENHANDLE
	or a
	jp nz,err_exit
	push bc
	ld de,#D000 ;addr
	ld hl,80 ;size
	OS_READHANDLE
	pop bc
	OS_CLOSEHANDLE
	ret
err_exit
	;file name > de
	ld iy,#2
	add iy,sp
	ld e,(iy)
	inc iy
	ld d,(iy)
	
	OS_CREATEHANDLE
	push bc
	push ix
	ld de,#D000 ;addr
	ld hl,80 ;size
	OS_WRITEHANDLE
	pop ix
	pop bc
	OS_CLOSEHANDLE
	ret



_save_to_file
	;file name > de
	ld iy,#2
	add iy,sp
	ld e,(iy)
	inc iy
	ld d,(iy)
	
	OS_OPENHANDLE
	push bc
	push ix
	ld de,#D000 ;addr
	ld hl,80 ;size
	OS_WRITEHANDLE
	pop ix
	pop bc
	OS_CLOSEHANDLE
	ret
	
	
	
_exit
	ld hl,0
	QUIT


;более быстрая версия ldir, эффективна при bc>12
;из статьи на MSX Assembly Page
;в отличие от нормального ldir портит A и флаги
_fast_ldir
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

	align 256
palBrightTable
	db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff	;bright 0
	db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
	db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
	db #ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff,#ff
	db #ff,#ff,#ff,#bf,#ff,#ff,#ff,#bf,#ff,#ff,#ff,#bf,#7f,#7f,#7f,#3f	;bright 1
	db #ff,#ff,#ff,#bf,#ff,#ff,#ff,#bf,#ff,#ff,#ff,#bf,#7f,#7f,#7f,#3f
	db #ff,#ff,#ff,#bf,#ff,#ff,#ff,#bf,#ff,#ff,#ff,#bf,#7f,#7f,#7f,#3f
	db #df,#df,#df,#9f,#df,#df,#df,#9f,#df,#df,#df,#9f,#5f,#5f,#5f,#1f
	db #ff,#ff,#bf,#fd,#ff,#ff,#bf,#fd,#7f,#7f,#3f,#7d,#ef,#ef,#af,#ed	;bright 2
	db #ff,#ff,#bf,#fd,#ff,#ff,#bf,#fd,#7f,#7f,#3f,#7d,#ef,#ef,#af,#ed
	db #df,#df,#9f,#dd,#df,#df,#9f,#dd,#5f,#5f,#1f,#5d,#cf,#cf,#8f,#cd
	db #fe,#fe,#be,#fc,#fe,#fe,#be,#fc,#7e,#7e,#3e,#7c,#ee,#ee,#ae,#ec
	db #ff,#bf,#fd,#bd,#7f,#3f,#7d,#3d,#ef,#af,#ed,#ad,#6f,#2f,#6d,#2d	;bright 3
	db #df,#9f,#dd,#9d,#5f,#1f,#5d,#1d,#cf,#8f,#cd,#8d,#4f,#0f,#4d,#0d
	db #fe,#be,#fc,#bc,#7e,#3e,#7c,#3c,#ee,#ae,#ec,#ac,#6e,#2e,#6c,#2c
	db #de,#9e,#dc,#9c,#5e,#1e,#5c,#1c,#ce,#8e,#cc,#8c,#4e,#0e,#4c,#0c
	db #1f,#5d,#1d,#1d,#8f,#cd,#8d,#8d,#0f,#4d,#0d,#0d,#0f,#4d,#0d,#0d	;bright 4
	db #3e,#7c,#3c,#3c,#ae,#ec,#ac,#ac,#2e,#6c,#2c,#2c,#2e,#6c,#2c,#2c
	db #1e,#5c,#1c,#1c,#8e,#cc,#8c,#8c,#0e,#4c,#0c,#0c,#0e,#4c,#0c,#0c
	db #1e,#5c,#1c,#1c,#8e,#cc,#8c,#8c,#0e,#4c,#0c,#0c,#0e,#4c,#0c,#0c
	db #ec,#ac,#ac,#ac,#6c,#2c,#2c,#2c,#6c,#2c,#2c,#2c,#6c,#2c,#2c,#2c	;bright 5
	db #cc,#8c,#8c,#8c,#4c,#0c,#0c,#0c,#4c,#0c,#0c,#0c,#4c,#0c,#0c,#0c
	db #cc,#8c,#8c,#8c,#4c,#0c,#0c,#0c,#4c,#0c,#0c,#0c,#4c,#0c,#0c,#0c
	db #cc,#8c,#8c,#8c,#4c,#0c,#0c,#0c,#4c,#0c,#0c,#0c,#4c,#0c,#0c,#0c
	db #0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c	;bright 6
	db #0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c
	db #0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c
	db #0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c,#0c

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

	align 256	;#nn00
tileUpdateMap	;битовая карта обновившихся знакомест, 64x25 бит
	ds 8*25,0

	export _pal_select
	export _pal_copy
	export _pal_bright
	export _swap_screen
	export _clear_screen
	export _fast_ldir
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	export _load_from_file
	export _save_to_file
	export _exit
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
		include "../_sdk/lib_int.asm"
        include "../_sdk/lib_tiles.asm"
	export _draw_tile
	export _draw_image
	export _select_image
	export _draw_tile_key
	export _color_key

        include "../_sdk/lib_sprites.asm"
	export _sprites_start
	export _sprites_stop

        include "../_sdk/lib_input.asm"
	export _joystick
	export _keyboard
	export _mouse_apply_clip

        include "../_sdk/lib_sound.asm"
        export _music_play
        export _music_stop
        export _sample_play
        export _sfx_play
        export _sfx_stop

;переменные

musicPage	db 0
tileOffset	dw 0
spritesActive	db 0	;1 если вывод спрайтов разрешён
tileUpdate	db 0	;1 если выводились тайлы, для системы обновления фона под спрайтами
palTemp		ds 16,0
keysPrevState	ds 40,0
	ifdef TFM
;turboFM	db 0	;!=0 если есть TFM
	else
turboSound	db 0	;!=0 если есть TS
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

	export _borderCol
	export _palBright
	export _palChange
	export _sprqueue
	export _screenActive
	export _mouse_dx
	export _mouse_dy
	export _mouse_x
	export _mouse_y
	export _mouse_cx1
	export _mouse_cx2
	export _mouse_cy1
	export _mouse_cy2
	export _mouse_btn
	export _time
    export _palette

        
res_path
;в этом относительном пути будут лежать все загружаемые данные игры
        ;db "nedoload"
        include "_temp_/sets.asm"
        db 0
fnbin
        db "page_101.bin",0
fnbin2
        db "page_102.bin",0
fnbin3
        db "page_103.bin",0
fnaddr
        db "addr.bin",0

		
end
	savebin "nedoload.com",begin,end-begin
	LABELSLIST "..\..\..\us\user.l"
