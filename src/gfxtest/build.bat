if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war gfxtest.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put gfxtest.com /bin/gfxtest.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)