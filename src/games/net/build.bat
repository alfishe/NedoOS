if "%settedpath%"=="" call ../../_sdk/setpath.bat
sjasmplus --nologo --msg=war master.asm
sjasmplus --nologo --msg=war slave.asm
if "%currentdir%"=="" (pause)
