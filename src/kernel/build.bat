@echo off
echo build kernel
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war main.asm
del code.c
mhmt -mlz syscode.c > nul
copy /b initcode.c + syscode.c.mlz code.c > nul
del initcode.c
del syscode.c
del syscode.c.mlz
sjasmplus --nologo --msg=war hobeta.asm
rem sjasmplus --nologo --msg=war term.asm

if "%currentdir%"=="" (pause)
