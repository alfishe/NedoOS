if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo ping.asm
if "%currentdir%"=="" (pause)
