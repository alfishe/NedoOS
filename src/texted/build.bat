if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war texted.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put texted.com /bin/texted.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)