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

if "%currentdir%"=="" (
 copy /Y nedoos.$c "../../release/sd_boot.$c" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put nedoos.$c /sd_boot.$c
 rem "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put nedoos.$c /osatm2hd.$c
 rem pause
 rem if "%makeall%"=="" ..\..\us\emulatm2.bat
 if "%makeall%"=="" ..\..\us\emul.exe
)