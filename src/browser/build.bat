if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war browser.asm

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put browser.com /bin/browser.com
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)