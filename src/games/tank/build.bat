set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..\..
path=%currentdir%\..\tools\;%currentdir%\_sdk\

nedores sprset.bmp sprset.dat sprset.ast
nedores tileset.bmp tileset.dat tileset.ast

sjasmplus --nologo main.asm

if "%wascurrentdir%"=="" (pause)
