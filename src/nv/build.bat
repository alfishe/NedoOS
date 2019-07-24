if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo nv.asm
if "%currentdir%"=="" (pause)
