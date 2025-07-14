@echo off
if "%settedpath%"=="" call "..\..\_sdk\setpath.bat"
..\_sdk\nedolang ../_sdk/emit.c commands.c
type err.f
..\_sdk\nedotok compc_os.s ../_sdk/lib.i ../_sdk/io_os.i ../_sdk/str.i ../../_sdk/sysdefs.asm lbltype.i
..\_sdk\nedoasm compc_os.S_
type asmerr.f
..\_sdk\nedolang ../_sdk/read.c compile.c
type err.f
..\_sdk\nedotok comp_os.s
..\_sdk\nedoasm comp_os.S_
type asmerr.f
del compc_os.bin
move /Y comp_os.bin comp.com > nul

if "%currentdir%"=="" (
 FOR %%j IN (*.com) DO (
 copy /Y %%j "../../../release/bin/" > nul
 "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /bin/%%j
 )
rem pause
 if "%makeall%"=="" ..\..\..\us\emul.exe
)