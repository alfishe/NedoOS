if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist worms mkdir worms
set LOCALDIR=worms
set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war

@echo off
%NEDORES% gfx/sprites_bw.bmp sprites.dat sprites.ast
%NEDORES% gfx/texmars_bw.bmp texture.dat texture.ast
%NEDORES% gfx/texforrest.bmp texforrest.dat texforrest.ast
%NEDORES% gfx/panel.bmp pal.dat pal.ast
%NEDORES% gfx/panel.bmp panel16.dat panel16.ast
%NEDORES% gfx/panel_bw.bmp panel.dat panel.ast
%NEDORES% gfx/panel_bw.bmp numfont.dat numfont.ast
%SJASMPLUS% %SJASMPLUSFLAGS% main.asm
rem sjasmplus depkmain.asm
nedotrd basic.trd -eh boot.$b > nul
rem del test.scl
rem mhmt -mlz code.c
rem del code.c
rem copy /b depkcode.c + code.c.mlz code.c
nedotrd worms.trd -n
nedotrd worms.trd -ah boot.$b
nedotrd worms.trd -ac code.c
nedotrd worms.trd -ac hicode.c
nedotrd worms.trd -ac hicode2.c
rem del code.c
rem del code.c.mlz
rem del depkcode.c
rem ..\us\emulatm test.scl
rem emul worms.trd > nul
rem unreal test.scl

@SET releasedir2=../../../release/
@if "%currentdir%"=="" (
  @FOR %%j IN (*.com) DO (
  @"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  @move "*.com" "%releasedir2%nedogame" > nul
  @IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
@cd ../../../src/
@call ..\tools\chkimg.bat sd
 rem pause
@if "%makeall%"=="" ..\us\emul.exe
)
