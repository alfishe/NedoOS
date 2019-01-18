@echo off
path=..\_sdk\

nedores testpic.bmp testpic.txt testpic.asm

echo ...compiling...
nedolang spr.c
type err.f

echo ...tokenizing...
nedotok main.s ../_sdk/sprite.i font.asm spr.asm spr.var ../_sdk/pt3play.i ../_sdk/ayfxplay.i ../_sdk/lib.i ../_sdk/runtime.i testpic.asm

echo ...assembling...
nedoasm main.S_
type asmerr.f

pause
