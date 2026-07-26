@echo off
"../../../../tools/mingw/make.exe" -f Makefile %1
if errorlevel 1 exit /b 1
if exist multibank.com (
	"../../../../tools/dmimg.exe" ../../../../us/sd_nedo.vhd put multibank.com /bin/kapps/multibank.com
)
if "%makeall%"=="" if "%notrunemu%"=="" ..\..\..\..\us\emul.exe
