if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war nv.asm
if "%currentdir%"=="" (pause)
