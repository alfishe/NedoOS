@echo off
path=..\_sdk\

echo ...compiling...
nedolang del.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok del.s del.asm del.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/str.i

echo ...assembling...
nedoasm del.S_
type asmerr.f

pause
