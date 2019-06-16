@echo off
path =..\_sdk\;..\..\_sdk\

nedolang batch.c
type err.f

nedotok batch.s batch.ast batch.var ../_sdk/lib.i ../_sdk/iofast.i

nedoasm batch.S_
type asmerr.f

pause
