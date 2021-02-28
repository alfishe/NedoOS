@echo off
if "%settedpath%"=="" call _sdk\setpath.ba
%MAKE% %MFLAGS% configure-pe26sd
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
