if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war mwm.asm
sjasmplus --nologo --msg=war pt3.asm
sjasmplus --nologo --msg=war ngsdec/gscode.asm
sjasmplus --nologo --msg=war mp3.asm
sjasmplus --nologo --msg=war vgm.asm
sjasmplus --nologo --msg=war moonmod.asm
sjasmplus --nologo --msg=war main.asm
rem sjasmplus --nologo --msg=war moonmod/generateperiodlookup.asm

if "%currentdir%"=="" (
 copy /Y gp.com "../../release/bin/" > nul
 copy /Y gp.plr "../../release/bin/gp/" > nul
 "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put gp.com /bin/gp.com
 "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put gp.plr /bin/gp/gp.plr
 pause
 if "%makeall%"=="" ..\..\us\emul.exe
)
