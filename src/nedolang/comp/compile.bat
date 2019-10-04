@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/emit.c ../_sdk/io.c commands.c
type err.f
nedotok compcode.s ../_sdk/emit.ast ../_sdk/emit.var commands.ast commands.var ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i
nedodel emit.ast
nedodel emit.var
nedodel commands.ast
nedodel commands.var
nedodel io.ast
nedodel io.var
movedisk
nedoasm compcode.S_
type asmerr.f
nedodel compcode.A_
nedodel emit.A_
nedodel emit.V_
nedodel commands.A_
nedodel commands.V_
nedodel lib.I_
nedodel io.I_
nedodel io.A_
nedodel io.V_
nedodel err.f
nedodel asmerr.f
movedisk
pause
nedolang ../_sdk/read.c compile.c
type err.f
nedotok comp.s ../_sdk/read.ast ../_sdk/read.var compile.ast compile.var
nedoasm comp.S_
type asmerr.f
diff nedolang comp.bin
del compcode.bin
pause
