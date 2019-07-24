if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo texted.asm
if "%currentdir%"=="" (pause)
