@echo off
REM Assemble kernel (syssets already in ..\_sdk\syssets.asm).
REM %1 = release basename WITHOUT .$c  (sd_boot, osatm2hd, osatm2hm, osatm2)
REM %2 = esp  -> suffix before .$c  (osatm2hdesp.$c, sd_bootesp.$c)
REM      sd   -> also put on VHD
REM %3 = sd   -> VHD put when %2 is a suffix
REM Nested call build.bat can clear %%1: keep names from the start.
set "KNAME=%~1"
set "KARG2=%~2"
set "KARG3=%~3"
set "KSUF="
set "KSD="
if /I "%KARG2%"=="sd" (
 set "KSD=sd"
) else if not "%KARG2%"=="" (
 set "KSUF=%KARG2%"
 if /I "%KARG3%"=="sd" set "KSD=sd"
)
if "%KNAME%"=="" (
 echo ERROR: run_kernel.bat needs dest name ^(sd_boot, osatm2hd, ...^)
 exit /b 1
)
cd /d "%~dp0"
set "currentdir=%~dp0.."
call "%~dp0build.bat"
if errorlevel 1 exit /b 1
if not exist "%~dp0nedoos.$c" (
 echo ERROR: kernel build did not produce nedoos.$C
 exit /b 1
)
set "KREL=%~dp0..\..\release"
if not exist "%KREL%" mkdir "%KREL%"
set "KOUT=%KREL%\%KNAME%%KSUF%.$c"
set "KVHD=/%KNAME%%KSUF%.$c"
copy /Y "%~dp0nedoos.$c" "%KOUT%" > nul
if errorlevel 1 (
 echo ERROR: failed to copy to %KOUT%
 exit /b 1
)
if /I "%KSD%"=="sd" (
 if exist "%~dp0..\..\us\sd_nedo.vhd" (
  "%~dp0..\..\tools\dmimg.exe" "%~dp0..\..\us\sd_nedo.vhd" put "%~dp0nedoos.$c" %KVHD%
  echo put %KVHD% -^> us\sd_nedo.vhd
 )
 if exist "%~dp0..\..\us_ns\sd_nedo.vhd" (
  "%~dp0..\..\tools\dmimg.exe" "%~dp0..\..\us_ns\sd_nedo.vhd" put "%~dp0nedoos.$c" %KVHD%
  echo put %KVHD% -^> us_ns\sd_nedo.vhd
 )
)
echo Kernel: %KOUT%
findstr INETDRV "%~dp0..\_sdk\syssets.asm"
exit /b 0
