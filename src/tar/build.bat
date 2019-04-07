set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..
path=%currentdir%\..\sjasm\;%currentdir%\..\us\;%currentdir%\..\tools\

sjasmplus --nologo tar.asm

if "%wascurrentdir%"=="" (pause)
