@echo off
echo build netterm
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war term.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 rem pause
 if "%makeall%"=="" start ..\..\us\emul.exe
)