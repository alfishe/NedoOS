"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put updater.com /bin/updater.com
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put updater.txt /doc/updater.txt
rd /Q /S obj
if "%makeall%"=="" ..\..\..\us\emul.exe


