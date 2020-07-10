if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war gfxtest.asm

if "%currentdir%"=="" (pause)
