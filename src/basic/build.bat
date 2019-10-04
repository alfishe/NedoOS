if "%settedpath%"=="" call ../_sdk/setpath.bat

sjasmplus --nologo --msg=war basic.asm
if "%currentdir%"=="" (pause)
