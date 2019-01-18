@echo off
path=..\_sdk\

echo ...compiling...
nedolang ../_sdk/emit.c commands.c
type err.f

echo ...tokenizing...
nedotok compc_os.s ../_sdk/emit.asm ../_sdk/emit.var commands.asm commands.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i

rem nedodel emit.asm
rem nedodel emit.var
rem nedodel commands.asm
rem nedodel commands.var

echo ...assembling...
nedoasm compc_os.S_
type asmerr.f

rem nedodel emit.A_
rem nedodel emit.V_
rem nedodel commands.A_
rem nedodel commands.V_
rem nedodel lib.I_
rem nedodel err.f
rem nedodel asmerr.f

echo ...compiling...
nedolang ../_sdk/read.c compile.c
type err.f

echo ...tokenizing...
nedotok comp_os.s ../_sdk/read.asm ../_sdk/read.var compile.asm compile.var

echo ...assembling...
nedoasm comp_os.S_
type asmerr.f

del comp.com
ren comp_os.bin comp.com
