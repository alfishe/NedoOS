@echo off
if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
sjasmplus --nologo --msg=war -DCLIENT=1 main.asm
sjasmplus --nologo --msg=war -DCLIENT=0 main.asm
if "%currentdir%"=="" (pause)
