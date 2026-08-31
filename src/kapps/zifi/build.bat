"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put zifi.com /bin/zifi.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
del zifi.com
