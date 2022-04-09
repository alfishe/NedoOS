@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
rem nedotrd basics.trd -a 1125vert.fnt
nedolang batch.c
type err.f
nedotok batch.s batch.ast batch.var ../_sdk/lib.i ../_sdk/iofast.i
nedoasm batch.S_
type asmerr.f
pause
