@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang ../_sdk/fmttg.h export.c exporttg.c
type err.f
..\_sdk\nedotok exp_os.s ../_sdk/lib.i ../_sdk/str.i ../_sdk/io_os.i
..\_sdk\nedoasm exp_os.S_
type asmerr.f
move /Y exp_os.bin exp.com > nul

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../../release/bin/" > nul
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /bin/%%j
 )
rem pause
 if "%makeall%"=="" ..\..\..\us\emul.exe
)