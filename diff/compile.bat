@echo off
path=..\_sdk\

echo ...compiling...
nedolang diff.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok diff.s diff.asm diff.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/print.i

echo ...assembling...
nedoasm diff.S_
type asmerr.f

pause
