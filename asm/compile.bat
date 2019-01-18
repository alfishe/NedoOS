@echo off
path=..\_sdk\

echo ...compiling...
nedolang ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c ../_sdk/io.c
type err.f

echo ...tokenizing...
nedotok asm.s ../_sdk/emit.asm ../_sdk/emit.var ../_sdk/fmttg.var asm.asm asm.var asmloop.asm asmloop.var ../_sdk/lib.i ../_sdk/iofast.i ../_sdk/io.asm ../_sdk/io.var ../_sdk/str.i

echo ...assembling...
nedoasm asm.S_
type asmerr.f

nedodel asm.pst
movedisk

diff nedoasm asm.bin

pause
