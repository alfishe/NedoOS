@echo off
if "%settedpath%"=="" call _sdk\setpath.bat
set prevmakeall=%makeall%
set makeall=1
%MAKE% %MFLAGS% configure-atm3sd
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
set makeall=%prevmakeall%