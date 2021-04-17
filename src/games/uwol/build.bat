echo -----------------------------
echo %CD%

if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist uwol mkdir uwol
echo  db "uwol" > _temp_\sets.asm

rem имя SCL файла

set output=uwol_ay.scl

rem сообщение, которое отображается при загрузке
rem 32 символа, стандартный шрифт

set title="ZX version of SEGA Genesis Uwol"

rem список изображений, откуда брать палитры
rem в программе они вызываются по автоматически генерируемым
rem идентификаторам в файле resources.h
rem нумерация после точки должна быть возрастающей

set palette.0=gfx\tiles.bmp
set palette.1=gfx\credits.bmp
set palette.2=gfx\finbad.bmp
set palette.3=gfx\finend.bmp
set palette.4=gfx\fingoo.bmp
set palette.5=gfx\gover.bmp
set palette.6=gfx\mojon.bmp
set palette.10=gfx\title4warp0.bmp
set palette.11=gfx\title4warp1.bmp
set palette.12=gfx\title4warp2.bmp
set palette.13=gfx\title4warp3.bmp

rem список изображений, откуда брать графику

set image.0=gfx\tiles.bmp
set image.1=gfx\credits.bmp
set image.2=gfx\finbad.bmp
set image.3=gfx\finend.bmp
set image.4=gfx\fingoo.bmp
set image.5=gfx\gover.bmp
set image.6=gfx\mojon.bmp
set image.10=gfx\title4warp.bmp
set image.11=gfx\title4warp_.bmp

set image.12=gfx\tilesa.bmp
set image.13=gfx\tilesa_.bmp
rem чтобы совпадала нумерация image=pal (требуется в коде игры)

rem спрайты

set sprite.0=gfx\sprites.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=uwol.afb

rem музыка, нужное число треков

set music.0=wyz\Menu.mus
set music.1=wyz\Zona1.mus
set music.2=wyz\Zona2.mus
set music.3=wyz\Zona3.mus
set music.4=wyz\Zona4.mus
set music.5=wyz\Piramide.mus
set music.6=wyz\EndingKO.mus
set music.7=wyz\EndingOK.mus
set music.8=wyz\Fantasma.mus
set music.9=wyz\GameOver.mus

rem сэмплы

rem set sample.0=bell.wav

echo %PATH%
echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
echo -3----------------------------
rem echo %CD%
copy _temp_\*.bin uwol
copy nedoload.com uwol.com
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