"../../../tools/mingw/make.exe" -f makefile %1
if "%makeall%"=="" "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put textview.com /bin/textview.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
