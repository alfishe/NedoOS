"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put atelnet.com /bin/atelnet.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj