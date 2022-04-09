@echo off
echo build term
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war -DTEXTMODE=0 term.asm
sjasmplus --nologo --msg=war -DTEXTMODE=1 term.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 rem pause
 if "%makeall%"=="" ..\..\us\emul.exe
)