@echo off
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war cmd.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put cmd.com /bin/cmd.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)