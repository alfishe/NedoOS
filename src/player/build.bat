rem ..\..\tools\make.exe %1 %2

if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war player.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 
 FOR %%j IN (*.etc) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 rem pause
 if "%makeall%"=="" ..\..\us\emul.exe
)