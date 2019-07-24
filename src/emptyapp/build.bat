if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo emptyapp.asm
if "%currentdir%"=="" (pause)
