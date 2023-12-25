if "%settedpath%"=="" call ../../_sdk/setpath.bat
set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war

rem %NEDORES% pal.bmp pal.dat pal.ast
sjasmplus --nologo --msg=war main.asm

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../../release/nedodemo/" > nul
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedodemo/%%j
 )
 rem pause
 if "%makeall%"=="" ..\..\..\us\emul.exe
)