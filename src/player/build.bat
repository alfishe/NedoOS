..\..\tools\make.exe %1 %2

if "%currentdir%"=="" (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put player.com /bin/player.com
 pause
 rem if "%makeall%"=="" ..\..\us\emul.exe
)