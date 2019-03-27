@echo off
set wascurrentdir=%currentdir%
if "%currentdir%"=="" set currentdir=..
path=%currentdir%\..\sjasm\;%currentdir%\..\us\;%currentdir%\..\tools\

sjasmplus --nologo main.asm
del code.c
mhmt -mlz syscode.c > nul
copy /b initcode.c + syscode.c.mlz code.c > nul
del initcode.c
del syscode.c
del syscode.c.mlz

if "%wascurrentdir%"=="" (pause)
