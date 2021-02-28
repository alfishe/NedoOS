@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang movedisk.c
type err.f
..\_sdk\nedotok move_os.s movedisk.ast movedisk.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm
..\_sdk\nedoasm move_os.S_
type asmerr.f
move /Y move_os.bin movedisk.com > nul
rem if "%makeall%"=="" (pause)
