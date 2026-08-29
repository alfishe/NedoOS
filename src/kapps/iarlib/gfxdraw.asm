
	MODULE gfxdraw
	PUBLIC gfx_init_tables, gfx_fill_vram, gfx_vram_sync, gfx_fill_rect
	PUBLIC gfx_ega_pair_byte, gfx_blit_row, gfx_blit_grow_h, gfx_blit_checkerboard
	PUBLIC gfx_setpg4000
	PUBLIC zx_ega_left_tab, zx_ega_right_tab, zx_ega_solid_tab
	PUBLIC gfx_put_screen_byte, gfx_store_pair, gfx_putpixel
	PUBLIC gfx_pal_buf, gfx_pal_load_zx, gfx_pal_load_standard
	PUBLIC gfx_pal_load_black, gfx_pal_apply
	PUBLIC ty_lo
	EXTERN g_row
	#include "sysdefs.asm"

; ---------------------------------------------------------------------------
; IAR Z80 C -> asm wrapper calling convention (gfxdraw.asm)
; Verified with iccz80 listing; do NOT guess stack layout from C signatures.
;
; Register args (first one or two byte/pointer params):
;   16-bit pointer  -> DE
;   1st byte param  -> E
;   2nd byte param  -> C
;
; Further byte/word params -> caller stack, read after standard prologue:
;   push ix
;   ld ix,0
;   add ix,sp
;   ; IX+0,1 = saved IX
;   ; IX+2,3 = return address
;   ; IX+4   = 1st stack argument (low byte if 16-bit)
;   ; IX+6   = next argument, etc.
;
; xytoscraddr (internal): L = pixel_x / 2, E = scanline y.
;   Same setup as gfx_blit_row: ld a,e / push af / ld a,c / ld e,a / pop af /
;   srl a / ld l,a / call xytoscraddr.
;
; zx_ega_combine_ce / gfx_ega_pair_byte(color_l, color_r):
;   E = color_l (left pixel), C = color_r (right pixel).
;
;   Do NOT add thin C stubs that re-call asm without restoring DE/C/stack args.
;
; NedoOS multitasking: IY (and often IX) hold the current task frame in IAR C code.
; Every PUBLIC asm entry called from C MUST: push iy / push ix ... pop ix / pop iy / ret
; Do NOT use IY as a work register inside asm; use UDATA temps or BC/DE/HL only.
; Stack args AFTER  push iy; push ix; ld ix,0; add ix,sp :
;   (IX+4)=saved IY  (IX+6)=1st caller stack arg  (IX+8)=next ...
; After  push ix only (no iy): (IX+4)=1st stack arg. Verify in obj/*.s01 .
;
; Calling gfx_blit_row from asm (match iccz80 listing):
;   push count (BC=128); push bytes (HL=ptr); E=x; C=y; call gfx_blit_row
;   -> (IX+4)=bytes lo, (IX+5)=bytes hi, (IX+6)=count
;
; ATM-turbo 2+ video (NOT PC EGA). See kapps/nc/ architecture manual, section 5.4:
;   320x200 x16, one byte = two pixels (pair). VRAM split into four interleaved
;   column banks on pages #05/#01 (mapped at 0x8000..). xytoscraddr + next_column
;   walk scanlines along those banks (tx[] holds 0x80/0xA0/0xC0/0xE0 column bases).
;   Do NOT gfx_vram_sync after interleaved blit (linear ldir corrupts column layout).
;   Palette hardware: ports #F6 / #FE (doc 5.6). Pair bit layout: doc fig. 10.
; ---------------------------------------------------------------------------

	RSEG UDATA0
g_color_byte:
	DEFS 1
xy_patch:
	DEFS 1
xy_y:
	DEFS 1
blit_dst_x:
	DEFS 1
blit_rows_left:
	DEFS 1

	RSEG UDATA0
ty_lo:
	DEFS 200
ty_pad:
	DEFS 56
ty_hi:
	DEFS 200
tx:
	DEFS 512

	RSEG CODE

gfx_init_tables:
	ld hl,tx
	ld c,0
init_tx0:
	ld a,c
	srl a
	srl a
	ld (hl),a
	inc hl
	inc c
	jr nz,init_tx0

	ld b,64
	ld hl,tx+256
init_tx1:
	ld a,0x80
	ld (hl),a
	inc hl
	ld a,0xc0
	ld (hl),a
	inc hl
	ld a,0xa0
	ld (hl),a
	inc hl
	ld a,0xe0
	ld (hl),a
	inc hl
	djnz init_tx1

	ld c,0
init_ty0:
	ld a,c
	ld l,a
	ld h,0
	add hl,hl
	add hl,hl
	add hl,hl
	ld d,h
	ld e,l
	add hl,hl
	add hl,hl
	add hl,de
	ld e,l
	ld d,h
	ld hl,ty_lo
	add hl,bc
	ld (hl),e
	ld hl,ty_hi
	add hl,bc
	ld (hl),d
	inc c
	ld a,c
	cp 200
	jr nz,init_ty0
	ret

; void gfx_fill_vram(unsigned char color);
; IAR: (IX+4)=color after prologue.
; Fill 8000 bytes at 0x8000 on the currently mapped 320x200 VRAM page (one bank).
gfx_fill_vram:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl
	ld a,(ix+4)
	call ega_solid_color_byte
	ld c,a
	ld hl,0x8000
	ld (hl),c
	ld de,0x8001
	ld bc,7999
	ldir
	ld hl,0x8000
	ld de,0xc000
	ld bc,8000
	ldir
	pop hl
	pop de
	pop bc
	pop ix
	ret

; Mirror 0x8000..0x9fff -> 0xc000..0xdfff only (linear copy within one mapping).
; Do NOT call after gfx_blit_row: blit uses interleaved column banks (doc 5.4);
; linear copy duplicates/wipes column data across 0x8/0xA/0xC/0xE regions.
gfx_vram_sync:
	push bc
	push de
	push hl
	ld hl,0x8000
	ld de,0xc000
	ld bc,8000
	ldir
	pop hl
	pop de
	pop bc
	ret

; Solid screen byte for palette index 0..15 (uwol colorMaskTable / tpixelrecode).
; Output is one ATM pair byte (both pixels same color, doc 5.4).
ega_solid_color_byte:
	ld e,a
	ld d,0
	ld hl,zx_ega_solid_tab
	add hl,de
	ld a,(hl)
	ret

; Single-pixel plot color (%33210210), getexprcolor / bascmds prpixel style.
ega_plot_color_byte:
	ld e,a
	and 7
	ld d,a
	ld a,e
	and 15
	add a,a
	add a,a
	add a,a
	or d
	rlca
	rlca
	rrca
	rrca
	ret

; xytoscraddr clobbers BC - do not keep row/column counters in B/C across calls.
; Also overwrites xy_patch (address low); use blit_dst_x for saved pixel x.
xytoscraddr:
;l=x/2, e=y  (tables are not page-aligned in IAR UDATA)
	ld a,e
	ld (xy_y),a
	ld a,l
	ld e,a
	ld d,0
	ld hl,tx
	add hl,de
	ld c,(hl)
	ld hl,tx+256
	add hl,de
	ld b,(hl)
	ld a,(xy_y)
	ld e,a
	ld d,0
	ld hl,ty_lo
	add hl,de
	ld a,(hl)
	add a,c
	ld (xy_patch),a
	ld hl,ty_hi
	add hl,de
	ld a,(hl)
	adc a,b
	ld h,a
	ld a,(xy_patch)
	ld l,a
	ret

; Advance HL to next horizontal screen column (interleaved VRAM bank, doc 5.4).
next_column:
	bit 6,h
	set 6,h
	jr z,next_column_done
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,next_column_done
	inc hl
next_column_done:
	ret

; ATM 320x200 column address from pixel x (HL=0..319), MeisouToshi p_calc_x style.
p_calc_x:
	and a
	rr h
	rr l
	ld a,l
	rrca
	rrca
	ld h,0
	and a
	push af
	rla
	rr h
	rla
	rr h
	scf
	rr h
	pop af
	and 0x3f
	ld l,a
	ret

; Add y*40 to screen address in HL (A=y).
p_calc_y:
	ld bc,40
p_calc_y_loop:
	and a
	ret z
	add hl,bc
	dec a
	jr p_calc_y_loop

drawverline:
;hl=addr, color in g_color_byte, b=hgt (gfxtest drawverline)
	ld de,40
	ld a,(g_color_byte)
drawverline0:
	ld (hl),a
	add hl,de
	djnz drawverline0
	ret

; void gfx_fill_rect(unsigned char x, unsigned char y,
;                    unsigned char w, unsigned char h, unsigned char color);
; x,y,w,h in pixels; loop draws w/2 screen columns (1 byte = 2 pixels, doc 5.4).
; IAR Z80: E=x, C=y, w/h/color on caller stack at (IX+4)/(IX+6)/(IX+8).
gfx_fill_rect:
	push ix
	ld ix,0
	add ix,sp
	push iy
	push bc
	push de
	push hl

	ld a,e
	push af
	ld a,c
	ld e,a
	push de
	ld c,(ix+4)
	ld b,(ix+6)
	ld a,(ix+8)
	call ega_solid_color_byte
	ld (g_color_byte),a
	pop de

	pop af
	srl a
	ld l,a

	call xytoscraddr
	ld a,(ix+4)
	or a
	jr z,fill_done
	ld c,a
	srl c
	ld a,(ix+4)
	and 1
	jr z,fill_w_ok
	inc c
fill_w_ok:
	ld a,(ix+6)
	or a
	jr z,fill_done
	ld b,a

fillcol0:
	push bc
	push hl
	call drawverline
	pop hl
	call next_column
	pop bc
	dec c
	jr nz,fillcol0

fill_done:
	pop hl
	pop de
	pop bc
	pop iy
	pop ix
	ret

; Combine palette indices 0..15 into one ATM screen pair byte (doc 5.4 fig. 10).
; IAR Z80 from C: E=color_l (left), C=color_r (right).
; out: A=byte (tpixelrecode LEFT|RIGHT or solid both sides).
zx_ega_combine_ce:
	ld a,e
	cp c
	jr nz,zx_ega_combine_mix
	ld hl,zx_ega_solid_tab
	ld b,0
	ld c,e
	add hl,bc
	ld a,(hl)
	ret
zx_ega_combine_mix:
	push bc
	ld hl,zx_ega_left_tab
	ld b,0
	ld c,e
	add hl,bc
	ld a,(hl)
	ld d,a
	pop bc
	push bc
	ld hl,zx_ega_right_tab
	ld b,0
	add hl,bc
	ld a,(hl)
	or d
	pop bc
	ret

; unsigned char gfx_ega_pair_byte(unsigned char color_l, unsigned char color_r);
; IAR: E=color_l, C=color_r (registers only, no stack).
gfx_ega_pair_byte:
	call zx_ega_combine_ce
	ret

; void gfx_setpg4000(unsigned char page); IAR: E=page
gfx_setpg4000:
	push iy
	push ix
	ld a,e
	rst 0x18
	pop ix
	pop iy
	ret

; void gfx_blit_row(unsigned char x, unsigned char y,
;                   unsigned char *bytes, unsigned char count);
; IAR: E=x, C=y, (IX+4)=bytes lo, (IX+5)=bytes hi, (IX+6)=count.
; One xytoscraddr, then count bytes along scanline via next_column.
gfx_blit_row:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl
	ld a,e
	push af
	ld a,c
	ld e,a
	pop af
	srl a
	ld l,a
	call xytoscraddr
	ld e,(ix+4)
	ld d,(ix+5)
	ld c,(ix+6)
blit_row_loop:
	ld a,(de)
	ld (hl),a
	inc de
	bit 6,h
	set 6,h
	jr z,blit_row_nc
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,blit_row_nc
	inc hl
blit_row_nc:
	dec c
	jr nz,blit_row_loop
	pop hl
	pop de
	pop bc
	pop ix
	ret

; void gfx_blit_grow_h(unsigned char x, unsigned char y, unsigned char height);
; IAR: E=x, C=y, (IX+4)=height. Blits EXTERN g_row[128] to each scanline.
; blit_dst_x / blit_rows_left survive xytoscraddr (BC and xy_patch are clobbered).
gfx_blit_grow_h:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl
	ld a,e
	ld (blit_dst_x),a
	ld a,c
	ld (xy_y),a
	ld a,(ix+4)
	ld (blit_rows_left),a
grow_h_row:
	ld a,(xy_y)
	ld e,a
	ld a,(blit_dst_x)
	srl a
	ld l,a
	call xytoscraddr
	ld de,g_row
	ld c,128
grow_h_col:
	ld a,(de)
	inc de
	ld (hl),a
	bit 6,h
	set 6,h
	jr z,grow_h_nc
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,grow_h_nc
	inc hl
grow_h_nc:
	dec c
	jr nz,grow_h_col
	ld a,(xy_y)
	inc a
	ld (xy_y),a
	ld a,(blit_rows_left)
	dec a
	ld (blit_rows_left),a
	jr nz,grow_h_row
	pop hl
	pop de
	pop bc
	pop ix
	ret

; void gfx_blit_checkerboard(unsigned char x, unsigned char y);
; IAR: E=x, C=y. 192 lines, vertical 00/FF stripes, invert every 2 rows (2x2 test).
; Stripe byte in B during cb_col (next_column inline uses ld a,h and clobbers A).
gfx_blit_checkerboard:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl
	ld a,e
	ld (blit_dst_x),a
	ld a,c
	ld (xy_y),a
	ld a,192
	ld (blit_rows_left),a
cb_row:
	ld a,(xy_y)
	ld e,a
	ld a,(blit_dst_x)
	srl a
	ld l,a
	call xytoscraddr
	ld a,(xy_y)
	rrca
	and 1
	neg
	sbc a,a
	ld b,a
	ld c,128
cb_col:
	ld a,b
	ld (hl),a
	xor 0ffh
	ld b,a
	bit 6,h
	set 6,h
	jr z,cb_nc
	ld a,h
	xor 0x60
	ld h,a
	and 0x20
	jr nz,cb_nc
	inc hl
cb_nc:
	dec c
	jr nz,cb_col
	ld a,(xy_y)
	inc a
	ld (xy_y),a
	ld a,(blit_rows_left)
	dec a
	ld (blit_rows_left),a
	jr nz,cb_row
	pop hl
	pop de
	pop bc
	pop ix
	ret

; void gfx_put_screen_byte(unsigned char x, unsigned char y, unsigned char byte_val);
; IAR: E=x, C=y, (IX+4)=byte_val.
; x = even pixel; one xytoscraddr per call (safe for mixed scanlines).
gfx_put_screen_byte:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl
	ld a,e
	push af
	ld a,c
	ld e,a
	pop af
	srl a
	ld l,a
	call xytoscraddr
	ld a,(ix+4)
	ld (hl),a
	pop hl
	pop de
	pop bc
	pop ix
	ret

; void gfx_store_pair(unsigned char x, unsigned char y,
;                     unsigned char color_l, unsigned char color_r);
; IAR: E=x, C=y, (IX+4)=color_l, (IX+6)=color_r.
gfx_store_pair:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl

	ld a,e
	push af
	ld a,c
	ld e,a
	pop af
	srl a
	ld l,a
	call xytoscraddr

	ld a,(ix+4)
	ld e,a
	ld a,(ix+6)
	ld c,a
	call zx_ega_combine_ce
	ld (hl),a

	pop hl
	pop de
	pop bc
	pop ix
	ret

; Hardware palette push (syskrnl.asm setgfxpal_focus): DDp pairs from buf[31..0].
gfx_hw_load_palette_focus:
	push bc
	push de
	push hl
	push af
	ld hl,gfx_pal_buf
	ld de,31
	add hl,de
	ld c,0xff
	ld b,8
	ld a,7
gfx_hw_pal_f6_loop:
	out (0xF6),a
	ld d,(hl)
	dec hl
	dec hl
	out (c),d
	dec a
	djnz gfx_hw_pal_f6_loop
	ld b,8
	ld a,7
gfx_hw_pal_fe_loop:
	out (0xFE),a
	ld d,(hl)
	dec hl
	dec hl
	out (c),d
	dec a
	djnz gfx_hw_pal_fe_loop
	pop af
	pop hl
	pop de
	pop bc
	ret

; RAM palette buffer (games keep pal[] in RAM; BDOS_setpal copies from DE).
gfx_pal_buf:
	DEFS	32

gfx_pal_copy_hl:
	ld de,gfx_pal_buf
	ld bc,32
	ldir
	ret

gfx_pal_load_zx:
	ld hl,gfx_zx_pal_src
	jp gfx_pal_copy_hl

gfx_pal_load_standard:
	ld hl,gfx_std_pal_src
	jp gfx_pal_copy_hl

gfx_pal_load_black:
	ld hl,gfx_black_pal_src
	jp gfx_pal_copy_hl

; OS_SETPAL(gfx_pal_buf) + INIT-style hardware palette push.
gfx_pal_apply:
	push bc
	push de
	push ix
	push iy
	ld de,gfx_pal_buf
	ld c,CMD_SETPAL
	call BDOS
	pop iy
	pop ix
	pop de
	call gfx_hw_load_palette_focus
	pop bc
	ret

; void gfx_putpixel(unsigned char x, unsigned char y, unsigned char color);
; E=x, C=y, color at (IX+4).
; XOR plot needs bascmds prpixel addressing (not xytoscraddr / fill_rect grid).
gfx_putpixel:
	push ix
	ld ix,0
	add ix,sp
	push bc
	push de
	push hl

	ld a,c
	ld c,e
	ld b,0
	ld e,a
	ld d,0

	ld l,e
	ld h,4
	add hl,hl
	add hl,hl
	add hl,de
	add hl,hl
	add hl,hl
	add hl,hl

	ld a,b
	rra
	ld a,c
	rra
	jr c,putpixel_right
	rra
	jr nc,putpixel_skip_set6
	set 6,h
putpixel_skip_set6:
	rra
	jr nc,putpixel_skip_set5
	set 5,h
putpixel_skip_set5:
	and 0x3f
	add a,l
	ld l,a
	adc a,h
	sub l
	ld h,a

	ld a,(ix+4)
	call ega_plot_color_byte
	xor (hl)
	and 0x47
	xor (hl)
	ld (hl),a
	jr putpixel_done

putpixel_right:
	rra
	jr nc,putpixel_r_skip_set6
	set 6,h
putpixel_r_skip_set6:
	rra
	jr nc,putpixel_r_skip_set5
	set 5,h
putpixel_r_skip_set5:
	and 0x3f
	add a,l
	ld l,a
	adc a,h
	sub l
	ld h,a

	ld a,(ix+4)
	call ega_plot_color_byte
	xor (hl)
	and 0xb8
	xor (hl)
	ld (hl),a

putpixel_done:
	pop hl
	pop de
	pop bc
	pop ix
	ret

	RSEG CONST
; Index 0..15 -> ATM screen pair byte halves (tpixelrecode / uwol colorMaskTable).
; uwol nedoload.asm colorMaskTable: ink=zx_ega_left, paper=zx_ega_right, pair=solid.
zx_ega_left_tab:
	DEFB	0,1,2,3,4,5,6,7,64,65,66,67,68,69,70,71
zx_ega_right_tab:
	DEFB	0,8,16,24,32,40,48,56,128,136,144,152,160,168,176,184
zx_ega_solid_tab:
	DEFB	0,9,18,27,36,45,54,63,192,201,210,219,228,237,246,255

gfx_black_pal_src:
	DEFS	32,0xff
; ZX Spectrum ULA 0..15 -> DDp. Normal row: recolour lx=8 on 208 RGB; bright row: kuler on 255 RGB.
; Order: black,blue,red,magenta,green,cyan,yellow,white x2 (Speccy ink/paper indices).
gfx_zx_pal_src:
	DEFB	0ffh,0ffh,0dfh,0deh,0bfh,0bdh,09fh,09ch
	DEFB	07fh,06fh,05fh,04eh,03fh,02dh,01fh,00ch
	DEFB	0ffh,0ffh,0deh,0deh,0bdh,0bdh,09ch,09ch
	DEFB	06fh,06fh,04eh,04eh,02dh,02dh,00ch,00ch
; STANDARDPAL macro (kernel/games default; NOT ZX index mapping).
gfx_std_pal_src:
	DEFB	0ffh,0ffh,0feh,0feh,0fdh,0fdh,0fch,0fch
	DEFB	0efh,0efh,0eeh,0eeh,0edh,0edh,0ech,0ech
	DEFB	0ffh,0ffh,0deh,0deh,0bdh,0bdh,09ch,09ch
	DEFB	06fh,06fh,04eh,04eh,02dh,02dh,00ch,00ch

	ENDMOD

END
