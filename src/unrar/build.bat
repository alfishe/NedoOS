if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war unrar.asm
if "%currentdir%"=="" (pause)
