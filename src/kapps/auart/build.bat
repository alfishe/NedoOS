rem @ECHO OFF
rem cls
"../../../tools/mingw/make.exe" -f makefile %1
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd  put auart.com /bin/auart.com
rd /Q /S obj
rem if "%makeall%"=="" ..\..\us\emul.exe

