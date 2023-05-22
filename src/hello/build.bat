if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war hello.asm
rem sjasmplus --nologo --msg=war hello.asm --raw=hello.com
