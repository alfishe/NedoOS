@echo off
path=..\sjasm\;..\us\;..\tools\
sjasmplus --nologo main.asm
del code.c
mhmt -mlz syscode.c
copy /b initcode.c + syscode.c.mlz code.c
del initcode.c
del syscode.c
del syscode.c.mlz

if "%currentdir%"=="" (pause)
