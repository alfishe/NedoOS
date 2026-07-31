"../../../tools/mingw/make.exe" -f Makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put girc.com /bin/girc.com
rd /Q /S obj
rem del girc.com
if "%makeall%"=="" ..\..\..\us\emul.exe
