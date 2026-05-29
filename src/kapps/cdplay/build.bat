"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put cdplay.com /bin/cdplay.com
rd /Q /S obj
if "%makeall%"=="" ..\..\..\us\emul.exe