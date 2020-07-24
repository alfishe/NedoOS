if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war nv.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put nv.com /bin/nv.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)