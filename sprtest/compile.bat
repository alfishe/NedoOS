@echo off
path=..\_sdk\

nedores testpic.bmp testpic.txt testpic.ast

echo ...compiling...
nedolang spr.c
type err.f

echo ...tokenizing...
nedotok main.s ../_sdk/sprite.i spr.ast spr.var ../_sdk/pt3play.i ../_sdk/ayfxplay.i ../_sdk/lib.i ../_sdk/runtime.i testpic.ast

echo ...assembling...
nedoasm main.S_
type asmerr.f

pause
