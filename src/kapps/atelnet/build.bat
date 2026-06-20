"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put atelnet.com /bin/atelnet.com
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put ansiview.com /bin/ansiview.com
if "%makeall%"=="" ..\..\..\us\emul.exe
