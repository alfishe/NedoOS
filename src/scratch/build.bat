if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war --syntax=m scratch.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)