@echo off
path=..\_sdk\

echo ...compiling...
nedolang ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok tok.s ../_sdk/read.asm ../_sdk/read.var ../_sdk/fmttg.var token.asm token.var tokenz80.asm tokenz80.var ../_sdk/lib.i ../_sdk/io.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/str.i

echo ...assembling...
nedoasm tok.S_
type asmerr.f

diff nedotok tok.bin

pause
