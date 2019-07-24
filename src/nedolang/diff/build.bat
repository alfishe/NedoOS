@echo off
path=..\_sdk\;..\..\_sdk\
nedolang diff.c
type err.f
nedotok diff_os.s diff.ast diff.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../_sdk/print_os.i ../../_sdk/sysdefs.asm
nedoasm diff_os.S_
type asmerr.f
move diff_os.bin diff.com > nul
if "%currentdir%"=="" (pause)
