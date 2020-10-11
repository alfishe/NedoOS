if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist sprexamp mkdir sprexamp
"../../_sdk/nedores.exe" tiles1.bmp images/tiles.dat tiles.ast
"../../_sdk/nedores.exe" images/WBAR.bmp images/WBAR.dat WBAR.ast
"../../_sdk/nedores.exe" images/WHUM1.bmp images/WHUM1.dat WHUM1.ast
"../../_sdk/nedores.exe" images/WHUM1.bmp images/pal.dat pal.ast
copy images\bg*.bmp sprexamp
rem copy images\tiles*.bmp sprexamp
copy map1.map sprexamp
copy map1.enm sprexamp
copy tiles1.bmp sprexamp
sjasmplus --nologo --msg=war --msg=war WBAR.ast --raw=sprexamp/WBAR.bin
sjasmplus --nologo --msg=war --msg=war tiles.ast --raw=sprexamp/tiles.bin
sjasmplus --nologo --msg=war --msg=war WHUM1.asm
sjasmplus --nologo --msg=war --msg=war music.asm
sjasmplus --nologo --msg=war --msg=war sfx.asm
sjasmplus --nologo --msg=war --msg=war main.asm

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