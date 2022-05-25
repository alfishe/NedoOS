@ECHO OFF

"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put rdtrd2.com /bin/rdtrd2.com
rd /Q /S obj
del rdtrd2.com
rem if "%makeall%"=="" ..\..\..\us\emul.exe