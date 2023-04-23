cls
"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put getpic.com /bin/getpic.com
if "%makeall%"=="" ..\..\..\us\emul.exe
del getpic.com
rd /Q /S obj