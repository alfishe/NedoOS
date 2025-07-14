@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c
type err.f
nedotok asm.s ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/str.i findlbl.i
nedoasm asm.S_
type asmerr.f
diff nedoasm asm.bin
pause
