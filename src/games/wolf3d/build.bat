if "%sjasmplus%"=="" call ../../_sdk/setpath.bat
%sjasmplus% --nologo main.asm
if "%currentdir%"=="" (pause)
