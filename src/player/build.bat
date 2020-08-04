..\..\tools\make.exe %1 %2

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)