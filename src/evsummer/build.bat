set wascurrentdir=%currentdir%
if "%settedpath%"=="" call "..\_sdk\setpath.bat"

sjasmplus --nologo --msg=war  main.asm

if "%wascurrentdir%"=="" (pause)

