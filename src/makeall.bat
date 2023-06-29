@echo off
setlocal ENABLEDELAYEDEXPANSION
set edeset=1
set makeall=1
set notrunemu=1
if "%settedpath%"=="" call "_sdk\setpath.bat"
FOR %%i IN (mk*.bat) DO (
        call %%i
)
set edeset=
set makeall=
set notrunemu=
call mkevo.bat
call cleansrc.bat
