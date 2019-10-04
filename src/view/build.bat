if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war view.asm
if "%currentdir%"=="" (pause)
