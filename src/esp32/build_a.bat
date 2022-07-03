if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war esp32_a.asm
rem sjasmplus --nologo --msg=war esp32_a.asm --raw=esp32_a.com

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 pause
rem if "%makeall%"=="" ..\..\us\emul.exe
)