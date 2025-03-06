; Z80 test - post CCF version.
;
; Copyright (C) 2012-2023 Patrik Rak (patrik@raxoft.cz)
;
; This source code is released under the MIT license, see included license.txt.

		org	0x100
cmd_begin:

		include	"nedowrap.asm"

code_beg:
            macro       testname
            db          "CCF"
            endm

maskflags   equ         0
onlyflags   equ         1
postccf     equ         1
memptr      equ         0

		DISP	DST_ADDR
		include     main.asm
		ENT
code_end:

cmd_end:

	savebin "z80ccf.com",cmd_begin,cmd_end-cmd_begin


; EOF ;
