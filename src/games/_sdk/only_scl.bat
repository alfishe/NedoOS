rem скрипт сборки проекта

if not defined output goto end
if %output%=="" goto end
if %title%=="" goto end

set error=1

PATH=..\evosdk\tools\sdcc\bin;..\evosdk
set temp=_temp_


rem переходим во временную директорию

cd %temp%

call createscl.bat

cd ..

copy %temp%\disk.scl %output% >nul
..\evosdk\monoscl %output%

set error=0

rem удал€ем временную директорию

:clean

rem rd /s /q %temp%

:end

if %error%==1 pause