@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang ../_sdk/fmttg.h export.c exporttg.c
type err.f
..\_sdk\nedotok exp_os.s ../_sdk/fmttg.var export.ast export.var exporttg.ast exporttg.var ../_sdk/lib.i ../_sdk/str.i ../_sdk/io_os.i
..\_sdk\nedoasm exp_os.S_
type asmerr.f
move /Y exp_os.bin exp.com > nul
if "%currentdir%"=="" (pause)
