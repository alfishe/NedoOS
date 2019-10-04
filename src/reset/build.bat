if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war reset.asm
if "%currentdir%"=="" (pause)
