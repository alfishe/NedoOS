; Z80 test - MEMPTR version.
;
; However note that the current set of tests was not designed to stress test MEMPTR
; particularly, so it doesn't detect much - I may eventually add such specific tests later.
;
; Copyright (C) 2012-2023 Patrik Rak (patrik@raxoft.cz)
;
; This source code is released under the MIT license, see included license.txt.

		org	0x100
cmd_begin:

		include	"nedowrap.asm"

code_beg:
            macro       testname
            db          "MEMPTR"
            endm

maskflags   equ         0
onlyflags   equ         1
postccf     equ         0
memptr      equ         1

		DISP	DST_ADDR
		include     main.asm
		ENT
code_end:

cmd_end:

	savebin "z80memptr.com",cmd_begin,cmd_end-cmd_begin


; EOF ;
