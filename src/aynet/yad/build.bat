@ECHO OFF
SET OLDSYSPATH=%PATH%
PATH=%SystemRoot%
"../../../tools/mingw/make.exe" -f makefile %1
PATH=%OLDSYSPATH%