if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist numtris mkdir numtris
echo  db "numtris" > _temp_\sets.asm

rem имя SCL файла

set output=numtris.scl

rem сообщение, которое отображается при загрузке
rem 32 символа, стандартный шрифт

set title="             NUMTRIS"

rem список изображений, откуда брать палитры
rem в программе они вызываются по автоматически генерируемым
rem идентификаторам в файле resources.h
rem нумерация после точки должна быть возрастающей

set palette.0=res\box.bmp

rem список изображений, откуда брать графику

set image.0=res\back.bmp
set image.1=res\box.bmp
set image.2=res\font.bmp
set image.3=res\best.bmp
set image.4=res\gameover.bmp
set image.5=res\intro.bmp
set image.6=res\pressspace.bmp
set image.7=res\pressspace0.bmp
set image.8=res\rotor_en.bmp
set image.9=res\rotor_dis.bmp
set image.10=res\space_q0.bmp
set image.11=res\space_q1.bmp

rem спрайты

set sprite.0=res\box.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=res\numtris.afb

rem музыка, нужное число треков

set music.0=

rem сэмплы

set sample.0=

rem echo %PATH%
rem echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
rem echo -3----------------------------
rem echo %CD%
copy _temp_\*.bin numtris > nul
copy nedoload.com numtris.com > nul
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