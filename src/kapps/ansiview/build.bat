"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put ansiview.com /bin/ansiview.com
rd /Q /S obj
del ansiview.com
if "%makeall%"=="" ..\..\..\us\emul.exe