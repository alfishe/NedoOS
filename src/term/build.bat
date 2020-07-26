@echo off
echo build term
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war term.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put term.com /bin/term.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)