if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
cd gfx
"../../../_sdk/nedores.exe" BQCOLL.BMP spr.dat bqcoll.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP spr2.dat bqcoll2.ast
"../../../_sdk/nedores.exe" balls.bmp sprball.dat ball.ast
"../../../_sdk/convega.exe" tt6B.bmp
copy 0tt6B.bmpx ..\bq\0title.bmpx
copy 1tt6B.bmpx ..\bq\1title.bmpx
"../../../_sdk/convega.exe" pic1bigben16.bmp
copy 0pic1bigben16.bmpx ..\bq\0pic1.bmpx
copy 1pic1bigben16.bmpx ..\bq\1pic1.bmpx
"../../../_sdk/convega.exe" pic2mayak16.bmp
copy 0pic2mayak16.bmpx ..\bq\0pic2.bmpx
copy 1pic2mayak16.bmpx ..\bq\1pic2.bmpx
"../../../_sdk/convega.exe" pic3tubes16b.bmp
copy 0pic3tubes16b.bmpx ..\bq\0pic3.bmpx
copy 1pic3tubes16b.bmpx ..\bq\1pic3.bmpx
"../../../_sdk/convega.exe" pic4modern16.bmp
copy 0pic4modern16.bmpx ..\bq\0pic4.bmpx
copy 1pic4modern16.bmpx ..\bq\1pic4.bmpx
"../../../_sdk/convega.exe" pic5skyscr.bmp
copy 0pic5skyscr.bmpx ..\bq\0pic5.bmpx
copy 1pic5skyscr.bmpx ..\bq\1pic5.bmpx
"../../../_sdk/convega.exe" pic6skyscrappers2.bmp
copy 0pic6skyscrappers2.bmpx ..\bq\0pic6.bmpx
copy 1pic6skyscrappers2.bmpx ..\bq\1pic6.bmpx
"../../../_sdk/convega.exe" pic7skysc16.bmp
copy 0pic7skysc16.bmpx ..\bq\0pic7.bmpx
copy 1pic7skysc16.bmpx ..\bq\1pic7.bmpx
"../../../_sdk/convega.exe" pic8skysc316.bmp
copy 0pic8skysc316.bmpx ..\bq\0pic8.bmpx
copy 1pic8skysc316.bmpx ..\bq\1pic8.bmpx
cd ..
copy LEV*.BIN bq\
copy sound\*.pt3 bq\
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