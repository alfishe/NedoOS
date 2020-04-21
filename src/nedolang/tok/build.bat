@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c
type err.f
..\_sdk\nedotok tok_os.s ../_sdk/read.ast ../_sdk/read.var ../_sdk/fmttg.var token.ast token.var tokenz80.ast tokenz80.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm
..\_sdk\nedoasm tok_os.S_
type asmerr.f
move /Y tok_os.bin tok.com > nul
if "%currentdir%"=="" (pause)
