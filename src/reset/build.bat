if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo reset.asm
if "%currentdir%"=="" (pause)
