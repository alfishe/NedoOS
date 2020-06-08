;startup
	org 0x0000
	include "cmdlist.var"
	include "state.ast"
        DW CMD_DONE

sin
        DW CMD_CONST,sin.A.
        DW CMD_READVAR
        DW CMD_RST,RST_SIN
        DW CMD_RET
cos
        DW CMD_CONST,cos.A.
        DW CMD_READVAR
        DW CMD_RST,RST_COS
        DW CMD_RET
atan
        DW CMD_CONST,atan.A.
        DW CMD_READVAR
        DW CMD_RST,RST_ATAN
        DW CMD_RET
atan2
        DW CMD_CONST,atan2.A.
        DW CMD_READVAR
        DW CMD_CONST,atan2.B.
        DW CMD_READVAR
        DW CMD_RST,RST_ATAN2
        DW CMD_RET
exp
        DW CMD_CONST,exp.A.
        DW CMD_READVAR
        DW CMD_RST,RST_EXP
        DW CMD_RET
log
        DW CMD_CONST,log.A.
        DW CMD_READVAR
        DW CMD_RST,RST_LOG
        DW CMD_RET
sqrt
        DW CMD_CONST,sqrt.A.
        DW CMD_READVAR
        DW CMD_RST,RST_SQRT
        DW CMD_RET
abs
        DW CMD_CONST,abs.A.
        DW CMD_READVAR
        DW CMD_RST,RST_ABS
        DW CMD_RET
        
        org 0x0000
	include "state.var"
exp.A.
log.A.
sqrt.A.
abs.A.
sin.A.
cos.A.
atan.A.
atan2.A.
        dw 0
atan2.B.
        dw 0
