if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist innsmouth mkdir innsmouth
echo  db "innsmouth" > _temp_\sets.asm

rem имя SCL файла

set output=innsmouth.scl

rem сообщение, которое отображается при загрузке
rem 32 символа, стандартный шрифт

set title="Entering into Innsmouth"

rem список изображений, откуда брать палитры
rem в программе они вызываются по автоматически генерируемым
rem идентификаторам в файле resources.h
rem нумерация после точки должна быть возрастающей

set palette.0=tiles.bmp
set palette.1=char.bmp
set palette.2=font.bmp
set palette.3=deep_one.bmp
set palette.4=gameover.bmp
set palette.5=title.bmp
set palette.6=win.bmp
rem список изображений, откуда брать графику

set image.0=tiles.bmp
set image.1=char.bmp
set image.2=font.bmp
set image.3=objects.bmp
set image.4=inventory.bmp
set image.5=sec_lay.bmp
set image.6=items.bmp
set image.7=deep_one.bmp
set image.8=scratch1.bmp
set image.9=scratch2.bmp
set image.10=roof.bmp
set image.11=basement.bmp
set image.12=gameover.bmp
set image.13=title.bmp
set image.14=win.bmp
rem спрайты

set sprite.0=char.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=

rem музыка, нужное число треков

set music.0=diamond.pt3
set music.1=diamond2.pt3

rem сэмплы

set sample.0=deepone.wav
set sample.1=slash.wav
set sample.2=inventory.wav
set sample.3=bell.wav
set sample.4=switch.wav

rem echo %PATH%
rem echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
rem echo -3----------------------------
rem echo %CD%
copy _temp_\*.bin innsmouth > nul
copy nedoload.com innsmouth.com > nul
del nedoload.com > nul
rem echo %PATH%
rem echo -4----------------------------
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