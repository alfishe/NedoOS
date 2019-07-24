if "%sjasmplus%"=="" call ../../_sdk/setpath.bat

%nedores% sprset.bmp sprset.dat sprset.ast
%nedores% tileset.bmp tileset.dat tileset.ast
%sjasmplus% --nologo main.asm
if "%currentdir%"=="" (pause)
