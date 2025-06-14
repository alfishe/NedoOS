"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put zxdb.com /bin/zxdb.com
if "%makeall%"=="" ..\..\..\us\emul.exe


