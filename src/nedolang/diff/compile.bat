@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang diff.c
type err.f
nedotok diff.s ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/print.i ../_sdk/str.i
nedoasm diff.S_
type asmerr.f
pause
