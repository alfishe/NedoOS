@echo off
IF NOT "%makeall%"=="" EXIT /b
setlocal EnableDelayedExpansion
call :ExpandFileName ..\release
IF EXIST ..\us\sd_nedo.vhd IF EXIST ..\us\hdd_nedo.vhd (
	GOTO COPYFILES
)

IF NOT EXIST ..\tools\images.exe (
	ECHO Error: Image not found!
	exit /b
)
..\tools\images.exe
IF NOT EXIST ..\us\sd_nedo.vhd move sd_nedo.vhd ..\us\
IF NOT EXIST ..\us\hdd_nedo.vhd move hdd_nedo.vhd ..\us\
IF EXIST sd_nedo.vhd del sd_nedo.vhd
IF EXIST hdd_nedo.vhd del hdd_nedo.vhd
IF EXIST b.bat del b.bat

:COPYFILES
echo Copy in to Unreal image ...

FOR /R %rel% %%i in (.) do (
	set ob=%%~dpni	
	echo %%i | findstr _sdk > NUL
	if ERRORLEVEL 1 call dmimg ..\us\%1_nedo.vhd mkdir !ob:%rel%=! > nul
)
FOR /R %rel% %%i IN (*.*) do (
	set ob=%%~dpnxi	
	echo %%i | findstr _sdk > NUL
	if ERRORLEVEL 1 dmimg ..\us\%1_nedo.vhd put %%i !ob:%rel%=! > nul
)
exit /b


:ExpandFileName
set rel=%~f1
exit /b
