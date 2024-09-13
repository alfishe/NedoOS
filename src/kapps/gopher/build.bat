"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put gopher.com /bin/gopher.com
rd /Q /S obj
del gopher.com
if "%makeall%"=="" ..\..\..\us\emul.exe


