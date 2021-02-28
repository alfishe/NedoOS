@echo off
if "%settedpath%"=="" call _sdk\setpath.ba
set prevmakeall=%makeall%
set makeall=1
%MAKE% %MFLAGS% configure-pe26
if not %ERRORLEVEL%==0 goto error
%MAKE% %MFLAGS% clean
if not %ERRORLEVEL%==0 goto error
%MAKE% %MFLAGS% install
if not %ERRORLEVEL%==0 goto error
if "%prevmakeall%"=="" (
 %MAKE% %MFLAGS% test
 if not %ERRORLEVEL%==0 goto error
)
goto end
:error
echo ERROR: Exit code %ERRORLEVEL%. Stopped.
:end
