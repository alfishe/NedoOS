if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war mdr.asm
sjasmplus --nologo --msg=war mwm.asm
sjasmplus --nologo --msg=war pt3.asm
sjasmplus --nologo --msg=war ngsdec/gscode.asm
sjasmplus --nologo --msg=war mp3.asm
sjasmplus --nologo --msg=war vgm.asm
sjasmplus --nologo --msg=war main.asm

if "%currentdir%"=="" (
 copy /Y gp.com "../../release/bin/" > nul
 copy /Y gp.plr "../../release/bin/gp/" > nul
)
