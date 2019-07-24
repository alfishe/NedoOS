if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo modplay.asm
if "%currentdir%"=="" (pause)
