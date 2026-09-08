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
sjasmplus --nologo --msg=war hobeta.asm
if errorlevel 1 exit /b 1

if "%currentdir%"=="" (
 if exist nedoos.$c copy /Y nedoos.$c "../../release/sd_boot.$c" > nul
 if exist "../../us/sd_nedo.vhd" "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put nedoos.$c /sd_boot.$c
 if exist "../../us_ns/sd_nedo.vhd" "../../tools/dmimg.exe" ../../us_ns/sd_nedo.vhd put nedoos.$c /sd_boot.$c
)