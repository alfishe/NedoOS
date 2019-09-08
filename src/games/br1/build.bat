if "%sjasmplus%"=="" call ../../_sdk/setpath.bat
%sjasmplus% --nologo main.asm
rem "..\..\..\tools\sjasmplus107.exe" --nologo main.asm
if "%currentdir%"=="" (pause)
