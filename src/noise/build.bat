if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo noise.asm
if "%currentdir%"=="" (pause)
