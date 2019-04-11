set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..\..
path=%currentdir%\..\tools\;%currentdir%\_sdk\

nedores spriteset.bmp spriteset.txt spriteset.ast
nedores tileset.bmp tileset.txt tileset.ast

sjasmplus --nologo main.asm

if "%wascurrentdir%"=="" (pause)
