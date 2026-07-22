@echo off
cd /d "%~dp0"
if not exist gs\ngsdrv_bin.c (
  echo Building GS blobs...
  call gs\build_gs.bat
  if errorlevel 1 exit /b 1
)
"..\..\..\tools\mingw\make.exe" -f makefile %1
if errorlevel 1 exit /b 1
if "%makeall%"=="" "..\..\..\tools\dmimg.exe" ..\..\..\us\sd_nedo.vhd put ngsplay.com /bin/ngsplay.com
if "%makeall%"=="" ..\..\..\us\emul.exe
