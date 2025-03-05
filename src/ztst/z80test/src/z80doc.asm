; Z80 test - officially documented flags version.
;
; Copyright (C) 2012-2023 Patrik Rak (patrik@raxoft.cz)
;
; This source code is released under the MIT license, see included license.txt.
        DEVICE ZXSPECTRUM128
        include "../../_sdk/sys_h.asm"

DST_ADDR=0x8000
STK_ADDR=0xFFFD

		org	0x100
cmd_begin:

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
		push	hl
		push	ix
		push	af

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
		pop	af
		pop	ix
		pop	hl
		ret



        include "../../_sdk/stdio.asm"

code_beg:
            macro       testname
            db          "doc"
            endm

maskflags   equ         1
onlyflags   equ         0
postccf     equ         0
memptr      equ         0

		DISP	DST_ADDR
		include     main.asm
		ENT
code_end:

cmd_end:

	savebin "z80doc.com",cmd_begin,cmd_end-cmd_begin


; EOF ;
