if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
"../../_sdk/convega.exe" pic0.bmp
copy 0pic0.bmpx puzzle\0pic0.bmpx
copy 1pic0.bmpx puzzle\1pic0.bmpx
"../../_sdk/nedores.exe" pic0.bmp pal.dat pal.ast
"../../_sdk/convega.exe" grid.bmp
copy 0grid.bmpx puzzle\0grid.bmpx
copy 1grid.bmpx puzzle\1grid.bmpx
"../../_sdk/nedores.exe" spr.bmp spr.dat spr.ast
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