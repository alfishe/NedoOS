if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
"../../_sdk/nedores.exe" image.bmp tiles.dat tiles.ast
"../../_sdk/nedores.exe" image.bmp font.dat font.ast
"../../_sdk/nedores.exe" image.bmp sprites.dat sprites.ast
"../../_sdk/nedores.exe" image.bmp spr1.dat spr1.ast
"../../_sdk/nedores.exe" image.bmp spr2.dat spr2.ast
"../../_sdk/nedores.exe" image.bmp spr3.dat spr3.ast
"../../_sdk/nedores.exe" image.bmp pal.dat pal.ast
sjasmplus --nologo --msg=war spr0.asm
sjasmplus --nologo --msg=war spr1.asm
sjasmplus --nologo --msg=war spr2.asm
sjasmplus --nologo --msg=war spr3.asm
sjasmplus --nologo --msg=war tiles.ast --raw=zxbattle/tiles.bin
sjasmplus --nologo --msg=war font.ast --raw=zxbattle/font.bin
sjasmplus --nologo --msg=war -DCLIENT=0 main.asm
sjasmplus --nologo --msg=war main.asm
sjasmplus --nologo --msg=war -DCLIENT=1 main.asm

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