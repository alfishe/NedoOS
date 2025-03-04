; Z80 test - flags only version.
;
; Copyright (C) 2012-2023 Patrik Rak (patrik@raxoft.cz)
;
; This source code is released under the MIT license, see included license.txt.
        DEVICE ZXSPECTRUM128

            macro       testname
            db          "flags"
            endm

maskflags   equ         0
onlyflags   equ         1
postccf     equ         0
memptr      equ         0

            include     main.asm
main_end:

	savebin "z80flags.bin",main,main_end-main

; EOF ;
