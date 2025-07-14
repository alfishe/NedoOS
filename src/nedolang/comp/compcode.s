FCB1=0x4800 ;aligned ;len=0x0200*files
DOSBUF=0xff00 ;aligned
        EXPORT FCB1
        EXPORT DOSBUF
;code generator for compiler
	org 0x6003
	;EXPORT emitdig
	include "../_sdk/fmttg.var"
	include "../_sdk/emit.ast"
	;include "regs.ast"
	;include "codez80.ast"
	include "commands.ast"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	include "../_sdk/iofast.i"
	;include "../_sdk/io.ast"

	;include "../_sdk/io.var"
	include "../_sdk/emit.var"
	;include "regs.var"
	;include "codez80.var"
	include "commands.var"
	include "lbltype.i"
