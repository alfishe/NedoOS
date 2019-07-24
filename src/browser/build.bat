if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo browser.asm
if "%currentdir%"=="" (pause)
