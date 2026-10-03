if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame

"../../_sdk/nedopad.exe" lev1.$B lev1.bin 17
"../../_sdk/nedopad.exe" lev2.$B lev2.bin 17
"../../_sdk/nedopad.exe" lev3.$B lev3.bin 17
"../../_sdk/nedopad.exe" lev4.$B lev4.bin 17
"../../_sdk/nedopad.exe" lev5.$B lev5.bin 17
"../../_sdk/nedopad.exe" lev6.$B lev6.bin 17
"../../_sdk/nedopad.exe" lev7.$B lev7.bin 17
"../../_sdk/nedopad.exe" lev8.$B lev8.bin 17
"../../_sdk/nedopad.exe" lev9.$B lev9.bin 17
"../../_sdk/nedopad.exe" leva.$B leva.bin 17

cd gfx

"../../../_sdk/nedores.exe" BQCOLL.BMP spr.dat bqcoll.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP spr2.dat bqcoll2.ast
"../../../_sdk/nedores.exe" BQCOLL.BMP fontgfx.dat fontgfx.ast
"../../../_sdk/nedores.exe" tileset.bmp tileset.dat tileset.ast
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
"../../../_sdk/convega.exe" pic9.bmp
"../../../_sdk/convega.exe" pica.bmp
copy *.bmpx ..\bq2\
cd ..
copy LEV*.BIN bq2\
copy sound\*.pt3 bq2\
sjasmplus --nologo --msg=war gfx/tileset.ast --raw=gfx/tileset.C
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