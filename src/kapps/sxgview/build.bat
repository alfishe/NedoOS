"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put sxgview.com /bin/sxgview.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
del sxgview.com 