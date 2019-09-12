if "%sjasmplus%"=="" call ../../_sdk/setpath.bat
%sjasmplus% --nologo brfinal.asm
%sjasmplus% --nologo main.asm
rem "..\..\..\tools\sjasmplus107.exe" --nologo main.asm
if "%currentdir%"=="" (pause)
