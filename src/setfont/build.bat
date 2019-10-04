if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war setfont.asm
if "%currentdir%"=="" (pause)
