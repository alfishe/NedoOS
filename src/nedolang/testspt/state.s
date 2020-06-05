;startup
	org 0x0000
	include "state.ast"
        DW CMD_DONE

        org 0x0001
	include "state.var"
