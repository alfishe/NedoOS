if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war scratch.asm

if "%currentdir%"=="" (pause)

..\..\tools\curl.exe -X PUT -F"filedata=@SCRATCH.COM" http://127.0.0.1:4444/bin/SCRATCH.COM
