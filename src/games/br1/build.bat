if "%sjasmplus%"=="" call ../../_sdk/setpath.bat
%sjasmplus% --nologo levels/w~104.a80
%sjasmplus% --nologo levels/w~107.a80
%sjasmplus% --nologo levels/w~112.a80
%sjasmplus% --nologo levels/w~117end.a80
%sjasmplus% --nologo levels/w~205.a80
%sjasmplus% --nologo levels/w~213.a80
%sjasmplus% --nologo levels/w~217end.a80
%sjasmplus% --nologo brfinal.asm
%sjasmplus% --nologo main.asm
rem "..\..\..\tools\sjasmplus107.exe" --nologo main.asm
if "%currentdir%"=="" (pause)
