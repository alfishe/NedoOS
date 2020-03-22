if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
sjasmplus --nologo --msg=war main.asm
if "%currentdir%"=="" (pause)
"../../_sdk/nedores.exe" loyd.bmp loyd.dat loydgfx.ast
