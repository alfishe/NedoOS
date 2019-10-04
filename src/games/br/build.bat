if "%settedpath%"=="" call ../../_sdk/setpath.bat
if not exist br mkdir br
sjasmplus --nologo --msg=war --msg=war levels/w~104.a80
sjasmplus --nologo --msg=war --msg=war levels/w~107.a80
sjasmplus --nologo --msg=war --msg=war levels/w~112.a80
sjasmplus --nologo --msg=war --msg=war levels/w~117end.a80
sjasmplus --nologo --msg=war --msg=war levels/w~205.a80
sjasmplus --nologo --msg=war --msg=war levels/w~213.a80
sjasmplus --nologo --msg=war --msg=war levels/w~217end.a80
sjasmplus --nologo --msg=war --msg=war brfinal.asm
sjasmplus --nologo --msg=war --msg=war main.asm
copy dat\*.dat br\ > nul
rem "..\..\..\tools\sjasmplus107.exe" --nologo main.asm
if "%currentdir%"=="" (pause)
