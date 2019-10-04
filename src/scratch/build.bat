if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war scratch.asm
if "%currentdir%"=="" (pause)
