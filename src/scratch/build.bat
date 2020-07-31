if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war --syntax=m scratch.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put scratch.com /bin/scratch.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)