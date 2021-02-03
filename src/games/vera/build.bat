if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist sprexamp mkdir sprexamp
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