@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang movedisk.c ../_sdk/io.c
type err.f
nedotok movedisk.s movedisk.ast movedisk.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i
nedoasm movedisk.S_
type asmerr.f
pause
