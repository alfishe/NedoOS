@echo off
if not exist %CD% (
	echo Error: No spaces allowed in the path! 
	pause
	exit
)
if NOT "%settedpath%"=="" exit /b
set settedpath=1
call :ExpandRootDir %~dp0..\..
set path=%rootdir%\tools\;%rootdir%;%rootdir%\us\;%rootdir%\src\_sdk\;%rootdir%\src\nedolang\_sdk\;%PATH%
exit /b

:ExpandRootDir
set rootdir=%~f1
exit /b