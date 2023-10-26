if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war -DSVNREVISION=999999999 main.asm
sjasmplus --nologo --msg=war -DSVNREVISION=999999999 -DOUTFNAME=\"md5.com\" -DMODULE=\"md5.asm\" main.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 )
 rem pause
 if "%makeall%"=="" ..\..\us\emul.exe
)
