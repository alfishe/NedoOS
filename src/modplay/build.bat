if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war modplay.asm
if "%currentdir%"=="" (pause)
