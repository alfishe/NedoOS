;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.9.0 #11195 (MINGW32)
;--------------------------------------------------------
	.module evo
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _vsync
	.globl _joystick
	.globl _draw_tile
	.globl _draw_image
	.globl _draw_image_extra
	.globl _memset
	.globl _memcpy
	.globl _pal_select
	.globl _pal_bright
	.globl _pal_copy
	.globl _sfx_play
	.globl _sfx_stop
	.globl _pal_clear
	.globl _pal_col
	.globl _pal_custom
	.globl _draw_tile_key
	.globl _clear_screen
	.globl _select_image
	.globl _color_key
	.globl _time
	.globl _delay
	.globl _swap_screen
	.globl _border
	.globl _keyboard
	.globl _music_play
	.globl _music_stop
	.globl _sample_play
	.globl _rand16
	.globl _set_sprite
	.globl _sprites_start
	.globl _sprites_stop
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _INITIALIZED
;--------------------------------------------------------
; absolute external ram data
;--------------------------------------------------------
	.area _DABS (ABS)
;--------------------------------------------------------
; global & static initialisations
;--------------------------------------------------------
	.area _HOME
	.area _GSINIT
	.area _GSFINAL
	.area _GSINIT
;--------------------------------------------------------
; Home
;--------------------------------------------------------
	.area _HOME
	.area _HOME
;--------------------------------------------------------
; code
;--------------------------------------------------------
	.area _CODE
;..\_sdk\evo.c:6: void vsync(void) __naked
;	---------------------------------
; Function vsync
; ---------------------------------
_vsync::
;..\_sdk\evo.c:11: __endasm;
	halt
	ret
;..\_sdk\evo.c:12: }
;..\_sdk\evo.c:16: u8 joystick(void) __naked
;	---------------------------------
; Function joystick
; ---------------------------------
_joystick::
;..\_sdk\evo.c:20: __endasm;
	jp	0x00001EBE
;..\_sdk\evo.c:21: }
;..\_sdk\evo.c:24: void draw_tile(u8 x,u8 y,u16 tile) __naked
;	---------------------------------
; Function draw_tile
; ---------------------------------
_draw_tile::
;..\_sdk\evo.c:37: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	jp	0x000011BC
;..\_sdk\evo.c:38: }
;..\_sdk\evo.c:40: void draw_image(u8 x,u8 y,u8 id) __naked
;	---------------------------------
; Function draw_image
; ---------------------------------
_draw_image::
;..\_sdk\evo.c:60: __endasm;
	ld	hl,#2
	add	hl,sp
;push	ix
;ld	ix,#0
;add	ix,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a,(hl)
	call	0x000013B7
;pop	ix
	ret
;..\_sdk\evo.c:61: }
;..\_sdk\evo.c:63: void draw_image_extra(u8 x,u8 y,u8 id,u8 width,u8 begx) __naked
;	---------------------------------
; Function draw_image_extra
; ---------------------------------
_draw_image_extra::
;..\_sdk\evo.c:96: __endasm;
	ld	hl,#2
	add	hl,sp ;cy=0
;push	ix
;ld	ix,#0
;add	ix,sp
;ld	a,(_MEMSLOT2)
;push	af
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	scf
	call	0x000013B7
;pop	af
;LD	BC, #0xbff7
;ld	(_MEMSLOT2),a
;out	(c),a
;pop	ix
	ret
;..\_sdk\evo.c:97: }
;..\_sdk\evo.c:100: void memset(void* m,u8 b,u16 len) __naked
;	---------------------------------
; Function memset
; ---------------------------------
_memset::
;..\_sdk\evo.c:122: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ex	de,hl
	ld	d,h
	ld	e,l
	inc	de
	dec	bc
	ld	(hl),a
	jp	0x000004F7
;..\_sdk\evo.c:123: }
;..\_sdk\evo.c:127: void memcpy(void* d,void* s,u16 len) __naked
;	---------------------------------
; Function memcpy
; ---------------------------------
_memcpy::
;..\_sdk\evo.c:147: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	de
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ex	de,hl
	pop	de
	jp	0x000004F7
;..\_sdk\evo.c:148: }
;..\_sdk\evo.c:150: void pal_select(u8 id) __naked
;	---------------------------------
; Function pal_select
; ---------------------------------
_pal_select::
;..\_sdk\evo.c:157: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	jp	0x00000475
;..\_sdk\evo.c:158: }
;..\_sdk\evo.c:162: void pal_bright(u8 bright) __naked
;	---------------------------------
; Function pal_bright
; ---------------------------------
_pal_bright::
;..\_sdk\evo.c:169: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	jp	0x00000489
;..\_sdk\evo.c:170: }
;..\_sdk\evo.c:172: void pal_copy(u8 id,u8* pal) __naked
;	---------------------------------
; Function pal_copy
; ---------------------------------
_pal_copy::
;..\_sdk\evo.c:183: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	jp	0x000004A3
;..\_sdk\evo.c:184: }
;..\_sdk\evo.c:188: void sfx_play(u8 sfx,i8 vol) __naked
;	---------------------------------
; Function sfx_play
; ---------------------------------
_sfx_play::
;..\_sdk\evo.c:197: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	b,(hl)
	inc	hl
	ld	c,(hl)
	jp	0x00001F70
;..\_sdk\evo.c:198: }
;..\_sdk\evo.c:202: void sfx_stop(void) __naked
;	---------------------------------
; Function sfx_stop
; ---------------------------------
_sfx_stop::
;..\_sdk\evo.c:206: __endasm;
	jp	0x00001F84
;..\_sdk\evo.c:207: }
;..\_sdk\evo.c:213: void pal_clear(void) __naked
;	---------------------------------
; Function pal_clear
; ---------------------------------
_pal_clear::
;..\_sdk\evo.c:225: __endasm;
	ld	hl,#0x00002040
	ld	bc,#0x1000
	1$:
	ld	(hl),c
	inc	l
	djnz	1$
	ld	a,h
	ld	(0x00002053),a
	ret
;..\_sdk\evo.c:226: }
;..\_sdk\evo.c:232: void pal_col(u8 id,u8 col) __naked
;	---------------------------------
; Function pal_col
; ---------------------------------
_pal_col::
;..\_sdk\evo.c:249: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	c,(hl)
	ld	hl,#0x00002040
	add	a,l
	ld	l,a
	ld	a,c
	and	#63
	ld	(hl),a
	ld	a,h
	ld	(0x00002053),a
	ret
;..\_sdk\evo.c:250: }
;..\_sdk\evo.c:256: void pal_custom(u8* pal) __naked
;	---------------------------------
; Function pal_custom
; ---------------------------------
_pal_custom::
;..\_sdk\evo.c:277: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	ld	de,#0x00002040
	ld	b,#16
	1$:
	ld	a,(hl)
	and	#63
	ld	(de),a
	inc	hl
	inc	e
	djnz	1$
	ld	a,d
	ld	(0x00002053),a
	ret
;..\_sdk\evo.c:278: }
;..\_sdk\evo.c:283: void draw_tile_key(u8 x,u8 y,u16 tile) __naked
;	---------------------------------
; Function draw_tile_key
; ---------------------------------
_draw_tile_key::
;..\_sdk\evo.c:296: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	jp	0x000012DD
;..\_sdk\evo.c:297: }
;..\_sdk\evo.c:302: void clear_screen(u8 color) __naked
;	---------------------------------
; Function clear_screen
; ---------------------------------
_clear_screen::
;..\_sdk\evo.c:309: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	jp	0x00000411
;..\_sdk\evo.c:310: }
;..\_sdk\evo.c:316: void select_image(u8 id) __naked
;	---------------------------------
; Function select_image
; ---------------------------------
_select_image::
;..\_sdk\evo.c:323: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	l,(hl)
	jp	0x0000118C
;..\_sdk\evo.c:324: }
;..\_sdk\evo.c:328: void color_key(u8 col) __naked
;	---------------------------------
; Function color_key
; ---------------------------------
_color_key::
;..\_sdk\evo.c:335: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	jp	0x000012AF
;..\_sdk\evo.c:336: }
;..\_sdk\evo.c:341: u32 time(void) __naked
;	---------------------------------
; Function time
; ---------------------------------
_time::
;..\_sdk\evo.c:354: __endasm;
	ld	hl,#0x00002060 +3
	ld	d,(hl)
	dec	hl
	ld	e,(hl)
	dec	hl
	ld	a,(hl)
	dec	hl
	ld	l,(hl)
	ld	h,a
	ret
;..\_sdk\evo.c:355: }
;..\_sdk\evo.c:359: void delay(u16 time) __naked
;	---------------------------------
; Function delay
; ---------------------------------
_delay::
;..\_sdk\evo.c:380: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	c,(hl)
	inc	hl
	ld	b,(hl)
	ld	a,b
	or	c
	ret	z
	1$:
	halt
	dec	bc
	ld	a,b
	or	c
	jr	nz,1$
	ret
;..\_sdk\evo.c:381: }
;..\_sdk\evo.c:383: void swap_screen(void) __naked
;	---------------------------------
; Function swap_screen
; ---------------------------------
_swap_screen::
;..\_sdk\evo.c:390: __endasm;
	jp	0x00000432
;..\_sdk\evo.c:391: }
;..\_sdk\evo.c:396: void border(u8 n) __naked
;	---------------------------------
; Function border
; ---------------------------------
_border::
;..\_sdk\evo.c:412: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	ld	(0x00002050),a
;ld	c,a
;and	#7
;bit	3,c
;jr	nz,1$
;out	(0xfe),a
;ret
;1$:
;out	(0xf6),a
	ret
;..\_sdk\evo.c:413: }
;..\_sdk\evo.c:420: void keyboard(u8* keys) __naked
;	---------------------------------
; Function keyboard
; ---------------------------------
_keyboard::
;..\_sdk\evo.c:429: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	jp	0x00001EF5
;..\_sdk\evo.c:430: }
;..\_sdk\evo.c:433: void music_play(u8 mus) __naked
;	---------------------------------
; Function music_play
; ---------------------------------
_music_play::
;..\_sdk\evo.c:440: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl)
	jp	0x00001F8B
;..\_sdk\evo.c:441: }
;..\_sdk\evo.c:445: void music_stop(void) __naked
;	---------------------------------
; Function music_stop
; ---------------------------------
_music_stop::
;..\_sdk\evo.c:449: __endasm;
	jp	0x00001F80
;..\_sdk\evo.c:450: }
;..\_sdk\evo.c:454: void sample_play(u8 sample) __naked
;	---------------------------------
; Function sample_play
; ---------------------------------
_sample_play::
;..\_sdk\evo.c:461: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	l,(hl)
	jp	0x00001F27
;..\_sdk\evo.c:462: }
;..\_sdk\evo.c:466: u16 rand16(void) __naked
;	---------------------------------
; Function rand16
; ---------------------------------
_rand16::
;..\_sdk\evo.c:489: __endasm;
	ld	hl,(1$)
	push	hl
	srl	h
	rr	l
	ex	de,hl
	ld	hl,(2$)
	add	hl,de
	ld	(2$),hl
	ld	a,l
	xor	#15
	ld	l,a
	ex	de,hl
	pop	hl
	sbc	hl,de
	ld	(1$),hl
	ret
	1$:
	.dw 1
	2$:
	.dw 5
;..\_sdk\evo.c:490: }
;..\_sdk\evo.c:582: void set_sprite(u8 id,u8 x,u8 y,u16 spr) __naked
;	---------------------------------
; Function set_sprite
; ---------------------------------
_set_sprite::
;..\_sdk\evo.c:622: __endasm;
	ld	hl,#2
	add	hl,sp
	ld	a,(hl) ;id
	inc	hl
	ld	c,(hl) ;x
	inc	hl
	ld	b,(hl) ;y
	inc	hl
	ld	e,(hl) ;sprl
	inc	hl
	ld	d,(hl) ;sprh
	add	a,a
	add	a,a
	ld	l,a
	ld	h,#0x00000800/256
	ld	a,d ;пересчёт номера спрайта
	cp	#255
	jr	z,1$
	add	a,a
	add	a,d
	ld	d,a
	1$:
	ld	a,(0x00002054)
	and	#2
	jr	nz,2$
	inc	h
	2$:
	ld	(hl),d
	inc	l
	ld	(hl),e
	inc	l
	ld	(hl),b
	inc	l
	ld	(hl),c
	ret
;..\_sdk\evo.c:623: }
;..\_sdk\evo.c:627: void sprites_start(void) __naked
;	---------------------------------
; Function sprites_start
; ---------------------------------
_sprites_start::
;..\_sdk\evo.c:631: __endasm;
	jp	0x0000158B
;..\_sdk\evo.c:632: }
;..\_sdk\evo.c:636: void sprites_stop(void) __naked
;	---------------------------------
; Function sprites_stop
; ---------------------------------
_sprites_stop::
;..\_sdk\evo.c:640: __endasm;
	jp	0x000015DE
;..\_sdk\evo.c:641: }
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
