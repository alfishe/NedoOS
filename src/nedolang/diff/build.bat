@echo off
path=..\_sdk\

echo ...compiling...
nedolang diff.c
type err.f

echo ...tokenizing...
nedotok diff_os.s diff.ast diff.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../_sdk/print_os.i ../_sdk/sysdefs.asm

echo ...assembling...
nedoasm diff_os.S_
type asmerr.f

del diff.com
ren diff_os.bin diff.com

if "%currentdir%"=="" (pause)
