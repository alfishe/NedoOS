@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang movedisk.c
type err.f
nedotok movedisk.s ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/str.i
nedoasm movedisk.S_
type asmerr.f
pause
