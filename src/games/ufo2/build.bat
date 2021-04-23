if "%settedpath%"=="" call ../../_sdk/setpath.bat

@echo off

set installdir=nedogame
set LOCALDIR=ufo2
set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war
set XLPZ=" "
set XLPZFLAGS=" "

rem #
rem # Flicks: save locally
rem #
rem copy /y intro\flick.lpz\*.* %LOCALDIR%\ > nul

rem #
rem # Modules: convert images to assembler sources
rem #
rem %NEDORES% images/W1LAND.bmp images/W1LAND.dat W1LAND.ast

rem #
rem # Modules: compile
rem #
rem %SJASMPLUS% %SJASMPLUSFLAGS% W1LAND.ast --raw=%LOCALDIR%/W1LAND.bin

rem #
rem # Executables
rem #
%SJASMPLUS% %SJASMPLUSFLAGS% xcom.asm
mhmt -mlz blk1.bin > nul
mhmt -mlz blk2.bin > nul
mhmt -mlz blk3.bin > nul
mhmt -mlz blk4.bin > nul
%SJASMPLUS% %SJASMPLUSFLAGS% xcom2.asm

SET releasedir2=../../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  move "*.com" "%releasedir2%nedogame" > nul
  IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
cd ../../../src/
call ..\tools\chkimg.bat sd
rem pause
rem  if "%makeall%"=="" ..\..\..\us\emul.exe
 if "%makeall%"=="" ..\us\emul.exe
)