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
        
acos
	DW CMD_CONST,acos.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ACOS
	DW CMD_RET
        
acosh
	DW CMD_CONST,acosh.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ACOSH
	DW CMD_RET
        
asin
	DW CMD_CONST,asin.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ASIN
	DW CMD_RET
        
asinh
	DW CMD_CONST,asinh.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ASINH
	DW CMD_RET
        
atanh
	DW CMD_CONST,atanh.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ATANH
	DW CMD_RET
        
cbrt
	DW CMD_CONST,cbrt.A.
	DW CMD_READVAR
	DW CMD_RST,RST_CBRT
	DW CMD_RET
        
ceil
	DW CMD_CONST,ceil.A.
	DW CMD_READVAR
	DW CMD_RST,RST_CEIL
	DW CMD_RET
        
cosh
	DW CMD_CONST,cosh.A.
	DW CMD_READVAR
	DW CMD_RST,RST_COSH
	DW CMD_RET
        
hypot
	DW CMD_CONST,hypot.A.
	DW CMD_READVAR
	DW CMD_CONST,hypot.B.
	DW CMD_READVAR
	DW CMD_RST,RST_HYPOT
	DW CMD_RET
        
isfinite
	DW CMD_CONST,isfinite.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ISFINITE
	DW CMD_RET
        
isinf
	DW CMD_CONST,isinf.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ISINF
	DW CMD_RET
        
isnan
	DW CMD_CONST,isnan.A.
	DW CMD_READVAR
	DW CMD_RST,RST_ISNAN
	DW CMD_RET
        
j0
	DW CMD_CONST,j0.A.
	DW CMD_READVAR
	DW CMD_RST,RST_J0
	DW CMD_RET
        
j1
	DW CMD_CONST,j1.A.
	DW CMD_READVAR
	DW CMD_RST,RST_J1
	DW CMD_RET
        
jn
	DW CMD_CONST,jn.A.
	DW CMD_READVAR
	DW CMD_CONST,jn.B.
	DW CMD_READVAR
	DW CMD_RST,RST_JN
	DW CMD_RET
        
log10
	DW CMD_CONST,log10.A.
	DW CMD_READVAR
	DW CMD_RST,RST_LOG10
	DW CMD_RET
        
log1p
	DW CMD_CONST,log1p.A.
	DW CMD_READVAR
	DW CMD_RST,RST_LOG1P
	DW CMD_RET
        
logb
	DW CMD_CONST,logb.A.
	DW CMD_READVAR
	DW CMD_RST,RST_LOGB
	DW CMD_RET
        
max
	DW CMD_CONST,max.A.
	DW CMD_READVAR
	DW CMD_CONST,max.B.
	DW CMD_READVAR
	DW CMD_RST,RST_MAX
	DW CMD_RET
        
min
	DW CMD_CONST,min.A.
	DW CMD_READVAR
	DW CMD_CONST,min.B.
	DW CMD_READVAR
	DW CMD_RST,RST_MIN
	DW CMD_RET
        
rint
	DW CMD_CONST,rint.A.
	DW CMD_READVAR
	DW CMD_RST,RST_RINT
	DW CMD_RET
        
sinh
	DW CMD_CONST,sinh.A.
	DW CMD_READVAR
	DW CMD_RST,RST_SINH
	DW CMD_RET
        
tan
	DW CMD_CONST,tan.A.
	DW CMD_READVAR
	DW CMD_RST,RST_TAN
	DW CMD_RET
        
tanh
	DW CMD_CONST,tanh.A.
	DW CMD_READVAR
	DW CMD_RST,RST_TANH
	DW CMD_RET
        
y0
	DW CMD_CONST,y0.A.
	DW CMD_READVAR
	DW CMD_RST,RST_Y0
	DW CMD_RET
        
y1
	DW CMD_CONST,y1.A.
	DW CMD_READVAR
	DW CMD_RST,RST_Y1
	DW CMD_RET
        
yn
	DW CMD_CONST,yn.A.
	DW CMD_READVAR
	DW CMD_CONST,yn.B.
	DW CMD_READVAR
	DW CMD_RST,RST_YN
	DW CMD_RET
        
pow
	DW CMD_CONST,pow.A.
	DW CMD_READVAR
	DW CMD_CONST,pow.B.
	DW CMD_READVAR
	DW CMD_RST,RST_POW
	DW CMD_RET
        
print
	DW CMD_CONST,print.A.
	DW CMD_READVAR
	DW CMD_RST,RST_PRINT
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
acos.A.
acosh.A.
asin.A.
asinh.A.
atanh.A.
cbrt.A.
ceil.A.
cosh.A.
hypot.A.
isfinite.A.
isinf.A.
isnan.A.
j0.A.
j1.A.
jn.A.
log10.A.
log1p.A.
logb.A.
max.A.
min.A.
rint.A.
sinh.A.
tan.A.
tanh.A.
y0.A.
y1.A.
yn.A.
pow.A.
print.A.
	dw 0
atan2.B.
hypot.B.
jn.B.
max.B.
min.B.
yn.B.
pow.B.
	dw 0
