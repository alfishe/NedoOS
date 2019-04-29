set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..
path=%currentdir%\..\sjasm\;%currentdir%\..\us\;%currentdir%\..\tools\

sjasmplus --nologo zxrar.asm

if "%wascurrentdir%"=="" (pause)
