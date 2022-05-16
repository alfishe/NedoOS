@ECHO OFF
"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put wrtrd2.com /bin/wrtrd2.com
rd /Q /S obj
del wrtrd2.com
rem if "%makeall%"=="" ..\..\..\us\emul.exe