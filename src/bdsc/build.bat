@echo off
echo build cc
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war cc.asm
sjasmplus --nologo --msg=war cc2.asm
sjasmplus --nologo --msg=war clink.asm
sjasmplus --nologo --msg=war mkccc.asm
sjasmplus --nologo --msg=war deff2a.csm
sjasmplus --nologo --msg=war deffgfx.csm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.c) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.h) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.ccc) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (*.crl) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 FOR %%j IN (cc.bat) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)