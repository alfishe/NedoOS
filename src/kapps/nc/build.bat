"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put nc.com /bin/nc.com
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put nc.ext /ini/nc.ext
if "%makeall%"=="" ..\..\..\us\emul.exe


