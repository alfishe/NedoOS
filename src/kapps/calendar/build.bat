"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put calendar.com /bin/calendar.com
rd /Q /S obj
del calendar.com
if "%makeall%"=="" ..\..\..\us\emul.exe


