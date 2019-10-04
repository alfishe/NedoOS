if "%settedpath%"=="" call ../../_sdk/setpath.bat

nedores sprset.bmp sprset.da sprset.ast
nedores tileset.bmp tileset.da tileset.ast
sjasmplus --nologo --msg=war main.asm
if "%currentdir%"=="" (pause)
