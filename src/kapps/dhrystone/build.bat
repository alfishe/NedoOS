"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put dhrystone.com /bin/dhrystone.com
rd /Q /S obj
del dhrystone.com
rem if "%makeall%"=="" ..\..\us\emul.exe