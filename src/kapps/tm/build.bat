"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put tm.com /bin/tm.com
rd /Q /S obj
del tm.com
if "%makeall%"=="" ..\..\..\us\emul.exe