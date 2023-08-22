"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put updater.com /bin/updater.com
rem rd /Q /S obj
if "%makeall%"=="" ..\..\..\us\emul.exe


