@echo off
setlocal
cd /d "%~dp0"
"..\..\..\tools\mingw\make.exe" -f Makefile %*
if errorlevel 1 exit /b 1
echo Build OK: timegal.com
exit /b 0
