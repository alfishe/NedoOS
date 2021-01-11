if "%settedpath%"=="" call ../../_sdk/setpath.bat
set installdir=nedogame
if not exist nedoload mkdir nedoload
sjasmplus --nologo --msg=war --msg=war nedoload.asm
java -jar exp2hConverter.jar nedoload.exp
copy functions.h nedoload.h
java -jar exp2hConverter.jar lib_tiles.exp
copy functions.h lib_tiles.h
rem java -jar exp2hConverter.jar functions
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

set palette.0=bg.bmp

rem список изображений, откуда брать графику

set image.0=bg.bmp

rem спрайты

set sprite.0=balls.bmp

rem набор звуковых эффектов, если нужен
rem он может быть только один

set soundfx=

rem музыка, нужное число треков

set music.0=

rem сэмплы

set sample.0=

rem echo %PATH%
call ..\_sdk\_compile_nedoos.bat

echo %PATH%
perl getMainAddr.pl .\_temp_\out.map nedoload\addr.bin

copy _temp_\*.bin nedoload

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