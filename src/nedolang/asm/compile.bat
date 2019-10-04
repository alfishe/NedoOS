@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c ../_sdk/io.c
type err.f
nedotok asm.s ../_sdk/emit.ast ../_sdk/emit.var ../_sdk/fmttg.var asm.ast asm.var asmloop.ast asmloop.var ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i
nedoasm asm.S_
type asmerr.f
nedodel asm.pst
movedisk
diff nedoasm asm.bin
pause
