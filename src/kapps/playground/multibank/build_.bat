@echo off
"../../../tools/mingw/make.exe" -f Makefile %1
if errorlevel 1 exit /b 1
if exist bin\multibank.com (
	"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put bin\multibank.com /bin/multibank.com
	if exist bin\multibank\codeB_01.bin "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put bin\multibank\codeB_01.bin /bin/multibank/codeB_01.bin
	if exist bin\multibank\codeB_02.bin "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put bin\multibank\codeB_02.bin /bin/multibank/codeB_02.bin
	if exist bin\multibank\codeB_03.bin "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put bin\multibank\codeB_03.bin /bin/multibank/codeB_03.bin
)
if "%makeall%"=="" if "%notrunemu%"=="" ..\..\..\us\emul.exe
