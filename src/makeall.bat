@echo off
setlocal ENABLEDELAYEDEXPANSION
set edeset=1
set makeall=1
if "%settedpath%"=="" call "_sdk\setpath.bat"
FOR %%i IN (mk*.bat) DO (
        call %%i
)
call mkevo.bat
call cleansrc.bat
