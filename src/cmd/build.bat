@echo off
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war cmd.asm
rem if "%currentdir%"=="" (pause)
