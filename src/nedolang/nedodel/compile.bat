@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang del.c
type err.f
nedotok del.s ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/str.i
nedoasm del.S_
type asmerr.f
pause
