@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/fmttg.h export.c exporttg.c ../_sdk/io.c
type err.f
nedotok exp.s ../_sdk/lib.i ../_sdk/str.i ../_sdk/io.i ../_sdk/print.i
nedoasm exp.S_
type asmerr.f
pause
