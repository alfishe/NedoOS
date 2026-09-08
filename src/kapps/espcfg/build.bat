"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put espcfg.com /bin/espcfg.com
rd /Q /S obj
del espcfg.com
if "%makeall%"=="" ..\..\..\us\emul.exe
