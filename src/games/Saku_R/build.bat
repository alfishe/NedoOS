if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame

sjasmplus --nologo --msg=war  players\ptsplay.asm
sjasmplus --nologo --msg=war  players\s98_plr.asm
sjasmplus --nologo --msg=war  players\midi_plr.asm
sjasmplus --nologo --msg=war  players\rcp_plr.asm
sjasmplus --nologo --msg=war  players\vgm_plr.asm

sjasmplus --nologo --msg=war main.asm


SET releasedir2=../../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  move "*.com" "%releasedir2%nedogame" > nul
  IF EXIST %%~nj xcopy /Y /E "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
cd ../../../src/
call ..\tools\chkimg.bat sd
rem pause

 if "%makeall%"=="" ..\us\emul.exe
)