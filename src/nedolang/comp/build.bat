@echo off
path=..\_sdk\;..\..\_sdk\

nedolang ../_sdk/emit.c commands.c
type err.f

nedotok compc_os.s ../_sdk/emit.ast ../_sdk/emit.var commands.ast commands.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm

nedoasm compc_os.S_
type asmerr.f

nedolang ../_sdk/read.c compile.c
type err.f

nedotok comp_os.s ../_sdk/read.ast ../_sdk/read.var compile.ast compile.var

nedoasm comp_os.S_
type asmerr.f

del compc_os.bin
move comp_os.bin comp.com > nul

if "%currentdir%"=="" (pause)
