"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put g.com /bin/g.com
rd /Q /S obj
if "%makeall%"=="" ..\..\..\us\emul.exe


