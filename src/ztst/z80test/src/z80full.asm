; Z80 test - the full version.
;
; Copyright (C) 2012-2023 Patrik Rak (patrik@raxoft.cz)
;
; This source code is released under the MIT license, see included license.txt.

		org	0x100
cmd_begin:

		include	"nedowrap.asm"

code_beg:
            macro       testname
            db          "full"
            endm

maskflags   equ         0
onlyflags   equ         0
postccf     equ         0
memptr      equ         0

		DISP	DST_ADDR
		include     main.asm
		ENT
code_end:

cmd_end:

	savebin "z80full.com",cmd_begin,cmd_end-cmd_begin


; EOF ;
