if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo setfont.asm
if "%currentdir%"=="" (pause)
