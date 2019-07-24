if "%sjasmplus%"=="" call ../_sdk/setpath.bat

%sjasmplus% --nologo basic.asm
if "%currentdir%"=="" (pause)
