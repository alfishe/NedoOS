@echo off
echo build tp
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war tp.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.msg) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.pas) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.inc) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)