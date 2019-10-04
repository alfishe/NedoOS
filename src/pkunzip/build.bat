if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war pkunzip.asm
if "%currentdir%"=="" (pause)
