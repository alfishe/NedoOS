set wascurrentdir=%currentdir%
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"

sjasmplus --nologo --msg=war  vgm_plr.asm

if "%wascurrentdir%"=="" (pause)

