@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c
type err.f
..\_sdk\nedotok asm_os.s ../_sdk/emit.ast ../_sdk/emit.var ../_sdk/fmttg.var asm.ast asm.var asmloop.ast asmloop.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm
..\_sdk\nedoasm asm_os.S_
type asmerr.f
move asm_os.bin asm.com > nul
