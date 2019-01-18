@echo off
path=..\_sdk\;..\sjasm\

echo ...compiling...
nedolang ../_sdk/read.c ../_sdk/fmttg.h token.c tokenz80.c
type err.f

echo ...tokenizing...
nedotok tok_os.s ../_sdk/read.asm ../_sdk/read.var ../_sdk/fmttg.var token.asm token.var tokenz80.asm tokenz80.var ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i

echo ...assembling...
nedoasm tok_os.S_
rem sjasmplus tok_os.s

type asmerr.f

del tok.com
ren tok_os.bin tok.com
