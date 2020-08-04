if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist nedoload mkdir nedoload
sjasmplus --nologo --msg=war --msg=war nedoload.asm
java -jar exp2hConverter.jar nedoload.exp
copy functions.h nedoload.h
java -jar exp2hConverter.jar lib_tiles.exp
copy functions.h lib_tiles.h
rem java -jar exp2hConverter.jar functions
del functions.h

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