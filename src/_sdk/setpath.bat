if NOT "%settedpath%"=="" exit /b
set settedpath=1
call :ExpandRootDir %~dp0..\..
set path=%rootdir%\tools\;%rootdir%;%rootdir%\us\;%rootdir%\src\_sdk\;%PATH%
exit /b

:ExpandRootDir
set rootdir=%~f1
exit /b