FCB1=0x4800 ;aligned ;len=0x0200*files
DOSBUF=0xff00 ;aligned
        EXPORT FCB1
        EXPORT DOSBUF
;code generator for compiler
	org 0x6003
	;EXPORT emitdig
	include "../_sdk/emit.asm"
	;include "regs.asm"
	;include "codez80.asm"
	include "commands.asm"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	include "../_sdk/iofast.i"
	;include "../_sdk/io.asm"

	;include "../_sdk/io.var"
	include "../_sdk/emit.var"
	;include "regs.var"
	;include "codez80.var"
	include "commands.var"
