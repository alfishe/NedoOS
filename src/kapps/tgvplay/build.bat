@echo off
setlocal
cd /d "%~dp0"
"..\..\..\tools\mingw\make.exe" -f Makefile %*
if errorlevel 1 exit /b 1
echo Build OK: tgvplay.com
for %%A in (tgvplay.com) do echo   %%~zA bytes tgvplay.com
"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put tgvplay.com /bin/tgvplay.com
if "%makeall%"=="" ..\..\..\us\emul.exe
rd /Q /S obj
exit /b 0
