if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
"../../_sdk/nedores.exe" loyd.bmp loyd.dat loydgfx.ast
sjasmplus --nologo --msg=war main.asm
if "%currentdir%"=="" (pause)
