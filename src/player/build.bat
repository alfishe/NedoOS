if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war player.asm
if "%currentdir%"=="" (pause)
