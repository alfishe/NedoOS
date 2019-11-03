if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
sjasmplus --nologo --msg=war main.asm

if "%currentdir%"=="" (pause)
