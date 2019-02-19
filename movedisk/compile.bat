@echo off
path=..\_sdk\

echo ...compiling...
nedolang movedisk.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok movedisk.s movedisk.ast movedisk.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.ast ../_sdk/io.var ../_sdk/str.i

echo ...assembling...
nedoasm movedisk.S_
type asmerr.f

pause
