@echo off
if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo main.asm
del code.c
%mhmt% -mlz syscode.c > nul
copy /b initcode.c + syscode.c.mlz code.c > nul
del initcode.c
del syscode.c
del syscode.c.mlz
cd ..
%sjasmplus% --nologo kernel/hobeta.asm
if "%currentdir%"=="" (pause)
