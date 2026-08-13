if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedodemo
sjasmplus --nologo --msg=war gfxtest.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../../release/nedodemo/" > nul
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedodemo/%%j
 )
 rem pause
 if "%makeall%"=="" ..\..\..\us\emul.exe
)