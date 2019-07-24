if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo telnet.asm
if "%currentdir%"=="" (pause)
