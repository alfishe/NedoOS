@echo off
if "%settedpath%"=="" call _sdk\setpath.bat
%MAKE% %MFLAGS% configure-evo clean install
if not %ERRORLEVEL%==0 goto error
if "%makeall%"=="" (
 %MAKE% %MFLAGS% test
 if not %ERRORLEVEL%==0 goto error
)
goto end
:error
echo ERROR: Exit code %ERRORLEVEL%. Stopped.
:end
