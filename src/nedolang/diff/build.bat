@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang diff.c
type err.f
..\_sdk\nedotok diff_os.s diff.ast diff.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../_sdk/print_os.i ../../_sdk/sysdefs.asm
..\_sdk\nedoasm diff_os.S_
type asmerr.f
move /Y diff_os.bin diff.com > nul
if "%currentdir%"=="" (pause)
