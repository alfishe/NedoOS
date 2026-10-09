@echo off
rem Far: prep-tgv.bat "!.!"
rem Bypass is only for this process. The system execution policy stays as it is.
setlocal
cd /d "%~dp0"
if "%~1"=="" goto usage
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0prep-tgv.ps1" %*
set ERR=%ERRORLEVEL%
if not "%ERR%"=="0" (
  echo.
  echo prep-tgv: error %ERR%
  pause
)
exit /b %ERR%

:usage
echo prep-tgv.bat video-or-folder [options]
echo Far, file under the cursor: prep-tgv.bat "!.!"
echo Options: -Fps 15   -Mode crop   -Mode fit   -Start sec   -Duration sec   -OutDir dir
exit /b 1
