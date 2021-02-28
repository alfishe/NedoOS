@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang del.c
type err.f
..\_sdk\nedotok del_os.s del.ast del.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm
..\_sdk\nedoasm del_os.S_
type asmerr.f
move /Y del_os.bin nedodel.com > nul
rem if "%makeall%"=="" (pause)
