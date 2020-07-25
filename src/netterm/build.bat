@echo off
echo build netterm
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war term.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put netterm.com /bin/netterm.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)