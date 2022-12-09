"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put gstest.com /bin/kapps/gstest.com
rd /Q /S obj
rem del gstest.com
if "%makeall%"=="" ..\..\..\us\emul.exe