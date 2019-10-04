if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war tar.asm
if "%currentdir%"=="" (pause)
