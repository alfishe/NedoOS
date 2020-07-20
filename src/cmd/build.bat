@echo off
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war cmd.asm
if "%currentdir%"=="" (pause)
