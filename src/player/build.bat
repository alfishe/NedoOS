if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war player.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put player.com /bin/player.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)