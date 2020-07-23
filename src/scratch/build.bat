if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war --syntax=m scratch.asm
if "%currentdir%"=="" (pause)
