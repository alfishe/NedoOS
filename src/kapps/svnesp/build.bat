"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put svnesp.com /bin/svnesp.com
rd /Q /S obj
del svnesp.com
if "%makeall%"=="" ..\..\..\us\emul.exe
