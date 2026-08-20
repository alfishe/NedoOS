@echo off
"../../../tools/mingw/make.exe" -f Makefile %1
if errorlevel 1 exit /b 1
if exist bin\nc.com (
	"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put bin\nc.com /bin/nc.com
	for %%f in (bin\nco\*.bin) do (
		"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put "%%f" /bin/nco/%%~nxf
	)
)
rd /Q /S obj
rd /Q /S bin
del nc.com
if "%makeall%"=="" if "%notrunemu%"=="" ..\..\..\us\emul.exe
