set wascurrentdir=%currentdir%
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"

sjasmplus --nologo --msg=war  ptsplay.asm

if "%wascurrentdir%"=="" (pause)

