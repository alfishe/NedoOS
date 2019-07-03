set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..\..
path=%currentdir%\..\tools\

sjasmplus --nologo main.asm

if "%wascurrentdir%"=="" (pause)
