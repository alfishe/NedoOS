if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist balls mkdir balls
echo  db "balls" > _temp_\sets.asm

rem имя SCL файла

set output=empty.scl

rem сообщение, которое отображается при загрузке
rem 32 символа, стандартный шрифт

set title=" NOTHING IS LOADING"

rem список изображений, откуда брать палитры
rem в программе они вызываются по автоматически генерируемым
rem идентификаторам в файле resources.h
rem нумерация после точки должна быть возрастающей

rem set palette.0=gfx\pic1.bmp
rem set palette.1=gfx\pic2.bmp
rem set palette.2=gfx\pic3.bmp
rem set palette.3=gfx\pic4.bmp
rem set palette.4=gfx\pic5.bmp
set palette.0=back.bmp
set palette.1=balls.bmp

rem список изображений, откуда брать графику

rem set image.0=gfx\pic1.bmp
rem set image.1=gfx\pic2.bmp
rem set image.2=gfx\pic3.bmp
rem set image.3=gfx\pic4.bmp
rem set image.4=gfx\pic5.bmp
set image.0=back.bmp
set image.1=font.bmp
set image.2=tiles.bmp

rem спрайты

set sprite.0=balls.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=balls.afb

rem музыка, нужное число треков

set music.0=

rem сэмплы

rem set sample.0=fanfare.wav
rem set sample.1=gong.wav

rem echo %PATH%
rem echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
rem echo -3----------------------------
rem echo %CD%
copy _temp_\*.bin balls > nul
copy nedoload.com balls.com > nul
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