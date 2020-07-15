if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war scratch.asm

if "%currentdir%"=="" (pause)

..\..\tools\curl.exe --upload-file scratch.com --url http://127.0.0.1:4444/bin/SCRATCH.COM
rem ..\..\tools\curl.exe --http1.0 -H @header -F"filedata=@SCRATCH.COM" http://127.0.0.1:4444/bin/SCRATCH.COM
rem ..\..\tools\curl.exe -X PUT -F"filedata=@SCRATCH.COM" http://127.0.0.1:4444/bin/SCRATCH.COM
..\..\tools\curl.exe -X GET http://127.0.0.1:4444/?s=bin/scratch.com
