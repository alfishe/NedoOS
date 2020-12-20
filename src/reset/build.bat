if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war reset.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put %%j /bin/%%j
 )
 rem if "%makeall%"=="" ..\..\us\emul.exe
)