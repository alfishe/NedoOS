if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
sjasmplus --nologo --msg=war main.asm

if "%currentdir%"=="" (
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put untangle.com /nedogame/untangle.com
 pause
 if "%makeall%"=="" ..\..\..\us\emul.exe
)