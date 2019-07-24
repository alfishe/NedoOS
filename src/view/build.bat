if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo view.asm
if "%currentdir%"=="" (pause)
