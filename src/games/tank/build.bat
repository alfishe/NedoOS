if "%sjasmplus%"=="" call ../../_sdk/setpath.bat

%nedores% sprset.bmp sprset.da sprset.ast
%nedores% tileset.bmp tileset.da tileset.ast
%sjasmplus% --nologo main.asm
if "%currentdir%"=="" (pause)
