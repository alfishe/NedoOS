@echo off
if "%settedpath%"=="" call _sdk\setpath.bat
%MAKE% %MFLAGS% configure-atm2hd
%MAKE% %MFLAGS% clean
%MAKE% %MFLAGS% install
if not %ERRORLEVEL%==0 goto error
if "%makeall%"=="" (
 %MAKE% %MFLAGS% test
 if not %ERRORLEVEL%==0 goto error
)
goto end
:error
echo ERROR: Exit code %ERRORLEVEL%. Stopped.
:end
