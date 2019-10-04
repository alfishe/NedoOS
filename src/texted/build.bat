if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war texted.asm
if "%currentdir%"=="" (pause)
