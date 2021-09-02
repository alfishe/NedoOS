if "%settedpath%"=="" call ../_sdk/setpath.bat
sjasmplus --nologo --msg=war bk.asm

SET releasedir2=../../release/
if "%currentdir%"=="" (
  FOR %%j IN (*.com) DO (
  echo "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put "%%j" "/bin/%%j"
  "../../tools/dmimg.exe" ../../us/sd_nedo.vhd put "%%j" "/bin/%%j"
  move "*.com" "%releasedir2%bin" > nul
  IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%bin\%%~nj\" > nul
  )
cd ../../src/
call ..\tools\chkimg.bat sd
rem pause
rem  if "%makeall%"=="" ..\..\..\us\emul.exe
 if "%makeall%"=="" ..\us\emul.exe
)
