echo -----------------------------
echo %CD%

if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist 2048 mkdir 2048
echo  db "2048" > _temp_\sets.asm

rem call compile_nedoos.bat

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
set palette.0=font.bmp
set palette.1=tiles2.bmp

rem список изображений, откуда брать графику

rem set image.0=gfx\pic1.bmp
rem set image.1=gfx\pic2.bmp
rem set image.2=gfx\pic3.bmp
rem set image.3=gfx\pic4.bmp
rem set image.4=gfx\pic5.bmp
set image.0=font.bmp
set image.1=tiles2.bmp

rem спрайты

set sprite.0=

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=

rem музыка, нужное число треков

set music.0=2atststr.pt3

rem сэмплы

set sample.0=fanfare.wav
set sample.1=gong.wav

rem sjasmplus --nologo --msg=war --msg=war --exp=_temp_/nedoload.exp nedoload.asm
rem java -jar ../_sdk/exp2hConverter.jar _temp_/nedoload.exp
rem copy functions.h nedoload.h
rem del nedoload.exp
rem del functions.h

rem echo %PATH%
rem echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
echo -3----------------------------
rem echo %CD%
copy _temp_\*.bin 2048
copy nedoload.com 2048.com
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