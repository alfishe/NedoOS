if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame

set NEDORES="../../_sdk/nedores.exe"
set SJASMPLUS=sjasmplus
set SJASMPLUSFLAGS=--nologo --msg=war

%NEDORES% sprites.bmp sprites.dat sprites.ast
%NEDORES% sprites.bmp pal.dat pal.ast

%SJASMPLUS% %SJASMPLUSFLAGS% wow.asm

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