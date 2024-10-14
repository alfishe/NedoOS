@ECHO OFF
"../../../tools\mingw\make.exe"
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put cuart.com /bin/cuart.com
rd /Q /S obj
del cuart.com
rem if "%makeall%"=="" ..\..\..\us\emul.exe
