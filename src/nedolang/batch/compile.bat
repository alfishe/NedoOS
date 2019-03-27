@echo off
path =..\_sdk\;..\..\_sdk\

echo ...compiling...
nedolang batch.c
type err.f

echo ...tokenizing...
nedotok batch.s batch.ast batch.var ../_sdk/lib.i ../_sdk/iofast.i

echo ...assembling...
nedoasm batch.S_
type asmerr.f

pause
