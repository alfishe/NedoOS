set makeall=1
set savepath=%PATH%
FOR %%i IN (mk*.bat) DO (
        call %%i
)
call cleansrc.bat
