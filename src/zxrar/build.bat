if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo zxrar.asm
if "%currentdir%"=="" (pause)
