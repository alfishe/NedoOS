echo -----------------------------
echo %CD%

if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist nedoload mkdir nedoload
sjasmplus --nologo --msg=war --msg=war nedoload.asm
java -jar exp2hConverter.jar nedoload.exp
copy functions.h nedoload.h
del functions.h

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

rem echo %PATH%
echo -1----------------------------
rem echo %CD%
call ..\_sdk\_compile_nedoos.bat

rem echo %PATH%
echo -2----------------------------
rem echo %CD%
perl getMainAddr.pl .\_temp_\out.map nedoload\addr.bin
rem echo %PATH%
echo -3----------------------------
rem echo %CD%

copy _temp_\*.bin nedoload
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