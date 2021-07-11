if "%settedpath%"=="" call ../../_sdk/setpath.bat

"../../_sdk/convega.exe" forest00.bmp
"../../_sdk/convega.exe" forest01.bmp
"../../_sdk/convega.exe" forest02.bmp
"../../_sdk/convega.exe" forest03.bmp
"../../_sdk/convega.exe" forest10.bmp
"../../_sdk/convega.exe" forest11.bmp
"../../_sdk/convega.exe" forest12.bmp
"../../_sdk/convega.exe" forest13.bmp
"../../_sdk/convega.exe" forest20.bmp
"../../_sdk/convega.exe" forest21.bmp
"../../_sdk/convega.exe" forest22.bmp
"../../_sdk/convega.exe" forest23.bmp
"../../_sdk/convega.exe" forest30.bmp
"../../_sdk/convega.exe" forest31.bmp
"../../_sdk/convega.exe" forest32.bmp
"../../_sdk/convega.exe" forest33.bmp

rem        db 0x7, 0xe, 0x2, 0xa
rem        db 0x9, 0x0, 0xc, 0x4
rem        db 0xd, 0xb, 0x6, 0x1
rem        db 0x3, 0x5, 0x8, 0xf 
rem или ходом коня?
        
copy /b 0forest13.bmpx + 16b + 1forest13.bmpx + 16b forest.dat
copy /b forest.dat + 0forest32.bmpx + 16b + 1forest32.bmpx + 16b forest.dat
copy /b forest.dat + 0forest02.bmpx + 16b + 1forest02.bmpx + 16b forest.dat
copy /b forest.dat + 0forest22.bmpx + 16b + 1forest22.bmpx + 16b forest.dat

copy /b forest.dat + 0forest21.bmpx + 16b + 1forest21.bmpx + 16b forest.dat
copy /b forest.dat + 0forest00.bmpx + 16b + 1forest00.bmpx + 16b forest.dat
copy /b forest.dat + 0forest30.bmpx + 16b + 1forest30.bmpx + 16b forest.dat
copy /b forest.dat + 0forest10.bmpx + 16b + 1forest10.bmpx + 16b forest.dat

copy /b forest.dat + 0forest31.bmpx + 16b + 1forest31.bmpx + 16b forest.dat
copy /b forest.dat + 0forest23.bmpx + 16b + 1forest23.bmpx + 16b forest.dat
copy /b forest.dat + 0forest12.bmpx + 16b + 1forest12.bmpx + 16b forest.dat
copy /b forest.dat + 0forest01.bmpx + 16b + 1forest01.bmpx + 16b forest.dat

copy /b forest.dat + 0forest03.bmpx + 16b + 1forest03.bmpx + 16b forest.dat
copy /b forest.dat + 0forest11.bmpx + 16b + 1forest11.bmpx + 16b forest.dat
copy /b forest.dat + 0forest20.bmpx + 16b + 1forest20.bmpx + 16b forest.dat
copy /b forest.dat + 0forest33.bmpx + 16b + 1forest33.bmpx + 16b forest.dat

copy forest.dat noise\forest.dat
del forest.dat
del *.bmpx

sjasmplus --nologo --msg=war noise.asm

SET releasedir2=../../../release/
if "%currentdir%"=="" (
  @FOR %%j IN (*.com) DO (
  @"../../../tools/dmimg.exe" ../../../us/sd_nedo.vhd put %%j /nedodemo/%%j
  @move "*.com" "%releasedir2%nedodemo" > nul
  @IF EXIST %%~nj xcopy /Y "%%~nj" "%releasedir2%nedodemo\%%~nj\" > nul
  )
 rem pause
cd ../../../src/
call ..\tools\chkimg.bat sd
 if "%makeall%"=="" ..\us\emul.exe
)
