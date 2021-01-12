if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
..\..\_sdk\convega.exe midnight.bmp
copy 0midnight.bmpx midnight\0midnigh.bmx
copy 1midnight.bmpx midnight\1midnigh.bmx
rem "../../_sdk/nedores.exe" slabtile.bmp tiles.dat tiles.ast
rem "../../_sdk/nedores.exe" slabpane.bmp panel.dat panel.ast
rem "../../_sdk/nedores.exe" slabspr.bmp sprites.dat sprites.ast
rem "../../_sdk/nedores.exe" slabspr.bmp pal.dat pal.ast
rem sjasmplus --nologo --msg=war sprdata.asm
rem sjasmplus --nologo --msg=war tiles.ast --raw=slabage/tiles.bin
rem sjasmplus --nologo --msg=war panel.ast --raw=slabage/panel.bin
sjasmplus --nologo --msg=war 1.asm

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