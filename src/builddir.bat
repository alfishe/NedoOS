@echo off
if "%1"=="" goto usage
if not "%2"=="" goto usage
if "%settedpath%"=="" call %~dp0_sdk\setpath.bat
cd %1
if not %ERRORLEVEL%==0 goto error
%MAKE% %MFLAGS% install
if not %ERRORLEVEL%==0 goto error

if "%makeall%"=="" (
 %MAKE% %MFLAGS% -C %EMULDIR%
 if not %ERRORLEVEL%==0 goto error
 pause
 if "%makeall%"=="" (
  %EMUL%
  if not %ERRORLEVEL%==0 goto error
 )
)
goto :end

:usage
echo Usage:
echo   %~nx0 WORK_DIR
echo where:
echo   WORK_DIR - working directory
goto :end

:error
echo ERROR: Exit code %ERRORLEVEL%. Stopped.
if "%currentdir%"=="" pause

:end
