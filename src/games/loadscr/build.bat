if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
convega.exe kubik.bmp
copy 0kubik.bmpx loadscr\0kubik.bmpx
copy 1kubik.bmpx loadscr\1kubik.bmpx
"../../_sdk/nedores.exe" vorobey.bmp vorobey.dat vorobey.ast
"../../_sdk/nedores.exe" spr.bmp spr.dat spr.ast
"../../_sdk/nedores.exe" vorobey.bmp pal.dat sprpal.ast
sjasmplus --nologo --msg=war vorobey.ast --raw=loadscr/vorobey.bin
sjasmplus --nologo --msg=war main.asm

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