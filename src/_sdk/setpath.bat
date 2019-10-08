if NOT "%settedpath%"=="" exit /b
set settedpath=1
set path=%~dp0../../tools/;%~dp0;%~dp0../../us/;%PATH%

rem if "%settedpath%"=="" set sjasmplus="%~dp0/../../tools/sjasmplus"
rem if "%mhmt%"=="" set mhmt="%~dp0/../../tools/mhmt"
rem if "%nedores%"=="" set nedores="%~dp0/nedores"
