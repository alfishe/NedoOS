if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
nedotrd WOLF484.TRD -e mapatm.E
sjasmplus --nologo --msg=war -Datm=1 -Ddoublescr=1 main.asm
sjasmplus --nologo --msg=war sfx.asm
sjasmplus --nologo --msg=war music.asm
copy wolftex.bmp wolf3d
copy wolfspr.bmp wolf3d

"../../_sdk/nedores.exe" walls.bmp walls.dat walls.ast
"../../_sdk/nedores.exe" walls2.bmp walls.dat walls2.ast
rem "../../_sdk/nedores.exe" textures_01_64x64_.bmp walls.dat walls.ast
"../../_sdk/nedores.exe" goods.bmp goods.dat goods.ast
"../../_sdk/nedores.exe" goods2.bmp goods.dat goods2.ast
sjasmplus --nologo --msg=war walls.ast --raw=walls.bin
sjasmplus --nologo --msg=war walls2.ast --raw=walls2.bin
sjasmplus --nologo --msg=war goods.ast --raw=goods.bin
sjasmplus --nologo --msg=war goods2.ast --raw=goods2.bin

sjasmplus --nologo --msg=war -Datm=0 -Ddoublescr=1 W48.ASM
nedotrd basic.trd -eh boot.$b > nul
rem del test.scl
rem mhmt -mlz code.c
rem del code.c
rem copy /b depkcode.c + code.c.mlz code.c
nedotrd wolf.trd -n
nedotrd wolf.trd -ah boot.$b
nedotrd wolf.trd -ac code.c
nedotrd wolf.trd -ac hicode.c
rem nedotrd wolf.trd -ac hicode2.c

del code.bin
ren code.c code.bin
ren hicode.c hicode.bin
bas2tap -a10 loader.txt wolf.tap
bin2tap -append -a 49152 -o wolf.tap hicode.bin
bin2tap -append -a 24576 -o wolf.tap code.bin

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
 if "%makeall%"=="" ..\us\emul.exe games\wolf3d\wolf.trd
)