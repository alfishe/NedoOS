@echo off
path=..\_sdk\

echo ...compiling...
nedolang ../_sdk/fmttg.h export.c exporttg.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok exp.s ../_sdk/fmttg.var export.asm export.var exporttg.asm exporttg.var ../_sdk/lib.i ../_sdk/str.i ../_sdk/io.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/print.i

echo ...assembling...
nedoasm exp.S_
type asmerr.f

pause
