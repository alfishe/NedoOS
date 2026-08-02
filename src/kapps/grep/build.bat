"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put grep.com /bin/grep.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
del grep.com
