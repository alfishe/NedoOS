@echo off
"../../../tools/mingw/make.exe" -f Makefile %1
if errorlevel 1 exit /b 1
if exist bin\multibank.com (
	"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put bin\multibank.com /bin/multibank.com
	for %%f in (bin\multibank\*.bin) do (
		"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put "%%f" /bin/multibank/%%~nxf
	)
)
if "%makeall%"=="" if "%notrunemu%"=="" ..\..\..\us\emul.exe
