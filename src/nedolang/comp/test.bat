rem copy lanscape.b zanscape.b
rem do nothing
rem tok.com tok_os.s
rem asm.com tok_os.S_
comp ../_sdk/emit.c commands.c
type err.f

tok compc_os.s ../_sdk/emit.ast ../_sdk/emit.var commands.ast commands.var
tok ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm

asm compc_os.S_
type asmerr.f

pause

comp ../_sdk/read.c compile.c
type err.f

tok comp_os.s ../_sdk/read.ast ../_sdk/read.var compile.ast compile.var

asm comp_os.S_
