if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war conv.asm -DCONVBACK=1
sjasmplus --nologo --msg=war conv.asm -DCONVBACK=0

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
rem pause
 if "%makeall%"=="" ..\..\us\emul.exe
)