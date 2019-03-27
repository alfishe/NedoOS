FCB1=0xe800 ;aligned ;len=0x0200*files
DOSBUF=0xfe00 ;aligned
	include "../../_sdk/sysdefs.asm"
;COMMANDLINE=0x0080
;COMMANDLINE_sz=0x0080
;PROGSTART=0x0100
        EXPORT FCB1
        EXPORT DOSBUF
;code generator for compiler
	org PROGSTART+3
	include "../_sdk/emit.ast"
	include "commands.ast"
	include "../_sdk/lib.i"
	include "../_sdk/str.i"
	include "../_sdk/io_os.i"

	include "../_sdk/emit.var"
	include "commands.var"
