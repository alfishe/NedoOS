echo -----------------------------
echo %CD%

if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist touhou-zero mkdir touhou-zero
echo  db "touhou-zero" > _temp_\sets.asm

rem имя SCL файла

set output=xnx.scl

rem сообщение, которое отображается при загрузке
rem 32 символа, стандартный шрифт

set title="Girls are praying..."

rem список изображений, откуда брать палитры
rem в программе они вызываются по автоматически генерируемым
rem идентификаторам в файле resources.h
rem нумерация после точки должна быть возрастающей

set palette.0=gfx\font-16.bmp
set palette.1=gfx\title-16.bmp
set palette.2=gfx\final-16.bmp
set palette.3=gfx\sprites-16.bmp
set palette.4=gfx\bg1-16.bmp
set palette.5=gfx\bg2-16.bmp
set palette.6=gfx\bg3-16.bmp
set palette.7=gfx\bg4-16.bmp
set palette.8=gfx\bg5-16.bmp
set palette.9=gfx\bg6-16.bmp
set palette.10=gfx\bg7-16.bmp
set palette.11=gfx\bg8-16.bmp

rem список изображений, откуда брать графику

set image.0=gfx\font-16.bmp
set image.1=gfx\title-16.bmp
set image.2=gfx\final-16.bmp
rem set image.3=gfx\bg1-16.bmp
rem set image.4=gfx\bg2-16.bmp
rem set image.5=gfx\bg3-16.bmp
rem set image.6=gfx\bg4-16.bmp
rem set image.7=gfx\bg5-16.bmp
rem set image.8=gfx\bg6-16.bmp
rem set image.9=gfx\bg7-16.bmp
rem set image.10=gfx\bg8-16.bmp

rem спрайты

set sprite.0=gfx\sprites-16.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=music\sfx.afb

rem музыка, нужное число треков

set music.0=music\th0ea1.pt3
set music.1=music\nwz.pt3
set music.2=music\ea2.pt3
set music.3=music\cirno.pt3
set music.4=music\sisters.pt3
set music.5=music\glassed.pt3
set music.6=music\hard.pt3
set music.7=music\zonk.pt3
set music.8=music\th0pn.pt3
set music.9=music\win.pt3

rem сэмплы

set sample.0=

rem echo %PATH%
rem echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
echo -3----------------------------
rem echo %CD%
copy _temp_\*.bin touhou-zero
copy gfx\bg1-16.bmp touhou-zero
copy gfx\bg2-16.bmp touhou-zero
copy gfx\bg3-16.bmp touhou-zero
copy gfx\bg4-16.bmp touhou-zero
copy gfx\bg5-16.bmp touhou-zero
copy gfx\bg6-16.bmp touhou-zero
copy gfx\bg7-16.bmp touhou-zero
copy gfx\bg8-16.bmp touhou-zero
copy gfx\final-16.bmp touhou-zero
copy gfx\title-16.bmp touhou-zero
copy nedoload.com touhou-zero.com
del nedoload.com
rem echo %PATH%
echo -4----------------------------
rem echo %CD%

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