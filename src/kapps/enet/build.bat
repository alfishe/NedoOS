"../../../tools/mingw/make.exe" -f Makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put enet.com /bin/enet.com
rd /Q /S obj
del enet.com
if "%makeall%"=="" ..\..\..\us\emul.exe
