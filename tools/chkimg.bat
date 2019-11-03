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
IF EXIST img.lst del img.lst
FOR /R %rel% %%i in (.) do (
	set ob=%%~dpni	
	echo mkdir !ob:%rel%=!>> img.lst
)
FOR /R %rel% %%i IN (*.*) do (
	set ob=%%~dpnxi	
	echo put %%i !ob:%rel%=!>> img.lst
)
%~dp0dmimg ..\us\%1_nedo.vhd conf img.lst
exit /b

:ExpandFileName
set rel=%~f1
exit /b
