rem copy lanscape.b zanscape.b
rem do nothing
rem tok.com tok_os.s
rem asm.com tok_os.S_
comp ../_sdk/emit.c commands.c
type err.f

echo ...tokenizing...
tok compc_os.s ../_sdk/emit.asm ../_sdk/emit.var commands.asm commands.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i

echo ...assembling...
asm compc_os.S_
type asmerr.f

pause

echo ...compiling...
comp ../_sdk/read.c compile.c
type err.f

echo ...tokenizing...
tok comp_os.s ../_sdk/read.asm ../_sdk/read.var compile.asm compile.var

echo ...assembling...
asm comp_os.S_
