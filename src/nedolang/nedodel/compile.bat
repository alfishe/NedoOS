@echo off
path=..\_sdk\

echo ...compiling...
nedolang del.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok del.s del.ast del.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i

echo ...assembling...
nedoasm del.S_
type asmerr.f

pause
