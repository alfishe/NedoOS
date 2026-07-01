if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
cd gfx
"../../../_sdk/nedores.exe" BQCOLL.BMP spr.dat bqcoll.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP spr2.dat bqcoll2.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP fontgfx.dat fontgfx.ast
rem "../../../_sdk/nedores.exe" balls.bmp sprball.dat ball.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP sprball.dat ball.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP sprpal.dat sprpal.ast
"../../../_sdk/convega.exe" title.bmp
"../../../_sdk/convega.exe" pic1.bmp
"../../../_sdk/convega.exe" pic2.bmp
"../../../_sdk/convega.exe" pic3.bmp
"../../../_sdk/convega.exe" pic4.bmp
"../../../_sdk/convega.exe" pic5.bmp
"../../../_sdk/convega.exe" pic6.bmp
"../../../_sdk/convega.exe" pic7.bmp
"../../../_sdk/convega.exe" pic8.bmp
copy *.bmpx ..\bq\
cd ..
copy LEV*.BIN bq\
copy sound\*.pt3 bq\
rem sjasmplus --nologo --msg=war tcol8tocol0.asm --raw=tcol8tocol0.bin
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