@echo off
if "%settedpath%"=="" call %~dp0..\..\_sdk\setpath.bat
%MAKE% %MFLAGS% install
if not %ERRORLEVEL%==0 goto error
if "%makeall%"=="" pause
goto :end
:error
echo ERROR: Exit code %ERRORLEVEL%. Stopped.
if "%makeall%"=="" pause
:end
