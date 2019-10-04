if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war telnet.asm
if "%currentdir%"=="" (pause)
