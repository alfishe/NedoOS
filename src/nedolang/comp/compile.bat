@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/emit.c ../_sdk/fmttg.h commands.c
type err.f
nedotok compcode.s ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/str.i lbltype.i
nedoasm compcode.S_
type asmerr.f
nedodel compcode.A_
nedodel emit.A_
nedodel emit.V_
del *.ast
nedoexp commands.A_
ren exp.f commands.ast
nedoexp compile.A_
ren exp.f compile.ast
nedodel commands.A_
nedodel commands.V_
nedodel lib.I_
nedodel err.f
nedodel asmerr.f
movedisk
pause
nedolang ../_sdk/read.c compile.c
type err.f
nedotok comp.s
nedoasm comp.S_
type asmerr.f
diff nedolang comp.bin
del compcode.bin
pause
