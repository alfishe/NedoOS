@echo off
set makeall=1
if "%settedpath%"=="" call "_sdk\setpath.bat"
FOR %%i IN (mk*.bat) DO (
        call %%i
)
call cleansrc.bat
