"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put sleep.com /bin/sleep.com
rd /Q /S obj
del sleep.com
if "%makeall%"=="" ..\..\..\us\emul.exe


