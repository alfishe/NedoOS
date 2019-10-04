if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war zxrar.asm
if "%currentdir%"=="" (pause)
