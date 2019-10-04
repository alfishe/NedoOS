if "%settedpath%"=="" call ../../_sdk/setpath.bat
sjasmplus --nologo --msg=war main.asm

if not exist wolf3d mkdir wolf3d
copy wolftex.* wolf3d\ > nul

if "%currentdir%"=="" (pause)
