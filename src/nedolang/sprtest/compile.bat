@echo off
if "%settedpath%"=="" call "..\_sdk\setpath.bat"
nedores testpic.bmp testpic.da testpic.ast
nedolang spr.c
type err.f
nedotok main.s ../_sdk/sprite.i spr.ast spr.var ../_sdk/pt3play.i ../_sdk/ayfxplay.i ../_sdk/lib.i ../_sdk/runtime.i testpic.ast
nedoasm main.S_
type asmerr.f
pause
