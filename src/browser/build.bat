if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war browser.asm
if "%currentdir%"=="" (pause)
