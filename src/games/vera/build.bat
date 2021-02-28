if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist vera mkdir vera
set LOCALDIR=vera
set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war

%NEDORES% icons-day.bmp icons.dat icons.ast
%NEDORES% icons-day.bmp palday.dat palday.ast
%NEDORES% icons-evening.bmp palev.dat palev.ast
%NEDORES% icons-dawn.bmp paldawn.dat paldawn.ast
%NEDORES% icons-night.bmp palnight.dat palnight.ast
%NEDORES% cursors.bmp cursors.dat cursors.ast
%NEDORES% hud.bmp hud.dat hud.ast
%NEDORES% hud.bmp hudmenu.dat hudmenu.ast
%NEDORES% tiles.bmp tiles0.dat tiles0.ast
%NEDORES% tiles.bmp tiles1.dat tiles1.ast
%NEDORES% tiles.bmp tiles2.dat tiles2.ast
%NEDORES% tiles.bmp tiles3.dat tiles3.ast
%NEDORES% herospr.bmp sprites0.dat sprites0.ast
%NEDORES% herospr.bmp sprites1.dat sprites1.ast
%NEDORES% herospr.bmp sprtran0.dat sprtran0.ast
%NEDORES% herospr.bmp sprtran1.dat sprtran1.ast
%NEDORES% day_night.bmp daynight.dat daynight.ast
rem %SJASMPLUS% %SJASMPLUSFLAGS% hud.ast --raw=%LOCALDIR%/hud.bin
rem %SJASMPLUS% %SJASMPLUSFLAGS% daynight.ast --raw=%LOCALDIR%/daynight.bin
rem %SJASMPLUS% %SJASMPLUSFLAGS% hudmenu.ast --raw=%LOCALDIR%/hudmenu.bin
%SJASMPLUS% %SJASMPLUSFLAGS% icons.ast --raw=%LOCALDIR%/icons.bin
%SJASMPLUS% %SJASMPLUSFLAGS% tiles0.ast --raw=%LOCALDIR%/tiles0.bin
%SJASMPLUS% %SJASMPLUSFLAGS% tiles1.ast --raw=%LOCALDIR%/tiles1.bin
%SJASMPLUS% %SJASMPLUSFLAGS% tiles2.ast --raw=%LOCALDIR%/tiles2.bin
%SJASMPLUS% %SJASMPLUSFLAGS% tiles3.ast --raw=%LOCALDIR%/tiles3.bin
rem %SJASMPLUS% %SJASMPLUSFLAGS% cursors.ast --raw=cursors.bin
rem %SJASMPLUS% %SJASMPLUSFLAGS% sprites0.ast --raw=%LOCALDIR%/sprites0.bin
rem %SJASMPLUS% %SJASMPLUSFLAGS% sprites1.ast --raw=%LOCALDIR%/sprites1.bin
sjasmplus --nologo --msg=war spr0.asm
sjasmplus --nologo --msg=war spr1.asm
sjasmplus --nologo --msg=war sprtran0.asm
sjasmplus --nologo --msg=war sprtran1.asm
sjasmplus --nologo --msg=war --msg=war VERA.asm
rem sjasmplus113 INTRO2.asm
rem sjasmplus113 VERALOAD.asm

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
rem  if "%makeall%"=="" ..\..\..\us\emul.exe
 @if "%makeall%"=="" ..\us\emul.exe
)