@echo off
echo build cc
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war cc.asm
sjasmplus --nologo --msg=war cc2.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.c) DO (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.h) DO (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)