@echo off
path =..\_sdk\;..\..\_sdk\
nedolang diff.c ../_sdk/io.c
type err.f
nedotok diff.s diff.ast diff.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/print.i ../_sdk/str.i
nedoasm diff.S_
type asmerr.f
pause
