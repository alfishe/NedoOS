if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war emptyapp.asm
if "%currentdir%"=="" (pause)
