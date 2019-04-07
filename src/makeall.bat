set makeall=1
FOR %%i IN (mk*.bat) DO (
        call %%i
)
call cleansrc.bat
