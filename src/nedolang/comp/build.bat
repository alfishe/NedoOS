@echo off
path=..\_sdk\

echo ...compiling...
nedolang ../_sdk/emit.c commands.c
type err.f

echo ...tokenizing...
nedotok compc_os.s ../_sdk/emit.ast ../_sdk/emit.var commands.ast commands.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../_sdk/sysdefs.asm

echo ...assembling...
nedoasm compc_os.S_
type asmerr.f

echo ...compiling...
nedolang ../_sdk/read.c compile.c
type err.f

echo ...tokenizing...
nedotok comp_os.s ../_sdk/read.ast ../_sdk/read.var compile.ast compile.var

echo ...assembling...
nedoasm comp_os.S_
type asmerr.f

del comp.com
ren comp_os.bin comp.com

if "%currentdir%"=="" (pause)
