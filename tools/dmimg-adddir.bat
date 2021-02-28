@echo off
set DMIMG=%~dp0dmimg.exe
if not exist %DMIMG% echo ERROR: "%DMIMG%" not found.&&exit
if "%1"=="" goto usage
if "%2"=="" goto usage
if not "%3"=="" goto usage
setlocal EnableDelayedExpansion
set IMAGEFILE=%1
set SOURCEDIR=%~dpn2
set SCRIPTFILE=script.tmp
echo Scanning directory "%SOURCEDIR%"...
if exist %SCRIPTFILE% del /q %SCRIPTFILE% > nul
for /r %SOURCEDIR% %%i in (.) do (
	rem disk:/path/file
	set j=%%~dpni
	if not "!j:%SOURCEDIR%=!"=="" echo mkdir !j:%SOURCEDIR%=!>> %SCRIPTFILE%
)
for /r %SOURCEDIR% %%i in (*.*) do (
	set j=%%~dpnxi
	echo put %%i !j:%SOURCEDIR%=!>> %SCRIPTFILE%
)
if not exist "%SCRIPTFILE%" (
	echo Nothing to add - skipping. File "%IMAGEFILE%" was not modified.
	exit /b
)
echo Adding files from directory "%SOURCEDIR%" to the image "%IMAGEFILE%"...
%DMIMG% %IMAGEFILE% conf %SCRIPTFILE%
del /q %SCRIPTFILE%
echo File "%IMAGEFILE%" is successfully updated.
exit /b

:usage
echo Usage:
echo   %~nx0 IMAGE_FILE SOURCE_DIR
echo Where:
echo   IMAGE_FILE is an image file, supported by "dmimg".
echo   SOURCE_DIR is a source directory to add files from.
exit
