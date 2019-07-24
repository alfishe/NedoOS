if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo player.asm
if "%currentdir%"=="" (pause)
