@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c
type err.f
nedotok tok.s ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/str.i
nedoasm tok.S_
type asmerr.f
diff nedotok tok.bin
pause
