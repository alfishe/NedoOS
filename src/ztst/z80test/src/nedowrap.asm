; NedoOS wrapper for Z80 test by Patrik Rak
;
; Copyright (C) 2025 lvd^mhm
;
; This source code is released under the MIT license, see included license.txt.

        DEVICE ZXSPECTRUM128
        include "../_sdk/sys_h.asm"

DST_ADDR=0x8000
STK_ADDR=0xFFFD
		ld	sp,STK_ADDR
		call	initstdio

		; move code to its place
		ld	hl,code_end-1
		ld	de,DST_ADDR+code_end-code_beg-1
		ld	bc,code_end-code_beg
		lddr

		;clear memory
		ld	hl,code_beg
		ld	de,code_beg+1
		ld	bc,DST_ADDR-code_beg-1
		ld	(hl),0
		ldir

		ld	hl,DST_ADDR+code_end-code_beg
		ld	de,DST_ADDR+code_end-code_beg+1
		ld	bc,0xFFFF-(DST_ADDR+code_end-code_beg)
		ld	(hl),0
		ldir

		;jump to code
		jp	DST_ADDR
		
EMU_CHAN_OPEN:	
		ret

EMU_QUIT:
		QUIT

EMU_RST_10:	;iy,de,bc are already pushed
		exx
		exa
		push	af
		push	bc
		push	de
		push	hl
		exx
		exa

		push	hl
		push	ix
		push	af ; here is char to print
		ei

.skip=$+1
		ld	a,0
		or	a
		jr	z,.skipe
		dec	a
		ld	(.skip),a
		jr	.skipdo

.skipe
		pop	af
		push	af

		cp	23
		jr	nz,.noat
		
		ld	a,2
		ld	(.skip),a
		ld	a,32
.noat
		cp	13
		jr	nz,.normal_print
		PRCHAR_
		ld	a,10
.normal_print
		PRCHAR_


.skipdo
		di
		pop	af
		pop	ix
		pop	hl

		exx
		exa
		pop	hl
		pop	de
		pop	bc
		pop	af
		exx
		exa
		ret

        include "../_sdk/stdio.asm"

