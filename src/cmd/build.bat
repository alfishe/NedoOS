if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo cmd.asm
if "%currentdir%"=="" (pause)
