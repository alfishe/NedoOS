if "%settedpath%"=="" call ../_sdk/setpath.bat

sjasmplus --nologo --msg=war --lst zexdoc/zexdoc.asm
sjasmplus --nologo --msg=war --lst zexall/zexall.asm

sjasmplus --nologo --msg=war --lst z80test/src/z80ccf.asm
sjasmplus --nologo --msg=war --lst z80test/src/z80doc.asm
sjasmplus --nologo --msg=war --lst z80test/src/z80docflags.asm
sjasmplus --nologo --msg=war --lst z80test/src/z80flags.asm
sjasmplus --nologo --msg=war --lst z80test/src/z80full.asm
sjasmplus --nologo --msg=war --lst z80test/src/z80memptr.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put %%j /bin/%%j
 )
 rem if "%makeall%"=="" ..\..\us\emul.exe
)

