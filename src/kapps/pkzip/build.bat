"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put pkzip2.com /bin/pkzip2.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
