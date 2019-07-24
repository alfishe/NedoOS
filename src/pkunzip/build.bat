if "%sjasmplus%"=="" call ../_sdk/setpath.bat
%sjasmplus% --nologo pkunzip.asm
if "%currentdir%"=="" (pause)
