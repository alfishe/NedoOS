if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo scratch.asm
if "%currentdir%"=="" (pause)
