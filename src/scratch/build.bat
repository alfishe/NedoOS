set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..
path=%currentdir%\..\sjasm\;%currentdir%\..\us\;%currentdir%\..\tools\

sjasmplus --nologo scratch.asm

if "%wascurrentdir%"=="" (pause)
