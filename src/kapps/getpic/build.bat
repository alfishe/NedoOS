cls
"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put getpic.com /bin/gp.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj