@echo off
if "%settedpath%"=="" call %~dp0_sdk\setpath.bat
%MAKE% %MFLAGS% clean-release
