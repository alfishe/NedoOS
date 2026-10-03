@echo off
echo build kernel
if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war ngsinst.asm
if errorlevel 1 exit /b 1
sjasmplus --nologo --msg=war main.asm
if errorlevel 1 exit /b 1
if exist code.c del /q code.c
mhmt -mlz syscode.c > nul
copy /b initcode.c + syscode.c.mlz code.c > nul
if exist initcode.c del /q initcode.c
if exist syscode.c del /q syscode.c
if exist syscode.c.mlz del /q syscode.c.mlz
if exist nedoos.$C del /q nedoos.$C
sjasmplus --nologo --msg=war hobeta.asm
if errorlevel 1 exit /b 1

if "%currentdir%"=="" (
 if exist nedoos.$C (
  if exist "../../release/sd_boot.$C" (
   ren "../../release/sd_boot.$C" "sd_boot.tmp"
   ren "../../release/sd_boot.tmp" "sd_boot.$C"
  )
  copy /Y nedoos.$C "../../release/sd_boot.$C" > nul
 )
 if exist "../../us/sd_nedo.vhd" "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put nedoos.$C /sd_boot.$C
 if exist "../../us_ns/sd_nedo.vhd" "../../tools/dmimg.exe" ../../us_ns/sd_nedo.vhd put nedoos.$C /sd_boot.$C
)