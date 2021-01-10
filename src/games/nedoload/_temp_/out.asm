;--------------------------------------------------------
; File Created by SDCC : free open source ANSI-C Compiler
; Version 3.9.0 #11195 (MINGW32)
;--------------------------------------------------------
	.module main
	.optsdcc -mz80
	
;--------------------------------------------------------
; Public variables in this module
;--------------------------------------------------------
	.globl _main
	.globl _setTileUpdateMap
	.globl _do_scrollup
	.globl _do_scrollup_looped
	.globl _do_scrollup_sector
	.globl _do_scrolldown
	.globl _do_scrolldown_looped
	.globl _do_scrolldown_sector
	.globl _set_sprite
	.globl _sprites_start
	.globl _swap_screen
	.globl _draw_image
	.globl _draw_tile
	.globl _select_image
	.globl _pal_select
;--------------------------------------------------------
; special function registers
;--------------------------------------------------------
;--------------------------------------------------------
; ram data
;--------------------------------------------------------
	.area _DATA
_gl_addr:
	.ds 2
_gl_page:
	.ds 1
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
;main.c:88: void do_scrolldown_sector(u8 shift,u8 start, u8 finish) __naked
;	---------------------------------
; Function do_scrolldown_sector
; ---------------------------------
_do_scrolldown_sector::
;main.c:258: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	a,(0x0000FF57)
	bit	1,a
	jr	z,secpageds
	frstpageds:
	ld	a,#0x1
	jp	dopageds
	secpageds:
	ld	a,#0x3
	dopageds:
	ld	(_gl_page),a
	begds:
	ld	a,(_gl_page)
	xor	#0x7f
	ld	bc,#0xbff7
	ld	(0x0000FF52),a
	out	(c),a
	beg2ds:
	ld	c,#0x0
	ld	b, 4 (ix)
	dec	b
	ld	hl,#0x28
	ld	de,#0x28
	jr	z,zerds
	mulds:
	add	hl,de
	djnz	mulds
	zerds:
	ld	de,(_gl_addr)
	ld	b,h
	ld	c,l
	add	hl,de
	ld	de,#0x1f40
	add	hl,de
	push	hl
	ld	hl,(_gl_addr)
	ld	de,#0x1f40
	add	hl,de
	pop	de
	ld	a,6 (ix)
	ld	c,5 (ix)
	ld	b,#0x0
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	sub	c
	push	af
	push	bc
	ld	b,#0xc9
	movds:
	push	bc
	push	hl
	push	de
	ld	b,#0x0
	ld	c,a
	ldir
	pop	hl
	ld	bc,#0x28
	sbc	hl, bc
	ld	d,h
	ld	e,l
	pop	hl
	sbc	hl, bc
	pop	bc
	djnz	movds
	pop	bc
	ld	hl,(_gl_addr)
	ld	de,#0x1f40
	add	hl,de
	add	hl,bc
	ex	de,hl
	ld	hl,(_gl_addr)
	add	hl,bc
	ex	de,hl
	pop	bc
	ld	a,b
	ld	c,#0x0
	ld	b, 4 (ix)
	adcpyds:
	push	bc
	ld	b,#0x0
	ld	c,a
	push	hl
	push	de
	ldir
	pop	de
	pop	hl
	ld	bc,#0x28
	add	hl, bc
	ex	de,hl
	add	hl, bc
	ex	de,hl
	pop	bc
	djnz	adcpyds
	ld	hl,(_gl_addr)
	ld	bc,#0x8000
	sbc	hl,bc
	jr	z,addrifds
	jp	nxtds
	addrifds:
	ld	hl,#0xa000
	ld(_gl_addr),hl
	jp	beg2ds
	nxtds:
	ld	hl,#0x8000
	ld(_gl_addr),hl
	ld	a,(_gl_page)
	ld	b,#0x1
	sub	b
	jr	z, frst_chngds
	jp	next_page_ifds
	frst_chngds:
	ld	a,#0x5
	ld	(_gl_page),a
	jp	begds
	next_page_ifds:
	ld	a,(_gl_page)
	ld	b,#0x3
	sub	b
	jr	z, sec_chngds
	jp	endds
	sec_chngds:
	ld	a,#0x7
	ld	(_gl_page),a
	jp	begds
	endds:
	ld bc,#0xbff7
	ld	a,#0x71
	out	(c),a
	pop	ix
	ret
;main.c:259: }
;main.c:260: void do_scrolldown_looped(u8 shift) __naked
;	---------------------------------
; Function do_scrolldown_looped
; ---------------------------------
_do_scrolldown_looped::
;main.c:370: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	bc,#0x7ffd
	ld	a,(0x0000FF57)
	bit	1,a
	jr	z,secpagedl
	frstpagedl:
	ld	a,#0x1
	jp	dopagedl
	secpagedl:
	ld	a,#0x3
	dopagedl:
	ld	(_gl_page),a
	begdl:
	ld	a,(_gl_page)
	xor	#0x7f
	ld	bc,#0xbff7
	ld	(0x0000FF52),a
	out	(c),a
	beg2dl:
	ld	c,#0x0
	ld	b, 4 (ix)
	dec	b
	ld	hl,#0x28
	ld	de,#0x28
	jr	z,zerdl
	muldl:
	add	hl,de
	djnz	muldl
	zerdl:
	ld	de,(_gl_addr)
	ld	b,h
	ld	c,l
	push	bc
	add	hl,de
	ld	de,#0x1f40
	add	hl,de
	push	hl
	ld	hl,(_gl_addr)
	add	hl,de
	push	hl
	ld	hl,#0x1f40
	ld	b,h
	ld	c,l
	inc	bc
	pop	hl
	pop	de
	push	hl
	lddr
	pop	hl
	pop	bc
	ld	de,(_gl_addr)
	ldir
	ld	hl,(_gl_addr)
	ld	bc,#0x8000
	sbc	hl,bc
	jr	z,addrifdl
	jp	nxtdl
	addrifdl:
	ld	hl,#0xa000
	ld(_gl_addr),hl
	jp	beg2dl
	nxtdl:
	ld	hl,#0x8000
	ld(_gl_addr),hl
	ld	a,(_gl_page)
	ld	b,#0x1
	sub	b
	jr	z, frst_chngdl
	jp	next_page_ifdl
	frst_chngdl:
	ld	a,#0x5
	ld	(_gl_page),a
	jp	begdl
	next_page_ifdl:
	ld	a,(_gl_page)
	ld	b,#0x3
	sub	b
	jr	z, sec_chngdl
	jp	enddl
	sec_chngdl:
	ld	a,#0x7
	ld	(_gl_page),a
	jp	begdl
	enddl:
	ld bc,#0xbff7
	ld	a,#0x71
	out	(c),a
	pop	ix
	ret
;main.c:371: }
;main.c:372: void do_scrolldown(u8 shift) __naked
;	---------------------------------
; Function do_scrolldown
; ---------------------------------
_do_scrolldown::
;main.c:478: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	a,(0x0000FF57)
	bit	1,a
	jr	z,secpaged
	frstpaged:
	ld	a,#0x1
	jp	dopaged
	secpaged:
	ld	a,#0x3
	dopaged:
	ld	(_gl_page),a
	begd:
	ld	a,(_gl_page)
	xor	#0x7f
	ld	bc,#0xbff7
	ld	(0x0000FF52),a
	out	(c),a
	beg2d:
	ld	c,#0x0
	ld	b, 4 (ix)
	dec	b
	ld	hl,#0x28
	ld	de,#0x28
	jr	z,zerd
	muld:
	add	hl,de
	djnz	muld
	zerd:
	ld	de,(_gl_addr)
	ld	b,h
	ld	c,l
	add	hl,de
	ld	de,#0x1f40
	add	hl,de
	push	hl
	ld	hl,(_gl_addr)
	add	hl,de
	push	hl
	ld	hl,#0x1f40
	sbc	hl,bc
	ld	b,h
	ld	c,l
	pop	hl
	pop	de
	lddr
	ld	hl,(_gl_addr)
	ld	bc,#0x8000
	sbc	hl,bc
	jr	z,addrifd
	jp	nxtd
	addrifd:
	ld	hl,#0xa000
	ld(_gl_addr),hl
	jp	beg2d
	nxtd:
	ld	hl,#0x8000
	ld(_gl_addr),hl
	ld	a,(_gl_page)
	ld	b,#0x1
	sub	b
	jr	z, frst_chngd
	jp	next_page_ifd
	frst_chngd:
	ld	a,#0x5
	ld	(_gl_page),a
	jp	begd
	next_page_ifd:
	ld	a,(_gl_page)
	ld	b,#0x3
	sub	b
	jr	z, sec_chngd
	jp	endd
	sec_chngd:
	ld	a,#0x7
	ld	(_gl_page),a
	jp	begd
	endd:
	ld bc,#0xbff7
	ld	a,#0x71
	out	(c),a
	pop	ix
	ret
;main.c:479: }
;main.c:481: void do_scrollup_sector(u8 shift,u8 start, u8 finish) __naked
;	---------------------------------
; Function do_scrollup_sector
; ---------------------------------
_do_scrollup_sector::
;main.c:616: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	a,(0x0000FF57)
	bit	1,a
	jr	z,secpages
	frstpages:
	ld	a,#0x1
	jp	dopages
	secpages:
	ld	a,#0x3
	dopages:
	ld	(_gl_page),a
	begs:
	ld	a,(_gl_page)
	xor	#0x7f
	ld	bc,#0xbff7
	ld	(0x0000FF52),a
	out	(c),a
	beg2s:
	ld	bc,#0xA0
	ld	hl,(_gl_addr)
	ld	de,#0x1f40
	add	hl,de
	ld	d,h
	ld	e,l
	ld	hl,(_gl_addr)
	ldir
	ld	c,#0x0
	ld	b, 4 (ix)
	dec	b
	ld	hl,#0x28
	ld	de,#0x28
	jr	z,zers
	muls:
	add	hl,de
	djnz	muls
	zers:
	ld	de,(_gl_addr)
	ld	b,h
	ld	c,l
	add	hl,de
	ld	de,(_gl_addr)
	ld	a,6 (ix)
	ld	c,5 (ix)
	ld	b,#0x0
	add	hl,bc
	ex	de,hl
	add	hl,bc
	ex	de,hl
	sub	c
	ld	b,#0xc9
	movs:
	push	bc
	push	hl
	push	de
	ld	b,#0x0
	ld	c,a
	ldir
	pop	hl
	ld	bc,#0x28
	add	hl, bc
	ld	d,h
	ld	e,l
	pop	hl
	add	hl, bc
	pop	bc
	djnz	movs
	ld	hl,(_gl_addr)
	ld	bc,#0x8000
	sbc	hl,bc
	jr	z,addrifs
	jp	nxts
	addrifs:
	ld	hl,#0xa000
	ld(_gl_addr),hl
	jp	beg2s
	nxts:
	ld	hl,#0x8000
	ld(_gl_addr),hl
	ld	a,(_gl_page)
	ld	b,#0x1
	sub	b
	jr	z, frst_chngs
	jp	next_page_ifs
	frst_chngs:
	ld	a,#0x5
	ld	(_gl_page),a
	jp	begs
	next_page_ifs:
	ld	a,(_gl_page)
	ld	b,#0x3
	sub	b
	jr	z, sec_chngs
	jp	ends
	sec_chngs:
	ld	a,#0x7
	ld	(_gl_page),a
	jp	begs
	ends:
	ld bc,#0xbff7
	ld	a,#0x71
	out	(c),a
	pop	ix
	ret
;main.c:617: }
;main.c:619: void do_scrollup_looped(u8 shift) __naked
;	---------------------------------
; Function do_scrollup_looped
; ---------------------------------
_do_scrollup_looped::
;main.c:733: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	bc,#0x7ffd
	ld	a,(0x0000FF57)
	bit	1,a
	jr	z,secpagel
	frstpagel:
	ld	a,#0x1
	jp	dopagel
	secpagel:
	ld	a,#0x3
	dopagel:
	ld	(_gl_page),a
	begl:
	ld	a,(_gl_page)
	xor	#0x7f
	ld	bc,#0xbff7
	ld	(0x0000FF52),a
	out	(c),a
	beg2l:
	ld	c,#0x0
	ld	b, 4 (ix)
	dec	b
	ld	hl,#0x28
	ld	de,#0x28
	jr	z,zerl
	mull:
	add	hl,de
	djnz	mull
	zerl:
	ld	de,(_gl_addr)
	ld	b,h
	ld	c,l
	add	hl,de
	push	hl
	ld	hl,(_gl_addr)
	ld	de,#0x1f40
	add	hl,de
	ld	d,h
	ld	e,l
	ld	hl,(_gl_addr)
	ldir
	ld	de,(_gl_addr)
	ld	hl,#0x1f40
	sbc	hl,bc
	ld	b,h
	ld	c,l
	pop	hl
	ldir
	ld	hl,(_gl_addr)
	ld	bc,#0x8000
	sbc	hl,bc
	jr	z,addrifl
	jp	nxtl
	addrifl:
	ld	hl,#0xa000
	ld(_gl_addr),hl
	jp	beg2l
	nxtl:
	ld	hl,#0x8000
	ld(_gl_addr),hl
	ld	a,(_gl_page)
	ld	b,#0x1
	sub	b
	jr	z, frst_chngl
	jp	next_page_ifl
	frst_chngl:
	ld	a,#0x5
	ld	(_gl_page),a
	jp	begl
	next_page_ifl:
	ld	a,(_gl_page)
	ld	b,#0x3
	sub	b
	jr	z, sec_chngl
	jp	endl
	sec_chngl:
	ld	a,#0x7
	ld	(_gl_page),a
	jp	begl
	endl:
	ld bc,#0xbff7
	ld	a,#0x71
	out	(c),a
	pop	ix
	ret
;main.c:734: }
;main.c:736: void do_scrollup(u8 shift) __naked
;	---------------------------------
; Function do_scrollup
; ---------------------------------
_do_scrollup::
;main.c:835: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	bc,#0x7ffd
	ld	a,(0x0000FF57)
	bit	1,a
	jr	z,secpage
	frstpage:
	ld	a,#0x1
	jp	dopage
	secpage:
	ld	a,#0x3
	dopage:
	ld	(_gl_page),a
	beg:
	ld	a,(_gl_page)
	xor	#0x7f
	ld	bc,#0xbff7
	ld	(0x0000FF52),a
	out	(c),a
	beg2:
	ld	c,#0x0
	ld	b, 4 (ix)
	dec	b
	ld	hl,#0x28
	ld	de,#0x28
	jr	z,zer
	mul:
	add	hl,de
	djnz	mul
	zer:
	ld	de,(_gl_addr)
	ld	b,h
	ld	c,l
	add	hl,de
	push	hl
	ld	de,(_gl_addr)
	ld	hl,#0x1f40
	sbc	hl,bc
	ld	b,h
	ld	c,l
	pop	hl
	ldir
	ld	hl,(_gl_addr)
	ld	bc,#0x8000
	sbc	hl,bc
	jr	z,addrif
	jp	nxt
	addrif:
	ld	hl,#0xa000
	ld(_gl_addr),hl
	jp	beg2
	nxt:
	ld	hl,#0x8000
	ld(_gl_addr),hl
	ld	a,(_gl_page)
	ld	b,#0x1
	sub	b
	jr	z, frst_chng
	jp	next_page_if
	frst_chng:
	ld	a,#0x5
	ld	(_gl_page),a
	jp	beg
	next_page_if:
	ld	a,(_gl_page)
	ld	b,#0x3
	sub	b
	jr	z, sec_chng
	jp	end
	sec_chng:
	ld	a,#0x7
	ld	(_gl_page),a
	jp	beg
	end:
	ld bc,#0xbff7
	ld	a,#0x71
	out	(c),a
	pop	ix
	ret
;main.c:836: }
;main.c:838: void setTileUpdateMap(u8 x,u8 y) __naked
;	---------------------------------
; Function setTileUpdateMap
; ---------------------------------
_setTileUpdateMap::
;main.c:867: __endasm;
	push	ix
	ld	ix,#0
	add	ix,sp
	ld	a,#0x1
	ld	c,4 (ix)
	ld	b,5 (ix)
	call	(#0xe644)
	inc	b
	call	(#0xe644)
	inc	b
	call	(#0xe644)
	inc	c
	call	(#0xe644)
	inc	c
	call	(#0xe644)
	dec	b
	call	(#0xe644)
	dec	b
	call	(#0xe644)
	dec	c
	call	(#0xe644)
	inc	b
	call	(#0xe644)
	pop	ix
	ret
;main.c:868: }
;main.c:869: void main(void)
;	---------------------------------
; Function main
; ---------------------------------
_main::
	call	___sdcc_enter_ix
	push	af
	push	af
	push	af
	push	af
;main.c:875: gl_addr=32768;
	ld	hl, #0x8000
	ld	(_gl_addr), hl
;main.c:879: select_image(IMG_BG);
	xor	a, a
	push	af
	inc	sp
	call	_select_image
	inc	sp
;main.c:880: draw_tile(1,1,0);
	ld	hl, #0x0000
	push	hl
	ld	de, #0x0101
	push	de
	call	_draw_tile
	pop	af
	pop	af
;main.c:881: sprites_start();
	call	_sprites_start
;main.c:882: pal_select(PAL_BG);
	xor	a, a
	push	af
	inc	sp
	call	_pal_select
	inc	sp
;main.c:883: draw_image(0,0,IMG_BG);
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	call	_draw_image
	pop	af
	inc	sp
;main.c:885: do_scrolldown_sector(2,10,15);
	ld	de, #0x0f0a
	push	de
	ld	a, #0x02
	push	af
	inc	sp
	call	_do_scrolldown_sector
	pop	af
	inc	sp
;main.c:886: do_scrolldown_sector(2,17,18);
	ld	de, #0x1211
	push	de
	ld	a, #0x02
	push	af
	inc	sp
	call	_do_scrolldown_sector
	pop	af
	inc	sp
;main.c:887: do_scrolldown_sector(2,26,30);
	ld	de, #0x1e1a
	push	de
	ld	a, #0x02
	push	af
	inc	sp
	call	_do_scrolldown_sector
	pop	af
	inc	sp
;main.c:889: swap_screen();
	call	_swap_screen
;main.c:890: draw_image(0,0,IMG_BG);
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	xor	a, a
	push	af
	inc	sp
	call	_draw_image
	pop	af
	inc	sp
;main.c:895: step=0;
	ld	-4 (ix), #0x00
;main.c:896: x2=128;
	ld	-8 (ix), #0x80
;main.c:897: y2=24;
	ld	-7 (ix), #0x18
;main.c:898: x=64;
	ld	-6 (ix), #0x40
;main.c:899: y=80;
	ld	-5 (ix), #0x50
;main.c:900: dx=2;
	ld	-3 (ix), #0x02
;main.c:901: dy=4;
	ld	-2 (ix), #0x04
;main.c:902: dx2=-2;
	ld	-1 (ix), #0xfe
;main.c:903: dy2=-4;
	ld	c, #0xfc
;main.c:907: while(1)
00122$:
;main.c:912: x+=dx;
	ld	a, -6 (ix)
	add	a, -3 (ix)
	ld	-6 (ix), a
;main.c:913: y+=dy;
	ld	a, -5 (ix)
	add	a, -2 (ix)
	ld	-5 (ix), a
;main.c:914: x2+=dx2;
	ld	a, -8 (ix)
	add	a, -1 (ix)
	ld	-8 (ix), a
;main.c:915: y2+=dy2;
	ld	a, -7 (ix)
	add	a, c
	ld	-7 (ix), a
;main.c:916: if(x>=140)dx=-dx;
	ld	a, -6 (ix)
	sub	a, #0x8c
	jr	C,00102$
	xor	a, a
	sub	a, -3 (ix)
	ld	-3 (ix), a
00102$:
;main.c:917: if(x<2)dx=-dx;
	ld	a, -6 (ix)
	sub	a, #0x02
	jr	NC,00104$
	xor	a, a
	sub	a, -3 (ix)
	ld	-3 (ix), a
00104$:
;main.c:918: if(y>182)dy=-dy;
	ld	a, #0xb6
	sub	a, -5 (ix)
	jr	NC,00106$
	xor	a, a
	sub	a, -2 (ix)
	ld	-2 (ix), a
00106$:
;main.c:919: if(y<2)dy=-dy;
	ld	a, -5 (ix)
	sub	a, #0x02
	jr	NC,00108$
	xor	a, a
	sub	a, -2 (ix)
	ld	-2 (ix), a
00108$:
;main.c:921: if(x2>=140)dx2=-dx2;
	ld	a, -8 (ix)
	sub	a, #0x8c
	jr	C,00110$
	xor	a, a
	sub	a, -1 (ix)
	ld	-1 (ix), a
00110$:
;main.c:922: if(x2<2)dx2=-dx2;
	ld	a, -8 (ix)
	sub	a, #0x02
	jr	NC,00112$
	xor	a, a
	sub	a, -1 (ix)
	ld	-1 (ix), a
00112$:
;main.c:923: if(y2>182)dy2=-dy2;
	ld	a, #0xb6
	sub	a, -7 (ix)
	jr	NC,00114$
	xor	a, a
	sub	a, c
	ld	c, a
00114$:
;main.c:924: if(y2<2)dy2=-dy2;
	ld	a, -7 (ix)
	sub	a, #0x02
	jr	NC,00116$
	xor	a, a
	sub	a, c
	ld	c, a
00116$:
;main.c:925: set_sprite(0,x,y,0);
	push	bc
	ld	hl, #0x0000
	push	hl
	ld	h, -5 (ix)
	ld	l, -6 (ix)
	push	hl
	xor	a, a
	push	af
	inc	sp
	call	_set_sprite
	pop	af
	inc	sp
	ld	hl,#0x0000
	ex	(sp),hl
	ld	a, -7 (ix)
	push	af
	inc	sp
	ld	d, -8 (ix)
	ld	e,#0x01
	push	de
	call	_set_sprite
	pop	af
	pop	af
	inc	sp
	pop	bc
;main.c:928: if(step==0)//нужно для того, чтобы спрайты не портили скролирующийся фон под собой
	ld	a, -4 (ix)
	or	a, a
	jr	NZ,00118$
;main.c:930: xx=x>>2;
	ld	b, -6 (ix)
	srl	b
	srl	b
;main.c:931: yy=y>>3;
	ld	a, -5 (ix)
	rrca
	rrca
	rrca
	and	a, #0x1f
;main.c:932: setTileUpdateMap(xx,yy);
	push	bc
	push	af
	inc	sp
	push	bc
	inc	sp
	call	_setTileUpdateMap
	pop	af
	pop	bc
;main.c:933: xx=x2>>2;
	ld	b, -8 (ix)
	srl	b
	srl	b
;main.c:934: yy=y2>>3;
	ld	a, -7 (ix)
	rrca
	rrca
	rrca
	and	a, #0x1f
;main.c:935: setTileUpdateMap(xx,yy);
	push	bc
	push	af
	inc	sp
	push	bc
	inc	sp
	call	_setTileUpdateMap
	pop	af
	pop	bc
00118$:
;main.c:938: step++;
	inc	-4 (ix)
;main.c:939: if(step==2)step=0;
	ld	a, -4 (ix)
	sub	a, #0x02
	jr	NZ,00120$
	ld	-4 (ix), #0x00
00120$:
;main.c:944: do_scrolldown_looped(4);
	push	bc
	ld	a, #0x04
	push	af
	inc	sp
	call	_do_scrolldown_looped
	inc	sp
	call	_swap_screen
	pop	bc
;main.c:949: }
	jp	00122$
	.area _CODE
	.area _INITIALIZER
	.area _CABS (ABS)
