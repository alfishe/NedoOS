@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
nedolang ../_sdk/fmttg.h export.c exporttg.c ../_sdk/io.c
type err.f
nedotok exp.s ../_sdk/fmttg.var export.ast export.var exporttg.ast exporttg.var ../_sdk/lib.i ../_sdk/str.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/print.i
nedoasm exp.S_
type asmerr.f
pause
