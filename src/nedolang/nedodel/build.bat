@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang del.c
type err.f
..\_sdk\nedotok del_os.s ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm
..\_sdk\nedoasm del_os.S_
type asmerr.f
move /Y del_os.bin nedodel.com > nul

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../../release/bin/" > nul
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /bin/%%j
 )
rem pause
 if "%makeall%"=="" ..\..\..\us\emul.exe
)