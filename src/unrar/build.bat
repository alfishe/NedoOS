if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo unrar.asm
if "%currentdir%"=="" (pause)
