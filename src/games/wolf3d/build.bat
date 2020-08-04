if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
nedotrd WOLF484.TRD -e mapatm.E
sjasmplus --nologo --msg=war main.asm
copy wolftex.bmp wolf3d
copy wolfspr.bmp wolf3d

SET releasedir2=../../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  "../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedogame/%%j
  move "*.com" "%releasedir2%nedogame" > nul
  IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%nedogame\%%~nj\" > nul
  )
cd ../../../src/
call ..\tools\chkimg.bat sd
 pause
rem  if "%makeall%"=="" ..\..\..\us\emul.exe
 if "%makeall%"=="" ..\us\emul.exe
)