"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put calendar.com /bin/calendar.com
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put calendar.ini /ini/calendar.ini
rd /Q /S obj
del calendar.com
if "%makeall%"=="" ..\..\..\us\emul.exe


