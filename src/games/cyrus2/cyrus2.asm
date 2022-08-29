	device zxspectrum128
        include "../../_sdk/sys_h.asm"

;FIX=1
        include "settings.ast"

INTSTACK=0x4000

ROM_START	equ	0

SCREEN		equ	#4000
SCR_ATTRS	equ	#5800

bas_LAST_K	equ	#5C08
bas_5C3A	equ	#5C3A

bas_FLAGS	equ	#5C3B
off_FLAGS	equ	bas_FLAGS-bas_5C3A

bas_ERRSP	equ	#5C3D
bas_5C78	equ	#5C78	;increments every 50 Hz by basic interrupt handler
word_5CC3	equ	#5CC3

bit_NEW_KEY	equ	5
bit_CAPS_LOCK	equ	3

EGA=0

_R=0x11
_N=0x31
_B=0x21
_Q=0x09
_K=0x01

		MACRO	EOS
		org	$-1
		db	{b $}|#80
		ENDM

        org PROGSTART
begin
        OS_HIDEFROMPARENT

        ld e,3+0x80 ;6912+keep
        ;ld e,0+0x80 ;EGA+keep
        OS_SETGFX ;e=0:EGA, e=2:MC, e=3:6912, e=6:text ;+SET FOCUS ;e=-1: disable gfx (out: e=old gfxmode)
        ;call setgfx

        ld e,0 ;color byte
        OS_CLS

        OS_GETMAINPAGES
;dehl=pages in 0000,4000,8000,c000 
        ld a,e
        ;ld (pgmain4000),a
        ld a,h
        ;ld (pgmain8000),a
        ld a,l
        ;ld (pgspr),a  

        ld a,(user_scr0_high) ;ok
        SETPG4000
        
        ld hl,scr
        ld de,0x4000
        ld bc,0x1b00
        ldir
        
        YIELDGETKEYLOOP
        
        ld de,pal
        OS_SETPAL

        YIELD


        call swapimer
        
        ld sp,0x8000
        ld iy,23610
        jp START_POINT

pal
;DDp palette: %grbG11RB(low),%grbG11RB(high), inverted
        ;dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0xeded,0xecec
        ;dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c
        dw 0xffff,0xfefe,0xfdfd,0xfcfc,0xefef,0xeeee,0x6d6d,0xecec
        dw 0xffff,0xdede,0xbdbd,0x9c9c,0x6f6f,0x4e4e,0x2d2d,0x0c0c

keymatrix
        ds 8,0xff

        include "int.asm"
        include "rst38.asm"
rst10
        push af
        push bc
        push de
        push hl

rst10_phase=$+1
        ld b,0 ;0=code, 1=X, 2=Y
        djnz rst10_noATY
        ld (rst10_y),a
        ld a,2
        ld (rst10_phase),a
        jr rst10_q
rst10_noATY
        djnz rst10_noATX
        ld (rst10_x),a
        xor a
        ld (rst10_phase),a
        call rst10_countscr
        jr rst10_q
rst10_noATX

        cp 22 ;AT
        jr z,rst10_AT
             
rst10_scr=$+1
        ld de,0x4000
             
        ld l,a
        ld h,0
        add hl,hl
        add hl,hl
        add hl,hl
        ld bc,font-256
        add hl,bc
        ld b,0
prchar0
        ld a,(hl)
        ld (de),a
        inc hl
        inc d
        djnz prchar0

        ld hl,rst10_scr
        inc (hl)
        ld hl,rst10_x
        inc (hl)
        ld a,(hl)
        cp 32
        jr nz,rst10_q
        ld (hl),0
        ld hl,rst10_y
        inc (hl)
        ld a,(hl)
        cp 24
        jr nz,$+4
        ld (hl),0
        call rst10_countscr
rst10_q
        pop hl
        pop de
        pop bc
        pop af
        ret
        
rst10_AT
        ld a,1
        ld (rst10_phase),a
        jr rst10_q
        
rst10_countscr
rst10_x=$+1
rst10_y=$+2
        ld bc,0
        ld a,b ;a = Y = 0b000TTYYY
        LD L,A
        and 0b00011000
        add a,0x40;screen/256
        LD H,A
        ld a,l
        rrca
        rrca
        rrca
        and 0b11100000
        add a,c ;x
        LD L,A
        ld (rst10_scr),hl
        ret

       if FIX
RandomizeSetup
        ld hl,starting_setup
        ld de,starting_setup+1
        ld bc,8-1
        ld (hl),0
        ldir

        call GEN_RANDBYTE
        ld a,b
        and 6
        call RandomizeSetup_HLplaceA
        ld (hl),_B
        call GEN_RANDBYTE
        ld a,b
        and 6
        inc a
        call RandomizeSetup_HLplaceA
        ld (hl),_B

        call GEN_RANDBYTE
        add a,6
        jr nc,$-2
;a=0..9
        call RandomizeSetup_HLemptyplaceA
        ld (hl),_Q

       if 1
;должны равноверо€тно выбиратьс€ 10 вариантов расстановки коней в 5 свободных клетках
        call GEN_RANDBYTE
        add a,10
        jr nc,$-2
;a=0..9
        add a,a
        ld c,a
        ld b,0
        ld hl,knightsetups
        add hl,bc
        ex de,hl
        ld a,(de)
        inc de
        call RandomizeSetup_HLemptyplaceA
        ld (hl),_N
        ld a,(de)
        call RandomizeSetup_HLemptyplaceA
        ld (hl),_N
       else
;так распределение коней неравномерно
        call GEN_RANDBYTE
        and 3
        call RandomizeSetup_HLemptyplaceA
        ld (hl),_N
        call GEN_RANDBYTE
        and 3
        call RandomizeSetup_HLemptyplaceA
        ld (hl),_N
       endif

        ld hl,starting_setup-1
        call RandomizeSetup_findempty
        ld (hl),_R
        call RandomizeSetup_findempty
        ld (hl),_K
        call RandomizeSetup_findempty
        ld (hl),_R
        ret
        
RandomizeSetup_HLplaceA
        ld c,a
        ld b,0
        ld hl,starting_setup
        add hl,bc
        ret

RandomizeSetup_findempty
RandomizeSetup_findempty0
        inc hl
        ld a,(hl)
        or a
        jr nz,RandomizeSetup_findempty0
        ret

RandomizeSetup_HLemptyplaceA
        inc a
        ld b,a
        ld hl,starting_setup-1
RandomizeSetup_HLemptyplaceA0
        call RandomizeSetup_findempty
        djnz RandomizeSetup_HLemptyplaceA0
        ret
        
knightsetups
        db 0,0
        db 0,1
        db 0,2
        db 0,3
        db 1,1
        db 1,2
        db 1,3
        db 2,2
        db 2,3
        db 3,3
       endif

font
        incbin "font.bin"

scr
        incbin "CyrusII.scr"

		ds 0x637c-$
		
unk_637C:	ds 1			; DATA XREF: sub_A262+4
txt_buf_6:	ds 6			; DATA XREF: sub_9FB2+33
		ds 3
buf_10bytes:	ds 10			; DATA XREF: sub_8977	sub_8977+17 ...
		ds 1
CLK_1:		ds 8			; DATA XREF: sub_9018+15
					; INIT_PRINT_CLOCKS+3	...
CLK_2:		ds 8			; DATA XREF: sub_9018+1D
					; INIT_PRINT_CLOCKS+E	...
TAPE_header:	ds 17			; DATA XREF: sub_8EA7+7 sub_8EFB ...
		ds 3
byte_63B5:	ds 1			; DATA XREF: sub_8C20+19F9
byte_63B6:	ds 9			; DATA XREF: sub_8C20+1A09
					; sub_8C20+1A14 ...
unk_63BF:	ds 65			; DATA XREF: sub_8C20+1A0F



		ds 0x6400-$
SCR_BUF_6400:	ds	#1b00		; up to 7EFF

		; 7F00..7FFF free





		ds 0x8000-$
START_POINT:

; FUNCTION CHUNK AT 8067 SIZE 00000033 BYTES

		jr	loc_8032

; ---------------------------------------------------------------------------
aCopyright1986I:db	'COPYRIGHT (1986) INTELLIGENT CHESS SOFTWARE LTD.'
; ---------------------------------------------------------------------------

loc_8032:
		di
		ld	(save_SP), sp
		exx
		ld	(save_HLtick), hl

		ld	hl, (bas_ERRSP)
		ld	(save_ERRSP), hl
               if !FIX
		ld	hl, INT_VEC
		ld	(hl), INT_PROC&255
		inc	hl
		ld	(hl), INT_PROC/256
		ld	a, INT_VEC/256
		ds 2 ;ld	i, a
		ds 2 ;im	2
               endif
		jp	loc_8067


; =============== S U B	R O U T	I N E =======================================


INT_PROC:				; DATA XREF: RAM:8044	RAM:8047
		push	af
		push	hl
		push	iy
		ld	hl, DECREMENT_50HZ
		dec	(hl)
		ld	iy, bas_5C3A
		call	L0038;ROM_START+#38

		pop	iy
		pop	hl
		pop	af
		ei
		ret

; End of function INT_PROC

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR START_POINT

loc_8067:				; CODE XREF: RAM:804F
		ld	sp, RAM_END_D800
		di
		ld	hl, BRD_88_0
		ld	b, 0
		ld	a, RAM_END_D800/256


loc_8072:				; CODE XREF: START_POINT+75
		ld	(hl), b
		inc	hl
		cp	h
		jp	nz, loc_8072

		res	bit_NEW_KEY, (iy+off_FLAGS)	; clear	keypressed bit
		res	bit_CAPS_LOCK, (iy+#30)	; CAPS LOCK off
		xor	a
		ld	(SEL_SCRorBUF),	a
		call	CLR_SCR_OR_BUF

		call	CLR_BOARD ;??? потом ещЄ раз

		call	PRT_DETECT

		ld	a, 1
		ld	(byte_D0B1), a
		ld	a, #FF
		ld	(stk_1bvalue), a
		ld	(byte_D0F0), a

; END OF FUNCTION CHUNK	FOR START_POINT
; START	OF FUNCTION CHUNK FOR sub_92D7

loc_809A:				; CODE XREF: sub_92D7+35
		xor	a
		ld	(byte_D0B4), a
		call	sub_9EE6

; END OF FUNCTION CHUNK	FOR sub_92D7
; START	OF FUNCTION CHUNK FOR sub_8C20

NEW_GAME:				; CODE XREF: sub_8C20-3
		call	sub_96A6

		call	CLR_BOARD

		call	INIT_PRINT_CLOCKS

		call	BEEP_start

		ei
		ld	a, (byte_D20C) ;oldmove #?
		dec	a
		jr	z, loc_80B9

		ld	a, #FF
		ld	(stk_1bvalue), a


loc_80B9:				; CODE XREF: sub_8C20-B6E
		xor	a
		ld	(byte_D0B3), a ;d3=swap board
                inc	a
		ld	(byte_D049), a ;move # ;бесполезно - 875B тоже туда пишет
		scf
		call	sub_A915

		ld	hl, 0
		ld	(word_D09F), hl


loc_80CB:				; CODE XREF: sub_8C20-1DA
		call	InitBoard_ClearMoves


loc_80CE:				; CODE XREF: sub_8C20-511
					; sub_8C20-186
		call	sub_A262

		ld	a, (CFG_BITS)
		and	#30
		jr	z, loc_80F5

		call	sub_A43C

		ld	b,#1E


loc_80DD:				; CODE XREF: sub_8C20-B3C
		push	bc
		ld	a,#3D
		call	loc_A476

		pop	bc
		djnz	loc_80DD

		call	sub_A43C

		ld	a, (byte_D049) ;move #
		dec	a
		jr	z, loc_80F5 ;first move

		call	sub_939F

		call	sub_94C4


loc_80F5:				; CODE XREF: sub_8C20-B4A
					; sub_8C20-B33
		ld	hl, #F7F7
		ld	(word_D240), hl
		xor	a
		ld	(byte_D04D), a
		ld	l, a
		ld	h, a
		ld	(word_D0F7), hl


loc_8104:				; CODE XREF: sub_8C20-507
					; sub_8C20-BD
		ld	hl, 0
		ld	(word_D25A), hl


loc_810A:				; CODE XREF: sub_8C20:loc_82E8
					; sub_8C20-852 ...
		ld	hl,  word_D240+1
		call	sub_B976

		jr	c, loc_811C

		bit	3, (hl)
		jp	nz, loc_8B9B

		ld	hl,  word_D240+1
		set	3, (hl)


loc_811C:				; CODE XREF: sub_8C20-B10
		ld	hl, (word_D09F)
		ld	a, l
		or	h
		jp	nz, loc_8AE8

		ld	hl, CFG_BITS
		res	5, (hl)
		call	sub_A08D

		call	sub_9571

		call	sub_954C

		ld	hl, byte_D0B4
		bit	5, (hl)
		jr	nz, loc_8142

		ld	sp, RAM_END_D800
		call	sub_8C2D

		call	sub_93A4


loc_8142:				; CODE XREF: sub_8C20-AE9
		ld	a, (byte_D00A)
		cp	100
		jp	nc, loc_8B9B

		ld	a, (byte_D02D)
		or	#80 ; 'А'
		ld	(byte_D0BF), a
		rra
		ld	a, (byte_D0B2)
		jr	nc, loc_815E

		or	a
		jr	z, loc_8162

		jp	loc_82EB

; ---------------------------------------------------------------------------

loc_815E:				; CODE XREF: sub_8C20-ACA
		or	a
		jp	z, loc_82EB


loc_8162:				; CODE XREF: sub_8C20-AC7
		ld	a, #BE	; 'Њ'
		ld	(byte_D0E3), a
		ld	(byte_D0F3), a
		ld	hl, 0
		ld	(INC_SECONDS), hl
		ld	(word_D02B), hl
		xor	a
		ld	(bas_5C78), a
		ld	(byte_D0DF), a
		ld	hl, byte_D0B4
		bit	0, (hl)
		jp	nz, loc_8CE9 ;move?

		ld	a, (hl)
		or	#40 ; '@'
		and	#6F ; 'o'
		ld	(hl), a
		bit	5, a
		jr	z, loc_818F

		call	sub_955D


loc_818F:				; CODE XREF: sub_8C20-A96
		call	sub_9F0D ;show state and help

		ld	ix, word_D059
		call	sub_A903

		call	sub_A90F

		jr	nz, loc_81A1

		scf
		jr	loc_81B7

; ---------------------------------------------------------------------------

loc_81A1:				; CODE XREF: sub_8C20-A84
		ld	hl, byte_D0B6
		res	2, (hl)
		call	sub_A900

		push	af


loc_81AA:				; CODE XREF: sub_8C20-A6C
		ld	hl, byte_D0DF
		bit	0, (hl)
		jr	z, loc_81B6

		call	sub_8F4D

		jr	loc_81AA

; ---------------------------------------------------------------------------

loc_81B6:				; CODE XREF: sub_8C20-A71
		pop	af


loc_81B7:				; CODE XREF: sub_8C20-A81
		ex	af, af' ;'
		ld	hl, 0
		ld	(word_D09F), hl
		ld	hl, byte_D0B4
		ld	a, (hl)
		ld	b, a
		and	#9F ; 'Я'
		ld	(hl), a
		bit	5, b
		jp	nz, loc_8520

		ex	af, af' ;'
		jp	c, loc_8B8D

		call	BEEP_move

		ld	a, (byte_D09E)
		or	a
		jr	z, loc_81E0
;end of opening?
		ld	a, (byte_D0B6)
		bit	2, a
		call	nz, sub_A684


loc_81E0:				; CODE XREF: sub_8C20-A4A
					; sub_8C20-8BE
		ld	h, (ix+0)
		res	7, h
		ld	l, (ix+1)
		res	7, l
		push	hl
		ld	ix, word_D059
		call	sub_A903

		ld	ix, RAM_END_D800
		ld	bc, 3
		pop	hl


loc_81FA:				; CODE XREF: sub_8C20-A20
					; sub_8C20-A1A
		add	ix, bc
		ld	a, (ix+0)
		cp	h
		jr	nz, loc_81FA

		ld	a, (ix+1)
		cp	l
		jr	nz, loc_81FA

		ld	a, (ix+0)
		ld	(byte_D0C4), a
		call	sub_9FF5

		ld	(byte_D0C2), a
		ld	a, (ix+1)
		ld	(byte_D0C5), a
		call	sub_9FF5

		ld	(byte_D0C3), a
		call	sub_A906

		call	sub_BC00


loc_8226:				; CODE XREF: sub_8C20-703
		call	sub_939F

		push	ix
		pop	hl
		ld	bc, RAM_END_D800
		xor	a
		ld	e, a
		sbc	hl, bc
		ld	bc, 3


loc_8236:				; CODE XREF: sub_8C20-9E7
		inc	e
		sbc	hl, bc
		jr	nz, loc_8236

		dec	e
		ld	hl, (word_D0F7)
		inc	hl
		ld	(word_D0F7), hl
		ld	a, (ix+2)
		and	#80 ; 'А'
		or	e
		ld	hl, (ptr_stk_1bvalue)
		ld	(hl), a
		inc	hl
		ld	(ptr_stk_1bvalue), hl
		ld	(hl), #FF


loc_8253:				; CODE XREF: sub_8C20-E5
		ld	hl, byte_D00A
		ld	a, (hl)
		ld	(byte_D029), a
		inc	(hl)
		pop	af
		push	af
		jp	po, loc_8279

		push	hl
		ld	l, (ix+1)
		ld	h, #D0	; '–'
		ld	l, (hl)
		res	2, l
		inc	l
		inc	h
		ld	e, (hl)
		ld	hl, (ptr_stk_1bvalue)
		ld	(hl), e
		inc	hl
		ld	(ptr_stk_1bvalue), hl
		ld	(hl), #FF
		pop	hl
		jr	loc_8281

; ---------------------------------------------------------------------------

loc_8279:				; CODE XREF: sub_8C20-9C3
		jp	p, loc_8281

		and	#F
		dec	a
		jr	nz, loc_8283


loc_8281:				; CODE XREF: sub_8C20-9A9
					; sub_8C20:loc_8279
		xor	a
		ld	(hl), a


loc_8283:				; CODE XREF: sub_8C20-9A1
					; sub_8C20-CB
		call	sub_8977

		call	sub_8B66

		ld	hl, (word_D09F)
		ld	a, h
		or	l
		jr	nz, loc_82B2

		ld	hl, byte_D0B4
		bit	5, (hl)
		jr	nz, loc_82B2

		call	sub_8D9E


loc_829A:				; CODE XREF: sub_8C20-97E
		call	sub_8F4D

		ld	hl, byte_D0DF
		bit	0, (hl)
		jr	nz, loc_829A

		call	sub_937B

		ld	hl, BOARD2
		ld	de, BOARD
		ld	bc,#40	; '@'
		ldir


loc_82B2:				; CODE XREF: sub_8C20-992
					; sub_8C20-98B
		ld	hl, (word_D09F)
		ld	de, (word_D0F7)
		sbc	hl, de
		jr	c, loc_82CD

		ld	a, (CFG_BITS)
		bit	5, a
		jr	nz, loc_82CD

		ld	a, h
		or	a
		jr	nz, loc_82D7

		ld	a, l
		cp	9
		jr	nc, loc_82D7


loc_82CD:				; CODE XREF: sub_8C20-965
					; sub_8C20-95E
		ld	hl, byte_D0B4
		bit	5, (hl)
		jr	nz, loc_82D7

		call	sub_9FB2


loc_82D7:				; CODE XREF: sub_8C20-95A
					; sub_8C20-955 ...
		ld	hl, byte_D02D
		ld	a, (hl)
		xor	1
		ld	(hl), a
		ld	(byte_D0BF), a
		rra
		jr	nc, loc_82E8

		ld	hl, byte_D049 ;move #
		inc	(hl)


loc_82E8:				; CODE XREF: sub_8C20-93E
		jp	loc_810A

; ---------------------------------------------------------------------------

loc_82EB:				; CODE XREF: sub_8C20-AC5
					; sub_8C20-AC1 ...
		ld	hl, byte_D0B4
		ld	a, (hl)
		bit	1, a
		jr	z, loc_82F9

		call	sub_A6E4

		jp	loc_8CE9 ;move?

; ---------------------------------------------------------------------------

loc_82F9:				; CODE XREF: sub_8C20-92F
		and	#9F ; 'Я'
		ld	(hl), a
		ld	ix, word_D059
		call	sub_A903

		call	sub_A90F

		jp	z, loc_8B8D

		call	sub_8446

		xor	a
		ld	hl, 0
		ld	(INC_SECONDS), hl
		ld	a, (byte_D09E)
		or	a
		jr	z, loc_8365
;end of opening?
		ld	a, (byte_D0B4)
		rra
		jr	c, loc_8365

		ld	hl, (word_D25A)
		res	7, l
		ld	d, l
		res	7, h
		ld	e, h
		ld	hl, RAM_END_D800
		call	sub_A90C

		jr	c, loc_8365

		push	hl
		pop	ix
		call	sub_A906

		call	sub_939F

		ld	hl, byte_D0B4
		set	5, (hl)
		ld	a, (byte_D02D)
		ld	hl, byte_D0B3 ;d3=swap board
		res	1, (hl)
		rra
		jr	z, loc_834B

		set	1, (hl)


loc_834B:				; CODE XREF: sub_8C20-8D9
		ld	h, (ix+0)
		ld	l, (ix+1)
		ld	(word_D0DA), hl
		pop	af
		push	af
		ld	a, 1
		jp	po, loc_835C

		dec	a


loc_835C:				; CODE XREF: sub_8C20-8C8
		ld	(byte_D0DC), a
		call	sub_A909

		jp	loc_81E0

; ---------------------------------------------------------------------------

loc_8365:				; CODE XREF: sub_8C20-909
					; sub_8C20-903 ...
		ld	hl, (tbl_D803)
		ld	(word_D25A), hl
		ld	hl, (word_D059)
		ld	(word_D05C), hl
		ld	ix, word_D059
		call	sub_A903


loc_8378:				; CODE XREF: sub_8C20-216
		call	sub_9F0D ;show state and help

		ld	b, 0
		ld	a, (byte_D02D)
		rra
		jr	nc, loc_8385

		ld	b,#70 ; 'p'


loc_8385:				; CODE XREF: sub_8C20-89F
		ld	a, b
		ld	(word_D0BB+1), a
		ld	a, #FF
		ld	(word_D0BB), a
		ld	(byte_D0CD), a
		call	sub_955D


loc_8394:				; CODE XREF: sub_8C20-83A
					; sub_8C20-82D ...
		ld	hl, byte_D0DF
		ld	a, 2
		ld	(hl), a
		xor	a
		ld	(byte_D0B8), a


loc_839E:				; CODE XREF: sub_8C20-87A
					; sub_8C20-86E
		call	sub_8F4D


loc_83A1:				; CODE XREF: sub_8C20-68E
		ld	hl, byte_D0DF
		bit	0, (hl)
		jr	nz, loc_839E

		bit	4, (hl)
		jp	nz, loc_845D

		ld	hl, byte_D0B8
		ld	a, (hl)
		or	a
		jr	z, loc_839E

		ld	(hl), 0
		cp	#43 ; 'C'
		jp	z, loc_A4F4

		cp	#50 ; 'P'
		jp	z, loc_A29F

		cp	#49 ; 'I'
		jr	nz, loc_83D1

		call	sub_9571

		ld	hl, byte_D0B3
		ld	a, (hl)
		xor	8
		ld	(hl), a ;d3=swap board
		jp	loc_810A

; ---------------------------------------------------------------------------

loc_83D1:				; CODE XREF: sub_8C20-85E
		call	sub_8D1B

		jr	nc, loc_83E8

		cp	#48 ; 'H'
		jr	nz, loc_83F6

		call	sub_9571

		ld	hl, (word_D25A)
		call	sub_8C6B

		call	sub_955D

		jr	loc_8394

; ---------------------------------------------------------------------------

loc_83E8:				; CODE XREF: sub_8C20-84C
		call	BEEP_start

		ld	a, (byte_D02D)
		or	#80 ; 'А'
		ld	(byte_D0BF), a
		jp	loc_8394

; ---------------------------------------------------------------------------

loc_83F6:				; CODE XREF: sub_8C20-848
		push	af
		call	sub_A6E4

		pop	af
		cp	#41 ; 'A' - analysis
		jp	z, loc_841F

		cp	#4D ; 'M' - move
		jp	z, loc_8CDA

		cp	#44 ; 'D' - demo
		jp	z, loc_8CD5

		cp	#42 ; 'B' - back
		jp	z, loc_8443

		cp	#46 ; 'F' - forward
		jp	z, loc_8A9D

		cp	#53 ; 'S' - set position
		jp	z, loc_8595


loc_8419:				; CODE XREF: sub_8C20-7AF
		call	BEEP_3

		jp	loc_8394

; ---------------------------------------------------------------------------

loc_841F:				; CODE XREF: sub_8C20-823
;'A' - analysis
		ld	hl, loc_8394
		push	hl
		ld	hl, byte_D0B6
		ld	a, (hl)
		xor	1
		and	1
		ld	(hl), a

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


sub_842C:				; CODE XREF: sub_9F0D
		ld	hl, byte_D0B6
		ld	a, (hl)
		or	a
		ld	hl, #D00
		ld	(scr_XY), hl
		ld	hl, a_8spaces	; "       "
		jr	z, loc_843F

		ld	hl, aAnalysis	; "ANALYSI"


loc_843F:				; CODE XREF: sub_842C+E
		call	PRINT_STR_FF

		ret

; End of function sub_842C

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_8443:				; CODE XREF: sub_8C20-814
;'B' - back
		jp	loc_8A0D

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


sub_8446:				; CODE XREF: sub_8C20-917
		ld	hl, tbl_D803
		ld	de, unk_F000


loc_844C:				; CODE XREF: sub_8446+13
		ld	a, (hl)
		cp	#FF
		jr	z, loc_845B

		ld	b, 3


loc_8453:				; CODE XREF: sub_8446+11
		ld	a, (hl)
		ld	(de), a
		inc	hl
		inc	de
		djnz	loc_8453

		jr	loc_844C

; ---------------------------------------------------------------------------

loc_845B:				; CODE XREF: sub_8446+9
		ld	(de), a
		ret

; End of function sub_8446

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_845D:				; CODE XREF: sub_8C20-876
		call	sub_8C2D

		ld	a, (word_D0BB)
		ld	b, a
		ld	a, (word_D0BB+1)
		ld	c, a
		ld	hl, RAM_END_D800


loc_846B:				; CODE XREF: sub_8C20-7AB
					; sub_8C20-7A5
		inc	hl
		inc	hl
		inc	hl
		ld	a, (hl)
		cp	#FF
		jp	z, loc_8419

		cp	b
		jr	nz, loc_846B

		inc	hl
		ld	a, (hl)
		dec	hl
		cp	c
		jr	nz, loc_846B

		push	hl
		call	sub_A6E4

		call	sub_9571

		call	BEEP_move

		pop	ix
		ld	a, (ix+0)
		ld	(byte_D0C4), a
		call	sub_9FF5

		ld	(byte_D0C2), a
		ld	a, (ix+1)
		ld	(byte_D0C5), a
		call	sub_9FF5

		ld	(byte_D0C3), a
		call	sub_A906

		call	sub_BC00

		pop	af
		push	af
		jp	po, loc_8515

		ld	hl, byte_D0DF
		bit	7, (hl)
		res	7, (hl)
		ld	a, (byte_D0DC)
		jp	nz, loc_84DF

		ld	(hl), 8
		xor	a
		ld	(byte_D0B8), a


loc_84BF:				; CODE XREF: sub_8C20-743
		call	sub_93A4

		ld	a,#14
		call	halt_A_frames

		call	sub_8F4D

		jr	nz, loc_84DF

		call	sub_A909

		call	sub_93A4

		call	sub_A906

		ld	a,#14
		call	halt_A_frames

		call	sub_8F4D

		jr	z, loc_84BF


loc_84DF:				; CODE XREF: sub_8C20-76A
					; sub_8C20-756
		ld	(byte_D0DC), a
		call	sub_A909

		call	sub_93A4

		call	sub_A906

		ld	a, (byte_D0DC)
		ld	b, 5
		cp	#52 ; 'R'
		jr	z, loc_8500

		ld	b, 3
		cp	#4E ; 'N'
		jr	z, loc_8500

		ld	b,#83 ; 'Г'
		cp	#42 ; 'B'
		jr	nz, loc_8512


loc_8500:				; CODE XREF: sub_8C20-72E
					; sub_8C20-728
		ld	l, (ix+1)
		ld	h, BRD_88_0/256
		ld	l, (hl)
		res	2, l
		inc	l
		inc	h		; h=word_D100/256
		ld	(hl), b
		res	7, (ix+2)
		call	sub_BC00


loc_8512:				; CODE XREF: sub_8C20-722
		call	BEEP_move


loc_8515:				; CODE XREF: sub_8C20-777
		ld	a, (byte_D0B1)
		cp	#A
		call	z, sub_8D6A

		jp	loc_8226

; ---------------------------------------------------------------------------

loc_8520:				; CODE XREF: sub_8C20-A58
					; sub_8C20-7D
		ld	hl, byte_D0DF
		res	5, (hl)
		pop	af
		push	af
		jp	po, loc_8533

		ld	hl, (ptr_stk_1bvalue)
		dec	hl
		ld	(ptr_stk_1bvalue), hl
		ld	(hl), #FF


loc_8533:				; CODE XREF: sub_8C20-6F9
		ld	hl, (word_D0F7)
		dec	hl
		ld	(word_D0F7), hl
		ld	hl, (ptr_stk_1bvalue)
		dec	hl
		ld	(ptr_stk_1bvalue), hl
		ld	(hl), #FF
		call	sub_A909

		ld	hl, (word_D059)
		ld	(word_D25A), hl
		ld	hl, (word_D05C)
		ld	a, (byte_D05E)
		ld	(word_D059), hl
		ld	(byte_D05B), a
		ld	a, (byte_D029)
		ld	(byte_D00A), a
		ld	hl, word_D240-1
		ld	de,  word_D240+1
		ld	bc,#17
		lddr
		ld	hl, byte_D02D
		ld	a, (hl)
		xor	1
		ld	(hl), a
		or	#80 ; 'А'
		ld	(byte_D0BF), a
		rra
		jr	c, loc_857C

		ld	hl, byte_D049 ;move #
		dec	(hl)


loc_857C:				; CODE XREF: sub_8C20-6AA
		ld	hl, (word_D059)
		ld	(word_D05C), hl
		ld	ix, word_D059
		call	sub_A903

		ld	hl, byte_D0D9
		ld	a, (hl)
		ld	(hl), 0
		ld	(byte_D0B8), a
		jp	loc_83A1

; ---------------------------------------------------------------------------

loc_8595:				; CODE XREF: sub_8C20-80A
					; sub_8C20-24
;'S' - set position
		xor	a
		ld	(byte_D0B7), a
		call	sub_9571

		ld	a, #FF
		ld	(word_D0BB), a
		call	sub_955D

		call	restore_6_spaces

		call	sub_890F

		call	sub_A150

		ld	hl,#1200
		jr	nc, loc_85B4

		ld	h, #A


loc_85B4:				; CODE XREF: sub_8C20-670
		ld	(scr_XY), hl
		ld	hl, aSIXbuf	; "     "
		call	PRINT_STR_scr0

		ld	a,#40 ; '@'
		ld	(byte_D08E), a
		ld	a, (byte_D02D)
		rra
		ld	a, 6
		rra
		ld	(byte_D08D), a
		ld	hl, byte_D04D
		set	0, (hl)
		ld	hl, byte_D0B4
		set	0, (hl)
		set	3, (hl)


loc_85D8:				; CODE XREF: sub_8C20-608
					; sub_8C20-5E4 ...
		call	BEEP_move

		jr	loc_85E0

; ---------------------------------------------------------------------------

loc_85DD:				; CODE XREF: sub_8C20-4D5
		call	BEEP_3


loc_85E0:				; CODE XREF: sub_8C20-645
		call	sub_9F0D ;show state and help

		ld	hl, #1601
		ld	(scr_XY), hl
		ld	hl, aWhite	; "WHIT"
		ld	a, (byte_D08D)
		rlca
		jr	c, loc_85F5

		ld	hl, aBlack	; "BLAC"


loc_85F5:				; CODE XREF: sub_8C20-630
		call	PRINT_STR_scr0

		ld	hl, byte_D0DF
		ld	(hl), 4


loc_85FD:				; CODE XREF: sub_8C20+A
		call	sub_955D


loc_8600:				; CODE XREF: sub_8C20-618
		call	sub_8F4D

		ld	hl, byte_D0B8
		ld	a, (hl)
		or	a
		jr	z, loc_8600

		ld	(hl), 0
		push	af
		call	sub_8C2D

		pop	af
		cp	#5A ; 'Z'
		jr	nz, loc_863F

		call	INIT_PRINT_CLOCKS

		jr	loc_85D8

; ---------------------------------------------------------------------------

loc_861A:				; CODE XREF: sub_8C20-4C8
		ld	a, (byte_D08D)
		add	a, b


loc_861E:				; CODE XREF: sub_8C20-4DE
		ld	c, (hl)
		ld	(hl), a
		bit	0, c
		jr	nz, loc_862E

		bit	2, c
		jr	z, loc_862E

		res	2, c
		ld	l, c
		inc	h
		set	7, (hl)


loc_862E:				; CODE XREF: sub_8C20-5FE
					; sub_8C20-5FA ...
		ld	sp, RAM_END_D800
		ld	a, 3
		ld	(byte_D04D), a
		call	sub_93A4

		call	sub_96A6

		jp	loc_85D8

; ---------------------------------------------------------------------------

loc_863F:				; CODE XREF: sub_8C20-60D
		call	sub_8D1B

		jp	nc, loc_85D8

		cp	#43 ; 'C'
		jr	nz, loc_864E

		call	sub_87CD

		jr	loc_862E

; ---------------------------------------------------------------------------

loc_864E:				; CODE XREF: sub_8C20-5D9
		cp	#4D ; 'M'
		jr	z, loc_865C

		cp	#53 ; 'S'
		jp	nz, loc_871C

		ld	hl, byte_D0B4
		res	0, (hl)


loc_865C:				; CODE XREF: sub_8C20-5D0
		ld	hl, #1600
		ld	(scr_XY), hl
		ld	hl, a_8spaces	; "       "
		call	PRINT_STR_scr0

		call	restore_6_spaces

		ld	hl, byte_D0DF
		res	2, (hl)
		ld	a, (byte_D08D)
		ld	hl, byte_D02D
		ld	b, (hl)
		res	0, b
		sub	3
		ld	(byte_D0B2), a
		jr	z, loc_8682

		set	0, b


loc_8682:				; CODE XREF: sub_8C20-5A2
		ld	a, b
		cp	(hl)
		jr	z, loc_868C

		ld	(hl), b
		ld	a, 3
		ld	(byte_D04D), a


loc_868C:				; CODE XREF: sub_8C20-59C
		ld	a, (byte_D04D)
		and	2
		jr	z, loc_8712

		call	sub_881D
		ld	a, #A ;??? сюда никогда не попадаем?
		ld	(byte_D049), a ;move #
		call	sub_A915

		xor	a
		ld	(byte_D00A), a
		ld	hl, word_D059
		ld	b, 6


loc_86A7:				; CODE XREF: sub_8C20-577
		ld	(hl), a
		inc	l
		djnz	loc_86A7

		xor	a
		ld	(word_D00D), a
		ld	ix, word_D059
		ld	hl, byte_D02D
		inc	(hl)
		push	hl
		call	sub_BC00

		pop	hl
		dec	(hl)
		or	a
		call	z, sub_8C20

		ld	a, #FF
		ld	(stk_1bvalue), a
		ld	hl, #F7F7
		ld	(word_D240), hl
		ld	hl, byte_D02D
		ld	a, (hl)
		and	1
		ld	b, a
		ld	a, (ix+2)
		and	#FE ; 'ю'
		or	b
		ld	(byte_D301), a
		ld	a, (ix+1)
		ld	(byte_D300), a
		ld	a, (byte_D00A)
		ld	(byte_D302), a
		ld	a, (byte_D049) ;move #
		ld	(byte_D20C), a ;oldmove #?
		ld	hl, word_D100
		ld	de, array_64bytes
		ld	b, #20 ; ' '


loc_86F6:				; CODE XREF: sub_8C20-51F
		ld	a, (hl)
		ld	(de), a
		inc	hl
		inc	de
		ld	a, (hl)
		ld	(de), a
		inc	de
		ld	a, l
		add	a, 7
		ld	l, a
		djnz	loc_86F6

		ld	hl, stk_1bvalue
		ld	(ptr_stk_1bvalue), hl
		call	BEEP_move

		call	sub_96A6

		jp	loc_80CE

; ---------------------------------------------------------------------------

loc_8712:				; CODE XREF: sub_8C20-58F
		xor	a
		ld	(byte_D04D), a
		call	BEEP_move

		jp	loc_8104

; ---------------------------------------------------------------------------

loc_871C:				; CODE XREF: sub_8C20-5CC
		cp	#58 ; 'X'
		jr	nz, loc_8737

		call	restore_6_spaces

		ld	hl, byte_D08D
		ld	a, (hl)
		xor	#80 ; 'А'
		ld	(hl), a
		ld	hl, byte_D0BF
		ld	a, (hl)
		xor	1
		ld	(hl), a
		call	sub_8939

		jp	loc_85D8

; ---------------------------------------------------------------------------

loc_8737:				; CODE XREF: sub_8C20-502
		cp	#45 ; 'E'
		jr	nz, loc_8745

		ld	h, #D0	; '–'
		ld	a, (word_D0BB+1)
		ld	l, a
		xor	a
		jp	loc_861E

; ---------------------------------------------------------------------------

loc_8745:				; CODE XREF: sub_8C20-4E7
		ld	hl, KING
		call	sub_8CF7

		jp	c, loc_85DD

		inc	hl
		inc	hl
		ld	a, (hl)
		ld	b, a
		ld	a, (word_D0BB+1)
		ld	l, a
		ld	h, BRD_88_0/256
		jp	loc_861A

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


InitBoard_ClearMoves:				; CODE XREF: sub_8C20:loc_80CB
       if FIX
        call RandomizeSetup
       endif
		xor	a
		ld	(byte_D0FF), a
		ld	hl, array_D200
		ld	b, #A


loc_8764:				; CODE XREF: InitBoard_ClearMoves+B
		ld	(hl), a
		inc	l
		djnz	loc_8764

		ld	(hl), #FF
		ld	c, a
		ld	b, a
		ld	hl, array_D200


loc_876F:				; CODE XREF: InitBoard_ClearMoves+16
		dec	hl
		ld	(hl), a
		djnz	loc_876F

		ld	hl, unk_D080
		ld	b, #80 ; 'А'


loc_8778:				; CODE XREF: InitBoard_ClearMoves+1F
		dec	hl
		ld	(hl), a
		djnz	loc_8778

		call	Copy_starting_setup

		ld	de, word_D100 ;пустышка
		ld	c, #41 ; 'A'
		call	sub_87BF ;копирует р€д de по |c в hl

		ld	l, #60 ; '`'
		ld	c, #C1	; 'Ѕ'
		call	sub_87BF ;копирует р€д de по |c в hl

		ld	c, #81 ; 'Б'
		call	Copy_starting_setup

       if !FIX
		xor	a
		ld	(byte_D09E), a
		inc	a
       else
        ld a,1
        ld (byte_D09E), a ;end of opening?
       endif
		ld	(byte_D0B2), a
		ld	(byte_D02D), a
		ld	(byte_D0BF), a
		ld	(byte_D049), a ;move #
		ld	(byte_D097), a
		ld	(byte_D20C), a ;oldmove #?
		ld	hl, stk_1bvalue
		ld	(ptr_stk_1bvalue), hl
		ld	hl, RAM_END_D800
		ld	(word_D099), hl
		call	sub_87DE

		jp	loc_8828

; End of function InitBoard_ClearMoves


; =============== S U B	R O U T	I N E =======================================


Copy_starting_setup:				; CODE XREF: InitBoard_ClearMoves+21 InitBoard_ClearMoves+35
		ld	de, starting_setup

; End of function Copy_starting_setup


; =============== S U B	R O U T	I N E =======================================


sub_87BF:				; CODE XREF: InitBoard_ClearMoves+29 InitBoard_ClearMoves+30
		ld	b, 8


loc_87C1:				; CODE XREF: sub_87BF+7
		ld	a, (de)
		or	c
		ld	(hl), a
		inc	l
		inc	de
		djnz	loc_87C1

		ld	a, 8
		add	a, l
		ld	l, a
		ret

; End of function sub_87BF


; =============== S U B	R O U T	I N E =======================================


sub_87CD:				; CODE XREF: sub_8C20-5D7
					; sub_8C20-1D7
		call	sub_A262

		xor	a
		ld	hl, BRD_88_0


loc_87D4:				; CODE XREF: sub_87CD+B
		ld	(hl), a


loc_87D5:				; CODE XREF: sub_87CD+F
		inc	l
		bit	3, l
		jr	z, loc_87D4

		bit	7, l
		jr	z, loc_87D5

; End of function sub_87CD


; =============== S U B	R O U T	I N E =======================================


sub_87DE:				; CODE XREF: InitBoard_ClearMoves+5B
		ld	hl, word_D100
		xor	a


loc_87E2:				; CODE XREF: sub_87DE+9
		set	7, (hl)
		add	a, 8
		ld	l, a
		jr	nc, loc_87E2

		ret

; End of function sub_87DE


; =============== S U B	R O U T	I N E =======================================


sub_87EA:				; CODE XREF: sub_87EA+30 sub_881D+3	...
		ld	d, (hl)
		bit	7, d
		jr	nz, loc_8814

		inc	l
		ld	b, (hl)
		dec	l
		ld	a, b
		and	#F
		dec	a
		jr	z, loc_8814

		set	7, (hl)
		ld	a, l
		and	#80 ; 'А'
		or	3
		ld	e, a
		ld	a, b
		and	#8F ; 'П'
		push	hl
		ld	hl, KING-1
		call	sub_8CF7

		inc	hl
		inc	hl
		inc	hl
		ld	a, (hl)
		or	e
		ld	h, #D0	; '–'
		ld	l, d
		ld	(hl), a
		pop	hl


loc_8814:				; CODE XREF: sub_87EA+3 sub_87EA+C
		ld	a, l
		add	a, 8
		ld	l, a
		bit	6, a
		jr	nz, sub_87EA

		ret

; End of function sub_87EA


; =============== S U B	R O U T	I N E =======================================


sub_881D:				; CODE XREF: sub_8C20-58D
		ld	hl, unk_D140
		call	sub_87EA

		ld	l, #C0	; 'ј'   ; word_D1C0&255
		call	sub_87EA


loc_8828:				; CODE XREF: InitBoard_ClearMoves+5E
		ld	de, BRD_88_0
		ld	h, #D1	; '—'   ; word_D100/256


loc_882D:				; CODE XREF: sub_881D+1A sub_881D+22
		ld	a, (de)		; bytes	from D000 are pointers into D100 table
		bit	0, a
		call	nz, sub_8853

		ld	a, #10
		add	a, e
		ld	e, a
		jp	p, loc_882D

		res	7, e
		inc	e
		bit	3, a
		jr	z, loc_882D

		ld	l, 0		; word_D100&255
		call	sub_884D

		ld	l, #80 ; 'А'    ; word_D180&255
		ld	a, b
		or	(hl)
		jp	m, sub_8C20	; illegal setup

; End of function sub_881D


; =============== S U B	R O U T	I N E =======================================


sub_884D:				; CODE XREF: sub_881D+26

; FUNCTION CHUNK AT A912 SIZE 00000003 BYTES

		ld	b, (hl)
		inc	l
		ld	a, (hl)
		jp	loc_A912

; End of function sub_884D


; =============== S U B	R O U T	I N E =======================================


sub_8853:				; CODE XREF: sub_881D+13
		ld	l, a
		dec	l
		bit	6, l
		jr	z, loc_8879

		ld	a, #70 ; 'p'
		and	e
		jr	z, loc_88D7

		cp	#70 ; 'p'
		jr	z, loc_88D7

		ld	b, 1
		ld	a, #80 ; 'А'
		and	l
		xor	#80 ; 'А'
		scf
		rra
		ld	c, a
		ld	a, e
		and	7
		cp	3
		jr	z, loc_88DB

		cp	4
		jr	z, loc_88DB

		jr	loc_88BB

; ---------------------------------------------------------------------------

loc_8879:				; CODE XREF: sub_8853+4
		ld	a, #78 ; 'x'
		and	l
		jr	nz, loc_888D

		ld	c, 1
		ld	b, 0
		bit	1, l
		jr	z, loc_8888

		ld	b, #30 ; '0'


loc_8888:				; CODE XREF: sub_8853+31
		call	sub_88E9

		jr	loc_88D7

; ---------------------------------------------------------------------------

loc_888D:				; CODE XREF: sub_8853+29
		cp	#10
		ld	c, #E
		ld	b, 9
		jr	c, loc_88B2

		jr	nz, loc_88A3

		ld	c, 8
		ld	b, 5
		bit	1, l
		jr	z, loc_88AF

		ld	b, #15
		jr	loc_88AF

; ---------------------------------------------------------------------------

loc_88A3:				; CODE XREF: sub_8853+42
		ld	b, 3
		ld	c, 0
		cp	#20 ; ' '
		jr	nz, loc_88AF

		ld	b, #83 ; 'Г'
		ld	c, 4


loc_88AF:				; CODE XREF: sub_8853+4A sub_8853+4E ...
		call	sub_88E9


loc_88B2:				; CODE XREF: sub_8853+40
		call	sub_88E9


loc_88B5:				; CODE XREF: sub_8853+94
		ld	a, #82 ; 'В'
		and	l
		set	6, a
		ld	l, a


loc_88BB:				; CODE XREF: sub_8853+24 sub_8853+77
		call	sub_88E9

		call	sub_88E9

		call	sub_88E9

		ld	a, l
		add	a, #10
		ld	l, a
		bit	6, a
		jr	nz, loc_88BB

		xor	#80 ; 'А'
		or	#58 ; 'X'
		ld	l, a
		call	sub_88E9

		call	sub_88E9


loc_88D7:				; CODE XREF: sub_8853+9 sub_8853+D ...
		pop	hl
		jp	sub_8C20

; ---------------------------------------------------------------------------

loc_88DB:				; CODE XREF: sub_8853+1E sub_8853+22
		ld	a, l
		and	#82 ; 'В'
		or	#58 ; 'X'
		ld	l, a
		call	sub_88E9

		call	sub_88E9

		jr	loc_88B5

; End of function sub_8853


; =============== S U B	R O U T	I N E =======================================


sub_88E9:				; CODE XREF: sub_8853:loc_8888
					; sub_8853:loc_88AF ...
		res	1, l
		ld	a, (hl)
		rla
		jr	c, loc_88F4

		ld	a, 8
		add	a, l
		ld	l, a
		ret

; ---------------------------------------------------------------------------

loc_88F4:				; CODE XREF: sub_88E9+4
		ld	(hl), e		; D000 (hl) and	D100 (de) point	to each	other here
		ld	a, l
		set	2, a
		ld	(de), a
		inc	l
		ld	(hl), b
		set	2, l
		inc	l
		ld	(hl), c
		pop	bc
		ret

; End of function sub_88E9

; ---------------------------------------------------------------------------
starting_setup:
	;db	#11,#31,#21,#09,#01,#21,#31,#11
	db	_R,_N,_B,_Q,_K,_B,_N,_R
	;db	_R,_K,_N,_R,_B,_B,_N,_Q

aSIXbuf:	db	'      '
		EOS

; =============== S U B	R O U T	I N E =======================================


sub_890F:				; CODE XREF: sub_8C20-679
					; restore_6_spaces+D ...
		ld	hl, #61A
		ld	(scr_XY), hl
		ld	hl, aSIXbuf	; "     "
		call	PRINT_STR_FF

		ld	hl, #1700
		ld	(scr_XY), hl
		ld	hl, aSIXbuf	; "     "
		call	PRINT_STR_scr0

		ret

; End of function sub_890F


; =============== S U B	R O U T	I N E =======================================


restore_6_spaces:			; CODE XREF: sub_8C20-67C
					; sub_8C20-5B8 ...
		ld	hl, aSIXbuf	; "     "
		ld	b, 5
		ld	a, #20 ; ' '


loc_892F:				; CODE XREF: restore_6_spaces+9
		ld	(hl), a
		inc	hl
		djnz	loc_892F

		ld	(hl),' '|#80
		call	sub_890F

		ret

; End of function restore_6_spaces


; =============== S U B	R O U T	I N E =======================================


sub_8939:				; CODE XREF: sub_8C20-4EF
					; sub_9128+37	...
		call	restore_6_spaces

		ld	hl, aSIXbuf	; "     "
		ld	a, (word_D0BB)
		cp	#FF
		jr	nz, loc_8949

		ld	a, (word_D0BB+1)


loc_8949:				; CODE XREF: sub_8939+B
		call	sub_8960

		ld	a, (word_D0BB)
		cp	#FF
		jr	z, loc_895C

		ld	(hl),'-'
		inc	hl
		ld	a, (word_D0BB+1)
		call	sub_8960


loc_895C:				; CODE XREF: sub_8939+18
		call	sub_890F

		ret

; End of function sub_8939


; =============== S U B	R O U T	I N E =======================================


sub_8960:				; CODE XREF: sub_8939:loc_8949
					; sub_8939+20	...
		ld	b, a
		and	#F
		add	a,'a'
		ld	(hl), a
		inc	hl
		ld	a, b
		and	#F0
		rlca
		rlca
		rlca
		rlca
		neg
		add	a, 7
		add	a,'1'
		ld	(hl), a
		inc	hl
		ret

; End of function sub_8960


; =============== S U B	R O U T	I N E =======================================


sub_8977:				; CODE XREF: sub_8C20:loc_8283
		ld	hl, buf_10bytes
		ld	b, #A


loc_897C:				; CODE XREF: sub_8977+8
		ld	(hl), #20 ; ' '
		inc	hl
		djnz	loc_897C

		xor	a
		ld	(byte_D0DC), a
		bit	4, (ix+2)
		jr	z, loc_89A4

		ld	hl, aOOO	; "O-O-O"
		ld	de, buf_10bytes+1
		ld	c, 5
		bit	2, (ix+1)
		jr	z, loc_899E

		inc	hl
		inc	hl
		inc	de
		ld	c, 3


loc_899E:				; CODE XREF: sub_8977+20
		ldir
		ex	de, hl
		dec	hl
		jr	loc_89FB

; ---------------------------------------------------------------------------

loc_89A4:				; CODE XREF: sub_8977+12
		ld	hl, buf_10bytes
		ld	a, (byte_D0C2)
		ld	(hl), a
		inc	hl
		ld	a, (ix+0)
		call	sub_8960

		ld	(hl),'-'
		bit	3, (ix+2)
		jr	z, loc_89BC

		ld	(hl),'x'


loc_89BC:				; CODE XREF: sub_8977+41
		inc	hl
		ld	a, (ix+1)
		call	sub_8960

		dec	hl
		pop	de
		pop	af
		push	af
		push	de
		jp	po, loc_89F3

		inc	hl
		ld	(hl), #2F ; '/'
		inc	hl
		push	hl
		ld	hl, (ptr_stk_1bvalue)
		dec	hl
		ld	a, (hl)
		and	#8F ; 'П'
		pop	hl
		ld	b, #51 ; 'Q'
		cp	9
		jr	z, loc_89EC

		ld	b, #52 ; 'R'
		cp	5
		jr	z, loc_89EC

		ld	b, #42 ; 'B'
		cp	#83 ; 'Г'
		jr	z, loc_89EC

		ld	b, #4E ; 'N'


loc_89EC:				; CODE XREF: sub_8977+65 sub_8977+6B ...
		ld	a, b
		ld	(hl), a
		ld	(byte_D0DC), a
		jr	loc_89FB

; ---------------------------------------------------------------------------

loc_89F3:				; CODE XREF: sub_8977+51
		jr	nc, loc_89FB

		inc	hl
		ld	(hl), #65 ; 'e'
		inc	hl
		ld	(hl), #70 ; 'p'


loc_89FB:				; CODE XREF: sub_8977+2B sub_8977+7A ...
		bit	7, (ix+2)
		jr	z, loc_8A04

		inc	hl
		ld	(hl), #2B ; '+'


loc_8A04:				; CODE XREF: sub_8977+88
		set	7, (hl)
		ret

; End of function sub_8977

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_8A07:				; CODE XREF: sub_8C20-204
					; sub_8C20-167
		call	BEEP_3

		jp	loc_8378

; ---------------------------------------------------------------------------

loc_8A0D:				; CODE XREF: sub_8C20:loc_8443
;'B' - back
		call	sub_9571

		ld	a, (word_D0BB)
		or	a
		call	p, sub_9595

		ld	hl, (word_D0F7)
		ld	a, l
		or	h
		jp	z, loc_8A07

		ld	a, (byte_D0F4)
		ld	c, a
		ld	b, 0
		ld	hl, (word_D088)
		sbc	hl, bc
		jr	nc, loc_8A2F

		ld	hl, 0


loc_8A2F:				; CODE XREF: sub_8C20-1F6
		ld	(word_D088), hl


loc_8A32:				; CODE XREF: sub_8C20-11
					; sub_8C20+172A ...
		call	BEEP_move

		call	sub_96A6

		ld	hl, (word_D0F7)
		dec	hl
		ld	(word_D09F), hl
		ld	a, (byte_D20C) ;oldmove #
		ld	(byte_D049), a ;move #
		dec	a
		jp	z, loc_80CB

		call	sub_87CD

		ld	de, array_64bytes
		ld	a, (byte_D300)
		ld	(word_D059+1), a
		ld	a, (byte_D301)
		ld	(byte_D05B), a
		ld	(byte_D02D), a
		and	1
		ld	(byte_D0B2), a
		ld	(byte_D0BF), a
		ld	a, (byte_D302)
		ld	(byte_D00A), a
		ld	hl, word_D100
		ld	b, #20 ; ' '


loc_8A71:				; CODE XREF: sub_8C20-1A4
		ld	a, (de)
		ld	(hl), a
		inc	hl
		inc	de
		ld	a, (de)
		ld	(hl), a
		inc	de
		ld	a, l
		add	a, 7
		ld	l, a
		djnz	loc_8A71

		ld	hl, word_D100
		ld	de, BRD_88_0


loc_8A84:				; CODE XREF: sub_8C20-18E
		ld	a, (hl)
		or	a
		jp	m, loc_8A8E

		ld	e, a
		ld	a, l
		or	4
		ld	(de), a


loc_8A8E:				; CODE XREF: sub_8C20-19A
		ld	a, l
		add	a, 8
		ld	l, a
		jr	nc, loc_8A84

		ld	hl, stk_1bvalue
		ld	(ptr_stk_1bvalue), hl
		jp	loc_80CE

; ---------------------------------------------------------------------------

loc_8A9D:				; CODE XREF: sub_8C20-80F
;'F' - forward
		call	sub_9571

		ld	a, (word_D0BB)
		or	a
		call	p, sub_9595

		ld	a, (byte_D0F4)
		ld	c, a
		ld	b, 0
		ld	hl, (word_D088)
		add	hl, bc
		ld	(word_D088), hl	; add byte D0F4	to word	D088
		ld	hl, (ptr_stk_1bvalue)
		ld	a, (hl)
		inc	a
		jp	z, loc_8A07	; check	gor end	mark on	stack

		ld	hl, (word_D0F7)
		inc	hl
		ld	(word_D09F), hl
		call	BEEP_move

		jp	loc_810A

; ---------------------------------------------------------------------------

loc_8AC9:				; CODE XREF: sub_8C20-119
		ld	hl, 0
		ld	(word_D09F), hl
		ld	a, (byte_D02D)
		and	1
		ld	(byte_D0B2), a
		ld	hl, (ptr_stk_1bvalue)
		dec	hl
		ld	(ptr_stk_1bvalue), hl
		ld	hl, (word_D0F7)
		dec	hl
		ld	(word_D0F7), hl
		jp	loc_82EB

; ---------------------------------------------------------------------------

loc_8AE8:				; CODE XREF: sub_8C20-AFF
		ld	sp, RAM_END_D800
		ld	de, (word_D0F7)
		or	a
		sbc	hl, de
		jp	z, loc_8B58

		inc	de
		ld	(word_D0F7), de
		ld	hl, (ptr_stk_1bvalue)
		ld	c, (hl)
		ld	b, 0
		inc	hl
		ld	(ptr_stk_1bvalue), hl
		ld	a, c
		cp	#FF
		jr	z, loc_8AC9	; if end mark

		res	7, c
		ld	hl, tbl_D803	; index	into 3byte structs array
		add	hl, bc
		add	hl, bc
		add	hl, bc
		push	af
		push	hl
		ld	ix, word_D059
		call	sub_A903

		pop	ix
		pop	af
		rla
		jr	nc, loc_8B24

		set	7, (ix+2)


loc_8B24:				; CODE XREF: sub_8C20-102
		ld	a, (ix+0)
		call	sub_9FF5

		ld	(byte_D0C2), a
		ld	a, (ix+1)
		call	sub_9FF5

		ld	(byte_D0C3), a
		call	sub_A906

		pop	af
		push	af
		jp	po, loc_8253

		ld	hl, (ptr_stk_1bvalue)
		ld	b, (hl)
		inc	hl
		ld	(ptr_stk_1bvalue), hl
		ld	l, (ix+1)
		ld	h, BRD_88_0/256
		ld	l, (hl)
		res	2, l
		inc	l
		inc	h		; word_D100/256
		ld	(hl), b
		xor	a
		ld	(byte_D00A), a
		jp	loc_8283

; ---------------------------------------------------------------------------

loc_8B58:				; CODE XREF: sub_8C20-12E
		ld	(word_D09F), hl
		ld	a, (byte_D02D)
		and	1
		ld	(byte_D0B2), a
		jp	loc_8104

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


sub_8B66:				; CODE XREF: sub_8C20-99A
		ld	hl, (word_D059)
		ld	(word_D05C), hl
		ld	a, (byte_D05B)
		ld	(byte_D05E), a
		ld	l, (ix+0)
		ld	h, (ix+1)
		ld	a, (ix+2)
		ld	(word_D059), hl
		ld	(byte_D05B), a
		ld	hl, unk_D22B
		ld	de, unk_D229
		ld	bc, #19		; 25
		ldir
		ret

; End of function sub_8B66

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_8B8D:				; CODE XREF: sub_8C20-A54
					; sub_8C20-91A
		ld	hl, aCheckmate	; "CHECKMAT"
		ld	a, (byte_D05B)
		rla
		jr	c, loc_8B9E

		ld	hl, aStalemate	; "STALEMAT"
		jr	loc_8B9E

; ---------------------------------------------------------------------------

loc_8B9B:				; CODE XREF: sub_8C20-B0C
					; sub_8C20-AD9
		ld	hl, aDraw	; "DRA"


loc_8B9E:				; CODE XREF: sub_8C20-8C sub_8C20-87
		ld	a, (byte_D0B4)
		bit	5, a
		jp	nz, loc_8520

		xor	a
		ld	(byte_D0BF), a
		push	hl
		call	sub_A43C

		call	sub_A45A

		call	sub_A43C

		pop	hl
		call	sub_9E68

		ld	hl, aBBackSSetPosn_ ; "B - Back          S - Set posn. G - new"...
		ld	de, #1000
		call	sub_9F42

		call	sub_9939

		ld	a, (byte_D02D)
		ld	hl, word_D100
		rra
		jr	nc, loc_8BCF

		ld	l, #80 ; 'А'


loc_8BCF:				; CODE XREF: sub_8C20-55
		ld	b, #30 ; '0'
		ld	d, 0
		ld	l, (hl)
		dec	h		; BRD_88_0/256
		ld	e, (hl)
		ld	c, e
		or	a


loc_8BD8:				; CODE XREF: sub_8C20-8 sub_8C20-5
		ld	a, e
		ld	e, d
		ld	d, a
		ld	(hl), e
		push	bc
		push	hl
		push	de
		call	c, BEEP_move

		call	sub_93A4

		ld	hl, byte_D0DF
		ld	(hl), 8
		ld	a, #A
		call	sub_8C34

		pop	de
		pop	hl
		pop	bc
		ld	(hl), c
		jr	z, loc_8C13

		cp	#53 ; 'S'
		jr	nz, loc_8BFF

		call	sub_93A4

		jp	loc_8595

; ---------------------------------------------------------------------------

loc_8BFF:				; CODE XREF: sub_8C20-29
		cp	#42 ; 'B'
		jr	nz, loc_8C12

		push	hl
		ld	hl, byte_D0B4
		res	1, (hl)
		ld	hl, (word_D0F7)
		ld	a, l
		or	h
		pop	hl
		jp	nz, loc_8A32


loc_8C12:				; CODE XREF: sub_8C20-1F
		scf


loc_8C13:				; CODE XREF: sub_8C20-2D
		ld	a, (byte_D0B4)
		bit	1, a
		jp	z, loc_8BD8

		djnz	loc_8BD8

		jp	NEW_GAME

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


sub_8C20:				; CODE XREF: sub_8C20-562
					; sub_881D+2D	...

; FUNCTION CHUNK AT 80A1 SIZE 0000038B BYTES
; FUNCTION CHUNK AT 8443 SIZE 00000003 BYTES
; FUNCTION CHUNK AT 845D SIZE 000002FE BYTES
; FUNCTION CHUNK AT 8A07 SIZE 0000015F BYTES
; FUNCTION CHUNK AT 8B8D SIZE 00000093 BYTES
; FUNCTION CHUNK AT 8CD5 SIZE 00000022 BYTES
; FUNCTION CHUNK AT A29F SIZE 00000112 BYTES
; FUNCTION CHUNK AT A4F4 SIZE 00000035 BYTES
; FUNCTION CHUNK AT A596 SIZE 000000EE BYTES

		pop	hl
		ld	hl, aIllegalSetup ; "ILLEGAL SETU"
		call	sub_9E68

		call	BEEP_3

		jp	loc_85FD

; End of function sub_8C20


; =============== S U B	R O U T	I N E =======================================


sub_8C2D:				; CODE XREF: sub_8C20-AE4
					; sub_8C20:loc_845D ...
		ld	hl, a_32spaces	; "                        "
		call	sub_9E68

		ret

; End of function sub_8C2D


; =============== S U B	R O U T	I N E =======================================


sub_8C34:				; CODE XREF: sub_8C20-34 sub_8C6B+3D ...
		xor	a
		ld	(byte_D0B8), a

loc_8C38:
		ld	a, #A


loc_8C3A:				; CODE XREF: sub_8C34+8
		halt
		dec	a
		jr	nz, loc_8C3A

		call	sub_8F4D

		ld	a, (byte_D0B8)
		push	af
		xor	a
		ld	(byte_D0B8), a
		pop	af
		or	a
		ret

; End of function sub_8C34

; ---------------------------------------------------------------------------
		ld	c, #A


loc_8C4E:				; CODE XREF: RAM:8C56
		ld	a, #25 ; '%'


loc_8C50:				; CODE XREF: RAM:loc_8C50 RAM:8C53
		djnz	$

		dec	a
		jr	nz, loc_8C50

		dec	c
		jr	nz, loc_8C4E

		ret

; ---------------------------------------------------------------------------
		ld	a, (byte_D0B3) ;d3=swap board
		bit	4, a
		ret	z
		bit	6, a
		ret	nz
		ld	hl, byte_D0B4
		bit	5, (hl)
		ret	nz
		ld	hl, (tbl_D803)


; =============== S U B	R O U T	I N E =======================================


sub_8C6B:				; CODE XREF: sub_8C20-840
					; sub_8FC1+37
		ld	a, l
		or	h
		ret	z
		ld	a, l
		call	sub_8CC1

		ld	c, a
		ld	a, h
		call	sub_8CC1

		ld	b, 0
		ld	hl, BOARD
		add	hl, bc
		ld	e, (hl)
		ld	b, a
		ld	hl, BOARD
		add	a, l
		ld	l, a
		ld	a, 0
		adc	a, h
		ld	h, a
		ld	d, (hl)
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl)
		jr	z, loc_8C98

		ld	a, b
		xor	#3F ; '?'
		ld	b, a
		ld	a, c
		xor	#3F ; '?'
		ld	c, a


loc_8C98:				; CODE XREF: sub_8C6B+23
		push	de
		push	bc
		ld	c, e
		ld	a, b
		call	SHOW_FIG_POS

		pop	bc
		push	bc
		ld	a, c
		call	SH_EMPT_POS

		call	BEEP_move

		call	sub_8C34

		call	sub_8C34

		pop	bc
		pop	de
		push	de
		push	bc
		ld	a, c
		ld	c, e
		call	SHOW_FIG_POS

		pop	bc
		pop	de
		ld	a, b
		ld	c, d
		call	SHOW_FIG_POS

		or	1
		ret

; End of function sub_8C6B


; =============== S U B	R O U T	I N E =======================================


sub_8CC1:				; CODE XREF: sub_8C6B+4 sub_8C6B+9
		push	af
		and	7
		ld	b, a
		pop	af
		rra
		and	#38 ; '8'
		add	a, b
		push	hl
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl)
		pop	hl
		ret	z
		xor	#3F ; '?'
		ret

; End of function sub_8CC1

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_8CD5:				; CODE XREF: sub_8C20-819
;'D' - demo
		ld	hl, byte_D0B4
		set	1, (hl)


loc_8CDA:				; CODE XREF: sub_8C20-81E
;'M' - move
		call	BEEP_move

		ld	a, (word_D0BB)
		or	a
		call	p, sub_9595

		ld	hl, byte_D0B4
		res	0, (hl)


loc_8CE9:				; CODE XREF: sub_8C20-AA1
					; sub_8C20-92A
		ld	hl, byte_D0B2
		ld	a, (hl)
		or	a
		ld	a, #16
		jr	z, loc_8CF3

		xor	a


loc_8CF3:				; CODE XREF: sub_8C20+D0
		ld	(hl), a
		jp	loc_810A

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


sub_8CF7:				; CODE XREF: sub_8C20-4D8
					; sub_87EA+1D	...
		ld	b, 6


loc_8CF9:				; CODE XREF: sub_8CF7+8
		cp	(hl)
		ret	z
		inc	hl
		inc	hl
		inc	hl
		inc	hl
		djnz	loc_8CF9

		scf
		ret

; End of function sub_8CF7

; ---------------------------------------------------------------------------
		db    0			; DATA XREF: sub_87EA+1A sub_9FF5+20
KING:		db  #4B	; K		; DATA XREF: sub_8C20:loc_8745
		db    6			; DATA XREF: sub_94C9:loc_94FF
		db    0
		db    9
		db  #51	; Q
		db    5
		db    8
		db    5
		db  #52	; R
		db    4
		db  #10
		db  #83	; Г
		db  #42	; B
		db    3
		db  #20
		db    3
		db  #4E	; N
		db    2
		db  #30	; 0
		db    1
		db  #50	; P
		db    1
		db  #40	; @

; =============== S U B	R O U T	I N E =======================================


sub_8D1B:				; CODE XREF: sub_8C20:loc_83D1
					; sub_8C20:loc_863F
		cp	#4C ; 'L'
		scf
		ret	nz
		ld	a, (byte_D0B1)


loc_8D22:				; CODE XREF: sub_8D1B+8 sub_8D1B+C
		inc	a
		jr	z, loc_8D22

		cp	#D
		jr	nc, loc_8D22

		ld	(byte_D0B1), a

; End of function sub_8D1B


; =============== S U B	R O U T	I N E =======================================


sub_8D2C:				; CODE XREF: sub_9EE6+23
		ld	a, (byte_D0B1)
		push	af
		or	a
		call	sub_A915

		ld	a, #FF
		ld	(NEED_SCR2BUF),	a
		pop	af
		ld	de, #41B
		ld	(scr_XY), de
		cp	#A
		jr	nc, loc_8D56

		push	af
		ld	a, #20 ; ' '
		call	PRINT_LETTER

		pop	af
		add	a, #30 ; '0'
		call	PRINT_LETTER

		ld	hl,  a_8spaces+5
		jr	loc_8D65

; ---------------------------------------------------------------------------

loc_8D56:				; CODE XREF: sub_8D2C+17
		ld	hl, a_ADAP	; "ADA"
		jr	z, loc_8D65

		ld	hl, a_INF	; "INF"
		cp	#B
		jr	z, loc_8D65

		ld	hl, aProb	; "PRO"


loc_8D65:				; CODE XREF: sub_8D2C+28 sub_8D2C+2D ...
		call	PRINT_STR_FF

		xor	a
		ret

; End of function sub_8D2C


; =============== S U B	R O U T	I N E =======================================


sub_8D6A:				; CODE XREF: sub_8C20-706
					; sub_8DE9+68
		ld	a, (byte_D0F4)
		ld	c, a
		ld	b, 0
		ld	h, b
		ld	l, c
		add	hl, hl
		add	hl, hl
		add	hl, bc
		add	hl, bc
		add	hl, bc
		ld	bc, (INC_SECONDS)
		dec	bc
		dec	bc
		bit	7, b
		jr	z, loc_8D84

		ld	bc, 0


loc_8D84:				; CODE XREF: sub_8D6A+15
		add	hl, bc
		ld	b, 3


loc_8D87:				; CODE XREF: sub_8D6A+21
		srl	h
		rr	l
		djnz	loc_8D87

		ld	a, h
		or	a
		jr	z, loc_8D93

		ld	l, #FE	; 'ю'


loc_8D93:				; CODE XREF: sub_8D6A+25
		ld	a, l
		cp	2
		jr	nc, loc_8D9A

		ld	a, 2


loc_8D9A:				; CODE XREF: sub_8D6A+2C
		ld	(byte_D0F4), a
		ret

; End of function sub_8D6A


; =============== S U B	R O U T	I N E =======================================


sub_8D9E:				; CODE XREF: sub_8C20-989
					; sub_9128+10E ...
		push	ix
		push	hl
		push	de
		push	bc
		ld	hl, byte_D0B4
		bit	5, (hl)
		jr	z, loc_8DB0

		call	BEEP_move

		call	sub_8C2D


loc_8DB0:				; CODE XREF: sub_8D9E+A
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_8DBC

		call	sub_937B

		jp	loc_8E2C

; ---------------------------------------------------------------------------

loc_8DBC:				; CODE XREF: sub_8D9E+16
		ld	a, (byte_D0C4) ;a=0b0YYY0XXX
		call	sub_96F7 ;count scr_XY, scr_pix_addr, scr_attr_addr with swap board

		ld	hl, (scr_XY)
		ld	(word_D0C6), hl
		ld	a, (byte_D0C5) ;a=0b0YYY0XXX
		call	sub_96F7 ;count scr_XY, scr_pix_addr, scr_attr_addr with swap board

		ld	hl, (scr_XY)
		ld	(word_D0C8), hl
		ld	bc, (word_D0C6)
		call	sub_8EFB ;write bc=scr_XY, scr_pix_addr, scr_attr_addr to TAPE_header+...

		call	sub_8E81

		ld	hl, byte_D0DF
		set	0, (hl)
		xor	a
		ld	(DECREMENT_50HZ), a
		jr	loc_8DF3

; End of function sub_8D9E


; =============== S U B	R O U T	I N E =======================================


sub_8DE9:				; CODE XREF: sub_8F4D:loc_8FBC
		ld	a, (DECREMENT_50HZ)
		or	a
		ret	p
		push	ix
		push	hl
		push	de
		push	bc


loc_8DF3:				; CODE XREF: sub_8D9E+49
		call	sub_8EA7

		ld	hl, (word_D0C6)
		ld	de, (word_D0C8)
		ld	a, h
		cp	d
		jr	z, loc_8E06

		inc	h
		jr	c, loc_8E06

		dec	h
		dec	h


loc_8E06:				; CODE XREF: sub_8DE9+16 sub_8DE9+19
		ld	a, l
		cp	e
		jr	z, loc_8E0F

		inc	l
		jr	c, loc_8E0F

		dec	l
		dec	l


loc_8E0F:				; CODE XREF: sub_8DE9+1F sub_8DE9+22
		ld	(word_D0C6), hl
		or	a
		sbc	hl, de
		push	af
		ld	bc, (word_D0C6)
		call	sub_8EFB ;write bc=scr_XY, scr_pix_addr, scr_attr_addr to TAPE_header+...

		call	sub_8EA3

		pop	af
		jr	z, loc_8E2C

		ld	hl, DECREMENT_50HZ
		ld	a, (hl)
		add	a, 8		; figure move speed
		ld	(hl), a
		jr	loc_8E7B

; ---------------------------------------------------------------------------

loc_8E2C:				; CODE XREF: sub_8D9E+1B sub_8DE9+38
		ld	hl, byte_D0B4
		bit	5, (hl)
		jr	z, loc_8E73

		call	sub_A6E4

		call	sub_9FB2

		ld	a, (byte_D0B6)
		bit	2, a
		call	nz, sub_A684

		ld	hl, BOARD2
		ld	de, BOARD
		ld	bc, #40	; '@'
		ldir
		ld	a, (byte_D0B1)
		cp	#A
		call	z, sub_8D6A

		ld	hl, (INC_SECONDS)
		ld	(word_D02B), hl
		ld	hl, 0
		ld	(INC_SECONDS), hl
		call	sub_9380

		ld	hl, byte_D0B3 ;d3=swap board
		bit	5, (hl)
		ld	hl, byte_D0B4
		jr	z, loc_8E71

		set	7, (hl)
		res	1, (hl)


loc_8E71:				; CODE XREF: sub_8DE9+82
		res	5, (hl)


loc_8E73:				; CODE XREF: sub_8DE9+48
		ld	hl, byte_D0DF
		res	0, (hl)
		call	sub_9F0D ;show state and help


loc_8E7B:				; CODE XREF: sub_8DE9+41
		pop	bc
		pop	de
		pop	hl
		pop	ix
		ret

; End of function sub_8DE9


; =============== S U B	R O U T	I N E =======================================


sub_8E81:				; CODE XREF: sub_8D9E+3D
		ld	c, 3
		ld	hl,  TAPE_header+2


loc_8E86:				; CODE XREF: sub_8E81+1A
		ld	b, #18
		xor	a


loc_8E89:				; CODE XREF: sub_8E81+A
		ld	(hl), a
		inc	hl
		djnz	loc_8E89

		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		ld	b, 3
		ld	a, (de)


loc_8E94:				; CODE XREF: sub_8E81+15
		ld	(hl), a
		inc	hl
		djnz	loc_8E94

		inc	hl
		inc	hl
		dec	c
		jr	nz, loc_8E86

		and	7
		ld	(byte_D0CB), a
		ret

; End of function sub_8E81


; =============== S U B	R O U T	I N E =======================================


sub_8EA3:				; CODE XREF: sub_8DE9+34
		ld	a, 1
		jr	loc_8EA8

; End of function sub_8EA3


; =============== S U B	R O U T	I N E =======================================


sub_8EA7:				; CODE XREF: sub_8DE9:loc_8DF3
		xor	a


loc_8EA8:				; CODE XREF: sub_8EA3+2
		ld	(byte_D0CC), a
		ld	b, 3
		exx
		ld	hl, TAPE_header


loc_8EB1:				; CODE XREF: sub_8EA7+3B sub_8EA7+51
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		ld	c, 8


loc_8EB7:				; CODE XREF: sub_8EA7+20
		push	de
		ld	b, 3


loc_8EBA:				; CODE XREF: sub_8EA7+1B
		ld	a, (de)
		ex	af, af'
		ld	a, (hl)
		ld	(de), a
		ex	af, af'
		ld	(hl), a
		inc	de
		inc	hl
		djnz	loc_8EBA

		pop	de
		inc	d
		dec	c
		jr	nz, loc_8EB7

		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		inc	hl
		ld	a, (byte_D0CC)
		or	a
		jr	nz, loc_8EE5

		ld	b, 3


loc_8ED5:				; CODE XREF: sub_8EA7+36
		ld	a, (de)
		ex	af, af'
		ld	a, (hl)
		ld	(de), a
		ex	af, af'
		ld	(hl), a
		inc	hl
		inc	de
		djnz	loc_8ED5

		exx
		dec	b
		exx
		jr	nz, loc_8EB1

		ret

; ---------------------------------------------------------------------------

loc_8EE5:				; CODE XREF: sub_8EA7+2A
		ld	a, (byte_D0CB)
		ld	c, a
		ld	b, 3


loc_8EEB:				; CODE XREF: sub_8EA7+4C
		ld	a, (de)
		ld	(hl), a
		and	#F8 ; 'ш'
		or	c
		ld	(de), a
		inc	hl
		inc	de
		djnz	loc_8EEB

		exx
		dec	b
		exx
		jr	nz, loc_8EB1

		ret

; End of function sub_8EA7


; =============== S U B	R O U T	I N E =======================================
;write bc=scr_XY, scr_pix_addr, scr_attr_addr to TAPE_header+...

sub_8EFB:				; CODE XREF: sub_8D9E+3A sub_8DE9+31
		ld	ix, TAPE_header
		ld	(scr_XY), bc
		call	CALC_SCR_ADDRS ;scr_XY to scr_pix_addr, scr_attr_addr

		ld	hl, (scr_pix_addr)
		ld	(ix+0),	l
		ld	(ix+1),	h
		ld	hl, (scr_attr_addr)
		ld	(ix+#1A), l
		ld	(ix+#1B), h
		inc	b
		ld	(scr_XY), bc
		call	CALC_SCR_ADDRS ;scr_XY to scr_pix_addr, scr_attr_addr

		ld	hl, (scr_pix_addr)
		ld	(ix+#1F), l
		ld	(ix+#20), h
		ld	hl, (scr_attr_addr)
		ld	(ix+#39), l
		ld	(ix+#3A), h
		inc	b
		ld	(scr_XY), bc
		call	CALC_SCR_ADDRS ;scr_XY to scr_pix_addr, scr_attr_addr

		ld	hl, (scr_pix_addr)
		ld	(ix+#3E), l
		ld	(ix+#3F), h
		ld	hl, (scr_attr_addr)
		ld	(ix+#58), l
		ld	(ix+#59), h
		ret

; End of function sub_8EFB


; =============== S U B	R O U T	I N E =======================================


sub_8F4D:				; CODE XREF: sub_8C20-A6F
					; sub_8C20:loc_829A ...
		push	ix
		push	iy
		ld	hl, bas_5C78
		ld	a, (hl)
		cp	50
		jr	c, loc_8F9B
		sub	50
		ld	(hl), a

		;1 second passed
		ld	hl, (INC_SECONDS)
		inc	hl
		ld	(INC_SECONDS), hl

		ld	a, (byte_D0B4)
		bit	5, a
		jr	nz, loc_8F94

		bit	6, a
		jr	z, loc_8F94

		ld	a, (byte_D0F4)
		inc	a
		jr	z, loc_8F94

		push	bc
		ld	a, (byte_D0F3)
		ld	b, 0
		add	a, a
		rl	b
		cp	l
		jr	nz, loc_8F93

		ld	a, b
		cp	h
		jr	nz, loc_8F93

		ld	hl, byte_D0B4
		set	7, (hl)
		ld	hl, byte_D0F1
		dec	(hl)
		ld	a, (hl)
		and	#F0
		jr	nz, loc_8F93

		inc	(hl)


loc_8F93:				; CODE XREF: sub_8F4D+31 sub_8F4D+35 ...
		pop	bc


loc_8F94:				; CODE XREF: sub_8F4D+1B sub_8F4D+1F ...
		ld	a, (byte_D0DF)
		rra
		call	nc, sub_9018


loc_8F9B:				; CODE XREF: sub_8F4D+A
		ld	a, (byte_D0DF)
		rra
		jr	c, loc_8FBC

		call	KEY_SCAN
		push	af
		ld	hl, byte_D0DF
		bit	5, (hl)
		jr	z, loc_8FB2

		pop	af
		call	sub_924C

		jr	loc_8FB6

; ---------------------------------------------------------------------------

loc_8FB2:				; CODE XREF: sub_8F4D+5D
		pop	af
		call	c, sub_8FC1


loc_8FB6:				; CODE XREF: sub_8F4D+63 sub_8F4D+72
		pop	iy
		pop	ix
		or	a
		ret

; ---------------------------------------------------------------------------

loc_8FBC:				; CODE XREF: sub_8F4D+52
		call	sub_8DE9

		jr	loc_8FB6

; End of function sub_8F4D


; =============== S U B	R O U T	I N E =======================================


sub_8FC1:				; CODE XREF: sub_8F4D+66

; FUNCTION CHUNK AT 90E1 SIZE 00000007 BYTES

		ld	hl, byte_D0B8
		ld	a, (hl)
		ld	(hl), 0
		cp	#20 ; ' '
		jp	z, sub_95C5

		cp	#47 ; 'G'
		call	z, sub_92D7

		ld	(hl), a
		ld	hl, byte_D0B4
		bit	6, (hl)
		jr	z, loc_8FFC

		ld	a, (byte_D0B8)
		cp	#4D ; 'M'
		ld	hl, byte_D0B4
		jr	nz, loc_8FE7

		set	7, (hl)
		res	1, (hl)


loc_8FE7:				; CODE XREF: sub_8FC1+20
		bit	5, (hl)
		jp	nz, loc_90E1

		ld	hl, byte_D0B8
		ld	a, (hl)
		ld	(hl), 0
		cp	#48 ; 'H'
		ret	nz
		ld	hl, (tbl_D803)
		call	sub_8C6B

		ret

; ---------------------------------------------------------------------------

loc_8FFC:				; CODE XREF: sub_8FC1+16
		ld	hl, byte_D0B8
		ld	a, (hl)
		ld	hl, byte_D0DF
		bit	3, (hl)
		jr	z, loc_9008

		ret

; ---------------------------------------------------------------------------

loc_9008:				; CODE XREF: sub_8FC1+44
		or	a
		ret	nz
		call	sub_9128

		ret

; End of function sub_8FC1

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_90E8

loc_900E:				; CODE XREF: sub_90E8+A sub_90E8+F ...
		ld	(byte_D0D9), a
		ld	hl, byte_D0B4
		set	7, (hl)
		pop	af
		ret

; END OF FUNCTION CHUNK	FOR sub_90E8

; =============== S U B	R O U T	I N E =======================================


sub_9018:				; CODE XREF: sub_8F4D+4B
		ld	a, (byte_D04D)
		rra
		ret	c
		ld	a, (byte_D0BF)
		or	a
		ret	p
		push	iy
		push	bc
		push	de
		ld	hl, (scr_XY)
		push	hl
		call	sub_A164

		ld	de, CLK_1
		ld	hl, #405
		jr	c, loc_903A

		ld	de, CLK_2
		ld	l, #F


loc_903A:				; CODE XREF: sub_9018+1B
		ld	(scr_XY), hl
		push	de
		ex	de, hl
		ld	de, 7
		add	hl, de
		push	hl
		res	7, (hl)


loc_9046:				; CODE XREF: sub_9018+41
		inc	(hl)
		ld	a, (hl)
		cp	#3A ; ':'
		jr	c, loc_905B

		ld	(hl), #30 ; '0'
		dec	hl
		inc	(hl)
		ld	a, (hl)
		cp	#36 ; '6'
		jr	c, loc_905B

		ld	(hl), #30 ; '0'
		dec	hl
		dec	hl
		jr	loc_9046

; ---------------------------------------------------------------------------

loc_905B:				; CODE XREF: sub_9018+32 sub_9018+3B
		pop	hl
		set	7, (hl)
		pop	hl
		push	hl
		call	PRINT_STR_FF

		call	sub_A150

		ld	hl, #1100
		jr	c, loc_906D

		ld	h, 9


loc_906D:				; CODE XREF: sub_9018+51
		ld	(scr_XY), hl
		pop	hl
		inc	hl
		call	PRINT_STR_scr0

		pop	hl
		ld	(scr_XY), hl
		pop	de
		pop	bc
		pop	iy
		ret

; End of function sub_9018


; =============== S U B	R O U T	I N E =======================================


sub_907E:				; CODE XREF: sub_8C20:loc_A2DA
					; sub_8C20+175A ...
		push	hl
		ld	hl, bas_FLAGS


loc_9082:				; CODE XREF: sub_907E+E sub_907E+1F
		ld	a, #7F ; ''
		in	a, (#FE)
		rra
		ccf
		jr	c, space_pressed

		bit	bit_NEW_KEY, (hl)		; keypressed bit
		jr	z, loc_9082

		res	bit_NEW_KEY, (hl)
		ld	a, (bas_LAST_K)
		cp	#C
		jr	z, space_pressed

		cp	#D
		jr	z, space_pressed

		cp	#21 ; '!'
		jr	c, loc_9082

		or	a


space_pressed:				; CODE XREF: sub_907E+A sub_907E+17	...
		push	af
		call	BEEP_4

		pop	af
		pop	hl
		ret

; End of function sub_907E




KEY_SCAN:
		xor	a			;CY=0
		ld	hl, bas_FLAGS
		bit	bit_NEW_KEY, (hl)
		ret	z			;return with CY=0 if nothing pressed
		res	bit_NEW_KEY, (hl)
		ld	(byte_D0BD), a
		ld	(byte_D0B8), a
		ld	a, (bas_LAST_K)
		cp	'I'
		jr	nc, loc_90D6	; >='I'
		cp	'A'
		jr	nc, loc_90D1	; >='A'
		cp	'9'
		jr	nc, loc_90D6	; >='9'
		cp	'1'
		jr	nc, loc_90D1	; >='1'
		cp	8
		ccf
		ret	nc	;report scancodes 0..7 as non-keypresses
		cp	#E
		jr	nc, loc_90D6	; >=#0E
loc_90D1:
		; when scancode copied here:
		;  'A'<=SCANCODE<='H'
		;  '1'<=SCANCODE<='8'
		;  8<=SCANCODE<#0E
		; 8-LEFT,9-RIGHT,10-DOWN,11-UP
		ld	(byte_D0BD), a
		scf			;CY=1 was keypress
		ret
loc_90D6:
		cp	'A'
		jr	c, loc_90DC	; <'A'
		and	#5F		;uppercase letters
loc_90DC:
		; when scancode copied here:
		;  SCANCODE>='I', 'a'..'z' are uppercased
		;  '9'<=SCANCODE<'A'
		;  #0E<=SCANCODE<'1'
		ld	(byte_D0B8), a
		scf			;CY=1 was keypress
		ret

; End of function KEY_SCAN

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8FC1

loc_90E1:				; CODE XREF: sub_8FC1+28
		call	sub_90E8

		call	sub_9128

		ret

; END OF FUNCTION CHUNK	FOR sub_8FC1

; =============== S U B	R O U T	I N E =======================================


sub_90E8:				; CODE XREF: sub_8FC1:loc_90E1

; FUNCTION CHUNK AT 900E SIZE 0000000A BYTES
; FUNCTION CHUNK AT 92CB SIZE 0000000C BYTES
; FUNCTION CHUNK AT 9326 SIZE 00000032 BYTES
; FUNCTION CHUNK AT 935D SIZE 00000003 BYTES

		ld	hl, byte_D0B8
		ld	a, (hl)
		or	a
		ret	z
		ld	(hl), 0
		cp	#4D ; 'M'
		jp	z, loc_900E

		cp	#42 ; 'B'
		jp	z, loc_900E

		cp	#46 ; 'F'
		jp	z, loc_92CB

		cp	#48 ; 'H'
		jp	z, loc_9340

		cp	#49 ; 'I'
		jp	z, loc_9326

		cp	#44 ; 'D'
		jp	z, loc_900E

		cp	#41 ; 'A'
		jp	z, loc_900E

		cp	#53 ; 'S'
		jp	z, loc_900E

		cp	#4C ; 'L'
		jp	z, loc_935D

		cp	#43 ; 'C'
		jp	z, loc_900E

		cp	#50 ; 'P'
		jp	z, loc_900E

		ret

; End of function sub_90E8


; =============== S U B	R O U T	I N E =======================================


sub_9128:				; CODE XREF: sub_8FC1+49
					; sub_8FC1+123

; FUNCTION CHUNK AT 9290 SIZE 00000010 BYTES

		ld	hl, byte_D0BD
		ld	a, (hl)
		or	a
		ret	z
		ld	(hl), 0
		ld	bc, (word_D0BB)
		cp	#D
		jp	z, loc_91CE

		cp	#C
		jp	z, loc_9290

		jp	loc_9163

; ---------------------------------------------------------------------------

loc_9141:				; CODE XREF: sub_9128+50 sub_9128+70 ...
		push	bc
		ld	a, b
		cp	#FF
		call	nz, sub_9595

		pop	bc
		ld	a, c
		cp	#FF
		call	nz, sub_9595

		ld	a, (word_D0BB+1)
		cp	#FF
		call	nz, sub_9585

		ld	a, (word_D0BB)
		cp	#FF
		call	nz, sub_95A8

		call	sub_8939

		ret

; ---------------------------------------------------------------------------

loc_9163:				; CODE XREF: sub_9128+16
		cp	#41 ; 'A'
		jr	c, loc_917B

		cp	#49 ; 'I'
		jr	nc, loc_917B

		push	bc
		sub	#41 ; 'A'
		ld	b, a
		ld	hl,  word_D0BB+1
		ld	a, (hl)
		and	#F0 ; 'р'
		or	b
		ld	(hl), a
		pop	bc
		jp	loc_9141

; ---------------------------------------------------------------------------

loc_917B:				; CODE XREF: sub_9128+3D sub_9128+41
		cp	#31 ; '1'
		jr	c, loc_919B

		cp	#39 ; '9'
		jr	nc, loc_919B

		push	bc
		sub	#31
		neg
		add	a, 7
		rlca
		rlca
		rlca
		rlca
		ld	b, a
		ld	hl,  word_D0BB+1
		ld	a, (hl)
		and	#F
		or	b
		ld	(hl), a
		pop	bc
		jp	loc_9141

; ---------------------------------------------------------------------------

loc_919B:				; CODE XREF: sub_9128+55 sub_9128+59
		push	bc
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl)
		jr	z, loc_91A5
		xor	1
loc_91A5:				; CODE XREF: sub_9128+79
		ld	b, a
		xor	a
		bit	1, b
		jr	nz, loc_91B5

		bit	0, b
		jr	z, loc_91B2

		inc	a
		jr	loc_91BF

; ---------------------------------------------------------------------------

loc_91B2:				; CODE XREF: sub_9128+85
		dec	a
		jr	loc_91BF

; ---------------------------------------------------------------------------

loc_91B5:				; CODE XREF: sub_9128+81
		bit	0, b
		jr	nz, loc_91BD

		add	a, #10
		jr	loc_91BF

; ---------------------------------------------------------------------------

loc_91BD:				; CODE XREF: sub_9128+8F
		sub	#10


loc_91BF:				; CODE XREF: sub_9128+88 sub_9128+8B ...
		ld	hl,  word_D0BB+1
		add	a, (hl)
		ld	b, a
		and	#77 ; 'w'
		cp	b
		jr	nz, loc_91CA

		ld	(hl), a


loc_91CA:				; CODE XREF: sub_9128+9F
		pop	bc
		jp	loc_9141

; ---------------------------------------------------------------------------

loc_91CE:				; CODE XREF: sub_9128+E
		ld	a, (byte_D0DF)
		bit	2, a
		ret	nz
		ld	a, c
		cp	b
		jr	nz, loc_91E0

		ld	a, #FF
		ld	(word_D0BB), a
		jp	loc_9141

; ---------------------------------------------------------------------------

loc_91E0:				; CODE XREF: sub_9128+AE
		inc	a
		jr	nz, loc_91F0

		call	sub_92A0

		jp	nz, loc_9141

		ld	a, b
		ld	(word_D0BB), a
		jp	loc_9141

; ---------------------------------------------------------------------------

loc_91F0:				; CODE XREF: sub_9128+B9
		call	sub_92B6

		jp	nz, loc_9141

		push	bc
		push	hl
		ld	a, (word_D0BB)
		ld	(byte_D0C4), a
		ld	a, (word_D0BB+1)
		ld	(byte_D0C5), a
		call	sub_9571

		pop	ix
		ld	hl, byte_D0B4
		bit	5, (hl)
		jr	z, loc_922A

		ld	d, (ix+0)
		ld	e, (ix+1)
		ld	hl, (word_D0DA)
		or	a
		sbc	hl, de
		jr	z, loc_9231

		pop	bc


loc_921F:				; CODE XREF: sub_924C+22
		ld	hl, byte_D0B4
		set	7, (hl)
		ld	hl, byte_D0DF
		set	4, (hl)
		ret

; ---------------------------------------------------------------------------

loc_922A:				; CODE XREF: sub_9128+E6
		ld	hl, byte_D0DF
		set	4, (hl)
		pop	bc
		ret

; ---------------------------------------------------------------------------

loc_9231:				; CODE XREF: sub_9128+F4
		pop	bc
		ld	a, (byte_D0DC)
		or	a
		jp	z, sub_8D9E

		ld	hl, byte_D0DF
		ld	a, (hl)
		or	#E0 ; 'а'
		ld	(hl), a
		call	sub_9571

		call	sub_937B

		ld	a, #14
		ld	(DECREMENT_50HZ), a
		ret

; End of function sub_9128


; =============== S U B	R O U T	I N E =======================================


sub_924C:				; CODE XREF: sub_8F4D+60
		ld	hl, byte_D0B8
		ld	a, (hl)
		or	a
		jr	z, loc_9279

		ld	(hl), 0
		cp	#20 ; ' '
		jp	z, sub_95C5

		ld	(byte_D0DC), a
		ld	hl, byte_D0DF
		bit	6, (hl)
		res	6, (hl)
		res	5, (hl)
		call	nz, sub_9380

		ld	a, (byte_D0DC)
		cp	#51 ; 'Q'
		jp	nz, loc_921F

		ld	hl, byte_D0DF
		res	7, (hl)
		jp	sub_8D9E

; ---------------------------------------------------------------------------

loc_9279:				; CODE XREF: sub_924C+5
		ld	hl, DECREMENT_50HZ
		ld	a, (hl)
		or	a
		ret	p
		ld	(hl), #14
		ld	hl, byte_D0DF
		ld	a, (hl)
		xor	#40 ; '@'
		ld	(hl), a
		and	#40 ; '@'
		jp	nz, sub_937B

		jp	sub_9380

; End of function sub_924C

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_9128

loc_9290:				; CODE XREF: sub_9128+13
		ld	a, #FF
		cp	c
		ret	z
		ld	a, #FF
		ld	(word_D0BB), a
		ld	a, c
		ld	(word_D0BB+1), a
		jp	loc_9141

; END OF FUNCTION CHUNK	FOR sub_9128

; =============== S U B	R O U T	I N E =======================================


sub_92A0:				; CODE XREF: sub_9128+BB
		ld	hl, unk_F000


loc_92A3:				; CODE XREF: sub_92A0+D
		ld	a, (hl)
		cp	#FF
		jr	z, loc_92AF

		cp	b
		ret	z
		inc	hl
		inc	hl
		inc	hl
		jr	loc_92A3

; ---------------------------------------------------------------------------

loc_92AF:				; CODE XREF: sub_92A0+6 sub_92B6+6
		push	af
		call	BEEP_3

		pop	af
		or	a
		ret

; End of function sub_92A0


; =============== S U B	R O U T	I N E =======================================


sub_92B6:				; CODE XREF: sub_9128:loc_91F0
		ld	hl, unk_F000


loc_92B9:				; CODE XREF: sub_92B6+13
		ld	a, (hl)
		cp	#FF
		jr	z, loc_92AF

		cp	c
		jr	nz, loc_92C6

		inc	hl
		ld	a, (hl)
		dec	hl
		cp	b
		ret	z


loc_92C6:				; CODE XREF: sub_92B6+9
		inc	hl
		inc	hl
		inc	hl
		jr	loc_92B9

; End of function sub_92B6

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_90E8

loc_92CB:				; CODE XREF: sub_90E8+14
		ld	hl, (ptr_stk_1bvalue)
		ld	l, (hl)
		inc	l
		jp	nz, loc_900E	; if not #FF

		call	BEEP_3

		ret

; END OF FUNCTION CHUNK	FOR sub_90E8

; =============== S U B	R O U T	I N E =======================================


sub_92D7:				; CODE XREF: sub_8FC1+D

; FUNCTION CHUNK AT 809A SIZE 00000007 BYTES

		push	af
		push	bc
		push	de
		push	hl
		call	sub_9933

		ld	hl, #1500
		ld	(scr_XY), hl
		ld	hl, aNew	; " NEW "
		call	PRINT_STR_scr0

		ld	de, #C00
		ld	(scr_XY), de
		ld	hl, aNewGameYN	; "NEW GAME (Y/N)?"
		call	PRINT_STR_FF


loc_92F7:
		call	KEY_SCAN
		jr	nc, loc_92F7

		push	af
		ld	hl, #1500
		ld	(scr_XY), hl
		ld	hl, a_8spaces	; "       "
		call	PRINT_STR_scr0

		pop	af
		cp	'Y'
		jp	z, loc_809A ;9EE6 + NEW_GAME

		call	BEEP_move

		ld	hl,  a_32spaces+#C
		ld	de, #C00
		ld	(scr_XY), de
		call	PRINT_STR_FF

		pop	hl
		ld	(hl), 0
		pop	de
		pop	bc
		pop	af
		ret

; End of function sub_92D7

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_90E8

loc_9326:				; CODE XREF: sub_90E8+1E
		call	sub_9571

		ld	hl, byte_D0B3
		ld	a, (hl)
		xor	8
		ld	(hl), a ;d3=swap board
		call	sub_9360

		call	sub_9380

		call	sub_9369

		call	sub_955D

		call	sub_A177

		ret

; ---------------------------------------------------------------------------

loc_9340:				; CODE XREF: sub_90E8+19
		ld	hl, (word_D25A)
		call	sub_9571

		call	sub_937B

		call	BEEP_move

		ld	a, #14
		call	halt_A_frames

		call	sub_9380

		call	sub_955D

		ret

; END OF FUNCTION CHUNK	FOR sub_90E8



halt_A_frames:

		halt
		dec	a
		ret	z
		jr	halt_A_frames


; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_90E8

loc_935D:				; CODE XREF: sub_90E8+32
		jp	loc_900E

; END OF FUNCTION CHUNK	FOR sub_90E8

; =============== S U B	R O U T	I N E =======================================


sub_9360:				; CODE XREF: sub_90E8+248
		ld	hl, BOARD
		ld	de,  BOARD+#3F
		jp	loc_936F

; End of function sub_9360


; =============== S U B	R O U T	I N E =======================================


sub_9369:				; CODE XREF: sub_90E8+24E
		ld	hl, BOARD2
		ld	de, BOARD2+63


loc_936F:				; CODE XREF: sub_9360+6
		ld	b, #20 ; ' '


loc_9371:				; CODE XREF: sub_9369+F
		ld	c, (hl)
		ld	a, (de)
		ld	(hl), a
		ld	a, c
		ld	(de), a
		inc	hl
		dec	de
		djnz	loc_9371

		ret

; End of function sub_9369


; =============== S U B	R O U T	I N E =======================================


sub_937B:				; CODE XREF: sub_8C20-97C
					; sub_8D9E+18	...
		ld	hl,  BOARD2+#3F
		jr	loc_9383

; End of function sub_937B


; =============== S U B	R O U T	I N E =======================================


sub_9380:				; CODE XREF: sub_8DE9+77 sub_924C+1A ...
		ld	hl,  BOARD+#3F


loc_9383:				; CODE XREF: sub_937B+3
		ld	b, #40 ; '@'


loc_9385:				; CODE XREF: sub_9380+1C
		ld	a, (hl)
		push	bc
		push	de
		push	hl
		ld	c, a
		ld	a, b
		dec	a
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl)
		jr	z, loc_9395
		xor	#3F ; '?'
loc_9395:				; CODE XREF: sub_9380+11
		call	SHOW_FIG_POS

		pop	hl
		pop	de
		pop	bc
		dec	hl
		djnz	loc_9385

		ret

; End of function sub_9380


; =============== S U B	R O U T	I N E =======================================


sub_939F:				; CODE XREF: sub_8C20-B31
					; sub_8C20:loc_8226 ...
		ld	hl, BOARD2
		jr	loc_93A7

; End of function sub_939F


; =============== S U B	R O U T	I N E =======================================


sub_93A4:				; CODE XREF: sub_8C20-AE1
					; sub_8C20:loc_84BF ...
		ld	hl, BOARD


loc_93A7:				; CODE XREF: sub_939F+3
		ld	(TMP_BOARD_PTR), hl
		ld	b, 0
		ld	hl, BRD_88_0


loc_93AF:				; CODE XREF: sub_93A4+78 sub_93A4+81
		push	hl
		ld	a, (hl)
		and	#43 ; 'C'
		cp	#43 ; 'C'
		ld	a, (hl)
		jr	nz, loc_93C3

		ld	c, 1
		bit	7, (hl)
		jr	nz, loc_93C0

		set	3, c


loc_93C0:				; CODE XREF: sub_93A4+18
		jp	loc_93F2

; ---------------------------------------------------------------------------

loc_93C3:				; CODE XREF: sub_93A4+12
		ld	c, 0
		or	a
		jr	z, loc_93F2

		and	#F8 ; 'ш'
		inc	a
		ld	l, a
		inc	h
		ld	c, 6
		ld	a, #F
		and	(hl)
		jr	z, loc_93EC

		ld	c, 1
		cp	1
		jr	z, loc_93EC

		ld	c, 4
		cp	5
		jr	z, loc_93EC

		ld	c, 5
		jr	nc, loc_93EC

		ld	c, 2
		bit	7, (hl)
		jr	z, loc_93EC

		ld	c, 3


loc_93EC:				; CODE XREF: sub_93A4+2E sub_93A4+34 ...
		bit	7, l
		jr	nz, loc_93F2

		set	3, c


loc_93F2:				; CODE XREF: sub_93A4:loc_93C0
					; sub_93A4+22	...
		ld	a, b
		ld	hl, byte_D0B3
		bit	3, (hl) ;d3=swap board
		jr	z, loc_93FC

		xor	#3F ; '?'


loc_93FC:				; CODE XREF: sub_93A4+54
		ld	hl, (TMP_BOARD_PTR)
		ld	e, a
		ld	d, 0
		add	hl, de
		ld	a, c
		cp	(hl)
		jr	z, loc_9417

		ld	(hl), a
		push	bc
		ld	hl, (TMP_BOARD_PTR)
		ld	de, BOARD2
		or	a
		sbc	hl, de
		ld	a, b
		call	nz, SHOW_FIG_POS

		pop	bc


loc_9417:				; CODE XREF: sub_93A4+61
		pop	hl
		inc	hl
		inc	b
		bit	3, l
		jp	z, loc_93AF

		ld	de, 8
		add	hl, de
		bit	7, l
		jp	z, loc_93AF

		ret

; End of function sub_93A4


; =============== S U B	R O U T	I N E =======================================


CLR_BOARD:				; CODE XREF: START_POINT+87
					; sub_8C20-B7C
		di
		ld	hl, BOARD
		ld	b, #40 ; '@'
		xor	a


loc_9430:				; CODE XREF: CLR_BOARD+9
		ld	(hl), a
		inc	hl
		djnz	loc_9430

		xor	a
		ld	c, a


loc_9436:				; CODE XREF: CLR_BOARD+15
		push	af
		call	SH_EMPT_POS ;show square
		pop	af
		inc	a
		cp	#40 ; '@'
		jr	nz, loc_9436

		ei
		ret

; End of function CLR_BOARD


; =============== S U B	R O U T	I N E =======================================


SH_EMPT_POS:				; CODE XREF: sub_8C6B+37 CLR_BOARD+E
		ld	c, 0

; End of function SH_EMPT_POS


; =============== S U B	R O U T	I N E =======================================

; A - position (0..63)
; C - figure:
; 0..6:	empty,pawn,knight,bishop,rook,queen,king ; 0..6 white, 8..E black

SHOW_FIG_POS:				; CODE XREF: sub_8C6B+31 sub_8C6B+49 ...
		ld	b, a		
		ld	d, #34 ; '4' ;attr: paper=6, ink=4
		and	9
		jr	z, loc_9451
		cp	9
		jr	z, loc_9451
		ld	d, #26 ; '&' ;attr: paper=4, ink=6
loc_9451:				; CODE XREF: SHOW_FIG_POS+5
					; SHOW_FIG_POS+9
		dec	c
		inc	c
		jr	z, loc_9463 ;empty figure - use default attr

		ld	a, d
		and	#F8
		ld	d, a ;attr=paper
		ld	a, 0
		bit	3, c
		jr	nz, loc_9461 ;nz=black
		ld	a, 7 ;white
loc_9461:				; CODE XREF: SHOW_FIG_POS+19
		or	d
		ld	d, a ;attr

loc_9463:				; CODE XREF: SHOW_FIG_POS+F
		push	bc
		push	de
		ld	a, b ;position (0..63)
		call	sub_95FA ;out: a=0b0YYY0XXX

		call	sub_9703 ;calc scr_XY, scr_pix_addr, scr_attr_addr

		call	CALC_SCR_ADDRS ;scr_XY to scr_pix_addr, scr_attr_addr

		call	sub_9609 ;recount scr_pix_addr, scr_attr_addr to scrbuf if needed

		ld	hl, (scr_attr_addr)
		pop	de
		ld	b, 3
loc_9478:				; CODE XREF: SHOW_FIG_POS:loc_9484
		ld	(hl), d ;attr
		inc	hl
		ld	(hl), d ;attr
		inc	hl
		ld	(hl), d ;attr
		ld	a, #1E
		add	a, l
		ld	l, a
		jr	nc, loc_9484
		inc	h
loc_9484:				; CODE XREF: SHOW_FIG_POS+3D
		djnz	loc_9478 ;set attr for figure

		pop	bc
		ld	hl, (scr_pix_addr)
		push	hl
		ld	a, c
		and	7
		ld	b, a
		add	a, a
		add	a, a
		add	a, a
		add	a, b
		ld	l, a
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	de, FIG_sprites
		add	hl, de
		ex	de, hl
		pop	hl
		ld	a, 3
		ex	af, af' ;'
loc_94A2:				; CODE XREF: SHOW_FIG_POS+78
					; SHOW_FIG_POS+7E
		push	hl
		ld	c, 3
loc_94A5:				; CODE XREF: SHOW_FIG_POS+6D
		push	hl
		ld	b, 8
loc_94A8:				; CODE XREF: SHOW_FIG_POS+68
		ld	a, (de)
		ld	(hl), a
		inc	de
		inc	h
		djnz	loc_94A8

		pop	hl
		inc	hl
		dec	c
		jr	nz, loc_94A5

		pop	hl
		ex	af, af' ;'
		dec	a
		ret	z
		ex	af, af' ;'
		ld	a, #20 ; ' '
		add	a, l
		ld	l, a
		jr	nc, loc_94A2

		ld	a, h
		add	a, 8
		ld	h, a
		jr	loc_94A2

; End of function SHOW_FIG_POS


; =============== S U B	R O U T	I N E =======================================


sub_94C4:				; CODE XREF: sub_8C20-B2E
		ld	hl, BOARD2
		jr	loc_94CC

; End of function sub_94C4


; =============== S U B	R O U T	I N E =======================================


sub_94C9:				; CODE XREF: sub_8C20+16ED
		ld	hl, BOARD


loc_94CC:				; CODE XREF: sub_94C4+3
		push	hl
		call	sub_A43C

		call	sub_A43C

		pop	hl
		ld	b, 8
		ld	d, #FF
		ld	e, #39 ; '9'
		ld	a, (byte_D0B3) ;d3=swap board
		bit	3, a
		jr	z, loc_94E5

		ld	d, 1
		ld	e, #30 ; '0'


loc_94E5:				; CODE XREF: sub_94C9+16 sub_94C9+59
		ld	c, 8
		ld	a, e
		add	a, d
		ld	e, a
		call	loc_A476

		ld	a, #20 ; ' '
		call	loc_A476


loc_94F2:				; CODE XREF: sub_94C9+51
		ld	a, (hl)
		push	hl
		push	de
		push	bc
		ld	c, a
		and	7
		jr	nz, loc_94FF

		ld	a, #2E ; '.'
		jr	loc_950D

; ---------------------------------------------------------------------------

loc_94FF:				; CODE XREF: sub_94C9+30
		ld	hl, KING+1
		call	sub_8CF7

		dec	hl
		ld	a, (hl)
		bit	3, c
		jr	z, loc_950D

		or	#20 ; ' '


loc_950D:				; CODE XREF: sub_94C9+34 sub_94C9+40
		call	loc_A476

		ld	a, #20 ; ' '
		call	loc_A476

		pop	bc
		pop	de
		pop	hl
		inc	hl
		dec	c
		jr	nz, loc_94F2

		call	sub_A43C

		call	sub_A43C

		djnz	loc_94E5

		ld	a, d
		neg
		ld	d, a
		ld	a, e
		add	a, #30 ; '0'
		ld	e, a
		ld	b, 2


loc_952E:				; CODE XREF: sub_94C9+6A
		ld	a, #20 ; ' '
		call	loc_A476

		djnz	loc_952E

		ld	b, 8


loc_9537:				; CODE XREF: sub_94C9+7A
		ld	a, e
		call	loc_A476

		ld	a, #20 ; ' '
		call	loc_A476

		ld	a, e
		add	a, d
		ld	e, a
		djnz	loc_9537

		call	sub_A43C

		call	sub_A43C

		ret

; End of function sub_94C9


; =============== S U B	R O U T	I N E =======================================


sub_954C:				; CODE XREF: sub_8C20-AF1
		call	sub_A164

		ld	a, #70 ; 'p'
		jr	c, loc_9554

		xor	a


loc_9554:				; CODE XREF: sub_954C+5
		ld	(word_D0BB+1), a
		ld	a, #FF
		ld	(word_D0BB), a
		ret

; End of function sub_954C


; =============== S U B	R O U T	I N E =======================================


sub_955D:				; CODE XREF: sub_8C20-A94
					; sub_8C20-88F ...
		ld	a, (word_D0BB+1)
		cp	#FF
		call	nz, sub_9585

		ld	a, (word_D0BB)
		cp	#FF
		call	nz, sub_95A8

		call	sub_8939

		ret

; End of function sub_955D


; =============== S U B	R O U T	I N E =======================================


sub_9571:				; CODE XREF: sub_8C20-AF4
					; sub_8C20-85C ...
		ld	a, (word_D0BB+1)
		cp	#FF
		call	nz, sub_9595

		ld	a, (word_D0BB)
		cp	#FF
		call	nz, sub_9595

		call	restore_6_spaces

		ret

; End of function sub_9571


; =============== S U B	R O U T	I N E =======================================


sub_9585:				; CODE XREF: sub_9128+2C sub_955D+5
		push	af
		ld	a, (byte_D04D)
		or	a
		ld	d, 0
		ld	e, #A9	; '©'
		jr	z, loc_9592

		ld	e, #AA	; '™'


loc_9592:				; CODE XREF: sub_9585+9
		pop	af
		jr	loc_959B

; End of function sub_9585


; =============== S U B	R O U T	I N E =======================================


sub_9595:				; CODE XREF: sub_8C20-20C
					; sub_8C20-17C ...
		ld	d, #FF
		ld	e, 0
		jr	loc_959B

; ---------------------------------------------------------------------------

loc_959B:				; CODE XREF: sub_9585+E sub_9595+4 ...
		push	hl
		push	af
		push	de
		call	sub_95AE

		pop	de
		and	d
		or	e
		ld	(hl), a
		pop	af
		pop	hl
		ret

; End of function sub_9595


; =============== S U B	R O U T	I N E =======================================


sub_95A8:				; CODE XREF: sub_9128+34 sub_955D+D
		ld	d, 0
		ld	e, #29 ; ')'
		jr	loc_959B

; End of function sub_95A8


; =============== S U B	R O U T	I N E =======================================


sub_95AE:				; CODE XREF: sub_9595+9
		and	#77 ; 'w'
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl)
		jr	z, loc_95B9

		xor	#77 ; 'w'


loc_95B9:				; CODE XREF: sub_95AE+7
		call	sub_9703 ;calc scr_XY, scr_pix_addr, scr_attr_addr

		ld	hl, (scr_attr_addr)
		ld	a, (hl)
		ld	de, #21	; '!'
		add	hl, de
		ret

; End of function sub_95AE


; =============== S U B	R O U T	I N E =======================================


sub_95C5:				; CODE XREF: sub_8FC1+8 sub_924C+B ...
		ld	hl, SEL_SCRorBUF
		ld	a, (hl)
		cpl
		ld	(hl), a
		call	SET_BRD_COLOR

		ld	hl, SCREEN
		ld	de, SCR_BUF_6400
		ld	c, #1B
		ld	b, 0


loc_95D8:				; CODE XREF: sub_95C5+1B sub_95C5+1E
		ld	a, (hl)
		ex	af, af'
		ld	a, (de)
		ld	(hl), a
		ex	af, af'
		ld	(de), a
		inc	hl
		inc	de
		djnz	loc_95D8

		dec	c
		jr	nz, loc_95D8

		ret

; End of function sub_95C5

		;unused data???
		db	#47,#1F,#E6,#38,#4F,#78,#E6,#07,#81

; =============== S U B	R O U T	I N E =======================================


sub_95EF:				; CODE XREF: sub_95FA+1
		push	hl
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl) ;swap board?
		pop	hl
		ret	z
		xor	#3F ; '?'
		ret

; End of function sub_95EF


; =============== S U B	R O U T	I N E =======================================


sub_95FA:				; CODE XREF: SHOW_FIG_POS+22
;a=position (0..63)
		push	bc
		call	sub_95EF ;swap board if needed
		ld	b, a
		and	#38 ; '8'
		rlca
		ld	c, a ;c=0b0YYY0000
		ld	a, b
		and	7
		or	c    ;a=0b0YYY0XXX
		pop	bc
		ret

; End of function sub_95FA


; =============== S U B	R O U T	I N E =======================================
;recount scr_pix_addr, scr_attr_addr to scrbuf if needed

sub_9609:				; CODE XREF: SHOW_FIG_POS+2B
		ld	a, (SEL_SCRorBUF)
		or	a
		ret	z
		jr	loc_9615

; ---------------------------------------------------------------------------
		ld	a, (SEL_SCRorBUF)
		or	a
		ret	nz


loc_9615:				; CODE XREF: sub_9609+5
		push	de
		push	hl
		ld	de, #2400
		ld	hl, (scr_pix_addr)
		add	hl, de
		ld	(scr_pix_addr),	hl
		ld	hl, (scr_attr_addr)
		add	hl, de
		ld	(scr_attr_addr), hl
		pop	hl
		pop	de
		ret

; End of function sub_9609


; =============== S U B	R O U T	I N E =======================================


CLR_SCR_OR_BUF:				; CODE XREF: START_POINT+84
		di
		ld	hl, SCREEN
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_9638

		ld	hl, SCR_BUF_6400


loc_9638:				; CODE XREF: CLR_SCR_OR_BUF+8
		ld	a, h
		add	a, #18
		ld	b, 0


loc_963D:				; CODE XREF: CLR_SCR_OR_BUF+15
		ld	(hl), b
		inc	hl
		cp	h
		jr	nz, loc_963D

		ld	b, #28 ; '('    ; ink=0, paper=5
		add	a, 3


loc_9646:				; CODE XREF: CLR_SCR_OR_BUF+1E
		ld	(hl), b
		inc	hl
		cp	h
		jr	nz, loc_9646

; End of function CLR_SCR_OR_BUF


; =============== S U B	R O U T	I N E =======================================


SET_BRD_COLOR:				; CODE XREF: sub_95C5+6 sub_965C+30	...
		ld	a, (SEL_SCRorBUF)
		or	a
		ld	a, 5
		jr	nz, loc_9655

		ld	a, 5


loc_9655:				; CODE XREF: SET_BRD_COLOR+6
		ld	(BRD_COLOR), a
		out	(#FE),	a
		ei
		ret

; End of function SET_BRD_COLOR


; =============== S U B	R O U T	I N E =======================================


sub_965C:				; CODE XREF: sub_9EE6
		di
		ld	hl, 0
		ld	(word_D0D5), hl
		ld	hl, SCR_BUF_6400
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_966F

		ld	hl, SCREEN


loc_966F:				; CODE XREF: sub_965C+E
		ld	a, h
		add	a, #18
		ld	b, 0


loc_9674:				; CODE XREF: sub_965C+1B
		ld	(hl), b
		inc	hl
		cp	h
		jr	nz, loc_9674

		ld	c, #18
		ld	de, fill_attrs


loc_967E:				; CODE XREF: sub_965C+2D
		ld	b, #20 ; ' '
		ld	a, (de)


loc_9681:				; CODE XREF: sub_965C+27
		ld	(hl), a
		inc	hl
		djnz	loc_9681

		dec	c
		jr	z, loc_968B

		inc	de
		jr	loc_967E

; ---------------------------------------------------------------------------

loc_968B:				; CODE XREF: sub_965C+2A
		ei
		jr	SET_BRD_COLOR

; End of function sub_965C

; ---------------------------------------------------------------------------
fill_attrs:	db  #3A,#3A,#29,#29,#29,#29,#29,#29
		db  #29,#29,#29,#29,#29,#29,#29,#29
		db  #32,#32,#32,#32,#32,#32,#32,#32

; =============== S U B	R O U T	I N E =======================================


sub_96A6:				; CODE XREF: sub_8C20:NEW_GAME
					; sub_8C20-5E7 ...
		ld	hl, #600
		ld	(scr_XY), hl


loc_96AC:				; CODE XREF: sub_96A6+11
		ld	hl, a_32spaces	; "                        "
		call	PRINT_STR_FF

		ld	a, (scr_XY+1)
		cp	#D
		jr	nz, loc_96AC

		xor	a
		ld	(byte_D0C0), a
		ret

; End of function sub_96A6


; =============== S U B	R O U T	I N E =======================================


CALC_SCR_ADDRS:				; CODE XREF: sub_8EFB+8 sub_8EFB+22	...
		push	bc
		push	de
		push	hl
		ld	bc, (scr_XY)
		ld	a, b
		ld	hl, SCREEN
		ld	de, #800
loc_96CC:				; CODE XREF: CALC_SCR_ADDRS+15
		cp	8
		jr	c, loc_96D5
		sub	8
		add	hl, de
		jr	loc_96CC
loc_96D5:				; CODE XREF: CALC_SCR_ADDRS+10
		rrca
		rrca
		rrca
		add	a, c
		ld	e, a
		ld	d, 0
		add	hl, de
		ld	(scr_pix_addr),	hl
		ld	l, b
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, hl
		ld	de, SCR_ATTRS
		add	hl, de
		ld	e, c
		ld	d, 0
		add	hl, de
		ld	(scr_attr_addr), hl
		pop	hl
		pop	de
		pop	bc
		ret

; End of function CALC_SCR_ADDRS


; =============== S U B	R O U T	I N E =======================================


sub_96F7:				; CODE XREF: sub_8D9E+21 sub_8D9E+2D
;a=0b0YYY0XXX
		push	hl
		ld	hl, byte_D0B3 ;d3=swap board
		bit	3, (hl)
		jr	z, loc_9704

		xor	#77 ;swap board
		jr	loc_9704

; End of function sub_96F7


; =============== S U B	R O U T	I N E =======================================
;count scr_XY, scr_pix_addr, scr_attr_addr

sub_9703:				; CODE XREF: SHOW_FIG_POS+25
					; sub_95AE:loc_95B9
;a=0b0YYY0XXX
		push	hl


loc_9704:				; CODE XREF: sub_96F7+6 sub_96F7+A
;a=0b0YYY0XXX
		push	de
		push	bc
		ld	c, a
		and	#F0 ; 'р'
		rlca
		rlca
		rlca
		rlca
		ld	b, a
		add	a, a
		add	a, b
		ld	h, a
		ld	a, c
		and	#F
		ld	b, a
		add	a, a
		add	a, b
		add	a, 8
		ld	l, a
		ld	(scr_XY), hl
		call	CALC_SCR_ADDRS ;scr_XY to scr_pix_addr, scr_attr_addr

		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_9737

		ld	de, #2400
		ld	hl, (scr_pix_addr)
		add	hl, de
		ld	(scr_pix_addr),	hl
		ld	hl, (scr_attr_addr)
		add	hl, de
		ld	(scr_attr_addr), hl

loc_9737:				; CODE XREF: sub_9703+21
		pop	bc
		pop	de
		pop	hl
		ret

; End of function sub_9703

; ---------------------------------------------------------------------------


	;following table could be placed anywhere without alignment

		;--empty--
FIG_sprites:	db  #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00 ; 72	bytes (24x24 pix) each,
		db  #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00 ; empty, pawn, knight, bishop,
		db  #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00 ; rook, queen, king.
		;pawn
		db  #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #00, #3C, #7E, #FF, #FF, #FF, #00, #00, #00, #00, #00, #00, #00, #00
		db  #00, #00, #01, #00, #00, #00, #00, #00, #FF, #7E, #FF, #7E, #3C, #3C, #3C, #7E, #00, #00, #80, #00, #00, #00, #00, #00
		db  #00, #00, #00, #03, #07, #07, #03, #00, #7E, #7E, #FF, #81, #FF, #FF, #FF, #00, #00, #00, #00, #C0, #E0, #E0, #C0, #00
		;knight
		db  #00, #00, #00, #00, #01, #07, #1F, #1F, #00, #03, #1F, #7F, #BF, #FF, #FF, #FF, #00, #80, #80, #00, #00, #80, #80, #80
		db  #07, #0F, #00, #00, #01, #03, #07, #07, #FF, #BF, #7F, #FF, #FF, #FF, #FF, #FF, #C0, #C0, #C0, #E0, #E0, #E0, #E0, #E0
		db  #03, #00, #01, #03, #0F, #0F, #07, #00, #FF, #FF, #FF, #00, #FF, #FF, #FF, #00, #C0, #00, #80, #C0, #F0, #F0, #E0, #00
		;bishop
		db  #00, #00, #00, #00, #00, #00, #01, #03, #00, #18, #3C, #3C, #26, #9F, #CF, #E7, #00, #00, #00, #00, #00, #00, #80, #C0
		db  #03, #07, #07, #07, #07, #03, #01, #00, #F7, #FF, #FF, #FF, #FF, #FF, #FF, #FF, #C0, #E0, #E0, #E0, #E0, #C0, #80, #00
		db  #00, #01, #03, #07, #0F, #0F, #07, #00, #FF, #FF, #FF, #00, #FF, #FF, #FF, #00, #00, #80, #C0, #E0, #F0, #F0, #E0, #00
		;rook
		db  #00, #00, #00, #0F, #0F, #0F, #0F, #0F, #00, #00, #00, #3C, #3C, #3C, #FF, #FF, #00, #00, #00, #F0, #F0, #F0, #F0, #F0
		db  #07, #02, #03, #03, #03, #03, #03, #03, #FF, #00, #FF, #FF, #FF, #FF, #FF, #FF, #E0, #40, #C0, #C0, #C0, #C0, #C0, #C0
		db  #03, #03, #07, #0E, #1F, #1F, #0F, #00, #FF, #FF, #FF, #00, #FF, #FF, #FF, #00, #C0, #C0, #E0, #70, #F8, #F8, #F0, #00
		;queen
		db  #00, #00, #00, #00, #00, #01, #47, #5E, #00, #18, #3C, #3C, #66, #FF, #7E, #3C, #00, #00, #00, #00, #00, #80, #E2, #7A
		db  #4C, #61, #3F, #1F, #0F, #07, #03, #02, #99, #C3, #FF, #FF, #FF, #FF, #FF, #FF, #32, #86, #FC, #F8, #F0, #E0, #C0, #40
		db  #0F, #0B, #1F, #18, #3F, #3F, #1F, #00, #FF, #66, #FF, #00, #FF, #FF, #FF, #00, #F0, #D0, #F8, #18, #FC, #FC, #F8, #00
		;king
		db  #00, #00, #00, #00, #1E, #33, #61, #4C, #00, #7E, #66, #5A, #5A, #66, #FF, #66, #00, #00, #00, #00, #78, #CC, #86, #32
		db  #5F, #5F, #4F, #67, #37, #13, #1B, #08, #66, #3C, #99, #DB, #DB, #DB, #DB, #00, #FA, #FA, #F2, #E6, #EC, #C8, #D8, #10
		db  #0F, #0B, #1F, #18, #3F, #3F, #1F, #00, #FF, #66, #FF, #00, #FF, #FF, #FF, #00, #F0, #D0, #F8, #18, #FC, #FC, #F8, #00

; =============== S U B	R O U T	I N E =======================================


sub_9933:				; CODE XREF: sub_92D7+4
		call	BEEP_move

		jp	BEEP_start

; End of function sub_9933


; =============== S U B	R O U T	I N E =======================================


sub_9939:				; CODE XREF: sub_8C20-5F
		call	BEEP_start

		call	BEEP_move

; End of function sub_9939


; =============== S U B	R O U T	I N E =======================================


BEEP_start:				; CODE XREF: sub_8C20-B76
					; sub_8C20:loc_83E8 ...
		push	hl
		push	de
		ld	hl, #511
		ld	de, #A5 ; '•'
		jr	BEEP_common

; End of function BEEP_start


; =============== S U B	R O U T	I N E =======================================


BEEP_move:				; CODE XREF: sub_8C20-A51
					; sub_8C20-79C ...
		push	hl
		push	de
		ld	hl, #43E
		ld	de, #C4 ; 'ƒ'
		jr	BEEP_common

; End of function BEEP_move


; =============== S U B	R O U T	I N E =======================================


BEEP_3:					; CODE XREF: sub_8C20:loc_8419
					; sub_8C20:loc_85DD ...
		push	hl
		push	de
		ld	hl, #66A
		ld	de, #83	; 'Г'
		jr	BEEP_common

; End of function BEEP_3


; =============== S U B	R O U T	I N E =======================================


BEEP_4:					; CODE XREF: sub_907E+23
		push	hl
		push	de
		ld	hl, #326
		ld	de, #34	; '4'
		jr	BEEP_common

; ---------------------------------------------------------------------------
		push	hl
		push	de
		ld	hl, #326
		ld	de, #105


BEEP_common:				; CODE XREF: BEEP_start+8
					; BEEP_move+8	...
		di
		call	BEEP_routine

		ei
		pop	de
		pop	hl
		ret

; End of function BEEP_4


; =============== S U B	R O U T	I N E =======================================


BEEP_routine:				; CODE XREF: BEEP_4+13
		di
		push	ix
		push	bc
		ld	a, l
		srl	l
		srl	l
		cpl
		and	3
		ld	c, a
		ld	b, 0
		ld	ix, BEEP_loop
		add	ix, bc
		ld	a, (BRD_COLOR)
		or	8


BEEP_loop:				; DATA XREF: BEEP_routine+F
		nop
		nop
		nop
		inc	b
		inc	c


BEEP_wait:				; CODE XREF: BEEP_routine+20
					; BEEP_routine+25
		dec	c
		jr	nz, BEEP_wait

		ld	c, #3F ; '?'
		dec	b
		jp	nz, BEEP_wait

		xor	#10
		out	(#FE),	a
		ld	b, h
		ld	c, a
		bit	4, a
		jr	nz, BEEP_smth

		ld	a, d
		or	e
		jr	z, BEEP_exit

		ld	a, c
		ld	c, l
		dec	de
		jp	(ix)

; ---------------------------------------------------------------------------

BEEP_smth:				; CODE XREF: BEEP_routine+30
		ld	c, l
		inc	c
		jp	(ix)

; ---------------------------------------------------------------------------

BEEP_exit:				; CODE XREF: BEEP_routine+34
		pop	bc
		pop	ix
		ei
		ret

; End of function BEEP_routine

; ---------------------------------------------------------------------------
aCyrusIi:	db 'CYRUS II     ',#7F
		db ' 1986',#0D
		db ' INTELLIGENT CHESS SOFTWARE LTD'
		EOS

		db '  LEVEL' ; unused string?
		EOS

		; unused string?
		db	'Press <SPACE> to see board'
		EOS

aPress:		db ' PRESS',#0D
		db '<SPACE>',#0D
		db '  for',#0D
		db ' MENU'
		EOS


aOOO:		db 'O-O-O'          ; DATA XREF: sub_8977+14


aNewGameYN:	db 'NEW GAME (Y/N)? ' ; DATA XREF: sub_92D7+1A
		EOS

aNew:		db ' NEW ?'          ; DATA XREF: sub_92D7+D
		EOS

aCyrus:		db 'CYRUS '          ; DATA XREF: sub_9F73 sub_A177+86 ...
		EOS

a_PLAYER:	db 'PLAYER'          ; DATA XREF: sub_9F73+5 sub_A177+8D ...
		EOS

a_ADAP:		db 'ADAP'            ; DATA XREF: sub_8D2C:loc_8D56
		EOS

a_INF:		db 'INF '            ; DATA XREF: sub_8D2C+2F
		EOS

aProb:		db 'PROB'            ; DATA XREF: sub_8D2C+36
		EOS

aAnalysis:	db 'ANALYSIS'        ; DATA XREF: sub_842C+10
		EOS

aPrinter:	db 'PRINTER'
		EOS

aNoMateIn:	db 'NO MATE IN '     ; DATA XREF: sub_A6F7:loc_A725
		EOS

aIllegalSetup:	db 'ILLEGAL SETUP'   ; DATA XREF: sub_8C20+1
		EOS

aStalemate:	db 'STALEMATE'       ; DATA XREF: sub_8C20-8A
		EOS

aCheckmate:	db 'CHECKMATE'       ; DATA XREF: sub_8C20:loc_8B8D
		EOS
		
aDraw:		db 'DRAW'            ; DATA XREF: sub_8C20:loc_8B9B
		EOS

aBlack:		db 'BLACK'           ; DATA XREF: sub_8C20-62E
					; sub_9F0D+61
		EOS

aWhite:		db 'WHITE'           ; DATA XREF: sub_8C20-637
					; sub_9F0D+58
		EOS

aInitClk:	db '00:00:00'        ; DATA XREF: INIT_PRINT_CLOCKS
					; INIT_PRINT_CLOCKS+B	...
		EOS


a_32spaces:	db '                        '
a_8spaces:	db '        '
		EOS

aSetUpPosition:	db 'SET UP POSITION',#0D ; DATA XREF: sub_9F0D+6
		db 'C - Clear board M - Multi-move  E - Empty squ.  S - exit Setup  '
		db 'G - new Game    X - swap colour L - Level       Z - Zero clocks '
		db  #0D
		db '   P,N,B,R,Q,K - piece to add'
		EOS

aThinking:	db 'THINKING',#0D       ; DATA XREF: sub_9F0D+32
		db  #0D
		db 'M - Move now      H - Hint',#0D
		db 'G - new Game'
		EOS

aYourMove:	db 'YOUR MOVE',#0D
		db 'A - Analysis      B - Back',#0D
		db 'C - Cassette      D - Demo',#0D
		db 'F - Forward       G - new Game',#0D
		db 'H - Hint          I - Invert',#0D
		db 'L - Level         M - Move',#0D
		db	'P - Printer       S - Set posn.'
		EOS

aBBackSSetPosn_:db 'B - Back          S - Set posn. G - new Game'
		EOS

aSSaveRecordLLo:db 'S- Save record   L- Load record',#0D
		db  #0D
		db '  PRESS ANY OTHER KEY TO ABORT'
		EOS

aNotAGameRecord:db 'NOT A '
aGameRecord:	db 'GAME RECORD : ' ; DATA XREF: sub_8C20+1A03
		EOS

aLoadAGameRecor:db '      LOAD A GAME RECORD',#0D
		db 'ENTER FILENAME; <BREAK> TO ABORT'
		EOS

aSaveTheGameRec:db '      SAVE THE GAME RECORD',#0D
		db 'ENTER FILENAME; <BREAK> TO ABORT'
		EOS

aStartTapeAndPr:db '  START TAPE AND PRESS ANY KEY'
		EOS

aZZxPrinterPSer:db ' Z-ZX PRINTER    P-SERIAL',#0D
		db ' G-GAME RECORD   B-BOARD',#0D
		db ' C-CONTINUOUS    O-OPTIONS',#0D
		db  #0D
		db '  PRESS ANY OTHER KEY TO ABORT'
		EOS

aSelectBaudRate:db 'SELECT BAUD RATE:-',#0D
		db '1=50  2=110  3=300  4=600 5=12006=2400  7=4800  8=9600  9=19200 ',#0D
		db '            C=CR+LF',#0D
		db  #0D
		db '  PRESS ANY OTHER KEY TO ABORT'
		EOS
; ---------------------------------------------------------------------------

PRINT_STR_scr0:				; CODE XREF: sub_8C20-666
					; sub_8C20:loc_85F5 ...
		xor	a
		jr	PRINT_STR_A


; =============== S U B	R O U T	I N E =======================================


sub_9E68:				; CODE XREF: sub_8C20-6B sub_8C20+4	...
		ld	de, #F00
		ld	(scr_XY), de
		call	PRINT_STR_FF

		ret

; End of function sub_9E68


; =============== S U B	R O U T	I N E =======================================


PRINT_STR_FF:				; CODE XREF: sub_842C:loc_843F
					; sub_890F+9 ...
		ld	a, #FF


PRINT_STR_A:				; CODE XREF: RAM:9E66
		ld	(NEED_SCR2BUF),	a


loc_9E78:				; CODE XREF: PRINT_STR_FF+14
					; PRINT_STR_FF+1F
		ld	a, (hl)
		inc	hl
		cp	#D
		jr	nz, loc_9E89

		push	hl
		ld	hl, scr_XY
		ld	(hl), 0
		inc	hl
		inc	(hl)
		pop	hl
		jr	loc_9E78

; ---------------------------------------------------------------------------

loc_9E89:				; CODE XREF: PRINT_STR_FF+9
		push	af
		and	#7F ; ''
		call	PRINT_LETTER

		pop	af
		bit	7, a
		jr	z, loc_9E78

		ret

; End of function PRINT_STR_FF


; =============== S U B	R O U T	I N E =======================================


PRINT_LETTER:				; CODE XREF: sub_8D2C+1C sub_8D2C+22 ...
		push	hl
		push	de
		push	bc
		push	af
		call	CALC_SCR_ADDRS

		ld	hl, (scr_pix_addr)
		call	ADDR_SCR2BUF

		add	hl, de
		pop	af
		cp	#30
		jr	nz, loc_9EAA

		ld	a, #4F ; 'O'


loc_9EAA:				; CODE XREF: PRINT_LETTER+11
		push	hl
		ld	de,font-256 ;#3C00	; ROM FONT
		ld	l, a
		ld	h, 0
		add	hl, hl
		add	hl, hl
		add	hl, hl
		add	hl, de
		ex	de, hl
		pop	hl
		ld	b, 8


loc_9EB9:				; CODE XREF: PRINT_LETTER+28
		ld	a, (de)
		ld	(hl), a
		inc	de
		inc	h
		djnz	loc_9EB9

		ld	hl, (scr_XY)
		ld	a, l
		inc	a
		cp	#20 ; ' '
		jr	nz, loc_9ECA

		xor	a
		inc	h


loc_9ECA:				; CODE XREF: PRINT_LETTER+31
		ld	l, a
		ld	(scr_XY), hl
		pop	bc
		pop	de
		pop	hl
		ret

; End of function PRINT_LETTER


; =============== S U B	R O U T	I N E =======================================


ADDR_SCR2BUF:				; CODE XREF: PRINT_LETTER+A
		push	af
		push	hl
		ld	a, (SEL_SCRorBUF)
		ld	hl, NEED_SCR2BUF
		cp	(hl)
		ld	de, #2400	; addition to move to SCR_BUF=#6400
		jr	nz, loc_9EE3

		ld	de, 0


loc_9EE3:				; CODE XREF: ADDR_SCR2BUF+C
		pop	hl
		pop	af
		ret

; End of function ADDR_SCR2BUF


; =============== S U B	R O U T	I N E =======================================


sub_9EE6:				; CODE XREF: sub_92D7-1239
					; sub_8C20+1A5B
		call	sub_965C

		ld	hl, #C
		ld	(scr_XY), hl
		ld	hl, aCyrusIi	; "CYRUS II     "
		call	PRINT_STR_FF

		ld	de, #318
		ld	(scr_XY), de
		call	PRINT_STR_FF

		ld	de, #1703
		ld	(scr_XY), de
		call	PRINT_STR_FF

		call	sub_8D2C

		ret

; End of function sub_9EE6


; =============== S U B	R O U T	I N E =======================================


sub_9F0D:				; CODE XREF: sub_8C20:loc_818F
					; sub_8C20:loc_8378 ...
;show state and help
; FUNCTION CHUNK AT 9F5B SIZE 00000018 BYTES

		call	sub_842C

		ld	de, #1000
		ld	hl, aSetUpPosition ; "SET UP POSITION"
		ld	a, (byte_D04D)
		rra
		jr	c, loc_9F5B

		push	de
		ld	de, #306
		call	sub_9F8B

		bit	1, b
		call	sub_9F73

		bit	0, b
		call	sub_9F73

		call	sub_A177

		pop	de
		ld	hl, aYourMove	; "YOUR MOVE"
		ld	a, (byte_D0B4)
		bit	5, a
		jr	nz, sub_9F42

		bit	6, a
		jr	z, sub_9F42

		ld	hl, aThinking	; "THINKING"

; End of function sub_9F0D


; =============== S U B	R O U T	I N E =======================================


sub_9F42:				; CODE XREF: sub_8C20-62 sub_9F0D+2C ...
		ld	bc, (word_D0D5)
		ld	(word_D0D5), hl
		or	a
		sbc	hl, bc
		ret	z
		call	sub_9F9E

		ld	hl, (word_D0D5)


loc_9F53:				; CODE XREF: sub_9F0D+5F sub_9F0D+64
		ld	(scr_XY), de
		call	PRINT_STR_FF

		ret

; End of function sub_9F42

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_9F0D

loc_9F5B:				; CODE XREF: sub_9F0D+D
		ld	(scr_XY), de
		call	sub_9F42

		ld	de, #1019
		ld	hl, aWhite	; "WHIT"
		ld	a, (byte_D08D)
		rla
		jr	c, loc_9F53

		ld	hl, aBlack	; "BLAC"
		jr	loc_9F53

; END OF FUNCTION CHUNK	FOR sub_9F0D

; =============== S U B	R O U T	I N E =======================================


sub_9F73:				; CODE XREF: sub_9F0D+18 sub_9F0D+1D
		ld	hl, aCyrus	; "CYRUS"
		jr	nz, loc_9F7B

		ld	hl, a_PLAYER	; "PLAYE"


loc_9F7B:				; CODE XREF: sub_9F73+3
		ld	(scr_XY), de
		call	PRINT_STR_FF

		ld	de, (scr_XY)
		inc	de
		inc	de
		inc	de
		inc	de
		ret

; End of function sub_9F73


; =============== S U B	R O U T	I N E =======================================


sub_9F8B:				; CODE XREF: sub_9F0D+13 sub_A177+83
		ld	a, (byte_D0B4)
		ld	b, 0
		rra
		ret	c
		ld	b, 3
		rra
		ret	c
		dec	b
		ld	a, (byte_D0B2)
		or	a
		ret	z
		dec	b
		ret

; End of function sub_9F8B


; =============== S U B	R O U T	I N E =======================================


sub_9F9E:				; CODE XREF: sub_9F42+B
		ld	hl, #1000
		ld	(scr_XY), hl


loc_9FA4:				; CODE XREF: sub_9F9E+12
		ld	hl, a_32spaces	; "                        "
		call	PRINT_STR_FF

		ld	a, (scr_XY+1)
		cp	#17
		ret	z
		jr	loc_9FA4

; End of function sub_9F9E


; =============== S U B	R O U T	I N E =======================================


sub_9FB2:				; CODE XREF: sub_8C20-94C
					; sub_8DE9+4D
		ld	a, #FF
		ld	(NEED_SCR2BUF),	a
		call	sub_A08D

		ld	l, 6
		call	sub_A164

		ld	a, (byte_D0C0)
		jr	c, loc_9FCB

		ld	l, #10
		inc	a
		ld	(byte_D0C0), a
		dec	a


loc_9FCB:				; CODE XREF: sub_9FB2+10
		add	a, 6
		ld	h, a
		push	hl
		ld	(scr_XY), hl
		ld	hl, buf_10bytes
		call	PRINT_STR_FF

		pop	hl
		ld	de, #B10
		or	a
		sbc	hl, de
		call	z, SCROLL_UP

		ld	hl, buf_10bytes
		ld	de, txt_buf_6
		ld	bc, 6
		ldir
		ex	de, hl
		dec	hl
		set	7, (hl)
		call	sub_A3D0

		ret

; End of function sub_9FB2


; =============== S U B	R O U T	I N E =======================================


sub_9FF5:				; CODE XREF: sub_8C20-A12
					; sub_8C20-A06 ...
		push	hl
		push	bc
		ld	b, #20 ; ' '
		ld	l, a
		ld	h, BRD_88_0/256
		ld	a, (hl)
		or	a
		jr	z, loc_A01D

		ld	l, a
		res	2, l
		inc	l
		inc	h		; word_D100
		ld	a, (hl)
		and	#F
		ld	b, #4B ; 'K'
		jr	z, loc_A01D

		ld	b, #20 ; ' '
		cp	1
		jr	z, loc_A01D

		ld	a, (hl)
		and	#8F ; 'П'
		ld	hl, KING-1
		call	sub_8CF7

		inc	hl
		ld	b, (hl)


loc_A01D:				; CODE XREF: sub_9FF5+9 sub_9FF5+15	...
		ld	a, b
		pop	bc
		pop	hl
		ret

; End of function sub_9FF5


; =============== S U B	R O U T	I N E =======================================


sub_A021:				; CODE XREF: sub_A684+36 sub_A684+42
		ld	b, a
		and	7
		add	a, #61 ; 'a'
		call	PRINT_LETTER

		ld	a, #70 ; 'p'
		and	b
		rra
		rra
		rra
		rra
		neg
		add	a, #38 ; '8'
		call	PRINT_LETTER

		ret

; End of function sub_A021


; =============== S U B	R O U T	I N E =======================================


INIT_PRINT_CLOCKS:			; CODE XREF: sub_8C20-B79
					; sub_8C20-60B ...
		ld	hl, aInitClk	; "00:00:0"
		ld	de, CLK_1
		ld	bc, 8
		ldir
		ld	hl, aInitClk	; "00:00:0"
		ld	de, CLK_2
		ld	bc, 8
		ldir
		ld	hl, #405
		ld	(scr_XY), hl
		ld	hl, aInitClk	; "00:00:0"
		call	PRINT_STR_FF

		ld	hl, #40F
		ld	(scr_XY), hl
		ld	hl, aInitClk	; "00:00:0"
		call	PRINT_STR_FF

		call	sub_A228

		ret

; End of function INIT_PRINT_CLOCKS


; =============== S U B	R O U T	I N E =======================================


PRINT_CLOCKS_SWAP:			; CODE XREF: sub_8C20+1A5E
		ld	hl, #405
		ld	(scr_XY), hl
		ld	hl, CLK_2
		ld	de, CLK_1
		ld	a, (byte_D0B3) ;d3=swap board
		and	8
		jr	z, loc_A07E

		ex	de, hl


loc_A07E:				; CODE XREF: PRINT_CLOCKS_SWAP+11
		push	de
		call	PRINT_STR_FF

		ld	hl,#40F
		ld	(scr_XY), hl
		pop	hl
		call	PRINT_STR_FF

		ret

; End of function PRINT_CLOCKS_SWAP


; =============== S U B	R O U T	I N E =======================================


sub_A08D:				; CODE XREF: sub_8C20-AF7 sub_9FB2+5
		ld	a, #FF		; print	move # in decimal???
		ld	(NEED_SCR2BUF),	a
		ld	a, (byte_D0C0)
		add	a, 6
		ld	h, a
		ld	l, 0
		ld	(scr_XY), hl
		ld	a, (byte_D049) ;move #
		ld	b, a
		ld	a, (byte_D0B4)
		bit	5, a
		jr	z, loc_A0AF

		ld	a, (byte_D0BF)
		rra
		jr	nc, loc_A0AF

		dec	b


loc_A0AF:				; CODE XREF: sub_A08D+19 sub_A08D+1F
		ld	a, (byte_D0B7)
		cp	b
		ret	z
		ld	a, b
		ld	(byte_D0B7), a
		ld	bc, #3000


loc_A0BB:				; CODE XREF: sub_A08D+36
		cp	#64 ; 'd'
		jr	c, loc_A0C5

		inc	b
		inc	c
		sub	#64 ; 'd'
		jr	loc_A0BB

; ---------------------------------------------------------------------------

loc_A0C5:				; CODE XREF: sub_A08D+30
		ex	af, af' ;'
		ld	a, b
		cp	#30 ; '0'
		jr	nz, loc_A0D3

		ld	a, c
		or	a
		ld	a, #30 ; '0'
		jr	nz, loc_A0D3

		ld	a, #20 ; ' '


loc_A0D3:				; CODE XREF: sub_A08D+3C sub_A08D+42
		call	sub_A0F7

		ex	af, af' ;'
		ld	b, #30 ; '0'


loc_A0D9:				; CODE XREF: sub_A08D+54
		cp	#A
		jr	c, loc_A0E3

		inc	b
		inc	c
		sub	#A
		jr	loc_A0D9

; ---------------------------------------------------------------------------

loc_A0E3:				; CODE XREF: sub_A08D+4E
		ex	af, af' ;'
		ld	a, b
		cp	#30 ; '0'
		jr	nz, loc_A0F1

		ld	a, c
		or	a
		ld	a, #30 ; '0'
		jr	nz, loc_A0F1

		ld	a, #20 ; ' '


loc_A0F1:				; CODE XREF: sub_A08D+5A sub_A08D+60
		call	sub_A0F7

		ex	af, af' ;'
		add	a, #30 ; '0'

; End of function sub_A08D


; =============== S U B	R O U T	I N E =======================================


sub_A0F7:				; CODE XREF: sub_A08D:loc_A0D3
					; sub_A08D:loc_A0F1
		push	af
		call	PRINT_LETTER

		ld	a, (byte_D0E1)
		cp	3
		jr	nc, loc_A102


loc_A102:				; CODE XREF: sub_A0F7+9
		pop	af
		ret

; End of function sub_A0F7


; =============== S U B	R O U T	I N E =======================================


SCROLL_UP:				; CODE XREF: sub_9FB2+2D
		di
		ld	hl,  SCR_BUF_6400+#C0
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_A111

		ld	hl,  SCREEN+#C0


loc_A111:				; CODE XREF: SCROLL_UP+8
		ld	a, 5
		ex	af, af' ;'


loc_A114:				; CODE XREF: SCROLL_UP+34
		ld	a, #20 ; ' '
		add	a, l
		ld	e, a
		ld	a, h
		jr	nc, loc_A11D

		add	a, 8


loc_A11D:				; CODE XREF: SCROLL_UP+15
		ld	d, a		; DE is	1 char lower than HL
		push	de
		ld	c, 8


loc_A121:				; CODE XREF: SCROLL_UP+2C
		push	hl
		push	de
		ld	b, #20 ; ' '


loc_A125:				; CODE XREF: SCROLL_UP+25
		ld	a, (de)
		ld	(hl), a
		inc	hl
		inc	de
		djnz	loc_A125

		pop	de
		pop	hl
		inc	h
		inc	d
		dec	c
		jr	nz, loc_A121

		pop	hl
		ex	af, af' ;'
		dec	a
		jr	z, loc_A13A

		ex	af, af' ;'
		jr	loc_A114

; ---------------------------------------------------------------------------

loc_A13A:				; CODE XREF: SCROLL_UP+31
		ld	c, 8


loc_A13C:				; CODE XREF: SCROLL_UP+43
		push	hl
		ld	b, #20 ; ' '
		xor	a


loc_A140:				; CODE XREF: SCROLL_UP+3E
		ld	(hl), a
		inc	hl
		djnz	loc_A140

		pop	hl
		inc	h
		dec	c
		jr	nz, loc_A13C

		ld	a, 5
		ld	(byte_D0C0), a
		ei
		ret

; End of function SCROLL_UP


; =============== S U B	R O U T	I N E =======================================


sub_A150:				; CODE XREF: sub_8C20-676
					; sub_9018+4B
		call	sub_A164

		ld	a, (byte_D0B3) ;d3=swap board
		jr	c, loc_A15E

		and	8
		jr	nz, loc_A162


loc_A15C:				; CODE XREF: sub_A150+10
		or	a
		ret

; ---------------------------------------------------------------------------

loc_A15E:				; CODE XREF: sub_A150+6
		and	8
		jr	nz, loc_A15C


loc_A162:				; CODE XREF: sub_A150+A
		scf
		ret

; End of function sub_A150


; =============== S U B	R O U T	I N E =======================================


sub_A164:				; CODE XREF: sub_9018+12 sub_954C ...
		ld	a, (byte_D0BF)
		rra
		ld	a, (byte_D0B4)
		bit	5, a
		jr	c, loc_A173

		jr	nz, loc_A175


loc_A171:				; CODE XREF: sub_A164:loc_A173
		or	a
		ret

; ---------------------------------------------------------------------------

loc_A173:				; CODE XREF: sub_A164+9
		jr	nz, loc_A171


loc_A175:				; CODE XREF: sub_A164+B
		scf
		ret

; End of function sub_A164


; =============== S U B	R O U T	I N E =======================================


sub_A177:				; CODE XREF: sub_90E8+254
					; sub_9F0D+20

; FUNCTION CHUNK AT A1F1 SIZE 00000037 BYTES

		call	SHOW_LOGO

		ld	hl, #B00
		ld	(scr_XY), hl
		ld	hl, aPress	; " PRESS"
		call	PRINT_STR_scr0

		ld	hl, SCR_ATTRS
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_A193

		ld	de, #2400
		add	hl, de


loc_A193:				; CODE XREF: sub_A177+16
		ld	e, 1
		call	sub_A24B

		ld	hl,  SCR_ATTRS+#100
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_A1A5

		ld	de, #2400
		add	hl, de


loc_A1A5:				; CODE XREF: sub_A177+28
		ld	a, (byte_D0B3) ;d3=swap board
		ld	e, 0
		and	8
		jr	z, loc_A1B0

		ld	e, 7


loc_A1B0:				; CODE XREF: sub_A177+35
		call	sub_A24B

		ld	hl,  SCR_ATTRS+#200
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_A1C0

		ld	de, #2400
		add	hl, de


loc_A1C0:				; CODE XREF: sub_A177+43
		ld	a, (byte_D0B3) ;d3=swap board
		ld	e, 7
		and	8
		jr	z, loc_A1CB

		ld	e, 0


loc_A1CB:				; CODE XREF: sub_A177+50
		call	sub_A24B

		ld	hl, #800
		ld	b, 3
		call	sub_A1E0

		ld	hl, #1000
		ld	b, 3
		call	sub_A1E0

		jr	loc_A1F1

; End of function sub_A177


; =============== S U B	R O U T	I N E =======================================


sub_A1E0:				; CODE XREF: sub_A177+5C sub_A177+64 ...
		push	bc
		push	hl
		ld	(scr_XY), hl
		ld	hl, a_8spaces	; "       "
		call	PRINT_STR_scr0

		pop	hl
		inc	h
		pop	bc
		djnz	sub_A1E0

		ret

; End of function sub_A1E0

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A177

loc_A1F1:				; CODE XREF: sub_A177+67
		call	sub_A228

		ld	hl, #801
		ld	(scr_XY), hl
		call	sub_9F8B

		ld	hl, aCyrus	; "CYRUS"
		bit	1, b
		jr	nz, loc_A207

		ld	hl, a_PLAYER	; "PLAYE"


loc_A207:				; CODE XREF: sub_A177+8B
		ld	de, aCyrus	; "CYRUS"
		bit	0, b
		jr	nz, loc_A211

		ld	de, a_PLAYER	; "PLAYE"


loc_A211:				; CODE XREF: sub_A177+95
		ld	a, (byte_D0B3) ;d3=swap board
		and	8
		jr	nz, loc_A219

		ex	de, hl


loc_A219:				; CODE XREF: sub_A177+9F
		push	de
		call	PRINT_STR_scr0

		ld	hl, #1001
		ld	(scr_XY), hl
		pop	hl
		call	PRINT_STR_scr0

		ret

; END OF FUNCTION CHUNK	FOR sub_A177

; =============== S U B	R O U T	I N E =======================================


sub_A228:				; CODE XREF: INIT_PRINT_CLOCKS+2E
					; sub_A177:loc_A1F1
		ld	hl, #900
		ld	(scr_XY), hl
		ld	hl,  CLK_2+1
		ld	de,  CLK_1+1
		ld	a, (byte_D0B3) ;d3=swap board
		and	8
		jr	z, loc_A23C

		ex	de, hl


loc_A23C:				; CODE XREF: sub_A228+11
		push	de
		call	PRINT_STR_scr0

		ld	hl, #1100
		ld	(scr_XY), hl
		pop	hl
		call	PRINT_STR_scr0

		ret

; End of function sub_A228


; =============== S U B	R O U T	I N E =======================================


sub_A24B:				; CODE XREF: sub_A177+1E
					; sub_A177:loc_A1B0 ...
		ld	b, 3


loc_A24D:				; CODE XREF: sub_A24B:loc_A25F
		ld	c, 8


loc_A24F:				; CODE XREF: sub_A24B+B
		ld	a, (hl)
		and	#F8 ; 'ш'
		or	e
		ld	(hl), a
		inc	hl
		dec	c
		jr	nz, loc_A24F

		ld	a, #18
		add	a, l
		ld	l, a
		jr	nc, loc_A25F

		inc	h


loc_A25F:				; CODE XREF: sub_A24B+11
		djnz	loc_A24D

		ret

; End of function sub_A24B


; =============== S U B	R O U T	I N E =======================================


sub_A262:				; CODE XREF: sub_8C20:loc_80CE
					; sub_87CD
		ld	a, #20 ; ' '
		ld	b, 8
		ld	hl, unk_637C


loc_A269:				; CODE XREF: sub_A262+9
		inc	hl
		ld	(hl), a
		djnz	loc_A269

		set	7, (hl)
		ret

; End of function sub_A262


; =============== S U B	R O U T	I N E =======================================


PRT_DETECT:				; CODE XREF: START_POINT+8A
		xor	a
		ld	(byte_D0E1), a
		ld	hl, PRTD_no_serial
		push	hl
		ld	(bas_ERRSP), sp

		;rst	8		; somehow jumps	to pushed address (loc_A28E)
		;db	#31
                 call PRTD_no_serial

		ld	hl, #C
		ld	(word_5CC3), hl
		ld	a, #39 ; '9'
		ld	(baudrate_NUM),	a
		pop	af
		ld	a, 4		; serial printer bit
		 ret ;jr	loc_A28F

; ---------------------------------------------------------------------------

PRTD_no_serial:				; DATA XREF: PRT_DETECT+4
		xor	a

loc_A28F:				; CODE XREF: PRT_DETECT+1C
		ld	hl, CFG_BITS
		ld	(hl), a
		ld	b, 0

PRTD_detect_zxprt:			; CODE XREF: PRT_DETECT+2A
		ld a,0xff;in	a, (#FB)
		and	#40 ; '@'       ; D6=0 -- zx printer is present
		ret	nz
		djnz	PRTD_detect_zxprt

		set	3, (hl)		; zx printer bit
		ret

; End of function PRT_DETECT

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_A29F:				; CODE XREF: sub_8C20-863
					; sub_8C20+16FA ...
		call	sub_9571

		ld	a, #FF
		ld	(NEED_SCR2BUF),	a
		ld	a, (SEL_SCRorBUF)
		or	a
		call	z, sub_95C5

		ld	a, (CFG_BITS)
		and	#C
		jp	z, loc_82EB

		ld	de, #1000
		ld	hl, aZZxPrinterPSer ; " Z-ZX PRINTER    P-SERIAL"
		call	sub_9F42

		ld	a, (CFG_BITS)
		ld	c, a
		ld	hl, #1000
		bit	0, c
		call	sub_A3C3

		ld	l, #10
		bit	1, c
		call	sub_A3C3

		ld	hl, #1200
		bit	4, c
		call	sub_A3C3


loc_A2DA:				; CODE XREF: sub_8C20+16E9
					; sub_8C20+16F5 ...
		call	sub_907E

		jp	c, loc_82EB

		res	5, a
		ld	hl, CFG_BITS
		cp	#5A ; 'Z'
		jp	z, loc_A318

		cp	#50 ; 'P'
		jp	z, loc_A325

		cp	#4F ; 'O'
		jp	z, loc_A35A

		cp	#47 ; 'G'
		jp	z, loc_A33C

		cp	#42 ; 'B'
		jp	z, loc_A306

		cp	#43 ; 'C'
		jp	z, loc_A34D

		jp	loc_82EB

; ---------------------------------------------------------------------------

loc_A306:				; CODE XREF: sub_8C20+16DB
		ld	a, (hl)
		and	3
		jr	z, loc_A2DA

		set	5, (hl)
		call	sub_94C9

		ld	hl, CFG_BITS
		res	5, (hl)
		jp	loc_A2DA

; ---------------------------------------------------------------------------

loc_A318:				; CODE XREF: sub_8C20+16C7
		bit	3, (hl)
		jp	z, loc_A29F

		ld	a, (hl)
		and	#FD ; 'э'
		xor	1
		ld	(hl), a
		jr	loc_A330

; ---------------------------------------------------------------------------

loc_A325:				; CODE XREF: sub_8C20+16CC
		bit	2, (hl)
		jp	z, loc_A29F

		ld	a, (hl)
		and	#FE ; 'ю'
		xor	2
		ld	(hl), a


loc_A330:				; CODE XREF: sub_8C20+1703
		and	3
		jp	nz, loc_A29F

		ld	a, (hl)
		and	#CF ; 'ѕ'
		ld	(hl), a
		jp	loc_A29F

; ---------------------------------------------------------------------------

loc_A33C:				; CODE XREF: sub_8C20+16D6
		ld	a, (hl)
		and	3
		jr	z, loc_A2DA

		set	5, (hl)
		ld	hl, (word_D0F7)
		inc	hl
		ld	(word_D0F7), hl
		jp	loc_8A32

; ---------------------------------------------------------------------------

loc_A34D:				; CODE XREF: sub_8C20+16E0
		ld	a, (hl)
		and	3
		jp	z, loc_A29F

		ld	a, (hl)
		xor	#10
		ld	(hl), a
		jp	loc_A29F

; ---------------------------------------------------------------------------

loc_A35A:				; CODE XREF: sub_8C20+16D1
					; sub_8C20+1777 ...
		ld	hl, aSelectBaudRate ; "SELECT BAUD RATE:-"
		ld	de, #1000
		call	sub_9F42

		ld	a, (CFG_BITS)
		ld	hl,#140B
		and	#40 ; '@'
		call	sub_A3C3

		ld	hl, #1014
		ld	(scr_XY), hl
		ld	a, (baudrate_NUM)
		call	PRINT_LETTER

		call	sub_907E

		jp	c, loc_A29F

		cp	#31 ; '1'
		jp	c, loc_A29F

		cp	#3A ; ':'
		jr	c, loc_A399

		res	5, a
		cp	#43 ; 'C'
		jp	nz, loc_A29F

		ld	hl, CFG_BITS
		ld	a, (hl)
		xor	#40 ; '@'
		ld	(hl), a
		jr	loc_A35A

; ---------------------------------------------------------------------------

loc_A399:				; CODE XREF: sub_8C20+1767
		ld	(baudrate_NUM),	a
		sub	#31 ; '1'
		add	a, a
		ld	hl, baud_rates
		add	a, l
		ld	l, a
		jr	nc, loc_A3A7

		inc	h


loc_A3A7:				; CODE XREF: sub_8C20+1784
		ld	e, (hl)
		inc	hl
		ld	d, (hl)
		ld	(word_5CC3), de
		jp	loc_A35A

; END OF FUNCTION CHUNK	FOR sub_8C20
; ---------------------------------------------------------------------------
baud_rates:	dw #A82		; DATA XREF: sub_8C20+177F
		dw #4C5
		dw #1BE
		dw #DE
		dw #6E
		dw #36
		dw #1A
		dw #C
		dw 5

; =============== S U B	R O U T	I N E =======================================


sub_A3C3:				; CODE XREF: sub_8C20+16A8
					; sub_8C20+16AF ...
		ld	(scr_XY), hl
		ld	a, #20 ; ' '
		jr	z, loc_A3CC

		ld	a, #2A ; '*'


loc_A3CC:				; CODE XREF: sub_A3C3+5
		call	PRINT_LETTER

		ret

; End of function sub_A3C3


; =============== S U B	R O U T	I N E =======================================


sub_A3D0:				; CODE XREF: sub_9FB2+3F
		call	sub_A4C2

		ret	nc
		ld	c, 6
		call	sub_A164

		jr	c, loc_A3E0

		ld	c, #10
		jp	loc_A437

; ---------------------------------------------------------------------------

loc_A3E0:				; CODE XREF: sub_A3D0+9
		ld	a, (byte_D049) ;move #
		ld	b, a
		ld	a, (byte_D0B4)
		bit	5, a
		jr	z, loc_A3F2

		ld	a, (byte_D0BF)
		rra
		jr	nc, loc_A3F2

		dec	b


loc_A3F2:				; CODE XREF: sub_A3D0+19 sub_A3D0+1F
		push	bc
		ld	a, b
		ld	bc, #3000


loc_A3F7:				; CODE XREF: sub_A3D0+2F
		cp	#64 ; 'd'
		jr	c, loc_A401

		inc	b
		inc	c
		sub	#64 ; 'd'
		jr	loc_A3F7

; ---------------------------------------------------------------------------

loc_A401:				; CODE XREF: sub_A3D0+29
		ex	af, af' ;'
		ld	a, b
		cp	#30 ; '0'
		jr	nz, loc_A40F

		ld	a, c
		or	a
		ld	a, #30 ; '0'
		jr	nz, loc_A40F

		ld	a, #20 ; ' '


loc_A40F:				; CODE XREF: sub_A3D0+35 sub_A3D0+3B
		call	loc_A476

		ex	af, af' ;'
		ld	b, #30 ; '0'


loc_A415:				; CODE XREF: sub_A3D0+4D
		cp	#A
		jr	c, loc_A41F

		inc	b
		inc	c
		sub	#A
		jr	loc_A415

; ---------------------------------------------------------------------------

loc_A41F:				; CODE XREF: sub_A3D0+47
		ex	af, af' ;'
		ld	a, b
		cp	#30 ; '0'
		jr	nz, loc_A42D

		ld	a, c
		or	a
		ld	a, #30 ; '0'
		jr	nz, loc_A42D

		ld	a, #20 ; ' '


loc_A42D:				; CODE XREF: sub_A3D0+53 sub_A3D0+59
		call	loc_A476

		ex	af, af' ;'
		add	a, #30 ; '0'
		call	loc_A476

		pop	bc


loc_A437:				; CODE XREF: sub_A3D0+D
		call	sub_A454

		jr	sub_A43C

; End of function sub_A3D0


; =============== S U B	R O U T	I N E =======================================


sub_A43C:				; CODE XREF: sub_8C20-B48
					; sub_8C20-B3A ...
		ld	a, #D
		call	loc_A476

		xor	a
		ld	(byte_D0E1), a
		ld	a, (CFG_BITS)
		bit	6, a
		ret	z
		bit	0, a
		ld	a, #A
		ret	nz
		call	loc_A476

		ret

; End of function sub_A43C


; =============== S U B	R O U T	I N E =======================================


sub_A454:				; CODE XREF: sub_A3D0:loc_A437
		call	sub_A466

		ld	hl, buf_10bytes

; End of function sub_A454


; =============== S U B	R O U T	I N E =======================================


sub_A45A:				; CODE XREF: sub_8C20-72 sub_A45A+9
		ld	a, (hl)
		and	#7F ; ''
		call	loc_A476

		bit	7, (hl)
		inc	hl
		jr	z, sub_A45A

		ret

; End of function sub_A45A


; =============== S U B	R O U T	I N E =======================================


sub_A466:				; CODE XREF: sub_A454
		call	sub_A4C2

		ret	nc


loc_A46A:				; CODE XREF: sub_A466+E
		ld	a, (byte_D0E1)
		cp	c
		ret	z
		ld	a, #20 ; ' '
		call	loc_A476

		jr	loc_A46A

; End of function sub_A466

; ---------------------------------------------------------------------------

loc_A476:				; CODE XREF: sub_8C20-B40
					; sub_94C9+21	...
		call	sub_A4C2

		ret	nc
		push	bc
		push	de
		push	hl
		ld	hl, byte_D0E1
		inc	(hl)
		exx
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		ex	af, af' ;'
		push	af
		ex	af, af' ;'
		ld	hl, loc_A4A7
		push	hl
		ld	(bas_ERRSP), sp
		ld	iy, #5C3A
		ld	hl, CFG_BITS
		bit	0, (hl)
		;jr	nz, loc_A4A3

		;rst	8 ;to printer?
		;db	#1E,#18,#01
                ds 4

loc_A4A3:				; CODE XREF: RAM:A49D
		call rst10 ;rst	#10 ;to screen

		pop	hl
		jr	loc_A4B1

; ---------------------------------------------------------------------------

loc_A4A7:				; DATA XREF: RAM:A48C
		ld	a, (CFG_BITS)
		res	4, a
		res	5, a
		ld	(CFG_BITS), a


loc_A4B1:				; CODE XREF: RAM:A4A5
		call	SET_BRD_COLOR

		pop	af
		ex	af, af' ;'
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		exx
		pop	hl
		pop	de
		pop	bc
		ret


; =============== S U B	R O U T	I N E =======================================


sub_A4C2:				; CODE XREF: sub_A3D0	sub_A466 ...
		push	af
		push	de
		push	hl
		ld	a, (CFG_BITS)
		and	#30 ; '0'
		jr	z, loc_A4EA

		ld	a, (byte_D0B4)
		bit	5, a
		jr	nz, loc_A4EF

		ld	hl, (word_D09F)
		ld	a, h
		or	l
		jr	z, loc_A4EF

		ld	de, (word_D0F7)
		or	a
		sbc	hl, de
		jr	z, loc_A4EF

		ld	a, (CFG_BITS)
		bit	5, a
		jr	nz, loc_A4EF


loc_A4EA:				; CODE XREF: sub_A4C2+8
		pop	hl
		pop	de
		pop	af
		or	a
		ret

; ---------------------------------------------------------------------------

loc_A4EF:				; CODE XREF: sub_A4C2+F sub_A4C2+16	...
		pop	hl
		pop	de
		pop	af
		scf
		ret

; End of function sub_A4C2

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_A4F4:				; CODE XREF: sub_8C20-868
		call	sub_9571

		ld	a, #FF
		ld	(NEED_SCR2BUF),	a
		ld	a, (SEL_SCRorBUF)
		or	a
		call	z, sub_95C5

		ld	de, #1000
		ld	hl, aSSaveRecordLLo ; "S- Save record   L- Load record"
		call	sub_9F42

		ld	hl, loc_A671
		push	hl
		ld	(bas_ERRSP), sp
		call	sub_907E

		jr	c, loc_A525

		and	#5F ; '_'
		cp	#4C ; 'L'
		jp	z, loc_A5D9

		cp	#53 ; 'S'
		jp	z, loc_A596


loc_A525:				; CODE XREF: sub_8C20+18F7
		pop	hl
		jp	loc_82EB

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


SAVE_RECORD:				; CODE XREF: sub_8C20+197F
					; sub_8C20:fool_name
		ld	a, #FF
		ld	(SEL_SCRorBUF),	a
		ld	hl, #1305
		ld	(scr_XY), hl
		ld	hl,  TAPE_header+#10
		ld	b, #10


loc_A539:				; CODE XREF: SAVE_RECORD+13
		ld	(hl), #20 ; ' '
		dec	hl
		djnz	loc_A539

		ld	(hl), 9


loc_A540:				; CODE XREF: SAVE_RECORD+28
					; SAVE_RECORD+42 ...
		call	sub_907E

		ret	c
		cp	#D
		jr	z, loc_A56E

		cp	#C
		jr	nz, loc_A57B

		ld	a, (scr_XY)
		sub	5
		jr	z, loc_A540

		ld	hl,  TAPE_header+1
		add	a, l
		ld	l, a
		jr	nc, loc_A55B

		inc	h


loc_A55B:				; CODE XREF: SAVE_RECORD+2F
		dec	hl
		ld	(hl), #20 ; ' '
		ld	hl, scr_XY
		dec	(hl)
		ld	a, #20 ; ' '
		call	PRINT_LETTER

		ld	hl, scr_XY
		dec	(hl)
		jp	loc_A540

; ---------------------------------------------------------------------------

loc_A56E:				; CODE XREF: SAVE_RECORD+1D
		ld	a, (scr_XY)
		cp	5
		ret	nz
		ld	hl,  TAPE_header+1
		ld	(hl), #FF
		or	a
		ret

; ---------------------------------------------------------------------------

loc_A57B:				; CODE XREF: SAVE_RECORD+21
		ld	e, a
		ld	a, (scr_XY)
		cp	#F
		jp	nc, loc_A540

		ld	hl,  TAPE_header+1
		sub	5
		add	a, l
		ld	l, a
		jr	nc, loc_A58E

		inc	h


loc_A58E:				; CODE XREF: SAVE_RECORD+62
		ld	(hl), e
		ld	a, e
		call	PRINT_LETTER

		jp	loc_A540

; End of function SAVE_RECORD

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_8C20

loc_A596:				; CODE XREF: sub_8C20+1902
		ld	de, #1000
		ld	hl, aSaveTheGameRec ; "      SAVE THE GAME RECORD"
		call	sub_9F42

		call	SAVE_RECORD

		jr	c, loc_A5D2

		ld	hl, #1500
		ld	(scr_XY), hl
		ld	hl, aStartTapeAndPr ; "  START TAPE AND PRESS ANY KE"
		call	PRINT_STR_FF

		call	sub_907E

		jr	c, loc_A5D2

		ld	ix, TAPE_header
		ld	de, #11
		xor	a
		call	ROM_START+#4C2

		ld	a, #32 ; '2'


loc_A5C2:				; CODE XREF: sub_8C20+19A4
		halt
		dec	a
		jr	nz, loc_A5C2

		ld	ix, BRD_88_0
		ld	de, #3FF
		ld	a, #FF
		call	ROM_START+#4C2


loc_A5D2:				; CODE XREF: sub_8C20+1982
					; sub_8C20+1993 ...
		pop	hl
		call	SET_BRD_COLOR

		jp	loc_82EB

; ---------------------------------------------------------------------------

loc_A5D9:				; CODE XREF: sub_8C20+18FD
		ld	de, #1000
		ld	hl, aLoadAGameRecor ; "      LOAD A GAME RECORD"
		call	sub_9F42


fool_name:
		call	SAVE_RECORD

		jr	c, loc_A5D2

		ld	hl, #1500
		ld	(scr_XY), hl
		ld	hl, #9D53
		call	PRINT_STR_FF

		call	sub_907E

		jr	c, loc_A5D2


loc_A5F8:				; CODE XREF: sub_8C20+19E4
					; sub_8C20+1A2C
		ld	ix, #63B5
		ld	de, #11
		xor	a
		scf
		call	ROM_START+#556

		jp	nc, loc_A5F8

		ld	hl, #1300
		ld	(scr_XY), hl
		ld	hl, a_32spaces	; "                        "
		call	PRINT_STR_FF

		ld	hl, #1300
		ld	(scr_XY), hl
		ld	a, (byte_63B5)
		ld	hl,  aGameRecord
		cp	9
		jr	z, loc_A626

		ld	hl, aNotAGameRecord ; "NOT A GAME RECORD :"


loc_A626:				; CODE XREF: sub_8C20+1A01
		call	PRINT_STR_FF

		ld	a, (byte_63B6)
		inc	a
		jr	z, loc_A640

		ld	hl, unk_63BF
		set	7, (hl)
		ld	hl, byte_63B6
		call	PRINT_STR_FF

		ld	a, (TAPE_header+1)
		inc	a
		jr	z, loc_A652


loc_A640:				; CODE XREF: sub_8C20+1A0D
		ld	de,  TAPE_header+1
		ld	hl, byte_63B6
		ld	b, #A


loc_A648:				; CODE XREF: sub_8C20+1A30
		ld	a, (de)
		res	7, (hl)
		cp	(hl)
		jr	nz, loc_A5F8

		inc	hl
		inc	de
		djnz	loc_A648


loc_A652:				; CODE XREF: sub_8C20+1A1E
		ld	ix, RAM_END_D800
		ld	de, #3FF
		ld	a, #FF
		scf
		call	ROM_START+#556

		jp	nc, loc_A670

		ld	hl, RAM_END_D800
		ld	de, BRD_88_0
		ld	bc, #3FF
		ldir
		call	INIT_PRINT_CLOCKS


loc_A670:				; CODE XREF: sub_8C20+1A3F
		pop	hl


loc_A671:				; DATA XREF: sub_8C20+18EC
		ld	hl, (word_D0F7)
		inc	hl
		ld	(word_D0F7), hl
		call	SET_BRD_COLOR

		call	sub_9EE6

		call	PRINT_CLOCKS_SWAP

		jp	loc_8A32

; END OF FUNCTION CHUNK	FOR sub_8C20

; =============== S U B	R O U T	I N E =======================================


sub_A684:				; CODE XREF: sub_8C20-A43
					; sub_8DE9+55	...
		ld	a, (byte_D0B4)
		bit	5, a
		ret	nz
		ld	a, (byte_D0DF)
		rra
		ret	c
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		exx
		push	bc
		push	de
		push	hl
		ld	a, #FF
		ld	(NEED_SCR2BUF),	a
		ld	hl, #D08
		ld	(scr_XY), hl
		ld	b, 7
		ld	hl, byte_D258


loc_A6AA:				; CODE XREF: sub_A684+48
		ld	a, (hl)
		cp	#FF
		jr	z, loc_A6D0

		push	bc
		push	hl
		ld	hl,  a_8spaces+5
		call	PRINT_STR_FF

		pop	hl
		push	hl
		ld	a, (hl)
		call	sub_A021

		ld	a, #2D ; '-'
		call	PRINT_LETTER

		pop	hl
		inc	hl
		push	hl
		ld	a, (hl)
		call	sub_A021

		pop	hl
		inc	hl
		pop	bc
		djnz	loc_A6AA

		jr	loc_A6D8

; ---------------------------------------------------------------------------

loc_A6D0:				; CODE XREF: sub_A684+29 sub_A684+52
		ld	hl, a_8spaces	; "       "
		call	PRINT_STR_FF

		djnz	loc_A6D0


loc_A6D8:				; CODE XREF: sub_A684+4A sub_A6F7+3E
		pop	hl
		pop	de
		pop	bc
		exx
		pop	iy
		pop	ix
		pop	hl
		pop	de
		pop	bc
		ret

; End of function sub_A684


; =============== S U B	R O U T	I N E =======================================


sub_A6E4:				; CODE XREF: sub_8C20-92D
					; sub_8C20-829 ...
		ld	hl, #D08
		ld	(scr_XY), hl
		ld	hl,  a_32spaces+8
		call	PRINT_STR_FF

		ld	hl, a_32spaces	; "                        "
		call	PRINT_STR_FF

		ret

; End of function sub_A6E4


; =============== S U B	R O U T	I N E =======================================


sub_A6F7:				; CODE XREF: sub_AFC5+C7
		ld	a, (byte_D0B4)
		bit	5, a
		ret	nz
		push	bc
		push	de
		push	hl
		push	ix
		push	iy
		exx
		push	bc
		push	de
		push	hl
		exx
		ld	de, #F00
		ld	(scr_XY), de
		ld	a, #FF
		ld	(NEED_SCR2BUF),	a
		ld	a, (hl)
		cp	#FE ; 'ю'
		jr	c, loc_A725

		ld	hl,  a_8spaces+5
		call	PRINT_STR_FF

		ld	hl,  aNoMateIn+3
		jr	loc_A728

; ---------------------------------------------------------------------------

loc_A725:				; CODE XREF: sub_A6F7+21
		ld	hl, aNoMateIn	; "NO MATE IN"


loc_A728:				; CODE XREF: sub_A6F7+2C
		call	PRINT_STR_FF

		ld	a, (byte_D098)
		srl	a
		add	a, #31 ; '1'
		call	PRINT_LETTER

		jp	loc_A6D8

; End of function sub_A6F7

; ---------------------------------------------------------------------------


	;cyrus logo, 128 bytes.
	;no alignment

CYRUS_LOGO_spr:	db  #00,#00,#00,#00,#00,#00,#00,#00
		db  #00,#00,#00,#00,#00,#00,#00,#00
		db  #3E,#7D,#F7,#E3,#DE,#3C,#1F,#FC
		db  #7F,#7D,#F7,#F3,#DE,#7E,#1F,#FC
		db  #F7,#B8,#E3,#39,#8C,#E7,#06,#30
		db  #E3,#9D,#C3,#39,#8C,#E7,#06,#30
		db  #C0,#0D,#83,#39,#8C,#E0,#06,#30
		db  #C0,#0F,#83,#F1,#8C,#FE,#06,#30
		db  #C0,#07,#03,#E1,#8C,#7F,#06,#30
		db  #C0,#07,#03,#71,#8C,#07,#06,#30
		db  #E3,#87,#03,#39,#8C,#E7,#06,#30
		db  #F7,#87,#03,#19,#DC,#E7,#06,#30
		db  #7F,#0F,#87,#BC,#F8,#7E,#1F,#FC
		db  #3E,#0F,#87,#BC,#70,#3C,#1F,#FC
		db  #00,#00,#00,#00,#00,#00,#00,#00
		db  #00,#00,#00,#00,#00,#00,#00,#00



; =============== S U B	R O U T	I N E =======================================

; show CYRUS II	logo in	upper left part	of screen or scrbuf

SHOW_LOGO:				; CODE XREF: sub_A177
		push	hl
		push	de
		push	bc
		ld	hl, SCREEN
		ld	a, (SEL_SCRorBUF)
		or	a
		jr	z, loc_A7C8

		ld	de, #2400
		add	hl, de		; step to SCR_BUF_6400


loc_A7C8:				; CODE XREF: SHOW_LOGO+A
		push	hl
		ld	de, CYRUS_LOGO_spr
		ld	b, 8


loc_A7CE:				; CODE XREF: SHOW_LOGO+22
		ld	c, 8
		push	hl


loc_A7D1:				; CODE XREF: SHOW_LOGO+1E
		ld	a, (de)
		ld	(hl), a
		inc	hl
		inc	de
		dec	c
		jr	nz, loc_A7D1

		pop	hl
		inc	h
		djnz	loc_A7CE

		pop	hl
		ld	a, #20 ; ' '
		add	a, l
		ld	l, a
		ld	b, 8


loc_A7E3:				; CODE XREF: SHOW_LOGO+37
		ld	c, 8
		push	hl


loc_A7E6:				; CODE XREF: SHOW_LOGO+33
		ld	a, (de)
		ld	(hl), a
		inc	hl
		inc	de
		dec	c
		jr	nz, loc_A7E6

		pop	hl
		inc	h
		djnz	loc_A7E3

		pop	bc
		pop	de
		pop	hl
		ret

; End of function SHOW_LOGO

; ---------------------------------------------------------------------------

       if !FIX
	;unneeded space???
		ds	267
       endif









	;following jump table is unneeded???

sub_A900:
		jp	sub_AFC5
sub_A903:
		jp	loc_A961
sub_A906:
		jp	sub_AD40
sub_A909:
		jp	sub_AF81
sub_A90C:
		jp	sub_AC59
sub_A90F:
		jp	sub_AB4C
loc_A912:
		jp	loc_AF68
sub_A915:
		jp	sub_B8B2





; ---------------------------------------------------------------------------
       if FIX
                align 8
       endif

		;must be inside 256b page
byte_A918:	db #0E,#12,#1F,#21,#F2,#EE,#E1,#DF ;8 bytes

byte_A920:	db #0F			; DATA XREF: sub_A94F+42 ;sub_AAF8:loc_AAFA ... ;8 bytes
		db #11
		db #EF
		db #F1
byte_A924:	db #01			; DATA XREF: sub_AAC9:loc_AACB ;4 bytes
		db #FF
		db #10
                db #F0			

byte_A928: ; DATA XREF: sub_AFC5:loc_B00D
;any place?
		db #80
		db #00
		db #34
		db #02
		db #28
		db #06
		db #19
		db #0E
		db #00
		db #1E

; =============== S U B	R O U T	I N E =======================================


sub_A932:				; CODE XREF: sub_AFC5+30 sub_AFC5+36
		ld	c, 0
		ld	b, #F


loc_A936:				; CODE XREF: sub_A932+1A
		bit	7, (hl)
		jr	nz, loc_A948

		inc	l
		ld	a, (hl)
		and	#F
		cp	1
		jr	nz, loc_A945

		ld	(byte_D04C), a


loc_A945:				; CODE XREF: sub_A932+E
		add	a, c
		ld	c, a
		dec	l


loc_A948:				; CODE XREF: sub_A932+6
		ld	a, 8
		add	a, l
		ld	l, a
		djnz	loc_A936

		ret

; End of function sub_A932


; =============== S U B	R O U T	I N E =======================================


sub_A94F:				; CODE XREF: sub_AFC5+4 sub_B47F-77
		call	sub_8F4D

		ld	a, (ix+2)
		and	#C9 ; '…'
		jr	z, loc_A961

		ld	hl,  word_D00D+1
		jp	p, loc_A960

		inc	(hl)


loc_A960:				; CODE XREF: sub_A94F+D
		inc	(hl)


loc_A961:				; CODE XREF: sub_A903	sub_A94F+8
		ld	hl, byte_D097
		ld	a, (hl)
		add	a, a
		add	a, l
		ld	l, a
		ld	e, (hl)
		inc	l
		ld	d, (hl)
		inc	l
		inc	de
		push	de
		inc	de
		inc	de
		push	hl
		ld	h, BRD_88_0/256
		ld	iy, word_D100
		ld	a, (byte_D02D)
		exx
		rrca
		ld	c, a
		exx
		jr	nc, loc_A984

		ld	iy, word_D180


loc_A984:				; CODE XREF: sub_A94F+2F
		ld	b, (iy+0)
		bit	4, (iy+1)
		call	z, sub_AB0A

		ld	c, #88 ; 'И'
		exx
		ld	de, byte_A920
		call	sub_AAA7

		ld	a, (iy+8)
		or	a
		call	p, sub_AB00

		ld	a, (iy+#10)
		or	a
		call	p, sub_AAC9

		ld	a, (iy+#18)
		or	a
		call	p, sub_AAC9

		ld	a, (iy+#20)
		or	a
		call	p, sub_AAF8

		ld	a, (iy+#28)
		or	a
		call	p, sub_AAF8

		ld	a, (iy+#30)
		ld	c, #88 ; 'И'
		or	a
		call	p, sub_AAA2

		ld	a, (iy+#38)
		or	a
		call	p, sub_AAA2

		ld	c, #11
		exx
		ld	hl, unk_D140
		bit	7, c
		jr	z, loc_A9DA

		ld	l, #C0	; 'ј'   ; word_D1C0&255
		exx
		ld	c, #F1	; 'с'
		exx


loc_A9DA:				; CODE XREF: sub_A94F+83 sub_A94F+F2
		ld	a, (hl)
		rla
		jr	c, loc_AA3B

		inc	l
		ld	a, (hl)
		dec	l
		and	#E
		ld	a, (hl)
		exx
		ld	b, a
		jr	nz, loc_AA54

		add	a, c
		ld	l, a
		xor	a
		or	(hl)
		jp	z, loc_A9F6

		exx
		xor	c
		exx
		call	m, sub_AB41

		xor	a


loc_A9F6:				; CODE XREF: sub_A94F+9D
		dec	l
		dec	l
		or	(hl)
		jp	z, loc_AA03

		exx
		xor	c
		exx
		call	m, sub_AB41

		xor	a


loc_AA03:				; CODE XREF: sub_A94F+AA
		inc	l
		or	(hl)
		jr	nz, loc_AA33

		ex	de, hl
		ld	(hl), b
		inc	hl
		ld	(hl), e
		inc	hl
		ld	(hl), a
		inc	hl
		ex	de, hl
		ld	a, b
		add	a, #20 ; ' '
		bit	6, a
		jr	nz, loc_AA33

		ld	a, c
		dec	a
		add	a, l
		jp	m, loc_AA3A

		ld	l, a
		xor	a
		or	(hl)
		jr	nz, loc_AA3A

		call	sub_AB43

		dec	l
		or	(hl)
		call	nz, sub_AA8B

		inc	l
		inc	l
		ld	a, (hl)
		or	a
		call	nz, sub_AA8B

		jp	loc_AA3A

; ---------------------------------------------------------------------------

loc_AA33:				; CODE XREF: sub_A94F+B6 sub_A94F+C5
		bit	5, (ix+2)
		call	nz, sub_AA71


loc_AA3A:				; CODE XREF: sub_A94F+CA sub_A94F+D0 ...
		exx


loc_AA3B:				; CODE XREF: sub_A94F+8D
		ld	a, 8
		add	a, l
		ld	l, a
		bit	6, a
		jp	nz, loc_A9DA

		exx
		ld	a, #FF
		ld	(de), a
		pop	hl
		ld	(hl), e
		inc	l
		ld	(hl), d
		pop	hl
		ld	(hl), a
		inc	hl
		ld	a, (ix+2)
		ld	(hl), a
		ret

; ---------------------------------------------------------------------------

loc_AA54:				; CODE XREF: sub_A94F+97
		push	bc
		ld	c, #88 ; 'И'
		exx
		inc	l
		ld	a, (hl)
		dec	l
		ld	de, byte_AA6D
		push	de
		or	a
		jp	m, loc_AAFA

		rra
		rra
		jr	c, loc_AAA4

		rra
		jr	c, loc_AACB

		jp	loc_AB02

; End of function sub_A94F

; ---------------------------------------------------------------------------
byte_AA6D:	db  #C1,#D9,#18,#CA ; DATA	XREF: sub_A94F+10C

; =============== S U B	R O U T	I N E =======================================


sub_AA71:				; CODE XREF: sub_A94F+E8
		bit	3, (ix+2)
		ret	nz
		ld	a, (ix+1)
		and	#7F ; ''
		inc	a
		cp	b
		jr	z, loc_AA85

		dec	a
		dec	a
		cp	b
		ret	nz
		inc	l
		inc	l


loc_AA85:				; CODE XREF: sub_AA71+C
		dec	l
		ld	a, #28 ; '('
		jp	sub_AB43

; End of function sub_AA71


; =============== S U B	R O U T	I N E =======================================


sub_AA8B:				; CODE XREF: sub_A94F+D7 sub_A94F+DE
		exx
		xor	c
		exx
		ret	p
		ld	a, (hl)
		exx
		ld	b, l
		sub	3
		ld	l, a
		ld	a, (hl)
		ld	l, b
		exx
		and	#F
		dec	a
		ret	nz
		ld	a, #20 ; ' '
		dec	de
		ld	(de), a
		inc	de
		ret

; End of function sub_AA8B


; =============== S U B	R O U T	I N E =======================================


sub_AAA2:				; CODE XREF: sub_A94F+71 sub_A94F+78
		ld	b, a
		exx


loc_AAA4:				; CODE XREF: sub_A94F+116
		ld	de, byte_A918

; End of function sub_AAA2


; =============== S U B	R O U T	I N E =======================================


sub_AAA7:				; CODE XREF: sub_A94F+45
		ld	b, 8


loc_AAA9:				; CODE XREF: sub_AAA7:loc_AAC5
		ld	a, (de)
		inc	e
		exx
		add	a, b
		ld	l, a
		and	c
		jr	nz, loc_AAC4

		or	(hl)
		jr	z, loc_AABC

		exx
		xor	c
		jp	p, loc_AAC5

		exx
		ld	a, 8


loc_AABC:				; CODE XREF: sub_AAA7+B
		ex	de, hl
		ld	(hl), b
		inc	hl
		ld	(hl), e
		inc	hl
		ld	(hl), a
		inc	hl
		ex	de, hl


loc_AAC4:				; CODE XREF: sub_AAA7+8
		exx


loc_AAC5:				; CODE XREF: sub_AAA7+F
		djnz	loc_AAA9

		exx
		ret

; End of function sub_AAA7


; =============== S U B	R O U T	I N E =======================================


sub_AAC9:				; CODE XREF: sub_A94F+53 sub_A94F+5A
		ld	b, a
		exx


loc_AACB:				; CODE XREF: sub_A94F+119
		ld	de, byte_A924


loc_AACE:				; CODE XREF: sub_AAF8+5
		ld	b, 4


loc_AAD0:				; CODE XREF: sub_AAC9:loc_AAF4
					; sub_AB00+7
		ld	a, (de)
		inc	e
		exx
		ld	c, a
		ld	l, b


loc_AAD5:				; CODE XREF: sub_AAC9+1E
		ld	a, l
		add	a, c
		ld	l, a
		and	#88 ; 'И'
		jr	nz, loc_AAF3

		or	(hl)
		jr	nz, loc_AAEA

		ex	de, hl
		ld	(hl), b
		inc	hl
		ld	(hl), e
		inc	hl
		ld	(hl), a
		inc	hl
		ex	de, hl
		jp	loc_AAD5

; ---------------------------------------------------------------------------

loc_AAEA:				; CODE XREF: sub_AAC9+14
		exx
		xor	c
		jp	p, loc_AAF4

		exx
		call	sub_AB41


loc_AAF3:				; CODE XREF: sub_AAC9+11
		exx


loc_AAF4:				; CODE XREF: sub_AAC9+23
		djnz	loc_AAD0

		exx
		ret

; End of function sub_AAC9


; =============== S U B	R O U T	I N E =======================================


sub_AAF8:				; CODE XREF: sub_A94F+61 sub_A94F+68
		ld	b, a
		exx


loc_AAFA:				; CODE XREF: sub_A94F+111
		ld	de, byte_A920
		jp	loc_AACE

; End of function sub_AAF8


; =============== S U B	R O U T	I N E =======================================


sub_AB00:				; CODE XREF: sub_A94F+4C
		ld	b, a
		exx


loc_AB02:				; CODE XREF: sub_A94F+11B
		ld	de, byte_A920
		ld	b, 8
		jp	loc_AAD0

; End of function sub_AB00


; =============== S U B	R O U T	I N E =======================================


sub_AB0A:				; CODE XREF: sub_A94F+3C
		bit	7, (ix+2)
		ret	nz
		bit	4, (iy+#19)
		jr	nz, loc_AB26

		bit	7, (iy+#18)
		jr	nz, loc_AB26

		xor	a
		ld	l, b
		inc	l
		or	(hl)
		jr	nz, loc_AB26

		inc	l
		or	(hl)
		call	z, sub_AB3C


loc_AB26:				; CODE XREF: sub_AB0A+9 sub_AB0A+F ...
		bit	4, (iy+#11)
		ret	nz
		bit	7, (iy+#10)
		ret	nz
		ld	l, b
		xor	a
		dec	l
		or	(hl)
		ret	nz
		dec	l
		or	(hl)
		ret	nz
		dec	l
		or	(hl)
		ret	nz
		inc	l

; End of function sub_AB0A


; =============== S U B	R O U T	I N E =======================================


sub_AB3C:				; CODE XREF: sub_AB0A+19
		ld	a, #10
		jp	sub_AB43

; End of function sub_AB3C


; =============== S U B	R O U T	I N E =======================================


sub_AB41:				; CODE XREF: sub_A94F+A3 sub_A94F+B0 ...
		ld	a, 8

; End of function sub_AB41


; =============== S U B	R O U T	I N E =======================================


sub_AB43:				; CODE XREF: sub_A94F+D2 sub_AA71+17 ...
		ex	de, hl
		ld	(hl), b
		inc	hl
		ld	(hl), e
		inc	hl
		ld	(hl), a
		inc	hl
		ex	de, hl
		ret

; End of function sub_AB43


; =============== S U B	R O U T	I N E =======================================


sub_AB4C:				; CODE XREF: sub_A90F	sub_AFC5+66
		ld	de, XOR_A
; End of function sub_AB4C

		ld	(JP_ADDR), de


; =============== S U B	R O U T	I N E =======================================


sub_AB53:				; CODE XREF: sub_B47F-4C
		ld	a, (hl)
		ld	(byte_D01D), a
		inc	hl
		push	hl
		pop	ix
		ld	(word_D04A), hl
		ld	(word_D069), hl
		xor	a
		ld	hl, unk_D0E6
		ld	b, #A


loc_AB67:				; CODE XREF: sub_AB53+16
		ld	(hl), a
		inc	hl
		djnz	loc_AB67

		ld	(byte_D04E), a
		jp	loc_ABC6

; ---------------------------------------------------------------------------

loc_AB71:				; CODE XREF: sub_AB53+77
		inc	a
		jr	z, loc_AB81

		ld	a, (ix+1)
		inc	a
		jr	z, loc_ABC1

		ld	a, 1
		ld	(byte_D04E), a
		jr	loc_ABC1

; ---------------------------------------------------------------------------

loc_AB81:				; CODE XREF: sub_AB53+1F
		xor	a
		ld	(word_D04A+1), a
		ld	a, (byte_D0EF)
		ld	hl, (word_D069)
		or	a
		jr	nz, loc_ABA6

		ld	a, (byte_D04E)
		or	a
		jr	z, loc_ABA6

		cp	1
		jr	z, loc_ABA6

		ld	de, (word_D086)
		ld	b, 3


loc_AB9E:				; CODE XREF: sub_AB53+4F
		ld	a, (de)
		ld	(hl), a
		inc	de
		inc	hl
		djnz	loc_AB9E

		ld	a, 6


loc_ABA6:				; CODE XREF: sub_AB53+39 sub_AB53+3F ...
		ld	(hl), #FF
		or	a
		ret

; ---------------------------------------------------------------------------

loc_ABAA:				; CODE XREF: sub_AB53+89
		ld	a, 0
		ld	(word_D04A+1), a
		ret

; ---------------------------------------------------------------------------

loc_ABB0:				; CODE XREF: sub_AB53+8B
		ld	a, (byte_D04E)
		cp	c
		jr	nc, loc_ABC1

		dec	a
		jr	z, loc_ABC1

		ld	a, c
		ld	(byte_D04E), a
		ld	(word_D086), ix


loc_ABC1:				; CODE XREF: sub_AB53+25 sub_AB53+2C ...
		ld	de, 3
		add	ix, de


loc_ABC6:				; CODE XREF: sub_AB53+1B
		ld	a, (ix+0)
		rlca
		jr	c, loc_AB71

		call	sub_AD40

		call	sub_BC00

		call	sub_AF81

		ld	a, c
		or	a
		jr	z, loc_ABC1

		call	sub_B79D

		jr	c, loc_ABAA

		jr	nz, loc_ABB0

		ld	a, (ix+2)
		and	#88 ; 'И'
		ld	a, c
		jr	z, loc_ABEF

		add	a, 4
		jr	nc, loc_ABEE

		ld	a, #FF


loc_ABEE:				; CODE XREF: sub_AB53+97
		ld	c, a


loc_ABEF:				; CODE XREF: sub_AB53+93
		ld	hl, unk_D0E6
		cp	(hl)
		jr	nc, loc_AC0F

		ld	hl, (word_D069)
		ld	a, (ix+0)
		ld	(hl), a
		inc	hl
		ld	a, (ix+1)
		ld	(hl), a
		inc	hl
		ld	a, (ix+2)
		res	6, a
		ld	(hl), a
		inc	hl
		ld	(word_D069), hl
		jp	loc_ABC1

; ---------------------------------------------------------------------------

loc_AC0F:				; CODE XREF: sub_AB53+A0
		ld	b, 9
		ld	d, h
		ld	e, l
		jp	loc_AC19

; ---------------------------------------------------------------------------

loc_AC16:				; CODE XREF: sub_AB53+C9
		ld	(de), a
		inc	e
		dec	b


loc_AC19:				; CODE XREF: sub_AB53+C0
		inc	l
		ld	a, (hl)
		cp	c
		jr	c, loc_AC16

		ld	a, c
		ld	(de), a
		ld	de, (word_D04A)
		ld	hl, (word_D069)
		ld	a, b
		add	a, a
		add	a, b
		sbc	hl, de
		ld	c, a
		ld	b, 0
		sbc	hl, bc
		ld	b, h
		ld	c, l
		ld	a, (ix+0)
		ld	d, (ix+1)
		ld	e, (ix+2)
		push	de
		ld	hl, (word_D069)
		ld	d, h
		ld	e, l
		dec	hl
		inc	de
		inc	de
		inc	de
		ld	(word_D069), de
		dec	de
		jr	z, loc_AC4F

		lddr


loc_AC4F:				; CODE XREF: sub_AB53+F8
		inc	hl
		ld	(hl), a
		pop	de
		inc	hl
		ld	(hl), d
		inc	hl
		ld	(hl), e
		jp	loc_ABC1

; End of function sub_AB53


; =============== S U B	R O U T	I N E =======================================


sub_AC59:				; CODE XREF: sub_A90C
		ld	bc, 3


loc_AC5C:				; CODE XREF: sub_AC5D+5 sub_AC5D+F
		add	hl, bc

; End of function sub_AC59


; =============== S U B	R O U T	I N E =======================================


sub_AC5D:				; CODE XREF: sub_B36B+48 sub_B36B+52
		ld	a, (hl)
		cp	d
		jr	z, loc_AC67

		inc	a
		jp	nz, loc_AC5C

		scf
		ret

; ---------------------------------------------------------------------------

loc_AC67:				; CODE XREF: sub_AC5D+2
		inc	hl
		ld	a, (hl)
		dec	hl
		cp	e
		ret	z
		jp	loc_AC5C

; End of function sub_AC5D

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_AC74

loc_AC6F:				; CODE XREF: sub_AC74+37
		ld	a, #FF ;end of opening?
		ld	(byte_D09E), a

; END OF FUNCTION CHUNK	FOR sub_AC74

; =============== S U B	R O U T	I N E =======================================


sub_AC74:				; CODE XREF: sub_AFC5+B

; FUNCTION CHUNK AT AC6F SIZE 00000005 BYTES

		ld	a, (byte_D09E)
		or	a
		ret	nz ;end of opening?
		ld	a, (byte_D20C) ;oldmove #?
		dec	a
		ret	nz
		call	GEN_RANDBYTE ;b=rnd

		ld	hl, #FFFF


loc_AC84:				; CODE XREF: sub_AC74+33
		inc	hl ;hl=opening chunk
		ld	a, (word_D0F7)
		ld	c, a
		ld	a, (byte_D09E)
		inc	a
		ld	(byte_D09E), a
		dec	a
		cp	c
		jr	z, loc_ACB2

		ld	bc, stk_1bvalue
		add	a, c
		ld	c, a
		jr	nc, loc_AC9C

		inc	b


loc_AC9C:				; CODE XREF: sub_AC74+25
		ld	a, (bc)
		and	#7F ; ''
		ld	c, a
		call	sub_AD01


loc_ACA3:				; CODE XREF: sub_AC74+3C
		ld	b, a
		res	6, a
		cp	c
		jr	z, loc_AC84

		bit	6, b
		jr	z, loc_AC6F ;end of opening?

		call	sub_ACF6 ;find opening in loop

		jr	loc_ACA3

; ---------------------------------------------------------------------------

loc_ACB2:				; CODE XREF: sub_AC74+1E
		call	GEN_RANDBYTE ;b=rnd

		call	sub_AD01

		ld	c, a
		bit	6, a
		jr	z, loc_ACDD

		ld	a, 1
		rla
		and	b
		jr	nz, loc_ACDD


loc_ACC3:				; CODE XREF: sub_AC74+60
		push	hl
		call	GEN_RANDBYTE ;b=rnd

		call	sub_ACF6 ;find opening in loop

		jr	c, loc_ACD8

		pop	de
		ld	c, a
		bit	6, a
		jr	z, loc_ACDD

		rr	b
		jr	c, loc_ACC3

		jr	loc_ACDD

; ---------------------------------------------------------------------------

loc_ACD8:				; CODE XREF: sub_AC74+56
		pop	hl
		call	sub_AD01

		ld	c, a


loc_ACDD:				; CODE XREF: sub_AC74+47 sub_AC74+4D ...
		ld	a, c
		and	#3F ; '?'
		ld	d, a
		rla
		add	a, d
		ld	e, a
		ld	d, 0
		ld	ix, tbl_D803
		add	ix, de
		xor	a
		bit	7, c
		jr	nz, loc_ACF4

		ld	(byte_D09E), a


loc_ACF4:				; CODE XREF: sub_AC74+7B
		xor	a
		ret

; End of function sub_AC74


; =============== S U B	R O U T	I N E =======================================


sub_ACF6:				; CODE XREF: sub_AC74+39 sub_AC74+53
;hl=opening chunk
		ld	de, #FFFF


loc_ACF9:				; CODE XREF: sub_ACF6+9
;hl=opening chunk
		call	sub_AD01

		inc	hl
		bit	7, d
		jr	z, loc_ACF9

; End of function sub_ACF6


; =============== S U B	R O U T	I N E =======================================


sub_AD01:				; CODE XREF: sub_AC74+2C sub_AC74+41 ...
;hl=opening chunk
		call	OPENING_SEARCH

		bit	7, a
		jr	z, loc_AD09

		dec	de


loc_AD09:				; CODE XREF: sub_AD01+5
		bit	6, a
		ret	z
		inc	de
		ret

; End of function sub_AD01


; =============== S U B	R O U T	I N E =======================================


OPENING_SEARCH:
		push	bc		; get any 8 bits from 9-byte chunks? HL=index into them, 0..63 into first chunk, 64..127 into next, etc.
		push	hl
		ld	a, l
		srl	h
		rra
		srl	h
		rra
		srl	h
		rra
		ld	b, h
		ld	c, a		; BC=HL/8
		pop	hl
		push	hl
		ld	a, 7
		and	l
		add	hl, bc		; HL=HL*1.125
		ld	bc, Openings
		add	hl, bc
		ld	b, a
		inc	b
		ld	a, (hl)
		inc	hl
		ld	c, (hl)


loc_AD2B:
		rl	c
		rla
		djnz	loc_AD2B

		pop	hl
		pop	bc		; output is A (8 bits from a word) + CY (9th bit)
		ret

; End of function OPENING_SEARCH


; =============== S U B	R O U T	I N E =======================================


GEN_RANDBYTE:				; CODE XREF: sub_AC74+A
					; sub_AC74:loc_ACB2 ...
		ld	a, r
		ld	b, a
		ld	a, (RAND_SEED)
		xor	b
		rra
		ld	(RAND_SEED), a
		ld	b, a
		ret ;b=rnd

; End of function GEN_RANDBYTE


; =============== S U B	R O U T	I N E =======================================


sub_AD40:				; CODE XREF: sub_A906	sub_AB53+79 ...
		pop	hl
		exx
		ld	hl, (word_D00D)
		push	hl
		ld	hl, byte_D03B
		res	7, (hl)
		ld	hl,  word_D240+1
		ld	a, (byte_D097)
		add	a, a
		add	a, l
		ld	l, a
		ld	c, (ix+1)
		res	7, c
		ld	(hl), c
		ld	(word_D03D), hl
		dec	l
		ld	b, (ix+0)
		res	7, b
		ld	(hl), b
		dec	l
		bit	7, (hl)
		jr	nz, loc_ADA9

		dec	l
		dec	l
		ld	a, (hl)
		and	#F7 ; 'ч'
		cp	b
		jr	nz, loc_ADA9

		dec	l
		ld	a, (hl)
		and	#77 ; 'w'
		cp	c
		jr	nz, loc_ADA9

		dec	l
		ld	a, (hl)
		and	#F7 ; 'ч'
		jp	m, loc_ADA2

		push	bc
		ld	b, a
		dec	l
		ld	a, (hl)
		and	#77 ; 'w'
		ld	c, a
		inc	l
		inc	l
		inc	l
		inc	l
		ld	a, (hl)
		and	#77 ; 'w'
		cp	b
		jr	nz, loc_ADA1

		inc	l
		ld	a, (hl)
		and	#77 ; 'w'
		cp	c
		jr	nz, loc_ADA1

		ld	hl, byte_D03B
		set	7, (hl)
		set	6, (hl)
		pop	bc
		jr	loc_ADA9

; ---------------------------------------------------------------------------

loc_ADA1:				; CODE XREF: sub_AD40+4E sub_AD40+55
		pop	bc


loc_ADA2:				; CODE XREF: sub_AD40+3C
		ld	hl, byte_D03B
		set	7, (hl)
		res	6, (hl)


loc_ADA9:				; CODE XREF: sub_AD40+27 sub_AD40+2F ...
		ld	h, BRD_88_0/256
		ld	l, b
		ld	e, (hl)
		ld	d, l
		push	de
		ld	(hl), 0
		ld	l, c
		ld	c, (hl)
		ld	(hl), e
		ld	b, l
		inc	h		; word_D100
		res	2, e
		ld	l, e
		ld	(hl), b
		inc	l
		ld	e, d
		ld	d, (hl)
		ld	a, #F
		and	d
		jp	z, loc_AF1F

		dec	a
		jr	z, loc_ADF5

		set	4, (hl)
		dec	c
		inc	c
		jr	nz, loc_ADD1


loc_ADCC:				; CODE XREF: sub_AD40+1E7
		ld	e, #80 ; 'А'
		push	de
		exx
		jp	(hl)

; ---------------------------------------------------------------------------

loc_ADD1:				; CODE XREF: sub_AD40+8A
					; sub_AD40+1BD ...
		ld	e, 0


loc_ADD3:				; CODE XREF: sub_AD40+1AE
					; sub_AD40+1D2
		push	bc
		res	2, c
		ld	l, c
		set	7, (hl)
		inc	l
		ld	a, #F
		and	(hl)
		bit	7, l
		jr	z, loc_ADE3

		neg


loc_ADE3:				; CODE XREF: sub_AD40+9F
		ld	hl, word_D00D
		add	a, (hl)
		ld	(hl), a
		ld	hl, byte_D03B
		res	7, (hl)
		ld	hl, (word_D03D)
		set	7, (hl)
		push	de
		exx
		jp	(hl)

; ---------------------------------------------------------------------------

loc_ADF5:				; CODE XREF: sub_AD40+84
		ld	a, b
		cp	e
		jr	c, loc_AE66

		rla
		rla
		jr	nc, loc_AE45

		rl	a
		jr	c, loc_AE4D

		jp	m, loc_AE2D

		ld	(hl), #21 ; '!'
		ld	e, l
		dec	h
		ld	a, b
		add	a, #10
		ld	l, a
		ld	a, (hl)
		cp	#C0 ; 'ј'
		jr	nc, loc_AE59

		ld	a, l
		add	a, #F
		ld	l, a
		ld	a, (hl)
		cp	#C0 ; 'ј'
		jr	nc, loc_AE59

		inc	l
		ld	a, (hl)
		cp	#C0 ; 'ј'
		jr	nc, loc_AE59

		inc	l
		ld	a, (hl)
		cp	#C0 ; 'ј'
		jr	nc, loc_AE59

		ld	l, e
		inc	h
		ld	(hl), #51 ; 'Q'
		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AE2D:				; CODE XREF: sub_AD40+C1
		ld	(hl), #41 ; 'A'
		ld	e, l
		dec	h
		ld	a, b
		add	a, #10
		ld	l, a
		ld	a, (hl)
		cp	#C0 ; 'ј'
		jr	nc, loc_AE59

		ld	l, e
		inc	h
		ld	(hl), #71 ; 'q'
		set	0, (ix+2)
		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AE45:				; CODE XREF: sub_AD40+BB
		cp	#C0 ; 'ј'
		jp	nc, loc_AEF1

		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AE4D:				; CODE XREF: sub_AD40+BF
		jp	m, loc_AECF

		ld	(hl), #A1 ; '°'
		set	0, (ix+2)
		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AE59:				; CODE XREF: sub_AD40+CF sub_AD40+D8 ...
		ld	a, (ix+2)
		bit	3, a
		jp	z, loc_AF15

		ld	l, e
		inc	h
		jp	loc_AEFB

; ---------------------------------------------------------------------------

loc_AE66:				; CODE XREF: sub_AD40+B7
		rla
		rla
		jr	c, loc_AEBC

		rl	a
		jr	nc, loc_AEC3

		jp	p, loc_AEA2

		ld	(hl), #21 ; '!'
		ld	e, l
		dec	h
		ld	a, b
		sub	#10
		ld	l, a
		ld	a, (hl)
		and	#C0 ; 'ј'
		cp	#40 ; '@'
		jr	nc, loc_AE59

		ld	a, l
		sub	#11
		ld	l, a
		ld	a, (hl)
		and	#C0 ; 'ј'
		cp	#40 ; '@'
		jr	z, loc_AE59

		inc	l
		ld	a, (hl)
		and	#C0 ; 'ј'
		cp	#40 ; '@'
		jr	z, loc_AE59

		inc	l
		ld	a, (hl)
		and	#C0 ; 'ј'
		cp	#40 ; '@'
		jr	z, loc_AE59

		ld	l, e
		inc	h
		ld	(hl), #51 ; 'Q'
		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AEA2:				; CODE XREF: sub_AD40+12E
		ld	(hl), #41 ; 'A'
		ld	e, l
		dec	h
		ld	a, b
		sub	#10
		ld	l, a
		ld	a, (hl)
		and	#C0 ; 'ј'
		cp	#40 ; '@'
		jr	z, loc_AE59

		ld	l, e
		inc	h
		ld	(hl), #71 ; 'q'
		set	0, (ix+2)
		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AEBC:				; CODE XREF: sub_AD40+128
		and	#C0 ; 'ј'
		jr	z, loc_AEF1

		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AEC3:				; CODE XREF: sub_AD40+12C
		jp	p, loc_AECF

		ld	(hl), #A1 ; '°'
		set	0, (ix+2)
		jp	loc_AEF3

; ---------------------------------------------------------------------------

loc_AECF:				; CODE XREF: sub_AD40:loc_AE4D
					; sub_AD40:loc_AEC3
		set	6, (ix+2)
		ld	(hl), #19
		ld	a, (word_D00D)
		bit	7, l
		jr	z, loc_AEDE

		add	a, #10


loc_AEDE:				; CODE XREF: sub_AD40+19A
		sub	8
		ld	(word_D00D), a
		ld	e, #84 ; 'Д'
		bit	3, (ix+2)
		jp	z, loc_AF17

		ld	e, 4
		jp	loc_ADD3

; ---------------------------------------------------------------------------

loc_AEF1:				; CODE XREF: sub_AD40+107
					; sub_AD40+17E
		ld	(hl), #11


loc_AEF3:				; CODE XREF: sub_AD40+EA
					; sub_AD40+102 ...
		ld	a, (ix+2)
		bit	3, a
		jp	z, loc_AF15


loc_AEFB:				; CODE XREF: sub_AD40+123
		bit	5, a
		jp	z, loc_ADD1

		ld	a, b
		bit	7, l
		jr	z, loc_AF07

		add	a, #20 ; ' '


loc_AF07:				; CODE XREF: sub_AD40+1C3
		sub	#10
		dec	h
		ld	l, a
		ld	c, (hl)
		ld	(hl), 0
		inc	h
		ld	b, l
		ld	e, 1
		jp	loc_ADD3

; ---------------------------------------------------------------------------

loc_AF15:				; CODE XREF: sub_AD40+11E
					; sub_AD40+1B8
		ld	e, #80 ; 'А'


loc_AF17:				; CODE XREF: sub_AD40+1A9
		push	de
		ld	hl, (word_D03D)
		set	7, (hl)
		exx
		jp	(hl)

; ---------------------------------------------------------------------------

loc_AF1F:				; CODE XREF: sub_AD40+80
		call	sub_AF65

		ld	a, (ix+2)
		and	#18
		jp	z, loc_ADCC

		and	8
		jp	nz, loc_ADD1

		set	5, (hl)
		dec	h
		bit	2, b
		jr	z, loc_AF40

		inc	b
		ld	l, b
		ld	c, (hl)
		ld	(hl), 0
		dec	l
		dec	l
		jp	loc_AF49

; ---------------------------------------------------------------------------

loc_AF40:				; CODE XREF: sub_AD40+1F4
		dec	b
		dec	b
		ld	l, b
		ld	c, (hl)
		ld	(hl), 0
		inc	l
		inc	l
		inc	l


loc_AF49:				; CODE XREF: sub_AD40+1FD
		ld	(hl), c
		ld	a, (word_D04A+1)
		or	a
		jr	z, loc_AF54

		ld	a, #84 ; 'Д'
		and	c
		ld	(hl), a


loc_AF54:				; CODE XREF: sub_AD40+20E
		push	bc
		res	2, c
		ld	b, #D1	; '—'
		ld	a, l
		ld	(bc), a
		ld	e, #40 ; '@'
		ld	hl, (word_D03D)
		set	7, (hl)
		push	de
		exx
		jp	(hl)

; End of function sub_AD40


; =============== S U B	R O U T	I N E =======================================


sub_AF65:				; CODE XREF: sub_AD40:loc_AF1F
		ld	a, d
		or	#10


loc_AF68:				; CODE XREF: sub_884D:loc_A912
		and	#3F ; '?'
		ld	e, #11


loc_AF6C:				; CODE XREF: sub_AF65+19
		ld	(hl), a
		ld	a, b
		add	a, e
		and	#88 ; 'И'
		ret	nz
		ld	a, b
		sub	e
		and	#88 ; 'И'
		ret	nz
		ld	a, #11
		add	a, e
		ld	e, a
		ld	a, #40 ; '@'
		add	a, (hl)
		jp	loc_AF6C

; End of function sub_AF65


; =============== S U B	R O U T	I N E =======================================


sub_AF81:				; CODE XREF: sub_A909	sub_AB53+7F ...
		pop	hl
		exx
		pop	af
		pop	hl
		ld	c, a
		ld	a, 0
		ld	d, BRD_88_0/256
		jp	m, loc_AF9A

		jr	z, loc_AFB6

		jr	c, loc_AFAF

		ld	b, l


loc_AF92:				; CODE XREF: sub_AF81+32
		res	2, l
		ld	h, word_D100/256
		res	7, (hl)
		ld	a, b


loc_AF99:				; CODE XREF: sub_AF81+41
		pop	hl


loc_AF9A:				; CODE XREF: sub_AF81+9
		ld	e, h
		ex	de, hl
		ld	(hl), e
		ex	de, hl
		res	2, l
		ld	h, word_D100/256
		ld	b, (hl)
		ld	(hl), e
		inc	l
		ld	(hl), c
		ld	l, b
		dec	h		; BRD_88_0/256
		ld	(hl), a
		pop	hl
		ld	(word_D00D), hl
		exx
		jp	(hl)

; ---------------------------------------------------------------------------

loc_AFAF:				; CODE XREF: sub_AF81+E
		ld	e, h
		ld	b, a
		ld	a, l
		ld	(de), a
		jp	loc_AF92

; ---------------------------------------------------------------------------

loc_AFB6:				; CODE XREF: sub_AF81+C
		ld	e, h
		ld	a, l
		ld	(de), a
		res	2, l
		ld	h, word_D100/256
		ld	b, (hl)
		ld	(hl), e
		xor	a
		ld	e, b
		ld	(de), a
		jp	loc_AF99

; End of function sub_AF81


; =============== S U B	R O U T	I N E =======================================


sub_AFC5:				; CODE XREF: sub_A900
		ld	ix, word_D059
		call	sub_A94F

		dec	hl
		dec	hl
		ld	(hl), #FF
		call	sub_AC74

		jp	z, loc_B0B7

		ld	a, (byte_D0B4)
		bit	5, a
		jr	z, loc_AFE0

		call	nz, sub_B2E2


loc_AFE0:				; CODE XREF: sub_AFC5+16
		call	sub_B2D1

		call	sub_B2F1

		call	sub_B1EB

		ld	hl, byte_D0B3 ;d3=swap board
		res	5, (hl)
		ld	hl, byte_D108
		xor	a
		ld	(byte_D04C), a
		call	sub_A932

		ld	e, c
		ld	l, #88 ; 'И'
		call	sub_A932

		ld	a, c
		sub	e
		ld	(byte_D02E), a
		ld	a, (byte_D049) ;move #
		cp	8
		cpl
		jr	c, loc_B00D

		ld	a, c
		add	a, e


loc_B00D:				; CODE XREF: sub_AFC5+44
		ld	hl, byte_A928-1


loc_B010:				; CODE XREF: sub_AFC5+4E
		inc	hl
		cp	(hl)
		inc	hl
		jr	c, loc_B010

		ld	b, (hl)
		ld	hl, byte_D02D
		ld	a, (hl)
		and	1
		or	b
		ld	(hl), a
		xor	a
		ld	(word_D00D), a
		ld	a, #FE	; 'ю'
		ld	(byte_D098), a
		call	sub_B2B9

		push	hl
		call	sub_AB4C

		pop	ix
		scf
		ret	z
		ld	a, (byte_D0EF)
		ld	(byte_D08B), a
		inc	ix
		xor	a
		ld	(word_D00D+1), a
		inc	a
		ld	(byte_D03B), a
		ld	a, (byte_D0B1)
		cp	#B
		call	nc, sub_B8B2

		ld	a, (byte_D0F1)
		ld	(byte_D0F2), a


loc_B050:				; CODE XREF: sub_AFC5+EF
		call	sub_8F4D

		call	loc_B819

		jr	c, loc_B0B7

		push	ix
		call	sub_B19C


loc_B05D:				; CODE XREF: sub_AFC5:loc_B182
		ld	a, (byte_D0B1)
		cp	#C
		jr	nz, loc_B07A

		xor	a
		ld	(byte_D08A), a
		ld	(byte_D08C), a
		ld	(byte_D00B), a
		ld	(byte_D01C), a
		inc	a
		ld	(byte_D08B), a
		ld	a, #80 ; 'А'
		ld	(byte_D019), a


loc_B07A:				; CODE XREF: sub_AFC5+9D
		call	sub_B47F

		call	sub_B2D1

		ld	hl, byte_D08B
		pop	ix
		ld	a, (byte_D0B1)
		cp	#C
		jr	nz, loc_B091

		call	sub_A6F7

		jr	loc_B097

; ---------------------------------------------------------------------------

loc_B091:				; CODE XREF: sub_AFC5+C5
		ld	a, (ix+3)
		inc	a
		jr	z, loc_B09C


loc_B097:				; CODE XREF: sub_AFC5+CA
		ld	a, (hl)
		cp	#FE ; 'ю'
		jr	c, loc_B0A3


loc_B09C:				; CODE XREF: sub_AFC5+D0
		ld	a, (byte_D0B4)
		bit	5, a
		jr	z, loc_B0B7


loc_B0A3:				; CODE XREF: sub_AFC5+D5
		ld	a, (byte_D0B4)
		rla
		jr	c, loc_B0B7

		push	ix
		ld	a, (byte_D00B)
		cp	(hl)
		jp	z, loc_B175

		pop	ix
		jp	loc_B050

; ---------------------------------------------------------------------------

loc_B0B7:				; CODE XREF: sub_AFC5+E sub_AFC5+91	...
		ld	a, (byte_D0B4)
		bit	5, a
		jp	nz, loc_B164

		ld	bc, (INC_SECONDS)
		ld	hl, (word_D088)
		add	hl, bc
		ld	(word_D088), hl
		ld	a, (byte_D049) ;move #
		cp	9
		jp	c, loc_B164

		ld	h, b
		ld	l, c
		ld	a, (byte_D03C)
		cp	4
		jr	nc, loc_B0E9

		push	af
		ld	a, (byte_D0B3) ;d3=swap board
		bit	5, a
		jr	nz, loc_B0E8

		ld	bc, (word_D02B)
		add	hl, bc


loc_B0E8:				; CODE XREF: sub_AFC5+11C
		pop	af


loc_B0E9:				; CODE XREF: sub_AFC5+114
		cp	6
		ld	a, (byte_D02A)
		ld	c, a
		ld	b, 0
		jr	c, loc_B0FE

		ld	a, c
		rra
		rra
		and	#3F ; '?'
		add	a, c
		ld	c, a
		ld	a, 0
		adc	a, b
		ld	b, a


loc_B0FE:				; CODE XREF: sub_AFC5+12C
		ld	a, 4


loc_B100:				; CODE XREF: sub_AFC5+140
		dec	a
		jr	z, loc_B107

		sbc	hl, bc
		jr	nc, loc_B100


loc_B107:				; CODE XREF: sub_AFC5+13C
		sub	2
		jr	z, loc_B120

		jr	c, loc_B11D

		ld	a, (byte_D03C)
		cp	3
		jr	nc, loc_B11B

		ld	a, (byte_D0B3) ;d3=swap board
		bit	5, a
		jr	nz, loc_B120


loc_B11B:				; CODE XREF: sub_AFC5+14D
		ld	a, 1


loc_B11D:				; CODE XREF: sub_AFC5+146
		call	sub_B185


loc_B120:				; CODE XREF: sub_AFC5+144
					; sub_AFC5+154
		ld	a, (byte_D0B1)
		cp	#A
		jr	z, loc_B14F

		ld	a, (byte_D02D)
		bit	2, a
		jr	nz, loc_B14F

		ld	a, (byte_D0F4)
		cp	#9B ; 'Ы'
		jr	c, loc_B164

		ld	a, (byte_D0B1)
		add	a, a
		ld	hl, tbl_B8DD-2
		add	a, l
		ld	l, a
		ld	a, 0
		adc	a, h
		ld	h, a
		ld	a, (byte_D0F1)
		sub	3
		sub	(hl)
		neg
		call	m, sub_B185

		jr	loc_B164

; ---------------------------------------------------------------------------

loc_B14F:				; CODE XREF: sub_AFC5+160
					; sub_AFC5+167
		ld	a, (byte_D0F1)
		add	a, 4
		ld	hl, byte_D0F2
		cp	(hl)
		ld	a, 2
		jr	nc, loc_B164

		ld	hl, byte_D0B3 ;d3=swap board
		bit	5, (hl)
		call	z, sub_B185


loc_B164:				; CODE XREF: sub_AFC5+F7
					; sub_AFC5+10A ...
		xor	a
		ret

; ---------------------------------------------------------------------------

loc_B166:				; CODE XREF: sub_B47F+CA
		xor	a
		ld	(byte_D08A), a
		ld	(byte_D08C), a
		ld	a, (byte_D00B)
		ld	(byte_D08B), a
		jr	loc_B182

; ---------------------------------------------------------------------------

loc_B175:				; CODE XREF: sub_AFC5+EA
		ld	a, (byte_D08A)
		ld	(byte_D08C), a
		xor	a
		ld	(byte_D00B), a
		ld	(byte_D08B), a


loc_B182:				; CODE XREF: sub_AFC5+1AE
		jp	loc_B05D

; End of function sub_AFC5


; =============== S U B	R O U T	I N E =======================================


sub_B185:				; CODE XREF: sub_AFC5:loc_B11D
					; sub_AFC5+185 ...
		ld	d, a
		ld	a, (byte_D0F1)
		add	a, d
		ld	d, a
		and	#F0 ; 'р'
		jr	nz, loc_B191

		ld	d, #10


loc_B191:				; CODE XREF: sub_B185+8
		cp	#50 ; 'P'
		jr	c, loc_B197

		ld	d, #4F ; 'O'


loc_B197:				; CODE XREF: sub_B185+E
		ld	a, d
		ld	(byte_D0F1), a
		ret

; End of function sub_B185


; =============== S U B	R O U T	I N E =======================================


sub_B19C:				; CODE XREF: sub_AFC5+95
		ld	a, (byte_D08B)
		ld	c, a
		add	a, #84 ; 'Д'
		sra	a
		sra	a
		sra	a
		ld	b, a
		ld	a, (byte_D0B2)
		or	a
		ld	a, b
		jr	nz, loc_B1B2

		neg


loc_B1B2:				; CODE XREF: sub_B19C+12
		ld	hl, word_D00D
		add	a, (hl)
		ld	(hl), a
		neg
		ld	hl, byte_D02E
		add	a, (hl)
		cp	#F
		jr	c, loc_B1CC

		cp	#F2 ; 'т'
		jr	nc, loc_B1CC

		rla
		ld	a, #E
		jr	nc, loc_B1CC

		ld	a, #F2	; 'т'


loc_B1CC:				; CODE XREF: sub_B19C+23 sub_B19C+27 ...
		add	a, a
		add	a, a
		add	a, a
		ld	(byte_D01E), a
		ld	a, b
		add	a, a
		add	a, a
		add	a, a
		neg
		add	a, c
		sub	8
		ld	(byte_D00B), a
		ld	(byte_D08B), a
		ld	(byte_D08A), a
		ld	(byte_D08C), a
		ret

; End of function sub_B19C

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_B1EB

loc_B1E8:				; CODE XREF: sub_B1EB+46
		call	sub_B8B2

; END OF FUNCTION CHUNK	FOR sub_B1EB

; =============== S U B	R O U T	I N E =======================================


sub_B1EB:				; CODE XREF: sub_AFC5+21

; FUNCTION CHUNK AT B1E8 SIZE 00000003 BYTES

		ld	a, (byte_D0B1)
		cp	#A
		ld	a, (byte_D0F4)
		jr	nz, loc_B205

		or	a
		ld	(byte_D0F3), a
		rr	a
		inc	a
		ld	(byte_D02A), a
		ld	a, #A
		ld	(byte_D03C), a
		ret

; ---------------------------------------------------------------------------

loc_B205:				; CODE XREF: sub_B1EB+8
		ld	e, a
		xor	a
		ld	d, a
		ld	b, #A
		ld	hl, 0


loc_B20D:				; CODE XREF: sub_B1EB+24
		adc	hl, de		; mul E	by 10, why ADC???
		djnz	loc_B20D

		ld	a, (byte_D049) ;move #
		dec	a
		ld	b, 0
		ld	c, #A


loc_B219:				; CODE XREF: sub_B1EB+30
		inc	b
		sub	c
		jr	nc, loc_B219

		neg
		ld	d, h
		ld	e, l
		or	a
		jr	loc_B226

; ---------------------------------------------------------------------------

loc_B224:				; CODE XREF: sub_B1EB:loc_B226
		adc	hl, de		; E*10*floor(byte_D049/10)


loc_B226:				; CODE XREF: sub_B1EB+37
		djnz	loc_B224

		ld	de, (word_D088)
		or	a
		sbc	hl, de
		bit	7, h
		jr	nz, loc_B1E8

		ld	c, a
		push	hl
		ld	a, (byte_D0F4)
		ld	d, 0
		ld	e, a
		xor	a
		ld	(byte_D03C), a
		dec	a


loc_B240:				; CODE XREF: sub_B1EB+58
		inc	a
		sbc	hl, de
		jr	nc, loc_B240

		sub	c
		jr	c, loc_B24B

		ld	(byte_D03C), a


loc_B24B:				; CODE XREF: sub_B1EB+5B
		pop	hl
		ld	a, #FE	; 'ю'
		ld	(byte_D0F3), a
		ld	(byte_D02A), a
		ld	a, h
		srl	a
		jr	nz, loc_B26A

		ld	a, l
		rra
		dec	c
		jr	z, loc_B260

		srl	a


loc_B260:				; CODE XREF: sub_B1EB+71
		inc	c
		sub	2
		jr	nc, loc_B266

		xor	a


loc_B266:				; CODE XREF: sub_B1EB+78
		inc	a
		ld	(byte_D0F3), a


loc_B26A:				; CODE XREF: sub_B1EB+6C
		xor	a		; HL=HL/C ?
		ld	b, #11


loc_B26D:				; CODE XREF: sub_B1EB+8C
		rl	l		; ADC HL,HL?
		rl	h
		rla
		cp	c
		jr	c, loc_B276

		sub	c


loc_B276:				; CODE XREF: sub_B1EB+88
		ccf
		djnz	loc_B26D

		ld	a, h
		srl	a
		jr	nz, loc_B29C

		ld	a, l
		rra
		or	a
		jr	nz, loc_B284

		inc	a


loc_B284:				; CODE XREF: sub_B1EB+96
		ld	(byte_D02A), a
		rla
		jr	c, loc_B29C

		ld	a, (byte_D0F4)
		cp	l
		jr	c, loc_B29F

		ld	a, (byte_D0B4)
		bit	5, a
		jr	nz, loc_B29C

		ld	a, #FF
		call	sub_B185


loc_B29C:				; CODE XREF: sub_B1EB+91 sub_B1EB+9D ...
		ld	a, (byte_D0F4)


loc_B29F:				; CODE XREF: sub_B1EB+A3
		ld	hl, byte_D02A
		cp	(hl)
		jr	nc, loc_B2A6

		ld	(hl), a


loc_B2A6:				; CODE XREF: sub_B1EB+B8
		ld	a, (byte_D02A)
		ld	b, a
		add	a, a
		ret	c
		add	a, b
		ret	c
		ld	b, a
		ld	a, (byte_D0F3)
		cp	b
		ret	c
		ld	a, b
		ld	(byte_D0F3), a
		ret

; End of function sub_B1EB


; =============== S U B	R O U T	I N E =======================================


sub_B2B9:				; CODE XREF: sub_AFC5+62 sub_B47F-50 ...
		ld	hl, byte_D097
		ld	a, (hl)
		add	a, a
		add	a, l
		ld	l, a
		ld	e, (hl)
		inc	l
		ld	d, (hl)
		ex	de, hl
		inc	hl
		inc	hl
		ret

; End of function sub_B2B9

; ---------------------------------------------------------------------------

		; no alignment

		; low parts of addresses in D2xx region
tbl_B2C7:	db #58
		db #66
		db #72
		db #7C
		db #84
		db #8A
		db #8E
		db #90
		db #90
		db #8E

; =============== S U B	R O U T	I N E =======================================


sub_B2D1:				; CODE XREF: sub_AFC5:loc_AFE0
					; sub_AFC5+B8
		ld	hl, byte_D258
		ld	de, byte_D20D
		ld	b, #E


loc_B2D9:				; CODE XREF: sub_B2D1+E
		ld	a, (hl)
		and	#77 ; 'w'
		ld	(de), a
		inc	e
		inc	l
		djnz	loc_B2D9

		ret

; End of function sub_B2D1


; =============== S U B	R O U T	I N E =======================================


sub_B2E2:				; CODE XREF: sub_AFC5+18
		ld	hl, byte_D25C
		ld	de, byte_D258
		ld	b, #A


loc_B2EA:				; CODE XREF: sub_B2E2+C
		ld	a, (hl)
		ld	(de), a
		inc	e
		inc	l
		djnz	loc_B2EA

		ret

; End of function sub_B2E2


; =============== S U B	R O U T	I N E =======================================


sub_B2F1:				; CODE XREF: sub_AFC5+1E
					; sub_B47F:loc_B405 ...
		ld	a, (byte_D097)
		cp	7
		ret	nc		; only 0..6
		ld	e, a
		ld	hl, tbl_B2C7
		ld	d, 0
		add	hl, de
		ld	e, (hl)
		inc	hl
		ld	l, (hl)
		ld	h, array_D200/256
		ld	d, h
		ld	a, #FF
		ld	(hl), a
		ld	(de), a
		ret

; End of function sub_B2F1


; =============== S U B	R O U T	I N E =======================================


sub_B309:				; CODE XREF: sub_B47F+9D
					; sub_B47F+228 ...
		ld	a, (byte_D097)
		ld	e, a
		sub	8
		jr	nc, sub_B34B

		cpl
		ld	b, a
		ld	hl, tbl_B2C7-1
		ld	d, 0
		add	hl, de
		ld	e, (hl)
		inc	hl
		ld	l, (hl)
		ld	h, array_D200/256
		ld	d, h
		ld	a, (ix+0)
		ld	(de), a
		inc	e
		ld	a, (ix+1)
		ld	(de), a
		dec	b
		jp	m, loc_B337

		inc	b


loc_B32D:				; CODE XREF: sub_B309+2C
		inc	e
		ld	a, (hl)
		ld	(de), a
		inc	l
		inc	e
		ld	a, (hl)
		ld	(de), a
		inc	l
		djnz	loc_B32D


loc_B337:				; CODE XREF: sub_B309+20
		ld	hl, byte_D0B6
		bit	0, (hl)
		jr	z, sub_B34B

		ld	a, (byte_D097)
		dec	a
		jr	nz, loc_B346

		set	2, (hl)


loc_B346:				; CODE XREF: sub_B309+39
		bit	2, (hl)
		call	nz, sub_A684

; End of function sub_B309


; =============== S U B	R O U T	I N E =======================================


sub_B34B:				; CODE XREF: sub_B309+6 sub_B309+33	...
		ld	c, (ix+1)
		bit	7, c
		ret	nz
		ld	hl, unk_D20B	; D20D-2 ?
		ld	a, (byte_D097)
		add	a, a
		add	a, l
		ld	l, a
		ld	a, (ix+0)
		and	#77 ; 'w'
		ld	(hl), a
		inc	l
		ld	(hl), c
		bit	3, (ix+2)
		ret	z
		dec	l
		set	7, (hl)
		ret

; End of function sub_B34B


; =============== S U B	R O U T	I N E =======================================


sub_B36B:				; CODE XREF: sub_B47F-71
		inc	hl
		inc	hl
		inc	hl
		push	hl
		ld	a, (ix+2)
		and	6
		jp	z, loc_B39E

		ld	b, (ix+1)
		and	4
		jr	nz, loc_B385

		ld	a, (byte_D07A)
		ld	b, a
		rla
		jr	c, loc_B39E


loc_B385:				; CODE XREF: sub_B36B+11
		ex	de, hl
		inc	hl
		ld	de, #FFFD	; -3
		res	7, b


loc_B38C:				; CODE XREF: sub_B36B+27
		add	hl, de
		ld	a, (hl)
		cp	b
		jr	z, loc_B397

		inc	a
		jp	nz, loc_B38C

		jr	loc_B39E

; ---------------------------------------------------------------------------

loc_B397:				; CODE XREF: sub_B36B+24
		pop	de
		dec	hl
		call	sub_B3CA

		inc	de
		push	de


loc_B39E:				; CODE XREF: sub_B36B+9 sub_B36B+18	...
		ld	hl, unk_D20B	; D20D-2 ?
		ld	a, (byte_D097)
		add	a, a
		add	a, l
		ld	l, a
		ld	d, (hl)
		inc	l
		ld	e, (hl)
		ld	bc, 3
		pop	hl
		push	hl
		bit	7, d
		jr	nz, loc_B3BB

		call	sub_AC5D


loc_B3B6:				; CODE XREF: sub_B36B+5B
		pop	de
		call	nc, sub_B3CA

		ret

; ---------------------------------------------------------------------------

loc_B3BB:				; CODE XREF: sub_B36B+46
		res	7, d
		call	sub_AC5D

		inc	hl
		inc	hl
		bit	3, (hl)
		dec	hl
		dec	hl
		jr	nz, loc_B3B6

		pop	de
		ret

; End of function sub_B36B


; =============== S U B	R O U T	I N E =======================================


sub_B3CA:				; CODE XREF: sub_B36B+2E sub_B36B+4C
		ld	c, (hl)
		ld	a, (de)
		ld	(hl), a
		ld	a, c
		or	#80 ; 'А'
		ld	(de), a
		inc	de
		inc	hl
		ld	c, (hl)
		ld	a, (de)
		ld	(hl), a
		ld	a, c
		or	#80 ; 'А'
		ld	(de), a
		inc	de
		inc	hl
		ld	c, (hl)
		ld	a, (de)
		ld	(hl), a
		ld	a, c
		ld	(de), a
		ret

; End of function sub_B3CA


; =============== S U B	R O U T	I N E =======================================


sub_B3E2:				; CODE XREF: sub_B47F+A7 sub_B47F+C2
		push	ix
		pop	hl
		ld	a, (hl)
		ld	d, h
		ld	e, l
		inc	hl
		ld	b, (hl)
		inc	hl
		ld	c, (hl)
		ex	af, af'


loc_B3ED:				; CODE XREF: sub_B3E2+18
		dec	de
		ld	a, (de)
		ld	(hl), a
		dec	de
		dec	hl
		ld	a, (de)
		ld	(hl), a
		dec	de
		dec	hl
		ld	a, (de)
		ld	(hl), a
		dec	hl
		inc	a
		jp	nz, loc_B3ED

		inc	hl
		ex	af, af'
		ld	(hl), a
		inc	hl
		ld	(hl), b
		inc	hl
		ld	(hl), c
		ret

; End of function sub_B3E2

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_B47F

loc_B405:				; CODE XREF: sub_B47F+3D
		call	sub_B2F1

		call	sub_A94F

		dec	hl
		dec	hl
		push	hl
		call	sub_B36B

		pop	ix


loc_B413:				; CODE XREF: sub_B47F+96 sub_B47F+99 ...
		ld	a, (byte_D098)
		inc	a
		ld	d, a
		ld	a, (byte_D097)
		cp	d
		jp	nc, loc_B5A3

		bit	7, (ix+0)
		jp	z, loc_B47A

		call	sub_B75A


loc_B429:				; CODE XREF: sub_B47F-12 sub_B47F-7
		bit	7, (ix+3)
		jr	nz, loc_B442

		call	sub_B2B9

		push	hl
		call	sub_AB53

		jp	c, loc_B531

		pop	ix
		jp	z, loc_B571

		inc	ix
		jr	sub_B47F

; ---------------------------------------------------------------------------

loc_B442:				; CODE XREF: sub_B47F-52
		ld	de, 3
		add	ix, de
		ld	a, (ix+0)
		inc	a
		jp	z, loc_B4E7

		call	sub_B2B9

		ld	a, (hl)
		ld	(byte_D01D), a
		push	ix
		call	sub_AD40

		call	sub_BC00

		or	a
		jr	z, loc_B46F

		call	sub_B79D

		jp	c, loc_B535

		jr	z, loc_B4A6

		call	sub_AF81

		pop	ix
		jr	loc_B429

; ---------------------------------------------------------------------------

loc_B46F:				; CODE XREF: sub_B47F-21
		ld	(ix+1),	#FF
		call	sub_AF81

		pop	ix
		jr	loc_B429

; ---------------------------------------------------------------------------

loc_B47A:				; CODE XREF: sub_B47F-5C
		ld	de, 3
		add	ix, de

; END OF FUNCTION CHUNK	FOR sub_B47F

; =============== S U B	R O U T	I N E =======================================


sub_B47F:				; CODE XREF: sub_AFC5:loc_B07A
					; sub_B47F-3F

; FUNCTION CHUNK AT B405 SIZE 0000007A BYTES
; FUNCTION CHUNK AT B5D1 SIZE 00000189 BYTES

		ld	a, #FF
		ld	(byte_D07A), a
		ld	a, (ix+0)
		inc	a
		jr	z, loc_B4E7

		push	ix
		call	sub_AD40

		call	sub_B96D

		jp	c, loc_B4A6

		ld	b, 0
		ld	hl, byte_D097
		inc	(hl)
		ld	a, (byte_D02D)
		xor	1
		ld	(byte_D02D), a
		jp	loc_B576

; ---------------------------------------------------------------------------

loc_B4A6:				; CODE XREF: sub_B47F-19 sub_B47F+13 ...
		ld	a, (byte_D02D)
		xor	1
		ld	(byte_D02D), a
		ld	hl, byte_D097
		ld	a, (hl)
		inc	(hl)
		ld	hl,  word_D088+1
		add	a, l
		ld	l, a
		ld	a, (hl)
		inc	l
		inc	l
		ld	(hl), a
		jp	loc_B405

; ---------------------------------------------------------------------------

loc_B4BF:				; CODE XREF: sub_B47F+54
		ld	hl, byte_D097
		dec	(hl)
		ld	a, (byte_D02D)
		xor	1
		ld	(byte_D02D), a
		jp	loc_B535

; ---------------------------------------------------------------------------

loc_B4CE:				; CODE XREF: sub_B47F+261
		rra
		jp	c, loc_B4D5

		rra
		jr	nc, loc_B4BF


loc_B4D5:				; CODE XREF: sub_B47F+50
					; sub_B47F+15B ...
		ld	de, #FFFD	; -3


loc_B4D8:				; CODE XREF: sub_B47F+66
		add	ix, de
		ld	a, (ix+0)
		inc	a
		jp	z, loc_B563

		ld	a, (ix+1)
		inc	a
		jr	z, loc_B4D8


loc_B4E7:				; CODE XREF: sub_B47F-34 sub_B47F+9	...
		ld	a, (byte_D097)
		dec	a
		ret	z
		ld	(byte_D097), a
		call	sub_AF81

		pop	ix


loc_B4F4:				; CODE XREF: sub_B47F+111
		ld	a, (byte_D02D)
		xor	1
		ld	(byte_D02D), a
		ld	a, (byte_D0B4)
		and	#90 ; 'Р'
		jr	nz, loc_B4E7

		ld	a, (byte_D097)
		ld	hl, byte_D08B
		add	a, l
		ld	l, a
		ld	a, (hl)
		dec	a
		dec	l
		dec	l
		cp	(hl)
		jr	c, loc_B53A

		cpl
		inc	l
		cp	(hl)
		jp	c, loc_B413

		jp	z, loc_B413

		ld	(hl), a
		call	sub_B309

		ld	a, (byte_D097)
		dec	a
		jp	nz, loc_B413

		call	sub_B3E2

		ld	a, (byte_D08B)
		inc	a
		ret	z
		jp	loc_B413

; ---------------------------------------------------------------------------

loc_B531:				; CODE XREF: sub_B47F-49
		pop	hl
		jp	loc_B53A

; ---------------------------------------------------------------------------

loc_B535:				; CODE XREF: sub_B47F-1C sub_B47F+4C ...
		call	sub_AF81

		pop	ix


loc_B53A:				; CODE XREF: sub_B47F+91 sub_B47F+B3
		ld	a, (byte_D097)
		dec	a
		jp	nz, loc_B54C

		call	sub_B3E2

		pop	hl
		pop	ix
		push	ix
		jp	loc_B166

; ---------------------------------------------------------------------------

loc_B54C:				; CODE XREF: sub_B47F+BF
		call	sub_B34B

		call	sub_AF81

		pop	ix
		ld	hl, byte_D097
		dec	(hl)
		ld	a, (byte_D02D)
		xor	1
		ld	(byte_D02D), a
		jp	loc_B413

; ---------------------------------------------------------------------------

loc_B563:				; CODE XREF: sub_B47F+5F
		ld	b, (ix+2)
		ld	a, (byte_D0B1)
		cp	#C
		jr	z, loc_B574

		ld	c, 2
		jr	loc_B576

; ---------------------------------------------------------------------------

loc_B571:				; CODE XREF: sub_B47F-44
		ld	b, (ix+0)


loc_B574:				; CODE XREF: sub_B47F+EC
		ld	c, 1


loc_B576:				; CODE XREF: sub_B47F+24 sub_B47F+F0
		ld	hl, byte_D08A
		ld	a, (byte_D097)
		add	a, l
		ld	l, a
		bit	7, b
		jr	z, loc_B593

		ld	(hl), c
		ld	hl, byte_D097
		dec	(hl)
		call	sub_AF81

		pop	ix
		ld	(ix+3),	#FF
		jp	loc_B4F4

; ---------------------------------------------------------------------------

loc_B593:				; CODE XREF: sub_B47F+101
		ld	a, (byte_D02D)
		rra
		ld	a, (byte_D01E)
		jr	nc, loc_B59D

		cpl


loc_B59D:				; CODE XREF: sub_B47F+11B
		add	a, #84 ; 'Д'
		ld	(hl), a
		jp	loc_B4E7

; ---------------------------------------------------------------------------

loc_B5A3:				; CODE XREF: sub_B47F-63
		call	sub_B2B9

		ld	a, (hl)
		ld	(byte_D01D), a
		ld	a, (byte_D097)
		ld	e, a
		ld	hl,  word_D088+1
		add	a, l
		ld	l, a
		ld	(word_D06D), hl
		ld	a, (byte_D098)
		add	a, 2
		sub	e
		jp	m, loc_B72D

		jp	z, loc_B6D4

		ld	(byte_D03B), a
		jp	loc_B5D1

; ---------------------------------------------------------------------------

loc_B5C8:				; CODE XREF: sub_B47F+167
		ld	(ix+1),	#FF


loc_B5CC:				; CODE XREF: sub_B47F+1DF
					; sub_B47F+1F2 ...
		call	sub_AF81

		pop	ix

; End of function sub_B47F

; START	OF FUNCTION CHUNK FOR sub_B47F

loc_B5D1:				; CODE XREF: sub_B47F+146
		ld	de, 3
		add	ix, de
		ld	a, (ix+0)
		inc	a
		jp	z, loc_B4D5

		push	ix
		call	sub_AD40

		call	sub_BC00

		or	a
		jr	z, loc_B5C8

		cpl
		ld	hl, (word_D06D)
		cp	(hl)
		jp	nc, loc_B645

		ld	a, (byte_D01D)
		and	#CD ; 'Ќ'
		jp	z, loc_B535

		cp	8
		jr	z, loc_B620

		ld	a, (byte_D097)
		ld	d, a
		ld	a, (word_D00D+1)
		add	a, a
		cp	d
		jr	c, loc_B620

		ld	a, (byte_D019)
		and	#7F ; ''
		jp	z, loc_B535

		bit	3, a
		jp	nz, loc_B4A6

		bit	2, a
		jr	z, loc_B623

		ld	hl, byte_D03B
		ld	(hl), 0
		jp	loc_B4A6

; ---------------------------------------------------------------------------

loc_B620:				; CODE XREF: sub_B47F+17B
					; sub_B47F+186
		ld	a, (byte_D019)


loc_B623:				; CODE XREF: sub_B47F+197
		and	3
		jp	z, loc_B535

		ld	d, 6
		rra
		jp	c, loc_B630

		ld	d, #C


loc_B630:				; CODE XREF: sub_B47F+1AC
		ld	a, (byte_D01D)
		and	#8D ; 'Н'
		jp	z, loc_B535

		rla
		jr	c, loc_B63D

		sra	d


loc_B63D:				; CODE XREF: sub_B47F+1BA
		ld	a, d
		sub	c
		jr	nc, loc_B645

		cp	(hl)
		jp	c, loc_B535


loc_B645:				; CODE XREF: sub_B47F+16E
					; sub_B47F+1C0
		inc	l
		ld	a, (ix+2)
		ld	d, a
		rla
		jp	nc, loc_B65B

		bit	2, d
		jp	z, loc_B4A6

		ld	a, (byte_D0B1)
		cp	#C
		jp	z, loc_B4A6


loc_B65B:				; CODE XREF: sub_B47F+1CC
		ld	a, b
		dec	b
		cp	(hl)
		jp	c, loc_B5CC

		ld	a, (byte_D01C)
		or	a
		jr	z, loc_B69B

		jp	m, loc_B4A6

		bit	2, a
		jr	nz, loc_B6AD

		ld	e, a
		ld	a, c
		cp	(hl)
		jp	c, loc_B5CC

		jp	z, loc_B5CC

		bit	6, e
		jp	nz, loc_B4A6

		ld	a, d
		and	#CB ; 'Ћ'
		jr	nz, loc_B688

		ld	a, (byte_D01D)
		and	#C9 ; '…'
		jr	z, loc_B6A3


loc_B688:				; CODE XREF: sub_B47F+200
		bit	1, e
		jp	nz, loc_B4A6

		ld	a, (byte_D097)
		ld	d, a
		ld	a, (word_D00D+1)
		add	a, a
		cp	d
		jr	c, loc_B6A3

		jp	loc_B4A6

; ---------------------------------------------------------------------------

loc_B69B:				; CODE XREF: sub_B47F+1E6
		ld	a, c
		cp	(hl)
		jp	c, loc_B5CC

		jp	z, loc_B5CC


loc_B6A3:				; CODE XREF: sub_B47F+207
					; sub_B47F+217
		ld	(hl), c
		call	sub_B2F1

		call	sub_B309

		jp	loc_B5CC

; ---------------------------------------------------------------------------

loc_B6AD:				; CODE XREF: sub_B47F+1ED
		ld	a, c
		cp	(hl)
		jr	c, loc_B6B4

		jp	nz, loc_B4A6


loc_B6B4:				; CODE XREF: sub_B47F+230
		ld	a, (byte_D097)
		ld	d, a
		ld	a, (word_D00D+1)
		add	a, a
		cp	d
		jp	nc, loc_B4A6

		jp	loc_B5CC

; ---------------------------------------------------------------------------

loc_B6C3:				; CODE XREF: sub_B47F+265
		bit	3, (ix+2)
		jr	z, loc_B6D4

		jr	loc_B6E6

; ---------------------------------------------------------------------------

loc_B6CB:				; CODE XREF: sub_B47F+270
		ld	(ix+1),	#FF


loc_B6CF:				; CODE XREF: sub_B47F+29B
		call	sub_AF81

		pop	ix


loc_B6D4:				; CODE XREF: sub_B47F+140
					; sub_B47F+248
		ld	de, 3
		add	ix, de
		ld	a, (ix+0)
		inc	a
		ld	a, (byte_D03B)
		jp	z, loc_B4CE

		rra
		jr	nc, loc_B6C3


loc_B6E6:				; CODE XREF: sub_B47F+24A
		push	ix
		call	sub_AD40

		call	sub_BC00

		or	a
		jr	z, loc_B6CB

		ld	a, (byte_D019)
		and	#83 ; 'Г'
		jp	m, loc_B535

		sub	c
		ld	hl, (word_D06D)
		cp	(hl)
		jp	c, loc_B535

		ld	a, (ix+2)
		ld	d, a
		and	#C0 ; 'ј'
		jr	z, loc_B711

		bit	3, d
		jr	nz, loc_B71C

		bit	2, d
		jr	z, loc_B71C


loc_B711:				; CODE XREF: sub_B47F+288
		inc	l
		ld	a, (byte_D01A)
		add	a, a
		add	a, b
		jr	c, loc_B71C

		cp	(hl)
		jr	c, loc_B6CF


loc_B71C:				; CODE XREF: sub_B47F+28C
					; sub_B47F+290 ...
		ld	hl, byte_D03B
		set	1, (hl)
		jp	loc_B4A6

; ---------------------------------------------------------------------------

loc_B724:				; CODE XREF: sub_B47F+2C3
		ld	(ix+1),	#FF


loc_B728:				; CODE XREF: sub_B47F+2D0
					; sub_B47F+2D2 ...
		call	sub_AF81

		pop	ix


loc_B72D:				; CODE XREF: sub_B47F+13D
		ld	de, 3
		add	ix, de
		ld	a, (ix+0)
		inc	a
		jp	z, loc_B4D5

		push	ix
		call	sub_AD40

		call	sub_BC00

		or	a
		jr	z, loc_B724

		cpl
		ld	hl, (word_D06D)
		cp	(hl)
		jp	c, loc_B535

		inc	l
		ld	a, c
		cp	(hl)
		jr	c, loc_B728

		jr	z, loc_B728

		ld	(hl), a
		call	sub_B309

		jp	loc_B728

; END OF FUNCTION CHUNK	FOR sub_B47F

; =============== S U B	R O U T	I N E =======================================


sub_B75A:				; CODE XREF: sub_B47F-59
		ld	a, (byte_D097)
		ld	e, a
		ld	hl,  word_D088+1
		add	a, l
		ld	l, a
		ld	(word_D06D), hl
		ld	a, (byte_D0B1)
		cp	#C
		jr	z, loc_B796

		ld	a, e
		inc	a
		ld	hl, byte_D098
		sub	(hl)
		jr	c, loc_B78B

		ld	hl, byte_D01A
		ld	a, (word_D00D+1)
		add	a, (hl)
		bit	0, e
		jr	nz, loc_B781

		add	a, (hl)


loc_B781:				; CODE XREF: sub_B75A+24
		ld	(byte_D009), a
		ld	hl, loc_B7A1
		ld	(JP_ADDR), hl
		ret

; ---------------------------------------------------------------------------

loc_B78B:				; CODE XREF: sub_B75A+19
		ld	hl, loc_B7CA
		add	a, 2
		jr	nc, loc_B796

		ld	(JP_ADDR), hl
		ret

; ---------------------------------------------------------------------------

loc_B796:				; CODE XREF: sub_B75A+11 sub_B75A+36
		ld	hl, XOR_A
		ld	(JP_ADDR), hl
		ret

; End of function sub_B75A


; =============== S U B	R O U T	I N E =======================================


sub_B79D:				; CODE XREF: sub_AB53+86 sub_B47F-1F
		ld	hl, (JP_ADDR)
		jp	(hl)

; End of function sub_B79D

; ---------------------------------------------------------------------------

loc_B7A1:				; DATA XREF: sub_B75A+2A
		ld	a, (byte_D097)
		rra
		ld	hl, (word_D06D)
		jr	c, loc_B7F1

		ld	a, (byte_D009)
		sub	c
		jr	nc, loc_B7F1

		cp	(hl)
		jr	nc, loc_B7F1

		ld	a, (byte_D01D)
		ld	d, a
		ld	a, (byte_D01B)
		and	d
		scf
		ret	z
		and	#C
		cp	#C
		jr	z, loc_B7F1

		bit	2, a
		scf
		ret	nz
		jp	loc_B7F1

; ---------------------------------------------------------------------------

loc_B7CA:				; DATA XREF: sub_B75A:loc_B78B
		ld	hl, (word_D06D)
		ld	a, (byte_D03B)
		rla
		call	c, sub_B80F ;может выходить отсюда

		bit	2, (ix+2)
		jr	z, loc_B7E5

		ld	a, #17


loc_B7DC:				; CODE XREF: RAM:B805
		add	a, c


loc_B7DD:				; CODE XREF: RAM:B80C
		jr	c, loc_B7E5

		inc	l
		cp	(hl)
		jr	c, loc_B7E7

		jr	z, loc_B7E7


loc_B7E5:				; CODE XREF: RAM:B7D8	RAM:loc_B7DD ...
		xor	a
		ret

; ---------------------------------------------------------------------------

loc_B7E7:				; CODE XREF: RAM:B7E1	RAM:B7E3
		ld	a, (ix+2)
		and	#C9 ; '…'
		jr	nz, loc_B7E5

		ld	a, c
		or	a
		ret

; ---------------------------------------------------------------------------

loc_B7F1:				; CODE XREF: RAM:B7A8	RAM:B7AE ...
		ld	a, (byte_D03B)
		rla
		call	c, sub_B80F ;может выходить отсюда

		ld	a, (byte_D009)
		bit	2, (ix+2)
		jr	z, loc_B809

		bit	3, (ix+2)
		jr	z, loc_B7DC

		xor	a
		ret

; ---------------------------------------------------------------------------

loc_B809:				; CODE XREF: RAM:B7FF
		add	a, #F
		add	a, c
		jp	loc_B7DD


; =============== S U B	R O U T	I N E =======================================


sub_B80F:				; CODE XREF: RAM:B7D1	RAM:B7F5
		inc	l
		ld	a, c
		cp	(hl)
		dec	l
		ret	nc
		pop	hl
		or	a
		ret

; End of function sub_B80F

; ---------------------------------------------------------------------------

XOR_A:					; DATA XREF: sub_AB4C
					; sub_B75A:loc_B796
		xor	a
		ret

; ---------------------------------------------------------------------------

loc_B819:				; CODE XREF: sub_AFC5+8E
		ld	a, (byte_D098)
		ld	c, a
		or	a
		jp	p, loc_B841

		ld	b, 2
		ld	a, (byte_D0B1)
		cp	#C
		jp	z, loc_B8A0

		ld	b, #C
		dec	a
		jr	z, loc_B8A0

		ld	a, (byte_D0F2)
		and	#F
		cp	9
		ld	b, a
		jr	nc, loc_B8A0

		ld	hl, byte_D098
		inc	(hl)
		inc	(hl)
		jr	loc_B8A0

; ---------------------------------------------------------------------------

loc_B841:				; CODE XREF: RAM:B81E
		ld	a, (byte_D0B1)
		dec	a
		jr	z, loc_B877

		ld	a, (byte_D0F1)
		rra
		rra
		rra
		and	#1E
		jr	z, loc_B877

		inc	c
		cp	c
		ld	a, (byte_D0F2)
		ld	b, a
		jr	nc, loc_B8A0

		ld	hl, (INC_SECONDS)
		ld	de, (word_D02B)
		add	hl, de
		ld	a, h
		or	a
		jr	nz, loc_B877

		ld	a, (byte_D02A)
		srl	a
		srl	a
		cp	l
		jr	c, loc_B877

		ld	a, (byte_D02A)
		ld	(byte_D0F3), a
		jr	loc_B88A

; ---------------------------------------------------------------------------

loc_B877:				; CODE XREF: RAM:B845	RAM:B84F ...
		ld	a, (byte_D0B1)
		cp	#B
		jr	z, loc_B88A

		ld	a, (byte_D0B4)
		bit	5, a
		scf
		ret	z
		ld	hl, byte_D0B3 ;d3=swap board
		set	5, (hl)


loc_B88A:				; CODE XREF: RAM:B875	RAM:B87C
		ld	a, (byte_D0F2)
		push	af
		and	#F0 ; 'р'
		ld	b, a
		pop	af
		add	a, 7
		ld	(byte_D0F2), a
		and	#F0 ; 'р'
		cp	b
		jr	z, loc_B8AD

		ld	(byte_D0F2), a
		ld	b, a


loc_B8A0:				; CODE XREF: RAM:B828	RAM:B82E ...
		ld	hl, byte_D098
		ld	a, (hl)
		cp	8
		ld	a, #F
		jr	z, loc_B8AD

		inc	(hl)
		inc	(hl)
		ld	a, b


loc_B8AD:				; CODE XREF: RAM:B89A	RAM:B8A8
		call	sub_B943 ;берЄт [a] из таблицы по 3 байта и раскладывает в byte_D019..C

		or	a
		ret


; =============== S U B	R O U T	I N E =======================================


sub_B8B2:				; CODE XREF: sub_A915	sub_AFC5+82 ...
		ld	a, (byte_D0B1)
		add	a, a
		ld	hl, tbl_B8DD-2
		add	a, l
		ld	l, a
		jr	nc, loc_B8BE

		inc	h


loc_B8BE:				; CODE XREF: sub_B8B2+9
		ld	a, (hl)
		ld	(byte_D0F1), a
		inc	hl
		ld	a, (hl)
		ld	(byte_D0F4), a
		ld	e, a
		ld	d, 0
		ld	hl, 0
		ld	a, (byte_D049) ;move #
		dec	a
		jr	z, loc_B8D9

		ld	b, a
		sbc	hl, de


loc_B8D6:				; CODE XREF: sub_B8B2+25
		add	hl, de
		djnz	loc_B8D6

; End of function sub_B8B2


loc_B8D9:				; CODE XREF: sub_B8B2+1F
		ld	(word_D088), hl
		ret

; ---------------------------------------------------------------------------

		; no alignment
tbl_B8DD:	db  #0C, #02
		db  #11, #06
		db  #16, #0F
		db  #1A, #1E
		db  #1F, #2D
		db  #20, #3C
		db  #24, #6E
		db  #28, #AA
		db  #2C, #D2
		db  #16, #0F
		db  #4F, #FF
		db  #42, #FF
		db  #34, #F6
		db  #07, #97
		db  #27, #96
		db  #76, #86
		db  #47, #94
		db  #E6, #47
		db  #56, #C6
		db  #C6, #96
		db  #76, #56
		db  #E6, #47
		db  #35, #F6
		db  #66, #47
		db  #77, #16
		db  #27, #56
		db  #83, #33


		; no alignment
tbl_B913:	db  #00, #85, #00
		db  #02, #85, #00
		db  #41, #85, #03
		db  #42, #85, #03
		db  #42, #8D, #03
		db  #42, #85, #01
		db  #43, #8D, #01
		db  #84, #89, #01
		db  #83, #8D, #40
		db  #83, #89, #40
		db  #94, #89, #40
		db  #93, #89, #07
		db  #94, #C9, #07
		db  #A5, #C9, #07
		db  #A5, #C9, #80
		db  #A6, #C9, #80

; =============== S U B	R O U T	I N E =======================================


sub_B943:				; CODE XREF: RAM:loc_B8AD
;a=?
		and	#F
		ld	hl, tbl_B913
		ld	c, a
		add	a, a ;*2
		add	a, c ;*3
		add	a, l
		ld	l, a
		jr	nc, loc_B950
		inc	h
loc_B950:				; CODE XREF: sub_B943+A
		ld	a, (hl)
		ld	c, a
		and	#F
		ld	(byte_D01A), a
		ld	a, c
		rra
		rra
		rra
		rra
		and	#F
		ld	(byte_D019), a
		inc	hl
		ld	a, (hl)
		ld	(byte_D01B), a
		inc	hl
		ld	a, (hl)
		ld	(byte_D01C), a
		or	a
		ret

; End of function sub_B943


; =============== S U B	R O U T	I N E =======================================


sub_B96D:				; CODE XREF: sub_B47F+10
		ld	a, (byte_D097)
		add	a, a
		ld	hl,  word_D240+1
		add	a, l
		ld	l, a

; End of function sub_B96D


; =============== S U B	R O U T	I N E =======================================


sub_B976:				; CODE XREF: sub_8C20-B13
		ld	e, l
		ld	b, #B


loc_B979:				; CODE XREF: sub_B976+1B
		bit	7, (hl)
		jr	nz, loc_B994

		dec	l
		ld	a, (hl)
		and	#77 ; 'w'
		or	#80 ; 'А'
		ld	(hl), a
		dec	l
		dec	b
		bit	7, (hl)
		jr	nz, loc_B994

		dec	l
		ld	a, (hl)
		and	#77 ; 'w'
		ld	(hl), a
		dec	l
		dec	b
		jp	p, loc_B979


loc_B994:				; CODE XREF: sub_B976+5 sub_B976+12
		ld	a, #C
		sub	b
		cp	5
		ret	c
		ld	d, a


loc_B99B:				; CODE XREF: sub_B976+58 sub_B976+74 ...
		ld	l, e
		scf


loc_B99D:				; CODE XREF: sub_B976+33
		ld	b, d
		dec	d
		ret	z
		ld	c, (hl)
		dec	l
		ld	a, (hl)
		dec	l
		bit	3, a
		jr	z, loc_B9AD

		rla
		jp	c, loc_B99D

		ret

; ---------------------------------------------------------------------------

loc_B9AD:				; CODE XREF: sub_B976+30
		ld	e, l
		sra	b
		push	de
		and	#77 ; 'w'
		ld	e, a
		ld	a, c
		and	#77 ; 'w'
		ld	c, a
		ld	d, 0


loc_B9BA:				; CODE XREF: sub_B976+52 sub_B976+71
		dec	l
		set	7, (hl)
		dec	l
		ld	a, (hl)
		dec	l
		and	#77 ; 'w'
		cp	e
		jr	z, loc_B9D1

		set	7, (hl)


loc_B9C7:				; CODE XREF: sub_B976+66
		dec	l
		djnz	loc_B9BA

		scf
		dec	d
		pop	de
		ret	m
		jp	loc_B99B

; ---------------------------------------------------------------------------

loc_B9D1:				; CODE XREF: sub_B976+4D
		set	3, (hl)
		ld	a, (hl)
		and	#77 ; 'w'
		cp	c
		jr	z, loc_B9F7

		set	7, (hl)
		ld	e, a
		jp	loc_B9C7

; ---------------------------------------------------------------------------

loc_B9DF:				; CODE XREF: sub_B976+7F
		ld	a, (hl)
		or	#88 ; 'И'
		ld	(hl), a
		and	#77 ; 'w'
		ld	e, a
		dec	l
		djnz	loc_B9BA

		pop	de
		jp	loc_B99B

; ---------------------------------------------------------------------------

loc_B9ED:				; CODE XREF: sub_B976+82
		inc	d
		dec	l
		dec	l
		ld	a, (hl)
		and	#77 ; 'w'
		dec	l
		cp	c
		jr	z, loc_B9DF


loc_B9F7:				; CODE XREF: sub_B976+61
		dec	l
		djnz	loc_B9ED

		pop	de
		jp	loc_B99B

; End of function sub_B976

; ---------------------------------------------------------------------------
		db    0	;unused?
		db    0 ;unused?


        align 256
		;must be 256-aligned ;какие-то константы дл€ оценки позиции?
tbl_BA00:	db    0,   1,   1,  #D,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    9,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    9,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    9,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		db    5,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1,   3,   1,   1,   1
		;must be after tbl_BA00
tbl_BB00:	db    0,   0,   1,   0,   0,   4,   5,   6,   4,   8,   9,  #A,   8,  #C,  #D,  #E
		db    0, #10, #11, #12, #10, #14, #15, #16, #14, #18, #19, #1A, #18, #1C, #1D, #1E
		db  #10, #20, #21, #22, #20, #24, #25, #26, #24, #28, #29, #2A, #28, #2C, #2D, #2E
		db  #20, #30, #31, #32, #30, #34, #35, #36, #34, #38, #39, #3A, #38, #3C, #3D, #3E
		db    0, #40, #41, #42, #40, #44, #45, #46, #44, #48, #49, #4A, #48, #4C, #4D, #4E
		db  #40, #50, #51, #52, #50, #54, #55, #56, #54, #58, #59, #5A, #58, #5C, #5D, #5E
		db  #50, #60, #61, #62, #60, #64, #65, #66, #64, #68, #69, #6A, #68, #6C, #6D, #6E
		db  #60, #70, #71, #72, #70, #74, #75, #76, #74, #78, #79, #7A, #78, #7C, #7D, #7E
		db  #40, #80, #81, #82, #80, #84, #85, #86, #84, #88, #89, #8A, #88, #8C, #8D, #8E
		db  #80, #90, #91, #92, #90, #94, #95, #96, #94, #98, #99, #9A, #98, #9C, #9D, #9E
		db  #90, #A0, #A1, #A2, #A0, #A4, #A5, #A6, #A4, #A8, #A9, #AA, #A8, #AC, #AD, #AE
		db  #A0, #B0, #B1, #B2, #B0, #B4, #B5, #B6, #B4, #B8, #B9, #BA, #B8, #BC, #BD, #BE
		db  #80, #C0, #C1, #C2, #C0, #C4, #C5, #C6, #C4, #C8, #C9, #CA, #C8, #CC, #CD, #CE
		db  #C0, #D0, #D1, #D2, #D0, #D4, #D5, #D6, #D4, #D8, #D9, #DA, #D8, #DC, #DD, #DE
		db  #D0, #E0, #E1, #E2, #E0, #E4, #E5, #E6, #E4, #E8, #E9, #EA, #E8, #EC, #ED, #EE
		db  #E0, #F0, #F1, #F2, #F0, #F4, #F5, #F6, #F4, #F8, #F9, #FA, #F8, #FC, #FD, #FE

; =============== S U B	R O U T	I N E =======================================


sub_BC00:				; CODE XREF: sub_8C20-9FD
					; sub_8C20-77C ...

; FUNCTION CHUNK AT C0A0 SIZE 000000AA BYTES

		call	sub_8F4D

		ld	(word_D03D), sp
		xor	a
		ld	e, a
		ex	af, af' ;'
		ld	h, BRD_88_0/256
		exx
		ld	h, word_D100/256
		ld	a, (byte_D02D)
		rrca
		ld	iy, loc_C313
		bit	1, a
		jr	z, loc_BC27

		ld	iy, loc_C303
		bit	2, a
		jr	z, loc_BC27

		ld	iy, loc_C2A6


loc_BC27:				; CODE XREF: sub_BC00+19 sub_BC00+21
		add	a, #80 ; 'А'
		ld	b, a
		exx
		jp	c, loc_C0AE


loc_BC2E:				; CODE XREF: sub_BC00+547
		ld	d, #88 ; 'И'
		ld	a, (byte_D188)
		or	a
		call	p, sub_C48D

		ld	a, (byte_D190)
		or	a
		call	p, sub_C498

		ld	a, (byte_D198)
		or	a
		call	p, sub_C498

		ld	a, (byte_D1A0)
		or	a
		call	p, sub_C5CF

		ld	a, (byte_D1A8)
		or	a
		call	p, sub_C5CF

		ld	a, (byte_D1B0)
		or	a
		call	p, sub_C505

		ld	a, (byte_D1B8)
		or	a
		call	p, sub_C505

		ld	d, #F1	; 'с'
		ld	b, array_D200/256
		ld	hl, (word_D1C0)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (word_D1C8)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (word_D1D0)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (word_D1D8)
		bit	7, l
		call	z, sub_C2EA

		ld	hl, (word_D1E0)
		bit	7, l
		call	z, sub_C2EA

		ld	hl, (word_D1E8)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (word_D1F0)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (word_D1F8)
		bit	7, l
		call	z, sub_C2F2

		call	sub_C06D

		exx
		bit	4, b
		jp	z, loc_C0A0


loc_BCAE:				; CODE XREF: sub_BC00+541
		bit	6, b
		jr	nz, loc_BCC1

		ld	l, (ix+1)
		res	7, l
		dec	h
		ld	l, (hl)
		inc	h
		bit	2, l
		jr	z, loc_BCC1

		inc	l
		set	1, (hl)


loc_BCC1:				; CODE XREF: sub_BC00+B0 sub_BC00+BC
		bit	3, b
		jp	z, loc_BCD2

		exx
		ld	a, (byte_D04C)
		or	a
		jr	nz, loc_BCCF

		sra	e


loc_BCCF:				; CODE XREF: sub_BC00+CB
		sra	e
		exx


loc_BCD2:				; CODE XREF: sub_BC00+C3
		bit	5, b
		exx
		call	nz, sub_C6C4

		ex	af, af' ;'
		sra	a
		sra	a
		add	a, e
		ld	e, a
		ld	hl, 0
		ld	(word_D039), hl
		ld	hl, (word_D18A)
		ld	a, h
		or	l
		jr	z, loc_BCF8

		ld	bc, (word_D18C)
		ld	a, 9
		call	sub_C3A3

		ld	(word_D18A), hl


loc_BCF8:				; CODE XREF: sub_BC00+EA
		ld	(word_D18C), hl
		ld	hl, (word_D192)
		ld	a, h
		or	l
		jr	z, loc_BD0E

		ld	bc, (word_D194)
		ld	a, 5
		call	sub_C3A3

		ld	(word_D192), hl


loc_BD0E:				; CODE XREF: sub_BC00+100
		ld	(word_D194), hl
		ld	hl, (word_D19A)
		ld	a, h
		or	l
		jr	z, loc_BD24

		ld	bc, (word_D19C)
		ld	a, 5
		call	sub_C3A3

		ld	(word_D19A), hl


loc_BD24:				; CODE XREF: sub_BC00+116
		ld	(word_D19C), hl
		ld	hl, (word_D1A2)
		ld	a, h
		or	l
		jr	z, loc_BD3A

		ld	bc, (word_D1A4)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D1A2), hl


loc_BD3A:				; CODE XREF: sub_BC00+12C
		ld	(word_D1A4), hl
		ld	hl, (word_D1AA)
		ld	a, h
		or	l
		jr	z, loc_BD50

		ld	bc, (word_D1AC)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D1AA), hl


loc_BD50:				; CODE XREF: sub_BC00+142
		ld	(word_D1AC), hl
		ld	hl, (word_D1B2)
		ld	a, h
		or	l
		jr	z, loc_BD66

		ld	bc, (word_D1B4)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D1B2), hl


loc_BD66:				; CODE XREF: sub_BC00+158
		ld	(word_D1B4), hl
		ld	hl, (word_D1BA)
		ld	a, h
		or	l
		jr	z, loc_BD7C

		ld	bc, (word_D1BC)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D1BA), hl


loc_BD7C:				; CODE XREF: sub_BC00+16E
		ld	(word_D1BC), hl
		ld	hl, (word_D1C2)
		ld	a, h
		or	l
		jr	z, loc_BD93

		ld	bc, (word_D1C4)
		ld	a, (word_D1C0+1)
		call	sub_C3A1

		ld	(word_D1C2), hl


loc_BD93:				; CODE XREF: sub_BC00+184
		ld	(word_D1C4), hl
		ld	hl, (word_D1CA)
		ld	a, h
		or	l
		jr	z, loc_BDAA

		ld	bc, (word_D1CC)
		ld	a, (word_D1C8+1)
		call	sub_C3A1

		ld	(word_D1CA), hl


loc_BDAA:				; CODE XREF: sub_BC00+19B
		ld	(word_D1CC), hl
		ld	hl, (word_D1D2)
		ld	a, h
		or	l
		jr	z, loc_BDC1

		ld	bc, (word_D1D4)
		ld	a, (word_D1D0+1)
		call	sub_C3A1

		ld	(word_D1D2), hl


loc_BDC1:				; CODE XREF: sub_BC00+1B2
		ld	(word_D1D4), hl
		ld	hl, (word_D1DA)
		ld	a, h
		or	l
		jr	z, loc_BDD8

		ld	bc, (word_D1DC)
		ld	a, (word_D1D8+1)
		call	sub_C3A1

		ld	(word_D1DA), hl


loc_BDD8:				; CODE XREF: sub_BC00+1C9
		ld	(word_D1DC), hl
		ld	hl, (word_D1E2)
		ld	a, h
		or	l
		jr	z, loc_BDEF

		ld	bc, (word_D1E4)
		ld	a, (word_D1E0+1)
		call	sub_C3A1

		ld	(word_D1E2), hl


loc_BDEF:				; CODE XREF: sub_BC00+1E0
		ld	(word_D1E4), hl
		ld	hl, (word_D1EA)
		ld	a, h
		or	l
		jr	z, loc_BE06

		ld	bc, (word_D1EC)
		ld	a, (word_D1E8+1)
		call	sub_C3A1

		ld	(word_D1EA), hl


loc_BE06:				; CODE XREF: sub_BC00+1F7
		ld	(word_D1EC), hl
		ld	hl, (word_D1F2)
		ld	a, h
		or	l
		jr	z, loc_BE1D

		ld	bc, (word_D1F4)
		ld	a, (word_D1F0+1)
		call	sub_C3A1

		ld	(word_D1F2), hl


loc_BE1D:				; CODE XREF: sub_BC00+20E
		ld	(word_D1F4), hl
		ld	hl, (word_D1FA)
		ld	a, h
		or	l
		jr	z, loc_BE34

		ld	bc, (word_D1FC)
		ld	a, (word_D1F8+1)
		call	sub_C3A1

		ld	(word_D1FA), hl


loc_BE34:				; CODE XREF: sub_BC00+225
		ld	(word_D1FC), hl
		xor	a
		sub	e
		ld	e, a
		ld	hl, (word_D039)
		push	hl
		ld	hl, 0
		ld	(word_D039), hl
		ld	hl, (word_D10A)
		ld	a, h
		or	l
		jr	z, loc_BE57

		ld	bc, (word_D10C)
		ld	a, 9
		call	sub_C3A3

		ld	(word_D10A), hl


loc_BE57:				; CODE XREF: sub_BC00+249
		ld	(word_D10C), hl
		ld	hl, (word_D112)
		ld	a, h
		or	l
		jr	z, loc_BE6D

		ld	bc, (word_D114)
		ld	a, 5
		call	sub_C3A3

		ld	(word_D112), hl


loc_BE6D:				; CODE XREF: sub_BC00+25F
		ld	(word_D114), hl
		ld	hl, (word_D11A)
		ld	a, h
		or	l
		jr	z, loc_BE83

		ld	bc, (word_D11C)
		ld	a, 5
		call	sub_C3A3

		ld	(word_D11A), hl


loc_BE83:				; CODE XREF: sub_BC00+275
		ld	(word_D11C), hl
		ld	hl, (word_D122)
		ld	a, h
		or	l
		jr	z, loc_BE99

		ld	bc, (word_D124)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D122), hl


loc_BE99:				; CODE XREF: sub_BC00+28B
		ld	(word_D124), hl
		ld	hl, (word_D12A)
		ld	a, h
		or	l
		jr	z, loc_BEAF

		ld	bc, (word_D12C)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D12A), hl


loc_BEAF:				; CODE XREF: sub_BC00+2A1
		ld	(word_D12C), hl
		ld	hl, (word_D132)
		ld	a, h
		or	l
		jr	z, loc_BEC5

		ld	bc, (word_D134)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D132), hl


loc_BEC5:				; CODE XREF: sub_BC00+2B7
		ld	(word_D134), hl
		ld	hl, (word_D13A)
		ld	a, h
		or	l
		jr	z, loc_BEDB

		ld	bc, (word_D13C)
		ld	a, 3
		call	sub_C3A3

		ld	(word_D13A), hl


loc_BEDB:				; CODE XREF: sub_BC00+2CD
		ld	(word_D13C), hl
		ld	hl, (word_D142)
		ld	a, h
		or	l
		jr	z, loc_BEF2

		ld	bc, (word_D144)
		ld	a, (byte_D141)
		call	sub_C3A1

		ld	(word_D142), hl


loc_BEF2:				; CODE XREF: sub_BC00+2E3
		ld	(word_D144), hl
		ld	hl, (word_D14A)
		ld	a, h
		or	l
		jr	z, loc_BF09

		ld	bc, (word_D14C)
		ld	a, (byte_D149)
		call	sub_C3A1

		ld	(word_D14A), hl


loc_BF09:				; CODE XREF: sub_BC00+2FA
		ld	(word_D14C), hl
		ld	hl, (word_D152)
		ld	a, h
		or	l
		jr	z, loc_BF20

		ld	bc, (word_D154)
		ld	a, (byte_D151)
		call	sub_C3A1

		ld	(word_D152), hl


loc_BF20:				; CODE XREF: sub_BC00+311
		ld	(word_D154), hl
		ld	hl, (word_D15A)
		ld	a, h
		or	l
		jr	z, loc_BF37

		ld	bc, (word_D15C)
		ld	a, (byte_D159)
		call	sub_C3A1

		ld	(word_D15A), hl


loc_BF37:				; CODE XREF: sub_BC00+328
		ld	(word_D15C), hl
		ld	hl, (word_D162)
		ld	a, h
		or	l
		jr	z, loc_BF4E

		ld	bc, (word_D164)
		ld	a, (byte_D161)
		call	sub_C3A1

		ld	(word_D162), hl


loc_BF4E:				; CODE XREF: sub_BC00+33F
		ld	(word_D164), hl
		ld	hl, (word_D16A)
		ld	a, h
		or	l
		jr	z, loc_BF65

		ld	bc, (word_D16C)
		ld	a, (byte_D169)
		call	sub_C3A1

		ld	(word_D16A), hl


loc_BF65:				; CODE XREF: sub_BC00+356
		ld	(word_D16C), hl
		ld	hl, (word_D172)
		ld	a, h
		or	l
		jr	z, loc_BF7C

		ld	bc, (word_D174)
		ld	a, (byte_D171)
		call	sub_C3A1

		ld	(word_D172), hl


loc_BF7C:				; CODE XREF: sub_BC00+36D
		ld	(word_D174), hl
		ld	hl, (word_D17A)
		ld	a, h
		or	l
		jr	z, loc_BF93

		ld	bc, (word_D17C)
		ld	a, (byte_D179)
		call	sub_C3A1

		ld	(word_D17A), hl


loc_BF93:				; CODE XREF: sub_BC00+384
		ld	(word_D17C), hl
		ld	b, e
		pop	de
		ld	hl, (word_D039)
		ld	a, (byte_D02D)
		rra
		jr	nc, loc_BFAB

		xor	a
		sub	b
		ld	b, a
		ex	de, hl
		ld	a, (word_D00D)
		jp	loc_BFB0

; ---------------------------------------------------------------------------

loc_BFAB:				; CODE XREF: sub_BC00+39F
		ld	a, (word_D00D)
		neg


loc_BFB0:				; CODE XREF: sub_BC00+3A8
		sub	l
		add	a, a
		dec	l
		jp	m, loc_BFD4

		set	1, (ix+2)
		ex	af, af' ;'
		ld	a, l
		inc	a
		sub	e
		jp	m, loc_BFCC

		ld	a, (byte_D07A)
		sub	2
		push	hl
		ld	l, a
		ld	h, word_D100/256
		ld	a, (hl)
		pop	hl


loc_BFCC:				; CODE XREF: sub_BC00+3BE
		ld	(byte_D07A), a
		ex	af, af' ;'
		jr	z, loc_BFD3

		dec	a


loc_BFD3:				; CODE XREF: sub_BC00+3D0
		sub	h


loc_BFD4:				; CODE XREF: sub_BC00+3B3
		inc	l
		dec	e
		jp	m, loc_C002

		ex	af, af' ;'
		ld	a, (byte_D01D)
		bit	1, a
		jr	nz, loc_BFE5

		set	6, (ix+2)


loc_BFE5:				; CODE XREF: sub_BC00+3DF
		bit	2, (ix+2)
		jr	nz, loc_C001

		inc	b
		inc	b
		dec	d
		jp	m, loc_C001

		and	#C9 ; '…'
		jr	z, loc_BFF9

		set	6, (ix+2)


loc_BFF9:				; CODE XREF: sub_BC00+3F3
		inc	b
		inc	b
		dec	d
		jp	m, loc_C001

		inc	b
		inc	b


loc_C001:				; CODE XREF: sub_BC00+3E9
					; sub_BC00+3EE ...
		ex	af, af' ;'


loc_C002:				; CODE XREF: sub_BC00+3D6
		cp	#18
		jr	c, loc_C016

		cp	#E9 ; 'й'
		jp	nc, loc_C016

		rla
		ld	a, 3
		ld	b, a
		ld	c, a
		ret	c
		ld	a, #FC	; 'ь'
		ld	b, a
		ld	c, a
		ret

; ---------------------------------------------------------------------------

loc_C016:				; CODE XREF: sub_BC00+404
					; sub_BC00+408
		add	a, a
		add	a, a
		ld	c, a
		ld	a, b
		sra	a
		cp	#22 ; '"'
		jr	c, loc_C02B

		cp	#DF ; 'я'
		jr	nc, loc_C02B

		rla
		ld	a, #21 ; '!'
		jr	nc, loc_C02B

		ld	a, #DF	; 'я'


loc_C02B:				; CODE XREF: sub_BC00+41E
					; sub_BC00+422 ...
		add	a, c
		add	a, #80 ; 'А'
		ld	c, a
		ld	b, a
		ld	a, (byte_D03B)
		rla
		jr	c, loc_C049


loc_C036:				; CODE XREF: sub_BC00+459
		ld	a, c
		bit	6, (ix+2)
		ret	z
		inc	e
		ret	z
		rlc	e
		rl	e
		add	a, e
		ld	b, a
		ld	a, c
		ret	nc
		ld	b, #FE	; 'ю'
		ret

; ---------------------------------------------------------------------------

loc_C049:				; CODE XREF: sub_BC00+434
		rla
		ld	a, (byte_D02D)
		jr	c, loc_C062

		rra
		ld	a, (byte_D01E)
		jr	nc, loc_C056

		cpl


loc_C056:				; CODE XREF: sub_BC00+453
		adc	a, #80 ; 'А'
		cp	c
		jr	nc, loc_C036


loc_C05B:				; CODE XREF: sub_BC00+46B
		ld	c, a
		ld	b, a
		res	6, (ix+2)
		ret

; ---------------------------------------------------------------------------

loc_C062:				; CODE XREF: sub_BC00+44D
		rra
		ld	a, (byte_D01E)
		jr	nc, loc_C069

		cpl


loc_C069:				; CODE XREF: sub_BC00+466
		adc	a, #80 ; 'А'
		jr	loc_C05B

; End of function sub_BC00


; =============== S U B	R O U T	I N E =======================================


sub_C06D:				; CODE XREF: sub_BC00+A5
					; sub_BC00+525
		ld	hl, array_D200
		xor	a
		ld	c, a


loc_C072:				; CODE XREF: sub_C06D+7 sub_C06D+27	...
		inc	l
		or	(hl)
		jr	z, loc_C072

		ret	m
		ld	(hl), c


loc_C078:				; CODE XREF: sub_C06D+12
		dec	a
		jp	z, loc_C082

		dec	e
		dec	e
		dec	e
		jp	loc_C078

; ---------------------------------------------------------------------------

loc_C082:				; CODE XREF: sub_C06D+C
		inc	l
		or	(hl)
		jr	z, loc_C09A

		ret	m


loc_C087:				; CODE XREF: sub_C06D+29
		ld	(hl), c


loc_C088:				; CODE XREF: sub_C06D+22
		dec	a
		jp	z, loc_C092

		dec	e
		dec	e
		dec	e
		jp	loc_C088

; ---------------------------------------------------------------------------

loc_C092:				; CODE XREF: sub_C06D+1C
		inc	l
		or	(hl)
		jr	z, loc_C072

		jp	p, loc_C087

		ret

; ---------------------------------------------------------------------------

loc_C09A:				; CODE XREF: sub_C06D+17
		dec	e
		dec	e
		dec	e
		jp	loc_C072

; End of function sub_C06D

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_BC00

loc_C0A0:				; CODE XREF: sub_BC00+AB
		ld	a, #90 ; 'Р'
		add	a, b
		ld	b, a
		exx
		xor	a
		sub	e
		ld	e, a
		ld	h, BRD_88_0/256
		ex	af, af' ;'
		neg
		ex	af, af' ;'


loc_C0AE:				; CODE XREF: sub_BC00+2B
		ld	a, (byte_D108)
		ld	d, #88 ; 'И'
		or	a
		call	p, sub_C48D

		ld	a, (byte_D110)
		or	a
		call	p, sub_C498

		ld	a, (byte_D118)
		or	a
		call	p, sub_C498

		ld	a, (byte_D120)
		or	a
		call	p, sub_C5C4

		ld	a, (byte_D128)
		or	a
		call	p, sub_C5C4

		ld	a, (byte_D130)
		or	a
		call	p, sub_C512

		ld	a, (byte_D138)
		or	a
		call	p, sub_C512

		ld	d, #11
		ld	b, array_D200/256
		ld	hl, (unk_D140)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (unk_D148)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (unk_D150)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (unk_D158)
		bit	7, l
		call	z, sub_C2EA

		ld	hl, (unk_D160)
		bit	7, l
		call	z, sub_C2EA

		ld	hl, (unk_D168)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (unk_D170)
		bit	7, l
		call	z, sub_C2F2

		ld	hl, (unk_D178)
		bit	7, l
		call	z, sub_C2F2

		call	sub_C06D

		ld	hl, (word_D100)
		call	sub_C1EF

		ex	af, af' ;'
		neg
		ex	af, af' ;'
		xor	a
		sub	e
		ld	e, a
		ld	hl, (word_D180)
		exx
		set	7, b
		call	sub_C1F4

		exx
		bit	4, b
		jp	nz, loc_BCAE

		set	4, b
		exx
		jp	loc_BC2E

; END OF FUNCTION CHUNK	FOR sub_BC00
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C1F4

loc_C14A:				; CODE XREF: sub_C1F4-1B
		or	a
		jp	nz, loc_C1E6

		ld	a, d
		or	a
		jr	nz, loc_C155

		sub	#A
		ld	d, a


loc_C155:				; CODE XREF: sub_C1F4-A4
		ld	a, 7
		and	l
		inc	a
		rra
		cp	2
		jr	z, loc_C169

		ld	a, #70 ; 'p'
		and	l
		cp	#30 ; '0'
		jr	z, loc_C169

		cp	#40 ; '@'
		jr	nz, loc_C16F


loc_C169:				; CODE XREF: sub_C1F4-98 sub_C1F4-91
		ex	af, af' ;'
		add	a, #10
		jp	loc_C1E7

; ---------------------------------------------------------------------------

loc_C16F:				; CODE XREF: sub_C1F4-8D
		ld	a, 7
		and	l
		cp	2
		jr	z, loc_C185

		cp	5
		jr	z, loc_C185

		ld	a, #70 ; 'p'
		and	l
		cp	#20 ; ' '
		jr	z, loc_C185

		cp	#50 ; 'P'
		jr	nz, loc_C1E6


loc_C185:				; CODE XREF: sub_C1F4-80 sub_C1F4-7C ...
		ex	af, af' ;'
		add	a, 8
		jp	loc_C1E7

; END OF FUNCTION CHUNK	FOR sub_C1F4
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C1EF

loc_C18B:				; CODE XREF: sub_C1EF+3
		ld	a, (byte_D049) ;move #
		cpl
		add	a, #B
		exx
		ld	c, a
		ld	a, (byte_D189)
		bit	4, a
		jr	z, loc_C1A4

		ld	a, (byte_D188)
		or	a
		jp	m, loc_C1A4

		ld	a, e
		add	a, c
		ld	e, a


loc_C1A4:				; CODE XREF: sub_C1EF-57 sub_C1EF-51
		ld	a, (byte_D109)
		bit	4, a
		jr	z, loc_C1B5

		ld	a, (byte_D108)
		or	a
		jp	m, loc_C1B5

		ld	a, e
		sub	c
		ld	e, a


loc_C1B5:				; CODE XREF: sub_C1EF-46 sub_C1EF-40
		exx
		jp	sub_C1F4

; END OF FUNCTION CHUNK	FOR sub_C1EF
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C1F4

loc_C1B9:				; CODE XREF: sub_C1F4+4
		bit	3, a
		jr	nz, loc_C1C5

		ld	h, BRD_88_0/256
		ld	b, l
		ld	c, 8
		jp	loc_C21E

; ---------------------------------------------------------------------------

loc_C1C5:				; CODE XREF: sub_C1F4-39
		ld	b, a
		ld	c, 4
		ld	a, #C0	; 'ј'
		and	h
		rra
		rra
		rra
		ld	d, a
		ld	a, (byte_D01E)
		or	a
		jr	z, loc_C1DC

		xor	b
		ld	a, (byte_D04C)
		jp	p, loc_C14A


loc_C1DC:				; CODE XREF: sub_C1F4-21
		rr	d
		or	a
		jr	nz, loc_C1E6

		ld	a, #C0	; 'ј'
		and	h
		jr	nz, loc_C185


loc_C1E6:				; CODE XREF: sub_C1F4-A9 sub_C1F4-71 ...
		ex	af, af' ;'


loc_C1E7:				; CODE XREF: sub_C1F4-88 sub_C1F4-6C
		add	a, d
		ex	af, af' ;'
		ld	h, BRD_88_0/256
		ld	b, l
		jp	loc_C21E

; END OF FUNCTION CHUNK	FOR sub_C1F4

; =============== S U B	R O U T	I N E =======================================


sub_C1EF:				; CODE XREF: sub_BC00+52B

; FUNCTION CHUNK AT C18B SIZE 0000002E BYTES

		exx
		bit	0, b
		jr	z, loc_C18B

; End of function sub_C1EF


; =============== S U B	R O U T	I N E =======================================


sub_C1F4:				; CODE XREF: sub_BC00+53B
					; sub_C1EF-39

; FUNCTION CHUNK AT C14A SIZE 00000041 BYTES
; FUNCTION CHUNK AT C1B9 SIZE 00000036 BYTES
; FUNCTION CHUNK AT C26D SIZE 0000001F BYTES
; FUNCTION CHUNK AT C28F SIZE 00000006 BYTES
; FUNCTION CHUNK AT C298 SIZE 0000000E BYTES

		ld	a, b
		exx
		bit	2, a
		jr	nz, loc_C1B9

		bit	5, h
		jp	z, loc_C27F

		ld	a, #C0	; 'ј'
		and	h
		jr	nz, loc_C26D

		ld	c, #C
		ld	b, l
		ld	h, BRD_88_0/256
		ld	a, #1F
		add	a, b
		jp	p, loc_C211

		sub	#40 ; '@'


loc_C211:				; CODE XREF: sub_C1F4+18
		ld	l, a
		ld	a, (hl)
		inc	l
		or	(hl)
		inc	l
		or	(hl)
		bit	6, a
		jr	nz, loc_C21D

		dec	e
		dec	e


loc_C21D:				; CODE XREF: sub_C1F4+25
		ld	l, b


loc_C21E:				; CODE XREF: sub_C1F4-32 sub_C1F4-8	...
		dec	l
		xor	a
		or	(hl)
		call	nz, sub_C254

		inc	l
		inc	l
		or	(hl)
		call	nz, sub_C254

		ld	a, #10
		add	a, b
		jp	m, loc_C241

		ld	l, a
		xor	a
		or	(hl)
		call	nz, sub_C254

		inc	l
		or	(hl)
		call	nz, sub_C254

		dec	l
		dec	l
		or	(hl)
		call	nz, sub_C254


loc_C241:				; CODE XREF: sub_C1F4+39
		ld	a, #F0	; 'р'
		add	a, b
		ret	m
		ld	l, a
		xor	a
		or	(hl)
		call	nz, sub_C254

		inc	l
		or	(hl)
		call	nz, sub_C254

		dec	l
		dec	l
		or	(hl)
		ret	z

; End of function sub_C1F4


; =============== S U B	R O U T	I N E =======================================


sub_C254:				; CODE XREF: sub_C1F4+2D sub_C1F4+33 ...

; FUNCTION CHUNK AT C471 SIZE 0000001C BYTES

		exx
		ld	l, a
		inc	l
		xor	b
		jp	p, loc_C263

		ld	a, #78 ; 'x'
		and	l
		jp	z, loc_C471

		dec	l
		dec	l


loc_C263:				; CODE XREF: sub_C254+4
		inc	(hl)
		xor	a
		bit	6, l
		exx
		ret	z
		ex	af, af' ;'
		add	a, c
		ex	af, af' ;'
		ret

; End of function sub_C254

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C1F4

loc_C26D:				; CODE XREF: sub_C1F4+E sub_C1F4+AA
		ld	c, 4
		bit	7, h
		jp	z, loc_C276

		dec	e
		dec	e


loc_C276:				; CODE XREF: sub_C1F4+7D
		dec	e
		dec	e
		dec	e
		ld	b, l
		ld	h, BRD_88_0/256
		jp	loc_C21E

; ---------------------------------------------------------------------------

loc_C27F:				; CODE XREF: sub_C1F4+8
		bit	4, h
		jr	nz, loc_C28F

		ld	h, BRD_88_0/256
		ld	b, l
		ld	c, 0
		inc	e
		jp	loc_C21E

; END OF FUNCTION CHUNK	FOR sub_C1F4
; ---------------------------------------------------------------------------
		rra			; dead code???
		jr	nc, loc_C295

; START	OF FUNCTION CHUNK FOR sub_C1F4

loc_C28F:				; CODE XREF: sub_C1F4+8D
		ld	a, e
		sub	#C
		jp	loc_C298	;  jr???

; END OF FUNCTION CHUNK	FOR sub_C1F4
; ---------------------------------------------------------------------------

loc_C295:				; CODE XREF: RAM:C28D
		ld	a, e
		sub	8

; START	OF FUNCTION CHUNK FOR sub_C1F4

loc_C298:				; CODE XREF: sub_C1F4+9E
		ld	e, a
		ld	c, 8
		ld	a, #C0	; 'ј'
		and	h
		jr	nz, loc_C26D

		ld	h, BRD_88_0/256
		ld	b, l
		jp	loc_C21E

; END OF FUNCTION CHUNK	FOR sub_C1F4
; ---------------------------------------------------------------------------

loc_C2A6:				; DATA XREF: sub_BC00+23
		srl	h
		srl	h
		ex	af, af' ;'
		add	a, h
		ex	af, af' ;'
		bit	5, h
		jp	z, loc_C313

; START	OF FUNCTION CHUNK FOR sub_C2F2

loc_C2B2:				; CODE XREF: sub_C2F2+1E
		ld	h, BRD_88_0/256
		dec	l
		ld	a, (hl)
		inc	l
		or	a
		jp	nz, loc_C315

		set	6, (ix+2)
		set	0, (ix+2)
		ex	af, af' ;'
		exx
		bit	4, b
		exx
		jr	nz, loc_C2CC

		add	a, #16


loc_C2CC:				; CODE XREF: sub_C2F2-2A
		add	a, #E
		ex	af, af' ;'
		jp	loc_C315

; END OF FUNCTION CHUNK	FOR sub_C2F2
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C2EA

loc_C2D2:				; CODE XREF: sub_C2EA+5
		ld	a, #E
		and	h
		jr	nz, loc_C33E

		dec	e
		ld	a, d
		add	a, l
		ld	l, a
		dec	l
		push	hl
		ld	h, BRD_88_0/256
		ld	a, (hl)
		pop	hl
		inc	l
		or	a
		ld	a, l
		jr	z, loc_C2FB

		dec	e
		dec	e
		jr	loc_C2FB

; END OF FUNCTION CHUNK	FOR sub_C2EA

; =============== S U B	R O U T	I N E =======================================


sub_C2EA:				; CODE XREF: sub_BC00+82 sub_BC00+8A ...

; FUNCTION CHUNK AT C2D2 SIZE 00000018 BYTES

		ld	a, l
		add	a, #20 ; ' '
		bit	6, a
		jr	z, loc_C2D2

		inc	e

; End of function sub_C2EA


; =============== S U B	R O U T	I N E =======================================


sub_C2F2:				; CODE XREF: sub_BC00+6A sub_BC00+72 ...

; FUNCTION CHUNK AT C2B2 SIZE 00000020 BYTES
; FUNCTION CHUNK AT C362 SIZE 0000000C BYTES
; FUNCTION CHUNK AT C467 SIZE 0000000A BYTES

		inc	e
		ld	a, #E
		and	h
		jr	nz, loc_C33E

		ld	a, d
		add	a, l
		ld	l, a


loc_C2FB:				; CODE XREF: sub_C2EA-6 sub_C2EA-2
		and	#F
		ld	c, a
		ld	a, (bc)
		inc	a
		ld	(bc), a
		jp	(iy)

; ---------------------------------------------------------------------------

loc_C303:				; DATA XREF: sub_BC00+1B
		srl	h
		jr	z, loc_C313

		srl	h
		srl	h
		ex	af, af' ;'
		add	a, h
		ex	af, af' ;'
		bit	4, h
		jp	nz, loc_C2B2


loc_C313:				; CODE XREF: RAM:C2AF	sub_C2F2+13
					; DATA XREF: ...
		ld	h, BRD_88_0/256


loc_C315:				; CODE XREF: sub_C2F2-3A sub_C2F2-23
		ld	a, (hl)
		or	a
		jp	z, loc_C32A

		exx
		ld	l, a
		xor	b
		jp	p, loc_C327

		ld	a, #78 ; 'x'
		and	l
		jr	z, loc_C362

		dec	l
		dec	l


loc_C327:				; CODE XREF: sub_C2F2+2B
		inc	(hl)
		exx
		xor	a


loc_C32A:				; CODE XREF: sub_C2F2+25
		dec	l
		dec	l
		or	(hl)
		ret	z
		exx
		ld	l, a
		xor	b
		jp	p, loc_C33B

		ld	a, #78 ; 'x'
		and	l
		jr	z, loc_C362

		dec	l
		dec	l


loc_C33B:				; CODE XREF: sub_C2F2+3F
		inc	(hl)
		exx
		ret

; ---------------------------------------------------------------------------

loc_C33E:				; CODE XREF: sub_C2EA-15 sub_C2F2+4
		push	bc
		push	de
		ld	bc, ret_C35D
		push	bc
		ld	c, h
		ld	h, BRD_88_0/256
		ld	d, #88 ; 'И'
		ld	a, l
		bit	3, c
		jp	nz, sub_C48D

		bit	2, c
		jp	nz, sub_C498

		bit	7, c
		ld	b, a
		jp	nz, loc_C5D5

		jp	loc_C517

; End of function sub_C2F2

; ---------------------------------------------------------------------------

ret_C35D:				; DATA XREF: sub_C2F2+4E
		ld	l, e
		pop	de
		ld	e, l
		pop	bc
		ret

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C2F2

loc_C362:				; CODE XREF: sub_C2F2+31 sub_C2F2+45
		bit	4, b
		jp	z, loc_C467

		set	7, (ix+2)
		exx
		inc	e
		ret

; END OF FUNCTION CHUNK	FOR sub_C2F2
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C3A3

loc_C36E:				; CODE XREF: sub_C3A3+A
		ld	a, b
		and	#FD ; 'э'
		jr	nz, loc_C377

		ex	af, af' ;'
		jp	loc_C432

; ---------------------------------------------------------------------------

loc_C377:				; CODE XREF: sub_C3A3-32
		ld	a, b
		ld	d, a
		and	3
		ld	b, a
		ld	a, d
		and	#FC ; 'ь'
		jr	nz, loc_C3AF

		dec	e
		res	0, b
		ld	a, 3
		jp	loc_C3AF

; ---------------------------------------------------------------------------

loc_C389:				; CODE XREF: sub_C3A3+3
		bit	0, h
		jr	nz, loc_C390

		ld	h, 0
		ret

; ---------------------------------------------------------------------------

loc_C390:				; CODE XREF: sub_C3A3-18
		ld	a, h
		ld	d, h
		and	3
		ld	h, a
		ld	a, d
		and	#FC ; 'ь'
		jr	nz, loc_C3A8

		ld	a, 3
		res	0, h
		jp	loc_C3A8

; END OF FUNCTION CHUNK	FOR sub_C3A3

; =============== S U B	R O U T	I N E =======================================


sub_C3A1:				; CODE XREF: sub_BC00+18D
					; sub_BC00+1A4 ...
		and	#F

; End of function sub_C3A1


; =============== S U B	R O U T	I N E =======================================
;a=0..15 (реально 9,5,3)? попадЄт в max?
;l=? попадЄт в индекс таблицы дл€ вычитани€
;c=? попадЄт в индекс таблицы дл€ сложени€
;b=?
;h=?
;out: hl в том же формате, что bc

sub_C3A3:				; CODE XREF: sub_BC00+F2
					; sub_BC00+108 ...

; FUNCTION CHUNK AT C36E SIZE 00000033 BYTES

		ex	af, af' ;'
		ld	a, l
		or	a
		jr	z, loc_C389

loc_C3A8:				; CODE XREF: sub_C3A3-B sub_C3A3-5
		exx
		ld	b, a
		exx
		ld	a, c
		or	a
		jr	z, loc_C36E

loc_C3AF:				; CODE XREF: sub_C3A3-24 sub_C3A3-1D
		exx
		ld	c, a
		ex	af, af' ;'
		ld	d, a ;max?
		ld	e, #FF ;min?
		ld	h, tbl_BA00/256 ;какие-то константы дл€ оценки позиции?

loc_C3B7:				; CODE XREF: sub_C3A3+36 sub_C3A3+49 ...
		ld	l, b
		sub	(hl)
		cp	e
		jp	m, loc_C3C2 ;value<max?
		cp	d
		jp	p, loc_C420 ;value>min?
;max<=value<=min???
		ld	e, a ;new max?
loc_C3C2:				; CODE XREF: sub_C3A3+17
		inc	h		; tbl_BB00
		ld	b, (hl)
		inc	b
		dec	b
		jr	z, loc_C3FD

loc_C3C8:				; CODE XREF: sub_C3A3+6A sub_C3A3+79
		dec	h
		ld	l, c
		add	a, (hl)
		cp	d
		jp	p, loc_C3D4 ;value>min?
		cp	e
		jp	m, loc_C42A ;value<max?
;max<=value<=min???
		ld	d, a ;new min?
loc_C3D4:				; CODE XREF: sub_C3A3+29
		inc	h
		ld	c, (hl)
		dec	h
		inc	c
		dec	c
		jp	nz, loc_C3B7

		exx
		ex	af, af' ;'
		ld	a, b ;изначально передано в процедуру в b
		and	#FC ; 'ь'
		jr	z, loc_C3EF

		ld	d, a
		ld	a, b
		and	3
		ld	b, a
		ld	a, d
		exx
		ld	c, a
		ex	af, af' ;'
		jp	loc_C3B7

; ---------------------------------------------------------------------------

loc_C3EF:				; CODE XREF: sub_C3A3+3E
		bit	0, b
		jr	z, loc_C41F

		res	0, b
		ld	a, 3
		exx
		ld	c, a
		ex	af, af' ;'
		jp	loc_C3B7

; ---------------------------------------------------------------------------

loc_C3FD:				; CODE XREF: sub_C3A3+23
		exx
		ex	af, af' ;'
		ld	a, h
		and	#FC ; 'ь'
		jr	z, loc_C410

		ld	d, a
		ld	a, h
		and	3
		ld	h, a
		ld	a, d
		exx
		ld	b, a
		ex	af, af' ;'
		jp	loc_C3C8

; ---------------------------------------------------------------------------

loc_C410:				; CODE XREF: sub_C3A3+5F
		bit	0, h
		jr	z, loc_C429

		res	0, h
		ld	a, 3
		dec	e
		exx
		ld	b, a
		ex	af, af' ;'
		jp	loc_C3C8

; ---------------------------------------------------------------------------

loc_C41F:				; CODE XREF: sub_C3A3+4E
		exx


loc_C420:				; CODE XREF: sub_C3A3+1B
		ld	a, d
		or	a
		exx
		jp	p, loc_C430

		jp	loc_C459

; ---------------------------------------------------------------------------

loc_C429:				; CODE XREF: sub_C3A3+6F
		exx


loc_C42A:				; CODE XREF: sub_C3A3+2D
		ld	a, e
		or	a
		exx
		jp	m, loc_C459


loc_C430:				; CODE XREF: sub_C3A3+80
		jr	z, loc_C454


loc_C432:				; CODE XREF: sub_C3A3-2F
		ld	hl, word_D039
		cp	(hl)
		jr	c, loc_C44F

		ld	c, a
		ld	d, (hl)
		ld	(hl), c
		pop	iy
		push	iy
		ld	a, (byte_D02D)
		rrca
		ld	c, (iy+1)
		xor	c
		jp	m, loc_C44E

		ld	a, c
		ld	(byte_D07A), a


loc_C44E:				; CODE XREF: sub_C3A3+A4
		ld	a, d


loc_C44F:				; CODE XREF: sub_C3A3+93
		inc	l
		cp	(hl)
		jr	c, loc_C454

		ld	(hl), a


loc_C454:				; CODE XREF: sub_C3A3:loc_C430
					; sub_C3A3+AE
		dec	e
		bit	1, b
		jr	nz, loc_C45D


loc_C459:				; CODE XREF: sub_C3A3+83 sub_C3A3+8A
		ld	hl, 0
		ret

; ---------------------------------------------------------------------------

loc_C45D:				; CODE XREF: sub_C3A3+B4
		set	2, (ix+2)
		ld	hl, 0
		dec	e
		dec	e
		ret

; End of function sub_C3A3

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C2F2

loc_C467:				; CODE XREF: sub_C2F2+72
		xor	a
		ld	b, 8
		ld	hl,  array_D200+1


loc_C46D:				; CODE XREF: sub_C2F2+17D
		ld	(hl), a
		inc	l
		djnz	loc_C46D

; END OF FUNCTION CHUNK	FOR sub_C2F2
; START	OF FUNCTION CHUNK FOR sub_C254

loc_C471:				; CODE XREF: sub_C254+A sub_C563+17	...
		xor	a
		ld	(byte_D079), a
		ld	b, #1F
		ld	de, 5
		ld	hl, word_D10A


loc_C47D:				; CODE XREF: sub_C254+231
		ld	(hl), a
		inc	l
		ld	(hl), a
		inc	l
		ld	(hl), a
		inc	l
		ld	(hl), a
		add	hl, de
		djnz	loc_C47D

		ld	c, a
		ld	sp, (word_D03D)
		ret

; END OF FUNCTION CHUNK	FOR sub_C254

; =============== S U B	R O U T	I N E =======================================


sub_C48D:				; CODE XREF: sub_BC00+34
					; sub_BC00+4B4 ...
		ld	b, a
		exx
		ld	c, #40 ; '@'
		call	sub_C49C

		exx
		jp	loc_C5D9

; End of function sub_C48D


; =============== S U B	R O U T	I N E =======================================


sub_C498:				; CODE XREF: sub_BC00+3B sub_BC00+42 ...
		ld	b, a
		exx
		ld	c, #10

; End of function sub_C498


; =============== S U B	R O U T	I N E =======================================


sub_C49C:				; CODE XREF: sub_C48D+4
		ld	e, 8
		exx
		ld	l, b
		xor	a


loc_C4A1:				; CODE XREF: sub_C49C+B
		inc	l
		bit	3, l
		jr	nz, loc_C4AF

		or	(hl)
		jr	z, loc_C4A1

		ld	c, 1
		call	sub_C4E2

		xor	a


loc_C4AF:				; CODE XREF: sub_C49C+8
		ld	l, b


loc_C4B0:				; CODE XREF: sub_C49C+1A
		dec	l
		bit	3, l
		jr	nz, loc_C4BD

		or	(hl)
		jr	z, loc_C4B0

		ld	c, #FF
		call	sub_C4E2


loc_C4BD:				; CODE XREF: sub_C49C+17
		ld	c, #10
		ld	a, b
		add	a, c
		call	p, sub_C4CA

		ld	c, #F0	; 'р'
		ld	l, b


loc_C4C7:				; CODE XREF: sub_C4CA+4
		ld	a, l
		add	a, c
		ret	m

; End of function sub_C49C


; =============== S U B	R O U T	I N E =======================================


sub_C4CA:				; CODE XREF: sub_C49C+25
		ld	l, a
		inc	e
		xor	a
		or	(hl)
		jr	z, loc_C4C7

		exx
		ld	l, a
		xor	b
		jp	m, loc_C609

		ld	a, c
		add	a, (hl)
		ld	(hl), a
		set	1, l
		ld	a, (hl)
		and	e
		exx
		ret	z
		jp	loc_C648

; End of function sub_C4CA


; =============== S U B	R O U T	I N E =======================================


sub_C4E2:				; CODE XREF: sub_C49C+F sub_C49C+1E
		exx
		ld	l, a
		xor	b
		jp	m, loc_C609

		ld	a, c
		add	a, (hl)
		ld	(hl), a
		set	1, l
		ld	a, (hl)
		and	e
		exx
		ret	z


loc_C4F1:				; CODE XREF: sub_C4E2+15
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz
		or	(hl)
		jr	z, loc_C4F1

		exx
		ld	l, a
		xor	b
		jp	m, loc_C657

		inc	l
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		exx
		ret

; End of function sub_C4E2


; =============== S U B	R O U T	I N E =======================================


sub_C505:				; CODE XREF: sub_BC00+57 sub_BC00+5E
		ld	b, a
		or	#70 ; 'p'
		cp	b
		jp	nz, loc_C517


loc_C50C:				; CODE XREF: sub_C512+3
		ld	a, e
		sub	6
		jp	loc_C51A

; End of function sub_C505


; =============== S U B	R O U T	I N E =======================================


sub_C512:				; CODE XREF: sub_BC00+4D7
					; sub_BC00+4DE
		ld	b, a
		and	#70 ; 'p'
		jr	z, loc_C50C


loc_C517:				; CODE XREF: sub_C2F2+68 sub_C505+4
		ld	a, e
		sub	5


loc_C51A:				; CODE XREF: sub_C505+A
		ld	e, a
		exx
		ld	c, 4
		exx


loc_C51F:				; CODE XREF: sub_C6C4+5E
		ld	a, #E
		add	a, b
		jp	m, loc_C542

		ld	l, a
		and	d
		call	z, sub_C563

		ld	a, #12
		add	a, b
		ld	l, a
		and	d
		call	z, sub_C563

		ld	a, #1F
		add	a, b
		ld	l, a
		and	d
		call	z, sub_C562

		ld	a, #21 ; '!'
		add	a, b
		ld	l, a
		and	d
		call	z, sub_C562


loc_C542:				; CODE XREF: sub_C512+10
		ld	a, #F2	; 'т'
		add	a, b
		ret	m
		ld	l, a
		and	d
		call	z, sub_C563

		ld	a, #EE	; 'о'
		add	a, b
		ld	l, a
		and	d
		call	z, sub_C563

		ld	a, #E1	; 'б'
		add	a, b
		ret	m
		ld	l, a
		and	d
		call	z, sub_C562

		ld	a, #DF	; 'я'
		add	a, b
		ld	l, a
		and	d
		ret	nz

; End of function sub_C512


; =============== S U B	R O U T	I N E =======================================


sub_C562:				; CODE XREF: sub_C512+25 sub_C512+2D ...
		inc	e

; End of function sub_C562


; =============== S U B	R O U T	I N E =======================================


sub_C563:				; CODE XREF: sub_C512+15 sub_C512+1D ...
		inc	e
		or	(hl)
		ret	z
		exx
		ld	l, a
		xor	b
		jp	p, loc_C573

		ld	a, #78 ; 'x'
		and	l
		jr	z, loc_C578

		dec	l
		dec	l


loc_C573:				; CODE XREF: sub_C563+6
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		exx
		ret

; ---------------------------------------------------------------------------

loc_C578:				; CODE XREF: sub_C563+C
		bit	4, b
		jp	z, loc_C471

		set	7, (ix+2)
		bit	6, b
		set	6, b
		exx
		jr	nz, loc_C592

		ld	l, b
		ld	l, (hl)
		inc	l
		inc	h
		set	1, (hl)
		dec	h
		inc	e
		inc	e
		ret

; ---------------------------------------------------------------------------

loc_C592:				; CODE XREF: sub_C563+23
		set	6, (ix+2)
		ex	af, af' ;'
		add	a, #14
		ex	af, af' ;'
		ret

; End of function sub_C563

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C5FF

loc_C59B:				; CODE XREF: sub_C5FF+D
		bit	4, b
		jp	z, loc_C471

		set	7, (ix+2)
		bit	6, b
		set	6, b
		exx
		jr	nz, loc_C5B9

		ld	a, l
		ld	l, b
		ld	l, (hl)
		inc	l
		inc	h
		set	1, (hl)
		dec	h
		ld	l, a
		inc	e
		inc	e
		jp	loc_C5FA

; ---------------------------------------------------------------------------

loc_C5B9:				; CODE XREF: sub_C5FF-56
		set	6, (ix+2)
		ex	af, af' ;'
		add	a, #14
		ex	af, af' ;'
		jp	loc_C5FA

; END OF FUNCTION CHUNK	FOR sub_C5FF

; =============== S U B	R O U T	I N E =======================================


sub_C5C4:				; CODE XREF: sub_BC00+4C9
					; sub_BC00+4D0
		ld	b, a
		and	#70 ; 'p'
		jp	nz, loc_C5D5


loc_C5CA:				; CODE XREF: sub_C5CF+4
		dec	e
		dec	e
		jp	loc_C5D6

; End of function sub_C5C4


; =============== S U B	R O U T	I N E =======================================


sub_C5CF:				; CODE XREF: sub_BC00+49 sub_BC00+50
		ld	b, a
		or	#70 ; 'p'
		cp	b
		jr	z, loc_C5CA


loc_C5D5:				; CODE XREF: sub_C2F2+65 sub_C5C4+3
		inc	e


loc_C5D6:				; CODE XREF: sub_C5C4+8
		exx
		ld	c, 4


loc_C5D9:				; CODE XREF: sub_C48D+8
		ld	e, #C4	; 'ƒ'
		exx
		ld	c, #F
		ld	a, b
		add	a, c
		ld	l, a
		and	d
		call	z, sub_C5FF

		ld	c, #11
		ld	a, b
		add	a, c
		ld	l, a
		and	d
		call	z, sub_C5FF

		ld	c, #EF	; 'п'
		ld	a, b
		add	a, c
		ld	l, a
		and	d
		call	z, sub_C5FF

		ld	c, #F1	; 'с'
		ld	l, b


loc_C5FA:				; CODE XREF: sub_C5FF-49 sub_C5FF-3E ...
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz

; End of function sub_C5CF


; =============== S U B	R O U T	I N E =======================================


sub_C5FF:				; CODE XREF: sub_C5CF+13 sub_C5CF+1C ...

; FUNCTION CHUNK AT C59B SIZE 00000029 BYTES

		inc	e
		or	(hl)
		jr	z, loc_C5FA

		exx
		ld	l, a
		xor	b
		jp	p, loc_C63C


loc_C609:				; CODE XREF: sub_C4CA+9 sub_C4E2+3
		ld	a, #78 ; 'x'
		and	l
		jr	z, loc_C59B

		dec	l
		dec	l
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		set	2, l
		ld	a, (hl)
		and	e
		jr	z, loc_C669

		jp	m, loc_C669

		exx


loc_C61D:				; CODE XREF: sub_C5FF+24
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz
		or	(hl)
		jr	z, loc_C61D

		exx
		ld	d, l
		ld	l, a
		xor	b
		jp	p, loc_C665

		dec	l
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		inc	l


loc_C631:				; CODE XREF: sub_C5FF+77
		inc	l
		inc	l
		ld	a, (hl)
		rra
		jr	c, loc_C67F

		rra
		jr	c, loc_C67B

		exx
		ret

; ---------------------------------------------------------------------------

loc_C63C:				; CODE XREF: sub_C5FF+7
		ld	a, c
		add	a, (hl)
		ld	(hl), a


loc_C63F:				; CODE XREF: sub_C5FF+63
		set	1, l
		ld	a, (hl)
		and	e
		exx
		ret	z
		jp	m, loc_C6AC


loc_C648:				; CODE XREF: sub_C4CA+15 sub_C5FF+50
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz
		inc	e
		or	(hl)
		jr	z, loc_C648

		exx
		ld	l, a
		xor	b
		jp	p, loc_C65D


loc_C657:				; CODE XREF: sub_C4E2+1A
		dec	l


loc_C658:				; CODE XREF: sub_C5FF+67
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		exx
		ret

; ---------------------------------------------------------------------------

loc_C65D:				; CODE XREF: sub_C5FF+55
		inc	l
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		dec	l
		jp	loc_C63F

; ---------------------------------------------------------------------------

loc_C665:				; CODE XREF: sub_C5FF+2A
		inc	l
		jp	loc_C658

; ---------------------------------------------------------------------------

loc_C669:				; CODE XREF: sub_C5FF+18 sub_C5FF+1A
		exx


loc_C66A:				; CODE XREF: sub_C5FF+71
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz
		or	(hl)
		jr	z, loc_C66A

		exx
		ld	d, l
		ld	l, a
		xor	b
		jp	m, loc_C631

		exx
		ret

; ---------------------------------------------------------------------------

loc_C67B:				; CODE XREF: sub_C5FF+39
		bit	6, c
		jr	nz, loc_C6A8


loc_C67F:				; CODE XREF: sub_C5FF+36
		res	1, d
		res	2, d
		ld	hl, byte_D079


loc_C686:				; CODE XREF: sub_C5FF+8E
		ld	a, (hl)
		or	a
		jr	z, loc_C697

		inc	l
		inc	l
		cp	d
		jp	nz, loc_C686

		dec	l
		ld	(hl), 0
		inc	h
		exx
		inc	e
		ret

; ---------------------------------------------------------------------------

loc_C697:				; CODE XREF: sub_C5FF+89
		ld	a, l
		cp	#84 ; 'Д'
		jr	nc, loc_C6A7

		ld	(hl), d
		inc	l
		exx
		ld	a, c
		exx
		ld	(hl), a
		inc	l
		ld	(hl), 0
		set	5, b


loc_C6A7:				; CODE XREF: sub_C5FF+9B
		inc	h


loc_C6A8:				; CODE XREF: sub_C5FF+7E
		exx
		inc	e
		inc	e
		ret

; ---------------------------------------------------------------------------

loc_C6AC:				; CODE XREF: sub_C5FF+46
		rla
		xor	c
		ret	p
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz
		or	(hl)
		ret	z
		exx
		ld	l, a
		inc	l
		xor	b
		jp	p, loc_C6BF

		dec	l
		dec	l


loc_C6BF:				; CODE XREF: sub_C5FF+BB
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		exx
		ret

; End of function sub_C5FF


; =============== S U B	R O U T	I N E =======================================


sub_C6C4:				; CODE XREF: sub_BC00+D5

; FUNCTION CHUNK AT C719 SIZE 0000000E BYTES
; FUNCTION CHUNK AT C734 SIZE 00000010 BYTES

		ld	iy, byte_D079
		push	de
		ld	h, BRD_88_0/256
		exx
		ld	l, (iy+0)


loc_C6CF:				; CODE XREF: RAM:C777
		ld	bc, loc_C76B
		push	bc
		ld	a, l
		and	#80 ; 'А'
		ld	b, a
		ld	e, (hl)
		inc	l
		ld	a, (hl)
		and	#8E ; 'О'
		jr	z, loc_C6EF

		jp	m, loc_C734

		cp	4
		jr	c, loc_C719

		jr	z, loc_C725

		ld	c, #C0	; 'ј'
		call	sub_C727

		jp	loc_C73D

; ---------------------------------------------------------------------------

loc_C6EF:				; CODE XREF: sub_C6C4+18 sub_C6C4+72
		bit	7, b
		ld	a, e
		exx
		ld	b, a
		ld	c, #F
		jr	z, loc_C6FA

		ld	c, #EF	; 'п'


loc_C6FA:				; CODE XREF: sub_C6C4+32
		call	sub_C6FF

		inc	c
		inc	c

; End of function sub_C6C4


; =============== S U B	R O U T	I N E =======================================


sub_C6FF:				; CODE XREF: sub_C6C4:loc_C6FA
		ld	a, (iy+1)
		cp	c
		ret	z
		neg
		cp	c
		ret	z
		ld	a, c
		add	a, b
		ld	l, a
		xor	a
		or	(hl)
		ret	z
		exx
		ld	l, a
		xor	b
		jp	p, loc_C716

		dec	l
		dec	l


loc_C716:				; CODE XREF: sub_C6FF+12
		dec	(hl)
		exx
		ret

; End of function sub_C6FF

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C6C4

loc_C719:				; CODE XREF: sub_C6C4+1F
		ld	c, #FC	; 'ь'
		set	4, b
		ld	a, e
		exx
		ld	d, #88 ; 'И'
		ld	b, a
		jp	loc_C51F

; ---------------------------------------------------------------------------

loc_C725:				; CODE XREF: sub_C6C4+21
		ld	c, #F0	; 'р'

; END OF FUNCTION CHUNK	FOR sub_C6C4

; =============== S U B	R O U T	I N E =======================================


sub_C727:				; CODE XREF: sub_C6C4+25
		ld	a, e
		exx
		ld	c, 1
		ld	b, a
		call	sub_C744

		ld	c, #10
		jp	sub_C744

; End of function sub_C727

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_C6C4

loc_C734:				; CODE XREF: sub_C6C4+1A
		and	2
		jr	z, loc_C6EF

		ld	c, #FC	; 'ь'
		ld	a, e
		exx
		ld	b, a


loc_C73D:				; CODE XREF: sub_C6C4+28
		ld	c, #F
		call	sub_C744

		ld	c, #11

; END OF FUNCTION CHUNK	FOR sub_C6C4

; =============== S U B	R O U T	I N E =======================================


sub_C744:				; CODE XREF: sub_C727+5 sub_C727+A ...
		ld	a, (iy+1)
		cp	c
		ret	z
		neg
		cp	c
		ret	z
		ld	d, #88 ; 'И'
		call	sub_C755

		xor	a
		sub	c
		ld	c, a

; End of function sub_C744


; =============== S U B	R O U T	I N E =======================================


sub_C755:				; CODE XREF: sub_C744+B
		ld	l, b


loc_C756:				; CODE XREF: sub_C755+7
		ld	a, l
		add	a, c
		ld	l, a
		and	d
		ret	nz
		or	(hl)
		jr	z, loc_C756

		exx
		ld	l, a
		xor	b
		jp	p, loc_C766

		dec	l
		dec	l


loc_C766:				; CODE XREF: sub_C755+C
		ld	a, c
		add	a, (hl)
		ld	(hl), a
		exx
		ret

; End of function sub_C755

; ---------------------------------------------------------------------------

loc_C76B:				; DATA XREF: sub_C6C4:loc_C6CF
		ld	a, (iy+2)
		or	a
		jr	z, loc_C77A

		inc	iy
		inc	iy
		exx
		ld	l, a
		jp	loc_C6CF

; ---------------------------------------------------------------------------

loc_C77A:				; CODE XREF: RAM:C76F
		pop	de
		ld	(byte_D079), a
		ret

; ---------------------------------------------------------------------------
       if !FIX
		db    0	;unneeded???
       endif


		;might be at any address
Openings:	
		db #26,#92,#69,#C4,#CA,#B0,#4C,#2E,#0D
		db #0A,#16,#49,#E8,#91,#32,#30,#B6,#4B
		db #05,#94,#90,#02,#84,#01,#3D,#17,#26
		db #05,#88,#82,#81,#00,#40,#A0,#34,#21
		db #08,#08,#C0,#C1,#C4,#00,#50,#9A,#18
		db #15,#A2,#89,#E9,#92,#5A,#64,#CC,#99
		db #08,#86,#02,#41,#50,#02,#2C,#0C,#4A
		db #40,#13,#13,#00,#50,#68,#15,#00,#44
		db #AB,#03,#C2,#E4,#90,#A1,#4C,#9A,#1C
		db #04,#15,#D0,#00,#A4,#01,#44,#39,#4E
		db #45,#14,#91,#40,#04,#50,#3C,#3A,#5A
		db #50,#86,#51,#C5,#52,#E9,#28,#3E,#8B
		db #2D,#03,#D3,#70,#90,#E2,#04,#BE,#93
		db #A7,#A2,#A4,#E1,#B4,#A0,#58,#BA,#59
		db #28,#26,#83,#09,#48,#E8,#71,#13,#59
		db #45,#56,#91,#55,#B4,#55,#71,#37,#1F
		db #49,#94,#4B,#41,#A5,#14,#50,#2E,#5F
		db #49,#92,#D2,#E4,#C4,#E0,#3D,#2C,#55
		db #31,#11,#01,#A8,#F0,#58,#51,#2A,#14
		db #02,#02,#C1,#E5,#44,#21,#88,#22,#28
		db #08,#1A,#D2,#61,#34,#79,#A0,#00,#06
		db #4C,#1A,#53,#05,#C4,#00,#48,#00,#68
		db #4B,#91,#53,#00,#04,#C0,#48,#B4,#56
		db #0D,#82,#C1,#44,#64,#94,#15,#27,#19
		db #11,#24,#2B,#81,#30,#A2,#2A,#B2,#1B
		db #04,#A2,#EB,#01,#40,#92,#26,#AC,#94
		db #8B,#A2,#C0,#C4,#92,#68,#20,#3A,#0A
		db #0B,#A1,#CB,#84,#A0,#6A,#42,#1A,#0C
		db #08,#A0,#20,#69,#52,#89,#00,#22,#15
		db #07,#01,#D2,#A4,#C0,#80,#00,#1A,#11
		db #43,#83,#4A,#20,#00,#70,#28,#0C,#94
		db #27,#00,#02,#41,#24,#69,#48,#00,#07
		db #05,#24,#40,#20,#D0,#58,#59,#29,#55
		db #0C,#12,#D0,#C4,#44,#E1,#04,#20,#07
		db #40,#13,#41,#E0,#E4,#A0,#48,#0A,#19
		db #0B,#25,#A8,#09,#8A,#08,#54,#28,#00
		db #09,#06,#52,#54,#70,#90,#24,#2E,#06
		db #47,#C2,#C1,#84,#84,#88,#31,#30,#4E
		db #0B,#04,#C2,#E5,#00,#A5,#24,#3A,#14
		db #02,#05,#44,#C1,#20,#D8,#38,#32,#05
		db #52,#85,#89,#E9,#33,#32,#4E,#50,#8C
		db #27,#06,#83,#40,#E2,#D2,#34,#1C,#89
		db #09,#15,#00,#28,#F2,#7A,#3A,#44,#10
		db #0A,#22,#A0,#E1,#30,#2A,#60,#94,#04
		db #2E,#05,#81,#60,#40,#B2,#5C,#36,#12
		db #09,#86,#81,#01,#50,#F2,#5C,#A6,#45
		db #0C,#01,#82,#E1,#14,#F8,#34,#30,#06
		db #0B,#88,#83,#29,#82,#C8,#38,#1E,#95
		db #8B,#02,#C3,#A0,#B0,#D0,#10,#42,#91
		db #26,#D3,#89,#64,#62,#9D,#18,#A6,#40
		db #22,#80,#C2,#E0,#62,#C0,#4C,#00,#59
		db #26,#22,#0A,#A9,#82,#42,#5E,#20,#98
		db #0B,#02,#8B,#C9,#01,#02,#26,#8C,#13
		db #4E,#40,#0A,#C9,#82,#90,#14,#AE,#8D
		db #86,#A3,#C2,#61,#70,#A9,#5D,#22,#1F
		db #0A,#A7,#0A,#41,#42,#E8,#2C,#3E,#1A
		db #06,#90,#52,#61,#A4,#99,#81,#0D,#08
		db #40,#86,#08,#C9,#48,#8A,#1C,#90,#13
		db #09,#A4,#4A,#C5,#A0,#00,#14,#3A,#12
		db #2A,#A4,#40,#C9,#88,#90,#11,#45,#49
		db #02,#92,#52,#80,#00,#B8,#15,#31,#03
		db #0B,#82,#D1,#05,#82,#99,#24,#2E,#97
		db #8E,#86,#11,#85,#60,#D0,#39,#24,#48
		db #09,#85,#12,#E5,#40,#60,#69,#19,#00
		db #06,#05,#92,#44,#92,#00,#64,#22,#8E
		db #09,#87,#41,#08,#2A,#D8,#58,#36,#21
		db #45,#45,#C0,#C0,#D0,#BA,#64,#18,#53
		db #20,#11,#C2,#49,#E2,#F8,#49,#1B,#11
		db #0A,#0A,#42,#60,#34,#39,#4D,#28,#54
		db #0E,#81,#D1,#20,#60,#F8,#59,#35,#10
		db #0A,#05,#10,#E5,#60,#D8,#20,#AC,#1B
		db #0F,#25,#A4,#69,#B2,#68,#48,#2A,#00
		db #08,#82,#01,#E4,#14,#B0,#19,#2C,#48
		db #2C,#05,#80,#00,#00,#CA,#22,#26,#13
		db #05,#21,#2A,#20,#00,#80,#60,#0E,#01
		db #4C,#46,#43,#41,#91,#00,#48,#00,#97
		db #22,#92,#0B,#44,#20,#E8,#34,#00,#95
		db #2B,#07,#43,#C2,#74,#3C,#70,#3A,#1F
		db #13,#A3,#8B,#61,#60,#A0,#78,#18,#A5
		db #A0,#05,#83,#20,#90,#D2,#26,#32,#07
		db #0D,#02,#43,#A9,#40,#89,#50,#B0,#1E
		db #09,#03,#43,#A2,#01,#09,#31,#4C,#44
		db #45,#C2,#54,#D0,#60,#88,#08,#14,#8A
		db #2E,#06,#48,#05,#00,#32,#78,#0C,#22
		db #4E,#19,#83,#01,#34,#BD,#7C,#30,#24
		db #41,#47,#82,#24,#74,#08,#65,#01,#0F
		db #43,#15,#83,#25,#72,#10,#69,#2A,#52
		db #0A,#01,#C3,#E9,#52,#40,#28,#06,#22
		db #50,#01,#02,#E0,#A4,#79,#38,#10,#1F
		db #09,#88,#13,#11,#E2,#C8,#60,#30,#14
		db #44,#96,#04,#40,#81,#02,#74,#34,#0F
		db #4C,#12,#02,#25,#84,#38,#1D,#16,#13
		db #2C,#00,#C3,#21,#94,#68,#44,#2E,#19
		db #11,#03,#83,#E9,#D2,#69,#58,#AE,#20
		db #06,#01,#43,#82,#90,#D1,#79,#20,#63
		db #48,#46,#D1,#F0,#C0,#60,#70,#34,#0F
		db #40,#13,#8A,#A1,#00,#81,#58,#3C,#0C
		db #47,#00,#40,#41,#64,#C4,#30,#02,#01
		db #05,#05,#05,#49,#A8,#28,#30,#1E,#13
		db #0D,#25,#8A,#A1,#62,#68,#35,#24,#51
		db #08,#82,#C1,#C0,#40,#02,#02,#38,#0D
		db #0C,#87,#CB,#40,#74,#00,#6C,#0E,#A1
		db #AC,#03,#80,#61,#C0,#F8,#58,#3A,#8E
		db #8B,#05,#C3,#E0,#12,#10,#34,#18,#11
		db #50,#88,#82,#C1,#50,#DA,#78,#94,#4D
		db #0D,#05,#83,#61,#42,#A0,#38,#32,#80
		db #A1,#85,#42,#A9,#A8,#C8,#58,#28,#9C
		db #05,#92,#02,#21,#C0,#38,#30,#3C,#11
		db #45,#46,#81,#01,#A0,#F0,#68,#10,#13
		db #4C,#11,#C1,#A1,#A0,#B8,#74,#AC,#24
		db #07,#88,#10,#90,#C0,#38,#4C,#36,#83
		db #2B,#05,#C9,#00,#B0,#21,#48,#A6,#98
		db #2D,#01,#C2,#28,#09,#28,#48,#26,#9D
		db #C4,#C7,#50,#31,#80,#38,#3C,#22,#54
		db #4F,#06,#03,#C1,#74,#41,#30,#AC,#16
		db #29,#16,#43,#21,#B2,#48,#50,#2C,#92
		db #09,#07,#40,#89,#72,#90,#64,#24,#07
		db #0B,#07,#51,#85,#02,#88,#58,#2E,#16
		db #05,#21,#C2,#C1,#D0,#D8,#20,#2A,#A8
		db #0D,#03,#82,#81,#80,#CA,#28,#A6,#4C
		db #2F,#87,#03,#84,#E0,#C1,#41,#2E,#03
		db #0B,#A4,#09,#E2,#02,#C0,#11,#24,#19
		db #0D,#A5,#83,#41,#F4,#B9,#3C,#38,#1F
		db #06,#02,#52,#A5,#B0,#58,#60,#2C,#04
		db #48,#52,#43,#A0,#30,#50,#01,#53,#5E
		db #0F,#00,#D0,#74,#40,#A8,#3C,#0E,#04
		db #44,#C6,#03,#A1,#20,#88,#35,#24,#52
		db #26,#11,#C4,#A1,#32,#92,#0E,#56,#92
		db #25,#09,#04,#00,#E4,#60,#68,#34,#09
		db #08,#A3,#A4,#01,#21,#08,#58,#3C,#8D
		db #8D,#05,#42,#81,#80,#CA,#28,#BE,#19
		db #2E,#04,#03,#20,#32,#72,#5A,#1E,#9B
		db #2B,#86,#00,#A1,#30,#4A,#84,#88,#10
		db #10,#05,#44,#88,#F0,#F0,#44,#32,#0F
		db #07,#29,#A3,#C1,#B0,#70,#50,#B2,#8F
		db #0D,#A3,#22,#A1,#60,#68,#48,#32,#1A
		db #0B,#A7,#C9,#05,#60,#61,#4C,#28,#15
		db #25,#05,#02,#26,#44,#D8,#41,#2E,#4D
		db #2E,#02,#42,#49,#30,#80,#24,#36,#93
		db #07,#96,#0A,#A1,#04,#80,#60,#26,#8C
		db #0A,#03,#93,#25,#E0,#A1,#74,#1C,#13
		db #47,#03,#91,#A5,#F0,#41,#38,#10,#88
		db #0A,#86,#51,#B1,#24,#A1,#28,#18,#12
		db #04,#A7,#2A,#80,#C0,#B8,#50,#26,#91
		db #87,#23,#08,#45,#70,#19,#58,#1E,#57
		db #03,#02,#C1,#A0,#04,#F4,#3C,#20,#0E
		db #4A,#15,#01,#05,#50,#51,#84,#26,#1D
		db #4A,#87,#82,#A8,#C0,#98,#0C,#1A,#0F
		db #09,#24,#41,#40,#52,#9A,#2C,#20,#8B
		db #85,#03,#C3,#48,#F2,#58,#5C,#98,#56
		db #06,#87,#4A,#2A,#20,#80,#5C,#12,#8E
		db #04,#01,#40,#E0,#70,#C0,#21,#14,#83
		db #20,#85,#89,#A1,#30,#A2,#80,#1E,#1E
		db #06,#03,#83,#49,#9A,#80,#58,#00,#13
		db #08,#18,#82,#E9,#D2,#D0,#19,#18,#10
		db #08,#20,#E1,#41,#60,#50,#4C,#34,#5A
		db #04,#23,#09,#40,#81,#20,#01,#0C,#62
		db #04,#06,#08,#09,#E0,#DA,#78,#98,#08
		db #44,#04,#01,#01,#F0,#00,#11,#0E,#4B
		db #25,#D4,#8A,#25,#40,#A0,#3C,#1C,#0D
		db #07,#02,#93,#64,#C0,#68,#48,#30,#5D
		db #0C,#88,#52,#41,#80,#58,#71,#42,#0F
		db #06,#83,#4B,#21,#D4,#78,#60,#30,#0B
		db #0E,#28,#49,#44,#C2,#70,#28,#20,#1D
		db #48,#05,#02,#E0,#A0,#18,#44,#32,#91
		db #27,#81,#C8,#60,#70,#D0,#4C,#2C,#8F
		db #2C,#02,#02,#60,#D0,#6A,#58,#34,#9A
		db #CA,#14,#E9,#E4,#D0,#C8,#6C,#18,#1C
		db #00,#25,#C9,#E1,#A0,#48,#40,#2E,#00
		db #4A,#C4,#82,#A1,#50,#D0,#08,#2C,#97
		db #26,#05,#83,#01,#90,#A2,#4A,#AC,#17
		db #0C,#08,#52,#31,#50,#B8,#38,#40,#21
		db #49,#05,#29,#85,#20,#51,#1C,#3C,#00
		db #0E,#A2,#81,#81,#E0,#A8,#89,#36,#19
		db #0B,#86,#C2,#41,#40,#F0,#69,#1A,#14
		db #0D,#83,#02,#C8,#92,#60,#2C,#2E,#17
		db #04,#06,#43,#C0,#E4,#B0,#24,#16,#07
		db #24,#95,#02,#60,#C0,#90,#65,#38,#44
		db #07,#8A,#02,#00,#E4,#98,#6C,#1C,#1A
		db #09,#08,#D2,#84,#60,#62,#5C,#AA,#0C
		db #49,#96,#91,#81,#60,#62,#60,#84,#52
		db #28,#53,#08,#C5,#82,#B1,#39,#0C,#15
		db #23,#A3,#C0,#C9,#12,#00,#38,#30,#1D
		db #0D,#00,#0B,#48,#D0,#78,#71,#18,#59
		db #2A,#86,#42,#28,#E0,#70,#34,#3A,#8B
		db #27,#05,#43,#A1,#14,#80,#6D,#30,#53
		db #03,#84,#08,#01,#54,#91,#48,#2A,#96
		db #07,#85,#51,#24,#A0,#F0,#38,#36,#98
		db #20,#86,#43,#A8,#02,#92,#64,#84,#19
		db #0B,#A3,#83,#41,#B0,#9A,#3E,#28,#18
		db #0A,#14,#41,#48,#70,#C8,#50,#30,#1C
		db #2E,#A3,#8C,#88,#E0,#9A,#38,#1F,#51
		db #24,#80,#C3,#E8,#A0,#E0,#0C,#18,#0A
		db #00,#20,#00,#C0,#70,#18,#64,#00,#0C
		db #44,#94,#89,#84,#12,#D0,#4C,#B4,#00
		db #07,#87,#28,#04,#E0,#F0,#40,#A6,#9A
		db #2E,#24,#02,#89,#30,#60,#79,#10,#61
		db #4B,#48,#13,#65,#10,#00,#2C,#B2,#22
		db #4E,#87,#41,#89,#D3,#10,#00,#16,#5C
		db #2D,#26,#44,#49,#92,#68,#69,#2E,#18
		db #4A,#08,#C0,#01,#80,#C9,#35,#36,#1E
		db #4D,#C4,#82,#61,#F0,#00,#35,#16,#11
		db #2B,#83,#C3,#01,#00,#D8,#2C,#2A,#00
		db #0E,#96,#50,#05,#34,#00,#09,#00,#52
		db #04,#90,#83,#80,#54,#01,#75,#00,#0A
		db #40,#12,#41,#22,#04,#00,#28,#1E,#0E
		db #07,#04,#91,#34,#F4,#0C,#69,#02,#4D
		db #0A,#94,#01,#A1,#40,#C8,#50,#B0,#1C
		db #2E,#A3,#8C,#88,#E0,#9A,#38,#36,#1C
		db #06,#A3,#81,#C1,#20,#78,#38,#1E,#18
		db #43,#C4,#42,#A4,#D4,#98,#30,#26,#0C
		db #48,#52,#41,#E0,#70,#49,#50,#26,#0C
		db #09,#06,#53,#85,#B0,#70,#68,#24,#23
		db #4A,#01,#01,#E2,#80,#80,#39,#27,#4C
		db #28,#21,#89,#E8,#60,#6A,#66,#0C,#05
		db #04,#06,#02,#61,#80,#88,#28,#24,#81
		db #A4,#85,#09,#80,#A0,#C2,#54,#1C,#17
		db #0A,#27,#A1,#E5,#20,#18,#68,#22,#0B
		db #02,#05,#C0,#00,#04,#B0,#24,#06,#87
		db #24,#93,#40,#64,#D2,#51,#24,#B0,#07
		db #05,#07,#42,#00,#B0,#2A,#78,#2C,#07
		db #00,#80,#02,#88,#48,#B8,#34,#22,#16
		db #0C,#26,#82,#C5,#60,#88,#50,#08,#9B
		db #23,#01,#00,#01,#20,#18,#01,#36,#13
		db #46,#05,#49,#49,#C0,#B0,#45,#08,#49
		db #23,#01,#40,#80,#50,#A0,#4C,#2C,#95
		db #01,#81,#02,#A1,#50,#20,#10,#24,#12
		db #02,#21,#00,#40,#30,#80,#4C,#A8,#19
		db #07,#06,#42,#60,#B4,#70,#58,#38,#1B
		db #0D,#05,#C2,#08,#32,#19,#2C,#1A,#54
		db #08,#82,#C2,#A0,#E0,#60,#10,#16,#A3
		db #28,#83,#41,#A0,#24,#4C,#4D,#0A,#42
		db #09,#04,#80,#20,#10,#00,#00,#22,#12
		db #04,#27,#21,#25,#24,#68,#29,#1B,#46
		db #26,#80,#11,#60,#B0,#02,#2E,#1E,#0B
		db #22,#02,#C2,#28,#70,#68,#2C,#1E,#87
		db #22,#16,#0C,#26,#82,#C5,#60,#88,#50
		db #08,#9B,#23,#01,#00,#01,#20,#18,#01
		db #36,#13,#46,#05,#49,#49,#C0,#B0,#45
		db #08,#49,#23,#01,#40,#80,#50,#A0,#4C
		db #2C,#95,#01,#81,#02,#A1,#50,#20,#10
		db #24,#12,#02,#21,#00,#40,#30

		;^^^ that table ends exactly at #CFFF !!!!
end


		; below is only data memory (tables and variables), zeroed at start

		ds 0xD000-$

BRD_88_0:	ds 8		; DATA XREF: START_POINT+6B
					; sub_8C20-71D ...
		db    0
byte_D009:	db 0			; DATA XREF: sub_B75A:loc_B781
					; RAM:B7AA ...
byte_D00A:	db 0			; DATA XREF: sub_8C20:loc_8142
					; sub_8C20:loc_8253 ...
byte_D00B:	db 0			; DATA XREF: sub_AFC5+A6 sub_AFC5+E6 ...
		db    0
word_D00D:	dw 0			; DATA XREF: sub_8C20-574 sub_AD40+2 ...
		db    0
BRD_88_1:	ds 8
		db    0
byte_D019:	db 0			; DATA XREF: sub_AFC5+B2
					; sub_B47F+188 ...
byte_D01A:	db 0			; DATA XREF: sub_B47F+293
					; sub_B75A+1B	...
byte_D01B:	db 0			; DATA XREF: RAM:B7B7	sub_B943+20
byte_D01C:	db 0			; DATA XREF: sub_AFC5+A9
					; sub_B47F+1E2 ...
byte_D01D:	db 0			; DATA XREF: sub_AB53+1 sub_B47F-2D	...
byte_D01E:	db 0			; DATA XREF: sub_B19C+33
					; sub_B47F+118 ...
		db    0
BRD_88_2:	ds 8
		db    0
byte_D029:	db 0			; DATA XREF: sub_8C20-9C9
					; sub_8C20-6C8
byte_D02A:	db 0			; DATA XREF: sub_AFC5+126
					; sub_B1EB+11	...
word_D02B:	dw 0			; DATA XREF: sub_8C20-AB0
					; sub_8DE9+6E	...
byte_D02D:	db 0			; DATA XREF: sub_8C20-AD6
					; sub_8C20:loc_82D7 ...
byte_D02E:	db 0			; DATA XREF: sub_AFC5+3B sub_B19C+1D
		db    0
BRD_88_3:	ds 8
		db    0
word_D039:	dw 0			; DATA XREF: sub_BC00+E2
					; sub_BC00+23A ...
byte_D03B:	db 0			; DATA XREF: sub_AD40+6 sub_AD40+57	...
byte_D03C:	db 0			; DATA XREF: sub_AFC5+10F
					; sub_AFC5+148 ...
word_D03D:	dw 0			; DATA XREF: sub_AD40+1A sub_AD40+AD ...
		db    0
BRD_88_4:	ds 8
		db    0
byte_D049:	db 0			; DATA XREF: sub_8C20-B62 ;move # (1..N)
					; sub_8C20-B37 ...
word_D04A:	dw 0			; DATA XREF: sub_AB53+8 sub_AB53+CD	...
byte_D04C:	db 0			; DATA XREF: sub_A932+10 sub_AFC5+2D ...
byte_D04D:	db 0			; DATA XREF: sub_8C20-B24
					; sub_8C20-654 ...
byte_D04E:	db 0			; DATA XREF: sub_AB53+18 sub_AB53+29 ...
		db    0
BRD_88_5:	ds 8
		db    0
word_D059:	dw 0			; DATA XREF: sub_8C20-A8E
					; sub_8C20-A35 ...
byte_D05B:	db 0			; DATA XREF: sub_8C20-6CB
					; sub_8C20-1C8 ...
word_D05C:	dw 0			; DATA XREF: sub_8C20-8B2
					; sub_8C20-6D4 ...
byte_D05E:	db 0			; DATA XREF: sub_8C20-6D1 sub_8B66+9
		db    0
BRD_88_6:	ds 8
		db    0
word_D069:	dw 0			; DATA XREF: sub_AB53+B sub_AB53+35	...
JP_ADDR:	dw 0			; DATA XREF: RAM:AB4F	sub_B75A+2D ...
word_D06D:	dw 0			; DATA XREF: sub_B47F+134
					; sub_B47F+16A ...
		db    0
BRD_88_7:	ds 8
		db    0
byte_D079:	db 0			; DATA XREF: sub_C254+21E
					; sub_C5FF+84	...
byte_D07A:	db 0			; DATA XREF: sub_B36B+13 sub_B47F+2	...
		db    0
		db    0
		db    0
		db    0
		db    0
unk_D080:	db    0			; DATA XREF: InitBoard_ClearMoves+18
		db    0
		db    0
		db    0
		db    0
		db    0
word_D086:	dw 0			; DATA XREF: sub_AB53+45 sub_AB53+6A
word_D088:	dw 0			; DATA XREF: sub_8C20-1FB
					; sub_8C20:loc_8A2F ...
byte_D08A:	db 0			; DATA XREF: sub_AFC5+A0
					; sub_AFC5+1A2 ...
byte_D08B:	db 0			; DATA XREF: sub_AFC5+70 sub_AFC5+AD ...
byte_D08C:	db 0			; DATA XREF: sub_AFC5+A3
					; sub_AFC5+1A5 ...
byte_D08D:	db 0			; DATA XREF: sub_8C20-657
					; sub_8C20-634 ...
byte_D08E:	db 0			; DATA XREF: sub_8C20-661
		db    0
		db    0
		db    0
		db    0
RAND_SEED:	db 0			; DATA XREF: GEN_RANDBYTE+3
					; GEN_RANDBYTE+8
		db    0
		db    0
		db    0
byte_D097:	db 0			; DATA XREF: InitBoard_ClearMoves+49
					; sub_A94F:loc_A961 ...
byte_D098:	db 0			; DATA XREF: sub_A6F7+34 sub_AFC5+5F ...
word_D099:	dw 0			; DATA XREF: InitBoard_ClearMoves+58
		db    0
		db    0
		db    0
byte_D09E:	db 0			; DATA XREF: sub_8C20-A4E ;end of opening?
					; sub_8C20-90D ...
word_D09F:	dw 0			; DATA XREF: sub_8C20-B58
					; sub_8C20:loc_811C ...
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
byte_D0B1:	db 0			; DATA XREF: START_POINT+8F
					; sub_8C20:loc_8515 ...
byte_D0B2:	db 0			; DATA XREF: sub_8C20-ACD
					; sub_8C20-5A5 ...
byte_D0B3:	db 0			; DATA XREF: sub_8C20-B66
					; sub_8C20-8DF ...
					; bit 3	-- swap	clocks ;d3=swap board
byte_D0B4:	db 0			; DATA XREF: sub_92D7-123C
					; sub_8C20-AEE ...
		db    0
byte_D0B6:	db 0			; DATA XREF: sub_8C20:loc_81A1
					; sub_8C20-A48 ...
byte_D0B7:	db 0			; DATA XREF: sub_8C20-68A
					; sub_A08D:loc_A0AF ...
byte_D0B8:	db 0			; DATA XREF: sub_8C20-885
					; sub_8C20-873 ...
		db    0
		db    0
word_D0BB:	dw 0			; DATA XREF: sub_8C20-895
					; sub_8C20-7C0 ...
byte_D0BD:	db 0			; DATA XREF: KEY_SCAN+9
					; KEY_SCAN:loc_90D1 ...
SEL_SCRorBUF:	db 0			; DATA XREF: START_POINT+81
					; sub_8D9E:loc_8DB0 ...
byte_D0BF:	db 0			; DATA XREF: sub_8C20-AD1
					; sub_8C20-942 ...
byte_D0C0:	db 0			; DATA XREF: sub_96A6+14 sub_9FB2+D	...
		db    0
byte_D0C2:	db 0			; DATA XREF: sub_8C20-A0F
					; sub_8C20-78E ...
byte_D0C3:	db 0			; DATA XREF: sub_8C20-A03
					; sub_8C20-782 ...
byte_D0C4:	db 0			; DATA XREF: sub_8C20-A15
					; sub_8C20-794 ...
byte_D0C5:	db 0			; DATA XREF: sub_8C20-A09
					; sub_8C20-788 ...
word_D0C6:	dw 0			; DATA XREF: sub_8D9E+27 sub_8D9E+36 ...
word_D0C8:	dw 0			; DATA XREF: sub_8D9E+33 sub_8DE9+10
BRD_COLOR:	db 0			; DATA XREF: SET_BRD_COLOR:loc_9655
					; BEEP_routine+15
byte_D0CB:	db 0			; DATA XREF: sub_8E81+1E
					; sub_8EA7:loc_8EE5
byte_D0CC:	db 0			; DATA XREF: sub_8EA7:loc_8EA8
					; sub_8EA7+26
byte_D0CD:	db 0			; DATA XREF: sub_8C20-892
scr_XY:		dw 0			; DATA XREF: sub_842C+8
					; sub_8C20:loc_85B4 ...
scr_pix_addr:	dw 0			; DATA XREF: sub_8EFB+B sub_8EFB+25	...
scr_attr_addr:	dw 0			; DATA XREF: sub_8EFB+14 sub_8EFB+2E ...
NEED_SCR2BUF:	db 0			; DATA XREF: sub_8D2C+A
					; PRINT_STR_FF:PRINT_STR_A ...
word_D0D5:	dw 0			; DATA XREF: sub_965C+4 sub_9F42 ...
TMP_BOARD_PTR:	dw 0			; DATA XREF: sub_93A4:loc_93A7
					; sub_93A4:loc_93FC ...
byte_D0D9:	db 0			; DATA XREF: sub_8C20-697
					; sub_90E8:loc_900E
word_D0DA:	dw 0			; DATA XREF: sub_8C20-8CF
					; sub_9128+EE
byte_D0DC:	db 0			; DATA XREF: sub_8C20:loc_835C
					; sub_8C20-76D ...
DECREMENT_50HZ:	db 0			; DATA XREF: INT_PROC+4 sub_8D9E+46	...
		db    0
byte_D0DF:	db 0			; DATA XREF: sub_8C20-AA9
					; sub_8C20:loc_81AA ...
CFG_BITS:	db 0			; DATA XREF: sub_8C20-B4F
					; sub_8C20-AFC ...
					; bit2=1 -- there is serial printer
					; bit3=1 -- there is zx	printer
byte_D0E1:	db 0			; DATA XREF: sub_A0F7+4 PRT_DETECT+1 ...
baudrate_NUM:	db 0			; DATA XREF: PRT_DETECT+16
					; sub_8C20+1754 ...
byte_D0E3:	db 0			; DATA XREF: sub_8C20-ABC
INC_SECONDS:	dw 0			; DATA XREF: sub_8C20-AB3
					; sub_8C20-910 ...
unk_D0E6:	db    0			; DATA XREF: sub_AB53+F
					; sub_AB53:loc_ABEF
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
byte_D0EF:	db 0			; DATA XREF: sub_AB53+32 sub_AFC5+6D
byte_D0F0:	db 0			; DATA XREF: START_POINT+97
byte_D0F1:	db 0			; DATA XREF: sub_8F4D+3C sub_AFC5+85 ...
byte_D0F2:	db 0			; DATA XREF: sub_AFC5+88
					; sub_AFC5+18F ...
byte_D0F3:	db 0			; DATA XREF: sub_8C20-AB9
					; sub_8F4D+28	...
byte_D0F4:	db 0			; DATA XREF: sub_8C20-201
					; sub_8C20-179 ...
ptr_stk_1bvalue:dw 0			; DATA XREF: sub_8C20-9D7
					; sub_8C20-9D2 ...
word_D0F7:	dw 0			; DATA XREF: sub_8C20-B1F
					; sub_8C20-9E4 ...
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
byte_D0FF:	db 0			; DATA XREF: InitBoard_ClearMoves+1
word_D100:	dw 0			; DATA XREF: sub_8C20-532
					; InitBoard_ClearMoves+24	...
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
byte_D108:	db 0			; DATA XREF: sub_AFC5+29
					; sub_BC00:loc_C0AE ...
byte_D109:	db 0			; DATA XREF: sub_C1EF:loc_C1A4
word_D10A:	dw 0			; DATA XREF: sub_BC00+244
					; sub_BC00+254 ...
word_D10C:	dw 0			; DATA XREF: sub_BC00+24B
					; sub_BC00:loc_BE57
		db    0
		db    0
byte_D110:	db 0			; DATA XREF: sub_BC00+4B7
		db    0
word_D112:	dw 0			; DATA XREF: sub_BC00+25A
					; sub_BC00+26A
word_D114:	dw 0			; DATA XREF: sub_BC00+261
					; sub_BC00:loc_BE6D
		db    0
		db    0
byte_D118:	db 0			; DATA XREF: sub_BC00+4BE
		db    0
word_D11A:	dw 0			; DATA XREF: sub_BC00+270
					; sub_BC00+280
word_D11C:	dw 0			; DATA XREF: sub_BC00+277
					; sub_BC00:loc_BE83
		db    0
		db    0
byte_D120:	db 0			; DATA XREF: sub_BC00+4C5
		db    0
word_D122:	dw 0			; DATA XREF: sub_BC00+286
					; sub_BC00+296
word_D124:	dw 0			; DATA XREF: sub_BC00+28D
					; sub_BC00:loc_BE99
		db    0
		db    0
byte_D128:	db 0			; DATA XREF: sub_BC00+4CC
		db    0
word_D12A:	dw 0			; DATA XREF: sub_BC00+29C
					; sub_BC00+2AC
word_D12C:	dw 0			; DATA XREF: sub_BC00+2A3
					; sub_BC00:loc_BEAF
		db    0
		db    0
byte_D130:	db 0			; DATA XREF: sub_BC00+4D3
		db    0
word_D132:	dw 0			; DATA XREF: sub_BC00+2B2
					; sub_BC00+2C2
word_D134:	dw 0			; DATA XREF: sub_BC00+2B9
					; sub_BC00:loc_BEC5
		db    0
		db    0
byte_D138:	db 0			; DATA XREF: sub_BC00+4DA
		db    0
word_D13A:	dw 0			; DATA XREF: sub_BC00+2C8
					; sub_BC00+2D8
word_D13C:	dw 0			; DATA XREF: sub_BC00+2CF
					; sub_BC00:loc_BEDB
		db    0
		db    0
unk_D140:	db    0			; DATA XREF: sub_881D	sub_A94F+7E ...
byte_D141:	db 0			; DATA XREF: sub_BC00+2E9
word_D142:	dw 0			; DATA XREF: sub_BC00+2DE
					; sub_BC00+2EF
word_D144:	dw 0			; DATA XREF: sub_BC00+2E5
					; sub_BC00:loc_BEF2
		db    0
		db    0
unk_D148:	db    0			; DATA XREF: sub_BC00+4ED
byte_D149:	db 0			; DATA XREF: sub_BC00+300
word_D14A:	dw 0			; DATA XREF: sub_BC00+2F5
					; sub_BC00+306
word_D14C:	dw 0			; DATA XREF: sub_BC00+2FC
					; sub_BC00:loc_BF09
		db    0
		db    0
unk_D150:	db    0			; DATA XREF: sub_BC00+4F5
byte_D151:	db 0			; DATA XREF: sub_BC00+317
word_D152:	dw 0			; DATA XREF: sub_BC00+30C
					; sub_BC00+31D
word_D154:	dw 0			; DATA XREF: sub_BC00+313
					; sub_BC00:loc_BF20
		db    0
		db    0
unk_D158:	db    0			; DATA XREF: sub_BC00+4FD
byte_D159:	db 0			; DATA XREF: sub_BC00+32E
word_D15A:	dw 0			; DATA XREF: sub_BC00+323
					; sub_BC00+334
word_D15C:	dw 0			; DATA XREF: sub_BC00+32A
					; sub_BC00:loc_BF37
		db    0
		db    0
unk_D160:	db    0			; DATA XREF: sub_BC00+505
byte_D161:	db 0			; DATA XREF: sub_BC00+345
word_D162:	dw 0			; DATA XREF: sub_BC00+33A
					; sub_BC00+34B
word_D164:	dw 0			; DATA XREF: sub_BC00+341
					; sub_BC00:loc_BF4E
		db    0
		db    0
unk_D168:	db    0			; DATA XREF: sub_BC00+50D
byte_D169:	db 0			; DATA XREF: sub_BC00+35C
word_D16A:	dw 0			; DATA XREF: sub_BC00+351
					; sub_BC00+362
word_D16C:	dw 0			; DATA XREF: sub_BC00+358
					; sub_BC00:loc_BF65
		db    0
		db    0
unk_D170:	db    0			; DATA XREF: sub_BC00+515
byte_D171:	db 0			; DATA XREF: sub_BC00+373
word_D172:	dw 0			; DATA XREF: sub_BC00+368
					; sub_BC00+379
word_D174:	dw 0			; DATA XREF: sub_BC00+36F
					; sub_BC00:loc_BF7C
		db    0
		db    0
unk_D178:	db    0			; DATA XREF: sub_BC00+51D
byte_D179:	db 0			; DATA XREF: sub_BC00+38A
word_D17A:	dw 0			; DATA XREF: sub_BC00+37F
					; sub_BC00+390
word_D17C:	dw 0			; DATA XREF: sub_BC00+386
					; sub_BC00:loc_BF93
		db    0
		db    0
word_D180:	dw 0			; DATA XREF: sub_A94F+31
					; sub_BC00+535
		db    0
		db    0
		db    0
		db    0
		db    0
		db    0
byte_D188:	db 0			; DATA XREF: sub_BC00+30 sub_C1EF-55
byte_D189:	db 0			; DATA XREF: sub_C1EF-5C
word_D18A:	dw 0			; DATA XREF: sub_BC00+E5 sub_BC00+F5
word_D18C:	dw 0			; DATA XREF: sub_BC00+EC
					; sub_BC00:loc_BCF8
		db    0
		db    0
byte_D190:	db 0			; DATA XREF: sub_BC00+37
		db    0
word_D192:	dw 0			; DATA XREF: sub_BC00+FB
					; sub_BC00+10B
word_D194:	dw 0			; DATA XREF: sub_BC00+102
					; sub_BC00:loc_BD0E
		db    0
		db    0
byte_D198:	db 0			; DATA XREF: sub_BC00+3E
		db    0
word_D19A:	dw 0			; DATA XREF: sub_BC00+111
					; sub_BC00+121
word_D19C:	dw 0			; DATA XREF: sub_BC00+118
					; sub_BC00:loc_BD24
		db    0
		db    0
byte_D1A0:	db 0			; DATA XREF: sub_BC00+45
		db    0
word_D1A2:	dw 0			; DATA XREF: sub_BC00+127
					; sub_BC00+137
word_D1A4:	dw 0			; DATA XREF: sub_BC00+12E
					; sub_BC00:loc_BD3A
		db    0
		db    0
byte_D1A8:	db 0			; DATA XREF: sub_BC00+4C
		db    0
word_D1AA:	dw 0			; DATA XREF: sub_BC00+13D
					; sub_BC00+14D
word_D1AC:	dw 0			; DATA XREF: sub_BC00+144
					; sub_BC00:loc_BD50
		db    0
		db    0
byte_D1B0:	db 0			; DATA XREF: sub_BC00+53
		db    0
word_D1B2:	dw 0			; DATA XREF: sub_BC00+153
					; sub_BC00+163
word_D1B4:	dw 0			; DATA XREF: sub_BC00+15A
					; sub_BC00:loc_BD66
		db    0
		db    0
byte_D1B8:	db 0			; DATA XREF: sub_BC00+5A
		db    0
word_D1BA:	dw 0			; DATA XREF: sub_BC00+169
					; sub_BC00+179
word_D1BC:	dw 0			; DATA XREF: sub_BC00+170
					; sub_BC00:loc_BD7C
		db    0
		db    0
;block 0
word_D1C0:	dw 0			; DATA XREF: sub_BC00+65
					; sub_BC00+18A
word_D1C2:	dw 0			; DATA XREF: sub_BC00+17F
					; sub_BC00+190
word_D1C4:	dw 0			; DATA XREF: sub_BC00+186
					; sub_BC00:loc_BD93
		db    0
		db    0
;block 1
word_D1C8:	dw 0			; DATA XREF: sub_BC00+6D
					; sub_BC00+1A1
word_D1CA:	dw 0			; DATA XREF: sub_BC00+196
					; sub_BC00+1A7
word_D1CC:	dw 0			; DATA XREF: sub_BC00+19D
					; sub_BC00:loc_BDAA
		db    0
		db    0
;block 2
word_D1D0:	dw 0			; DATA XREF: sub_BC00+75
					; sub_BC00+1B8
word_D1D2:	dw 0			; DATA XREF: sub_BC00+1AD
					; sub_BC00+1BE
word_D1D4:	dw 0			; DATA XREF: sub_BC00+1B4
					; sub_BC00:loc_BDC1
		db    0
		db    0
;block 3
word_D1D8:	dw 0			; DATA XREF: sub_BC00+7D
					; sub_BC00+1CF
word_D1DA:	dw 0			; DATA XREF: sub_BC00+1C4
					; sub_BC00+1D5
word_D1DC:	dw 0			; DATA XREF: sub_BC00+1CB
					; sub_BC00:loc_BDD8
		db    0
		db    0
;block 4
word_D1E0:	dw 0			; DATA XREF: sub_BC00+85
					; sub_BC00+1E6
word_D1E2:	dw 0			; DATA XREF: sub_BC00+1DB
					; sub_BC00+1EC
word_D1E4:	dw 0			; DATA XREF: sub_BC00+1E2
					; sub_BC00:loc_BDEF
		db    0
		db    0
;block 5
word_D1E8:	dw 0			; DATA XREF: sub_BC00+8D
					; sub_BC00+1FD
word_D1EA:	dw 0			; DATA XREF: sub_BC00+1F2
					; sub_BC00+203
word_D1EC:	dw 0			; DATA XREF: sub_BC00+1F9
					; sub_BC00:loc_BE06
		db    0
		db    0
;block 6
word_D1F0:	dw 0			; DATA XREF: sub_BC00+95
					; sub_BC00+214
word_D1F2:	dw 0			; DATA XREF: sub_BC00+209
					; sub_BC00+21A
word_D1F4:	dw 0			; DATA XREF: sub_BC00+210
					; sub_BC00:loc_BE1D
		db    0
		db    0
;block 7
word_D1F8:	dw 0			; DATA XREF: sub_BC00+9D
					; sub_BC00+22B
word_D1FA:	dw 0			; DATA XREF: sub_BC00+220
					; sub_BC00+231
word_D1FC:	dw 0			; DATA XREF: sub_BC00+227
					; sub_BC00:loc_BE34
		db    0
		db    0

array_D200:	db    0,   0,	0,   0,	  0,   0,   0,	 0 ; DATA XREF:	InitBoard_ClearMoves+4
					; InitBoard_ClearMoves+11	...
		ds 1			; still
		ds 1			; array
		ds 1			; D200
unk_D20B:	ds 1			; DATA XREF: sub_B34B+6
					; sub_B36B:loc_B39E
byte_D20C:	ds 1			; DATA XREF: sub_8C20-B72 ;oldmove #?
					; sub_8C20-535 ...
byte_D20D:	ds #E			; DATA XREF: sub_B2D1+3
					; array	of 14 bytes
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
unk_D229:	ds 1			; DATA XREF: sub_8B66+1E
		ds 1
unk_D22B:	ds 1			; DATA XREF: sub_8B66+1B
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
word_D240:	ds 2			; DATA XREF: sub_8C20-B28
					; sub_8C20-6C2 ...
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
		ds 1
byte_D258:	ds 1			; DATA XREF: sub_A684+23 sub_B2D1 ...
					; array	of 14 bytes
		ds 1
word_D25A:	ds 2			; DATA XREF: sub_8C20-B19
					; sub_8C20-901 ...
byte_D25C:	ds #A			; DATA XREF: sub_B2E2




		ds 0xD300-$

byte_D300:	ds 1			; DATA XREF: sub_8C20-541
					; sub_8C20-1D1
byte_D301:	ds 1			; DATA XREF: sub_8C20-547
					; sub_8C20-1CB
byte_D302:	ds 1			; DATA XREF: sub_8C20-53B
					; sub_8C20-1BA
array_64bytes:	ds #40			; DATA XREF: sub_8C20-52F
					; sub_8C20-1D4
stk_1bvalue:	ds 1			; DATA XREF: START_POINT+94
					; sub_8C20-B6A ...





		ds 0xD800-$
		;stack is upwards
RAM_END_D800:	    			; DATA XREF: START_POINT:loc_8067
					; START_POINT+70 ...
		    
		ds 0xD803-$
tbl_D803:	    			; DATA XREF: sub_8C20:loc_8365
					; sub_8446 ...
					; some 3byte structs, #FF -- end mark
					; sized kilobyte or more




		ds 0xF000-$
unk_F000:	    			; DATA XREF: sub_8446+3 sub_92A0 ...
			


		ds 0xF300-$

		ds 1

BOARD:		ds #40			; DATA XREF: sub_8C20-976 sub_8C6B+E ...
		
		ds 6

BOARD2:		ds #40			; DATA XREF: sub_8C20-979
					; sub_8DE9+58	...
		ds 6

save_SP:	ds 2			; DATA XREF: START_POINT+33
save_HLtick:	ds 2			; DATA XREF: START_POINT+38
save_ERRSP:	ds 2			; DATA XREF: RAM:803E




		ds 0xFEFF-$
INT_VEC:	ds 2




		;savebin "cyrus2_compilable.bin",#8000,#5000
		;labelslist "cyrus2_compilable.lab"
 		;end
       if FIX
	savebin "cyrus960.com",begin,end-begin
       else
	savebin "cyrus2.com",begin,end-begin
       endif
	LABELSLIST "../../../us/user.l",1
