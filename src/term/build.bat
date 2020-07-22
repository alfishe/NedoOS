@echo off
echo build term
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war term.asm

if "%currentdir%"=="" (pause)
