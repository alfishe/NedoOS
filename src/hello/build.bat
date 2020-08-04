if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war hello.asm
rem sjasmplus --nologo --msg=war hello.asm --raw=hello.com

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put hello.com /bin/hello.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)