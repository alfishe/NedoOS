@echo off
path=..\_sdk\

echo ...compiling...
nedolang ../_sdk/emit.c ../_sdk/fmttg.h asm.c asmloop.c
type err.f

echo ...tokenizing...
nedotok asm_os.s ../_sdk/emit.asm ../_sdk/emit.var ../_sdk/fmttg.var asm.asm asm.var asmloop.asm asmloop.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i

echo ...assembling...
nedoasm asm_os.S_
type asmerr.f

del asm.com
ren asm_os.bin asm.com
