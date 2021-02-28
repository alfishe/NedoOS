@echo off
setlocal ENABLEDELAYEDEXPANSION
set makeall=1
if "%settedpath"=="" call _sdk\setpath.bat
for %%f in (mk*.bat) do (
 call %%f
 if not %ERRORLEVEL%==0 goto error
)
goto :end
:error
echo ERROR: Exit code %ERRORLEVEL%. Stopped.
:end
