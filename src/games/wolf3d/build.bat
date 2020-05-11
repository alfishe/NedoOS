if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
nedotrd WOLF484.TRD -e mapatm.E
sjasmplus --nologo --msg=war main.asm

if "%currentdir%"=="" (pause)
