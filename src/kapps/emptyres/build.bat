"../../../tools/mingw/make.exe" -f Makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put emptyres.com /bin/kapps/emptyres.com
if "%makeall%"=="" ..\..\..\us\emul.exe
