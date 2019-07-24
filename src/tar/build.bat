if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo tar.asm
if "%currentdir%"=="" (pause)
