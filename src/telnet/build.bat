if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war telnet.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put telnet.com /bin/telnet.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)