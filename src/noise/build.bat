if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war noise.asm
if "%currentdir%"=="" (pause)
