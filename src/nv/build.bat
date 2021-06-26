if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war -DPRSTDIO=1 nv.asm
sjasmplus --nologo --msg=war -DPRSTDIO=0 nv.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../release/bin/" > nul
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put %%j /bin/%%j
 "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put %%j /bin/%%j
 )
 "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put nv.ext /bin/nv.ext
 "../../tools/dmimg.exe" ../../us/hdd_nedo.vhd put nv.ext /bin/nv.ext
 rem pause
 if "%makeall%"=="" ..\..\us\emul.exe
)