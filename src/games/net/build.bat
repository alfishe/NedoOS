@echo off
if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
sjasmplus --nologo --msg=war master.asm
sjasmplus --nologo --msg=war slave.asm
if "%currentdir%"=="" (pause)
