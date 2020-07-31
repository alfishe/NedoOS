if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war basic.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put basic.com /bin/basic.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)