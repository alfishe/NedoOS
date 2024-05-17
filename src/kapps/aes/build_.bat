"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put aesdemo.com /nedodemo/aesdemo.com
rd /Q /S obj
if "%makeall%"=="" ..\..\..\us\emul.exe


